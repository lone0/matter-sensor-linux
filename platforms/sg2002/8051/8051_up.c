#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

#define RTC_SRAM_BASE 0x05200000UL
#define RTC_SRAM_SIZE 8192U
#define TOP_RTC_BUS_ENABLE 0x03000248UL
#define RTC_8051_RESET 0x05025018UL
#define RTC_8051_BOOT 0x05025020UL

static const char *default_firmware = "/lib/firmware/mars_mcu_fw_sht31.bin";

static int load_firmware(const char *path, uint8_t image[RTC_SRAM_SIZE], size_t *image_size)
{
    int fd;
    ssize_t bytes;
    struct stat stat_buffer;

    fd = open(path, O_RDONLY);
    if (fd < 0) {
        return -1;
    }
    if (fstat(fd, &stat_buffer) != 0 || stat_buffer.st_size <= 0 || stat_buffer.st_size > RTC_SRAM_SIZE) {
        close(fd);
        errno = EFBIG;
        return -1;
    }

    *image_size = (size_t) stat_buffer.st_size;
    bytes = read(fd, image, *image_size);
    close(fd);
    if (bytes != (ssize_t) *image_size) {
        errno = EIO;
        return -1;
    }
    return 0;
}

static int write_8051_firmware(const uint8_t image[RTC_SRAM_SIZE], size_t image_size)
{
    int fd;
    size_t map_length;
    size_t offset;
    volatile uint32_t *registers;
    volatile uint32_t *sram;
    volatile uint32_t *top;

    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        return -1;
    }

    map_length = 0x27000U;
    registers = mmap(NULL, map_length, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0x05000000UL);
    if (registers == MAP_FAILED) {
        close(fd);
        return -1;
    }
    top = mmap(NULL, 0x1000U, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0x03000000UL);
    if (top == MAP_FAILED) {
        munmap((void *) registers, map_length);
        close(fd);
        return -1;
    }
    sram = mmap(NULL, RTC_SRAM_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, RTC_SRAM_BASE);
    if (sram == MAP_FAILED) {
        munmap((void *) top, 0x1000U);
        munmap((void *) registers, map_length);
        close(fd);
        return -1;
    }

    registers[(RTC_8051_RESET - 0x05000000UL) / sizeof(uint32_t)] = 0x8107fffdU;
    for (offset = 0; offset < RTC_SRAM_SIZE; offset += sizeof(uint32_t)) {
        uint32_t word = 0;
        size_t byte;

        for (byte = 0; byte < sizeof(word) && offset + byte < image_size; ++byte) {
            word |= (uint32_t) image[offset + byte] << (8U * byte);
        }
        sram[offset / sizeof(uint32_t)] = word;
    }

    top[(TOP_RTC_BUS_ENABLE - 0x03000000UL) / sizeof(uint32_t)] = 0x1U;
    registers[(RTC_8051_BOOT - 0x05000000UL) / sizeof(uint32_t)] =
        (RTC_SRAM_BASE & 0xfffff000UL) | 0x84U;
    registers[(RTC_8051_RESET - 0x05000000UL) / sizeof(uint32_t)] = 0x8107ffffU;

    munmap((void *) sram, RTC_SRAM_SIZE);
    munmap((void *) top, 0x1000U);
    munmap((void *) registers, map_length);
    close(fd);
    return 0;
}

int main(int argc, char *argv[])
{
    uint8_t image[RTC_SRAM_SIZE];
    size_t image_size;
    const char *firmware = default_firmware;

    if (argc == 2) {
        firmware = argv[1];
    } else if (argc > 2) {
        fprintf(stderr, "usage: %s [firmware]\n", argv[0]);
        return 2;
    }

    if (load_firmware(firmware, image, &image_size) != 0) {
        if (strcmp(firmware, default_firmware) != 0 ||
            load_firmware("mars_mcu_fw_sht31.bin", image, &image_size) != 0) {
            fprintf(stderr, "cannot load firmware: %s\n", strerror(errno));
            return 1;
        }
        firmware = "mars_mcu_fw_sht31.bin";
    }
    if (write_8051_firmware(image, image_size) != 0) {
        fprintf(stderr, "cannot load 8051 firmware through /dev/mem: %s\n", strerror(errno));
        return 1;
    }

    printf("loaded %zu bytes from %s\n", image_size, firmware);
    return 0;
}
