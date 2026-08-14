/*
 * SG2002 8051 fixed-reading publisher for Matter commissioning and diagnostics.
 *
 * This intentionally does not access a physical sensor. It publishes 23.45 C
 * and 56.78 % through the same RTC information-register ABI as production.
 */

typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;

#ifndef LED_GPIO_PIN
#define LED_GPIO_PIN 20
#endif

#ifndef LED_GPIO_BASE
#define LED_GPIO_BASE 0x05021000UL
#endif

#define RTC_TIMER_BASE 0x05020000UL
#define RTC_TIMER_CONTROL (RTC_TIMER_BASE + 0x008UL)
#define RTC_TIMER_EOI (RTC_TIMER_BASE + 0x00CUL)
#define RTC_TIMER_INTSTATUS (RTC_TIMER_BASE + 0x010UL)
#define RTC_TIMER_TICKS_PER_MILLISECOND 25000UL
#define RTC_INFO0 0x0502601CUL
#define RTC_INFO2 0x05026024UL
#define RTC_INFO3 0x05026028UL

#define GPIO_DATA 0x000UL
#define GPIO_DIRECTION 0x004UL

#define STATUS_FAKE 0x46414B45UL /* "FAKE" */
#define FIXED_TEMPERATURE_CENTI_C 2345U
#define FIXED_HUMIDITY_CENTI_PERCENT 5678U

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
__sbit __at (0xAF) ea;

static uint32_t robot_read(uint32_t address)
{
    uint32_t value;
    uint8_t interrupts_enabled = ea;

    ea = 0;
    r51_addr0 = (uint8_t) address;
    r51_addr1 = (uint8_t) (address >> 8);
    r51_addr2 = (uint8_t) (address >> 16);
    r51_addr3 = (uint8_t) (address >> 24);
    r51_write_enable = 4;
    r51_fire = 1;
    while (r51_fire == 1) {
    }
    value = (uint32_t) r51_rd0;
    value |= (uint32_t) r51_rd1 << 8;
    value |= (uint32_t) r51_rd2 << 16;
    value |= (uint32_t) r51_rd3 << 24;
    ea = interrupts_enabled;
    return value;
}

static void robot_write(uint32_t address, uint32_t value)
{
    uint8_t interrupts_enabled = ea;

    ea = 0;
    r51_addr0 = (uint8_t) address;
    r51_addr1 = (uint8_t) (address >> 8);
    r51_addr2 = (uint8_t) (address >> 16);
    r51_addr3 = (uint8_t) (address >> 24);
    r51_wd0 = (uint8_t) value;
    r51_wd1 = (uint8_t) (value >> 8);
    r51_wd2 = (uint8_t) (value >> 16);
    r51_wd3 = (uint8_t) (value >> 24);
    r51_write_enable = 5;
    r51_fire = 1;
    while (r51_fire == 1) {
    }
    ea = interrupts_enabled;
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

static void delay_ms(uint16_t milliseconds)
{
    robot_write(RTC_TIMER_CONTROL, 0);
    robot_write(RTC_TIMER_BASE, (uint32_t) milliseconds * RTC_TIMER_TICKS_PER_MILLISECOND);
    robot_write(RTC_TIMER_CONTROL, 3);
    while ((robot_read(RTC_TIMER_INTSTATUS) & 1U) == 0U) {
    }
    robot_read(RTC_TIMER_EOI);
}

static void publish_reading(uint32_t *sequence)
{
    uint32_t packed = ((uint32_t) FIXED_HUMIDITY_CENTI_PERCENT << 16) |
                      FIXED_TEMPERATURE_CENTI_C;

    robot_write(RTC_INFO2, packed);
    ++*sequence;
    if (*sequence == 0UL) {
        ++*sequence;
    }
    robot_write(RTC_INFO3, *sequence);
    robot_write(RTC_INFO0, STATUS_FAKE);
}

void main(void)
{
    uint8_t led_on = 0;
    uint32_t sequence = 0;

    gpio_write(LED_GPIO_BASE, LED_GPIO_PIN, 0);
    gpio_output(LED_GPIO_BASE, LED_GPIO_PIN);

    for (;;) {
        gpio_write(LED_GPIO_BASE, LED_GPIO_PIN, led_on);
        led_on = (uint8_t) !led_on;
        publish_reading(&sequence);
        delay_ms(1000);
    }
}
