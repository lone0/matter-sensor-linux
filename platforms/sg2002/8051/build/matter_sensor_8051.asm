;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module firmware
	.optsdcc -mmcs51 --model-large
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _EA
	.globl _r51_addr3
	.globl _r51_addr2
	.globl _r51_addr1
	.globl _r51_addr0
	.globl _r51_wd3
	.globl _r51_wd2
	.globl _r51_wd1
	.globl _r51_wd0
	.globl _r51_write_enable
	.globl _r51_fire
	.globl _r51_rd3
	.globl _r51_rd2
	.globl _r51_rd1
	.globl _r51_rd0
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
	.area RSEG    (ABS,DATA)
	.org 0x0000
_r51_rd0	=	0x00e4
_r51_rd1	=	0x00e5
_r51_rd2	=	0x00e6
_r51_rd3	=	0x00e7
_r51_fire	=	0x00f2
_r51_write_enable	=	0x00f3
_r51_wd0	=	0x00f4
_r51_wd1	=	0x00f5
_r51_wd2	=	0x00f6
_r51_wd3	=	0x00f7
_r51_addr0	=	0x00f8
_r51_addr1	=	0x00f9
_r51_addr2	=	0x00fa
_r51_addr3	=	0x00fb
;--------------------------------------------------------
; special function bits
;--------------------------------------------------------
	.area RSEG    (ABS,DATA)
	.org 0x0000
_EA	=	0x00af
;--------------------------------------------------------
; overlayable register banks
;--------------------------------------------------------
	.area REG_BANK_0	(REL,OVR,DATA)
	.ds 8
;--------------------------------------------------------
; overlayable bit register bank
;--------------------------------------------------------
	.area BIT_BANK	(REL,OVR,DATA)
bits:
	.ds 1
	b0 = bits[0]
	b1 = bits[1]
	b2 = bits[2]
	b3 = bits[3]
	b4 = bits[4]
	b5 = bits[5]
	b6 = bits[6]
	b7 = bits[7]
;--------------------------------------------------------
; internal ram data
;--------------------------------------------------------
	.area DSEG    (DATA)
;--------------------------------------------------------
; overlayable items in internal ram
;--------------------------------------------------------
;--------------------------------------------------------
; Stack segment in internal ram
;--------------------------------------------------------
	.area	SSEG
__start__stack:
	.ds	1

;--------------------------------------------------------
; indirectly addressable internal ram data
;--------------------------------------------------------
	.area ISEG    (DATA)
;--------------------------------------------------------
; absolute internal ram data
;--------------------------------------------------------
	.area IABS    (ABS,DATA)
	.area IABS    (ABS,DATA)
;--------------------------------------------------------
; bit data
;--------------------------------------------------------
	.area BSEG    (BIT)
;--------------------------------------------------------
; paged external ram data
;--------------------------------------------------------
	.area PSEG    (PAG,XDATA)
