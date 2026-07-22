/*
 * SG2002 8051 DHT11 publisher.
 *
 * DHT_GPIO_PIN and LED_GPIO_PIN are GPIO line numbers. The Nano defaults use
 * header GPIOA26 for DHT11 and RTC power GPIO20 (GPIOP20) for an external LED.
 * The board-side preparation script must place both pads in GPIO mode before
 * this firmware starts, and the two pins must remain electrically separate.
 */

typedef unsigned char uint8_t;
typedef signed int int16_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;

#ifndef DHT_GPIO_PIN
#define DHT_GPIO_PIN 26
#endif

#ifndef LED_GPIO_PIN
#define LED_GPIO_PIN 3
#endif

#ifndef LED_GPIO_BASE
#define LED_GPIO_BASE 0x05021000UL
#endif

#define DHT_GPIO_BASE 0x03020000UL

#if DHT_GPIO_PIN > 31 || LED_GPIO_PIN > 31 || \
    (DHT_GPIO_BASE == LED_GPIO_BASE && DHT_GPIO_PIN == LED_GPIO_PIN)
#error "DHT and LED pins must be distinct AP GPIO lines in 0..31"
#endif

#define GPIO_DATA 0x000UL
#define GPIO_DIRECTION 0x004UL
#define GPIO_EXTERNAL_PORT 0x050UL

#define RTC_TIMER_BASE 0x05020000UL
#define RTC_TIMER_LOAD RTC_TIMER_BASE
#define RTC_TIMER_CONTROL (RTC_TIMER_BASE + 0x008UL)
#define RTC_TIMER_EOI (RTC_TIMER_BASE + 0x00cUL)
#define RTC_TIMER_INTSTATUS (RTC_TIMER_BASE + 0x010UL)
#define RTC_TIMER_TICKS_PER_MILLISECOND 25000UL

#define RTC_INFO0 0x0502601CUL
#define RTC_INFO2 0x05026024UL
#define RTC_INFO3 0x05026028UL

#define STATUS_RUNNING 0x424C4E4BUL /* "BLNK" */
#define STATUS_NO_RESPONSE 0x45523031UL /* "ER01" */
#define STATUS_TIMING 0x45523032UL /* "ER02" */
#define STATUS_CHECKSUM 0x45523033UL /* "ER03" */
#define STATUS_RANGE 0x45523034UL /* "ER04" */

#define DHT_START_LOW_MS 20U
#define DHT_RESPONSE_DELAY_US 40U
#define DHT_BIT_SAMPLE_US 40U
#define DHT_WAIT_POLLS 255U

__sfr __at (0xE4) r51_rd0;
__sfr __at (0xE5) r51_rd1;
__sfr __at (0xE6) r51_rd2;
__sfr __at (0xE7) r51_rd3;
__sfr __at (0xF2) r51_fire;
__sfr __at (0xF3) r51_write_enable;
__sfr __at (0xF4) r51_wd0;
__sfr __at (0xF5) r51_wd1;
__sfr __at (0xF6) r51_wd2;
__sfr __at (0xF7) r51_wd3;
__sfr __at (0xF8) r51_addr0;
__sfr __at (0xF9) r51_addr1;
__sfr __at (0xFA) r51_addr2;
__sfr __at (0xFB) r51_addr3;
__sbit __at (0xAF) EA;

static uint32_t robot_read(uint32_t address) __reentrant
{
    uint32_t value;
    uint8_t interrupts_enabled = EA;

    EA = 0;
    r51_addr0 = (uint8_t) address;
    r51_addr1 = (uint8_t) (address >> 8);
    r51_addr2 = (uint8_t) (address >> 16);
    r51_addr3 = (uint8_t) (address >> 24);
    r51_write_enable = 4; /* 32-bit read */
    r51_fire = 1;
    while (r51_fire == 1) {
    }

    value = (uint32_t) r51_rd0;
    value |= (uint32_t) r51_rd1 << 8;
    value |= (uint32_t) r51_rd2 << 16;
    value |= (uint32_t) r51_rd3 << 24;
    EA = interrupts_enabled;
    return value;
}

static void robot_write(uint32_t address, uint32_t value) __reentrant
{
    uint8_t interrupts_enabled = EA;

    EA = 0;
    r51_addr0 = (uint8_t) address;
    r51_addr1 = (uint8_t) (address >> 8);
    r51_addr2 = (uint8_t) (address >> 16);
    r51_addr3 = (uint8_t) (address >> 24);
    r51_wd0 = (uint8_t) value;
    r51_wd1 = (uint8_t) (value >> 8);
    r51_wd2 = (uint8_t) (value >> 16);
    r51_wd3 = (uint8_t) (value >> 24);
    r51_write_enable = 5; /* 32-bit write */
    r51_fire = 1;
    while (r51_fire == 1) {
    }
    EA = interrupts_enabled;
}

static void gpio_write(uint32_t base, uint8_t pin, uint8_t high)
{
    uint32_t value = robot_read(base + GPIO_DATA);
    uint32_t mask = (uint32_t) 1U << pin;

    robot_write(base + GPIO_DATA, high ? value | mask : value & ~mask);
}

