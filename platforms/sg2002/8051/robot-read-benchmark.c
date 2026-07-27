/*
 * SG2002 8051 robot-read benchmark.
 *
 * RTC_INFO0: "BMRN" while running, "BMOK" after a valid sample, "OVFL" if a
 * timer overflow cannot be accounted for.
 * RTC_INFO1: calibrated Timer0 ticks per second.
 * RTC_INFO2: total Timer0 ticks for 100 robot_read(GPIOA external port) calls.
 * RTC_INFO3: sample count (100).
 */

typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;

#define GPIOA_BASE 0x03020000UL
#define GPIO_EXTERNAL_PORT 0x050UL
#define RTC_TIMER_BASE 0x05020000UL
#define RTC_TIMER_CONTROL (RTC_TIMER_BASE + 0x008UL)
#define RTC_TIMER_EOI (RTC_TIMER_BASE + 0x00cUL)
#define RTC_TIMER_INTSTATUS (RTC_TIMER_BASE + 0x010UL)
#define RTC_TIMER_TICKS_PER_SECOND 25000000UL
#define RTC_INFO0 0x0502601CUL
#define RTC_INFO1 0x05026020UL
#define RTC_INFO2 0x05026024UL
#define RTC_INFO3 0x05026028UL
#define CALIBRATION_SECONDS 1UL
#define BENCHMARK_READS 10000U

#define STATUS_RUNNING 0x424D524EUL /* "BMRN" */
#define STATUS_COMPLETE 0x424D4F4BUL /* "BMOK" */
#define STATUS_OVERFLOW 0x4F56464CUL /* "OVFL" */

__sfr __at (0x88) tcon;
__sfr __at (0x89) tmod;
__sfr __at (0x8a) tl0;
__sfr __at (0x8c) th0;
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
__sbit __at (0x8c) tr0;
__sbit __at (0x8d) tf0;
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

static void timer0_start(void)
{
    tmod = (uint8_t) ((tmod & 0xf0U) | 0x01U);
    tr0 = 0;
    tf0 = 0;
    th0 = 0;
    tl0 = 0;
    tr0 = 1;
}

static uint32_t timer0_stop(uint16_t overflows)
{
    uint16_t low;

    tr0 = 0;
    if (tf0 != 0) {
        ++overflows;
        tf0 = 0;
    }
    low = ((uint16_t) th0 << 8) | tl0;
    return ((uint32_t) overflows << 16) | low;
}

static uint8_t timer0_record_overflow(uint16_t *overflows)
{
    if (tf0 == 0) {
        return 1;
    }
    tf0 = 0;
    if (*overflows == 0xffffU) {
        return 0;
    }
    ++*overflows;
    return 1;
}

static uint32_t calibrate_timer0(uint8_t *valid)
{
    uint16_t overflows = 0;

    robot_write(RTC_TIMER_CONTROL, 0);
    robot_write(RTC_TIMER_BASE, RTC_TIMER_TICKS_PER_SECOND * CALIBRATION_SECONDS);
    timer0_start();
    robot_write(RTC_TIMER_CONTROL, 3);
    while ((robot_read(RTC_TIMER_INTSTATUS) & 1U) == 0U) {
        if (!timer0_record_overflow(&overflows)) {
            *valid = 0;
            return 0;
        }
    }
    robot_read(RTC_TIMER_EOI);
    *valid = 1;
    return timer0_stop(overflows);
}

static uint32_t benchmark_robot_read(uint8_t *valid)
{
    uint16_t overflows = 0;
    uint16_t index;
    uint32_t sink = 0;

    timer0_start();
    for (index = 0; index < BENCHMARK_READS; ++index) {
        sink ^= robot_read(GPIOA_BASE + GPIO_EXTERNAL_PORT);
        if (!timer0_record_overflow(&overflows)) {
            *valid = 0;
            return 0;
        }
    }
    if (sink == 0xffffffffUL) {
        robot_write(RTC_INFO0, STATUS_RUNNING);
    }
    *valid = 1;
    return timer0_stop(overflows);
}

void main(void)
{
    uint8_t valid;
    uint32_t timer_ticks_per_second;
    uint32_t total_ticks;

    robot_write(RTC_INFO0, STATUS_RUNNING);
    timer_ticks_per_second = calibrate_timer0(&valid);
    if (valid == 0) {
        robot_write(RTC_INFO0, STATUS_OVERFLOW);
        for (;;) {
        }
    }

    total_ticks = benchmark_robot_read(&valid);
    if (valid == 0) {
        robot_write(RTC_INFO0, STATUS_OVERFLOW);
        for (;;) {
        }
    }

    robot_write(RTC_INFO1, timer_ticks_per_second);
    robot_write(RTC_INFO2, total_ticks);
    robot_write(RTC_INFO3, BENCHMARK_READS);
    robot_write(RTC_INFO0, STATUS_COMPLETE);
    for (;;) {
    }
}