;--------------------------------------------------------
; external ram data
;--------------------------------------------------------
	.area XSEG    (XDATA)
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area XABS    (ABS,XDATA)
;--------------------------------------------------------
; external initialized ram data
;--------------------------------------------------------
	.area XISEG   (XDATA)
	.area HOME    (CODE)
	.area GSINIT0 (CODE)
	.area GSINIT1 (CODE)
	.area GSINIT2 (CODE)
	.area GSINIT3 (CODE)
	.area GSINIT4 (CODE)
	.area GSINIT5 (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area CSEG    (CODE)
;--------------------------------------------------------
; interrupt vector
;--------------------------------------------------------
	.area HOME    (CODE)
__interrupt_vect:
	ljmp	__sdcc_gsinit_startup
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME    (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area GSINIT  (CODE)
	.globl __sdcc_gsinit_startup
	.globl __sdcc_program_startup
	.globl __start__stack
	.globl __mcs51_genXINIT
	.globl __mcs51_genXRAMCLEAR
	.globl __mcs51_genRAMCLEAR
	.area GSFINAL (CODE)
	ljmp	__sdcc_program_startup
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME    (CODE)
	.area HOME    (CODE)
__sdcc_program_startup:
	ljmp	_main
;	return from main will return to caller
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CSEG    (CODE)
;------------------------------------------------------------
;Allocation info for local variables in function 'robot_read'
;------------------------------------------------------------
;address                   Allocated to registers r4 r5 r6 r7 
;value                     Allocated to stack - _bp +5
;interrupts_enabled        Allocated to stack - _bp +9
;sloc0                     Allocated to stack - _bp +1
;------------------------------------------------------------
;	firmware.c:62: static uint32_t robot_read(uint32_t address) __reentrant
;	-----------------------------------------
;	 function robot_read
;	-----------------------------------------
_robot_read:
	ar7 = 0x07
	ar6 = 0x06
	ar5 = 0x05
	ar4 = 0x04
	ar3 = 0x03
	ar2 = 0x02
	ar1 = 0x01
	ar0 = 0x00
	push	_bp
	mov	_bp,sp
	mov	r4,dpl
	mov	r5,dph
	mov	r6,b
	mov	r7,a
	mov	a,sp
	add	a,#0x09
	mov	sp,a
;	firmware.c:65: uint8_t interrupts_enabled = EA;
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	mov	c,_EA
	clr	a
	rlc	a
	mov	@r0,a
;	firmware.c:67: EA = 0;
;	assignBit
	clr	_EA
;	firmware.c:68: r51_addr0 = (uint8_t) address;
	mov	_r51_addr0,r4
;	firmware.c:69: r51_addr1 = (uint8_t) (address >> 8);
	mov	_r51_addr1,r5
;	firmware.c:70: r51_addr2 = (uint8_t) (address >> 16);
	mov	_r51_addr2,r6
;	firmware.c:71: r51_addr3 = (uint8_t) (address >> 24);
	mov	_r51_addr3,r7
;	firmware.c:72: r51_write_enable = 4; /* 32-bit read */
	mov	_r51_write_enable,#0x04
;	firmware.c:73: r51_fire = 1;
	mov	_r51_fire,#0x01
;	firmware.c:74: while (r51_fire == 1) {
00101$:
	mov	a,#0x01
	cjne	a,_r51_fire,00116$
	sjmp	00101$
00116$:
;	firmware.c:77: value = (uint32_t) r51_rd0;
	mov	r0,_bp
	inc	r0
	mov	@r0,_r51_rd0
	inc	r0
	mov	@r0,#0x00
	inc	r0
	mov	@r0,#0x00
	inc	r0
	mov	@r0,#0x00
;	firmware.c:78: value |= (uint32_t) r51_rd1 << 8;
	mov	r2,_r51_rd1
	mov	r3,#0x00
	mov	r6,#0x00
	mov	ar7,r6
	mov	ar6,r3
	mov	ar3,r2
	mov	r2,#0x00
	mov	r0,_bp
	inc	r0
	mov	a,r2
	orl	a,@r0
	mov	@r0,a
	mov	a,r3
	inc	r0
	orl	a,@r0
	mov	@r0,a
	mov	a,r6
	inc	r0
	orl	a,@r0
	mov	@r0,a
	mov	a,r7
	inc	r0
	orl	a,@r0
	mov	@r0,a
;	firmware.c:79: value |= (uint32_t) r51_rd2 << 16;
	mov	r4,_r51_rd2
	mov	r5,#0x00
	mov	ar7,r5
	mov	ar6,r4
	mov	r4,#0x00
	mov	r5,#0x00
	mov	r0,_bp
	inc	r0
	mov	a,@r0
	orl	ar4,a
	inc	r0
	mov	a,@r0
	orl	ar5,a
	inc	r0
	mov	a,@r0
	orl	ar6,a
	inc	r0
	mov	a,@r0
	orl	ar7,a
	mov	a,_bp
	add	a,#0x05
	mov	r0,a
	mov	@r0,ar4
	inc	r0
	mov	@r0,ar5
	inc	r0
	mov	@r0,ar6
	inc	r0
	mov	@r0,ar7
;	firmware.c:80: value |= (uint32_t) r51_rd3 << 24;
	mov	r2,_r51_rd3
	mov	ar7,r2
	clr	a
	mov	r2,a
	mov	r3,a
	mov	r6,a
	mov	a,_bp
	add	a,#0x05
	mov	r0,a
	mov	a,@r0
	orl	ar2,a
	inc	r0
	mov	a,@r0
	orl	ar3,a
	inc	r0
	mov	a,@r0
	orl	ar6,a
	inc	r0
	mov	a,@r0
	orl	ar7,a
;	firmware.c:81: EA = interrupts_enabled;
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
;	assignBit
	mov	a,@r0
	add	a,#0xff
	mov	_EA,c
;	firmware.c:82: return value;
	mov	dpl,r2
	mov	dph,r3
	mov	b,r6
	mov	a,r7
;	firmware.c:83: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'robot_write'
;------------------------------------------------------------
;value                     Allocated to stack - _bp -6
;address                   Allocated to registers r4 r5 r6 r7 
;interrupts_enabled        Allocated to registers r3 
;------------------------------------------------------------
;	firmware.c:85: static void robot_write(uint32_t address, uint32_t value) __reentrant
;	-----------------------------------------
;	 function robot_write
;	-----------------------------------------
_robot_write:
	push	_bp
	mov	_bp,sp
	mov	r4,dpl
	mov	r5,dph
	mov	r6,b
	mov	r7,a
;	firmware.c:87: uint8_t interrupts_enabled = EA;
	mov	c,_EA
	clr	a
	rlc	a
	mov	r3,a
;	firmware.c:89: EA = 0;
;	assignBit
	clr	_EA
;	firmware.c:90: r51_addr0 = (uint8_t) address;
	mov	_r51_addr0,r4
;	firmware.c:91: r51_addr1 = (uint8_t) (address >> 8);
	mov	_r51_addr1,r5
;	firmware.c:92: r51_addr2 = (uint8_t) (address >> 16);
	mov	_r51_addr2,r6
;	firmware.c:93: r51_addr3 = (uint8_t) (address >> 24);
	mov	_r51_addr3,r7
;	firmware.c:94: r51_wd0 = (uint8_t) value;
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	mov	_r51_wd0,@r0
;	firmware.c:95: r51_wd1 = (uint8_t) (value >> 8);
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	inc	r0
	mov	_r51_wd1,@r0
;	firmware.c:96: r51_wd2 = (uint8_t) (value >> 16);
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	inc	r0
	inc	r0
	mov	_r51_wd2,@r0
;	firmware.c:97: r51_wd3 = (uint8_t) (value >> 24);
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	inc	r0
	inc	r0
	inc	r0
	mov	_r51_wd3,@r0
;	firmware.c:98: r51_write_enable = 5; /* 32-bit write */
	mov	_r51_write_enable,#0x05
;	firmware.c:99: r51_fire = 1;
	mov	_r51_fire,#0x01
;	firmware.c:100: while (r51_fire == 1) {
00101$:
	mov	a,#0x01
	cjne	a,_r51_fire,00114$
	sjmp	00101$
00114$:
;	firmware.c:102: EA = interrupts_enabled;
;	assignBit
	mov	a,r3
	add	a,#0xff
	mov	_EA,c
;	firmware.c:103: }
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'gpio_write'
;------------------------------------------------------------
;high                      Allocated to stack - _bp -3
;pin                       Allocated to registers r7 
;value                     Allocated to stack - _bp +5
;mask                      Allocated to stack - _bp +9
;sloc0                     Allocated to stack - _bp +1
;------------------------------------------------------------
;	firmware.c:105: static void gpio_write(uint8_t pin, uint8_t high)
;	-----------------------------------------
;	 function gpio_write
;	-----------------------------------------
_gpio_write:
	push	_bp
	mov	a,sp
	mov	_bp,a
	add	a,#0x0c
	mov	sp,a
	mov	r7,dpl
;	firmware.c:107: uint32_t value = robot_read(GPIOA_BASE + GPIO_DATA);
	mov	dptr,#0x0000
	mov	b,#0x02
	mov	a,#0x03
	push	ar7
	lcall	_robot_read
	mov	r3,dpl
	mov	r4,dph
	mov	r5,b
	mov	r6,a
	pop	ar7
	mov	a,_bp
	add	a,#0x05
	mov	r0,a
	mov	@r0,ar3
	inc	r0
	mov	@r0,ar4
	inc	r0
	mov	@r0,ar5
	inc	r0
	mov	@r0,ar6
;	firmware.c:108: uint32_t mask = (uint32_t) 1U << pin;
	mov	b,r7
	inc	b
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	mov	@r0,#0x01
	inc	r0
	mov	@r0,#0x00
	inc	r0
	mov	@r0,#0x00
	inc	r0
	mov	@r0,#0x00
	dec	r0
	dec	r0
	dec	r0
	sjmp	00110$
00109$:
	mov	a,@r0
	add	a,@r0
	mov	@r0,a
	inc	r0
	mov	a,@r0
	rlc	a
	mov	@r0,a
	inc	r0
	mov	a,@r0
	rlc	a
	mov	@r0,a
	inc	r0
	mov	a,@r0
	rlc	a
	mov	@r0,a
	dec	r0
	dec	r0
	dec	r0
00110$:
	djnz	b,00109$
;	firmware.c:110: robot_write(GPIOA_BASE + GPIO_DATA, high ? value | mask : value & ~mask);
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	a,@r0
	jz	00103$
	mov	a,_bp
	add	a,#0x05
	mov	r0,a
	mov	a,_bp
	add	a,#0x09
	mov	r1,a
	mov	a,@r1
	orl	a,@r0
	mov	r3,a
	inc	r1
	mov	a,@r1
	inc	r0
	orl	a,@r0
	mov	r4,a
	inc	r1
	mov	a,@r1
	inc	r0
	orl	a,@r0
	mov	r6,a
	inc	r1
	mov	a,@r1
	inc	r0
	orl	a,@r0
	mov	r7,a
	sjmp	00104$
00103$:
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	mov	r1,_bp
	inc	r1
	mov	a,@r0
	cpl	a
	mov	@r1,a
	inc	r0
	mov	a,@r0
	cpl	a
	inc	r1
	mov	@r1,a
	inc	r0
	mov	a,@r0
	cpl	a
	inc	r1
	mov	@r1,a
	inc	r0
	mov	a,@r0
	cpl	a
	inc	r1
	mov	@r1,a
	mov	a,_bp
	add	a,#0x05
	mov	r0,a
	mov	r1,_bp
	inc	r1
	mov	a,@r1
	anl	a,@r0
	mov	r3,a
	inc	r1
	mov	a,@r1
	inc	r0
	anl	a,@r0
	mov	r4,a
	inc	r1
	mov	a,@r1
	inc	r0
	anl	a,@r0
	mov	r6,a
	inc	r1
	mov	a,@r1
	inc	r0
	anl	a,@r0
	mov	r7,a
00104$:
	push	ar3
	push	ar4
	push	ar6
	push	ar7
	mov	dptr,#0x0000
	mov	b,#0x02
	mov	a,#0x03
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	firmware.c:111: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'gpio_output'
;------------------------------------------------------------
;pin                       Allocated to registers r7 
;value                     Allocated to stack - _bp +1
;------------------------------------------------------------
;	firmware.c:113: static void gpio_output(uint8_t pin)
;	-----------------------------------------
;	 function gpio_output
;	-----------------------------------------
_gpio_output:
	push	_bp
	mov	a,sp
	mov	_bp,a
	add	a,#0x04
	mov	sp,a
	mov	r7,dpl
;	firmware.c:115: uint32_t value = robot_read(GPIOA_BASE + GPIO_DIRECTION);
	mov	dptr,#0x0004
	mov	b,#0x02
	mov	a,#0x03
	push	ar7
	lcall	_robot_read
	mov	r3,dpl
	mov	r4,dph
	mov	r5,b
	mov	r6,a
	pop	ar7
	mov	r0,_bp
	inc	r0
	mov	@r0,ar3
	inc	r0
	mov	@r0,ar4
	inc	r0
	mov	@r0,ar5
	inc	r0
	mov	@r0,ar6
;	firmware.c:117: robot_write(GPIOA_BASE + GPIO_DIRECTION, value | ((uint32_t) 1U << pin));
	mov	b,r7
	inc	b
	mov	r2,#0x01
	mov	r5,#0x00
	mov	r6,#0x00
	mov	r7,#0x00
	sjmp	00104$
00103$:
	mov	a,r2
	add	a,r2
	mov	r2,a
	mov	a,r5
	rlc	a
	mov	r5,a
	mov	a,r6
	rlc	a
	mov	r6,a
	mov	a,r7
	rlc	a
	mov	r7,a
00104$:
	djnz	b,00103$
	mov	r0,_bp
	inc	r0
	mov	a,@r0
	orl	ar2,a
	inc	r0
	mov	a,@r0
	orl	ar5,a
	inc	r0
	mov	a,@r0
	orl	ar6,a
	inc	r0
	mov	a,@r0
	orl	ar7,a
	push	ar2
	push	ar5
	push	ar6
	push	ar7
	mov	dptr,#0x0004
	mov	b,#0x02
	mov	a,#0x03
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	firmware.c:118: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'gpio_input'
;------------------------------------------------------------
;pin                       Allocated to registers r7 
;value                     Allocated to stack - _bp +1
;------------------------------------------------------------
;	firmware.c:120: static void gpio_input(uint8_t pin)
;	-----------------------------------------
;	 function gpio_input
;	-----------------------------------------
_gpio_input:
	push	_bp
	mov	a,sp
	mov	_bp,a
	add	a,#0x04
	mov	sp,a
	mov	r7,dpl
;	firmware.c:122: uint32_t value = robot_read(GPIOA_BASE + GPIO_DIRECTION);
	mov	dptr,#0x0004
	mov	b,#0x02
	mov	a,#0x03
	push	ar7
	lcall	_robot_read
	mov	r3,dpl
	mov	r4,dph
	mov	r5,b
	mov	r6,a
	pop	ar7
	mov	r0,_bp
	inc	r0
	mov	@r0,ar3
	inc	r0
	mov	@r0,ar4
	inc	r0
	mov	@r0,ar5
	inc	r0
	mov	@r0,ar6
;	firmware.c:124: robot_write(GPIOA_BASE + GPIO_DIRECTION, value & ~((uint32_t) 1U << pin));
	mov	b,r7
	inc	b
	mov	r2,#0x01
	mov	r5,#0x00
	mov	r6,#0x00
	mov	r7,#0x00
	sjmp	00104$
00103$:
	mov	a,r2
	add	a,r2
	mov	r2,a
	mov	a,r5
	rlc	a
	mov	r5,a
	mov	a,r6
	rlc	a
	mov	r6,a
	mov	a,r7
	rlc	a
	mov	r7,a
00104$:
	djnz	b,00103$
	mov	a,r2
	cpl	a
	mov	r2,a
	mov	a,r5
	cpl	a
	mov	r5,a
	mov	a,r6
	cpl	a
	mov	r6,a
	mov	a,r7
	cpl	a
	mov	r7,a
	mov	r0,_bp
	inc	r0
	mov	a,@r0
	anl	ar2,a
	inc	r0
	mov	a,@r0
	anl	ar5,a
	inc	r0
	mov	a,@r0
	anl	ar6,a
	inc	r0
	mov	a,@r0
	anl	ar7,a
	push	ar2
	push	ar5
	push	ar6
	push	ar7
	mov	dptr,#0x0004
	mov	b,#0x02
	mov	a,#0x03
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	firmware.c:125: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'gpio_read'
;------------------------------------------------------------
;pin                       Allocated to registers r7 
;------------------------------------------------------------
;	firmware.c:127: static uint8_t gpio_read(uint8_t pin)
;	-----------------------------------------
;	 function gpio_read
;	-----------------------------------------
_gpio_read:
	mov	r7,dpl
;	firmware.c:129: return (uint8_t) ((robot_read(GPIOA_BASE + GPIO_EXTERNAL_PORT) >> pin) & 1U);
	mov	dptr,#0x0050
	mov	b,#0x02
	mov	a,#0x03
	push	ar7
	lcall	_robot_read
	mov	r3,dpl
	mov	r4,dph
	mov	r5,b
	mov	r6,a
	pop	ar7
	mov	b,r7
	inc	b
	sjmp	00104$
00103$:
	clr	c
	mov	a,r6
	rrc	a
	mov	r6,a
	mov	a,r5
	rrc	a
	mov	r5,a
	mov	a,r4
	rrc	a
	mov	r4,a
	mov	a,r3
	rrc	a
	mov	r3,a
00104$:
	djnz	b,00103$
	anl	ar3,#0x01
	mov	dpl,r3
;	firmware.c:130: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'delay_us'
;------------------------------------------------------------
;microseconds              Allocated to registers 
;loops                     Allocated to stack - _bp +1
;------------------------------------------------------------
;	firmware.c:137: static void delay_us(uint16_t microseconds)
;	-----------------------------------------
;	 function delay_us
;	-----------------------------------------
_delay_us:
	push	_bp
	mov	_bp,sp
	inc	sp
	mov	r6,dpl
	mov	r7,dph
;	firmware.c:141: while (microseconds-- != 0U) {
00104$:
	mov	ar4,r6
	mov	ar5,r7
	dec	r6
	cjne	r6,#0xff,00126$
	dec	r7
00126$:
	mov	a,r4
	orl	a,r5
	jz	00107$
;	firmware.c:142: loops = 10;
	mov	r0,_bp
	inc	r0
	mov	@r0,#0x0a
;	firmware.c:143: while (loops-- != 0U) {
00101$:
	mov	r0,_bp
	inc	r0
	mov	ar5,@r0
	mov	r0,_bp
	inc	r0
	mov	a,r5
	dec	a
	mov	@r0,a
	mov	a,r5
	jz	00104$
	sjmp	00101$
00107$:
;	firmware.c:146: }
	dec	sp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'delay_ms'
;------------------------------------------------------------
;milliseconds              Allocated to registers 
;------------------------------------------------------------
;	firmware.c:148: static void delay_ms(uint16_t milliseconds)
;	-----------------------------------------
;	 function delay_ms
;	-----------------------------------------
_delay_ms:
	mov	r6,dpl
	mov	r7,dph
;	firmware.c:150: while (milliseconds-- != 0U) {
00101$:
	mov	ar4,r6
	mov	ar5,r7
	dec	r6
	cjne	r6,#0xff,00115$
	dec	r7
00115$:
	mov	a,r4
	orl	a,r5
	jz	00104$
;	firmware.c:151: delay_us(1000);
	mov	dptr,#0x03e8
	push	ar7
	push	ar6
	lcall	_delay_us
	pop	ar6
	pop	ar7
	sjmp	00101$
00104$:
;	firmware.c:153: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'wait_for_level'
;------------------------------------------------------------
;level                     Allocated to registers r7 
;polls                     Allocated to registers r6 
;------------------------------------------------------------
;	firmware.c:155: static uint8_t wait_for_level(uint8_t level)
;	-----------------------------------------
;	 function wait_for_level
;	-----------------------------------------
_wait_for_level:
	mov	r7,dpl
;	firmware.c:159: while (polls-- != 0U) {
	mov	r6,#0xff
00103$:
	mov	ar5,r6
	dec	r6
	mov	a,r5
	jz	00105$
;	firmware.c:160: if (gpio_read(DHT_GPIO_PIN) == level) {
	mov	dpl,#0x1a
	push	ar7
	push	ar6
	lcall	_gpio_read
	mov	r5,dpl
	pop	ar6
	pop	ar7
	mov	a,r5
	cjne	a,ar7,00103$
;	firmware.c:161: return 1;
	mov	dpl,#0x01
	ret
00105$:
;	firmware.c:164: return 0;
	mov	dpl,#0x00
;	firmware.c:165: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'dht11_read'
;------------------------------------------------------------
;bytes                     Allocated to stack - _bp +1
;byte_index                Allocated to registers r5 
;bit_index                 Allocated to registers r2 
;value                     Allocated to registers r6 
;------------------------------------------------------------
;	firmware.c:167: static uint8_t dht11_read(uint8_t bytes[5])
;	-----------------------------------------
;	 function dht11_read
;	-----------------------------------------
_dht11_read:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
;	firmware.c:173: gpio_write(DHT_GPIO_PIN, 0);
	clr	a
	push	acc
	mov	dpl,#0x1a
	lcall	_gpio_write
	dec	sp
;	firmware.c:174: gpio_output(DHT_GPIO_PIN);
	mov	dpl,#0x1a
	lcall	_gpio_output
;	firmware.c:175: delay_ms(DHT_START_LOW_MS);
	mov	dptr,#0x0014
	lcall	_delay_ms
;	firmware.c:176: gpio_input(DHT_GPIO_PIN);
	mov	dpl,#0x1a
	lcall	_gpio_input
;	firmware.c:177: delay_us(DHT_RESPONSE_DELAY_US);
	mov	dptr,#0x0028
	lcall	_delay_us
;	firmware.c:179: if (!wait_for_level(0) || !wait_for_level(1) || !wait_for_level(0)) {
	mov	dpl,#0x00
	lcall	_wait_for_level
	mov	a,dpl
	jz	00101$
	mov	dpl,#0x01
	lcall	_wait_for_level
	mov	a,dpl
	jz	00101$
	mov	dpl,#0x00
	lcall	_wait_for_level
	mov	a,dpl
	jnz	00125$
00101$:
;	firmware.c:180: return 1;
	mov	dpl,#0x01
	ljmp	00117$
;	firmware.c:183: for (byte_index = 0; byte_index < 5; ++byte_index) {
00125$:
	mov	r5,#0x00
00115$:
;	firmware.c:184: value = 0;
	mov	r6,#0x00
;	firmware.c:185: for (bit_index = 0; bit_index < 8; ++bit_index) {
	mov	r2,#0x00
00113$:
;	firmware.c:186: if (!wait_for_level(1)) {
	mov	dpl,#0x01
	push	ar6
	push	ar5
	push	ar2
	lcall	_wait_for_level
	mov	a,dpl
	pop	ar2
	pop	ar5
	pop	ar6
	jnz	00106$
;	firmware.c:187: return 2;
	mov	dpl,#0x02
	ljmp	00117$
00106$:
;	firmware.c:189: delay_us(DHT_BIT_SAMPLE_US);
	mov	dptr,#0x0028
	push	ar6
	push	ar5
	push	ar2
	lcall	_delay_us
	pop	ar2
	pop	ar5
	pop	ar6
;	firmware.c:190: value = (uint8_t) ((value << 1) | gpio_read(DHT_GPIO_PIN));
	mov	ar7,r6
	mov	a,r7
	add	a,r7
	mov	r7,a
	mov	dpl,#0x1a
	push	ar7
	push	ar5
	push	ar2
	lcall	_gpio_read
	mov	r6,dpl
	pop	ar2
	pop	ar5
	pop	ar7
	mov	a,r6
	orl	ar7,a
	mov	ar6,r7
;	firmware.c:191: if (!wait_for_level(0)) {
	mov	dpl,#0x00
	push	ar6
	push	ar5
	push	ar2
	lcall	_wait_for_level
	mov	a,dpl
	pop	ar2
	pop	ar5
	pop	ar6
	jnz	00114$
;	firmware.c:192: return 2;
	mov	dpl,#0x02
	ljmp	00117$
00114$:
;	firmware.c:185: for (bit_index = 0; bit_index < 8; ++bit_index) {
	inc	r2
	cjne	r2,#0x08,00160$
00160$:
	jc	00113$
;	firmware.c:195: bytes[byte_index] = value;
	mov	r0,_bp
	inc	r0
	mov	a,r5
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,r6
	lcall	__gptrput
;	firmware.c:183: for (byte_index = 0; byte_index < 5; ++byte_index) {
	inc	r5
	cjne	r5,#0x05,00162$
00162$:
	jnc	00163$
	ljmp	00115$
00163$:
;	firmware.c:198: if ((uint8_t) (bytes[0] + bytes[1] + bytes[2] + bytes[3]) != bytes[4]) {
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__gptrget
	mov	r4,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r7
	lcall	__gptrget
	mov	r2,a
	add	a,r4
	mov	r4,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	add	a,r4
	mov	r4,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x03
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	add	a,r4
	mov	r4,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x04
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	mov	a,r4
	cjne	a,ar5,00164$
	sjmp	00112$
00164$:
;	firmware.c:199: return 3;
	mov	dpl,#0x03
	sjmp	00117$
00112$:
;	firmware.c:201: return 0;
	mov	dpl,#0x00
00117$:
;	firmware.c:202: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'publish_reading'
;------------------------------------------------------------
;sequence                  Allocated to stack - _bp -5
;bytes                     Allocated to stack - _bp +1
;temperature               Allocated to registers r4 r5 
;humidity                  Allocated to stack - _bp +12
;packed                    Allocated to registers 
;sloc0                     Allocated to stack - _bp +4
;sloc1                     Allocated to stack - _bp +8
;------------------------------------------------------------
;	firmware.c:204: static uint8_t publish_reading(const uint8_t bytes[5], uint32_t *sequence)
;	-----------------------------------------
;	 function publish_reading
;	-----------------------------------------
_publish_reading:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
	mov	a,sp
	add	a,#0x0a
	mov	sp,a
;	firmware.c:210: humidity = (uint16_t) bytes[0] * 100U + bytes[1];
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__gptrget
	mov	r4,a
	mov	r3,#0x00
	push	ar4
	push	ar3
	mov	dptr,#0x0064
	lcall	__mulint
	mov	r3,dpl
	mov	r4,dph
	dec	sp
	dec	sp
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r7,#0x00
	add	a,r3
	mov	r3,a
	mov	a,r7
	addc	a,r4
	mov	r4,a
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	mov	@r0,ar3
	inc	r0
	mov	@r0,ar4
;	firmware.c:211: temperature = (int16_t) ((uint16_t) (bytes[2] & 0x7fU) * 100U + bytes[3]);
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar5,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r5
	lcall	__gptrget
	mov	r3,a
	mov	r4,a
	anl	ar4,#0x7f
	mov	r5,#0x00
	push	ar3
	push	ar4
	push	ar5
	mov	dptr,#0x0064
	lcall	__mulint
	mov	r4,dpl
	mov	r5,dph
	dec	sp
	dec	sp
	pop	ar3
	mov	r0,_bp
	inc	r0
	mov	a,#0x03
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r2,a
	mov	r7,#0x00
	add	a,r4
	mov	r4,a
	mov	a,r7
	addc	a,r5
	mov	r5,a
;	firmware.c:212: if ((bytes[2] & 0x80U) != 0U) {
	mov	a,r3
	jnb	acc.7,00102$
;	firmware.c:213: temperature = -temperature;
	clr	c
	clr	a
	subb	a,r4
	mov	r4,a
	clr	a
	subb	a,r5
	mov	r5,a
00102$:
;	firmware.c:215: if (humidity > 10000U || temperature < -4000 || temperature > 8000) {
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	clr	c
	mov	a,#0x10
	subb	a,@r0
	mov	a,#0x27
	inc	r0
	subb	a,@r0
	jc	00103$
	mov	a,r4
	subb	a,#0x60
	mov	a,r5
	xrl	a,#0x80
	subb	a,#0x70
	jc	00103$
	mov	a,#0x40
	subb	a,r4
	mov	a,#(0x1f ^ 0x80)
	mov	b,r5
	xrl	b,#0x80
	subb	a,b
	jnc	00104$
00103$:
;	firmware.c:216: return 0;
	mov	dpl,#0x00
	ljmp	00109$
00104$:
;	firmware.c:219: packed = ((uint32_t) humidity << 16) | (uint16_t) temperature;
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	mov	ar2,@r0
	inc	r0
	mov	ar3,@r0
	clr	a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	inc	r0
	inc	r0
	inc	r0
	mov	@r0,ar3
	dec	r0
	mov	@r0,ar2
	dec	r0
	dec	r0
	mov	@r0,#0x00
	inc	r0
	clr	a
	mov	@r0,a
	mov	r6,a
	mov	r7,a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,@r0
	orl	ar4,a
	inc	r0
	mov	a,@r0
	orl	ar5,a
	inc	r0
	mov	a,@r0
	orl	ar6,a
	inc	r0
	mov	a,@r0
	orl	ar7,a
;	firmware.c:220: robot_write(RTC_INFO2, packed);
	push	ar4
	push	ar5
	push	ar6
	push	ar7
	mov	dptr,#0x6024
	mov	b,#0x02
	mov	a,#0x05
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	firmware.c:221: ++*sequence;
	mov	a,_bp
	add	a,#0xfb
	mov	r0,a
	mov	a,_bp
	add	a,#0x04
	mov	r1,a
	mov	a,@r0
	mov	@r1,a
	inc	r0
	mov	a,@r0
	inc	r1
	mov	@r1,a
	inc	r0
	mov	a,@r0
	inc	r1
	mov	@r1,a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__gptrget
	mov	r2,a
	inc	dptr
	lcall	__gptrget
	mov	r3,a
	inc	dptr
	lcall	__gptrget
	mov	r4,a
	inc	dptr
	lcall	__gptrget
	mov	r7,a
	inc	r2
	cjne	r2,#0x00,00131$
	inc	r3
	cjne	r3,#0x00,00131$
	inc	r4
	cjne	r4,#0x00,00131$
	inc	r7
00131$:
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,r2
	lcall	__gptrput
	inc	dptr
	mov	a,r3
	lcall	__gptrput
	inc	dptr
	mov	a,r4
	lcall	__gptrput
	inc	dptr
	mov	a,r7
	lcall	__gptrput
;	firmware.c:222: if (*sequence == 0UL) {
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,_bp
	add	a,#0x08
	mov	r1,a
	lcall	__gptrget
	mov	@r1,a
	inc	dptr
	lcall	__gptrget
	inc	r1
	mov	@r1,a
	inc	dptr
	lcall	__gptrget
	inc	r1
	mov	@r1,a
	inc	dptr
	lcall	__gptrget
	inc	r1
	mov	@r1,a
	mov	a,r2
	orl	a,r3
	orl	a,r4
	orl	a,r7
	jnz	00108$
;	firmware.c:223: ++*sequence;
	mov	a,_bp
	add	a,#0x08
	mov	r0,a
	mov	a,#0x01
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r7,a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,r5
	lcall	__gptrput
	inc	dptr
	mov	a,r6
	lcall	__gptrput
	inc	dptr
	mov	a,r4
	lcall	__gptrput
	inc	dptr
	mov	a,r7
	lcall	__gptrput
00108$:
;	firmware.c:225: robot_write(RTC_INFO3, *sequence);
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__gptrget
	mov	r4,a
	inc	dptr
	lcall	__gptrget
	mov	r5,a
	inc	dptr
	lcall	__gptrget
	mov	r6,a
	inc	dptr
	lcall	__gptrget
	mov	r7,a
	push	ar4
	push	ar5
	push	ar6
	push	ar7
	mov	dptr,#0x6028
	mov	b,#0x02
	mov	a,#0x05
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	firmware.c:226: robot_write(RTC_INFO0, STATUS_RUNNING);
	mov	a,#0x4b
	push	acc
	mov	a,#0x4e
	push	acc
	mov	a,#0x4c
	push	acc
	mov	a,#0x42
	push	acc
	mov	dptr,#0x601c
	mov	b,#0x02
	mov	a,#0x05
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	firmware.c:227: return 1;
	mov	dpl,#0x01
00109$:
;	firmware.c:228: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;bytes                     Allocated to stack - _bp +1
;result                    Allocated to registers r5 
;led_on                    Allocated to registers r7 
;sequence                  Allocated to stack - _bp +6
;------------------------------------------------------------
;	firmware.c:230: void main(void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	push	_bp
	mov	a,sp
	mov	_bp,a
	add	a,#0x09
	mov	sp,a
;	firmware.c:234: uint8_t led_on = 0;
	mov	r7,#0x00
;	firmware.c:235: uint32_t sequence = 0;
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	clr	a
	mov	@r0,a
	inc	r0
	mov	@r0,a
	inc	r0
	mov	@r0,a
	inc	r0
	mov	@r0,a
;	firmware.c:237: gpio_write(LED_GPIO_PIN, 0);
	push	ar7
	push	acc
	mov	dpl,#0x0d
	lcall	_gpio_write
	dec	sp
;	firmware.c:238: gpio_output(LED_GPIO_PIN);
	mov	dpl,#0x0d
	lcall	_gpio_output
;	firmware.c:239: gpio_input(DHT_GPIO_PIN);
	mov	dpl,#0x1a
	lcall	_gpio_input
;	firmware.c:240: robot_write(RTC_INFO0, STATUS_RUNNING);
	mov	a,#0x4b
	push	acc
	mov	a,#0x4e
	push	acc
	mov	a,#0x4c
	push	acc
	mov	a,#0x42
	push	acc
	mov	dptr,#0x601c
	mov	b,#0x02
	mov	a,#0x05
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	pop	ar7
00113$:
;	firmware.c:243: gpio_write(LED_GPIO_PIN, led_on);
	push	ar7
	push	ar7
	mov	dpl,#0x0d
	lcall	_gpio_write
	dec	sp
	pop	ar7
;	firmware.c:244: led_on = (uint8_t) !led_on;
	mov	a,r7
	cjne	a,#0x01,00137$
00137$:
	mov  b0,c
	clr	a
	rlc	a
	mov	r7,a
;	firmware.c:245: result = dht11_read(bytes);
	mov	r6,_bp
	inc	r6
	mov	ar3,r6
	mov	r4,#0x00
	mov	r5,#0x40
	mov	dpl,r3
	mov	dph,r4
	mov	b,r5
	push	ar7
	push	ar6
	lcall	_dht11_read
	mov	r5,dpl
	pop	ar6
	pop	ar7
;	firmware.c:246: if (result == 1U) {
	cjne	r5,#0x01,00110$
;	firmware.c:247: robot_write(RTC_INFO0, STATUS_NO_RESPONSE);
	push	ar7
	mov	a,#0x31
	push	acc
	dec	a
	push	acc
	mov	a,#0x52
	push	acc
	mov	a,#0x45
	push	acc
	mov	dptr,#0x601c
	mov	b,#0x02
	mov	a,#0x05
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	pop	ar7
	ljmp	00111$
00110$:
;	firmware.c:248: } else if (result == 2U) {
	cjne	r5,#0x02,00107$
;	firmware.c:249: robot_write(RTC_INFO0, STATUS_TIMING);
	push	ar7
	mov	a,#0x32
	push	acc
	mov	a,#0x30
	push	acc
	mov	a,#0x52
	push	acc
	mov	a,#0x45
	push	acc
	mov	dptr,#0x601c
	mov	b,#0x02
	mov	a,#0x05
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	pop	ar7
	sjmp	00111$
00107$:
;	firmware.c:250: } else if (result == 3U) {
	cjne	r5,#0x03,00104$
;	firmware.c:251: robot_write(RTC_INFO0, STATUS_CHECKSUM);
	push	ar7
	mov	a,#0x33
	push	acc
	mov	a,#0x30
	push	acc
	mov	a,#0x52
	push	acc
	mov	a,#0x45
	push	acc
	mov	dptr,#0x601c
	mov	b,#0x02
	mov	a,#0x05
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	pop	ar7
	sjmp	00111$
00104$:
;	firmware.c:252: } else if (!publish_reading(bytes, &sequence)) {
	push	ar7
	mov	a,_bp
	add	a,#0x06
	mov	r5,a
	mov	r4,#0x00
	mov	r3,#0x40
	mov	ar2,r6
	mov	r6,#0x00
	mov	r7,#0x40
	push	ar5
	push	ar4
	push	ar3
	mov	dpl,r2
	mov	dph,r6
	mov	b,r7
	lcall	_publish_reading
	mov	r7,dpl
	dec	sp
	dec	sp
	dec	sp
	mov	a,r7
	pop	ar7
	jnz	00111$
;	firmware.c:253: robot_write(RTC_INFO0, STATUS_RANGE);
	push	ar7
	mov	a,#0x34
	push	acc
	mov	a,#0x30
	push	acc
	mov	a,#0x52
	push	acc
	mov	a,#0x45
	push	acc
	mov	dptr,#0x601c
	mov	b,#0x02
	mov	a,#0x05
	lcall	_robot_write
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	pop	ar7
00111$:
;	firmware.c:255: delay_ms(1000);
	mov	dptr,#0x03e8
	push	ar7
	lcall	_delay_ms
	pop	ar7
	ljmp	00113$
;	firmware.c:257: }
	mov	sp,_bp
	pop	_bp
	ret
	.area CSEG    (CODE)
	.area CONST   (CODE)
	.area XINIT   (CODE)
	.area CABS    (ABS,CODE)
