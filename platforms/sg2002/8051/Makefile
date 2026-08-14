SDCC ?= sdcc
SDOBJCOPY ?= sdobjcopy
TARGET_CC ?= riscv64-linux-gnu-gcc-12

BUILD_DIR := build
SHT31_FIRMWARE := $(BUILD_DIR)/mars_mcu_fw_sht31.bin
SHT31_IHX := $(BUILD_DIR)/matter_sensor_8051_sht31.ihx
FAKE_FIRMWARE := $(BUILD_DIR)/mars_mcu_fw_fake.bin
FAKE_IHX := $(BUILD_DIR)/fake_sensor_8051.ihx
BENCHMARK_FIRMWARE := $(BUILD_DIR)/robot_read_benchmark.bin
BENCHMARK_IHX := $(BUILD_DIR)/robot_read_benchmark.ihx
LOADER := $(BUILD_DIR)/8051_up
CODE_LIMIT := 8192

LED_GPIO_BASE ?= 0x05021000
LED_GPIO_PIN ?= 20

SDCC_CFLAGS := -mmcs51 --model-large --code-loc 0x0000 --code-size 0x2000 \
	--xram-loc 0x2000 --xram-size 0x0400 --stack-auto --int-long-reent \
	--std-c11 --Werror -DLED_GPIO_BASE=$(LED_GPIO_BASE) -DLED_GPIO_PIN=$(LED_GPIO_PIN)
LOADER_CFLAGS := -std=c11 -O2 -Wall -Wextra -Werror -static

.PHONY: all benchmark clean check-loader-tools check-size check-tools fake i2c loader sht31

all: check-tools $(SHT31_FIRMWARE) $(FAKE_FIRMWARE) check-size

fake: check-tools $(FAKE_FIRMWARE) check-size

benchmark: check-tools $(BENCHMARK_FIRMWARE) check-benchmark-size

sht31 i2c: check-tools $(SHT31_FIRMWARE) check-size

check-tools:
	@command -v "$(SDCC)" >/dev/null || { echo "SDCC compiler not found; install the host package: sudo apt install sdcc" >&2; exit 2; }
	@command -v "$(SDOBJCOPY)" >/dev/null || { echo "sdobjcopy not found; install the host package: sudo apt install sdcc" >&2; exit 2; }

check-loader-tools:
	@command -v "$(TARGET_CC)" >/dev/null || { echo "RISC-V compiler not found; install gcc-12-riscv64-linux-gnu" >&2; exit 2; }

$(BUILD_DIR):
	mkdir -p $@

$(FAKE_IHX): fake-firmware.c | $(BUILD_DIR)
	$(SDCC) $(SDCC_CFLAGS) -o $@ $<

$(FAKE_FIRMWARE): $(FAKE_IHX)
	$(SDOBJCOPY) -I ihex -O binary $< $@

$(BENCHMARK_IHX): robot-read-benchmark.c | $(BUILD_DIR)
	$(SDCC) $(SDCC_CFLAGS) -o $@ $<

$(BENCHMARK_FIRMWARE): $(BENCHMARK_IHX)
	$(SDOBJCOPY) -I ihex -O binary $< $@

$(SHT31_IHX): sht31-firmware.c | $(BUILD_DIR)
	$(SDCC) $(SDCC_CFLAGS) -o $@ $<

$(SHT31_FIRMWARE): $(SHT31_IHX)
	$(SDOBJCOPY) -I ihex -O binary $< $@

check-size: $(SHT31_FIRMWARE) $(FAKE_FIRMWARE)
	@for image in $^; do \
		size=$$(wc -c <"$$image"); \
		if [ "$$size" -gt "$(CODE_LIMIT)" ]; then \
			echo "$$image is $$size bytes; SG2002 RTC SRAM limit is $(CODE_LIMIT)" >&2; \
			exit 1; \
		fi; \
		echo "$$image: $$size / $(CODE_LIMIT) bytes"; \
	done

check-benchmark-size: $(BENCHMARK_FIRMWARE)
	@size=$$(wc -c <"$(BENCHMARK_FIRMWARE)"); \
	if [ "$$size" -gt "$(CODE_LIMIT)" ]; then \
		echo "$(BENCHMARK_FIRMWARE) is $$size bytes; SG2002 RTC SRAM limit is $(CODE_LIMIT)" >&2; \
		exit 1; \
	fi; \
	echo "$(BENCHMARK_FIRMWARE): $$size / $(CODE_LIMIT) bytes"

loader: check-loader-tools $(LOADER)

$(LOADER): 8051_up.c | $(BUILD_DIR)
	$(TARGET_CC) $(LOADER_CFLAGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIR)