static void gpio_output(uint32_t base, uint8_t pin)
{
    uint32_t value = robot_read(base + GPIO_DIRECTION);

    robot_write(base + GPIO_DIRECTION, value | ((uint32_t) 1U << pin));
}

static void gpio_input(uint32_t base, uint8_t pin)
{
    uint32_t value = robot_read(base + GPIO_DIRECTION);

    robot_write(base + GPIO_DIRECTION, value & ~((uint32_t) 1U << pin));
}

static uint8_t gpio_read(uint32_t base, uint8_t pin)
{
    return (uint8_t) ((robot_read(base + GPIO_EXTERNAL_PORT) >> pin) & 1U);
}

/*
 * The 8051 instruction timing is verified on hardware through the LED/status
 * path first.  These conservative delays match the vendor base firmware's
 * unoptimised busy-wait approach and can be tuned without changing the ABI.
 */
static void delay_us(uint16_t microseconds)
{
    volatile uint8_t loops;

    while (microseconds-- != 0U) {
        loops = 10;
        while (loops-- != 0U) {
        }
    }
}

static void delay_ms(uint16_t milliseconds)
{
    robot_write(RTC_TIMER_CONTROL, 0);
    robot_write(RTC_TIMER_LOAD, (uint32_t) milliseconds * RTC_TIMER_TICKS_PER_MILLISECOND);
    robot_write(RTC_TIMER_CONTROL, 3);
    while ((robot_read(RTC_TIMER_INTSTATUS) & 1U) == 0U) {
    }
    robot_read(RTC_TIMER_EOI);
}

static uint8_t wait_for_level(uint8_t level)
{
    uint8_t polls = DHT_WAIT_POLLS;

    while (polls-- != 0U) {
        if (gpio_read(DHT_GPIO_BASE, DHT_GPIO_PIN) == level) {
            return 1;
        }
    }
    return 0;
}

static uint8_t dht11_read(uint8_t bytes[5])
{
    uint8_t byte_index;
    uint8_t bit_index;
    uint8_t value;

    gpio_write(DHT_GPIO_BASE, DHT_GPIO_PIN, 0);
    gpio_output(DHT_GPIO_BASE, DHT_GPIO_PIN);
    delay_ms(DHT_START_LOW_MS);
    gpio_input(DHT_GPIO_BASE, DHT_GPIO_PIN);
    delay_us(DHT_RESPONSE_DELAY_US);

    if (!wait_for_level(0) || !wait_for_level(1) || !wait_for_level(0)) {
        return 1;
    }

    for (byte_index = 0; byte_index < 5; ++byte_index) {
        value = 0;
        for (bit_index = 0; bit_index < 8; ++bit_index) {
            if (!wait_for_level(1)) {
                return 2;
            }
            delay_us(DHT_BIT_SAMPLE_US);
            value = (uint8_t) ((value << 1) | gpio_read(DHT_GPIO_BASE, DHT_GPIO_PIN));
            if (!wait_for_level(0)) {
                return 2;
            }
        }
        bytes[byte_index] = value;
    }

    if ((uint8_t) (bytes[0] + bytes[1] + bytes[2] + bytes[3]) != bytes[4]) {
        return 3;
    }
    return 0;
}

static uint8_t publish_reading(const uint8_t bytes[5], uint32_t *sequence)
{
    int16_t temperature;
    uint16_t humidity;
    uint32_t packed;

    humidity = (uint16_t) bytes[0] * 100U + bytes[1];
    temperature = (int16_t) ((uint16_t) (bytes[2] & 0x7fU) * 100U + bytes[3]);
    if ((bytes[2] & 0x80U) != 0U) {
        temperature = -temperature;
    }
    if (humidity > 10000U || temperature < -4000 || temperature > 8000) {
        return 0;
    }

    packed = ((uint32_t) humidity << 16) | (uint16_t) temperature;
    robot_write(RTC_INFO2, packed);
    ++*sequence;
    if (*sequence == 0UL) {
        ++*sequence;
    }
    robot_write(RTC_INFO3, *sequence);
    robot_write(RTC_INFO0, STATUS_RUNNING);
    return 1;
}

void main(void)
{
    uint8_t bytes[5];
    uint8_t result;
    uint8_t led_on = 0;
    uint32_t sequence = 0;

    gpio_write(LED_GPIO_BASE, LED_GPIO_PIN, 0);
    gpio_output(LED_GPIO_BASE, LED_GPIO_PIN);
    gpio_input(DHT_GPIO_BASE, DHT_GPIO_PIN);
    robot_write(RTC_INFO0, STATUS_RUNNING);

    for (;;) {
        gpio_write(LED_GPIO_BASE, LED_GPIO_PIN, led_on);
        led_on = (uint8_t) !led_on;
        result = dht11_read(bytes);
        if (result == 1U) {
            robot_write(RTC_INFO0, STATUS_NO_RESPONSE);
        } else if (result == 2U) {
            robot_write(RTC_INFO0, STATUS_TIMING);
        } else if (result == 3U) {
            robot_write(RTC_INFO0, STATUS_CHECKSUM);
        } else if (!publish_reading(bytes, &sequence)) {
            robot_write(RTC_INFO0, STATUS_RANGE);
        }
        delay_ms(1000);
    }
}
