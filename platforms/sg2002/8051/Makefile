SDCC ?= sdcc
SDOBJCOPY ?= sdobjcopy
TARGET_CC ?= riscv64-linux-gnu-gcc-12

BUILD_DIR := build
FIRMWARE := $(BUILD_DIR)/mars_mcu_fw.bin
IHX := $(BUILD_DIR)/matter_sensor_8051.ihx
LOADER := $(BUILD_DIR)/8051_up
CODE_LIMIT := 8192

# Override only after the board-side preflight confirms these header GPIOs are free.
DHT_GPIO_PIN ?= 26
LED_GPIO_BASE ?= 0x05021000
LED_GPIO_PIN ?= 20

SDCC_CFLAGS := -mmcs51 --model-large --code-loc 0x0000 --code-size 0x2000 \
	--xram-loc 0x2000 --xram-size 0x0400 --stack-auto --int-long-reent \
	--std-c11 --Werror -DDHT_GPIO_PIN=$(DHT_GPIO_PIN) \
	-DLED_GPIO_BASE=$(LED_GPIO_BASE) -DLED_GPIO_PIN=$(LED_GPIO_PIN)
LOADER_CFLAGS := -std=c11 -O2 -Wall -Wextra -Werror -static

.PHONY: all clean check-loader-tools check-size check-tools loader

all: check-tools $(FIRMWARE) check-size

check-tools:
	@command -v "$(SDCC)" >/dev/null || { echo "SDCC compiler not found; install the host package: sudo apt install sdcc" >&2; exit 2; }
	@command -v "$(SDOBJCOPY)" >/dev/null || { echo "sdobjcopy not found; install the host package: sudo apt install sdcc" >&2; exit 2; }

check-loader-tools:
	@command -v "$(TARGET_CC)" >/dev/null || { echo "RISC-V compiler not found; install gcc-12-riscv64-linux-gnu" >&2; exit 2; }

$(BUILD_DIR):
	mkdir -p $@

$(IHX): firmware.c | $(BUILD_DIR)
	$(SDCC) $(SDCC_CFLAGS) -o $@ $<

$(FIRMWARE): $(IHX)
	$(SDOBJCOPY) -I ihex -O binary $< $@

check-size: $(FIRMWARE)
	@size=$$(wc -c <"$(FIRMWARE)"); \
	if [ "$$size" -gt "$(CODE_LIMIT)" ]; then \
		echo "$(FIRMWARE) is $$size bytes; SG2002 RTC SRAM limit is $(CODE_LIMIT)" >&2; \
		exit 1; \
	fi; \
	echo "$(FIRMWARE): $$size / $(CODE_LIMIT) bytes"

loader: check-loader-tools $(LOADER)

$(LOADER): 8051_up.c | $(BUILD_DIR)
	$(TARGET_CC) $(LOADER_CFLAGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIR)
