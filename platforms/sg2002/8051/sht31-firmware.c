/*
 * SG2002 8051 SHT31-D publisher using AP I2C3.
 *
 * Uses the Linux-decommissioned DesignWare I2C3 controller and publishes measurements
 * through the RTC_INFO2/RTC_INFO3 ABI consumed by the Linux Matter reader.
 */

typedef unsigned char uint8_t;
typedef signed char int8_t;
typedef signed int int16_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;

#ifndef LED_GPIO_PIN
#define LED_GPIO_PIN 20
#endif

#ifndef LED_GPIO_BASE
#define LED_GPIO_BASE 0x05021000UL
#endif

#define I2C_BASE 0x04030000UL
#define RTC_TIMER_BASE 0x05020000UL
#define RTC_TIMER_CONTROL (RTC_TIMER_BASE + 0x008UL)
#define RTC_TIMER_EOI (RTC_TIMER_BASE + 0x00CUL)
#define RTC_TIMER_INTSTATUS (RTC_TIMER_BASE + 0x010UL)
#define RTC_TIMER_TICKS_PER_MILLISECOND 25000UL
#define RTC_INFO0 0x0502601CUL
#define RTC_INFO1 0x05026020UL
#define RTC_INFO2 0x05026024UL
#define RTC_INFO3 0x05026028UL

#define GPIO_DATA 0x000UL
#define GPIO_DIRECTION 0x004UL

#define I2C_CON 0x000UL
#define I2C_TAR 0x004UL
#define I2C_DATA_CMD 0x010UL
#define I2C_FS_SCL_HCNT 0x01CUL
#define I2C_FS_SCL_LCNT 0x020UL
#define I2C_RAW_INT_STAT 0x034UL
#define I2C_CLR_INTR 0x040UL
#define I2C_CLR_TX_ABRT 0x054UL
#define I2C_ENABLE 0x06CUL
#define I2C_STATUS 0x070UL
#define I2C_TXFLR 0x074UL
#define I2C_RXFLR 0x078UL
#define I2C_SDA_HOLD 0x07CUL
#define I2C_SDA_SETUP 0x094UL
#define I2C_TX_ABRT_SOURCE 0x080UL
#define I2C_RX_TL 0x038UL
#define I2C_TX_TL 0x03CUL

#define I2C_CON_MASTER 0x01UL
#define I2C_CON_FAST_SPEED 0x04UL
#define I2C_CON_RESTART 0x20UL
#define I2C_CON_SLAVE_DISABLE 0x40UL
#define I2C_RAW_RX_FULL 0x04UL
#define I2C_RAW_TX_ABORT 0x40UL
#define I2C_STATUS_TFNF 0x02UL
#define I2C_CMD_READ 0x100UL
#define I2C_CMD_STOP 0x200UL

#define SHT31_ADDRESS 0x44U
#define SHT31_MEASURE_HIGH_REPEATABILITY 0x2400U
#define SHT31_MEASURE_DELAY_MS 15U
#define I2C_WAIT_POLLS 2000U

#define STATUS_STARTING 0x49324352UL /* "I2CR" */
#define STATUS_READY 0x4932434FUL /* "I2CO" */
#define STATUS_I2C_ERROR 0x49324321UL /* "I2C!" */
#define STATUS_CRC_ERROR 0x43524321UL /* "CRC!" */
#define STATUS_RANGE_ERROR 0x524E4721UL /* "RNG!" */
#define STATUS_DEBOUNCE 0x44454221UL /* "DEB!" */

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

static uint32_t i2c_error_detail;
static uint16_t last_raw_temperature;
static uint16_t last_raw_humidity;
static int8_t temperature_direction;
static int8_t humidity_direction;

static void robot_write(uint32_t address, uint32_t value);

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

static void delay_ms(uint16_t milliseconds)
{
    robot_write(RTC_TIMER_CONTROL, 0);
    robot_write(RTC_TIMER_BASE, (uint32_t) milliseconds * RTC_TIMER_TICKS_PER_MILLISECOND);
    robot_write(RTC_TIMER_CONTROL, 3);
    while ((robot_read(RTC_TIMER_INTSTATUS) & 1U) == 0U) {
    }
    robot_read(RTC_TIMER_EOI);
}

