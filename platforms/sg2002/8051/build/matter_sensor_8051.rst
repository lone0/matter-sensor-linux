                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module firmware
                                      6 	.optsdcc -mmcs51 --model-large
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _EA
                                     13 	.globl _r51_addr3
                                     14 	.globl _r51_addr2
                                     15 	.globl _r51_addr1
                                     16 	.globl _r51_addr0
                                     17 	.globl _r51_wd3
                                     18 	.globl _r51_wd2
                                     19 	.globl _r51_wd1
                                     20 	.globl _r51_wd0
                                     21 	.globl _r51_write_enable
                                     22 	.globl _r51_fire
                                     23 	.globl _r51_rd3
                                     24 	.globl _r51_rd2
                                     25 	.globl _r51_rd1
                                     26 	.globl _r51_rd0
                                     27 ;--------------------------------------------------------
                                     28 ; special function registers
                                     29 ;--------------------------------------------------------
                                     30 	.area RSEG    (ABS,DATA)
      000000                         31 	.org 0x0000
                           0000E4    32 _r51_rd0	=	0x00e4
                           0000E5    33 _r51_rd1	=	0x00e5
                           0000E6    34 _r51_rd2	=	0x00e6
                           0000E7    35 _r51_rd3	=	0x00e7
                           0000F2    36 _r51_fire	=	0x00f2
                           0000F3    37 _r51_write_enable	=	0x00f3
                           0000F4    38 _r51_wd0	=	0x00f4
                           0000F5    39 _r51_wd1	=	0x00f5
                           0000F6    40 _r51_wd2	=	0x00f6
                           0000F7    41 _r51_wd3	=	0x00f7
                           0000F8    42 _r51_addr0	=	0x00f8
                           0000F9    43 _r51_addr1	=	0x00f9
                           0000FA    44 _r51_addr2	=	0x00fa
                           0000FB    45 _r51_addr3	=	0x00fb
                                     46 ;--------------------------------------------------------
                                     47 ; special function bits
                                     48 ;--------------------------------------------------------
                                     49 	.area RSEG    (ABS,DATA)
      000000                         50 	.org 0x0000
                           0000AF    51 _EA	=	0x00af
                                     52 ;--------------------------------------------------------
                                     53 ; overlayable register banks
                                     54 ;--------------------------------------------------------
                                     55 	.area REG_BANK_0	(REL,OVR,DATA)
      000000                         56 	.ds 8
                                     57 ;--------------------------------------------------------
                                     58 ; overlayable bit register bank
                                     59 ;--------------------------------------------------------
                                     60 	.area BIT_BANK	(REL,OVR,DATA)
      000020                         61 bits:
      000020                         62 	.ds 1
                           008000    63 	b0 = bits[0]
                           008100    64 	b1 = bits[1]
                           008200    65 	b2 = bits[2]
                           008300    66 	b3 = bits[3]
                           008400    67 	b4 = bits[4]
                           008500    68 	b5 = bits[5]
                           008600    69 	b6 = bits[6]
                           008700    70 	b7 = bits[7]
                                     71 ;--------------------------------------------------------
                                     72 ; internal ram data
                                     73 ;--------------------------------------------------------
                                     74 	.area DSEG    (DATA)
                                     75 ;--------------------------------------------------------
                                     76 ; overlayable items in internal ram
                                     77 ;--------------------------------------------------------
                                     78 ;--------------------------------------------------------
                                     79 ; Stack segment in internal ram
                                     80 ;--------------------------------------------------------
                                     81 	.area	SSEG
      000021                         82 __start__stack:
      000021                         83 	.ds	1
                                     84 
                                     85 ;--------------------------------------------------------
                                     86 ; indirectly addressable internal ram data
                                     87 ;--------------------------------------------------------
                                     88 	.area ISEG    (DATA)
                                     89 ;--------------------------------------------------------
                                     90 ; absolute internal ram data
                                     91 ;--------------------------------------------------------
                                     92 	.area IABS    (ABS,DATA)
                                     93 	.area IABS    (ABS,DATA)
                                     94 ;--------------------------------------------------------
                                     95 ; bit data
                                     96 ;--------------------------------------------------------
                                     97 	.area BSEG    (BIT)
                                     98 ;--------------------------------------------------------
                                     99 ; paged external ram data
                                    100 ;--------------------------------------------------------
                                    101 	.area PSEG    (PAG,XDATA)
                                    102 ;--------------------------------------------------------
                                    103 ; external ram data
                                    104 ;--------------------------------------------------------
                                    105 	.area XSEG    (XDATA)
                                    106 ;--------------------------------------------------------
                                    107 ; absolute external ram data
                                    108 ;--------------------------------------------------------
                                    109 	.area XABS    (ABS,XDATA)
                                    110 ;--------------------------------------------------------
                                    111 ; external initialized ram data
                                    112 ;--------------------------------------------------------
                                    113 	.area XISEG   (XDATA)
                                    114 	.area HOME    (CODE)
                                    115 	.area GSINIT0 (CODE)
                                    116 	.area GSINIT1 (CODE)
                                    117 	.area GSINIT2 (CODE)
                                    118 	.area GSINIT3 (CODE)
                                    119 	.area GSINIT4 (CODE)
                                    120 	.area GSINIT5 (CODE)
                                    121 	.area GSINIT  (CODE)
                                    122 	.area GSFINAL (CODE)
                                    123 	.area CSEG    (CODE)
                                    124 ;--------------------------------------------------------
                                    125 ; interrupt vector
                                    126 ;--------------------------------------------------------
                                    127 	.area HOME    (CODE)
      000000                        128 __interrupt_vect:
      000000 02 00 06         [24]  129 	ljmp	__sdcc_gsinit_startup
                                    130 ;--------------------------------------------------------
                                    131 ; global & static initialisations
                                    132 ;--------------------------------------------------------
                                    133 	.area HOME    (CODE)
                                    134 	.area GSINIT  (CODE)
                                    135 	.area GSFINAL (CODE)
                                    136 	.area GSINIT  (CODE)
                                    137 	.globl __sdcc_gsinit_startup
                                    138 	.globl __sdcc_program_startup
                                    139 	.globl __start__stack
                                    140 	.globl __mcs51_genXINIT
                                    141 	.globl __mcs51_genXRAMCLEAR
                                    142 	.globl __mcs51_genRAMCLEAR
                                    143 	.area GSFINAL (CODE)
      00005F 02 00 03         [24]  144 	ljmp	__sdcc_program_startup
                                    145 ;--------------------------------------------------------
                                    146 ; Home
                                    147 ;--------------------------------------------------------
                                    148 	.area HOME    (CODE)
                                    149 	.area HOME    (CODE)
      000003                        150 __sdcc_program_startup:
      000003 02 07 CE         [24]  151 	ljmp	_main
                                    152 ;	return from main will return to caller
                                    153 ;--------------------------------------------------------
                                    154 ; code
                                    155 ;--------------------------------------------------------
                                    156 	.area CSEG    (CODE)
                                    157 ;------------------------------------------------------------
                                    158 ;Allocation info for local variables in function 'robot_read'
                                    159 ;------------------------------------------------------------
                                    160 ;address                   Allocated to registers r4 r5 r6 r7 
                                    161 ;value                     Allocated to stack - _bp +5
                                    162 ;interrupts_enabled        Allocated to stack - _bp +9
                                    163 ;sloc0                     Allocated to stack - _bp +1
                                    164 ;------------------------------------------------------------
                                    165 ;	firmware.c:62: static uint32_t robot_read(uint32_t address) __reentrant
                                    166 ;	-----------------------------------------
                                    167 ;	 function robot_read
                                    168 ;	-----------------------------------------
      000062                        169 _robot_read:
                           000007   170 	ar7 = 0x07
                           000006   171 	ar6 = 0x06
                           000005   172 	ar5 = 0x05
                           000004   173 	ar4 = 0x04
                           000003   174 	ar3 = 0x03
                           000002   175 	ar2 = 0x02
                           000001   176 	ar1 = 0x01
                           000000   177 	ar0 = 0x00
      000062 C0 08            [24]  178 	push	_bp
      000064 85 81 08         [24]  179 	mov	_bp,sp
      000067 AC 82            [24]  180 	mov	r4,dpl
      000069 AD 83            [24]  181 	mov	r5,dph
      00006B AE F0            [24]  182 	mov	r6,b
      00006D FF               [12]  183 	mov	r7,a
      00006E E5 81            [12]  184 	mov	a,sp
      000070 24 09            [12]  185 	add	a,#0x09
      000072 F5 81            [12]  186 	mov	sp,a
                                    187 ;	firmware.c:65: uint8_t interrupts_enabled = EA;
      000074 E5 08            [12]  188 	mov	a,_bp
      000076 24 09            [12]  189 	add	a,#0x09
      000078 F8               [12]  190 	mov	r0,a
      000079 A2 AF            [12]  191 	mov	c,_EA
      00007B E4               [12]  192 	clr	a
      00007C 33               [12]  193 	rlc	a
      00007D F6               [12]  194 	mov	@r0,a
                                    195 ;	firmware.c:67: EA = 0;
                                    196 ;	assignBit
      00007E C2 AF            [12]  197 	clr	_EA
                                    198 ;	firmware.c:68: r51_addr0 = (uint8_t) address;
      000080 8C F8            [24]  199 	mov	_r51_addr0,r4
                                    200 ;	firmware.c:69: r51_addr1 = (uint8_t) (address >> 8);
      000082 8D F9            [24]  201 	mov	_r51_addr1,r5
                                    202 ;	firmware.c:70: r51_addr2 = (uint8_t) (address >> 16);
      000084 8E FA            [24]  203 	mov	_r51_addr2,r6
                                    204 ;	firmware.c:71: r51_addr3 = (uint8_t) (address >> 24);
      000086 8F FB            [24]  205 	mov	_r51_addr3,r7
                                    206 ;	firmware.c:72: r51_write_enable = 4; /* 32-bit read */
      000088 75 F3 04         [24]  207 	mov	_r51_write_enable,#0x04
                                    208 ;	firmware.c:73: r51_fire = 1;
      00008B 75 F2 01         [24]  209 	mov	_r51_fire,#0x01
                                    210 ;	firmware.c:74: while (r51_fire == 1) {
      00008E                        211 00101$:
      00008E 74 01            [12]  212 	mov	a,#0x01
      000090 B5 F2 02         [24]  213 	cjne	a,_r51_fire,00116$
      000093 80 F9            [24]  214 	sjmp	00101$
      000095                        215 00116$:
                                    216 ;	firmware.c:77: value = (uint32_t) r51_rd0;
      000095 A8 08            [24]  217 	mov	r0,_bp
      000097 08               [12]  218 	inc	r0
      000098 A6 E4            [24]  219 	mov	@r0,_r51_rd0
      00009A 08               [12]  220 	inc	r0
      00009B 76 00            [12]  221 	mov	@r0,#0x00
      00009D 08               [12]  222 	inc	r0
      00009E 76 00            [12]  223 	mov	@r0,#0x00
      0000A0 08               [12]  224 	inc	r0
      0000A1 76 00            [12]  225 	mov	@r0,#0x00
                                    226 ;	firmware.c:78: value |= (uint32_t) r51_rd1 << 8;
      0000A3 AA E5            [24]  227 	mov	r2,_r51_rd1
      0000A5 7B 00            [12]  228 	mov	r3,#0x00
      0000A7 7E 00            [12]  229 	mov	r6,#0x00
      0000A9 8E 07            [24]  230 	mov	ar7,r6
      0000AB 8B 06            [24]  231 	mov	ar6,r3
      0000AD 8A 03            [24]  232 	mov	ar3,r2
      0000AF 7A 00            [12]  233 	mov	r2,#0x00
      0000B1 A8 08            [24]  234 	mov	r0,_bp
      0000B3 08               [12]  235 	inc	r0
      0000B4 EA               [12]  236 	mov	a,r2
      0000B5 46               [12]  237 	orl	a,@r0
      0000B6 F6               [12]  238 	mov	@r0,a
      0000B7 EB               [12]  239 	mov	a,r3
      0000B8 08               [12]  240 	inc	r0
      0000B9 46               [12]  241 	orl	a,@r0
      0000BA F6               [12]  242 	mov	@r0,a
      0000BB EE               [12]  243 	mov	a,r6
      0000BC 08               [12]  244 	inc	r0
      0000BD 46               [12]  245 	orl	a,@r0
      0000BE F6               [12]  246 	mov	@r0,a
      0000BF EF               [12]  247 	mov	a,r7
      0000C0 08               [12]  248 	inc	r0
      0000C1 46               [12]  249 	orl	a,@r0
      0000C2 F6               [12]  250 	mov	@r0,a
                                    251 ;	firmware.c:79: value |= (uint32_t) r51_rd2 << 16;
      0000C3 AC E6            [24]  252 	mov	r4,_r51_rd2
      0000C5 7D 00            [12]  253 	mov	r5,#0x00
      0000C7 8D 07            [24]  254 	mov	ar7,r5
      0000C9 8C 06            [24]  255 	mov	ar6,r4
      0000CB 7C 00            [12]  256 	mov	r4,#0x00
      0000CD 7D 00            [12]  257 	mov	r5,#0x00
      0000CF A8 08            [24]  258 	mov	r0,_bp
      0000D1 08               [12]  259 	inc	r0
      0000D2 E6               [12]  260 	mov	a,@r0
      0000D3 42 04            [12]  261 	orl	ar4,a
      0000D5 08               [12]  262 	inc	r0
      0000D6 E6               [12]  263 	mov	a,@r0
      0000D7 42 05            [12]  264 	orl	ar5,a
      0000D9 08               [12]  265 	inc	r0
      0000DA E6               [12]  266 	mov	a,@r0
      0000DB 42 06            [12]  267 	orl	ar6,a
      0000DD 08               [12]  268 	inc	r0
      0000DE E6               [12]  269 	mov	a,@r0
      0000DF 42 07            [12]  270 	orl	ar7,a
      0000E1 E5 08            [12]  271 	mov	a,_bp
      0000E3 24 05            [12]  272 	add	a,#0x05
      0000E5 F8               [12]  273 	mov	r0,a
      0000E6 A6 04            [24]  274 	mov	@r0,ar4
      0000E8 08               [12]  275 	inc	r0
      0000E9 A6 05            [24]  276 	mov	@r0,ar5
      0000EB 08               [12]  277 	inc	r0
      0000EC A6 06            [24]  278 	mov	@r0,ar6
      0000EE 08               [12]  279 	inc	r0
      0000EF A6 07            [24]  280 	mov	@r0,ar7
                                    281 ;	firmware.c:80: value |= (uint32_t) r51_rd3 << 24;
      0000F1 AA E7            [24]  282 	mov	r2,_r51_rd3
      0000F3 8A 07            [24]  283 	mov	ar7,r2
      0000F5 E4               [12]  284 	clr	a
      0000F6 FA               [12]  285 	mov	r2,a
      0000F7 FB               [12]  286 	mov	r3,a
      0000F8 FE               [12]  287 	mov	r6,a
      0000F9 E5 08            [12]  288 	mov	a,_bp
      0000FB 24 05            [12]  289 	add	a,#0x05
      0000FD F8               [12]  290 	mov	r0,a
      0000FE E6               [12]  291 	mov	a,@r0
      0000FF 42 02            [12]  292 	orl	ar2,a
      000101 08               [12]  293 	inc	r0
      000102 E6               [12]  294 	mov	a,@r0
      000103 42 03            [12]  295 	orl	ar3,a
      000105 08               [12]  296 	inc	r0
      000106 E6               [12]  297 	mov	a,@r0
      000107 42 06            [12]  298 	orl	ar6,a
      000109 08               [12]  299 	inc	r0
      00010A E6               [12]  300 	mov	a,@r0
      00010B 42 07            [12]  301 	orl	ar7,a
                                    302 ;	firmware.c:81: EA = interrupts_enabled;
      00010D E5 08            [12]  303 	mov	a,_bp
      00010F 24 09            [12]  304 	add	a,#0x09
      000111 F8               [12]  305 	mov	r0,a
                                    306 ;	assignBit
      000112 E6               [12]  307 	mov	a,@r0
      000113 24 FF            [12]  308 	add	a,#0xff
      000115 92 AF            [24]  309 	mov	_EA,c
                                    310 ;	firmware.c:82: return value;
      000117 8A 82            [24]  311 	mov	dpl,r2
      000119 8B 83            [24]  312 	mov	dph,r3
      00011B 8E F0            [24]  313 	mov	b,r6
      00011D EF               [12]  314 	mov	a,r7
                                    315 ;	firmware.c:83: }
      00011E 85 08 81         [24]  316 	mov	sp,_bp
      000121 D0 08            [24]  317 	pop	_bp
      000123 22               [24]  318 	ret
                                    319 ;------------------------------------------------------------
                                    320 ;Allocation info for local variables in function 'robot_write'
                                    321 ;------------------------------------------------------------
                                    322 ;value                     Allocated to stack - _bp -6
                                    323 ;address                   Allocated to registers r4 r5 r6 r7 
                                    324 ;interrupts_enabled        Allocated to registers r3 
                                    325 ;------------------------------------------------------------
                                    326 ;	firmware.c:85: static void robot_write(uint32_t address, uint32_t value) __reentrant
                                    327 ;	-----------------------------------------
                                    328 ;	 function robot_write
                                    329 ;	-----------------------------------------
      000124                        330 _robot_write:
      000124 C0 08            [24]  331 	push	_bp
      000126 85 81 08         [24]  332 	mov	_bp,sp
      000129 AC 82            [24]  333 	mov	r4,dpl
      00012B AD 83            [24]  334 	mov	r5,dph
      00012D AE F0            [24]  335 	mov	r6,b
      00012F FF               [12]  336 	mov	r7,a
                                    337 ;	firmware.c:87: uint8_t interrupts_enabled = EA;
      000130 A2 AF            [12]  338 	mov	c,_EA
      000132 E4               [12]  339 	clr	a
      000133 33               [12]  340 	rlc	a
      000134 FB               [12]  341 	mov	r3,a
                                    342 ;	firmware.c:89: EA = 0;
                                    343 ;	assignBit
      000135 C2 AF            [12]  344 	clr	_EA
                                    345 ;	firmware.c:90: r51_addr0 = (uint8_t) address;
      000137 8C F8            [24]  346 	mov	_r51_addr0,r4
                                    347 ;	firmware.c:91: r51_addr1 = (uint8_t) (address >> 8);
      000139 8D F9            [24]  348 	mov	_r51_addr1,r5
                                    349 ;	firmware.c:92: r51_addr2 = (uint8_t) (address >> 16);
      00013B 8E FA            [24]  350 	mov	_r51_addr2,r6
                                    351 ;	firmware.c:93: r51_addr3 = (uint8_t) (address >> 24);
      00013D 8F FB            [24]  352 	mov	_r51_addr3,r7
                                    353 ;	firmware.c:94: r51_wd0 = (uint8_t) value;
      00013F E5 08            [12]  354 	mov	a,_bp
      000141 24 FA            [12]  355 	add	a,#0xfa
      000143 F8               [12]  356 	mov	r0,a
      000144 86 F4            [24]  357 	mov	_r51_wd0,@r0
                                    358 ;	firmware.c:95: r51_wd1 = (uint8_t) (value >> 8);
      000146 E5 08            [12]  359 	mov	a,_bp
      000148 24 FA            [12]  360 	add	a,#0xfa
      00014A F8               [12]  361 	mov	r0,a
      00014B 08               [12]  362 	inc	r0
      00014C 86 F5            [24]  363 	mov	_r51_wd1,@r0
                                    364 ;	firmware.c:96: r51_wd2 = (uint8_t) (value >> 16);
      00014E E5 08            [12]  365 	mov	a,_bp
      000150 24 FA            [12]  366 	add	a,#0xfa
      000152 F8               [12]  367 	mov	r0,a
      000153 08               [12]  368 	inc	r0
      000154 08               [12]  369 	inc	r0
      000155 86 F6            [24]  370 	mov	_r51_wd2,@r0
                                    371 ;	firmware.c:97: r51_wd3 = (uint8_t) (value >> 24);
      000157 E5 08            [12]  372 	mov	a,_bp
      000159 24 FA            [12]  373 	add	a,#0xfa
      00015B F8               [12]  374 	mov	r0,a
      00015C 08               [12]  375 	inc	r0
      00015D 08               [12]  376 	inc	r0
      00015E 08               [12]  377 	inc	r0
      00015F 86 F7            [24]  378 	mov	_r51_wd3,@r0
                                    379 ;	firmware.c:98: r51_write_enable = 5; /* 32-bit write */
      000161 75 F3 05         [24]  380 	mov	_r51_write_enable,#0x05
                                    381 ;	firmware.c:99: r51_fire = 1;
      000164 75 F2 01         [24]  382 	mov	_r51_fire,#0x01
                                    383 ;	firmware.c:100: while (r51_fire == 1) {
      000167                        384 00101$:
      000167 74 01            [12]  385 	mov	a,#0x01
      000169 B5 F2 02         [24]  386 	cjne	a,_r51_fire,00114$
      00016C 80 F9            [24]  387 	sjmp	00101$
      00016E                        388 00114$:
                                    389 ;	firmware.c:102: EA = interrupts_enabled;
                                    390 ;	assignBit
      00016E EB               [12]  391 	mov	a,r3
      00016F 24 FF            [12]  392 	add	a,#0xff
      000171 92 AF            [24]  393 	mov	_EA,c
                                    394 ;	firmware.c:103: }
      000173 D0 08            [24]  395 	pop	_bp
      000175 22               [24]  396 	ret
                                    397 ;------------------------------------------------------------
                                    398 ;Allocation info for local variables in function 'gpio_write'
                                    399 ;------------------------------------------------------------
                                    400 ;high                      Allocated to stack - _bp -3
                                    401 ;pin                       Allocated to registers r7 
                                    402 ;value                     Allocated to stack - _bp +5
                                    403 ;mask                      Allocated to stack - _bp +9
                                    404 ;sloc0                     Allocated to stack - _bp +1
                                    405 ;------------------------------------------------------------
                                    406 ;	firmware.c:105: static void gpio_write(uint8_t pin, uint8_t high)
                                    407 ;	-----------------------------------------
                                    408 ;	 function gpio_write
                                    409 ;	-----------------------------------------
      000176                        410 _gpio_write:
      000176 C0 08            [24]  411 	push	_bp
      000178 E5 81            [12]  412 	mov	a,sp
      00017A F5 08            [12]  413 	mov	_bp,a
      00017C 24 0C            [12]  414 	add	a,#0x0c
      00017E F5 81            [12]  415 	mov	sp,a
      000180 AF 82            [24]  416 	mov	r7,dpl
                                    417 ;	firmware.c:107: uint32_t value = robot_read(GPIOA_BASE + GPIO_DATA);
      000182 90 00 00         [24]  418 	mov	dptr,#0x0000
      000185 75 F0 02         [24]  419 	mov	b,#0x02
      000188 74 03            [12]  420 	mov	a,#0x03
      00018A C0 07            [24]  421 	push	ar7
      00018C 12 00 62         [24]  422 	lcall	_robot_read
      00018F AB 82            [24]  423 	mov	r3,dpl
      000191 AC 83            [24]  424 	mov	r4,dph
      000193 AD F0            [24]  425 	mov	r5,b
      000195 FE               [12]  426 	mov	r6,a
      000196 D0 07            [24]  427 	pop	ar7
      000198 E5 08            [12]  428 	mov	a,_bp
      00019A 24 05            [12]  429 	add	a,#0x05
      00019C F8               [12]  430 	mov	r0,a
      00019D A6 03            [24]  431 	mov	@r0,ar3
      00019F 08               [12]  432 	inc	r0
      0001A0 A6 04            [24]  433 	mov	@r0,ar4
      0001A2 08               [12]  434 	inc	r0
      0001A3 A6 05            [24]  435 	mov	@r0,ar5
      0001A5 08               [12]  436 	inc	r0
      0001A6 A6 06            [24]  437 	mov	@r0,ar6
                                    438 ;	firmware.c:108: uint32_t mask = (uint32_t) 1U << pin;
      0001A8 8F F0            [24]  439 	mov	b,r7
      0001AA 05 F0            [12]  440 	inc	b
      0001AC E5 08            [12]  441 	mov	a,_bp
      0001AE 24 09            [12]  442 	add	a,#0x09
      0001B0 F8               [12]  443 	mov	r0,a
      0001B1 76 01            [12]  444 	mov	@r0,#0x01
      0001B3 08               [12]  445 	inc	r0
      0001B4 76 00            [12]  446 	mov	@r0,#0x00
      0001B6 08               [12]  447 	inc	r0
      0001B7 76 00            [12]  448 	mov	@r0,#0x00
      0001B9 08               [12]  449 	inc	r0
      0001BA 76 00            [12]  450 	mov	@r0,#0x00
      0001BC 18               [12]  451 	dec	r0
      0001BD 18               [12]  452 	dec	r0
      0001BE 18               [12]  453 	dec	r0
      0001BF 80 12            [24]  454 	sjmp	00110$
      0001C1                        455 00109$:
      0001C1 E6               [12]  456 	mov	a,@r0
      0001C2 26               [12]  457 	add	a,@r0
      0001C3 F6               [12]  458 	mov	@r0,a
      0001C4 08               [12]  459 	inc	r0
      0001C5 E6               [12]  460 	mov	a,@r0
      0001C6 33               [12]  461 	rlc	a
      0001C7 F6               [12]  462 	mov	@r0,a
      0001C8 08               [12]  463 	inc	r0
      0001C9 E6               [12]  464 	mov	a,@r0
      0001CA 33               [12]  465 	rlc	a
      0001CB F6               [12]  466 	mov	@r0,a
      0001CC 08               [12]  467 	inc	r0
      0001CD E6               [12]  468 	mov	a,@r0
      0001CE 33               [12]  469 	rlc	a
      0001CF F6               [12]  470 	mov	@r0,a
      0001D0 18               [12]  471 	dec	r0
      0001D1 18               [12]  472 	dec	r0
      0001D2 18               [12]  473 	dec	r0
      0001D3                        474 00110$:
      0001D3 D5 F0 EB         [24]  475 	djnz	b,00109$
                                    476 ;	firmware.c:110: robot_write(GPIOA_BASE + GPIO_DATA, high ? value | mask : value & ~mask);
      0001D6 E5 08            [12]  477 	mov	a,_bp
      0001D8 24 FD            [12]  478 	add	a,#0xfd
      0001DA F8               [12]  479 	mov	r0,a
      0001DB E6               [12]  480 	mov	a,@r0
      0001DC 60 1E            [24]  481 	jz	00103$
      0001DE E5 08            [12]  482 	mov	a,_bp
      0001E0 24 05            [12]  483 	add	a,#0x05
      0001E2 F8               [12]  484 	mov	r0,a
      0001E3 E5 08            [12]  485 	mov	a,_bp
      0001E5 24 09            [12]  486 	add	a,#0x09
      0001E7 F9               [12]  487 	mov	r1,a
      0001E8 E7               [12]  488 	mov	a,@r1
      0001E9 46               [12]  489 	orl	a,@r0
      0001EA FB               [12]  490 	mov	r3,a
      0001EB 09               [12]  491 	inc	r1
      0001EC E7               [12]  492 	mov	a,@r1
      0001ED 08               [12]  493 	inc	r0
      0001EE 46               [12]  494 	orl	a,@r0
      0001EF FC               [12]  495 	mov	r4,a
      0001F0 09               [12]  496 	inc	r1
      0001F1 E7               [12]  497 	mov	a,@r1
      0001F2 08               [12]  498 	inc	r0
      0001F3 46               [12]  499 	orl	a,@r0
      0001F4 FE               [12]  500 	mov	r6,a
      0001F5 09               [12]  501 	inc	r1
      0001F6 E7               [12]  502 	mov	a,@r1
      0001F7 08               [12]  503 	inc	r0
      0001F8 46               [12]  504 	orl	a,@r0
      0001F9 FF               [12]  505 	mov	r7,a
      0001FA 80 34            [24]  506 	sjmp	00104$
      0001FC                        507 00103$:
      0001FC E5 08            [12]  508 	mov	a,_bp
      0001FE 24 09            [12]  509 	add	a,#0x09
      000200 F8               [12]  510 	mov	r0,a
      000201 A9 08            [24]  511 	mov	r1,_bp
      000203 09               [12]  512 	inc	r1
      000204 E6               [12]  513 	mov	a,@r0
      000205 F4               [12]  514 	cpl	a
      000206 F7               [12]  515 	mov	@r1,a
      000207 08               [12]  516 	inc	r0
      000208 E6               [12]  517 	mov	a,@r0
      000209 F4               [12]  518 	cpl	a
      00020A 09               [12]  519 	inc	r1
      00020B F7               [12]  520 	mov	@r1,a
      00020C 08               [12]  521 	inc	r0
      00020D E6               [12]  522 	mov	a,@r0
      00020E F4               [12]  523 	cpl	a
      00020F 09               [12]  524 	inc	r1
      000210 F7               [12]  525 	mov	@r1,a
      000211 08               [12]  526 	inc	r0
      000212 E6               [12]  527 	mov	a,@r0
      000213 F4               [12]  528 	cpl	a
      000214 09               [12]  529 	inc	r1
      000215 F7               [12]  530 	mov	@r1,a
      000216 E5 08            [12]  531 	mov	a,_bp
      000218 24 05            [12]  532 	add	a,#0x05
      00021A F8               [12]  533 	mov	r0,a
      00021B A9 08            [24]  534 	mov	r1,_bp
      00021D 09               [12]  535 	inc	r1
      00021E E7               [12]  536 	mov	a,@r1
      00021F 56               [12]  537 	anl	a,@r0
      000220 FB               [12]  538 	mov	r3,a
      000221 09               [12]  539 	inc	r1
      000222 E7               [12]  540 	mov	a,@r1
      000223 08               [12]  541 	inc	r0
      000224 56               [12]  542 	anl	a,@r0
      000225 FC               [12]  543 	mov	r4,a
      000226 09               [12]  544 	inc	r1
      000227 E7               [12]  545 	mov	a,@r1
      000228 08               [12]  546 	inc	r0
      000229 56               [12]  547 	anl	a,@r0
      00022A FE               [12]  548 	mov	r6,a
      00022B 09               [12]  549 	inc	r1
      00022C E7               [12]  550 	mov	a,@r1
      00022D 08               [12]  551 	inc	r0
      00022E 56               [12]  552 	anl	a,@r0
      00022F FF               [12]  553 	mov	r7,a
      000230                        554 00104$:
      000230 C0 03            [24]  555 	push	ar3
      000232 C0 04            [24]  556 	push	ar4
      000234 C0 06            [24]  557 	push	ar6
      000236 C0 07            [24]  558 	push	ar7
      000238 90 00 00         [24]  559 	mov	dptr,#0x0000
      00023B 75 F0 02         [24]  560 	mov	b,#0x02
      00023E 74 03            [12]  561 	mov	a,#0x03
      000240 12 01 24         [24]  562 	lcall	_robot_write
      000243 E5 81            [12]  563 	mov	a,sp
      000245 24 FC            [12]  564 	add	a,#0xfc
      000247 F5 81            [12]  565 	mov	sp,a
                                    566 ;	firmware.c:111: }
      000249 85 08 81         [24]  567 	mov	sp,_bp
      00024C D0 08            [24]  568 	pop	_bp
      00024E 22               [24]  569 	ret
                                    570 ;------------------------------------------------------------
                                    571 ;Allocation info for local variables in function 'gpio_output'
                                    572 ;------------------------------------------------------------
                                    573 ;pin                       Allocated to registers r7 
                                    574 ;value                     Allocated to stack - _bp +1
                                    575 ;------------------------------------------------------------
                                    576 ;	firmware.c:113: static void gpio_output(uint8_t pin)
                                    577 ;	-----------------------------------------
                                    578 ;	 function gpio_output
                                    579 ;	-----------------------------------------
      00024F                        580 _gpio_output:
      00024F C0 08            [24]  581 	push	_bp
      000251 E5 81            [12]  582 	mov	a,sp
      000253 F5 08            [12]  583 	mov	_bp,a
      000255 24 04            [12]  584 	add	a,#0x04
      000257 F5 81            [12]  585 	mov	sp,a
      000259 AF 82            [24]  586 	mov	r7,dpl
                                    587 ;	firmware.c:115: uint32_t value = robot_read(GPIOA_BASE + GPIO_DIRECTION);
      00025B 90 00 04         [24]  588 	mov	dptr,#0x0004
      00025E 75 F0 02         [24]  589 	mov	b,#0x02
      000261 74 03            [12]  590 	mov	a,#0x03
      000263 C0 07            [24]  591 	push	ar7
      000265 12 00 62         [24]  592 	lcall	_robot_read
      000268 AB 82            [24]  593 	mov	r3,dpl
      00026A AC 83            [24]  594 	mov	r4,dph
      00026C AD F0            [24]  595 	mov	r5,b
      00026E FE               [12]  596 	mov	r6,a
      00026F D0 07            [24]  597 	pop	ar7
      000271 A8 08            [24]  598 	mov	r0,_bp
      000273 08               [12]  599 	inc	r0
      000274 A6 03            [24]  600 	mov	@r0,ar3
      000276 08               [12]  601 	inc	r0
      000277 A6 04            [24]  602 	mov	@r0,ar4
      000279 08               [12]  603 	inc	r0
      00027A A6 05            [24]  604 	mov	@r0,ar5
      00027C 08               [12]  605 	inc	r0
      00027D A6 06            [24]  606 	mov	@r0,ar6
                                    607 ;	firmware.c:117: robot_write(GPIOA_BASE + GPIO_DIRECTION, value | ((uint32_t) 1U << pin));
      00027F 8F F0            [24]  608 	mov	b,r7
      000281 05 F0            [12]  609 	inc	b
      000283 7A 01            [12]  610 	mov	r2,#0x01
      000285 7D 00            [12]  611 	mov	r5,#0x00
      000287 7E 00            [12]  612 	mov	r6,#0x00
      000289 7F 00            [12]  613 	mov	r7,#0x00
      00028B 80 0C            [24]  614 	sjmp	00104$
      00028D                        615 00103$:
      00028D EA               [12]  616 	mov	a,r2
      00028E 2A               [12]  617 	add	a,r2
      00028F FA               [12]  618 	mov	r2,a
      000290 ED               [12]  619 	mov	a,r5
      000291 33               [12]  620 	rlc	a
      000292 FD               [12]  621 	mov	r5,a
      000293 EE               [12]  622 	mov	a,r6
      000294 33               [12]  623 	rlc	a
      000295 FE               [12]  624 	mov	r6,a
      000296 EF               [12]  625 	mov	a,r7
      000297 33               [12]  626 	rlc	a
      000298 FF               [12]  627 	mov	r7,a
      000299                        628 00104$:
      000299 D5 F0 F1         [24]  629 	djnz	b,00103$
      00029C A8 08            [24]  630 	mov	r0,_bp
      00029E 08               [12]  631 	inc	r0
      00029F E6               [12]  632 	mov	a,@r0
      0002A0 42 02            [12]  633 	orl	ar2,a
      0002A2 08               [12]  634 	inc	r0
      0002A3 E6               [12]  635 	mov	a,@r0
      0002A4 42 05            [12]  636 	orl	ar5,a
      0002A6 08               [12]  637 	inc	r0
      0002A7 E6               [12]  638 	mov	a,@r0
      0002A8 42 06            [12]  639 	orl	ar6,a
      0002AA 08               [12]  640 	inc	r0
      0002AB E6               [12]  641 	mov	a,@r0
      0002AC 42 07            [12]  642 	orl	ar7,a
      0002AE C0 02            [24]  643 	push	ar2
      0002B0 C0 05            [24]  644 	push	ar5
      0002B2 C0 06            [24]  645 	push	ar6
      0002B4 C0 07            [24]  646 	push	ar7
      0002B6 90 00 04         [24]  647 	mov	dptr,#0x0004
      0002B9 75 F0 02         [24]  648 	mov	b,#0x02
      0002BC 74 03            [12]  649 	mov	a,#0x03
      0002BE 12 01 24         [24]  650 	lcall	_robot_write
      0002C1 E5 81            [12]  651 	mov	a,sp
      0002C3 24 FC            [12]  652 	add	a,#0xfc
      0002C5 F5 81            [12]  653 	mov	sp,a
                                    654 ;	firmware.c:118: }
      0002C7 85 08 81         [24]  655 	mov	sp,_bp
      0002CA D0 08            [24]  656 	pop	_bp
      0002CC 22               [24]  657 	ret
                                    658 ;------------------------------------------------------------
                                    659 ;Allocation info for local variables in function 'gpio_input'
                                    660 ;------------------------------------------------------------
                                    661 ;pin                       Allocated to registers r7 
                                    662 ;value                     Allocated to stack - _bp +1
                                    663 ;------------------------------------------------------------
                                    664 ;	firmware.c:120: static void gpio_input(uint8_t pin)
                                    665 ;	-----------------------------------------
                                    666 ;	 function gpio_input
                                    667 ;	-----------------------------------------
      0002CD                        668 _gpio_input:
      0002CD C0 08            [24]  669 	push	_bp
      0002CF E5 81            [12]  670 	mov	a,sp
      0002D1 F5 08            [12]  671 	mov	_bp,a
      0002D3 24 04            [12]  672 	add	a,#0x04
      0002D5 F5 81            [12]  673 	mov	sp,a
      0002D7 AF 82            [24]  674 	mov	r7,dpl
                                    675 ;	firmware.c:122: uint32_t value = robot_read(GPIOA_BASE + GPIO_DIRECTION);
      0002D9 90 00 04         [24]  676 	mov	dptr,#0x0004
      0002DC 75 F0 02         [24]  677 	mov	b,#0x02
      0002DF 74 03            [12]  678 	mov	a,#0x03
      0002E1 C0 07            [24]  679 	push	ar7
      0002E3 12 00 62         [24]  680 	lcall	_robot_read
      0002E6 AB 82            [24]  681 	mov	r3,dpl
      0002E8 AC 83            [24]  682 	mov	r4,dph
      0002EA AD F0            [24]  683 	mov	r5,b
      0002EC FE               [12]  684 	mov	r6,a
      0002ED D0 07            [24]  685 	pop	ar7
      0002EF A8 08            [24]  686 	mov	r0,_bp
      0002F1 08               [12]  687 	inc	r0
      0002F2 A6 03            [24]  688 	mov	@r0,ar3
      0002F4 08               [12]  689 	inc	r0
      0002F5 A6 04            [24]  690 	mov	@r0,ar4
      0002F7 08               [12]  691 	inc	r0
      0002F8 A6 05            [24]  692 	mov	@r0,ar5
      0002FA 08               [12]  693 	inc	r0
      0002FB A6 06            [24]  694 	mov	@r0,ar6
                                    695 ;	firmware.c:124: robot_write(GPIOA_BASE + GPIO_DIRECTION, value & ~((uint32_t) 1U << pin));
      0002FD 8F F0            [24]  696 	mov	b,r7
      0002FF 05 F0            [12]  697 	inc	b
      000301 7A 01            [12]  698 	mov	r2,#0x01
      000303 7D 00            [12]  699 	mov	r5,#0x00
      000305 7E 00            [12]  700 	mov	r6,#0x00
      000307 7F 00            [12]  701 	mov	r7,#0x00
      000309 80 0C            [24]  702 	sjmp	00104$
      00030B                        703 00103$:
      00030B EA               [12]  704 	mov	a,r2
      00030C 2A               [12]  705 	add	a,r2
      00030D FA               [12]  706 	mov	r2,a
      00030E ED               [12]  707 	mov	a,r5
      00030F 33               [12]  708 	rlc	a
      000310 FD               [12]  709 	mov	r5,a
      000311 EE               [12]  710 	mov	a,r6
      000312 33               [12]  711 	rlc	a
      000313 FE               [12]  712 	mov	r6,a
      000314 EF               [12]  713 	mov	a,r7
      000315 33               [12]  714 	rlc	a
      000316 FF               [12]  715 	mov	r7,a
      000317                        716 00104$:
      000317 D5 F0 F1         [24]  717 	djnz	b,00103$
      00031A EA               [12]  718 	mov	a,r2
      00031B F4               [12]  719 	cpl	a
      00031C FA               [12]  720 	mov	r2,a
      00031D ED               [12]  721 	mov	a,r5
      00031E F4               [12]  722 	cpl	a
      00031F FD               [12]  723 	mov	r5,a
      000320 EE               [12]  724 	mov	a,r6
      000321 F4               [12]  725 	cpl	a
      000322 FE               [12]  726 	mov	r6,a
      000323 EF               [12]  727 	mov	a,r7
      000324 F4               [12]  728 	cpl	a
      000325 FF               [12]  729 	mov	r7,a
      000326 A8 08            [24]  730 	mov	r0,_bp
      000328 08               [12]  731 	inc	r0
      000329 E6               [12]  732 	mov	a,@r0
      00032A 52 02            [12]  733 	anl	ar2,a
      00032C 08               [12]  734 	inc	r0
      00032D E6               [12]  735 	mov	a,@r0
      00032E 52 05            [12]  736 	anl	ar5,a
      000330 08               [12]  737 	inc	r0
      000331 E6               [12]  738 	mov	a,@r0
      000332 52 06            [12]  739 	anl	ar6,a
      000334 08               [12]  740 	inc	r0
      000335 E6               [12]  741 	mov	a,@r0
      000336 52 07            [12]  742 	anl	ar7,a
      000338 C0 02            [24]  743 	push	ar2
      00033A C0 05            [24]  744 	push	ar5
      00033C C0 06            [24]  745 	push	ar6
      00033E C0 07            [24]  746 	push	ar7
      000340 90 00 04         [24]  747 	mov	dptr,#0x0004
      000343 75 F0 02         [24]  748 	mov	b,#0x02
      000346 74 03            [12]  749 	mov	a,#0x03
      000348 12 01 24         [24]  750 	lcall	_robot_write
      00034B E5 81            [12]  751 	mov	a,sp
      00034D 24 FC            [12]  752 	add	a,#0xfc
      00034F F5 81            [12]  753 	mov	sp,a
                                    754 ;	firmware.c:125: }
      000351 85 08 81         [24]  755 	mov	sp,_bp
      000354 D0 08            [24]  756 	pop	_bp
      000356 22               [24]  757 	ret
                                    758 ;------------------------------------------------------------
                                    759 ;Allocation info for local variables in function 'gpio_read'
                                    760 ;------------------------------------------------------------
                                    761 ;pin                       Allocated to registers r7 
                                    762 ;------------------------------------------------------------
                                    763 ;	firmware.c:127: static uint8_t gpio_read(uint8_t pin)
                                    764 ;	-----------------------------------------
                                    765 ;	 function gpio_read
                                    766 ;	-----------------------------------------
      000357                        767 _gpio_read:
      000357 AF 82            [24]  768 	mov	r7,dpl
                                    769 ;	firmware.c:129: return (uint8_t) ((robot_read(GPIOA_BASE + GPIO_EXTERNAL_PORT) >> pin) & 1U);
      000359 90 00 50         [24]  770 	mov	dptr,#0x0050
      00035C 75 F0 02         [24]  771 	mov	b,#0x02
      00035F 74 03            [12]  772 	mov	a,#0x03
      000361 C0 07            [24]  773 	push	ar7
      000363 12 00 62         [24]  774 	lcall	_robot_read
      000366 AB 82            [24]  775 	mov	r3,dpl
      000368 AC 83            [24]  776 	mov	r4,dph
      00036A AD F0            [24]  777 	mov	r5,b
      00036C FE               [12]  778 	mov	r6,a
      00036D D0 07            [24]  779 	pop	ar7
      00036F 8F F0            [24]  780 	mov	b,r7
      000371 05 F0            [12]  781 	inc	b
      000373 80 0D            [24]  782 	sjmp	00104$
      000375                        783 00103$:
      000375 C3               [12]  784 	clr	c
      000376 EE               [12]  785 	mov	a,r6
      000377 13               [12]  786 	rrc	a
      000378 FE               [12]  787 	mov	r6,a
      000379 ED               [12]  788 	mov	a,r5
      00037A 13               [12]  789 	rrc	a
      00037B FD               [12]  790 	mov	r5,a
      00037C EC               [12]  791 	mov	a,r4
      00037D 13               [12]  792 	rrc	a
      00037E FC               [12]  793 	mov	r4,a
      00037F EB               [12]  794 	mov	a,r3
      000380 13               [12]  795 	rrc	a
      000381 FB               [12]  796 	mov	r3,a
      000382                        797 00104$:
      000382 D5 F0 F0         [24]  798 	djnz	b,00103$
      000385 53 03 01         [24]  799 	anl	ar3,#0x01
      000388 8B 82            [24]  800 	mov	dpl,r3
                                    801 ;	firmware.c:130: }
      00038A 22               [24]  802 	ret
                                    803 ;------------------------------------------------------------
                                    804 ;Allocation info for local variables in function 'delay_us'
                                    805 ;------------------------------------------------------------
                                    806 ;microseconds              Allocated to registers 
                                    807 ;loops                     Allocated to stack - _bp +1
                                    808 ;------------------------------------------------------------
                                    809 ;	firmware.c:137: static void delay_us(uint16_t microseconds)
                                    810 ;	-----------------------------------------
                                    811 ;	 function delay_us
                                    812 ;	-----------------------------------------
      00038B                        813 _delay_us:
      00038B C0 08            [24]  814 	push	_bp
      00038D 85 81 08         [24]  815 	mov	_bp,sp
      000390 05 81            [12]  816 	inc	sp
      000392 AE 82            [24]  817 	mov	r6,dpl
      000394 AF 83            [24]  818 	mov	r7,dph
                                    819 ;	firmware.c:141: while (microseconds-- != 0U) {
      000396                        820 00104$:
      000396 8E 04            [24]  821 	mov	ar4,r6
      000398 8F 05            [24]  822 	mov	ar5,r7
      00039A 1E               [12]  823 	dec	r6
      00039B BE FF 01         [24]  824 	cjne	r6,#0xff,00126$
      00039E 1F               [12]  825 	dec	r7
      00039F                        826 00126$:
      00039F EC               [12]  827 	mov	a,r4
      0003A0 4D               [12]  828 	orl	a,r5
      0003A1 60 15            [24]  829 	jz	00107$
                                    830 ;	firmware.c:142: loops = 10;
      0003A3 A8 08            [24]  831 	mov	r0,_bp
      0003A5 08               [12]  832 	inc	r0
      0003A6 76 0A            [12]  833 	mov	@r0,#0x0a
                                    834 ;	firmware.c:143: while (loops-- != 0U) {
      0003A8                        835 00101$:
      0003A8 A8 08            [24]  836 	mov	r0,_bp
      0003AA 08               [12]  837 	inc	r0
      0003AB 86 05            [24]  838 	mov	ar5,@r0
      0003AD A8 08            [24]  839 	mov	r0,_bp
      0003AF 08               [12]  840 	inc	r0
      0003B0 ED               [12]  841 	mov	a,r5
      0003B1 14               [12]  842 	dec	a
      0003B2 F6               [12]  843 	mov	@r0,a
      0003B3 ED               [12]  844 	mov	a,r5
      0003B4 60 E0            [24]  845 	jz	00104$
      0003B6 80 F0            [24]  846 	sjmp	00101$
      0003B8                        847 00107$:
                                    848 ;	firmware.c:146: }
      0003B8 15 81            [12]  849 	dec	sp
      0003BA D0 08            [24]  850 	pop	_bp
      0003BC 22               [24]  851 	ret
                                    852 ;------------------------------------------------------------
                                    853 ;Allocation info for local variables in function 'delay_ms'
                                    854 ;------------------------------------------------------------
                                    855 ;milliseconds              Allocated to registers 
                                    856 ;------------------------------------------------------------
                                    857 ;	firmware.c:148: static void delay_ms(uint16_t milliseconds)
                                    858 ;	-----------------------------------------
                                    859 ;	 function delay_ms
                                    860 ;	-----------------------------------------
      0003BD                        861 _delay_ms:
      0003BD AE 82            [24]  862 	mov	r6,dpl
      0003BF AF 83            [24]  863 	mov	r7,dph
                                    864 ;	firmware.c:150: while (milliseconds-- != 0U) {
      0003C1                        865 00101$:
      0003C1 8E 04            [24]  866 	mov	ar4,r6
      0003C3 8F 05            [24]  867 	mov	ar5,r7
      0003C5 1E               [12]  868 	dec	r6
      0003C6 BE FF 01         [24]  869 	cjne	r6,#0xff,00115$
      0003C9 1F               [12]  870 	dec	r7
      0003CA                        871 00115$:
      0003CA EC               [12]  872 	mov	a,r4
      0003CB 4D               [12]  873 	orl	a,r5
      0003CC 60 10            [24]  874 	jz	00104$
                                    875 ;	firmware.c:151: delay_us(1000);
      0003CE 90 03 E8         [24]  876 	mov	dptr,#0x03e8
      0003D1 C0 07            [24]  877 	push	ar7
      0003D3 C0 06            [24]  878 	push	ar6
      0003D5 12 03 8B         [24]  879 	lcall	_delay_us
      0003D8 D0 06            [24]  880 	pop	ar6
      0003DA D0 07            [24]  881 	pop	ar7
      0003DC 80 E3            [24]  882 	sjmp	00101$
      0003DE                        883 00104$:
                                    884 ;	firmware.c:153: }
      0003DE 22               [24]  885 	ret
                                    886 ;------------------------------------------------------------
                                    887 ;Allocation info for local variables in function 'wait_for_level'
                                    888 ;------------------------------------------------------------
                                    889 ;level                     Allocated to registers r7 
                                    890 ;polls                     Allocated to registers r6 
                                    891 ;------------------------------------------------------------
                                    892 ;	firmware.c:155: static uint8_t wait_for_level(uint8_t level)
                                    893 ;	-----------------------------------------
                                    894 ;	 function wait_for_level
                                    895 ;	-----------------------------------------
      0003DF                        896 _wait_for_level:
      0003DF AF 82            [24]  897 	mov	r7,dpl
                                    898 ;	firmware.c:159: while (polls-- != 0U) {
      0003E1 7E FF            [12]  899 	mov	r6,#0xff
      0003E3                        900 00103$:
      0003E3 8E 05            [24]  901 	mov	ar5,r6
      0003E5 1E               [12]  902 	dec	r6
      0003E6 ED               [12]  903 	mov	a,r5
      0003E7 60 18            [24]  904 	jz	00105$
                                    905 ;	firmware.c:160: if (gpio_read(DHT_GPIO_PIN) == level) {
      0003E9 75 82 1A         [24]  906 	mov	dpl,#0x1a
      0003EC C0 07            [24]  907 	push	ar7
      0003EE C0 06            [24]  908 	push	ar6
      0003F0 12 03 57         [24]  909 	lcall	_gpio_read
      0003F3 AD 82            [24]  910 	mov	r5,dpl
      0003F5 D0 06            [24]  911 	pop	ar6
      0003F7 D0 07            [24]  912 	pop	ar7
      0003F9 ED               [12]  913 	mov	a,r5
      0003FA B5 07 E6         [24]  914 	cjne	a,ar7,00103$
                                    915 ;	firmware.c:161: return 1;
      0003FD 75 82 01         [24]  916 	mov	dpl,#0x01
      000400 22               [24]  917 	ret
      000401                        918 00105$:
                                    919 ;	firmware.c:164: return 0;
      000401 75 82 00         [24]  920 	mov	dpl,#0x00
                                    921 ;	firmware.c:165: }
      000404 22               [24]  922 	ret
                                    923 ;------------------------------------------------------------
                                    924 ;Allocation info for local variables in function 'dht11_read'
                                    925 ;------------------------------------------------------------
                                    926 ;bytes                     Allocated to stack - _bp +1
                                    927 ;byte_index                Allocated to registers r5 
                                    928 ;bit_index                 Allocated to registers r2 
                                    929 ;value                     Allocated to registers r6 
                                    930 ;------------------------------------------------------------
                                    931 ;	firmware.c:167: static uint8_t dht11_read(uint8_t bytes[5])
                                    932 ;	-----------------------------------------
                                    933 ;	 function dht11_read
                                    934 ;	-----------------------------------------
      000405                        935 _dht11_read:
      000405 C0 08            [24]  936 	push	_bp
      000407 85 81 08         [24]  937 	mov	_bp,sp
      00040A C0 82            [24]  938 	push	dpl
      00040C C0 83            [24]  939 	push	dph
      00040E C0 F0            [24]  940 	push	b
                                    941 ;	firmware.c:173: gpio_write(DHT_GPIO_PIN, 0);
      000410 E4               [12]  942 	clr	a
      000411 C0 E0            [24]  943 	push	acc
      000413 75 82 1A         [24]  944 	mov	dpl,#0x1a
      000416 12 01 76         [24]  945 	lcall	_gpio_write
      000419 15 81            [12]  946 	dec	sp
                                    947 ;	firmware.c:174: gpio_output(DHT_GPIO_PIN);
      00041B 75 82 1A         [24]  948 	mov	dpl,#0x1a
      00041E 12 02 4F         [24]  949 	lcall	_gpio_output
                                    950 ;	firmware.c:175: delay_ms(DHT_START_LOW_MS);
      000421 90 00 14         [24]  951 	mov	dptr,#0x0014
      000424 12 03 BD         [24]  952 	lcall	_delay_ms
                                    953 ;	firmware.c:176: gpio_input(DHT_GPIO_PIN);
      000427 75 82 1A         [24]  954 	mov	dpl,#0x1a
      00042A 12 02 CD         [24]  955 	lcall	_gpio_input
                                    956 ;	firmware.c:177: delay_us(DHT_RESPONSE_DELAY_US);
      00042D 90 00 28         [24]  957 	mov	dptr,#0x0028
      000430 12 03 8B         [24]  958 	lcall	_delay_us
                                    959 ;	firmware.c:179: if (!wait_for_level(0) || !wait_for_level(1) || !wait_for_level(0)) {
      000433 75 82 00         [24]  960 	mov	dpl,#0x00
      000436 12 03 DF         [24]  961 	lcall	_wait_for_level
      000439 E5 82            [12]  962 	mov	a,dpl
      00043B 60 14            [24]  963 	jz	00101$
      00043D 75 82 01         [24]  964 	mov	dpl,#0x01
      000440 12 03 DF         [24]  965 	lcall	_wait_for_level
      000443 E5 82            [12]  966 	mov	a,dpl
      000445 60 0A            [24]  967 	jz	00101$
      000447 75 82 00         [24]  968 	mov	dpl,#0x00
      00044A 12 03 DF         [24]  969 	lcall	_wait_for_level
      00044D E5 82            [12]  970 	mov	a,dpl
      00044F 70 06            [24]  971 	jnz	00125$
      000451                        972 00101$:
                                    973 ;	firmware.c:180: return 1;
      000451 75 82 01         [24]  974 	mov	dpl,#0x01
      000454 02 05 6C         [24]  975 	ljmp	00117$
                                    976 ;	firmware.c:183: for (byte_index = 0; byte_index < 5; ++byte_index) {
      000457                        977 00125$:
      000457 7D 00            [12]  978 	mov	r5,#0x00
      000459                        979 00115$:
                                    980 ;	firmware.c:184: value = 0;
      000459 7E 00            [12]  981 	mov	r6,#0x00
                                    982 ;	firmware.c:185: for (bit_index = 0; bit_index < 8; ++bit_index) {
      00045B 7A 00            [12]  983 	mov	r2,#0x00
      00045D                        984 00113$:
                                    985 ;	firmware.c:186: if (!wait_for_level(1)) {
      00045D 75 82 01         [24]  986 	mov	dpl,#0x01
      000460 C0 06            [24]  987 	push	ar6
      000462 C0 05            [24]  988 	push	ar5
      000464 C0 02            [24]  989 	push	ar2
      000466 12 03 DF         [24]  990 	lcall	_wait_for_level
      000469 E5 82            [12]  991 	mov	a,dpl
      00046B D0 02            [24]  992 	pop	ar2
      00046D D0 05            [24]  993 	pop	ar5
      00046F D0 06            [24]  994 	pop	ar6
      000471 70 06            [24]  995 	jnz	00106$
                                    996 ;	firmware.c:187: return 2;
      000473 75 82 02         [24]  997 	mov	dpl,#0x02
      000476 02 05 6C         [24]  998 	ljmp	00117$
      000479                        999 00106$:
                                   1000 ;	firmware.c:189: delay_us(DHT_BIT_SAMPLE_US);
      000479 90 00 28         [24] 1001 	mov	dptr,#0x0028
      00047C C0 06            [24] 1002 	push	ar6
      00047E C0 05            [24] 1003 	push	ar5
      000480 C0 02            [24] 1004 	push	ar2
      000482 12 03 8B         [24] 1005 	lcall	_delay_us
      000485 D0 02            [24] 1006 	pop	ar2
      000487 D0 05            [24] 1007 	pop	ar5
      000489 D0 06            [24] 1008 	pop	ar6
                                   1009 ;	firmware.c:190: value = (uint8_t) ((value << 1) | gpio_read(DHT_GPIO_PIN));
      00048B 8E 07            [24] 1010 	mov	ar7,r6
      00048D EF               [12] 1011 	mov	a,r7
      00048E 2F               [12] 1012 	add	a,r7
      00048F FF               [12] 1013 	mov	r7,a
      000490 75 82 1A         [24] 1014 	mov	dpl,#0x1a
      000493 C0 07            [24] 1015 	push	ar7
      000495 C0 05            [24] 1016 	push	ar5
      000497 C0 02            [24] 1017 	push	ar2
      000499 12 03 57         [24] 1018 	lcall	_gpio_read
      00049C AE 82            [24] 1019 	mov	r6,dpl
      00049E D0 02            [24] 1020 	pop	ar2
      0004A0 D0 05            [24] 1021 	pop	ar5
      0004A2 D0 07            [24] 1022 	pop	ar7
      0004A4 EE               [12] 1023 	mov	a,r6
      0004A5 42 07            [12] 1024 	orl	ar7,a
      0004A7 8F 06            [24] 1025 	mov	ar6,r7
                                   1026 ;	firmware.c:191: if (!wait_for_level(0)) {
      0004A9 75 82 00         [24] 1027 	mov	dpl,#0x00
      0004AC C0 06            [24] 1028 	push	ar6
      0004AE C0 05            [24] 1029 	push	ar5
      0004B0 C0 02            [24] 1030 	push	ar2
      0004B2 12 03 DF         [24] 1031 	lcall	_wait_for_level
      0004B5 E5 82            [12] 1032 	mov	a,dpl
      0004B7 D0 02            [24] 1033 	pop	ar2
      0004B9 D0 05            [24] 1034 	pop	ar5
      0004BB D0 06            [24] 1035 	pop	ar6
      0004BD 70 06            [24] 1036 	jnz	00114$
                                   1037 ;	firmware.c:192: return 2;
      0004BF 75 82 02         [24] 1038 	mov	dpl,#0x02
      0004C2 02 05 6C         [24] 1039 	ljmp	00117$
      0004C5                       1040 00114$:
                                   1041 ;	firmware.c:185: for (bit_index = 0; bit_index < 8; ++bit_index) {
      0004C5 0A               [12] 1042 	inc	r2
      0004C6 BA 08 00         [24] 1043 	cjne	r2,#0x08,00160$
      0004C9                       1044 00160$:
      0004C9 40 92            [24] 1045 	jc	00113$
                                   1046 ;	firmware.c:195: bytes[byte_index] = value;
      0004CB A8 08            [24] 1047 	mov	r0,_bp
      0004CD 08               [12] 1048 	inc	r0
      0004CE ED               [12] 1049 	mov	a,r5
      0004CF 26               [12] 1050 	add	a,@r0
      0004D0 FA               [12] 1051 	mov	r2,a
      0004D1 E4               [12] 1052 	clr	a
      0004D2 08               [12] 1053 	inc	r0
      0004D3 36               [12] 1054 	addc	a,@r0
      0004D4 FB               [12] 1055 	mov	r3,a
      0004D5 08               [12] 1056 	inc	r0
      0004D6 86 04            [24] 1057 	mov	ar4,@r0
      0004D8 8A 82            [24] 1058 	mov	dpl,r2
      0004DA 8B 83            [24] 1059 	mov	dph,r3
      0004DC 8C F0            [24] 1060 	mov	b,r4
      0004DE EE               [12] 1061 	mov	a,r6
      0004DF 12 09 38         [24] 1062 	lcall	__gptrput
                                   1063 ;	firmware.c:183: for (byte_index = 0; byte_index < 5; ++byte_index) {
      0004E2 0D               [12] 1064 	inc	r5
      0004E3 BD 05 00         [24] 1065 	cjne	r5,#0x05,00162$
      0004E6                       1066 00162$:
      0004E6 50 03            [24] 1067 	jnc	00163$
      0004E8 02 04 59         [24] 1068 	ljmp	00115$
      0004EB                       1069 00163$:
                                   1070 ;	firmware.c:198: if ((uint8_t) (bytes[0] + bytes[1] + bytes[2] + bytes[3]) != bytes[4]) {
      0004EB A8 08            [24] 1071 	mov	r0,_bp
      0004ED 08               [12] 1072 	inc	r0
      0004EE 86 82            [24] 1073 	mov	dpl,@r0
      0004F0 08               [12] 1074 	inc	r0
      0004F1 86 83            [24] 1075 	mov	dph,@r0
      0004F3 08               [12] 1076 	inc	r0
      0004F4 86 F0            [24] 1077 	mov	b,@r0
      0004F6 12 09 F1         [24] 1078 	lcall	__gptrget
      0004F9 FC               [12] 1079 	mov	r4,a
      0004FA A8 08            [24] 1080 	mov	r0,_bp
      0004FC 08               [12] 1081 	inc	r0
      0004FD 74 01            [12] 1082 	mov	a,#0x01
      0004FF 26               [12] 1083 	add	a,@r0
      000500 FA               [12] 1084 	mov	r2,a
      000501 E4               [12] 1085 	clr	a
      000502 08               [12] 1086 	inc	r0
      000503 36               [12] 1087 	addc	a,@r0
      000504 FB               [12] 1088 	mov	r3,a
      000505 08               [12] 1089 	inc	r0
      000506 86 07            [24] 1090 	mov	ar7,@r0
      000508 8A 82            [24] 1091 	mov	dpl,r2
      00050A 8B 83            [24] 1092 	mov	dph,r3
      00050C 8F F0            [24] 1093 	mov	b,r7
      00050E 12 09 F1         [24] 1094 	lcall	__gptrget
      000511 FA               [12] 1095 	mov	r2,a
      000512 2C               [12] 1096 	add	a,r4
      000513 FC               [12] 1097 	mov	r4,a
      000514 A8 08            [24] 1098 	mov	r0,_bp
      000516 08               [12] 1099 	inc	r0
      000517 74 02            [12] 1100 	mov	a,#0x02
      000519 26               [12] 1101 	add	a,@r0
      00051A FD               [12] 1102 	mov	r5,a
      00051B E4               [12] 1103 	clr	a
      00051C 08               [12] 1104 	inc	r0
      00051D 36               [12] 1105 	addc	a,@r0
      00051E FE               [12] 1106 	mov	r6,a
      00051F 08               [12] 1107 	inc	r0
      000520 86 07            [24] 1108 	mov	ar7,@r0
      000522 8D 82            [24] 1109 	mov	dpl,r5
      000524 8E 83            [24] 1110 	mov	dph,r6
      000526 8F F0            [24] 1111 	mov	b,r7
      000528 12 09 F1         [24] 1112 	lcall	__gptrget
      00052B 2C               [12] 1113 	add	a,r4
      00052C FC               [12] 1114 	mov	r4,a
      00052D A8 08            [24] 1115 	mov	r0,_bp
      00052F 08               [12] 1116 	inc	r0
      000530 74 03            [12] 1117 	mov	a,#0x03
      000532 26               [12] 1118 	add	a,@r0
      000533 FD               [12] 1119 	mov	r5,a
      000534 E4               [12] 1120 	clr	a
      000535 08               [12] 1121 	inc	r0
      000536 36               [12] 1122 	addc	a,@r0
      000537 FE               [12] 1123 	mov	r6,a
      000538 08               [12] 1124 	inc	r0
      000539 86 07            [24] 1125 	mov	ar7,@r0
      00053B 8D 82            [24] 1126 	mov	dpl,r5
      00053D 8E 83            [24] 1127 	mov	dph,r6
      00053F 8F F0            [24] 1128 	mov	b,r7
      000541 12 09 F1         [24] 1129 	lcall	__gptrget
      000544 2C               [12] 1130 	add	a,r4
      000545 FC               [12] 1131 	mov	r4,a
      000546 A8 08            [24] 1132 	mov	r0,_bp
      000548 08               [12] 1133 	inc	r0
      000549 74 04            [12] 1134 	mov	a,#0x04
      00054B 26               [12] 1135 	add	a,@r0
      00054C FD               [12] 1136 	mov	r5,a
      00054D E4               [12] 1137 	clr	a
      00054E 08               [12] 1138 	inc	r0
      00054F 36               [12] 1139 	addc	a,@r0
      000550 FE               [12] 1140 	mov	r6,a
      000551 08               [12] 1141 	inc	r0
      000552 86 07            [24] 1142 	mov	ar7,@r0
      000554 8D 82            [24] 1143 	mov	dpl,r5
      000556 8E 83            [24] 1144 	mov	dph,r6
      000558 8F F0            [24] 1145 	mov	b,r7
      00055A 12 09 F1         [24] 1146 	lcall	__gptrget
      00055D FD               [12] 1147 	mov	r5,a
      00055E EC               [12] 1148 	mov	a,r4
      00055F B5 05 02         [24] 1149 	cjne	a,ar5,00164$
      000562 80 05            [24] 1150 	sjmp	00112$
      000564                       1151 00164$:
                                   1152 ;	firmware.c:199: return 3;
      000564 75 82 03         [24] 1153 	mov	dpl,#0x03
      000567 80 03            [24] 1154 	sjmp	00117$
      000569                       1155 00112$:
                                   1156 ;	firmware.c:201: return 0;
      000569 75 82 00         [24] 1157 	mov	dpl,#0x00
      00056C                       1158 00117$:
                                   1159 ;	firmware.c:202: }
      00056C 85 08 81         [24] 1160 	mov	sp,_bp
      00056F D0 08            [24] 1161 	pop	_bp
      000571 22               [24] 1162 	ret
                                   1163 ;------------------------------------------------------------
                                   1164 ;Allocation info for local variables in function 'publish_reading'
                                   1165 ;------------------------------------------------------------
                                   1166 ;sequence                  Allocated to stack - _bp -5
                                   1167 ;bytes                     Allocated to stack - _bp +1
                                   1168 ;temperature               Allocated to registers r4 r5 
                                   1169 ;humidity                  Allocated to stack - _bp +12
                                   1170 ;packed                    Allocated to registers 
                                   1171 ;sloc0                     Allocated to stack - _bp +4
                                   1172 ;sloc1                     Allocated to stack - _bp +8
                                   1173 ;------------------------------------------------------------
                                   1174 ;	firmware.c:204: static uint8_t publish_reading(const uint8_t bytes[5], uint32_t *sequence)
                                   1175 ;	-----------------------------------------
                                   1176 ;	 function publish_reading
                                   1177 ;	-----------------------------------------
      000572                       1178 _publish_reading:
      000572 C0 08            [24] 1179 	push	_bp
      000574 85 81 08         [24] 1180 	mov	_bp,sp
      000577 C0 82            [24] 1181 	push	dpl
      000579 C0 83            [24] 1182 	push	dph
      00057B C0 F0            [24] 1183 	push	b
      00057D E5 81            [12] 1184 	mov	a,sp
      00057F 24 0A            [12] 1185 	add	a,#0x0a
      000581 F5 81            [12] 1186 	mov	sp,a
                                   1187 ;	firmware.c:210: humidity = (uint16_t) bytes[0] * 100U + bytes[1];
      000583 A8 08            [24] 1188 	mov	r0,_bp
      000585 08               [12] 1189 	inc	r0
      000586 86 82            [24] 1190 	mov	dpl,@r0
      000588 08               [12] 1191 	inc	r0
      000589 86 83            [24] 1192 	mov	dph,@r0
      00058B 08               [12] 1193 	inc	r0
      00058C 86 F0            [24] 1194 	mov	b,@r0
      00058E 12 09 F1         [24] 1195 	lcall	__gptrget
      000591 FC               [12] 1196 	mov	r4,a
      000592 7B 00            [12] 1197 	mov	r3,#0x00
      000594 C0 04            [24] 1198 	push	ar4
      000596 C0 03            [24] 1199 	push	ar3
      000598 90 00 64         [24] 1200 	mov	dptr,#0x0064
      00059B 12 09 53         [24] 1201 	lcall	__mulint
      00059E AB 82            [24] 1202 	mov	r3,dpl
      0005A0 AC 83            [24] 1203 	mov	r4,dph
      0005A2 15 81            [12] 1204 	dec	sp
      0005A4 15 81            [12] 1205 	dec	sp
      0005A6 A8 08            [24] 1206 	mov	r0,_bp
      0005A8 08               [12] 1207 	inc	r0
      0005A9 74 01            [12] 1208 	mov	a,#0x01
      0005AB 26               [12] 1209 	add	a,@r0
      0005AC FA               [12] 1210 	mov	r2,a
      0005AD E4               [12] 1211 	clr	a
      0005AE 08               [12] 1212 	inc	r0
      0005AF 36               [12] 1213 	addc	a,@r0
      0005B0 FE               [12] 1214 	mov	r6,a
      0005B1 08               [12] 1215 	inc	r0
      0005B2 86 07            [24] 1216 	mov	ar7,@r0
      0005B4 8A 82            [24] 1217 	mov	dpl,r2
      0005B6 8E 83            [24] 1218 	mov	dph,r6
      0005B8 8F F0            [24] 1219 	mov	b,r7
      0005BA 12 09 F1         [24] 1220 	lcall	__gptrget
      0005BD 7F 00            [12] 1221 	mov	r7,#0x00
      0005BF 2B               [12] 1222 	add	a,r3
      0005C0 FB               [12] 1223 	mov	r3,a
      0005C1 EF               [12] 1224 	mov	a,r7
      0005C2 3C               [12] 1225 	addc	a,r4
      0005C3 FC               [12] 1226 	mov	r4,a
      0005C4 E5 08            [12] 1227 	mov	a,_bp
      0005C6 24 0C            [12] 1228 	add	a,#0x0c
      0005C8 F8               [12] 1229 	mov	r0,a
      0005C9 A6 03            [24] 1230 	mov	@r0,ar3
      0005CB 08               [12] 1231 	inc	r0
      0005CC A6 04            [24] 1232 	mov	@r0,ar4
                                   1233 ;	firmware.c:211: temperature = (int16_t) ((uint16_t) (bytes[2] & 0x7fU) * 100U + bytes[3]);
      0005CE A8 08            [24] 1234 	mov	r0,_bp
      0005D0 08               [12] 1235 	inc	r0
      0005D1 74 02            [12] 1236 	mov	a,#0x02
      0005D3 26               [12] 1237 	add	a,@r0
      0005D4 FB               [12] 1238 	mov	r3,a
      0005D5 E4               [12] 1239 	clr	a
      0005D6 08               [12] 1240 	inc	r0
      0005D7 36               [12] 1241 	addc	a,@r0
      0005D8 FC               [12] 1242 	mov	r4,a
      0005D9 08               [12] 1243 	inc	r0
      0005DA 86 05            [24] 1244 	mov	ar5,@r0
      0005DC 8B 82            [24] 1245 	mov	dpl,r3
      0005DE 8C 83            [24] 1246 	mov	dph,r4
      0005E0 8D F0            [24] 1247 	mov	b,r5
      0005E2 12 09 F1         [24] 1248 	lcall	__gptrget
      0005E5 FB               [12] 1249 	mov	r3,a
      0005E6 FC               [12] 1250 	mov	r4,a
      0005E7 53 04 7F         [24] 1251 	anl	ar4,#0x7f
      0005EA 7D 00            [12] 1252 	mov	r5,#0x00
      0005EC C0 03            [24] 1253 	push	ar3
      0005EE C0 04            [24] 1254 	push	ar4
      0005F0 C0 05            [24] 1255 	push	ar5
      0005F2 90 00 64         [24] 1256 	mov	dptr,#0x0064
      0005F5 12 09 53         [24] 1257 	lcall	__mulint
      0005F8 AC 82            [24] 1258 	mov	r4,dpl
      0005FA AD 83            [24] 1259 	mov	r5,dph
      0005FC 15 81            [12] 1260 	dec	sp
      0005FE 15 81            [12] 1261 	dec	sp
      000600 D0 03            [24] 1262 	pop	ar3
      000602 A8 08            [24] 1263 	mov	r0,_bp
      000604 08               [12] 1264 	inc	r0
      000605 74 03            [12] 1265 	mov	a,#0x03
      000607 26               [12] 1266 	add	a,@r0
      000608 FA               [12] 1267 	mov	r2,a
      000609 E4               [12] 1268 	clr	a
      00060A 08               [12] 1269 	inc	r0
      00060B 36               [12] 1270 	addc	a,@r0
      00060C FE               [12] 1271 	mov	r6,a
      00060D 08               [12] 1272 	inc	r0
      00060E 86 07            [24] 1273 	mov	ar7,@r0
      000610 8A 82            [24] 1274 	mov	dpl,r2
      000612 8E 83            [24] 1275 	mov	dph,r6
      000614 8F F0            [24] 1276 	mov	b,r7
      000616 12 09 F1         [24] 1277 	lcall	__gptrget
      000619 FA               [12] 1278 	mov	r2,a
      00061A 7F 00            [12] 1279 	mov	r7,#0x00
      00061C 2C               [12] 1280 	add	a,r4
      00061D FC               [12] 1281 	mov	r4,a
      00061E EF               [12] 1282 	mov	a,r7
      00061F 3D               [12] 1283 	addc	a,r5
      000620 FD               [12] 1284 	mov	r5,a
                                   1285 ;	firmware.c:212: if ((bytes[2] & 0x80U) != 0U) {
      000621 EB               [12] 1286 	mov	a,r3
      000622 30 E7 07         [24] 1287 	jnb	acc.7,00102$
                                   1288 ;	firmware.c:213: temperature = -temperature;
      000625 C3               [12] 1289 	clr	c
      000626 E4               [12] 1290 	clr	a
      000627 9C               [12] 1291 	subb	a,r4
      000628 FC               [12] 1292 	mov	r4,a
      000629 E4               [12] 1293 	clr	a
      00062A 9D               [12] 1294 	subb	a,r5
      00062B FD               [12] 1295 	mov	r5,a
      00062C                       1296 00102$:
                                   1297 ;	firmware.c:215: if (humidity > 10000U || temperature < -4000 || temperature > 8000) {
      00062C E5 08            [12] 1298 	mov	a,_bp
      00062E 24 0C            [12] 1299 	add	a,#0x0c
      000630 F8               [12] 1300 	mov	r0,a
      000631 C3               [12] 1301 	clr	c
      000632 74 10            [12] 1302 	mov	a,#0x10
      000634 96               [12] 1303 	subb	a,@r0
      000635 74 27            [12] 1304 	mov	a,#0x27
      000637 08               [12] 1305 	inc	r0
      000638 96               [12] 1306 	subb	a,@r0
      000639 40 18            [24] 1307 	jc	00103$
      00063B EC               [12] 1308 	mov	a,r4
      00063C 94 60            [12] 1309 	subb	a,#0x60
      00063E ED               [12] 1310 	mov	a,r5
      00063F 64 80            [12] 1311 	xrl	a,#0x80
      000641 94 70            [12] 1312 	subb	a,#0x70
      000643 40 0E            [24] 1313 	jc	00103$
      000645 74 40            [12] 1314 	mov	a,#0x40
      000647 9C               [12] 1315 	subb	a,r4
      000648 74 9F            [12] 1316 	mov	a,#(0x1f ^ 0x80)
      00064A 8D F0            [24] 1317 	mov	b,r5
      00064C 63 F0 80         [24] 1318 	xrl	b,#0x80
      00064F 95 F0            [12] 1319 	subb	a,b
      000651 50 06            [24] 1320 	jnc	00104$
      000653                       1321 00103$:
                                   1322 ;	firmware.c:216: return 0;
      000653 75 82 00         [24] 1323 	mov	dpl,#0x00
      000656 02 07 C8         [24] 1324 	ljmp	00109$
      000659                       1325 00104$:
                                   1326 ;	firmware.c:219: packed = ((uint32_t) humidity << 16) | (uint16_t) temperature;
      000659 E5 08            [12] 1327 	mov	a,_bp
      00065B 24 0C            [12] 1328 	add	a,#0x0c
      00065D F8               [12] 1329 	mov	r0,a
      00065E 86 02            [24] 1330 	mov	ar2,@r0
      000660 08               [12] 1331 	inc	r0
      000661 86 03            [24] 1332 	mov	ar3,@r0
      000663 E4               [12] 1333 	clr	a
      000664 E5 08            [12] 1334 	mov	a,_bp
      000666 24 04            [12] 1335 	add	a,#0x04
      000668 F8               [12] 1336 	mov	r0,a
      000669 08               [12] 1337 	inc	r0
      00066A 08               [12] 1338 	inc	r0
      00066B 08               [12] 1339 	inc	r0
      00066C A6 03            [24] 1340 	mov	@r0,ar3
      00066E 18               [12] 1341 	dec	r0
      00066F A6 02            [24] 1342 	mov	@r0,ar2
      000671 18               [12] 1343 	dec	r0
      000672 18               [12] 1344 	dec	r0
      000673 76 00            [12] 1345 	mov	@r0,#0x00
      000675 08               [12] 1346 	inc	r0
      000676 E4               [12] 1347 	clr	a
      000677 F6               [12] 1348 	mov	@r0,a
      000678 FE               [12] 1349 	mov	r6,a
      000679 FF               [12] 1350 	mov	r7,a
      00067A E5 08            [12] 1351 	mov	a,_bp
      00067C 24 04            [12] 1352 	add	a,#0x04
      00067E F8               [12] 1353 	mov	r0,a
      00067F E6               [12] 1354 	mov	a,@r0
      000680 42 04            [12] 1355 	orl	ar4,a
      000682 08               [12] 1356 	inc	r0
      000683 E6               [12] 1357 	mov	a,@r0
      000684 42 05            [12] 1358 	orl	ar5,a
      000686 08               [12] 1359 	inc	r0
      000687 E6               [12] 1360 	mov	a,@r0
      000688 42 06            [12] 1361 	orl	ar6,a
      00068A 08               [12] 1362 	inc	r0
      00068B E6               [12] 1363 	mov	a,@r0
      00068C 42 07            [12] 1364 	orl	ar7,a
                                   1365 ;	firmware.c:220: robot_write(RTC_INFO2, packed);
      00068E C0 04            [24] 1366 	push	ar4
      000690 C0 05            [24] 1367 	push	ar5
      000692 C0 06            [24] 1368 	push	ar6
      000694 C0 07            [24] 1369 	push	ar7
      000696 90 60 24         [24] 1370 	mov	dptr,#0x6024
      000699 75 F0 02         [24] 1371 	mov	b,#0x02
      00069C 74 05            [12] 1372 	mov	a,#0x05
      00069E 12 01 24         [24] 1373 	lcall	_robot_write
      0006A1 E5 81            [12] 1374 	mov	a,sp
      0006A3 24 FC            [12] 1375 	add	a,#0xfc
      0006A5 F5 81            [12] 1376 	mov	sp,a
                                   1377 ;	firmware.c:221: ++*sequence;
      0006A7 E5 08            [12] 1378 	mov	a,_bp
      0006A9 24 FB            [12] 1379 	add	a,#0xfb
      0006AB F8               [12] 1380 	mov	r0,a
      0006AC E5 08            [12] 1381 	mov	a,_bp
      0006AE 24 04            [12] 1382 	add	a,#0x04
      0006B0 F9               [12] 1383 	mov	r1,a
      0006B1 E6               [12] 1384 	mov	a,@r0
      0006B2 F7               [12] 1385 	mov	@r1,a
      0006B3 08               [12] 1386 	inc	r0
      0006B4 E6               [12] 1387 	mov	a,@r0
      0006B5 09               [12] 1388 	inc	r1
      0006B6 F7               [12] 1389 	mov	@r1,a
      0006B7 08               [12] 1390 	inc	r0
      0006B8 E6               [12] 1391 	mov	a,@r0
      0006B9 09               [12] 1392 	inc	r1
      0006BA F7               [12] 1393 	mov	@r1,a
      0006BB E5 08            [12] 1394 	mov	a,_bp
      0006BD 24 04            [12] 1395 	add	a,#0x04
      0006BF F8               [12] 1396 	mov	r0,a
      0006C0 86 82            [24] 1397 	mov	dpl,@r0
      0006C2 08               [12] 1398 	inc	r0
      0006C3 86 83            [24] 1399 	mov	dph,@r0
      0006C5 08               [12] 1400 	inc	r0
      0006C6 86 F0            [24] 1401 	mov	b,@r0
      0006C8 12 09 F1         [24] 1402 	lcall	__gptrget
      0006CB FA               [12] 1403 	mov	r2,a
      0006CC A3               [24] 1404 	inc	dptr
      0006CD 12 09 F1         [24] 1405 	lcall	__gptrget
      0006D0 FB               [12] 1406 	mov	r3,a
      0006D1 A3               [24] 1407 	inc	dptr
      0006D2 12 09 F1         [24] 1408 	lcall	__gptrget
      0006D5 FC               [12] 1409 	mov	r4,a
      0006D6 A3               [24] 1410 	inc	dptr
      0006D7 12 09 F1         [24] 1411 	lcall	__gptrget
      0006DA FF               [12] 1412 	mov	r7,a
      0006DB 0A               [12] 1413 	inc	r2
      0006DC BA 00 09         [24] 1414 	cjne	r2,#0x00,00131$
      0006DF 0B               [12] 1415 	inc	r3
      0006E0 BB 00 05         [24] 1416 	cjne	r3,#0x00,00131$
      0006E3 0C               [12] 1417 	inc	r4
      0006E4 BC 00 01         [24] 1418 	cjne	r4,#0x00,00131$
      0006E7 0F               [12] 1419 	inc	r7
      0006E8                       1420 00131$:
      0006E8 E5 08            [12] 1421 	mov	a,_bp
      0006EA 24 04            [12] 1422 	add	a,#0x04
      0006EC F8               [12] 1423 	mov	r0,a
      0006ED 86 82            [24] 1424 	mov	dpl,@r0
      0006EF 08               [12] 1425 	inc	r0
      0006F0 86 83            [24] 1426 	mov	dph,@r0
      0006F2 08               [12] 1427 	inc	r0
      0006F3 86 F0            [24] 1428 	mov	b,@r0
      0006F5 EA               [12] 1429 	mov	a,r2
      0006F6 12 09 38         [24] 1430 	lcall	__gptrput
      0006F9 A3               [24] 1431 	inc	dptr
      0006FA EB               [12] 1432 	mov	a,r3
      0006FB 12 09 38         [24] 1433 	lcall	__gptrput
      0006FE A3               [24] 1434 	inc	dptr
      0006FF EC               [12] 1435 	mov	a,r4
      000700 12 09 38         [24] 1436 	lcall	__gptrput
      000703 A3               [24] 1437 	inc	dptr
      000704 EF               [12] 1438 	mov	a,r7
      000705 12 09 38         [24] 1439 	lcall	__gptrput
                                   1440 ;	firmware.c:222: if (*sequence == 0UL) {
      000708 E5 08            [12] 1441 	mov	a,_bp
      00070A 24 04            [12] 1442 	add	a,#0x04
      00070C F8               [12] 1443 	mov	r0,a
      00070D 86 82            [24] 1444 	mov	dpl,@r0
      00070F 08               [12] 1445 	inc	r0
      000710 86 83            [24] 1446 	mov	dph,@r0
      000712 08               [12] 1447 	inc	r0
      000713 86 F0            [24] 1448 	mov	b,@r0
      000715 E5 08            [12] 1449 	mov	a,_bp
      000717 24 08            [12] 1450 	add	a,#0x08
      000719 F9               [12] 1451 	mov	r1,a
      00071A 12 09 F1         [24] 1452 	lcall	__gptrget
      00071D F7               [12] 1453 	mov	@r1,a
      00071E A3               [24] 1454 	inc	dptr
      00071F 12 09 F1         [24] 1455 	lcall	__gptrget
      000722 09               [12] 1456 	inc	r1
      000723 F7               [12] 1457 	mov	@r1,a
      000724 A3               [24] 1458 	inc	dptr
      000725 12 09 F1         [24] 1459 	lcall	__gptrget
      000728 09               [12] 1460 	inc	r1
      000729 F7               [12] 1461 	mov	@r1,a
      00072A A3               [24] 1462 	inc	dptr
      00072B 12 09 F1         [24] 1463 	lcall	__gptrget
      00072E 09               [12] 1464 	inc	r1
      00072F F7               [12] 1465 	mov	@r1,a
      000730 EA               [12] 1466 	mov	a,r2
      000731 4B               [12] 1467 	orl	a,r3
      000732 4C               [12] 1468 	orl	a,r4
      000733 4F               [12] 1469 	orl	a,r7
      000734 70 35            [24] 1470 	jnz	00108$
                                   1471 ;	firmware.c:223: ++*sequence;
      000736 E5 08            [12] 1472 	mov	a,_bp
      000738 24 08            [12] 1473 	add	a,#0x08
      00073A F8               [12] 1474 	mov	r0,a
      00073B 74 01            [12] 1475 	mov	a,#0x01
      00073D 26               [12] 1476 	add	a,@r0
      00073E FD               [12] 1477 	mov	r5,a
      00073F E4               [12] 1478 	clr	a
      000740 08               [12] 1479 	inc	r0
      000741 36               [12] 1480 	addc	a,@r0
      000742 FE               [12] 1481 	mov	r6,a
      000743 E4               [12] 1482 	clr	a
      000744 08               [12] 1483 	inc	r0
      000745 36               [12] 1484 	addc	a,@r0
      000746 FC               [12] 1485 	mov	r4,a
      000747 E4               [12] 1486 	clr	a
      000748 08               [12] 1487 	inc	r0
      000749 36               [12] 1488 	addc	a,@r0
      00074A FF               [12] 1489 	mov	r7,a
      00074B E5 08            [12] 1490 	mov	a,_bp
      00074D 24 04            [12] 1491 	add	a,#0x04
      00074F F8               [12] 1492 	mov	r0,a
      000750 86 82            [24] 1493 	mov	dpl,@r0
      000752 08               [12] 1494 	inc	r0
      000753 86 83            [24] 1495 	mov	dph,@r0
      000755 08               [12] 1496 	inc	r0
      000756 86 F0            [24] 1497 	mov	b,@r0
      000758 ED               [12] 1498 	mov	a,r5
      000759 12 09 38         [24] 1499 	lcall	__gptrput
      00075C A3               [24] 1500 	inc	dptr
      00075D EE               [12] 1501 	mov	a,r6
      00075E 12 09 38         [24] 1502 	lcall	__gptrput
      000761 A3               [24] 1503 	inc	dptr
      000762 EC               [12] 1504 	mov	a,r4
      000763 12 09 38         [24] 1505 	lcall	__gptrput
      000766 A3               [24] 1506 	inc	dptr
      000767 EF               [12] 1507 	mov	a,r7
      000768 12 09 38         [24] 1508 	lcall	__gptrput
      00076B                       1509 00108$:
                                   1510 ;	firmware.c:225: robot_write(RTC_INFO3, *sequence);
      00076B E5 08            [12] 1511 	mov	a,_bp
      00076D 24 04            [12] 1512 	add	a,#0x04
      00076F F8               [12] 1513 	mov	r0,a
      000770 86 82            [24] 1514 	mov	dpl,@r0
      000772 08               [12] 1515 	inc	r0
      000773 86 83            [24] 1516 	mov	dph,@r0
      000775 08               [12] 1517 	inc	r0
      000776 86 F0            [24] 1518 	mov	b,@r0
      000778 12 09 F1         [24] 1519 	lcall	__gptrget
      00077B FC               [12] 1520 	mov	r4,a
      00077C A3               [24] 1521 	inc	dptr
      00077D 12 09 F1         [24] 1522 	lcall	__gptrget
      000780 FD               [12] 1523 	mov	r5,a
      000781 A3               [24] 1524 	inc	dptr
      000782 12 09 F1         [24] 1525 	lcall	__gptrget
      000785 FE               [12] 1526 	mov	r6,a
      000786 A3               [24] 1527 	inc	dptr
      000787 12 09 F1         [24] 1528 	lcall	__gptrget
      00078A FF               [12] 1529 	mov	r7,a
      00078B C0 04            [24] 1530 	push	ar4
      00078D C0 05            [24] 1531 	push	ar5
      00078F C0 06            [24] 1532 	push	ar6
      000791 C0 07            [24] 1533 	push	ar7
      000793 90 60 28         [24] 1534 	mov	dptr,#0x6028
      000796 75 F0 02         [24] 1535 	mov	b,#0x02
      000799 74 05            [12] 1536 	mov	a,#0x05
      00079B 12 01 24         [24] 1537 	lcall	_robot_write
      00079E E5 81            [12] 1538 	mov	a,sp
      0007A0 24 FC            [12] 1539 	add	a,#0xfc
      0007A2 F5 81            [12] 1540 	mov	sp,a
                                   1541 ;	firmware.c:226: robot_write(RTC_INFO0, STATUS_RUNNING);
      0007A4 74 4B            [12] 1542 	mov	a,#0x4b
      0007A6 C0 E0            [24] 1543 	push	acc
      0007A8 74 4E            [12] 1544 	mov	a,#0x4e
      0007AA C0 E0            [24] 1545 	push	acc
      0007AC 74 4C            [12] 1546 	mov	a,#0x4c
      0007AE C0 E0            [24] 1547 	push	acc
      0007B0 74 42            [12] 1548 	mov	a,#0x42
      0007B2 C0 E0            [24] 1549 	push	acc
      0007B4 90 60 1C         [24] 1550 	mov	dptr,#0x601c
      0007B7 75 F0 02         [24] 1551 	mov	b,#0x02
      0007BA 74 05            [12] 1552 	mov	a,#0x05
      0007BC 12 01 24         [24] 1553 	lcall	_robot_write
      0007BF E5 81            [12] 1554 	mov	a,sp
      0007C1 24 FC            [12] 1555 	add	a,#0xfc
      0007C3 F5 81            [12] 1556 	mov	sp,a
                                   1557 ;	firmware.c:227: return 1;
      0007C5 75 82 01         [24] 1558 	mov	dpl,#0x01
      0007C8                       1559 00109$:
                                   1560 ;	firmware.c:228: }
      0007C8 85 08 81         [24] 1561 	mov	sp,_bp
      0007CB D0 08            [24] 1562 	pop	_bp
      0007CD 22               [24] 1563 	ret
                                   1564 ;------------------------------------------------------------
                                   1565 ;Allocation info for local variables in function 'main'
                                   1566 ;------------------------------------------------------------
                                   1567 ;bytes                     Allocated to stack - _bp +1
                                   1568 ;result                    Allocated to registers r5 
                                   1569 ;led_on                    Allocated to registers r7 
                                   1570 ;sequence                  Allocated to stack - _bp +6
                                   1571 ;------------------------------------------------------------
                                   1572 ;	firmware.c:230: void main(void)
                                   1573 ;	-----------------------------------------
                                   1574 ;	 function main
                                   1575 ;	-----------------------------------------
      0007CE                       1576 _main:
      0007CE C0 08            [24] 1577 	push	_bp
      0007D0 E5 81            [12] 1578 	mov	a,sp
      0007D2 F5 08            [12] 1579 	mov	_bp,a
      0007D4 24 09            [12] 1580 	add	a,#0x09
      0007D6 F5 81            [12] 1581 	mov	sp,a
                                   1582 ;	firmware.c:234: uint8_t led_on = 0;
      0007D8 7F 00            [12] 1583 	mov	r7,#0x00
                                   1584 ;	firmware.c:235: uint32_t sequence = 0;
      0007DA E5 08            [12] 1585 	mov	a,_bp
      0007DC 24 06            [12] 1586 	add	a,#0x06
      0007DE F8               [12] 1587 	mov	r0,a
      0007DF E4               [12] 1588 	clr	a
      0007E0 F6               [12] 1589 	mov	@r0,a
      0007E1 08               [12] 1590 	inc	r0
      0007E2 F6               [12] 1591 	mov	@r0,a
      0007E3 08               [12] 1592 	inc	r0
      0007E4 F6               [12] 1593 	mov	@r0,a
      0007E5 08               [12] 1594 	inc	r0
      0007E6 F6               [12] 1595 	mov	@r0,a
                                   1596 ;	firmware.c:237: gpio_write(LED_GPIO_PIN, 0);
      0007E7 C0 07            [24] 1597 	push	ar7
      0007E9 C0 E0            [24] 1598 	push	acc
      0007EB 75 82 0D         [24] 1599 	mov	dpl,#0x0d
      0007EE 12 01 76         [24] 1600 	lcall	_gpio_write
      0007F1 15 81            [12] 1601 	dec	sp
                                   1602 ;	firmware.c:238: gpio_output(LED_GPIO_PIN);
      0007F3 75 82 0D         [24] 1603 	mov	dpl,#0x0d
      0007F6 12 02 4F         [24] 1604 	lcall	_gpio_output
                                   1605 ;	firmware.c:239: gpio_input(DHT_GPIO_PIN);
      0007F9 75 82 1A         [24] 1606 	mov	dpl,#0x1a
      0007FC 12 02 CD         [24] 1607 	lcall	_gpio_input
                                   1608 ;	firmware.c:240: robot_write(RTC_INFO0, STATUS_RUNNING);
      0007FF 74 4B            [12] 1609 	mov	a,#0x4b
      000801 C0 E0            [24] 1610 	push	acc
      000803 74 4E            [12] 1611 	mov	a,#0x4e
      000805 C0 E0            [24] 1612 	push	acc
      000807 74 4C            [12] 1613 	mov	a,#0x4c
      000809 C0 E0            [24] 1614 	push	acc
      00080B 74 42            [12] 1615 	mov	a,#0x42
      00080D C0 E0            [24] 1616 	push	acc
      00080F 90 60 1C         [24] 1617 	mov	dptr,#0x601c
      000812 75 F0 02         [24] 1618 	mov	b,#0x02
      000815 74 05            [12] 1619 	mov	a,#0x05
      000817 12 01 24         [24] 1620 	lcall	_robot_write
      00081A E5 81            [12] 1621 	mov	a,sp
      00081C 24 FC            [12] 1622 	add	a,#0xfc
      00081E F5 81            [12] 1623 	mov	sp,a
      000820 D0 07            [24] 1624 	pop	ar7
      000822                       1625 00113$:
                                   1626 ;	firmware.c:243: gpio_write(LED_GPIO_PIN, led_on);
      000822 C0 07            [24] 1627 	push	ar7
      000824 C0 07            [24] 1628 	push	ar7
      000826 75 82 0D         [24] 1629 	mov	dpl,#0x0d
      000829 12 01 76         [24] 1630 	lcall	_gpio_write
      00082C 15 81            [12] 1631 	dec	sp
      00082E D0 07            [24] 1632 	pop	ar7
                                   1633 ;	firmware.c:244: led_on = (uint8_t) !led_on;
      000830 EF               [12] 1634 	mov	a,r7
      000831 B4 01 00         [24] 1635 	cjne	a,#0x01,00137$
      000834                       1636 00137$:
      000834 92 00            [24] 1637 	mov  b0,c
      000836 E4               [12] 1638 	clr	a
      000837 33               [12] 1639 	rlc	a
      000838 FF               [12] 1640 	mov	r7,a
                                   1641 ;	firmware.c:245: result = dht11_read(bytes);
      000839 AE 08            [24] 1642 	mov	r6,_bp
      00083B 0E               [12] 1643 	inc	r6
      00083C 8E 03            [24] 1644 	mov	ar3,r6
      00083E 7C 00            [12] 1645 	mov	r4,#0x00
      000840 7D 40            [12] 1646 	mov	r5,#0x40
      000842 8B 82            [24] 1647 	mov	dpl,r3
      000844 8C 83            [24] 1648 	mov	dph,r4
      000846 8D F0            [24] 1649 	mov	b,r5
      000848 C0 07            [24] 1650 	push	ar7
      00084A C0 06            [24] 1651 	push	ar6
      00084C 12 04 05         [24] 1652 	lcall	_dht11_read
      00084F AD 82            [24] 1653 	mov	r5,dpl
      000851 D0 06            [24] 1654 	pop	ar6
      000853 D0 07            [24] 1655 	pop	ar7
                                   1656 ;	firmware.c:246: if (result == 1U) {
      000855 BD 01 27         [24] 1657 	cjne	r5,#0x01,00110$
                                   1658 ;	firmware.c:247: robot_write(RTC_INFO0, STATUS_NO_RESPONSE);
      000858 C0 07            [24] 1659 	push	ar7
      00085A 74 31            [12] 1660 	mov	a,#0x31
      00085C C0 E0            [24] 1661 	push	acc
      00085E 14               [12] 1662 	dec	a
      00085F C0 E0            [24] 1663 	push	acc
      000861 74 52            [12] 1664 	mov	a,#0x52
      000863 C0 E0            [24] 1665 	push	acc
      000865 74 45            [12] 1666 	mov	a,#0x45
      000867 C0 E0            [24] 1667 	push	acc
      000869 90 60 1C         [24] 1668 	mov	dptr,#0x601c
      00086C 75 F0 02         [24] 1669 	mov	b,#0x02
      00086F 74 05            [12] 1670 	mov	a,#0x05
      000871 12 01 24         [24] 1671 	lcall	_robot_write
      000874 E5 81            [12] 1672 	mov	a,sp
      000876 24 FC            [12] 1673 	add	a,#0xfc
      000878 F5 81            [12] 1674 	mov	sp,a
      00087A D0 07            [24] 1675 	pop	ar7
      00087C 02 09 25         [24] 1676 	ljmp	00111$
      00087F                       1677 00110$:
                                   1678 ;	firmware.c:248: } else if (result == 2U) {
      00087F BD 02 27         [24] 1679 	cjne	r5,#0x02,00107$
                                   1680 ;	firmware.c:249: robot_write(RTC_INFO0, STATUS_TIMING);
      000882 C0 07            [24] 1681 	push	ar7
      000884 74 32            [12] 1682 	mov	a,#0x32
      000886 C0 E0            [24] 1683 	push	acc
      000888 74 30            [12] 1684 	mov	a,#0x30
      00088A C0 E0            [24] 1685 	push	acc
      00088C 74 52            [12] 1686 	mov	a,#0x52
      00088E C0 E0            [24] 1687 	push	acc
      000890 74 45            [12] 1688 	mov	a,#0x45
      000892 C0 E0            [24] 1689 	push	acc
      000894 90 60 1C         [24] 1690 	mov	dptr,#0x601c
      000897 75 F0 02         [24] 1691 	mov	b,#0x02
      00089A 74 05            [12] 1692 	mov	a,#0x05
      00089C 12 01 24         [24] 1693 	lcall	_robot_write
      00089F E5 81            [12] 1694 	mov	a,sp
      0008A1 24 FC            [12] 1695 	add	a,#0xfc
      0008A3 F5 81            [12] 1696 	mov	sp,a
      0008A5 D0 07            [24] 1697 	pop	ar7
      0008A7 80 7C            [24] 1698 	sjmp	00111$
      0008A9                       1699 00107$:
                                   1700 ;	firmware.c:250: } else if (result == 3U) {
      0008A9 BD 03 27         [24] 1701 	cjne	r5,#0x03,00104$
                                   1702 ;	firmware.c:251: robot_write(RTC_INFO0, STATUS_CHECKSUM);
      0008AC C0 07            [24] 1703 	push	ar7
      0008AE 74 33            [12] 1704 	mov	a,#0x33
      0008B0 C0 E0            [24] 1705 	push	acc
      0008B2 74 30            [12] 1706 	mov	a,#0x30
      0008B4 C0 E0            [24] 1707 	push	acc
      0008B6 74 52            [12] 1708 	mov	a,#0x52
      0008B8 C0 E0            [24] 1709 	push	acc
      0008BA 74 45            [12] 1710 	mov	a,#0x45
      0008BC C0 E0            [24] 1711 	push	acc
      0008BE 90 60 1C         [24] 1712 	mov	dptr,#0x601c
      0008C1 75 F0 02         [24] 1713 	mov	b,#0x02
      0008C4 74 05            [12] 1714 	mov	a,#0x05
      0008C6 12 01 24         [24] 1715 	lcall	_robot_write
      0008C9 E5 81            [12] 1716 	mov	a,sp
      0008CB 24 FC            [12] 1717 	add	a,#0xfc
      0008CD F5 81            [12] 1718 	mov	sp,a
      0008CF D0 07            [24] 1719 	pop	ar7
      0008D1 80 52            [24] 1720 	sjmp	00111$
      0008D3                       1721 00104$:
                                   1722 ;	firmware.c:252: } else if (!publish_reading(bytes, &sequence)) {
      0008D3 C0 07            [24] 1723 	push	ar7
      0008D5 E5 08            [12] 1724 	mov	a,_bp
      0008D7 24 06            [12] 1725 	add	a,#0x06
      0008D9 FD               [12] 1726 	mov	r5,a
      0008DA 7C 00            [12] 1727 	mov	r4,#0x00
      0008DC 7B 40            [12] 1728 	mov	r3,#0x40
      0008DE 8E 02            [24] 1729 	mov	ar2,r6
      0008E0 7E 00            [12] 1730 	mov	r6,#0x00
      0008E2 7F 40            [12] 1731 	mov	r7,#0x40
      0008E4 C0 05            [24] 1732 	push	ar5
      0008E6 C0 04            [24] 1733 	push	ar4
      0008E8 C0 03            [24] 1734 	push	ar3
      0008EA 8A 82            [24] 1735 	mov	dpl,r2
      0008EC 8E 83            [24] 1736 	mov	dph,r6
      0008EE 8F F0            [24] 1737 	mov	b,r7
      0008F0 12 05 72         [24] 1738 	lcall	_publish_reading
      0008F3 AF 82            [24] 1739 	mov	r7,dpl
      0008F5 15 81            [12] 1740 	dec	sp
      0008F7 15 81            [12] 1741 	dec	sp
      0008F9 15 81            [12] 1742 	dec	sp
      0008FB EF               [12] 1743 	mov	a,r7
      0008FC D0 07            [24] 1744 	pop	ar7
      0008FE 70 25            [24] 1745 	jnz	00111$
                                   1746 ;	firmware.c:253: robot_write(RTC_INFO0, STATUS_RANGE);
      000900 C0 07            [24] 1747 	push	ar7
      000902 74 34            [12] 1748 	mov	a,#0x34
      000904 C0 E0            [24] 1749 	push	acc
      000906 74 30            [12] 1750 	mov	a,#0x30
      000908 C0 E0            [24] 1751 	push	acc
      00090A 74 52            [12] 1752 	mov	a,#0x52
      00090C C0 E0            [24] 1753 	push	acc
      00090E 74 45            [12] 1754 	mov	a,#0x45
      000910 C0 E0            [24] 1755 	push	acc
      000912 90 60 1C         [24] 1756 	mov	dptr,#0x601c
      000915 75 F0 02         [24] 1757 	mov	b,#0x02
      000918 74 05            [12] 1758 	mov	a,#0x05
      00091A 12 01 24         [24] 1759 	lcall	_robot_write
      00091D E5 81            [12] 1760 	mov	a,sp
      00091F 24 FC            [12] 1761 	add	a,#0xfc
      000921 F5 81            [12] 1762 	mov	sp,a
      000923 D0 07            [24] 1763 	pop	ar7
      000925                       1764 00111$:
                                   1765 ;	firmware.c:255: delay_ms(1000);
      000925 90 03 E8         [24] 1766 	mov	dptr,#0x03e8
      000928 C0 07            [24] 1767 	push	ar7
      00092A 12 03 BD         [24] 1768 	lcall	_delay_ms
      00092D D0 07            [24] 1769 	pop	ar7
      00092F 02 08 22         [24] 1770 	ljmp	00113$
                                   1771 ;	firmware.c:257: }
      000932 85 08 81         [24] 1772 	mov	sp,_bp
      000935 D0 08            [24] 1773 	pop	_bp
      000937 22               [24] 1774 	ret
                                   1775 	.area CSEG    (CODE)
                                   1776 	.area CONST   (CODE)
                                   1777 	.area XINIT   (CODE)
                                   1778 	.area CABS    (ABS,CODE)