static uint8_t i2c_check_abort(void)
{
    if ((robot_read(I2C_BASE + I2C_RAW_INT_STAT) & I2C_RAW_TX_ABORT) == 0U) {
        return 1;
    }

    i2c_error_detail = robot_read(I2C_BASE + I2C_TX_ABRT_SOURCE);
    robot_read(I2C_BASE + I2C_CLR_TX_ABRT);
    return 0;
}

static uint8_t i2c_wait_tx_space(void)
{
    uint16_t polls = I2C_WAIT_POLLS;

    while (polls-- != 0U) {
        if (!i2c_check_abort()) {
            return 0;
        }
        if ((robot_read(I2C_BASE + I2C_STATUS) & I2C_STATUS_TFNF) != 0U) {
            return 1;
        }
    }
    return 0;
}

static uint8_t i2c_wait_rx_byte(void)
{
    uint16_t polls = I2C_WAIT_POLLS;

    while (polls-- != 0U) {
        if (!i2c_check_abort()) {
            return 0;
        }
        if ((robot_read(I2C_BASE + I2C_RAW_INT_STAT) & I2C_RAW_RX_FULL) != 0U) {
            return 1;
        }
    }
    return 0;
}

static void i2c_init(void)
{
    robot_write(I2C_BASE + I2C_ENABLE, 0);
    robot_write(I2C_BASE + I2C_CON,
                I2C_CON_MASTER | I2C_CON_FAST_SPEED | I2C_CON_RESTART | I2C_CON_SLAVE_DISABLE);
    robot_write(I2C_BASE + I2C_TAR, SHT31_ADDRESS);
    robot_write(I2C_BASE + I2C_FS_SCL_HCNT, 0x57UL);
    robot_write(I2C_BASE + I2C_FS_SCL_LCNT, 0x9fUL);
    robot_write(I2C_BASE + I2C_SDA_HOLD, 1);
    robot_write(I2C_BASE + I2C_SDA_SETUP, 0x64UL);
    robot_write(I2C_BASE + I2C_RX_TL, 0);
    robot_write(I2C_BASE + I2C_TX_TL, 0x20UL);
    robot_write(I2C_BASE + I2C_ENABLE, 1);
    robot_read(I2C_BASE + I2C_CLR_INTR);
}

static uint8_t i2c_write_command(uint16_t command)
{
    if (!i2c_wait_tx_space()) {
        return 0;
    }
    robot_write(I2C_BASE + I2C_DATA_CMD, command >> 8);
    if (!i2c_wait_tx_space()) {
        return 0;
    }
    robot_write(I2C_BASE + I2C_DATA_CMD, (command & 0xffU) | I2C_CMD_STOP);
    return i2c_check_abort();
}

static uint8_t i2c_read_frame(uint8_t bytes[6])
{
    uint8_t index;

    for (index = 0; index < 6; ++index) {
        if (!i2c_wait_tx_space()) {
            return 0;
        }
        robot_write(I2C_BASE + I2C_DATA_CMD,
                    I2C_CMD_READ | (index == 5U ? I2C_CMD_STOP : 0U));
    }

    for (index = 0; index < 6; ++index) {
        if (!i2c_wait_rx_byte()) {
            return 0;
        }
        bytes[index] = (uint8_t) robot_read(I2C_BASE + I2C_DATA_CMD);
    }

    return 1;
}

static uint8_t sht31_crc(const uint8_t data[2])
{
    uint8_t crc = 0xffU;
    uint8_t byte_index;
    uint8_t bit_index;

    for (byte_index = 0; byte_index < 2; ++byte_index) {
        crc ^= data[byte_index];
        for (bit_index = 0; bit_index < 8; ++bit_index) {
            crc = (uint8_t) ((crc & 0x80U) ? (crc << 1) ^ 0x31U : crc << 1);
        }
    }
    return crc;
}

static uint8_t sht31_read(uint8_t bytes[6])
{
    if (!i2c_write_command(SHT31_MEASURE_HIGH_REPEATABILITY)) {
        return 0;
    }
    delay_ms(SHT31_MEASURE_DELAY_MS);
    return i2c_read_frame(bytes);
}

static uint16_t u16_abs_diff(uint16_t a, uint16_t b)
{
    return (a >= b) ? (uint16_t)(a - b) : (uint16_t)(b - a);
}

static uint8_t debounce_filter(uint16_t raw_temperature, uint16_t raw_humidity, uint16_t last_raw_temperature, uint16_t last_raw_humidity)
{
    int8_t t_direction = 0;
    int8_t h_direction = 0;

    if (u16_abs_diff(raw_temperature, last_raw_temperature) < 10 || u16_abs_diff(raw_humidity, last_raw_humidity) < 10)
        //filtered out by debounce filter
        return 1;

    t_direction = (raw_temperature > last_raw_temperature) ? 1 : -1;
    if ((t_direction > 0 && temperature_direction > 1) ||
        (t_direction < 0 && temperature_direction < -1))
        return 0;

    h_direction = (raw_humidity > last_raw_humidity) ? 1 : -1;
    if ((h_direction > 0 && humidity_direction > 1) ||
        (h_direction < 0 && humidity_direction < -1))
        return 0;

    temperature_direction += t_direction;    humidity_direction += h_direction;
    return 1;
}

static uint8_t publish_reading(const uint8_t bytes[6], uint32_t *sequence)
{
    uint16_t raw_temperature;
    uint16_t raw_humidity;
    int16_t temperature;
    uint16_t humidity;
    uint32_t packed;

    if (sht31_crc(bytes) != bytes[2] || sht31_crc(bytes + 3) != bytes[5]) {
        robot_write(RTC_INFO1, ((uint32_t) bytes[2] << 8) | bytes[5]);
        robot_write(RTC_INFO2, ((uint32_t) bytes[0] << 24) |
                               ((uint32_t) bytes[1] << 16) |
                               ((uint32_t) bytes[3] << 8) | bytes[4]);
        robot_write(RTC_INFO0, STATUS_CRC_ERROR);
        return 0;
    }

    raw_temperature = ((uint16_t) bytes[0] << 8) | bytes[1];
    raw_humidity = ((uint16_t) bytes[3] << 8) | bytes[4];
    if (debounce_filter(raw_temperature, raw_humidity, last_raw_temperature, last_raw_humidity)) {
        //filtered out by debounce filter
        robot_write(RTC_INFO0, STATUS_DEBOUNCE);
        packed = ((uint32_t) temperature_direction << 16) | (uint32_t)humidity_direction;
        robot_write(RTC_INFO1, packed);
        delay_ms(2000);
        return 0;
    }

    temperature = (int16_t) (((uint32_t) raw_temperature * 17500UL + 32767UL) / 65535UL) - 4500;
    humidity = (uint16_t) (((uint32_t) raw_humidity * 10000UL + 32767UL) / 65535UL);

    packed = ((uint32_t) humidity << 16) | (uint16_t) temperature;
    robot_write(RTC_INFO2, packed);
    ++*sequence;
    if (*sequence == 0UL) {
        ++*sequence;
    }
    robot_write(RTC_INFO3, *sequence);
    robot_write(RTC_INFO1, 0);
    robot_write(RTC_INFO0, STATUS_READY);
    last_raw_temperature = raw_temperature;
    last_raw_humidity = raw_humidity;
    return 1;
}

void main(void)
{
    uint8_t bytes[6];
    uint8_t led_on = 0;
    uint32_t sequence = 0;

    robot_write(RTC_INFO0, STATUS_STARTING);
    gpio_write(LED_GPIO_BASE, LED_GPIO_PIN, 0);
    gpio_output(LED_GPIO_BASE, LED_GPIO_PIN);
    i2c_init();
    for (;;) {
        i2c_error_detail = 0;
        gpio_write(LED_GPIO_BASE, LED_GPIO_PIN, led_on);
        led_on = (uint8_t) !led_on;
        if (!sht31_read(bytes)) {
            robot_write(RTC_INFO1, i2c_error_detail);
            robot_write(RTC_INFO0, STATUS_I2C_ERROR);
        } else {
            if (publish_reading(bytes, &sequence)) {
                gpio_write(LED_GPIO_BASE, LED_GPIO_PIN, led_on);
                delay_ms(100);
                gpio_write(LED_GPIO_BASE, LED_GPIO_PIN, !led_on);
            }
        }
        delay_ms(1000);
    }
}
