
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	d4010113          	addi	sp,sp,-704 # 80008d40 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	bb070713          	addi	a4,a4,-1104 # 80008c00 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	7ee78793          	addi	a5,a5,2030 # 80006850 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb5fd7>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	00e78793          	addi	a5,a5,14 # 800010ba <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	c56080e7          	jalr	-938(ra) # 80002d80 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	bbc50513          	addi	a0,a0,-1092 # 80010d40 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	c8e080e7          	jalr	-882(ra) # 80000e1a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	bac48493          	addi	s1,s1,-1108 # 80010d40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	c3c90913          	addi	s2,s2,-964 # 80010dd8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	adc080e7          	jalr	-1316(ra) # 80001c90 <myproc>
    800001bc:	00003097          	auipc	ra,0x3
    800001c0:	a0e080e7          	jalr	-1522(ra) # 80002bca <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	600080e7          	jalr	1536(ra) # 800027ca <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	b6270713          	addi	a4,a4,-1182 # 80010d40 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00003097          	auipc	ra,0x3
    80000214:	b1a080e7          	jalr	-1254(ra) # 80002d2a <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	b1850513          	addi	a0,a0,-1256 # 80010d40 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	c9e080e7          	jalr	-866(ra) # 80000ece <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	b0250513          	addi	a0,a0,-1278 # 80010d40 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	c88080e7          	jalr	-888(ra) # 80000ece <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	b6f72523          	sw	a5,-1174(a4) # 80010dd8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	a7850513          	addi	a0,a0,-1416 # 80010d40 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	b4a080e7          	jalr	-1206(ra) # 80000e1a <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00003097          	auipc	ra,0x3
    800002f2:	ae8080e7          	jalr	-1304(ra) # 80002dd6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	a4a50513          	addi	a0,a0,-1462 # 80010d40 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	bd0080e7          	jalr	-1072(ra) # 80000ece <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	a2670713          	addi	a4,a4,-1498 # 80010d40 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00011797          	auipc	a5,0x11
    80000348:	9fc78793          	addi	a5,a5,-1540 # 80010d40 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	a667a783          	lw	a5,-1434(a5) # 80010dd8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	9ba70713          	addi	a4,a4,-1606 # 80010d40 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	9aa48493          	addi	s1,s1,-1622 # 80010d40 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00011717          	auipc	a4,0x11
    800003d6:	96e70713          	addi	a4,a4,-1682 # 80010d40 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	9ef72c23          	sw	a5,-1544(a4) # 80010de0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00011797          	auipc	a5,0x11
    80000412:	93278793          	addi	a5,a5,-1742 # 80010d40 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	9ac7a523          	sw	a2,-1622(a5) # 80010ddc <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	99e50513          	addi	a0,a0,-1634 # 80010dd8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	538080e7          	jalr	1336(ra) # 8000297a <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00011517          	auipc	a0,0x11
    80000460:	8e450513          	addi	a0,a0,-1820 # 80010d40 <cons>
    80000464:	00001097          	auipc	ra,0x1
    80000468:	926080e7          	jalr	-1754(ra) # 80000d8a <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00247797          	auipc	a5,0x247
    80000478:	21c78793          	addi	a5,a5,540 # 80247690 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00011797          	auipc	a5,0x11
    8000054c:	8a07ac23          	sw	zero,-1864(a5) # 80010e00 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	f7650513          	addi	a0,a0,-138 # 800084e0 <states.0+0x178>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	64f72223          	sw	a5,1604(a4) # 80008bc0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00011d97          	auipc	s11,0x11
    800005bc:	848dad83          	lw	s11,-1976(s11) # 80010e00 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	7f250513          	addi	a0,a0,2034 # 80010de8 <pr>
    800005fe:	00001097          	auipc	ra,0x1
    80000602:	81c080e7          	jalr	-2020(ra) # 80000e1a <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	69450513          	addi	a0,a0,1684 # 80010de8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	772080e7          	jalr	1906(ra) # 80000ece <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	67848493          	addi	s1,s1,1656 # 80010de8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	608080e7          	jalr	1544(ra) # 80000d8a <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	63850513          	addi	a0,a0,1592 # 80010e08 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	5b2080e7          	jalr	1458(ra) # 80000d8a <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	5da080e7          	jalr	1498(ra) # 80000dce <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	3c47a783          	lw	a5,964(a5) # 80008bc0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	64c080e7          	jalr	1612(ra) # 80000e6e <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	3947b783          	ld	a5,916(a5) # 80008bc8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	39473703          	ld	a4,916(a4) # 80008bd0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	5aaa0a13          	addi	s4,s4,1450 # 80010e08 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	36248493          	addi	s1,s1,866 # 80008bc8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	36298993          	addi	s3,s3,866 # 80008bd0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	0ea080e7          	jalr	234(ra) # 8000297a <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	53c50513          	addi	a0,a0,1340 # 80010e08 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	546080e7          	jalr	1350(ra) # 80000e1a <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	2e47a783          	lw	a5,740(a5) # 80008bc0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	2ea73703          	ld	a4,746(a4) # 80008bd0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	2da7b783          	ld	a5,730(a5) # 80008bc8 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	50e98993          	addi	s3,s3,1294 # 80010e08 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	2c648493          	addi	s1,s1,710 # 80008bc8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	2c690913          	addi	s2,s2,710 # 80008bd0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	eb0080e7          	jalr	-336(ra) # 800027ca <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	4d848493          	addi	s1,s1,1240 # 80010e08 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	28e7b623          	sd	a4,652(a5) # 80008bd0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	578080e7          	jalr	1400(ra) # 80000ece <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	45248493          	addi	s1,s1,1106 # 80010e08 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	45a080e7          	jalr	1114(ra) # 80000e1a <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	4fc080e7          	jalr	1276(ra) # 80000ece <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	e7d5                	bnez	a5,80000aa0 <kfree+0xbc>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00248797          	auipc	a5,0x248
    800009fc:	e3078793          	addi	a5,a5,-464 # 80248828 <end>
    80000a00:	0af56063          	bltu	a0,a5,80000aa0 <kfree+0xbc>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	08f57c63          	bgeu	a0,a5,80000aa0 <kfree+0xbc>
  {
    panic("kfree");
  }

  acquire(&ref_count.lock);
    80000a0c:	00010517          	auipc	a0,0x10
    80000a10:	45450513          	addi	a0,a0,1108 # 80010e60 <ref_count>
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	406080e7          	jalr	1030(ra) # 80000e1a <acquire>
  if(ref_count.no_of_references[(uint64)pa >> 12] <= 0)
    80000a1c:	00c4d793          	srli	a5,s1,0xc
    80000a20:	00478693          	addi	a3,a5,4
    80000a24:	068a                	slli	a3,a3,0x2
    80000a26:	00010717          	auipc	a4,0x10
    80000a2a:	43a70713          	addi	a4,a4,1082 # 80010e60 <ref_count>
    80000a2e:	9736                	add	a4,a4,a3
    80000a30:	4718                	lw	a4,8(a4)
    80000a32:	06e05f63          	blez	a4,80000ab0 <kfree+0xcc>
  {
    panic("safe_decrement_references");
  }
  ref_count.no_of_references[(uint64)pa >> 12] -= 1;   // decrementing reference
    80000a36:	377d                	addiw	a4,a4,-1
    80000a38:	0007061b          	sext.w	a2,a4
    80000a3c:	0791                	addi	a5,a5,4
    80000a3e:	078a                	slli	a5,a5,0x2
    80000a40:	00010697          	auipc	a3,0x10
    80000a44:	42068693          	addi	a3,a3,1056 # 80010e60 <ref_count>
    80000a48:	97b6                	add	a5,a5,a3
    80000a4a:	c798                	sw	a4,8(a5)
  
  if(ref_count.no_of_references[(uint64)pa >> 12] > 0)
    80000a4c:	06c04a63          	bgtz	a2,80000ac0 <kfree+0xdc>
  {
    release(&ref_count.lock);
    return; // can't free the page address yet
  }
  release(&ref_count.lock);
    80000a50:	00010517          	auipc	a0,0x10
    80000a54:	41050513          	addi	a0,a0,1040 # 80010e60 <ref_count>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	476080e7          	jalr	1142(ra) # 80000ece <release>

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a60:	6605                	lui	a2,0x1
    80000a62:	4585                	li	a1,1
    80000a64:	8526                	mv	a0,s1
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	4b0080e7          	jalr	1200(ra) # 80000f16 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a6e:	00010917          	auipc	s2,0x10
    80000a72:	3d290913          	addi	s2,s2,978 # 80010e40 <kmem>
    80000a76:	854a                	mv	a0,s2
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	3a2080e7          	jalr	930(ra) # 80000e1a <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	442080e7          	jalr	1090(ra) # 80000ece <release>
}
    80000a94:	60e2                	ld	ra,24(sp)
    80000a96:	6442                	ld	s0,16(sp)
    80000a98:	64a2                	ld	s1,8(sp)
    80000a9a:	6902                	ld	s2,0(sp)
    80000a9c:	6105                	addi	sp,sp,32
    80000a9e:	8082                	ret
    panic("kfree");
    80000aa0:	00007517          	auipc	a0,0x7
    80000aa4:	5c050513          	addi	a0,a0,1472 # 80008060 <digits+0x20>
    80000aa8:	00000097          	auipc	ra,0x0
    80000aac:	a94080e7          	jalr	-1388(ra) # 8000053c <panic>
    panic("safe_decrement_references");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	5b850513          	addi	a0,a0,1464 # 80008068 <digits+0x28>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	a84080e7          	jalr	-1404(ra) # 8000053c <panic>
    release(&ref_count.lock);
    80000ac0:	8536                	mv	a0,a3
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	40c080e7          	jalr	1036(ra) # 80000ece <release>
    return; // can't free the page address yet
    80000aca:	b7e9                	j	80000a94 <kfree+0xb0>

0000000080000acc <refcountinit>:
  }  
  return (void*)r;
}

void refcountinit()
{
    80000acc:	1141                	addi	sp,sp,-16
    80000ace:	e406                	sd	ra,8(sp)
    80000ad0:	e022                	sd	s0,0(sp)
    80000ad2:	0800                	addi	s0,sp,16
  initlock(&ref_count.lock,"ref_count");
    80000ad4:	00007597          	auipc	a1,0x7
    80000ad8:	5b458593          	addi	a1,a1,1460 # 80008088 <digits+0x48>
    80000adc:	00010517          	auipc	a0,0x10
    80000ae0:	38450513          	addi	a0,a0,900 # 80010e60 <ref_count>
    80000ae4:	00000097          	auipc	ra,0x0
    80000ae8:	2a6080e7          	jalr	678(ra) # 80000d8a <initlock>
  acquire(&kmem.lock);            // reason we need to memset is to ensure no other concurrent child process can modify this at the same time, very important
    80000aec:	00010517          	auipc	a0,0x10
    80000af0:	35450513          	addi	a0,a0,852 # 80010e40 <kmem>
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	326080e7          	jalr	806(ra) # 80000e1a <acquire>
  // memset(ref_count.no_of_references,0,sizeof(int));
  for(int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12);i++)
    80000afc:	00010797          	auipc	a5,0x10
    80000b00:	37c78793          	addi	a5,a5,892 # 80010e78 <ref_count+0x18>
    80000b04:	00230717          	auipc	a4,0x230
    80000b08:	37470713          	addi	a4,a4,884 # 80230e78 <pid_lock>
  {
    ref_count.no_of_references[i] = 0;
    80000b0c:	0007a023          	sw	zero,0(a5)
  for(int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12);i++)
    80000b10:	0791                	addi	a5,a5,4
    80000b12:	fee79de3          	bne	a5,a4,80000b0c <refcountinit+0x40>
  }      
  release(&kmem.lock);
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	32a50513          	addi	a0,a0,810 # 80010e40 <kmem>
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	3b0080e7          	jalr	944(ra) # 80000ece <release>
}
    80000b26:	60a2                	ld	ra,8(sp)
    80000b28:	6402                	ld	s0,0(sp)
    80000b2a:	0141                	addi	sp,sp,16
    80000b2c:	8082                	ret

0000000080000b2e <safe_increment_references>:

void safe_increment_references(void* pa)
{
    80000b2e:	1101                	addi	sp,sp,-32
    80000b30:	ec06                	sd	ra,24(sp)
    80000b32:	e822                	sd	s0,16(sp)
    80000b34:	e426                	sd	s1,8(sp)
    80000b36:	1000                	addi	s0,sp,32
    80000b38:	84aa                	mv	s1,a0
  acquire(&ref_count.lock);
    80000b3a:	00010517          	auipc	a0,0x10
    80000b3e:	32650513          	addi	a0,a0,806 # 80010e60 <ref_count>
    80000b42:	00000097          	auipc	ra,0x0
    80000b46:	2d8080e7          	jalr	728(ra) # 80000e1a <acquire>
  if(ref_count.no_of_references[(uint64)pa >> 12] < 0)
    80000b4a:	00c4d793          	srli	a5,s1,0xc
    80000b4e:	00478693          	addi	a3,a5,4
    80000b52:	068a                	slli	a3,a3,0x2
    80000b54:	00010717          	auipc	a4,0x10
    80000b58:	30c70713          	addi	a4,a4,780 # 80010e60 <ref_count>
    80000b5c:	9736                	add	a4,a4,a3
    80000b5e:	4718                	lw	a4,8(a4)
    80000b60:	02074463          	bltz	a4,80000b88 <safe_increment_references+0x5a>
  {
    panic("safe_increment_references");
  }
  ref_count.no_of_references[((uint64)(pa) >> 12)] += 1;       // basically increments the number of references for that page
    80000b64:	00010517          	auipc	a0,0x10
    80000b68:	2fc50513          	addi	a0,a0,764 # 80010e60 <ref_count>
    80000b6c:	0791                	addi	a5,a5,4
    80000b6e:	078a                	slli	a5,a5,0x2
    80000b70:	97aa                	add	a5,a5,a0
    80000b72:	2705                	addiw	a4,a4,1
    80000b74:	c798                	sw	a4,8(a5)
  release(&ref_count.lock);
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	358080e7          	jalr	856(ra) # 80000ece <release>
}
    80000b7e:	60e2                	ld	ra,24(sp)
    80000b80:	6442                	ld	s0,16(sp)
    80000b82:	64a2                	ld	s1,8(sp)
    80000b84:	6105                	addi	sp,sp,32
    80000b86:	8082                	ret
    panic("safe_increment_references");
    80000b88:	00007517          	auipc	a0,0x7
    80000b8c:	51050513          	addi	a0,a0,1296 # 80008098 <digits+0x58>
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	9ac080e7          	jalr	-1620(ra) # 8000053c <panic>

0000000080000b98 <freerange>:
{
    80000b98:	7139                	addi	sp,sp,-64
    80000b9a:	fc06                	sd	ra,56(sp)
    80000b9c:	f822                	sd	s0,48(sp)
    80000b9e:	f426                	sd	s1,40(sp)
    80000ba0:	f04a                	sd	s2,32(sp)
    80000ba2:	ec4e                	sd	s3,24(sp)
    80000ba4:	e852                	sd	s4,16(sp)
    80000ba6:	e456                	sd	s5,8(sp)
    80000ba8:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000baa:	6785                	lui	a5,0x1
    80000bac:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000bb0:	00e504b3          	add	s1,a0,a4
    80000bb4:	777d                	lui	a4,0xfffff
    80000bb6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000bb8:	94be                	add	s1,s1,a5
    80000bba:	0295e463          	bltu	a1,s1,80000be2 <freerange+0x4a>
    80000bbe:	89ae                	mv	s3,a1
    80000bc0:	7afd                	lui	s5,0xfffff
    80000bc2:	6a05                	lui	s4,0x1
    80000bc4:	01548933          	add	s2,s1,s5
    safe_increment_references(p);    // increment page references
    80000bc8:	854a                	mv	a0,s2
    80000bca:	00000097          	auipc	ra,0x0
    80000bce:	f64080e7          	jalr	-156(ra) # 80000b2e <safe_increment_references>
    kfree(p);
    80000bd2:	854a                	mv	a0,s2
    80000bd4:	00000097          	auipc	ra,0x0
    80000bd8:	e10080e7          	jalr	-496(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000bdc:	94d2                	add	s1,s1,s4
    80000bde:	fe99f3e3          	bgeu	s3,s1,80000bc4 <freerange+0x2c>
}
    80000be2:	70e2                	ld	ra,56(sp)
    80000be4:	7442                	ld	s0,48(sp)
    80000be6:	74a2                	ld	s1,40(sp)
    80000be8:	7902                	ld	s2,32(sp)
    80000bea:	69e2                	ld	s3,24(sp)
    80000bec:	6a42                	ld	s4,16(sp)
    80000bee:	6aa2                	ld	s5,8(sp)
    80000bf0:	6121                	addi	sp,sp,64
    80000bf2:	8082                	ret

0000000080000bf4 <kinit>:
{
    80000bf4:	1141                	addi	sp,sp,-16
    80000bf6:	e406                	sd	ra,8(sp)
    80000bf8:	e022                	sd	s0,0(sp)
    80000bfa:	0800                	addi	s0,sp,16
  refcountinit();
    80000bfc:	00000097          	auipc	ra,0x0
    80000c00:	ed0080e7          	jalr	-304(ra) # 80000acc <refcountinit>
  initlock(&kmem.lock, "kmem");
    80000c04:	00007597          	auipc	a1,0x7
    80000c08:	4b458593          	addi	a1,a1,1204 # 800080b8 <digits+0x78>
    80000c0c:	00010517          	auipc	a0,0x10
    80000c10:	23450513          	addi	a0,a0,564 # 80010e40 <kmem>
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	176080e7          	jalr	374(ra) # 80000d8a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000c1c:	45c5                	li	a1,17
    80000c1e:	05ee                	slli	a1,a1,0x1b
    80000c20:	00248517          	auipc	a0,0x248
    80000c24:	c0850513          	addi	a0,a0,-1016 # 80248828 <end>
    80000c28:	00000097          	auipc	ra,0x0
    80000c2c:	f70080e7          	jalr	-144(ra) # 80000b98 <freerange>
}
    80000c30:	60a2                	ld	ra,8(sp)
    80000c32:	6402                	ld	s0,0(sp)
    80000c34:	0141                	addi	sp,sp,16
    80000c36:	8082                	ret

0000000080000c38 <kalloc>:
{
    80000c38:	1101                	addi	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	addi	s0,sp,32
  acquire(&kmem.lock);
    80000c42:	00010497          	auipc	s1,0x10
    80000c46:	1fe48493          	addi	s1,s1,510 # 80010e40 <kmem>
    80000c4a:	8526                	mv	a0,s1
    80000c4c:	00000097          	auipc	ra,0x0
    80000c50:	1ce080e7          	jalr	462(ra) # 80000e1a <acquire>
  r = kmem.freelist;
    80000c54:	6c84                	ld	s1,24(s1)
  if(r)
    80000c56:	cc8d                	beqz	s1,80000c90 <kalloc+0x58>
    kmem.freelist = r->next;
    80000c58:	609c                	ld	a5,0(s1)
    80000c5a:	00010517          	auipc	a0,0x10
    80000c5e:	1e650513          	addi	a0,a0,486 # 80010e40 <kmem>
    80000c62:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000c64:	00000097          	auipc	ra,0x0
    80000c68:	26a080e7          	jalr	618(ra) # 80000ece <release>
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c6c:	6605                	lui	a2,0x1
    80000c6e:	4595                	li	a1,5
    80000c70:	8526                	mv	a0,s1
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	2a4080e7          	jalr	676(ra) # 80000f16 <memset>
    safe_increment_references((void*)r);
    80000c7a:	8526                	mv	a0,s1
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	eb2080e7          	jalr	-334(ra) # 80000b2e <safe_increment_references>
}
    80000c84:	8526                	mv	a0,s1
    80000c86:	60e2                	ld	ra,24(sp)
    80000c88:	6442                	ld	s0,16(sp)
    80000c8a:	64a2                	ld	s1,8(sp)
    80000c8c:	6105                	addi	sp,sp,32
    80000c8e:	8082                	ret
  release(&kmem.lock);
    80000c90:	00010517          	auipc	a0,0x10
    80000c94:	1b050513          	addi	a0,a0,432 # 80010e40 <kmem>
    80000c98:	00000097          	auipc	ra,0x0
    80000c9c:	236080e7          	jalr	566(ra) # 80000ece <release>
  if(r)
    80000ca0:	b7d5                	j	80000c84 <kalloc+0x4c>

0000000080000ca2 <safe_decrement_references>:

void safe_decrement_references(void* pa)
{
    80000ca2:	1101                	addi	sp,sp,-32
    80000ca4:	ec06                	sd	ra,24(sp)
    80000ca6:	e822                	sd	s0,16(sp)
    80000ca8:	e426                	sd	s1,8(sp)
    80000caa:	1000                	addi	s0,sp,32
    80000cac:	84aa                	mv	s1,a0
  acquire(&ref_count.lock);
    80000cae:	00010517          	auipc	a0,0x10
    80000cb2:	1b250513          	addi	a0,a0,434 # 80010e60 <ref_count>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	164080e7          	jalr	356(ra) # 80000e1a <acquire>
  if(ref_count.no_of_references[(uint64)pa >> 12] <= 0)
    80000cbe:	00c4d793          	srli	a5,s1,0xc
    80000cc2:	00478693          	addi	a3,a5,4
    80000cc6:	068a                	slli	a3,a3,0x2
    80000cc8:	00010717          	auipc	a4,0x10
    80000ccc:	19870713          	addi	a4,a4,408 # 80010e60 <ref_count>
    80000cd0:	9736                	add	a4,a4,a3
    80000cd2:	4718                	lw	a4,8(a4)
    80000cd4:	02e05463          	blez	a4,80000cfc <safe_decrement_references+0x5a>
  {
    panic("safe_decrement_references");
  }
  ref_count.no_of_references[((uint64)(pa) >> 12)]  -= 1;
    80000cd8:	00010517          	auipc	a0,0x10
    80000cdc:	18850513          	addi	a0,a0,392 # 80010e60 <ref_count>
    80000ce0:	0791                	addi	a5,a5,4
    80000ce2:	078a                	slli	a5,a5,0x2
    80000ce4:	97aa                	add	a5,a5,a0
    80000ce6:	377d                	addiw	a4,a4,-1
    80000ce8:	c798                	sw	a4,8(a5)
  release(&ref_count.lock);
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	1e4080e7          	jalr	484(ra) # 80000ece <release>
}
    80000cf2:	60e2                	ld	ra,24(sp)
    80000cf4:	6442                	ld	s0,16(sp)
    80000cf6:	64a2                	ld	s1,8(sp)
    80000cf8:	6105                	addi	sp,sp,32
    80000cfa:	8082                	ret
    panic("safe_decrement_references");
    80000cfc:	00007517          	auipc	a0,0x7
    80000d00:	36c50513          	addi	a0,a0,876 # 80008068 <digits+0x28>
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	838080e7          	jalr	-1992(ra) # 8000053c <panic>

0000000080000d0c <get_refcount>:

int get_refcount(void *pa)
{
    80000d0c:	1101                	addi	sp,sp,-32
    80000d0e:	ec06                	sd	ra,24(sp)
    80000d10:	e822                	sd	s0,16(sp)
    80000d12:	e426                	sd	s1,8(sp)
    80000d14:	1000                	addi	s0,sp,32
    80000d16:	84aa                	mv	s1,a0
  acquire(&ref_count.lock);
    80000d18:	00010517          	auipc	a0,0x10
    80000d1c:	14850513          	addi	a0,a0,328 # 80010e60 <ref_count>
    80000d20:	00000097          	auipc	ra,0x0
    80000d24:	0fa080e7          	jalr	250(ra) # 80000e1a <acquire>
  int result = ref_count.no_of_references[((uint64)(pa) >> 12)];
    80000d28:	80b1                	srli	s1,s1,0xc
    80000d2a:	0491                	addi	s1,s1,4
    80000d2c:	048a                	slli	s1,s1,0x2
    80000d2e:	00010797          	auipc	a5,0x10
    80000d32:	13278793          	addi	a5,a5,306 # 80010e60 <ref_count>
    80000d36:	97a6                	add	a5,a5,s1
    80000d38:	4784                	lw	s1,8(a5)
  if(ref_count.no_of_references[(uint64)pa >> 12] < 0)
    80000d3a:	0204c063          	bltz	s1,80000d5a <get_refcount+0x4e>
  {
    panic("get_page_ref");
  }
  release(&ref_count.lock);
    80000d3e:	00010517          	auipc	a0,0x10
    80000d42:	12250513          	addi	a0,a0,290 # 80010e60 <ref_count>
    80000d46:	00000097          	auipc	ra,0x0
    80000d4a:	188080e7          	jalr	392(ra) # 80000ece <release>
  return result;
}
    80000d4e:	8526                	mv	a0,s1
    80000d50:	60e2                	ld	ra,24(sp)
    80000d52:	6442                	ld	s0,16(sp)
    80000d54:	64a2                	ld	s1,8(sp)
    80000d56:	6105                	addi	sp,sp,32
    80000d58:	8082                	ret
    panic("get_page_ref");
    80000d5a:	00007517          	auipc	a0,0x7
    80000d5e:	36650513          	addi	a0,a0,870 # 800080c0 <digits+0x80>
    80000d62:	fffff097          	auipc	ra,0xfffff
    80000d66:	7da080e7          	jalr	2010(ra) # 8000053c <panic>

0000000080000d6a <reset_refcount>:

void reset_refcount(void* pa)
{
    80000d6a:	1141                	addi	sp,sp,-16
    80000d6c:	e422                	sd	s0,8(sp)
    80000d6e:	0800                	addi	s0,sp,16
  ref_count.no_of_references[((uint64)(pa) >> 12)] = 0;
    80000d70:	8131                	srli	a0,a0,0xc
    80000d72:	0511                	addi	a0,a0,4
    80000d74:	050a                	slli	a0,a0,0x2
    80000d76:	00010797          	auipc	a5,0x10
    80000d7a:	0ea78793          	addi	a5,a5,234 # 80010e60 <ref_count>
    80000d7e:	97aa                	add	a5,a5,a0
    80000d80:	0007a423          	sw	zero,8(a5)
}
    80000d84:	6422                	ld	s0,8(sp)
    80000d86:	0141                	addi	sp,sp,16
    80000d88:	8082                	ret

0000000080000d8a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e422                	sd	s0,8(sp)
    80000d8e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d90:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d92:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d96:	00053823          	sd	zero,16(a0)
}
    80000d9a:	6422                	ld	s0,8(sp)
    80000d9c:	0141                	addi	sp,sp,16
    80000d9e:	8082                	ret

0000000080000da0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000da0:	411c                	lw	a5,0(a0)
    80000da2:	e399                	bnez	a5,80000da8 <holding+0x8>
    80000da4:	4501                	li	a0,0
  return r;
}
    80000da6:	8082                	ret
{
    80000da8:	1101                	addi	sp,sp,-32
    80000daa:	ec06                	sd	ra,24(sp)
    80000dac:	e822                	sd	s0,16(sp)
    80000dae:	e426                	sd	s1,8(sp)
    80000db0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000db2:	6904                	ld	s1,16(a0)
    80000db4:	00001097          	auipc	ra,0x1
    80000db8:	ec0080e7          	jalr	-320(ra) # 80001c74 <mycpu>
    80000dbc:	40a48533          	sub	a0,s1,a0
    80000dc0:	00153513          	seqz	a0,a0
}
    80000dc4:	60e2                	ld	ra,24(sp)
    80000dc6:	6442                	ld	s0,16(sp)
    80000dc8:	64a2                	ld	s1,8(sp)
    80000dca:	6105                	addi	sp,sp,32
    80000dcc:	8082                	ret

0000000080000dce <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000dce:	1101                	addi	sp,sp,-32
    80000dd0:	ec06                	sd	ra,24(sp)
    80000dd2:	e822                	sd	s0,16(sp)
    80000dd4:	e426                	sd	s1,8(sp)
    80000dd6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dd8:	100024f3          	csrr	s1,sstatus
    80000ddc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000de0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000de2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000de6:	00001097          	auipc	ra,0x1
    80000dea:	e8e080e7          	jalr	-370(ra) # 80001c74 <mycpu>
    80000dee:	5d3c                	lw	a5,120(a0)
    80000df0:	cf89                	beqz	a5,80000e0a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000df2:	00001097          	auipc	ra,0x1
    80000df6:	e82080e7          	jalr	-382(ra) # 80001c74 <mycpu>
    80000dfa:	5d3c                	lw	a5,120(a0)
    80000dfc:	2785                	addiw	a5,a5,1
    80000dfe:	dd3c                	sw	a5,120(a0)
}
    80000e00:	60e2                	ld	ra,24(sp)
    80000e02:	6442                	ld	s0,16(sp)
    80000e04:	64a2                	ld	s1,8(sp)
    80000e06:	6105                	addi	sp,sp,32
    80000e08:	8082                	ret
    mycpu()->intena = old;
    80000e0a:	00001097          	auipc	ra,0x1
    80000e0e:	e6a080e7          	jalr	-406(ra) # 80001c74 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000e12:	8085                	srli	s1,s1,0x1
    80000e14:	8885                	andi	s1,s1,1
    80000e16:	dd64                	sw	s1,124(a0)
    80000e18:	bfe9                	j	80000df2 <push_off+0x24>

0000000080000e1a <acquire>:
{
    80000e1a:	1101                	addi	sp,sp,-32
    80000e1c:	ec06                	sd	ra,24(sp)
    80000e1e:	e822                	sd	s0,16(sp)
    80000e20:	e426                	sd	s1,8(sp)
    80000e22:	1000                	addi	s0,sp,32
    80000e24:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000e26:	00000097          	auipc	ra,0x0
    80000e2a:	fa8080e7          	jalr	-88(ra) # 80000dce <push_off>
  if(holding(lk))
    80000e2e:	8526                	mv	a0,s1
    80000e30:	00000097          	auipc	ra,0x0
    80000e34:	f70080e7          	jalr	-144(ra) # 80000da0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000e38:	4705                	li	a4,1
  if(holding(lk))
    80000e3a:	e115                	bnez	a0,80000e5e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000e3c:	87ba                	mv	a5,a4
    80000e3e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000e42:	2781                	sext.w	a5,a5
    80000e44:	ffe5                	bnez	a5,80000e3c <acquire+0x22>
  __sync_synchronize();
    80000e46:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e4a:	00001097          	auipc	ra,0x1
    80000e4e:	e2a080e7          	jalr	-470(ra) # 80001c74 <mycpu>
    80000e52:	e888                	sd	a0,16(s1)
}
    80000e54:	60e2                	ld	ra,24(sp)
    80000e56:	6442                	ld	s0,16(sp)
    80000e58:	64a2                	ld	s1,8(sp)
    80000e5a:	6105                	addi	sp,sp,32
    80000e5c:	8082                	ret
    panic("acquire");
    80000e5e:	00007517          	auipc	a0,0x7
    80000e62:	27250513          	addi	a0,a0,626 # 800080d0 <digits+0x90>
    80000e66:	fffff097          	auipc	ra,0xfffff
    80000e6a:	6d6080e7          	jalr	1750(ra) # 8000053c <panic>

0000000080000e6e <pop_off>:

void
pop_off(void)
{
    80000e6e:	1141                	addi	sp,sp,-16
    80000e70:	e406                	sd	ra,8(sp)
    80000e72:	e022                	sd	s0,0(sp)
    80000e74:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e76:	00001097          	auipc	ra,0x1
    80000e7a:	dfe080e7          	jalr	-514(ra) # 80001c74 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e7e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e82:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e84:	e78d                	bnez	a5,80000eae <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e86:	5d3c                	lw	a5,120(a0)
    80000e88:	02f05b63          	blez	a5,80000ebe <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e8c:	37fd                	addiw	a5,a5,-1
    80000e8e:	0007871b          	sext.w	a4,a5
    80000e92:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e94:	eb09                	bnez	a4,80000ea6 <pop_off+0x38>
    80000e96:	5d7c                	lw	a5,124(a0)
    80000e98:	c799                	beqz	a5,80000ea6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e9a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e9e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ea2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ea6:	60a2                	ld	ra,8(sp)
    80000ea8:	6402                	ld	s0,0(sp)
    80000eaa:	0141                	addi	sp,sp,16
    80000eac:	8082                	ret
    panic("pop_off - interruptible");
    80000eae:	00007517          	auipc	a0,0x7
    80000eb2:	22a50513          	addi	a0,a0,554 # 800080d8 <digits+0x98>
    80000eb6:	fffff097          	auipc	ra,0xfffff
    80000eba:	686080e7          	jalr	1670(ra) # 8000053c <panic>
    panic("pop_off");
    80000ebe:	00007517          	auipc	a0,0x7
    80000ec2:	23250513          	addi	a0,a0,562 # 800080f0 <digits+0xb0>
    80000ec6:	fffff097          	auipc	ra,0xfffff
    80000eca:	676080e7          	jalr	1654(ra) # 8000053c <panic>

0000000080000ece <release>:
{
    80000ece:	1101                	addi	sp,sp,-32
    80000ed0:	ec06                	sd	ra,24(sp)
    80000ed2:	e822                	sd	s0,16(sp)
    80000ed4:	e426                	sd	s1,8(sp)
    80000ed6:	1000                	addi	s0,sp,32
    80000ed8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000eda:	00000097          	auipc	ra,0x0
    80000ede:	ec6080e7          	jalr	-314(ra) # 80000da0 <holding>
    80000ee2:	c115                	beqz	a0,80000f06 <release+0x38>
  lk->cpu = 0;
    80000ee4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ee8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000eec:	0f50000f          	fence	iorw,ow
    80000ef0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	f7a080e7          	jalr	-134(ra) # 80000e6e <pop_off>
}
    80000efc:	60e2                	ld	ra,24(sp)
    80000efe:	6442                	ld	s0,16(sp)
    80000f00:	64a2                	ld	s1,8(sp)
    80000f02:	6105                	addi	sp,sp,32
    80000f04:	8082                	ret
    panic("release");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1f250513          	addi	a0,a0,498 # 800080f8 <digits+0xb8>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	62e080e7          	jalr	1582(ra) # 8000053c <panic>

0000000080000f16 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000f16:	1141                	addi	sp,sp,-16
    80000f18:	e422                	sd	s0,8(sp)
    80000f1a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000f1c:	ca19                	beqz	a2,80000f32 <memset+0x1c>
    80000f1e:	87aa                	mv	a5,a0
    80000f20:	1602                	slli	a2,a2,0x20
    80000f22:	9201                	srli	a2,a2,0x20
    80000f24:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000f28:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000f2c:	0785                	addi	a5,a5,1
    80000f2e:	fee79de3          	bne	a5,a4,80000f28 <memset+0x12>
  }
  return dst;
}
    80000f32:	6422                	ld	s0,8(sp)
    80000f34:	0141                	addi	sp,sp,16
    80000f36:	8082                	ret

0000000080000f38 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000f38:	1141                	addi	sp,sp,-16
    80000f3a:	e422                	sd	s0,8(sp)
    80000f3c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000f3e:	ca05                	beqz	a2,80000f6e <memcmp+0x36>
    80000f40:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000f44:	1682                	slli	a3,a3,0x20
    80000f46:	9281                	srli	a3,a3,0x20
    80000f48:	0685                	addi	a3,a3,1
    80000f4a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000f4c:	00054783          	lbu	a5,0(a0)
    80000f50:	0005c703          	lbu	a4,0(a1)
    80000f54:	00e79863          	bne	a5,a4,80000f64 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000f58:	0505                	addi	a0,a0,1
    80000f5a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000f5c:	fed518e3          	bne	a0,a3,80000f4c <memcmp+0x14>
  }

  return 0;
    80000f60:	4501                	li	a0,0
    80000f62:	a019                	j	80000f68 <memcmp+0x30>
      return *s1 - *s2;
    80000f64:	40e7853b          	subw	a0,a5,a4
}
    80000f68:	6422                	ld	s0,8(sp)
    80000f6a:	0141                	addi	sp,sp,16
    80000f6c:	8082                	ret
  return 0;
    80000f6e:	4501                	li	a0,0
    80000f70:	bfe5                	j	80000f68 <memcmp+0x30>

0000000080000f72 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f72:	1141                	addi	sp,sp,-16
    80000f74:	e422                	sd	s0,8(sp)
    80000f76:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f78:	c205                	beqz	a2,80000f98 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f7a:	02a5e263          	bltu	a1,a0,80000f9e <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f7e:	1602                	slli	a2,a2,0x20
    80000f80:	9201                	srli	a2,a2,0x20
    80000f82:	00c587b3          	add	a5,a1,a2
{
    80000f86:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f88:	0585                	addi	a1,a1,1
    80000f8a:	0705                	addi	a4,a4,1
    80000f8c:	fff5c683          	lbu	a3,-1(a1)
    80000f90:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f94:	fef59ae3          	bne	a1,a5,80000f88 <memmove+0x16>

  return dst;
}
    80000f98:	6422                	ld	s0,8(sp)
    80000f9a:	0141                	addi	sp,sp,16
    80000f9c:	8082                	ret
  if(s < d && s + n > d){
    80000f9e:	02061693          	slli	a3,a2,0x20
    80000fa2:	9281                	srli	a3,a3,0x20
    80000fa4:	00d58733          	add	a4,a1,a3
    80000fa8:	fce57be3          	bgeu	a0,a4,80000f7e <memmove+0xc>
    d += n;
    80000fac:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000fae:	fff6079b          	addiw	a5,a2,-1
    80000fb2:	1782                	slli	a5,a5,0x20
    80000fb4:	9381                	srli	a5,a5,0x20
    80000fb6:	fff7c793          	not	a5,a5
    80000fba:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000fbc:	177d                	addi	a4,a4,-1
    80000fbe:	16fd                	addi	a3,a3,-1
    80000fc0:	00074603          	lbu	a2,0(a4)
    80000fc4:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000fc8:	fee79ae3          	bne	a5,a4,80000fbc <memmove+0x4a>
    80000fcc:	b7f1                	j	80000f98 <memmove+0x26>

0000000080000fce <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000fce:	1141                	addi	sp,sp,-16
    80000fd0:	e406                	sd	ra,8(sp)
    80000fd2:	e022                	sd	s0,0(sp)
    80000fd4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000fd6:	00000097          	auipc	ra,0x0
    80000fda:	f9c080e7          	jalr	-100(ra) # 80000f72 <memmove>
}
    80000fde:	60a2                	ld	ra,8(sp)
    80000fe0:	6402                	ld	s0,0(sp)
    80000fe2:	0141                	addi	sp,sp,16
    80000fe4:	8082                	ret

0000000080000fe6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000fe6:	1141                	addi	sp,sp,-16
    80000fe8:	e422                	sd	s0,8(sp)
    80000fea:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000fec:	ce11                	beqz	a2,80001008 <strncmp+0x22>
    80000fee:	00054783          	lbu	a5,0(a0)
    80000ff2:	cf89                	beqz	a5,8000100c <strncmp+0x26>
    80000ff4:	0005c703          	lbu	a4,0(a1)
    80000ff8:	00f71a63          	bne	a4,a5,8000100c <strncmp+0x26>
    n--, p++, q++;
    80000ffc:	367d                	addiw	a2,a2,-1
    80000ffe:	0505                	addi	a0,a0,1
    80001000:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80001002:	f675                	bnez	a2,80000fee <strncmp+0x8>
  if(n == 0)
    return 0;
    80001004:	4501                	li	a0,0
    80001006:	a809                	j	80001018 <strncmp+0x32>
    80001008:	4501                	li	a0,0
    8000100a:	a039                	j	80001018 <strncmp+0x32>
  if(n == 0)
    8000100c:	ca09                	beqz	a2,8000101e <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    8000100e:	00054503          	lbu	a0,0(a0)
    80001012:	0005c783          	lbu	a5,0(a1)
    80001016:	9d1d                	subw	a0,a0,a5
}
    80001018:	6422                	ld	s0,8(sp)
    8000101a:	0141                	addi	sp,sp,16
    8000101c:	8082                	ret
    return 0;
    8000101e:	4501                	li	a0,0
    80001020:	bfe5                	j	80001018 <strncmp+0x32>

0000000080001022 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80001022:	1141                	addi	sp,sp,-16
    80001024:	e422                	sd	s0,8(sp)
    80001026:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001028:	87aa                	mv	a5,a0
    8000102a:	86b2                	mv	a3,a2
    8000102c:	367d                	addiw	a2,a2,-1
    8000102e:	00d05963          	blez	a3,80001040 <strncpy+0x1e>
    80001032:	0785                	addi	a5,a5,1
    80001034:	0005c703          	lbu	a4,0(a1)
    80001038:	fee78fa3          	sb	a4,-1(a5)
    8000103c:	0585                	addi	a1,a1,1
    8000103e:	f775                	bnez	a4,8000102a <strncpy+0x8>
    ;
  while(n-- > 0)
    80001040:	873e                	mv	a4,a5
    80001042:	9fb5                	addw	a5,a5,a3
    80001044:	37fd                	addiw	a5,a5,-1
    80001046:	00c05963          	blez	a2,80001058 <strncpy+0x36>
    *s++ = 0;
    8000104a:	0705                	addi	a4,a4,1
    8000104c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80001050:	40e786bb          	subw	a3,a5,a4
    80001054:	fed04be3          	bgtz	a3,8000104a <strncpy+0x28>
  return os;
}
    80001058:	6422                	ld	s0,8(sp)
    8000105a:	0141                	addi	sp,sp,16
    8000105c:	8082                	ret

000000008000105e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000105e:	1141                	addi	sp,sp,-16
    80001060:	e422                	sd	s0,8(sp)
    80001062:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001064:	02c05363          	blez	a2,8000108a <safestrcpy+0x2c>
    80001068:	fff6069b          	addiw	a3,a2,-1
    8000106c:	1682                	slli	a3,a3,0x20
    8000106e:	9281                	srli	a3,a3,0x20
    80001070:	96ae                	add	a3,a3,a1
    80001072:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001074:	00d58963          	beq	a1,a3,80001086 <safestrcpy+0x28>
    80001078:	0585                	addi	a1,a1,1
    8000107a:	0785                	addi	a5,a5,1
    8000107c:	fff5c703          	lbu	a4,-1(a1)
    80001080:	fee78fa3          	sb	a4,-1(a5)
    80001084:	fb65                	bnez	a4,80001074 <safestrcpy+0x16>
    ;
  *s = 0;
    80001086:	00078023          	sb	zero,0(a5)
  return os;
}
    8000108a:	6422                	ld	s0,8(sp)
    8000108c:	0141                	addi	sp,sp,16
    8000108e:	8082                	ret

0000000080001090 <strlen>:

int
strlen(const char *s)
{
    80001090:	1141                	addi	sp,sp,-16
    80001092:	e422                	sd	s0,8(sp)
    80001094:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001096:	00054783          	lbu	a5,0(a0)
    8000109a:	cf91                	beqz	a5,800010b6 <strlen+0x26>
    8000109c:	0505                	addi	a0,a0,1
    8000109e:	87aa                	mv	a5,a0
    800010a0:	86be                	mv	a3,a5
    800010a2:	0785                	addi	a5,a5,1
    800010a4:	fff7c703          	lbu	a4,-1(a5)
    800010a8:	ff65                	bnez	a4,800010a0 <strlen+0x10>
    800010aa:	40a6853b          	subw	a0,a3,a0
    800010ae:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    800010b0:	6422                	ld	s0,8(sp)
    800010b2:	0141                	addi	sp,sp,16
    800010b4:	8082                	ret
  for(n = 0; s[n]; n++)
    800010b6:	4501                	li	a0,0
    800010b8:	bfe5                	j	800010b0 <strlen+0x20>

00000000800010ba <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800010ba:	1141                	addi	sp,sp,-16
    800010bc:	e406                	sd	ra,8(sp)
    800010be:	e022                	sd	s0,0(sp)
    800010c0:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800010c2:	00001097          	auipc	ra,0x1
    800010c6:	ba2080e7          	jalr	-1118(ra) # 80001c64 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800010ca:	00008717          	auipc	a4,0x8
    800010ce:	b0e70713          	addi	a4,a4,-1266 # 80008bd8 <started>
  if(cpuid() == 0){
    800010d2:	c139                	beqz	a0,80001118 <main+0x5e>
    while(started == 0)
    800010d4:	431c                	lw	a5,0(a4)
    800010d6:	2781                	sext.w	a5,a5
    800010d8:	dff5                	beqz	a5,800010d4 <main+0x1a>
      ;
    __sync_synchronize();
    800010da:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800010de:	00001097          	auipc	ra,0x1
    800010e2:	b86080e7          	jalr	-1146(ra) # 80001c64 <cpuid>
    800010e6:	85aa                	mv	a1,a0
    800010e8:	00007517          	auipc	a0,0x7
    800010ec:	03050513          	addi	a0,a0,48 # 80008118 <digits+0xd8>
    800010f0:	fffff097          	auipc	ra,0xfffff
    800010f4:	496080e7          	jalr	1174(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	0d8080e7          	jalr	216(ra) # 800011d0 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001100:	00002097          	auipc	ra,0x2
    80001104:	e4c080e7          	jalr	-436(ra) # 80002f4c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001108:	00005097          	auipc	ra,0x5
    8000110c:	788080e7          	jalr	1928(ra) # 80006890 <plicinithart>
  }

  scheduler();        
    80001110:	00001097          	auipc	ra,0x1
    80001114:	508080e7          	jalr	1288(ra) # 80002618 <scheduler>
    consoleinit();
    80001118:	fffff097          	auipc	ra,0xfffff
    8000111c:	334080e7          	jalr	820(ra) # 8000044c <consoleinit>
    printfinit();
    80001120:	fffff097          	auipc	ra,0xfffff
    80001124:	646080e7          	jalr	1606(ra) # 80000766 <printfinit>
    printf("\n");
    80001128:	00007517          	auipc	a0,0x7
    8000112c:	3b850513          	addi	a0,a0,952 # 800084e0 <states.0+0x178>
    80001130:	fffff097          	auipc	ra,0xfffff
    80001134:	456080e7          	jalr	1110(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80001138:	00007517          	auipc	a0,0x7
    8000113c:	fc850513          	addi	a0,a0,-56 # 80008100 <digits+0xc0>
    80001140:	fffff097          	auipc	ra,0xfffff
    80001144:	446080e7          	jalr	1094(ra) # 80000586 <printf>
    printf("\n");
    80001148:	00007517          	auipc	a0,0x7
    8000114c:	39850513          	addi	a0,a0,920 # 800084e0 <states.0+0x178>
    80001150:	fffff097          	auipc	ra,0xfffff
    80001154:	436080e7          	jalr	1078(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	a9c080e7          	jalr	-1380(ra) # 80000bf4 <kinit>
    kvminit();       // create kernel page table
    80001160:	00000097          	auipc	ra,0x0
    80001164:	326080e7          	jalr	806(ra) # 80001486 <kvminit>
    kvminithart();   // turn on paging
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	068080e7          	jalr	104(ra) # 800011d0 <kvminithart>
    procinit();      // process table
    80001170:	00001097          	auipc	ra,0x1
    80001174:	a40080e7          	jalr	-1472(ra) # 80001bb0 <procinit>
    trapinit();      // trap vectors
    80001178:	00002097          	auipc	ra,0x2
    8000117c:	dac080e7          	jalr	-596(ra) # 80002f24 <trapinit>
    trapinithart();  // install kernel trap vector
    80001180:	00002097          	auipc	ra,0x2
    80001184:	dcc080e7          	jalr	-564(ra) # 80002f4c <trapinithart>
    plicinit();      // set up interrupt controller
    80001188:	00005097          	auipc	ra,0x5
    8000118c:	6f2080e7          	jalr	1778(ra) # 8000687a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001190:	00005097          	auipc	ra,0x5
    80001194:	700080e7          	jalr	1792(ra) # 80006890 <plicinithart>
    binit();         // buffer cache
    80001198:	00003097          	auipc	ra,0x3
    8000119c:	8f6080e7          	jalr	-1802(ra) # 80003a8e <binit>
    iinit();         // inode table
    800011a0:	00003097          	auipc	ra,0x3
    800011a4:	f94080e7          	jalr	-108(ra) # 80004134 <iinit>
    fileinit();      // file table
    800011a8:	00004097          	auipc	ra,0x4
    800011ac:	f0a080e7          	jalr	-246(ra) # 800050b2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800011b0:	00005097          	auipc	ra,0x5
    800011b4:	7e8080e7          	jalr	2024(ra) # 80006998 <virtio_disk_init>
    userinit();      // first user process
    800011b8:	00001097          	auipc	ra,0x1
    800011bc:	df4080e7          	jalr	-524(ra) # 80001fac <userinit>
    __sync_synchronize();
    800011c0:	0ff0000f          	fence
    started = 1;
    800011c4:	4785                	li	a5,1
    800011c6:	00008717          	auipc	a4,0x8
    800011ca:	a0f72923          	sw	a5,-1518(a4) # 80008bd8 <started>
    800011ce:	b789                	j	80001110 <main+0x56>

00000000800011d0 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800011d0:	1141                	addi	sp,sp,-16
    800011d2:	e422                	sd	s0,8(sp)
    800011d4:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800011d6:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800011da:	00008797          	auipc	a5,0x8
    800011de:	a067b783          	ld	a5,-1530(a5) # 80008be0 <kernel_pagetable>
    800011e2:	83b1                	srli	a5,a5,0xc
    800011e4:	577d                	li	a4,-1
    800011e6:	177e                	slli	a4,a4,0x3f
    800011e8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800011ea:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800011ee:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800011f2:	6422                	ld	s0,8(sp)
    800011f4:	0141                	addi	sp,sp,16
    800011f6:	8082                	ret

00000000800011f8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800011f8:	7139                	addi	sp,sp,-64
    800011fa:	fc06                	sd	ra,56(sp)
    800011fc:	f822                	sd	s0,48(sp)
    800011fe:	f426                	sd	s1,40(sp)
    80001200:	f04a                	sd	s2,32(sp)
    80001202:	ec4e                	sd	s3,24(sp)
    80001204:	e852                	sd	s4,16(sp)
    80001206:	e456                	sd	s5,8(sp)
    80001208:	e05a                	sd	s6,0(sp)
    8000120a:	0080                	addi	s0,sp,64
    8000120c:	84aa                	mv	s1,a0
    8000120e:	89ae                	mv	s3,a1
    80001210:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001212:	57fd                	li	a5,-1
    80001214:	83e9                	srli	a5,a5,0x1a
    80001216:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001218:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000121a:	04b7f263          	bgeu	a5,a1,8000125e <walk+0x66>
    panic("walk");
    8000121e:	00007517          	auipc	a0,0x7
    80001222:	f1250513          	addi	a0,a0,-238 # 80008130 <digits+0xf0>
    80001226:	fffff097          	auipc	ra,0xfffff
    8000122a:	316080e7          	jalr	790(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000122e:	060a8663          	beqz	s5,8000129a <walk+0xa2>
    80001232:	00000097          	auipc	ra,0x0
    80001236:	a06080e7          	jalr	-1530(ra) # 80000c38 <kalloc>
    8000123a:	84aa                	mv	s1,a0
    8000123c:	c529                	beqz	a0,80001286 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000123e:	6605                	lui	a2,0x1
    80001240:	4581                	li	a1,0
    80001242:	00000097          	auipc	ra,0x0
    80001246:	cd4080e7          	jalr	-812(ra) # 80000f16 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000124a:	00c4d793          	srli	a5,s1,0xc
    8000124e:	07aa                	slli	a5,a5,0xa
    80001250:	0017e793          	ori	a5,a5,1
    80001254:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001258:	3a5d                	addiw	s4,s4,-9 # ff7 <_entry-0x7ffff009>
    8000125a:	036a0063          	beq	s4,s6,8000127a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000125e:	0149d933          	srl	s2,s3,s4
    80001262:	1ff97913          	andi	s2,s2,511
    80001266:	090e                	slli	s2,s2,0x3
    80001268:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000126a:	00093483          	ld	s1,0(s2)
    8000126e:	0014f793          	andi	a5,s1,1
    80001272:	dfd5                	beqz	a5,8000122e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001274:	80a9                	srli	s1,s1,0xa
    80001276:	04b2                	slli	s1,s1,0xc
    80001278:	b7c5                	j	80001258 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000127a:	00c9d513          	srli	a0,s3,0xc
    8000127e:	1ff57513          	andi	a0,a0,511
    80001282:	050e                	slli	a0,a0,0x3
    80001284:	9526                	add	a0,a0,s1
}
    80001286:	70e2                	ld	ra,56(sp)
    80001288:	7442                	ld	s0,48(sp)
    8000128a:	74a2                	ld	s1,40(sp)
    8000128c:	7902                	ld	s2,32(sp)
    8000128e:	69e2                	ld	s3,24(sp)
    80001290:	6a42                	ld	s4,16(sp)
    80001292:	6aa2                	ld	s5,8(sp)
    80001294:	6b02                	ld	s6,0(sp)
    80001296:	6121                	addi	sp,sp,64
    80001298:	8082                	ret
        return 0;
    8000129a:	4501                	li	a0,0
    8000129c:	b7ed                	j	80001286 <walk+0x8e>

000000008000129e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000129e:	57fd                	li	a5,-1
    800012a0:	83e9                	srli	a5,a5,0x1a
    800012a2:	00b7f463          	bgeu	a5,a1,800012aa <walkaddr+0xc>
    return 0;
    800012a6:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800012a8:	8082                	ret
{
    800012aa:	1141                	addi	sp,sp,-16
    800012ac:	e406                	sd	ra,8(sp)
    800012ae:	e022                	sd	s0,0(sp)
    800012b0:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800012b2:	4601                	li	a2,0
    800012b4:	00000097          	auipc	ra,0x0
    800012b8:	f44080e7          	jalr	-188(ra) # 800011f8 <walk>
  if(pte == 0)
    800012bc:	c105                	beqz	a0,800012dc <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800012be:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800012c0:	0117f693          	andi	a3,a5,17
    800012c4:	4745                	li	a4,17
    return 0;
    800012c6:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800012c8:	00e68663          	beq	a3,a4,800012d4 <walkaddr+0x36>
}
    800012cc:	60a2                	ld	ra,8(sp)
    800012ce:	6402                	ld	s0,0(sp)
    800012d0:	0141                	addi	sp,sp,16
    800012d2:	8082                	ret
  pa = PTE2PA(*pte);
    800012d4:	83a9                	srli	a5,a5,0xa
    800012d6:	00c79513          	slli	a0,a5,0xc
  return pa;
    800012da:	bfcd                	j	800012cc <walkaddr+0x2e>
    return 0;
    800012dc:	4501                	li	a0,0
    800012de:	b7fd                	j	800012cc <walkaddr+0x2e>

00000000800012e0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800012e0:	715d                	addi	sp,sp,-80
    800012e2:	e486                	sd	ra,72(sp)
    800012e4:	e0a2                	sd	s0,64(sp)
    800012e6:	fc26                	sd	s1,56(sp)
    800012e8:	f84a                	sd	s2,48(sp)
    800012ea:	f44e                	sd	s3,40(sp)
    800012ec:	f052                	sd	s4,32(sp)
    800012ee:	ec56                	sd	s5,24(sp)
    800012f0:	e85a                	sd	s6,16(sp)
    800012f2:	e45e                	sd	s7,8(sp)
    800012f4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800012f6:	c639                	beqz	a2,80001344 <mappages+0x64>
    800012f8:	8aaa                	mv	s5,a0
    800012fa:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800012fc:	777d                	lui	a4,0xfffff
    800012fe:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001302:	fff58993          	addi	s3,a1,-1
    80001306:	99b2                	add	s3,s3,a2
    80001308:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000130c:	893e                	mv	s2,a5
    8000130e:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001312:	6b85                	lui	s7,0x1
    80001314:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001318:	4605                	li	a2,1
    8000131a:	85ca                	mv	a1,s2
    8000131c:	8556                	mv	a0,s5
    8000131e:	00000097          	auipc	ra,0x0
    80001322:	eda080e7          	jalr	-294(ra) # 800011f8 <walk>
    80001326:	cd1d                	beqz	a0,80001364 <mappages+0x84>
    if(*pte & PTE_V)
    80001328:	611c                	ld	a5,0(a0)
    8000132a:	8b85                	andi	a5,a5,1
    8000132c:	e785                	bnez	a5,80001354 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000132e:	80b1                	srli	s1,s1,0xc
    80001330:	04aa                	slli	s1,s1,0xa
    80001332:	0164e4b3          	or	s1,s1,s6
    80001336:	0014e493          	ori	s1,s1,1
    8000133a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000133c:	05390063          	beq	s2,s3,8000137c <mappages+0x9c>
    a += PGSIZE;
    80001340:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001342:	bfc9                	j	80001314 <mappages+0x34>
    panic("mappages: size");
    80001344:	00007517          	auipc	a0,0x7
    80001348:	df450513          	addi	a0,a0,-524 # 80008138 <digits+0xf8>
    8000134c:	fffff097          	auipc	ra,0xfffff
    80001350:	1f0080e7          	jalr	496(ra) # 8000053c <panic>
      panic("mappages: remap");
    80001354:	00007517          	auipc	a0,0x7
    80001358:	df450513          	addi	a0,a0,-524 # 80008148 <digits+0x108>
    8000135c:	fffff097          	auipc	ra,0xfffff
    80001360:	1e0080e7          	jalr	480(ra) # 8000053c <panic>
      return -1;
    80001364:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001366:	60a6                	ld	ra,72(sp)
    80001368:	6406                	ld	s0,64(sp)
    8000136a:	74e2                	ld	s1,56(sp)
    8000136c:	7942                	ld	s2,48(sp)
    8000136e:	79a2                	ld	s3,40(sp)
    80001370:	7a02                	ld	s4,32(sp)
    80001372:	6ae2                	ld	s5,24(sp)
    80001374:	6b42                	ld	s6,16(sp)
    80001376:	6ba2                	ld	s7,8(sp)
    80001378:	6161                	addi	sp,sp,80
    8000137a:	8082                	ret
  return 0;
    8000137c:	4501                	li	a0,0
    8000137e:	b7e5                	j	80001366 <mappages+0x86>

0000000080001380 <kvmmap>:
{
    80001380:	1141                	addi	sp,sp,-16
    80001382:	e406                	sd	ra,8(sp)
    80001384:	e022                	sd	s0,0(sp)
    80001386:	0800                	addi	s0,sp,16
    80001388:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000138a:	86b2                	mv	a3,a2
    8000138c:	863e                	mv	a2,a5
    8000138e:	00000097          	auipc	ra,0x0
    80001392:	f52080e7          	jalr	-174(ra) # 800012e0 <mappages>
    80001396:	e509                	bnez	a0,800013a0 <kvmmap+0x20>
}
    80001398:	60a2                	ld	ra,8(sp)
    8000139a:	6402                	ld	s0,0(sp)
    8000139c:	0141                	addi	sp,sp,16
    8000139e:	8082                	ret
    panic("kvmmap");
    800013a0:	00007517          	auipc	a0,0x7
    800013a4:	db850513          	addi	a0,a0,-584 # 80008158 <digits+0x118>
    800013a8:	fffff097          	auipc	ra,0xfffff
    800013ac:	194080e7          	jalr	404(ra) # 8000053c <panic>

00000000800013b0 <kvmmake>:
{
    800013b0:	1101                	addi	sp,sp,-32
    800013b2:	ec06                	sd	ra,24(sp)
    800013b4:	e822                	sd	s0,16(sp)
    800013b6:	e426                	sd	s1,8(sp)
    800013b8:	e04a                	sd	s2,0(sp)
    800013ba:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	87c080e7          	jalr	-1924(ra) # 80000c38 <kalloc>
    800013c4:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800013c6:	6605                	lui	a2,0x1
    800013c8:	4581                	li	a1,0
    800013ca:	00000097          	auipc	ra,0x0
    800013ce:	b4c080e7          	jalr	-1204(ra) # 80000f16 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013d2:	4719                	li	a4,6
    800013d4:	6685                	lui	a3,0x1
    800013d6:	10000637          	lui	a2,0x10000
    800013da:	100005b7          	lui	a1,0x10000
    800013de:	8526                	mv	a0,s1
    800013e0:	00000097          	auipc	ra,0x0
    800013e4:	fa0080e7          	jalr	-96(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013e8:	4719                	li	a4,6
    800013ea:	6685                	lui	a3,0x1
    800013ec:	10001637          	lui	a2,0x10001
    800013f0:	100015b7          	lui	a1,0x10001
    800013f4:	8526                	mv	a0,s1
    800013f6:	00000097          	auipc	ra,0x0
    800013fa:	f8a080e7          	jalr	-118(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013fe:	4719                	li	a4,6
    80001400:	004006b7          	lui	a3,0x400
    80001404:	0c000637          	lui	a2,0xc000
    80001408:	0c0005b7          	lui	a1,0xc000
    8000140c:	8526                	mv	a0,s1
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	f72080e7          	jalr	-142(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001416:	00007917          	auipc	s2,0x7
    8000141a:	bea90913          	addi	s2,s2,-1046 # 80008000 <etext>
    8000141e:	4729                	li	a4,10
    80001420:	80007697          	auipc	a3,0x80007
    80001424:	be068693          	addi	a3,a3,-1056 # 8000 <_entry-0x7fff8000>
    80001428:	4605                	li	a2,1
    8000142a:	067e                	slli	a2,a2,0x1f
    8000142c:	85b2                	mv	a1,a2
    8000142e:	8526                	mv	a0,s1
    80001430:	00000097          	auipc	ra,0x0
    80001434:	f50080e7          	jalr	-176(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001438:	4719                	li	a4,6
    8000143a:	46c5                	li	a3,17
    8000143c:	06ee                	slli	a3,a3,0x1b
    8000143e:	412686b3          	sub	a3,a3,s2
    80001442:	864a                	mv	a2,s2
    80001444:	85ca                	mv	a1,s2
    80001446:	8526                	mv	a0,s1
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	f38080e7          	jalr	-200(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001450:	4729                	li	a4,10
    80001452:	6685                	lui	a3,0x1
    80001454:	00006617          	auipc	a2,0x6
    80001458:	bac60613          	addi	a2,a2,-1108 # 80007000 <_trampoline>
    8000145c:	040005b7          	lui	a1,0x4000
    80001460:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001462:	05b2                	slli	a1,a1,0xc
    80001464:	8526                	mv	a0,s1
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	f1a080e7          	jalr	-230(ra) # 80001380 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000146e:	8526                	mv	a0,s1
    80001470:	00000097          	auipc	ra,0x0
    80001474:	6aa080e7          	jalr	1706(ra) # 80001b1a <proc_mapstacks>
}
    80001478:	8526                	mv	a0,s1
    8000147a:	60e2                	ld	ra,24(sp)
    8000147c:	6442                	ld	s0,16(sp)
    8000147e:	64a2                	ld	s1,8(sp)
    80001480:	6902                	ld	s2,0(sp)
    80001482:	6105                	addi	sp,sp,32
    80001484:	8082                	ret

0000000080001486 <kvminit>:
{
    80001486:	1141                	addi	sp,sp,-16
    80001488:	e406                	sd	ra,8(sp)
    8000148a:	e022                	sd	s0,0(sp)
    8000148c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000148e:	00000097          	auipc	ra,0x0
    80001492:	f22080e7          	jalr	-222(ra) # 800013b0 <kvmmake>
    80001496:	00007797          	auipc	a5,0x7
    8000149a:	74a7b523          	sd	a0,1866(a5) # 80008be0 <kernel_pagetable>
}
    8000149e:	60a2                	ld	ra,8(sp)
    800014a0:	6402                	ld	s0,0(sp)
    800014a2:	0141                	addi	sp,sp,16
    800014a4:	8082                	ret

00000000800014a6 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800014a6:	715d                	addi	sp,sp,-80
    800014a8:	e486                	sd	ra,72(sp)
    800014aa:	e0a2                	sd	s0,64(sp)
    800014ac:	fc26                	sd	s1,56(sp)
    800014ae:	f84a                	sd	s2,48(sp)
    800014b0:	f44e                	sd	s3,40(sp)
    800014b2:	f052                	sd	s4,32(sp)
    800014b4:	ec56                	sd	s5,24(sp)
    800014b6:	e85a                	sd	s6,16(sp)
    800014b8:	e45e                	sd	s7,8(sp)
    800014ba:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800014bc:	03459793          	slli	a5,a1,0x34
    800014c0:	e795                	bnez	a5,800014ec <uvmunmap+0x46>
    800014c2:	8a2a                	mv	s4,a0
    800014c4:	892e                	mv	s2,a1
    800014c6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014c8:	0632                	slli	a2,a2,0xc
    800014ca:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800014ce:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014d0:	6b05                	lui	s6,0x1
    800014d2:	0735e263          	bltu	a1,s3,80001536 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800014d6:	60a6                	ld	ra,72(sp)
    800014d8:	6406                	ld	s0,64(sp)
    800014da:	74e2                	ld	s1,56(sp)
    800014dc:	7942                	ld	s2,48(sp)
    800014de:	79a2                	ld	s3,40(sp)
    800014e0:	7a02                	ld	s4,32(sp)
    800014e2:	6ae2                	ld	s5,24(sp)
    800014e4:	6b42                	ld	s6,16(sp)
    800014e6:	6ba2                	ld	s7,8(sp)
    800014e8:	6161                	addi	sp,sp,80
    800014ea:	8082                	ret
    panic("uvmunmap: not aligned");
    800014ec:	00007517          	auipc	a0,0x7
    800014f0:	c7450513          	addi	a0,a0,-908 # 80008160 <digits+0x120>
    800014f4:	fffff097          	auipc	ra,0xfffff
    800014f8:	048080e7          	jalr	72(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800014fc:	00007517          	auipc	a0,0x7
    80001500:	c7c50513          	addi	a0,a0,-900 # 80008178 <digits+0x138>
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	038080e7          	jalr	56(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c7c50513          	addi	a0,a0,-900 # 80008188 <digits+0x148>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	028080e7          	jalr	40(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    8000151c:	00007517          	auipc	a0,0x7
    80001520:	c8450513          	addi	a0,a0,-892 # 800081a0 <digits+0x160>
    80001524:	fffff097          	auipc	ra,0xfffff
    80001528:	018080e7          	jalr	24(ra) # 8000053c <panic>
    *pte = 0;
    8000152c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001530:	995a                	add	s2,s2,s6
    80001532:	fb3972e3          	bgeu	s2,s3,800014d6 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001536:	4601                	li	a2,0
    80001538:	85ca                	mv	a1,s2
    8000153a:	8552                	mv	a0,s4
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	cbc080e7          	jalr	-836(ra) # 800011f8 <walk>
    80001544:	84aa                	mv	s1,a0
    80001546:	d95d                	beqz	a0,800014fc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001548:	6108                	ld	a0,0(a0)
    8000154a:	00157793          	andi	a5,a0,1
    8000154e:	dfdd                	beqz	a5,8000150c <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001550:	3ff57793          	andi	a5,a0,1023
    80001554:	fd7784e3          	beq	a5,s7,8000151c <uvmunmap+0x76>
    if(do_free){
    80001558:	fc0a8ae3          	beqz	s5,8000152c <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000155c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000155e:	0532                	slli	a0,a0,0xc
    80001560:	fffff097          	auipc	ra,0xfffff
    80001564:	484080e7          	jalr	1156(ra) # 800009e4 <kfree>
    80001568:	b7d1                	j	8000152c <uvmunmap+0x86>

000000008000156a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000156a:	1101                	addi	sp,sp,-32
    8000156c:	ec06                	sd	ra,24(sp)
    8000156e:	e822                	sd	s0,16(sp)
    80001570:	e426                	sd	s1,8(sp)
    80001572:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001574:	fffff097          	auipc	ra,0xfffff
    80001578:	6c4080e7          	jalr	1732(ra) # 80000c38 <kalloc>
    8000157c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000157e:	c519                	beqz	a0,8000158c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001580:	6605                	lui	a2,0x1
    80001582:	4581                	li	a1,0
    80001584:	00000097          	auipc	ra,0x0
    80001588:	992080e7          	jalr	-1646(ra) # 80000f16 <memset>
  return pagetable;
}
    8000158c:	8526                	mv	a0,s1
    8000158e:	60e2                	ld	ra,24(sp)
    80001590:	6442                	ld	s0,16(sp)
    80001592:	64a2                	ld	s1,8(sp)
    80001594:	6105                	addi	sp,sp,32
    80001596:	8082                	ret

0000000080001598 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001598:	7179                	addi	sp,sp,-48
    8000159a:	f406                	sd	ra,40(sp)
    8000159c:	f022                	sd	s0,32(sp)
    8000159e:	ec26                	sd	s1,24(sp)
    800015a0:	e84a                	sd	s2,16(sp)
    800015a2:	e44e                	sd	s3,8(sp)
    800015a4:	e052                	sd	s4,0(sp)
    800015a6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800015a8:	6785                	lui	a5,0x1
    800015aa:	04f67863          	bgeu	a2,a5,800015fa <uvmfirst+0x62>
    800015ae:	8a2a                	mv	s4,a0
    800015b0:	89ae                	mv	s3,a1
    800015b2:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800015b4:	fffff097          	auipc	ra,0xfffff
    800015b8:	684080e7          	jalr	1668(ra) # 80000c38 <kalloc>
    800015bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800015be:	6605                	lui	a2,0x1
    800015c0:	4581                	li	a1,0
    800015c2:	00000097          	auipc	ra,0x0
    800015c6:	954080e7          	jalr	-1708(ra) # 80000f16 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015ca:	4779                	li	a4,30
    800015cc:	86ca                	mv	a3,s2
    800015ce:	6605                	lui	a2,0x1
    800015d0:	4581                	li	a1,0
    800015d2:	8552                	mv	a0,s4
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	d0c080e7          	jalr	-756(ra) # 800012e0 <mappages>
  memmove(mem, src, sz);
    800015dc:	8626                	mv	a2,s1
    800015de:	85ce                	mv	a1,s3
    800015e0:	854a                	mv	a0,s2
    800015e2:	00000097          	auipc	ra,0x0
    800015e6:	990080e7          	jalr	-1648(ra) # 80000f72 <memmove>
}
    800015ea:	70a2                	ld	ra,40(sp)
    800015ec:	7402                	ld	s0,32(sp)
    800015ee:	64e2                	ld	s1,24(sp)
    800015f0:	6942                	ld	s2,16(sp)
    800015f2:	69a2                	ld	s3,8(sp)
    800015f4:	6a02                	ld	s4,0(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret
    panic("uvmfirst: more than a page");
    800015fa:	00007517          	auipc	a0,0x7
    800015fe:	bbe50513          	addi	a0,a0,-1090 # 800081b8 <digits+0x178>
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	f3a080e7          	jalr	-198(ra) # 8000053c <panic>

000000008000160a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000160a:	1101                	addi	sp,sp,-32
    8000160c:	ec06                	sd	ra,24(sp)
    8000160e:	e822                	sd	s0,16(sp)
    80001610:	e426                	sd	s1,8(sp)
    80001612:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001614:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001616:	00b67d63          	bgeu	a2,a1,80001630 <uvmdealloc+0x26>
    8000161a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000161c:	6785                	lui	a5,0x1
    8000161e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001620:	00f60733          	add	a4,a2,a5
    80001624:	76fd                	lui	a3,0xfffff
    80001626:	8f75                	and	a4,a4,a3
    80001628:	97ae                	add	a5,a5,a1
    8000162a:	8ff5                	and	a5,a5,a3
    8000162c:	00f76863          	bltu	a4,a5,8000163c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001630:	8526                	mv	a0,s1
    80001632:	60e2                	ld	ra,24(sp)
    80001634:	6442                	ld	s0,16(sp)
    80001636:	64a2                	ld	s1,8(sp)
    80001638:	6105                	addi	sp,sp,32
    8000163a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000163c:	8f99                	sub	a5,a5,a4
    8000163e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001640:	4685                	li	a3,1
    80001642:	0007861b          	sext.w	a2,a5
    80001646:	85ba                	mv	a1,a4
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	e5e080e7          	jalr	-418(ra) # 800014a6 <uvmunmap>
    80001650:	b7c5                	j	80001630 <uvmdealloc+0x26>

0000000080001652 <uvmalloc>:
  if(newsz < oldsz)
    80001652:	0ab66563          	bltu	a2,a1,800016fc <uvmalloc+0xaa>
{
    80001656:	7139                	addi	sp,sp,-64
    80001658:	fc06                	sd	ra,56(sp)
    8000165a:	f822                	sd	s0,48(sp)
    8000165c:	f426                	sd	s1,40(sp)
    8000165e:	f04a                	sd	s2,32(sp)
    80001660:	ec4e                	sd	s3,24(sp)
    80001662:	e852                	sd	s4,16(sp)
    80001664:	e456                	sd	s5,8(sp)
    80001666:	e05a                	sd	s6,0(sp)
    80001668:	0080                	addi	s0,sp,64
    8000166a:	8aaa                	mv	s5,a0
    8000166c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000166e:	6785                	lui	a5,0x1
    80001670:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001672:	95be                	add	a1,a1,a5
    80001674:	77fd                	lui	a5,0xfffff
    80001676:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000167a:	08c9f363          	bgeu	s3,a2,80001700 <uvmalloc+0xae>
    8000167e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001680:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	5b4080e7          	jalr	1460(ra) # 80000c38 <kalloc>
    8000168c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000168e:	c51d                	beqz	a0,800016bc <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001690:	6605                	lui	a2,0x1
    80001692:	4581                	li	a1,0
    80001694:	00000097          	auipc	ra,0x0
    80001698:	882080e7          	jalr	-1918(ra) # 80000f16 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000169c:	875a                	mv	a4,s6
    8000169e:	86a6                	mv	a3,s1
    800016a0:	6605                	lui	a2,0x1
    800016a2:	85ca                	mv	a1,s2
    800016a4:	8556                	mv	a0,s5
    800016a6:	00000097          	auipc	ra,0x0
    800016aa:	c3a080e7          	jalr	-966(ra) # 800012e0 <mappages>
    800016ae:	e90d                	bnez	a0,800016e0 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800016b0:	6785                	lui	a5,0x1
    800016b2:	993e                	add	s2,s2,a5
    800016b4:	fd4968e3          	bltu	s2,s4,80001684 <uvmalloc+0x32>
  return newsz;
    800016b8:	8552                	mv	a0,s4
    800016ba:	a809                	j	800016cc <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800016bc:	864e                	mv	a2,s3
    800016be:	85ca                	mv	a1,s2
    800016c0:	8556                	mv	a0,s5
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	f48080e7          	jalr	-184(ra) # 8000160a <uvmdealloc>
      return 0;
    800016ca:	4501                	li	a0,0
}
    800016cc:	70e2                	ld	ra,56(sp)
    800016ce:	7442                	ld	s0,48(sp)
    800016d0:	74a2                	ld	s1,40(sp)
    800016d2:	7902                	ld	s2,32(sp)
    800016d4:	69e2                	ld	s3,24(sp)
    800016d6:	6a42                	ld	s4,16(sp)
    800016d8:	6aa2                	ld	s5,8(sp)
    800016da:	6b02                	ld	s6,0(sp)
    800016dc:	6121                	addi	sp,sp,64
    800016de:	8082                	ret
      kfree(mem);
    800016e0:	8526                	mv	a0,s1
    800016e2:	fffff097          	auipc	ra,0xfffff
    800016e6:	302080e7          	jalr	770(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016ea:	864e                	mv	a2,s3
    800016ec:	85ca                	mv	a1,s2
    800016ee:	8556                	mv	a0,s5
    800016f0:	00000097          	auipc	ra,0x0
    800016f4:	f1a080e7          	jalr	-230(ra) # 8000160a <uvmdealloc>
      return 0;
    800016f8:	4501                	li	a0,0
    800016fa:	bfc9                	j	800016cc <uvmalloc+0x7a>
    return oldsz;
    800016fc:	852e                	mv	a0,a1
}
    800016fe:	8082                	ret
  return newsz;
    80001700:	8532                	mv	a0,a2
    80001702:	b7e9                	j	800016cc <uvmalloc+0x7a>

0000000080001704 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001704:	7179                	addi	sp,sp,-48
    80001706:	f406                	sd	ra,40(sp)
    80001708:	f022                	sd	s0,32(sp)
    8000170a:	ec26                	sd	s1,24(sp)
    8000170c:	e84a                	sd	s2,16(sp)
    8000170e:	e44e                	sd	s3,8(sp)
    80001710:	e052                	sd	s4,0(sp)
    80001712:	1800                	addi	s0,sp,48
    80001714:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001716:	84aa                	mv	s1,a0
    80001718:	6905                	lui	s2,0x1
    8000171a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000171c:	4985                	li	s3,1
    8000171e:	a829                	j	80001738 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001720:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001722:	00c79513          	slli	a0,a5,0xc
    80001726:	00000097          	auipc	ra,0x0
    8000172a:	fde080e7          	jalr	-34(ra) # 80001704 <freewalk>
      pagetable[i] = 0;
    8000172e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001732:	04a1                	addi	s1,s1,8
    80001734:	03248163          	beq	s1,s2,80001756 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001738:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000173a:	00f7f713          	andi	a4,a5,15
    8000173e:	ff3701e3          	beq	a4,s3,80001720 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001742:	8b85                	andi	a5,a5,1
    80001744:	d7fd                	beqz	a5,80001732 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001746:	00007517          	auipc	a0,0x7
    8000174a:	a9250513          	addi	a0,a0,-1390 # 800081d8 <digits+0x198>
    8000174e:	fffff097          	auipc	ra,0xfffff
    80001752:	dee080e7          	jalr	-530(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    80001756:	8552                	mv	a0,s4
    80001758:	fffff097          	auipc	ra,0xfffff
    8000175c:	28c080e7          	jalr	652(ra) # 800009e4 <kfree>
}
    80001760:	70a2                	ld	ra,40(sp)
    80001762:	7402                	ld	s0,32(sp)
    80001764:	64e2                	ld	s1,24(sp)
    80001766:	6942                	ld	s2,16(sp)
    80001768:	69a2                	ld	s3,8(sp)
    8000176a:	6a02                	ld	s4,0(sp)
    8000176c:	6145                	addi	sp,sp,48
    8000176e:	8082                	ret

0000000080001770 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001770:	1101                	addi	sp,sp,-32
    80001772:	ec06                	sd	ra,24(sp)
    80001774:	e822                	sd	s0,16(sp)
    80001776:	e426                	sd	s1,8(sp)
    80001778:	1000                	addi	s0,sp,32
    8000177a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000177c:	e999                	bnez	a1,80001792 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000177e:	8526                	mv	a0,s1
    80001780:	00000097          	auipc	ra,0x0
    80001784:	f84080e7          	jalr	-124(ra) # 80001704 <freewalk>
}
    80001788:	60e2                	ld	ra,24(sp)
    8000178a:	6442                	ld	s0,16(sp)
    8000178c:	64a2                	ld	s1,8(sp)
    8000178e:	6105                	addi	sp,sp,32
    80001790:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001792:	6785                	lui	a5,0x1
    80001794:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001796:	95be                	add	a1,a1,a5
    80001798:	4685                	li	a3,1
    8000179a:	00c5d613          	srli	a2,a1,0xc
    8000179e:	4581                	li	a1,0
    800017a0:	00000097          	auipc	ra,0x0
    800017a4:	d06080e7          	jalr	-762(ra) # 800014a6 <uvmunmap>
    800017a8:	bfd9                	j	8000177e <uvmfree+0xe>

00000000800017aa <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    800017aa:	715d                	addi	sp,sp,-80
    800017ac:	e486                	sd	ra,72(sp)
    800017ae:	e0a2                	sd	s0,64(sp)
    800017b0:	fc26                	sd	s1,56(sp)
    800017b2:	f84a                	sd	s2,48(sp)
    800017b4:	f44e                	sd	s3,40(sp)
    800017b6:	f052                	sd	s4,32(sp)
    800017b8:	ec56                	sd	s5,24(sp)
    800017ba:	e85a                	sd	s6,16(sp)
    800017bc:	e45e                	sd	s7,8(sp)
    800017be:	0880                	addi	s0,sp,80
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    800017c0:	c269                	beqz	a2,80001882 <uvmcopy+0xd8>
    800017c2:	8aaa                	mv	s5,a0
    800017c4:	8a2e                	mv	s4,a1
    800017c6:	89b2                	mv	s3,a2
    800017c8:	4481                	li	s1,0
    //   goto err;
    // }
    if(flags & PTE_W)
    {
      flags = (flags&(~PTE_W)) | PTE_C;
      *pte = PA2PTE(pa) | flags ;
    800017ca:	7b7d                	lui	s6,0xfffff
    800017cc:	002b5b13          	srli	s6,s6,0x2
    800017d0:	a8a1                	j	80001828 <uvmcopy+0x7e>
      panic("uvmcopy: pte should exist");
    800017d2:	00007517          	auipc	a0,0x7
    800017d6:	a1650513          	addi	a0,a0,-1514 # 800081e8 <digits+0x1a8>
    800017da:	fffff097          	auipc	ra,0xfffff
    800017de:	d62080e7          	jalr	-670(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800017e2:	00007517          	auipc	a0,0x7
    800017e6:	a2650513          	addi	a0,a0,-1498 # 80008208 <digits+0x1c8>
    800017ea:	fffff097          	auipc	ra,0xfffff
    800017ee:	d52080e7          	jalr	-686(ra) # 8000053c <panic>
      flags = (flags&(~PTE_W)) | PTE_C;
    800017f2:	2fb77693          	andi	a3,a4,763
    800017f6:	1006e713          	ori	a4,a3,256
      *pte = PA2PTE(pa) | flags ;
    800017fa:	0167f7b3          	and	a5,a5,s6
    800017fe:	8fd9                	or	a5,a5,a4
    80001800:	e11c                	sd	a5,0(a0)
    }

    if(mappages(new,i,PGSIZE,pa,flags) != 0)
    80001802:	86ca                	mv	a3,s2
    80001804:	6605                	lui	a2,0x1
    80001806:	85a6                	mv	a1,s1
    80001808:	8552                	mv	a0,s4
    8000180a:	00000097          	auipc	ra,0x0
    8000180e:	ad6080e7          	jalr	-1322(ra) # 800012e0 <mappages>
    80001812:	8baa                	mv	s7,a0
    80001814:	e129                	bnez	a0,80001856 <uvmcopy+0xac>
    {
      goto err;
    }

    safe_increment_references((void*)pa);
    80001816:	854a                	mv	a0,s2
    80001818:	fffff097          	auipc	ra,0xfffff
    8000181c:	316080e7          	jalr	790(ra) # 80000b2e <safe_increment_references>
  for(i = 0; i < sz; i += PGSIZE){
    80001820:	6785                	lui	a5,0x1
    80001822:	94be                	add	s1,s1,a5
    80001824:	0534f363          	bgeu	s1,s3,8000186a <uvmcopy+0xc0>
    if((pte = walk(old, i, 0)) == 0)
    80001828:	4601                	li	a2,0
    8000182a:	85a6                	mv	a1,s1
    8000182c:	8556                	mv	a0,s5
    8000182e:	00000097          	auipc	ra,0x0
    80001832:	9ca080e7          	jalr	-1590(ra) # 800011f8 <walk>
    80001836:	dd51                	beqz	a0,800017d2 <uvmcopy+0x28>
    if((*pte & PTE_V) == 0)
    80001838:	611c                	ld	a5,0(a0)
    8000183a:	0017f713          	andi	a4,a5,1
    8000183e:	d355                	beqz	a4,800017e2 <uvmcopy+0x38>
    pa = PTE2PA(*pte);
    80001840:	00a7d913          	srli	s2,a5,0xa
    80001844:	0932                	slli	s2,s2,0xc
    flags = PTE_FLAGS(*pte);
    80001846:	0007871b          	sext.w	a4,a5
    if(flags & PTE_W)
    8000184a:	0047f693          	andi	a3,a5,4
    8000184e:	f2d5                	bnez	a3,800017f2 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    80001850:	3ff77713          	andi	a4,a4,1023
    80001854:	b77d                	j	80001802 <uvmcopy+0x58>
    
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001856:	4685                	li	a3,1
    80001858:	00c4d613          	srli	a2,s1,0xc
    8000185c:	4581                	li	a1,0
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	c46080e7          	jalr	-954(ra) # 800014a6 <uvmunmap>
  return -1;
    80001868:	5bfd                	li	s7,-1
}
    8000186a:	855e                	mv	a0,s7
    8000186c:	60a6                	ld	ra,72(sp)
    8000186e:	6406                	ld	s0,64(sp)
    80001870:	74e2                	ld	s1,56(sp)
    80001872:	7942                	ld	s2,48(sp)
    80001874:	79a2                	ld	s3,40(sp)
    80001876:	7a02                	ld	s4,32(sp)
    80001878:	6ae2                	ld	s5,24(sp)
    8000187a:	6b42                	ld	s6,16(sp)
    8000187c:	6ba2                	ld	s7,8(sp)
    8000187e:	6161                	addi	sp,sp,80
    80001880:	8082                	ret
  return 0;
    80001882:	4b81                	li	s7,0
    80001884:	b7dd                	j	8000186a <uvmcopy+0xc0>

0000000080001886 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001886:	1141                	addi	sp,sp,-16
    80001888:	e406                	sd	ra,8(sp)
    8000188a:	e022                	sd	s0,0(sp)
    8000188c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000188e:	4601                	li	a2,0
    80001890:	00000097          	auipc	ra,0x0
    80001894:	968080e7          	jalr	-1688(ra) # 800011f8 <walk>
  if(pte == 0)
    80001898:	c901                	beqz	a0,800018a8 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000189a:	611c                	ld	a5,0(a0)
    8000189c:	9bbd                	andi	a5,a5,-17
    8000189e:	e11c                	sd	a5,0(a0)
}
    800018a0:	60a2                	ld	ra,8(sp)
    800018a2:	6402                	ld	s0,0(sp)
    800018a4:	0141                	addi	sp,sp,16
    800018a6:	8082                	ret
    panic("uvmclear");
    800018a8:	00007517          	auipc	a0,0x7
    800018ac:	98050513          	addi	a0,a0,-1664 # 80008228 <digits+0x1e8>
    800018b0:	fffff097          	auipc	ra,0xfffff
    800018b4:	c8c080e7          	jalr	-884(ra) # 8000053c <panic>

00000000800018b8 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0,flags;
  pte_t *pte;

  while(len > 0){
    800018b8:	c2d5                	beqz	a3,8000195c <copyout+0xa4>
{
    800018ba:	711d                	addi	sp,sp,-96
    800018bc:	ec86                	sd	ra,88(sp)
    800018be:	e8a2                	sd	s0,80(sp)
    800018c0:	e4a6                	sd	s1,72(sp)
    800018c2:	e0ca                	sd	s2,64(sp)
    800018c4:	fc4e                	sd	s3,56(sp)
    800018c6:	f852                	sd	s4,48(sp)
    800018c8:	f456                	sd	s5,40(sp)
    800018ca:	f05a                	sd	s6,32(sp)
    800018cc:	ec5e                	sd	s7,24(sp)
    800018ce:	e862                	sd	s8,16(sp)
    800018d0:	e466                	sd	s9,8(sp)
    800018d2:	1080                	addi	s0,sp,96
    800018d4:	8baa                	mv	s7,a0
    800018d6:	89ae                	mv	s3,a1
    800018d8:	8b32                	mv	s6,a2
    800018da:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800018dc:	7cfd                	lui	s9,0xfffff
    if(flags & PTE_C)
    {
      pagefaulthandler((void*)va0,pagetable);
      pa0 = walkaddr(pagetable,va0);
    }  
    n = PGSIZE - (dstva - va0);
    800018de:	6c05                	lui	s8,0x1
    800018e0:	a081                	j	80001920 <copyout+0x68>
      pagefaulthandler((void*)va0,pagetable);
    800018e2:	85de                	mv	a1,s7
    800018e4:	854a                	mv	a0,s2
    800018e6:	00002097          	auipc	ra,0x2
    800018ea:	8d4080e7          	jalr	-1836(ra) # 800031ba <pagefaulthandler>
      pa0 = walkaddr(pagetable,va0);
    800018ee:	85ca                	mv	a1,s2
    800018f0:	855e                	mv	a0,s7
    800018f2:	00000097          	auipc	ra,0x0
    800018f6:	9ac080e7          	jalr	-1620(ra) # 8000129e <walkaddr>
    800018fa:	8a2a                	mv	s4,a0
    800018fc:	a0b9                	j	8000194a <copyout+0x92>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800018fe:	41298533          	sub	a0,s3,s2
    80001902:	0004861b          	sext.w	a2,s1
    80001906:	85da                	mv	a1,s6
    80001908:	9552                	add	a0,a0,s4
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	668080e7          	jalr	1640(ra) # 80000f72 <memmove>

    len -= n;
    80001912:	409a8ab3          	sub	s5,s5,s1
    src += n;
    80001916:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    80001918:	018909b3          	add	s3,s2,s8
  while(len > 0){
    8000191c:	020a8e63          	beqz	s5,80001958 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    80001920:	0199f933          	and	s2,s3,s9
    pa0 = walkaddr(pagetable, va0);
    80001924:	85ca                	mv	a1,s2
    80001926:	855e                	mv	a0,s7
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	976080e7          	jalr	-1674(ra) # 8000129e <walkaddr>
    80001930:	8a2a                	mv	s4,a0
    if(pa0 == 0)
    80001932:	c51d                	beqz	a0,80001960 <copyout+0xa8>
    pte = walk(pagetable,va0,0);
    80001934:	4601                	li	a2,0
    80001936:	85ca                	mv	a1,s2
    80001938:	855e                	mv	a0,s7
    8000193a:	00000097          	auipc	ra,0x0
    8000193e:	8be080e7          	jalr	-1858(ra) # 800011f8 <walk>
    if(flags & PTE_C)
    80001942:	611c                	ld	a5,0(a0)
    80001944:	1007f793          	andi	a5,a5,256
    80001948:	ffc9                	bnez	a5,800018e2 <copyout+0x2a>
    n = PGSIZE - (dstva - va0);
    8000194a:	413904b3          	sub	s1,s2,s3
    8000194e:	94e2                	add	s1,s1,s8
    80001950:	fa9af7e3          	bgeu	s5,s1,800018fe <copyout+0x46>
    80001954:	84d6                	mv	s1,s5
    80001956:	b765                	j	800018fe <copyout+0x46>
  }
  return 0;
    80001958:	4501                	li	a0,0
    8000195a:	a021                	j	80001962 <copyout+0xaa>
    8000195c:	4501                	li	a0,0
}
    8000195e:	8082                	ret
      return -1;  
    80001960:	557d                	li	a0,-1
}
    80001962:	60e6                	ld	ra,88(sp)
    80001964:	6446                	ld	s0,80(sp)
    80001966:	64a6                	ld	s1,72(sp)
    80001968:	6906                	ld	s2,64(sp)
    8000196a:	79e2                	ld	s3,56(sp)
    8000196c:	7a42                	ld	s4,48(sp)
    8000196e:	7aa2                	ld	s5,40(sp)
    80001970:	7b02                	ld	s6,32(sp)
    80001972:	6be2                	ld	s7,24(sp)
    80001974:	6c42                	ld	s8,16(sp)
    80001976:	6ca2                	ld	s9,8(sp)
    80001978:	6125                	addi	sp,sp,96
    8000197a:	8082                	ret

000000008000197c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000197c:	caa5                	beqz	a3,800019ec <copyin+0x70>
{
    8000197e:	715d                	addi	sp,sp,-80
    80001980:	e486                	sd	ra,72(sp)
    80001982:	e0a2                	sd	s0,64(sp)
    80001984:	fc26                	sd	s1,56(sp)
    80001986:	f84a                	sd	s2,48(sp)
    80001988:	f44e                	sd	s3,40(sp)
    8000198a:	f052                	sd	s4,32(sp)
    8000198c:	ec56                	sd	s5,24(sp)
    8000198e:	e85a                	sd	s6,16(sp)
    80001990:	e45e                	sd	s7,8(sp)
    80001992:	e062                	sd	s8,0(sp)
    80001994:	0880                	addi	s0,sp,80
    80001996:	8b2a                	mv	s6,a0
    80001998:	8a2e                	mv	s4,a1
    8000199a:	8c32                	mv	s8,a2
    8000199c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000199e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800019a0:	6a85                	lui	s5,0x1
    800019a2:	a01d                	j	800019c8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800019a4:	018505b3          	add	a1,a0,s8
    800019a8:	0004861b          	sext.w	a2,s1
    800019ac:	412585b3          	sub	a1,a1,s2
    800019b0:	8552                	mv	a0,s4
    800019b2:	fffff097          	auipc	ra,0xfffff
    800019b6:	5c0080e7          	jalr	1472(ra) # 80000f72 <memmove>

    len -= n;
    800019ba:	409989b3          	sub	s3,s3,s1
    dst += n;
    800019be:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800019c0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800019c4:	02098263          	beqz	s3,800019e8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800019c8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800019cc:	85ca                	mv	a1,s2
    800019ce:	855a                	mv	a0,s6
    800019d0:	00000097          	auipc	ra,0x0
    800019d4:	8ce080e7          	jalr	-1842(ra) # 8000129e <walkaddr>
    if(pa0 == 0)
    800019d8:	cd01                	beqz	a0,800019f0 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800019da:	418904b3          	sub	s1,s2,s8
    800019de:	94d6                	add	s1,s1,s5
    800019e0:	fc99f2e3          	bgeu	s3,s1,800019a4 <copyin+0x28>
    800019e4:	84ce                	mv	s1,s3
    800019e6:	bf7d                	j	800019a4 <copyin+0x28>
  }
  return 0;
    800019e8:	4501                	li	a0,0
    800019ea:	a021                	j	800019f2 <copyin+0x76>
    800019ec:	4501                	li	a0,0
}
    800019ee:	8082                	ret
      return -1;
    800019f0:	557d                	li	a0,-1
}
    800019f2:	60a6                	ld	ra,72(sp)
    800019f4:	6406                	ld	s0,64(sp)
    800019f6:	74e2                	ld	s1,56(sp)
    800019f8:	7942                	ld	s2,48(sp)
    800019fa:	79a2                	ld	s3,40(sp)
    800019fc:	7a02                	ld	s4,32(sp)
    800019fe:	6ae2                	ld	s5,24(sp)
    80001a00:	6b42                	ld	s6,16(sp)
    80001a02:	6ba2                	ld	s7,8(sp)
    80001a04:	6c02                	ld	s8,0(sp)
    80001a06:	6161                	addi	sp,sp,80
    80001a08:	8082                	ret

0000000080001a0a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001a0a:	c2dd                	beqz	a3,80001ab0 <copyinstr+0xa6>
{
    80001a0c:	715d                	addi	sp,sp,-80
    80001a0e:	e486                	sd	ra,72(sp)
    80001a10:	e0a2                	sd	s0,64(sp)
    80001a12:	fc26                	sd	s1,56(sp)
    80001a14:	f84a                	sd	s2,48(sp)
    80001a16:	f44e                	sd	s3,40(sp)
    80001a18:	f052                	sd	s4,32(sp)
    80001a1a:	ec56                	sd	s5,24(sp)
    80001a1c:	e85a                	sd	s6,16(sp)
    80001a1e:	e45e                	sd	s7,8(sp)
    80001a20:	0880                	addi	s0,sp,80
    80001a22:	8a2a                	mv	s4,a0
    80001a24:	8b2e                	mv	s6,a1
    80001a26:	8bb2                	mv	s7,a2
    80001a28:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001a2a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a2c:	6985                	lui	s3,0x1
    80001a2e:	a02d                	j	80001a58 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001a30:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001a34:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001a36:	37fd                	addiw	a5,a5,-1
    80001a38:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001a3c:	60a6                	ld	ra,72(sp)
    80001a3e:	6406                	ld	s0,64(sp)
    80001a40:	74e2                	ld	s1,56(sp)
    80001a42:	7942                	ld	s2,48(sp)
    80001a44:	79a2                	ld	s3,40(sp)
    80001a46:	7a02                	ld	s4,32(sp)
    80001a48:	6ae2                	ld	s5,24(sp)
    80001a4a:	6b42                	ld	s6,16(sp)
    80001a4c:	6ba2                	ld	s7,8(sp)
    80001a4e:	6161                	addi	sp,sp,80
    80001a50:	8082                	ret
    srcva = va0 + PGSIZE;
    80001a52:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001a56:	c8a9                	beqz	s1,80001aa8 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001a58:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001a5c:	85ca                	mv	a1,s2
    80001a5e:	8552                	mv	a0,s4
    80001a60:	00000097          	auipc	ra,0x0
    80001a64:	83e080e7          	jalr	-1986(ra) # 8000129e <walkaddr>
    if(pa0 == 0)
    80001a68:	c131                	beqz	a0,80001aac <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001a6a:	417906b3          	sub	a3,s2,s7
    80001a6e:	96ce                	add	a3,a3,s3
    80001a70:	00d4f363          	bgeu	s1,a3,80001a76 <copyinstr+0x6c>
    80001a74:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001a76:	955e                	add	a0,a0,s7
    80001a78:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001a7c:	daf9                	beqz	a3,80001a52 <copyinstr+0x48>
    80001a7e:	87da                	mv	a5,s6
    80001a80:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001a82:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001a86:	96da                	add	a3,a3,s6
    80001a88:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001a8a:	00f60733          	add	a4,a2,a5
    80001a8e:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fdb67d8>
    80001a92:	df59                	beqz	a4,80001a30 <copyinstr+0x26>
        *dst = *p;
    80001a94:	00e78023          	sb	a4,0(a5)
      dst++;
    80001a98:	0785                	addi	a5,a5,1
    while(n > 0){
    80001a9a:	fed797e3          	bne	a5,a3,80001a88 <copyinstr+0x7e>
    80001a9e:	14fd                	addi	s1,s1,-1
    80001aa0:	94c2                	add	s1,s1,a6
      --max;
    80001aa2:	8c8d                	sub	s1,s1,a1
      dst++;
    80001aa4:	8b3e                	mv	s6,a5
    80001aa6:	b775                	j	80001a52 <copyinstr+0x48>
    80001aa8:	4781                	li	a5,0
    80001aaa:	b771                	j	80001a36 <copyinstr+0x2c>
      return -1;
    80001aac:	557d                	li	a0,-1
    80001aae:	b779                	j	80001a3c <copyinstr+0x32>
  int got_null = 0;
    80001ab0:	4781                	li	a5,0
  if(got_null){
    80001ab2:	37fd                	addiw	a5,a5,-1
    80001ab4:	0007851b          	sext.w	a0,a5
}
    80001ab8:	8082                	ret

0000000080001aba <rand_ret>:
// Map it high in memory, followed by an invalid
// guard page.

static uint rand_table[1000];
void rand_ret(int n)
{
    80001aba:	1141                	addi	sp,sp,-16
    80001abc:	e422                	sd	s0,8(sp)
    80001abe:	0800                	addi	s0,sp,16

  rand_table[0] = n * (PHI + 1);
    80001ac0:	0022f717          	auipc	a4,0x22f
    80001ac4:	7e870713          	addi	a4,a4,2024 # 802312a8 <rand_table>
    80001ac8:	9e3787b7          	lui	a5,0x9e378
    80001acc:	9ba7869b          	addiw	a3,a5,-1606 # ffffffff9e3779ba <end+0xffffffff1e12f192>
    80001ad0:	02d506bb          	mulw	a3,a0,a3
    80001ad4:	c314                	sw	a3,0(a4)
  rand_table[1] = n * (PHI + 2);
    80001ad6:	9bb7869b          	addiw	a3,a5,-1605
    80001ada:	02d506bb          	mulw	a3,a0,a3
    80001ade:	c354                	sw	a3,4(a4)
  rand_table[2] = n * (PHI + 3);
    80001ae0:	9bc7879b          	addiw	a5,a5,-1604
    80001ae4:	02f5053b          	mulw	a0,a0,a5
    80001ae8:	c708                	sw	a0,8(a4)

  for (int i = 3; i < 1000; ++i)
    80001aea:	0022f717          	auipc	a4,0x22f
    80001aee:	7c270713          	addi	a4,a4,1986 # 802312ac <rand_table+0x4>
    80001af2:	468d                	li	a3,3
  {
    rand_table[i] = rand_table[i - 1] ^ rand_table[i - 2] ^ i ^ PHI;
    80001af4:	9e3785b7          	lui	a1,0x9e378
    80001af8:	9b958593          	addi	a1,a1,-1607 # ffffffff9e3779b9 <end+0xffffffff1e12f191>
  for (int i = 3; i < 1000; ++i)
    80001afc:	3e800513          	li	a0,1000
    rand_table[i] = rand_table[i - 1] ^ rand_table[i - 2] ^ i ^ PHI;
    80001b00:	435c                	lw	a5,4(a4)
    80001b02:	8fb5                	xor	a5,a5,a3
    80001b04:	4310                	lw	a2,0(a4)
    80001b06:	8fb1                	xor	a5,a5,a2
    80001b08:	8fad                	xor	a5,a5,a1
    80001b0a:	c71c                	sw	a5,8(a4)
  for (int i = 3; i < 1000; ++i)
    80001b0c:	2685                	addiw	a3,a3,1 # fffffffffffff001 <end+0xffffffff7fdb67d9>
    80001b0e:	0711                	addi	a4,a4,4
    80001b10:	fea698e3          	bne	a3,a0,80001b00 <rand_ret+0x46>
  }
}
    80001b14:	6422                	ld	s0,8(sp)
    80001b16:	0141                	addi	sp,sp,16
    80001b18:	8082                	ret

0000000080001b1a <proc_mapstacks>:

void proc_mapstacks(pagetable_t kpgtbl)
{
    80001b1a:	7139                	addi	sp,sp,-64
    80001b1c:	fc06                	sd	ra,56(sp)
    80001b1e:	f822                	sd	s0,48(sp)
    80001b20:	f426                	sd	s1,40(sp)
    80001b22:	f04a                	sd	s2,32(sp)
    80001b24:	ec4e                	sd	s3,24(sp)
    80001b26:	e852                	sd	s4,16(sp)
    80001b28:	e456                	sd	s5,8(sp)
    80001b2a:	e05a                	sd	s6,0(sp)
    80001b2c:	0080                	addi	s0,sp,64
    80001b2e:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001b30:	00230497          	auipc	s1,0x230
    80001b34:	71848493          	addi	s1,s1,1816 # 80232248 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001b38:	8b26                	mv	s6,s1
    80001b3a:	00006a97          	auipc	s5,0x6
    80001b3e:	4c6a8a93          	addi	s5,s5,1222 # 80008000 <etext>
    80001b42:	04000937          	lui	s2,0x4000
    80001b46:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b48:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001b4a:	0023ca17          	auipc	s4,0x23c
    80001b4e:	8fea0a13          	addi	s4,s4,-1794 # 8023d448 <tickslock>
    char *pa = kalloc();
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	0e6080e7          	jalr	230(ra) # 80000c38 <kalloc>
    80001b5a:	862a                	mv	a2,a0
    if (pa == 0)
    80001b5c:	c131                	beqz	a0,80001ba0 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001b5e:	416485b3          	sub	a1,s1,s6
    80001b62:	858d                	srai	a1,a1,0x3
    80001b64:	000ab783          	ld	a5,0(s5)
    80001b68:	02f585b3          	mul	a1,a1,a5
    80001b6c:	2585                	addiw	a1,a1,1
    80001b6e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b72:	4719                	li	a4,6
    80001b74:	6685                	lui	a3,0x1
    80001b76:	40b905b3          	sub	a1,s2,a1
    80001b7a:	854e                	mv	a0,s3
    80001b7c:	00000097          	auipc	ra,0x0
    80001b80:	804080e7          	jalr	-2044(ra) # 80001380 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001b84:	2c848493          	addi	s1,s1,712
    80001b88:	fd4495e3          	bne	s1,s4,80001b52 <proc_mapstacks+0x38>
  }
}
    80001b8c:	70e2                	ld	ra,56(sp)
    80001b8e:	7442                	ld	s0,48(sp)
    80001b90:	74a2                	ld	s1,40(sp)
    80001b92:	7902                	ld	s2,32(sp)
    80001b94:	69e2                	ld	s3,24(sp)
    80001b96:	6a42                	ld	s4,16(sp)
    80001b98:	6aa2                	ld	s5,8(sp)
    80001b9a:	6b02                	ld	s6,0(sp)
    80001b9c:	6121                	addi	sp,sp,64
    80001b9e:	8082                	ret
      panic("kalloc");
    80001ba0:	00006517          	auipc	a0,0x6
    80001ba4:	69850513          	addi	a0,a0,1688 # 80008238 <digits+0x1f8>
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	994080e7          	jalr	-1644(ra) # 8000053c <panic>

0000000080001bb0 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001bb0:	7139                	addi	sp,sp,-64
    80001bb2:	fc06                	sd	ra,56(sp)
    80001bb4:	f822                	sd	s0,48(sp)
    80001bb6:	f426                	sd	s1,40(sp)
    80001bb8:	f04a                	sd	s2,32(sp)
    80001bba:	ec4e                	sd	s3,24(sp)
    80001bbc:	e852                	sd	s4,16(sp)
    80001bbe:	e456                	sd	s5,8(sp)
    80001bc0:	e05a                	sd	s6,0(sp)
    80001bc2:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001bc4:	00006597          	auipc	a1,0x6
    80001bc8:	67c58593          	addi	a1,a1,1660 # 80008240 <digits+0x200>
    80001bcc:	0022f517          	auipc	a0,0x22f
    80001bd0:	2ac50513          	addi	a0,a0,684 # 80230e78 <pid_lock>
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	1b6080e7          	jalr	438(ra) # 80000d8a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001bdc:	00006597          	auipc	a1,0x6
    80001be0:	66c58593          	addi	a1,a1,1644 # 80008248 <digits+0x208>
    80001be4:	0022f517          	auipc	a0,0x22f
    80001be8:	2ac50513          	addi	a0,a0,684 # 80230e90 <wait_lock>
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	19e080e7          	jalr	414(ra) # 80000d8a <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bf4:	00230497          	auipc	s1,0x230
    80001bf8:	65448493          	addi	s1,s1,1620 # 80232248 <proc>
  {
    initlock(&p->lock, "proc");
    80001bfc:	00006b17          	auipc	s6,0x6
    80001c00:	65cb0b13          	addi	s6,s6,1628 # 80008258 <digits+0x218>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001c04:	8aa6                	mv	s5,s1
    80001c06:	00006a17          	auipc	s4,0x6
    80001c0a:	3faa0a13          	addi	s4,s4,1018 # 80008000 <etext>
    80001c0e:	04000937          	lui	s2,0x4000
    80001c12:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001c14:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001c16:	0023c997          	auipc	s3,0x23c
    80001c1a:	83298993          	addi	s3,s3,-1998 # 8023d448 <tickslock>
    initlock(&p->lock, "proc");
    80001c1e:	85da                	mv	a1,s6
    80001c20:	8526                	mv	a0,s1
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	168080e7          	jalr	360(ra) # 80000d8a <initlock>
    p->state = UNUSED;
    80001c2a:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001c2e:	415487b3          	sub	a5,s1,s5
    80001c32:	878d                	srai	a5,a5,0x3
    80001c34:	000a3703          	ld	a4,0(s4)
    80001c38:	02e787b3          	mul	a5,a5,a4
    80001c3c:	2785                	addiw	a5,a5,1
    80001c3e:	00d7979b          	slliw	a5,a5,0xd
    80001c42:	40f907b3          	sub	a5,s2,a5
    80001c46:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001c48:	2c848493          	addi	s1,s1,712
    80001c4c:	fd3499e3          	bne	s1,s3,80001c1e <procinit+0x6e>
  }
}
    80001c50:	70e2                	ld	ra,56(sp)
    80001c52:	7442                	ld	s0,48(sp)
    80001c54:	74a2                	ld	s1,40(sp)
    80001c56:	7902                	ld	s2,32(sp)
    80001c58:	69e2                	ld	s3,24(sp)
    80001c5a:	6a42                	ld	s4,16(sp)
    80001c5c:	6aa2                	ld	s5,8(sp)
    80001c5e:	6b02                	ld	s6,0(sp)
    80001c60:	6121                	addi	sp,sp,64
    80001c62:	8082                	ret

0000000080001c64 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001c64:	1141                	addi	sp,sp,-16
    80001c66:	e422                	sd	s0,8(sp)
    80001c68:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c6a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001c6c:	2501                	sext.w	a0,a0
    80001c6e:	6422                	ld	s0,8(sp)
    80001c70:	0141                	addi	sp,sp,16
    80001c72:	8082                	ret

0000000080001c74 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001c74:	1141                	addi	sp,sp,-16
    80001c76:	e422                	sd	s0,8(sp)
    80001c78:	0800                	addi	s0,sp,16
    80001c7a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001c7c:	2781                	sext.w	a5,a5
    80001c7e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001c80:	0022f517          	auipc	a0,0x22f
    80001c84:	22850513          	addi	a0,a0,552 # 80230ea8 <cpus>
    80001c88:	953e                	add	a0,a0,a5
    80001c8a:	6422                	ld	s0,8(sp)
    80001c8c:	0141                	addi	sp,sp,16
    80001c8e:	8082                	ret

0000000080001c90 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001c90:	1101                	addi	sp,sp,-32
    80001c92:	ec06                	sd	ra,24(sp)
    80001c94:	e822                	sd	s0,16(sp)
    80001c96:	e426                	sd	s1,8(sp)
    80001c98:	1000                	addi	s0,sp,32
  push_off();
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	134080e7          	jalr	308(ra) # 80000dce <push_off>
    80001ca2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001ca4:	2781                	sext.w	a5,a5
    80001ca6:	079e                	slli	a5,a5,0x7
    80001ca8:	0022f717          	auipc	a4,0x22f
    80001cac:	1d070713          	addi	a4,a4,464 # 80230e78 <pid_lock>
    80001cb0:	97ba                	add	a5,a5,a4
    80001cb2:	7b84                	ld	s1,48(a5)
  pop_off();
    80001cb4:	fffff097          	auipc	ra,0xfffff
    80001cb8:	1ba080e7          	jalr	442(ra) # 80000e6e <pop_off>
  return p;
}
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	60e2                	ld	ra,24(sp)
    80001cc0:	6442                	ld	s0,16(sp)
    80001cc2:	64a2                	ld	s1,8(sp)
    80001cc4:	6105                	addi	sp,sp,32
    80001cc6:	8082                	ret

0000000080001cc8 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001cc8:	1141                	addi	sp,sp,-16
    80001cca:	e406                	sd	ra,8(sp)
    80001ccc:	e022                	sd	s0,0(sp)
    80001cce:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001cd0:	00000097          	auipc	ra,0x0
    80001cd4:	fc0080e7          	jalr	-64(ra) # 80001c90 <myproc>
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	1f6080e7          	jalr	502(ra) # 80000ece <release>

  if (first)
    80001ce0:	00007797          	auipc	a5,0x7
    80001ce4:	e907a783          	lw	a5,-368(a5) # 80008b70 <first.1>
    80001ce8:	eb89                	bnez	a5,80001cfa <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001cea:	00001097          	auipc	ra,0x1
    80001cee:	27a080e7          	jalr	634(ra) # 80002f64 <usertrapret>
}
    80001cf2:	60a2                	ld	ra,8(sp)
    80001cf4:	6402                	ld	s0,0(sp)
    80001cf6:	0141                	addi	sp,sp,16
    80001cf8:	8082                	ret
    first = 0;
    80001cfa:	00007797          	auipc	a5,0x7
    80001cfe:	e607ab23          	sw	zero,-394(a5) # 80008b70 <first.1>
    fsinit(ROOTDEV);
    80001d02:	4505                	li	a0,1
    80001d04:	00002097          	auipc	ra,0x2
    80001d08:	3b0080e7          	jalr	944(ra) # 800040b4 <fsinit>
    80001d0c:	bff9                	j	80001cea <forkret+0x22>

0000000080001d0e <allocpid>:
{
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	e426                	sd	s1,8(sp)
    80001d16:	e04a                	sd	s2,0(sp)
    80001d18:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d1a:	0022f917          	auipc	s2,0x22f
    80001d1e:	15e90913          	addi	s2,s2,350 # 80230e78 <pid_lock>
    80001d22:	854a                	mv	a0,s2
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	0f6080e7          	jalr	246(ra) # 80000e1a <acquire>
  pid = nextpid;
    80001d2c:	00007797          	auipc	a5,0x7
    80001d30:	e4878793          	addi	a5,a5,-440 # 80008b74 <nextpid>
    80001d34:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d36:	0014871b          	addiw	a4,s1,1
    80001d3a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d3c:	854a                	mv	a0,s2
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	190080e7          	jalr	400(ra) # 80000ece <release>
}
    80001d46:	8526                	mv	a0,s1
    80001d48:	60e2                	ld	ra,24(sp)
    80001d4a:	6442                	ld	s0,16(sp)
    80001d4c:	64a2                	ld	s1,8(sp)
    80001d4e:	6902                	ld	s2,0(sp)
    80001d50:	6105                	addi	sp,sp,32
    80001d52:	8082                	ret

0000000080001d54 <proc_pagetable>:
{
    80001d54:	1101                	addi	sp,sp,-32
    80001d56:	ec06                	sd	ra,24(sp)
    80001d58:	e822                	sd	s0,16(sp)
    80001d5a:	e426                	sd	s1,8(sp)
    80001d5c:	e04a                	sd	s2,0(sp)
    80001d5e:	1000                	addi	s0,sp,32
    80001d60:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d62:	00000097          	auipc	ra,0x0
    80001d66:	808080e7          	jalr	-2040(ra) # 8000156a <uvmcreate>
    80001d6a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001d6c:	c121                	beqz	a0,80001dac <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d6e:	4729                	li	a4,10
    80001d70:	00005697          	auipc	a3,0x5
    80001d74:	29068693          	addi	a3,a3,656 # 80007000 <_trampoline>
    80001d78:	6605                	lui	a2,0x1
    80001d7a:	040005b7          	lui	a1,0x4000
    80001d7e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d80:	05b2                	slli	a1,a1,0xc
    80001d82:	fffff097          	auipc	ra,0xfffff
    80001d86:	55e080e7          	jalr	1374(ra) # 800012e0 <mappages>
    80001d8a:	02054863          	bltz	a0,80001dba <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d8e:	4719                	li	a4,6
    80001d90:	05893683          	ld	a3,88(s2)
    80001d94:	6605                	lui	a2,0x1
    80001d96:	020005b7          	lui	a1,0x2000
    80001d9a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d9c:	05b6                	slli	a1,a1,0xd
    80001d9e:	8526                	mv	a0,s1
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	540080e7          	jalr	1344(ra) # 800012e0 <mappages>
    80001da8:	02054163          	bltz	a0,80001dca <proc_pagetable+0x76>
}
    80001dac:	8526                	mv	a0,s1
    80001dae:	60e2                	ld	ra,24(sp)
    80001db0:	6442                	ld	s0,16(sp)
    80001db2:	64a2                	ld	s1,8(sp)
    80001db4:	6902                	ld	s2,0(sp)
    80001db6:	6105                	addi	sp,sp,32
    80001db8:	8082                	ret
    uvmfree(pagetable, 0);
    80001dba:	4581                	li	a1,0
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	00000097          	auipc	ra,0x0
    80001dc2:	9b2080e7          	jalr	-1614(ra) # 80001770 <uvmfree>
    return 0;
    80001dc6:	4481                	li	s1,0
    80001dc8:	b7d5                	j	80001dac <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dca:	4681                	li	a3,0
    80001dcc:	4605                	li	a2,1
    80001dce:	040005b7          	lui	a1,0x4000
    80001dd2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dd4:	05b2                	slli	a1,a1,0xc
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	6ce080e7          	jalr	1742(ra) # 800014a6 <uvmunmap>
    uvmfree(pagetable, 0);
    80001de0:	4581                	li	a1,0
    80001de2:	8526                	mv	a0,s1
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	98c080e7          	jalr	-1652(ra) # 80001770 <uvmfree>
    return 0;
    80001dec:	4481                	li	s1,0
    80001dee:	bf7d                	j	80001dac <proc_pagetable+0x58>

0000000080001df0 <proc_freepagetable>:
{
    80001df0:	1101                	addi	sp,sp,-32
    80001df2:	ec06                	sd	ra,24(sp)
    80001df4:	e822                	sd	s0,16(sp)
    80001df6:	e426                	sd	s1,8(sp)
    80001df8:	e04a                	sd	s2,0(sp)
    80001dfa:	1000                	addi	s0,sp,32
    80001dfc:	84aa                	mv	s1,a0
    80001dfe:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e00:	4681                	li	a3,0
    80001e02:	4605                	li	a2,1
    80001e04:	040005b7          	lui	a1,0x4000
    80001e08:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e0a:	05b2                	slli	a1,a1,0xc
    80001e0c:	fffff097          	auipc	ra,0xfffff
    80001e10:	69a080e7          	jalr	1690(ra) # 800014a6 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e14:	4681                	li	a3,0
    80001e16:	4605                	li	a2,1
    80001e18:	020005b7          	lui	a1,0x2000
    80001e1c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e1e:	05b6                	slli	a1,a1,0xd
    80001e20:	8526                	mv	a0,s1
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	684080e7          	jalr	1668(ra) # 800014a6 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e2a:	85ca                	mv	a1,s2
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	00000097          	auipc	ra,0x0
    80001e32:	942080e7          	jalr	-1726(ra) # 80001770 <uvmfree>
}
    80001e36:	60e2                	ld	ra,24(sp)
    80001e38:	6442                	ld	s0,16(sp)
    80001e3a:	64a2                	ld	s1,8(sp)
    80001e3c:	6902                	ld	s2,0(sp)
    80001e3e:	6105                	addi	sp,sp,32
    80001e40:	8082                	ret

0000000080001e42 <freeproc>:
{
    80001e42:	1101                	addi	sp,sp,-32
    80001e44:	ec06                	sd	ra,24(sp)
    80001e46:	e822                	sd	s0,16(sp)
    80001e48:	e426                	sd	s1,8(sp)
    80001e4a:	1000                	addi	s0,sp,32
    80001e4c:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001e4e:	6d28                	ld	a0,88(a0)
    80001e50:	c509                	beqz	a0,80001e5a <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001e52:	fffff097          	auipc	ra,0xfffff
    80001e56:	b92080e7          	jalr	-1134(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001e5a:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001e5e:	68a8                	ld	a0,80(s1)
    80001e60:	c511                	beqz	a0,80001e6c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e62:	64ac                	ld	a1,72(s1)
    80001e64:	00000097          	auipc	ra,0x0
    80001e68:	f8c080e7          	jalr	-116(ra) # 80001df0 <proc_freepagetable>
  p->pagetable = 0;
    80001e6c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e70:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e74:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001e78:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001e7c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e80:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e84:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e88:	0204a623          	sw	zero,44(s1)
  p->tickets = 1;
    80001e8c:	4785                	li	a5,1
    80001e8e:	2cf4a223          	sw	a5,708(s1)
  p->state = UNUSED;
    80001e92:	0004ac23          	sw	zero,24(s1)
  p->mask = 0;
    80001e96:	1604a423          	sw	zero,360(s1)
}
    80001e9a:	60e2                	ld	ra,24(sp)
    80001e9c:	6442                	ld	s0,16(sp)
    80001e9e:	64a2                	ld	s1,8(sp)
    80001ea0:	6105                	addi	sp,sp,32
    80001ea2:	8082                	ret

0000000080001ea4 <allocproc>:
{
    80001ea4:	1101                	addi	sp,sp,-32
    80001ea6:	ec06                	sd	ra,24(sp)
    80001ea8:	e822                	sd	s0,16(sp)
    80001eaa:	e426                	sd	s1,8(sp)
    80001eac:	e04a                	sd	s2,0(sp)
    80001eae:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001eb0:	00230497          	auipc	s1,0x230
    80001eb4:	39848493          	addi	s1,s1,920 # 80232248 <proc>
    80001eb8:	0023b917          	auipc	s2,0x23b
    80001ebc:	59090913          	addi	s2,s2,1424 # 8023d448 <tickslock>
    acquire(&p->lock);
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	f58080e7          	jalr	-168(ra) # 80000e1a <acquire>
    if (p->state == UNUSED)
    80001eca:	4c9c                	lw	a5,24(s1)
    80001ecc:	cf81                	beqz	a5,80001ee4 <allocproc+0x40>
      release(&p->lock);
    80001ece:	8526                	mv	a0,s1
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	ffe080e7          	jalr	-2(ra) # 80000ece <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ed8:	2c848493          	addi	s1,s1,712
    80001edc:	ff2492e3          	bne	s1,s2,80001ec0 <allocproc+0x1c>
  return 0;
    80001ee0:	4481                	li	s1,0
    80001ee2:	a071                	j	80001f6e <allocproc+0xca>
  p->pid = allocpid();
    80001ee4:	00000097          	auipc	ra,0x0
    80001ee8:	e2a080e7          	jalr	-470(ra) # 80001d0e <allocpid>
    80001eec:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001eee:	4785                	li	a5,1
    80001ef0:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	d46080e7          	jalr	-698(ra) # 80000c38 <kalloc>
    80001efa:	892a                	mv	s2,a0
    80001efc:	eca8                	sd	a0,88(s1)
    80001efe:	cd3d                	beqz	a0,80001f7c <allocproc+0xd8>
  p->pagetable = proc_pagetable(p);
    80001f00:	8526                	mv	a0,s1
    80001f02:	00000097          	auipc	ra,0x0
    80001f06:	e52080e7          	jalr	-430(ra) # 80001d54 <proc_pagetable>
    80001f0a:	892a                	mv	s2,a0
    80001f0c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001f0e:	c159                	beqz	a0,80001f94 <allocproc+0xf0>
  memset(&p->context, 0, sizeof(p->context));
    80001f10:	07000613          	li	a2,112
    80001f14:	4581                	li	a1,0
    80001f16:	06048513          	addi	a0,s1,96
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	ffc080e7          	jalr	-4(ra) # 80000f16 <memset>
  p->context.ra = (uint64)forkret;
    80001f22:	00000797          	auipc	a5,0x0
    80001f26:	da678793          	addi	a5,a5,-602 # 80001cc8 <forkret>
    80001f2a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f2c:	60bc                	ld	a5,64(s1)
    80001f2e:	6705                	lui	a4,0x1
    80001f30:	97ba                	add	a5,a5,a4
    80001f32:	f4bc                	sd	a5,104(s1)
  p->ticks = ticks;
    80001f34:	00007797          	auipc	a5,0x7
    80001f38:	cbc7a783          	lw	a5,-836(a5) # 80008bf0 <ticks>
    80001f3c:	16f4a623          	sw	a5,364(s1)
  p->elapsed_ticks = 0;
    80001f40:	1604a823          	sw	zero,368(s1)
  p->handler = 0;
    80001f44:	1604bc23          	sd	zero,376(s1)
  p->rtime = 0;
    80001f48:	2a04a423          	sw	zero,680(s1)
  p->etime = 0;
    80001f4c:	2a04a623          	sw	zero,684(s1)
  p->stime = 0;
    80001f50:	2a04ac23          	sw	zero,696(s1)
  p->trtime = 0;
    80001f54:	2a04aa23          	sw	zero,692(s1)
  p->runs = 0;
    80001f58:	2a04ae23          	sw	zero,700(s1)
  p->priority = 60;
    80001f5c:	03c00713          	li	a4,60
    80001f60:	2ce4a023          	sw	a4,704(s1)
  p->ctime = ticks;
    80001f64:	2af4a023          	sw	a5,672(s1)
  p->tickets = 1;
    80001f68:	4785                	li	a5,1
    80001f6a:	2cf4a223          	sw	a5,708(s1)
}
    80001f6e:	8526                	mv	a0,s1
    80001f70:	60e2                	ld	ra,24(sp)
    80001f72:	6442                	ld	s0,16(sp)
    80001f74:	64a2                	ld	s1,8(sp)
    80001f76:	6902                	ld	s2,0(sp)
    80001f78:	6105                	addi	sp,sp,32
    80001f7a:	8082                	ret
    freeproc(p);
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	00000097          	auipc	ra,0x0
    80001f82:	ec4080e7          	jalr	-316(ra) # 80001e42 <freeproc>
    release(&p->lock);
    80001f86:	8526                	mv	a0,s1
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	f46080e7          	jalr	-186(ra) # 80000ece <release>
    return 0;
    80001f90:	84ca                	mv	s1,s2
    80001f92:	bff1                	j	80001f6e <allocproc+0xca>
    freeproc(p);
    80001f94:	8526                	mv	a0,s1
    80001f96:	00000097          	auipc	ra,0x0
    80001f9a:	eac080e7          	jalr	-340(ra) # 80001e42 <freeproc>
    release(&p->lock);
    80001f9e:	8526                	mv	a0,s1
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	f2e080e7          	jalr	-210(ra) # 80000ece <release>
    return 0;
    80001fa8:	84ca                	mv	s1,s2
    80001faa:	b7d1                	j	80001f6e <allocproc+0xca>

0000000080001fac <userinit>:
{
    80001fac:	1101                	addi	sp,sp,-32
    80001fae:	ec06                	sd	ra,24(sp)
    80001fb0:	e822                	sd	s0,16(sp)
    80001fb2:	e426                	sd	s1,8(sp)
    80001fb4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	eee080e7          	jalr	-274(ra) # 80001ea4 <allocproc>
    80001fbe:	84aa                	mv	s1,a0
  initproc = p;
    80001fc0:	00007797          	auipc	a5,0x7
    80001fc4:	c2a7b423          	sd	a0,-984(a5) # 80008be8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001fc8:	03400613          	li	a2,52
    80001fcc:	00007597          	auipc	a1,0x7
    80001fd0:	bb458593          	addi	a1,a1,-1100 # 80008b80 <initcode>
    80001fd4:	6928                	ld	a0,80(a0)
    80001fd6:	fffff097          	auipc	ra,0xfffff
    80001fda:	5c2080e7          	jalr	1474(ra) # 80001598 <uvmfirst>
  p->sz = PGSIZE;
    80001fde:	6785                	lui	a5,0x1
    80001fe0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001fe2:	6cb8                	ld	a4,88(s1)
    80001fe4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001fe8:	6cb8                	ld	a4,88(s1)
    80001fea:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001fec:	4641                	li	a2,16
    80001fee:	00006597          	auipc	a1,0x6
    80001ff2:	27258593          	addi	a1,a1,626 # 80008260 <digits+0x220>
    80001ff6:	15848513          	addi	a0,s1,344
    80001ffa:	fffff097          	auipc	ra,0xfffff
    80001ffe:	064080e7          	jalr	100(ra) # 8000105e <safestrcpy>
  p->cwd = namei("/");
    80002002:	00006517          	auipc	a0,0x6
    80002006:	26e50513          	addi	a0,a0,622 # 80008270 <digits+0x230>
    8000200a:	00003097          	auipc	ra,0x3
    8000200e:	ac8080e7          	jalr	-1336(ra) # 80004ad2 <namei>
    80002012:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002016:	478d                	li	a5,3
    80002018:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000201a:	8526                	mv	a0,s1
    8000201c:	fffff097          	auipc	ra,0xfffff
    80002020:	eb2080e7          	jalr	-334(ra) # 80000ece <release>
}
    80002024:	60e2                	ld	ra,24(sp)
    80002026:	6442                	ld	s0,16(sp)
    80002028:	64a2                	ld	s1,8(sp)
    8000202a:	6105                	addi	sp,sp,32
    8000202c:	8082                	ret

000000008000202e <growproc>:
{
    8000202e:	1101                	addi	sp,sp,-32
    80002030:	ec06                	sd	ra,24(sp)
    80002032:	e822                	sd	s0,16(sp)
    80002034:	e426                	sd	s1,8(sp)
    80002036:	e04a                	sd	s2,0(sp)
    80002038:	1000                	addi	s0,sp,32
    8000203a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	c54080e7          	jalr	-940(ra) # 80001c90 <myproc>
    80002044:	84aa                	mv	s1,a0
  sz = p->sz;
    80002046:	652c                	ld	a1,72(a0)
  if (n > 0)
    80002048:	01204c63          	bgtz	s2,80002060 <growproc+0x32>
  else if (n < 0)
    8000204c:	02094663          	bltz	s2,80002078 <growproc+0x4a>
  p->sz = sz;
    80002050:	e4ac                	sd	a1,72(s1)
  return 0;
    80002052:	4501                	li	a0,0
}
    80002054:	60e2                	ld	ra,24(sp)
    80002056:	6442                	ld	s0,16(sp)
    80002058:	64a2                	ld	s1,8(sp)
    8000205a:	6902                	ld	s2,0(sp)
    8000205c:	6105                	addi	sp,sp,32
    8000205e:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002060:	4691                	li	a3,4
    80002062:	00b90633          	add	a2,s2,a1
    80002066:	6928                	ld	a0,80(a0)
    80002068:	fffff097          	auipc	ra,0xfffff
    8000206c:	5ea080e7          	jalr	1514(ra) # 80001652 <uvmalloc>
    80002070:	85aa                	mv	a1,a0
    80002072:	fd79                	bnez	a0,80002050 <growproc+0x22>
      return -1;
    80002074:	557d                	li	a0,-1
    80002076:	bff9                	j	80002054 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002078:	00b90633          	add	a2,s2,a1
    8000207c:	6928                	ld	a0,80(a0)
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	58c080e7          	jalr	1420(ra) # 8000160a <uvmdealloc>
    80002086:	85aa                	mv	a1,a0
    80002088:	b7e1                	j	80002050 <growproc+0x22>

000000008000208a <fork>:
{
    8000208a:	7139                	addi	sp,sp,-64
    8000208c:	fc06                	sd	ra,56(sp)
    8000208e:	f822                	sd	s0,48(sp)
    80002090:	f426                	sd	s1,40(sp)
    80002092:	f04a                	sd	s2,32(sp)
    80002094:	ec4e                	sd	s3,24(sp)
    80002096:	e852                	sd	s4,16(sp)
    80002098:	e456                	sd	s5,8(sp)
    8000209a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	bf4080e7          	jalr	-1036(ra) # 80001c90 <myproc>
    800020a4:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    800020a6:	00000097          	auipc	ra,0x0
    800020aa:	dfe080e7          	jalr	-514(ra) # 80001ea4 <allocproc>
    800020ae:	12050463          	beqz	a0,800021d6 <fork+0x14c>
    800020b2:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    800020b4:	048ab603          	ld	a2,72(s5)
    800020b8:	692c                	ld	a1,80(a0)
    800020ba:	050ab503          	ld	a0,80(s5)
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	6ec080e7          	jalr	1772(ra) # 800017aa <uvmcopy>
    800020c6:	06054063          	bltz	a0,80002126 <fork+0x9c>
  np->sz = p->sz;
    800020ca:	048ab783          	ld	a5,72(s5)
    800020ce:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800020d2:	058ab683          	ld	a3,88(s5)
    800020d6:	87b6                	mv	a5,a3
    800020d8:	0589b703          	ld	a4,88(s3)
    800020dc:	12068693          	addi	a3,a3,288
    800020e0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800020e4:	6788                	ld	a0,8(a5)
    800020e6:	6b8c                	ld	a1,16(a5)
    800020e8:	6f90                	ld	a2,24(a5)
    800020ea:	01073023          	sd	a6,0(a4)
    800020ee:	e708                	sd	a0,8(a4)
    800020f0:	eb0c                	sd	a1,16(a4)
    800020f2:	ef10                	sd	a2,24(a4)
    800020f4:	02078793          	addi	a5,a5,32
    800020f8:	02070713          	addi	a4,a4,32
    800020fc:	fed792e3          	bne	a5,a3,800020e0 <fork+0x56>
  np->tickets = p->tickets;
    80002100:	2c4aa783          	lw	a5,708(s5)
    80002104:	2cf9a223          	sw	a5,708(s3)
  np->mask = p->mask; // Storing mask value into struct
    80002108:	168aa783          	lw	a5,360(s5)
    8000210c:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80002110:	0589b783          	ld	a5,88(s3)
    80002114:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002118:	0d0a8493          	addi	s1,s5,208
    8000211c:	0d098913          	addi	s2,s3,208
    80002120:	150a8a13          	addi	s4,s5,336
    80002124:	a00d                	j	80002146 <fork+0xbc>
    freeproc(np);
    80002126:	854e                	mv	a0,s3
    80002128:	00000097          	auipc	ra,0x0
    8000212c:	d1a080e7          	jalr	-742(ra) # 80001e42 <freeproc>
    release(&np->lock);
    80002130:	854e                	mv	a0,s3
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	d9c080e7          	jalr	-612(ra) # 80000ece <release>
    return -1;
    8000213a:	597d                	li	s2,-1
    8000213c:	a059                	j	800021c2 <fork+0x138>
  for (i = 0; i < NOFILE; i++)
    8000213e:	04a1                	addi	s1,s1,8
    80002140:	0921                	addi	s2,s2,8
    80002142:	01448b63          	beq	s1,s4,80002158 <fork+0xce>
    if (p->ofile[i])
    80002146:	6088                	ld	a0,0(s1)
    80002148:	d97d                	beqz	a0,8000213e <fork+0xb4>
      np->ofile[i] = filedup(p->ofile[i]);
    8000214a:	00003097          	auipc	ra,0x3
    8000214e:	ffa080e7          	jalr	-6(ra) # 80005144 <filedup>
    80002152:	00a93023          	sd	a0,0(s2)
    80002156:	b7e5                	j	8000213e <fork+0xb4>
  np->cwd = idup(p->cwd);
    80002158:	150ab503          	ld	a0,336(s5)
    8000215c:	00002097          	auipc	ra,0x2
    80002160:	192080e7          	jalr	402(ra) # 800042ee <idup>
    80002164:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002168:	4641                	li	a2,16
    8000216a:	158a8593          	addi	a1,s5,344
    8000216e:	15898513          	addi	a0,s3,344
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	eec080e7          	jalr	-276(ra) # 8000105e <safestrcpy>
  pid = np->pid;
    8000217a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    8000217e:	854e                	mv	a0,s3
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	d4e080e7          	jalr	-690(ra) # 80000ece <release>
  acquire(&wait_lock);
    80002188:	0022f497          	auipc	s1,0x22f
    8000218c:	d0848493          	addi	s1,s1,-760 # 80230e90 <wait_lock>
    80002190:	8526                	mv	a0,s1
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	c88080e7          	jalr	-888(ra) # 80000e1a <acquire>
  np->parent = p;
    8000219a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    8000219e:	8526                	mv	a0,s1
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	d2e080e7          	jalr	-722(ra) # 80000ece <release>
  acquire(&np->lock);
    800021a8:	854e                	mv	a0,s3
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	c70080e7          	jalr	-912(ra) # 80000e1a <acquire>
  np->state = RUNNABLE;
    800021b2:	478d                	li	a5,3
    800021b4:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800021b8:	854e                	mv	a0,s3
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	d14080e7          	jalr	-748(ra) # 80000ece <release>
}
    800021c2:	854a                	mv	a0,s2
    800021c4:	70e2                	ld	ra,56(sp)
    800021c6:	7442                	ld	s0,48(sp)
    800021c8:	74a2                	ld	s1,40(sp)
    800021ca:	7902                	ld	s2,32(sp)
    800021cc:	69e2                	ld	s3,24(sp)
    800021ce:	6a42                	ld	s4,16(sp)
    800021d0:	6aa2                	ld	s5,8(sp)
    800021d2:	6121                	addi	sp,sp,64
    800021d4:	8082                	ret
    return -1;
    800021d6:	597d                	li	s2,-1
    800021d8:	b7ed                	j	800021c2 <fork+0x138>

00000000800021da <update_time>:
{
    800021da:	7179                	addi	sp,sp,-48
    800021dc:	f406                	sd	ra,40(sp)
    800021de:	f022                	sd	s0,32(sp)
    800021e0:	ec26                	sd	s1,24(sp)
    800021e2:	e84a                	sd	s2,16(sp)
    800021e4:	e44e                	sd	s3,8(sp)
    800021e6:	e052                	sd	s4,0(sp)
    800021e8:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    800021ea:	00230497          	auipc	s1,0x230
    800021ee:	05e48493          	addi	s1,s1,94 # 80232248 <proc>
    if (p->state == RUNNING)
    800021f2:	4991                	li	s3,4
    if (p->state == SLEEPING)
    800021f4:	4a09                	li	s4,2
  for (p = proc; p < &proc[NPROC]; p++)
    800021f6:	0023b917          	auipc	s2,0x23b
    800021fa:	25290913          	addi	s2,s2,594 # 8023d448 <tickslock>
    800021fe:	a025                	j	80002226 <update_time+0x4c>
      p->rtime++;
    80002200:	2a84a783          	lw	a5,680(s1)
    80002204:	2785                	addiw	a5,a5,1
    80002206:	2af4a423          	sw	a5,680(s1)
      p->trtime++;
    8000220a:	2b44a783          	lw	a5,692(s1)
    8000220e:	2785                	addiw	a5,a5,1
    80002210:	2af4aa23          	sw	a5,692(s1)
    release(&p->lock);
    80002214:	8526                	mv	a0,s1
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	cb8080e7          	jalr	-840(ra) # 80000ece <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000221e:	2c848493          	addi	s1,s1,712
    80002222:	03248263          	beq	s1,s2,80002246 <update_time+0x6c>
    acquire(&p->lock);
    80002226:	8526                	mv	a0,s1
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	bf2080e7          	jalr	-1038(ra) # 80000e1a <acquire>
    if (p->state == RUNNING)
    80002230:	4c9c                	lw	a5,24(s1)
    80002232:	fd3787e3          	beq	a5,s3,80002200 <update_time+0x26>
    if (p->state == SLEEPING)
    80002236:	fd479fe3          	bne	a5,s4,80002214 <update_time+0x3a>
      p->stime++;
    8000223a:	2b84a783          	lw	a5,696(s1)
    8000223e:	2785                	addiw	a5,a5,1
    80002240:	2af4ac23          	sw	a5,696(s1)
    80002244:	bfc1                	j	80002214 <update_time+0x3a>
}
    80002246:	70a2                	ld	ra,40(sp)
    80002248:	7402                	ld	s0,32(sp)
    8000224a:	64e2                	ld	s1,24(sp)
    8000224c:	6942                	ld	s2,16(sp)
    8000224e:	69a2                	ld	s3,8(sp)
    80002250:	6a02                	ld	s4,0(sp)
    80002252:	6145                	addi	sp,sp,48
    80002254:	8082                	ret

0000000080002256 <RRschedule>:
{
    80002256:	7139                	addi	sp,sp,-64
    80002258:	fc06                	sd	ra,56(sp)
    8000225a:	f822                	sd	s0,48(sp)
    8000225c:	f426                	sd	s1,40(sp)
    8000225e:	f04a                	sd	s2,32(sp)
    80002260:	ec4e                	sd	s3,24(sp)
    80002262:	e852                	sd	s4,16(sp)
    80002264:	e456                	sd	s5,8(sp)
    80002266:	e05a                	sd	s6,0(sp)
    80002268:	0080                	addi	s0,sp,64
    8000226a:	8a2a                	mv	s4,a0
  for (p = proc; p < &proc[NPROC]; p++)
    8000226c:	00230497          	auipc	s1,0x230
    80002270:	fdc48493          	addi	s1,s1,-36 # 80232248 <proc>
    if (p->state == RUNNABLE)
    80002274:	498d                	li	s3,3
      p->state = RUNNING;
    80002276:	4b11                	li	s6,4
      swtch(&c->context, &p->context);
    80002278:	00850a93          	addi	s5,a0,8
  for (p = proc; p < &proc[NPROC]; p++)
    8000227c:	0023b917          	auipc	s2,0x23b
    80002280:	1cc90913          	addi	s2,s2,460 # 8023d448 <tickslock>
    80002284:	a811                	j	80002298 <RRschedule+0x42>
    release(&p->lock);
    80002286:	8526                	mv	a0,s1
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	c46080e7          	jalr	-954(ra) # 80000ece <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002290:	2c848493          	addi	s1,s1,712
    80002294:	03248863          	beq	s1,s2,800022c4 <RRschedule+0x6e>
    acquire(&p->lock);
    80002298:	8526                	mv	a0,s1
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	b80080e7          	jalr	-1152(ra) # 80000e1a <acquire>
    if (p->state == RUNNABLE)
    800022a2:	4c9c                	lw	a5,24(s1)
    800022a4:	ff3791e3          	bne	a5,s3,80002286 <RRschedule+0x30>
      p->state = RUNNING;
    800022a8:	0164ac23          	sw	s6,24(s1)
      c->proc = p;
    800022ac:	009a3023          	sd	s1,0(s4)
      swtch(&c->context, &p->context);
    800022b0:	06048593          	addi	a1,s1,96
    800022b4:	8556                	mv	a0,s5
    800022b6:	00001097          	auipc	ra,0x1
    800022ba:	c04080e7          	jalr	-1020(ra) # 80002eba <swtch>
      c->proc = 0;
    800022be:	000a3023          	sd	zero,0(s4)
    800022c2:	b7d1                	j	80002286 <RRschedule+0x30>
}
    800022c4:	70e2                	ld	ra,56(sp)
    800022c6:	7442                	ld	s0,48(sp)
    800022c8:	74a2                	ld	s1,40(sp)
    800022ca:	7902                	ld	s2,32(sp)
    800022cc:	69e2                	ld	s3,24(sp)
    800022ce:	6a42                	ld	s4,16(sp)
    800022d0:	6aa2                	ld	s5,8(sp)
    800022d2:	6b02                	ld	s6,0(sp)
    800022d4:	6121                	addi	sp,sp,64
    800022d6:	8082                	ret

00000000800022d8 <proc_swtch>:
  if (!change)
    800022d8:	c5a9                	beqz	a1,80002322 <proc_swtch+0x4a>
{
    800022da:	1101                	addi	sp,sp,-32
    800022dc:	ec06                	sd	ra,24(sp)
    800022de:	e822                	sd	s0,16(sp)
    800022e0:	e426                	sd	s1,8(sp)
    800022e2:	e04a                	sd	s2,0(sp)
    800022e4:	1000                	addi	s0,sp,32
    800022e6:	892a                	mv	s2,a0
    800022e8:	84ae                	mv	s1,a1
  if (change->state == RUNNABLE)
    800022ea:	4d98                	lw	a4,24(a1)
    800022ec:	478d                	li	a5,3
    800022ee:	00f70d63          	beq	a4,a5,80002308 <proc_swtch+0x30>
  release(&change->lock);
    800022f2:	8526                	mv	a0,s1
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	bda080e7          	jalr	-1062(ra) # 80000ece <release>
}
    800022fc:	60e2                	ld	ra,24(sp)
    800022fe:	6442                	ld	s0,16(sp)
    80002300:	64a2                	ld	s1,8(sp)
    80002302:	6902                	ld	s2,0(sp)
    80002304:	6105                	addi	sp,sp,32
    80002306:	8082                	ret
    change->state = RUNNING;
    80002308:	4791                	li	a5,4
    8000230a:	cd9c                	sw	a5,24(a1)
    c->proc = change;
    8000230c:	e10c                	sd	a1,0(a0)
    swtch(&c->context, &change->context);
    8000230e:	06058593          	addi	a1,a1,96
    80002312:	0521                	addi	a0,a0,8
    80002314:	00001097          	auipc	ra,0x1
    80002318:	ba6080e7          	jalr	-1114(ra) # 80002eba <swtch>
    c->proc = 0;
    8000231c:	00093023          	sd	zero,0(s2)
    80002320:	bfc9                	j	800022f2 <proc_swtch+0x1a>
    80002322:	8082                	ret

0000000080002324 <FCFSschedule>:
{
    80002324:	7139                	addi	sp,sp,-64
    80002326:	fc06                	sd	ra,56(sp)
    80002328:	f822                	sd	s0,48(sp)
    8000232a:	f426                	sd	s1,40(sp)
    8000232c:	f04a                	sd	s2,32(sp)
    8000232e:	ec4e                	sd	s3,24(sp)
    80002330:	e852                	sd	s4,16(sp)
    80002332:	e456                	sd	s5,8(sp)
    80002334:	e05a                	sd	s6,0(sp)
    80002336:	0080                	addi	s0,sp,64
    80002338:	8b2a                	mv	s6,a0
  uint lowestFound = 2100000000;
    8000233a:	7d2b7937          	lui	s2,0x7d2b7
    8000233e:	50090913          	addi	s2,s2,1280 # 7d2b7500 <_entry-0x2d48b00>
  struct proc *next = 0;
    80002342:	4a81                	li	s5,0
  for (p = proc; p < &proc[NPROC]; p++)
    80002344:	00230497          	auipc	s1,0x230
    80002348:	f0448493          	addi	s1,s1,-252 # 80232248 <proc>
    if (p->state != RUNNABLE)
    8000234c:	4a0d                	li	s4,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000234e:	0023b997          	auipc	s3,0x23b
    80002352:	0fa98993          	addi	s3,s3,250 # 8023d448 <tickslock>
    80002356:	a829                	j	80002370 <FCFSschedule+0x4c>
      release(&p->lock);
    80002358:	8526                	mv	a0,s1
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	b74080e7          	jalr	-1164(ra) # 80000ece <release>
      continue;
    80002362:	a019                	j	80002368 <FCFSschedule+0x44>
      lowestFound = p->ctime;
    80002364:	893e                	mv	s2,a5
    80002366:	8aa6                	mv	s5,s1
  for (p = proc; p < &proc[NPROC]; p++)
    80002368:	2c848493          	addi	s1,s1,712
    8000236c:	03348463          	beq	s1,s3,80002394 <FCFSschedule+0x70>
    acquire(&p->lock);
    80002370:	8526                	mv	a0,s1
    80002372:	fffff097          	auipc	ra,0xfffff
    80002376:	aa8080e7          	jalr	-1368(ra) # 80000e1a <acquire>
    if (p->state != RUNNABLE)
    8000237a:	4c9c                	lw	a5,24(s1)
    8000237c:	fd479ee3          	bne	a5,s4,80002358 <FCFSschedule+0x34>
    if (p->ctime < lowestFound)
    80002380:	2a04a783          	lw	a5,672(s1)
    80002384:	ff27e0e3          	bltu	a5,s2,80002364 <FCFSschedule+0x40>
    release(&p->lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	b44080e7          	jalr	-1212(ra) # 80000ece <release>
    80002392:	bfd9                	j	80002368 <FCFSschedule+0x44>
  proc_swtch(c, next);
    80002394:	85d6                	mv	a1,s5
    80002396:	855a                	mv	a0,s6
    80002398:	00000097          	auipc	ra,0x0
    8000239c:	f40080e7          	jalr	-192(ra) # 800022d8 <proc_swtch>
}
    800023a0:	70e2                	ld	ra,56(sp)
    800023a2:	7442                	ld	s0,48(sp)
    800023a4:	74a2                	ld	s1,40(sp)
    800023a6:	7902                	ld	s2,32(sp)
    800023a8:	69e2                	ld	s3,24(sp)
    800023aa:	6a42                	ld	s4,16(sp)
    800023ac:	6aa2                	ld	s5,8(sp)
    800023ae:	6b02                	ld	s6,0(sp)
    800023b0:	6121                	addi	sp,sp,64
    800023b2:	8082                	ret

00000000800023b4 <total_tickets>:
{
    800023b4:	1141                	addi	sp,sp,-16
    800023b6:	e422                	sd	s0,8(sp)
    800023b8:	0800                	addi	s0,sp,16
  int ticket_sum = 0;
    800023ba:	4501                	li	a0,0
  for (p = proc; p < &proc[NPROC]; p++)
    800023bc:	00230797          	auipc	a5,0x230
    800023c0:	e8c78793          	addi	a5,a5,-372 # 80232248 <proc>
    if (p->state == RUNNABLE)
    800023c4:	460d                	li	a2,3
  for (p = proc; p < &proc[NPROC]; p++)
    800023c6:	0023b697          	auipc	a3,0x23b
    800023ca:	08268693          	addi	a3,a3,130 # 8023d448 <tickslock>
    800023ce:	a029                	j	800023d8 <total_tickets+0x24>
    800023d0:	2c878793          	addi	a5,a5,712
    800023d4:	00d78963          	beq	a5,a3,800023e6 <total_tickets+0x32>
    if (p->state == RUNNABLE)
    800023d8:	4f98                	lw	a4,24(a5)
    800023da:	fec71be3          	bne	a4,a2,800023d0 <total_tickets+0x1c>
      ticket_sum += p->tickets;
    800023de:	2c47a703          	lw	a4,708(a5)
    800023e2:	9d39                	addw	a0,a0,a4
    800023e4:	b7f5                	j	800023d0 <total_tickets+0x1c>
}
    800023e6:	6422                	ld	s0,8(sp)
    800023e8:	0141                	addi	sp,sp,16
    800023ea:	8082                	ret

00000000800023ec <LOTTERYschedule>:
{
    800023ec:	7139                	addi	sp,sp,-64
    800023ee:	fc06                	sd	ra,56(sp)
    800023f0:	f822                	sd	s0,48(sp)
    800023f2:	f426                	sd	s1,40(sp)
    800023f4:	f04a                	sd	s2,32(sp)
    800023f6:	ec4e                	sd	s3,24(sp)
    800023f8:	e852                	sd	s4,16(sp)
    800023fa:	e456                	sd	s5,8(sp)
    800023fc:	e05a                	sd	s6,0(sp)
    800023fe:	0080                	addi	s0,sp,64
    80002400:	8a2a                	mv	s4,a0
     rand_ret(237592526);
    80002402:	0e296537          	lui	a0,0xe296
    80002406:	fce50513          	addi	a0,a0,-50 # e295fce <_entry-0x71d6a032>
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	6b0080e7          	jalr	1712(ra) # 80001aba <rand_ret>
     int total_tix = total_tickets();
    80002412:	00000097          	auipc	ra,0x0
    80002416:	fa2080e7          	jalr	-94(ra) # 800023b4 <total_tickets>
     int winner_ticket = rand_table[667]%total_tix;
    8000241a:	00230997          	auipc	s3,0x230
    8000241e:	8fa9a983          	lw	s3,-1798(s3) # 80231d14 <rand_table+0xa6c>
    80002422:	02a9f9bb          	remuw	s3,s3,a0
  int win_index = 0;
    80002426:	4901                	li	s2,0
  for (p = proc; p < &proc[NPROC]; p++)
    80002428:	00230497          	auipc	s1,0x230
    8000242c:	e2048493          	addi	s1,s1,-480 # 80232248 <proc>
    if (p->state != RUNNABLE)
    80002430:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002432:	0023bb17          	auipc	s6,0x23b
    80002436:	016b0b13          	addi	s6,s6,22 # 8023d448 <tickslock>
    8000243a:	a811                	j	8000244e <LOTTERYschedule+0x62>
      release(&p->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	a90080e7          	jalr	-1392(ra) # 80000ece <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002446:	2c848493          	addi	s1,s1,712
    8000244a:	03648563          	beq	s1,s6,80002474 <LOTTERYschedule+0x88>
    acquire(&p->lock);
    8000244e:	8526                	mv	a0,s1
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	9ca080e7          	jalr	-1590(ra) # 80000e1a <acquire>
    if (p->state != RUNNABLE)
    80002458:	4c9c                	lw	a5,24(s1)
    8000245a:	ff5791e3          	bne	a5,s5,8000243c <LOTTERYschedule+0x50>
    if (winner_ticket > (win_index + p->tickets))
    8000245e:	2c44a783          	lw	a5,708(s1)
    80002462:	0127893b          	addw	s2,a5,s2
    80002466:	03394c63          	blt	s2,s3,8000249e <LOTTERYschedule+0xb2>
    release(&p->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	a62080e7          	jalr	-1438(ra) # 80000ece <release>
  acquire(&p->lock);
    80002474:	8526                	mv	a0,s1
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	9a4080e7          	jalr	-1628(ra) # 80000e1a <acquire>
  proc_swtch(c, p);
    8000247e:	85a6                	mv	a1,s1
    80002480:	8552                	mv	a0,s4
    80002482:	00000097          	auipc	ra,0x0
    80002486:	e56080e7          	jalr	-426(ra) # 800022d8 <proc_swtch>
}
    8000248a:	70e2                	ld	ra,56(sp)
    8000248c:	7442                	ld	s0,48(sp)
    8000248e:	74a2                	ld	s1,40(sp)
    80002490:	7902                	ld	s2,32(sp)
    80002492:	69e2                	ld	s3,24(sp)
    80002494:	6a42                	ld	s4,16(sp)
    80002496:	6aa2                	ld	s5,8(sp)
    80002498:	6b02                	ld	s6,0(sp)
    8000249a:	6121                	addi	sp,sp,64
    8000249c:	8082                	ret
      release(&p->lock);
    8000249e:	8526                	mv	a0,s1
    800024a0:	fffff097          	auipc	ra,0xfffff
    800024a4:	a2e080e7          	jalr	-1490(ra) # 80000ece <release>
      continue;
    800024a8:	bf79                	j	80002446 <LOTTERYschedule+0x5a>

00000000800024aa <priority_switch>:
  if (!change)
    800024aa:	c5ad                	beqz	a1,80002514 <priority_switch+0x6a>
{
    800024ac:	1101                	addi	sp,sp,-32
    800024ae:	ec06                	sd	ra,24(sp)
    800024b0:	e822                	sd	s0,16(sp)
    800024b2:	e426                	sd	s1,8(sp)
    800024b4:	e04a                	sd	s2,0(sp)
    800024b6:	1000                	addi	s0,sp,32
    800024b8:	892a                	mv	s2,a0
    800024ba:	84ae                	mv	s1,a1
  acquire(&change->lock);
    800024bc:	852e                	mv	a0,a1
    800024be:	fffff097          	auipc	ra,0xfffff
    800024c2:	95c080e7          	jalr	-1700(ra) # 80000e1a <acquire>
  if (change->state == RUNNABLE)
    800024c6:	4c98                	lw	a4,24(s1)
    800024c8:	478d                	li	a5,3
    800024ca:	00f70d63          	beq	a4,a5,800024e4 <priority_switch+0x3a>
  release(&change->lock);
    800024ce:	8526                	mv	a0,s1
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	9fe080e7          	jalr	-1538(ra) # 80000ece <release>
}
    800024d8:	60e2                	ld	ra,24(sp)
    800024da:	6442                	ld	s0,16(sp)
    800024dc:	64a2                	ld	s1,8(sp)
    800024de:	6902                	ld	s2,0(sp)
    800024e0:	6105                	addi	sp,sp,32
    800024e2:	8082                	ret
    change->state = RUNNING;
    800024e4:	4791                	li	a5,4
    800024e6:	cc9c                	sw	a5,24(s1)
    change->runs++;
    800024e8:	2bc4a783          	lw	a5,700(s1)
    800024ec:	2785                	addiw	a5,a5,1
    800024ee:	2af4ae23          	sw	a5,700(s1)
    change->rtime = 0;
    800024f2:	2a04a423          	sw	zero,680(s1)
    change->stime = 0;
    800024f6:	2a04ac23          	sw	zero,696(s1)
    c->proc = change;
    800024fa:	00993023          	sd	s1,0(s2)
    swtch(&c->context, &change->context);
    800024fe:	06048593          	addi	a1,s1,96
    80002502:	00890513          	addi	a0,s2,8
    80002506:	00001097          	auipc	ra,0x1
    8000250a:	9b4080e7          	jalr	-1612(ra) # 80002eba <swtch>
    c->proc = 0;
    8000250e:	00093023          	sd	zero,0(s2)
    80002512:	bf75                	j	800024ce <priority_switch+0x24>
    80002514:	8082                	ret

0000000080002516 <PBSschedule>:
{
    80002516:	7159                	addi	sp,sp,-112
    80002518:	f486                	sd	ra,104(sp)
    8000251a:	f0a2                	sd	s0,96(sp)
    8000251c:	eca6                	sd	s1,88(sp)
    8000251e:	e8ca                	sd	s2,80(sp)
    80002520:	e4ce                	sd	s3,72(sp)
    80002522:	e0d2                	sd	s4,64(sp)
    80002524:	fc56                	sd	s5,56(sp)
    80002526:	f85a                	sd	s6,48(sp)
    80002528:	f45e                	sd	s7,40(sp)
    8000252a:	f062                	sd	s8,32(sp)
    8000252c:	ec66                	sd	s9,24(sp)
    8000252e:	e86a                	sd	s10,16(sp)
    80002530:	e46e                	sd	s11,8(sp)
    80002532:	1880                	addi	s0,sp,112
    80002534:	8daa                	mv	s11,a0
  int flag = 0;     //  Initialising flag
    80002536:	4c81                	li	s9,0
  int niceness = 5; //  Default Nice value
    80002538:	4915                	li	s2,5
  int dp = 101;     //  Highest Priority
    8000253a:	06500b13          	li	s6,101
  struct proc *priority_proc = 0;
    8000253e:	4a81                	li	s5,0
  for (p = proc; p < &proc[NPROC]; p++)
    80002540:	00230497          	auipc	s1,0x230
    80002544:	d0848493          	addi	s1,s1,-760 # 80232248 <proc>
    if (p->state == RUNNABLE)
    80002548:	4a0d                	li	s4,3
      proc_dp = MAX(0, MIN(temp, 100));
    8000254a:	06400c13          	li	s8,100
        flag = 1;
    8000254e:	4b85                	li	s7,1
      proc_dp = MAX(0, MIN(temp, 100));
    80002550:	06400d13          	li	s10,100
  for (p = proc; p < &proc[NPROC]; p++)
    80002554:	0023b997          	auipc	s3,0x23b
    80002558:	ef498993          	addi	s3,s3,-268 # 8023d448 <tickslock>
    8000255c:	a00d                	j	8000257e <PBSschedule+0x68>
        dp = proc_dp;
    8000255e:	8b3e                	mv	s6,a5
    80002560:	8aa6                	mv	s5,s1
        flag = 1;
    80002562:	8cde                	mv	s9,s7
    80002564:	a021                	j	8000256c <PBSschedule+0x56>
        dp = proc_dp;
    80002566:	8b3e                	mv	s6,a5
    80002568:	8aa6                	mv	s5,s1
        flag = 1;
    8000256a:	8cde                	mv	s9,s7
    release(&p->lock);
    8000256c:	8526                	mv	a0,s1
    8000256e:	fffff097          	auipc	ra,0xfffff
    80002572:	960080e7          	jalr	-1696(ra) # 80000ece <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002576:	2c848493          	addi	s1,s1,712
    8000257a:	07348463          	beq	s1,s3,800025e2 <PBSschedule+0xcc>
    acquire(&p->lock);
    8000257e:	8526                	mv	a0,s1
    80002580:	fffff097          	auipc	ra,0xfffff
    80002584:	89a080e7          	jalr	-1894(ra) # 80000e1a <acquire>
    if (p->state == RUNNABLE)
    80002588:	4c9c                	lw	a5,24(s1)
    8000258a:	ff4791e3          	bne	a5,s4,8000256c <PBSschedule+0x56>
      if (p->stime + p->rtime > 0)
    8000258e:	2b84a703          	lw	a4,696(s1)
    80002592:	2a84a783          	lw	a5,680(s1)
    80002596:	9fb9                	addw	a5,a5,a4
    80002598:	0007869b          	sext.w	a3,a5
    8000259c:	ca89                	beqz	a3,800025ae <PBSschedule+0x98>
        niceness = 10 * p->stime;
    8000259e:	0027191b          	slliw	s2,a4,0x2
    800025a2:	00e9093b          	addw	s2,s2,a4
    800025a6:	0019191b          	slliw	s2,s2,0x1
        niceness /= p->stime + p->rtime;
    800025aa:	02f9593b          	divuw	s2,s2,a5
      int temp = p->priority - niceness + 5;
    800025ae:	2c04a783          	lw	a5,704(s1)
    800025b2:	2795                	addiw	a5,a5,5
    800025b4:	412787bb          	subw	a5,a5,s2
      proc_dp = MAX(0, MIN(temp, 100));
    800025b8:	0007871b          	sext.w	a4,a5
    800025bc:	00ec5363          	bge	s8,a4,800025c2 <PBSschedule+0xac>
    800025c0:	87ea                	mv	a5,s10
    800025c2:	0007871b          	sext.w	a4,a5
    800025c6:	fff74713          	not	a4,a4
    800025ca:	977d                	srai	a4,a4,0x3f
    800025cc:	8ff9                	and	a5,a5,a4
    800025ce:	2781                	sext.w	a5,a5
      if (priority_proc == 0)
    800025d0:	f80a87e3          	beqz	s5,8000255e <PBSschedule+0x48>
      if (dp > proc_dp)
    800025d4:	f967c9e3          	blt	a5,s6,80002566 <PBSschedule+0x50>
      if (flag == 1)
    800025d8:	f97c9ae3          	bne	s9,s7,8000256c <PBSschedule+0x56>
        dp = proc_dp;
    800025dc:	8b3e                	mv	s6,a5
    800025de:	8aa6                	mv	s5,s1
    800025e0:	b771                	j	8000256c <PBSschedule+0x56>
  priority_switch(c, priority_proc);
    800025e2:	85d6                	mv	a1,s5
    800025e4:	856e                	mv	a0,s11
    800025e6:	00000097          	auipc	ra,0x0
    800025ea:	ec4080e7          	jalr	-316(ra) # 800024aa <priority_switch>
}
    800025ee:	70a6                	ld	ra,104(sp)
    800025f0:	7406                	ld	s0,96(sp)
    800025f2:	64e6                	ld	s1,88(sp)
    800025f4:	6946                	ld	s2,80(sp)
    800025f6:	69a6                	ld	s3,72(sp)
    800025f8:	6a06                	ld	s4,64(sp)
    800025fa:	7ae2                	ld	s5,56(sp)
    800025fc:	7b42                	ld	s6,48(sp)
    800025fe:	7ba2                	ld	s7,40(sp)
    80002600:	7c02                	ld	s8,32(sp)
    80002602:	6ce2                	ld	s9,24(sp)
    80002604:	6d42                	ld	s10,16(sp)
    80002606:	6da2                	ld	s11,8(sp)
    80002608:	6165                	addi	sp,sp,112
    8000260a:	8082                	ret

000000008000260c <MLFQschedule>:
{
    8000260c:	1141                	addi	sp,sp,-16
    8000260e:	e422                	sd	s0,8(sp)
    80002610:	0800                	addi	s0,sp,16
}
    80002612:	6422                	ld	s0,8(sp)
    80002614:	0141                	addi	sp,sp,16
    80002616:	8082                	ret

0000000080002618 <scheduler>:
{
    80002618:	1141                	addi	sp,sp,-16
    8000261a:	e422                	sd	s0,8(sp)
    8000261c:	0800                	addi	s0,sp,16
    8000261e:	8792                	mv	a5,tp
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002620:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002624:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002628:	10079073          	csrw	sstatus,a5
    8000262c:	bfd5                	j	80002620 <scheduler+0x8>

000000008000262e <sched>:
{
    8000262e:	7179                	addi	sp,sp,-48
    80002630:	f406                	sd	ra,40(sp)
    80002632:	f022                	sd	s0,32(sp)
    80002634:	ec26                	sd	s1,24(sp)
    80002636:	e84a                	sd	s2,16(sp)
    80002638:	e44e                	sd	s3,8(sp)
    8000263a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000263c:	fffff097          	auipc	ra,0xfffff
    80002640:	654080e7          	jalr	1620(ra) # 80001c90 <myproc>
    80002644:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002646:	ffffe097          	auipc	ra,0xffffe
    8000264a:	75a080e7          	jalr	1882(ra) # 80000da0 <holding>
    8000264e:	c93d                	beqz	a0,800026c4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002650:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002652:	2781                	sext.w	a5,a5
    80002654:	079e                	slli	a5,a5,0x7
    80002656:	0022f717          	auipc	a4,0x22f
    8000265a:	82270713          	addi	a4,a4,-2014 # 80230e78 <pid_lock>
    8000265e:	97ba                	add	a5,a5,a4
    80002660:	0a87a703          	lw	a4,168(a5)
    80002664:	4785                	li	a5,1
    80002666:	06f71763          	bne	a4,a5,800026d4 <sched+0xa6>
  if (p->state == RUNNING)
    8000266a:	4c98                	lw	a4,24(s1)
    8000266c:	4791                	li	a5,4
    8000266e:	06f70b63          	beq	a4,a5,800026e4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002672:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002676:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002678:	efb5                	bnez	a5,800026f4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000267a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000267c:	0022e917          	auipc	s2,0x22e
    80002680:	7fc90913          	addi	s2,s2,2044 # 80230e78 <pid_lock>
    80002684:	2781                	sext.w	a5,a5
    80002686:	079e                	slli	a5,a5,0x7
    80002688:	97ca                	add	a5,a5,s2
    8000268a:	0ac7a983          	lw	s3,172(a5)
    8000268e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002690:	2781                	sext.w	a5,a5
    80002692:	079e                	slli	a5,a5,0x7
    80002694:	0022f597          	auipc	a1,0x22f
    80002698:	81c58593          	addi	a1,a1,-2020 # 80230eb0 <cpus+0x8>
    8000269c:	95be                	add	a1,a1,a5
    8000269e:	06048513          	addi	a0,s1,96
    800026a2:	00001097          	auipc	ra,0x1
    800026a6:	818080e7          	jalr	-2024(ra) # 80002eba <swtch>
    800026aa:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800026ac:	2781                	sext.w	a5,a5
    800026ae:	079e                	slli	a5,a5,0x7
    800026b0:	993e                	add	s2,s2,a5
    800026b2:	0b392623          	sw	s3,172(s2)
}
    800026b6:	70a2                	ld	ra,40(sp)
    800026b8:	7402                	ld	s0,32(sp)
    800026ba:	64e2                	ld	s1,24(sp)
    800026bc:	6942                	ld	s2,16(sp)
    800026be:	69a2                	ld	s3,8(sp)
    800026c0:	6145                	addi	sp,sp,48
    800026c2:	8082                	ret
    panic("sched p->lock");
    800026c4:	00006517          	auipc	a0,0x6
    800026c8:	bb450513          	addi	a0,a0,-1100 # 80008278 <digits+0x238>
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	e70080e7          	jalr	-400(ra) # 8000053c <panic>
    panic("sched locks");
    800026d4:	00006517          	auipc	a0,0x6
    800026d8:	bb450513          	addi	a0,a0,-1100 # 80008288 <digits+0x248>
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	e60080e7          	jalr	-416(ra) # 8000053c <panic>
    panic("sched running");
    800026e4:	00006517          	auipc	a0,0x6
    800026e8:	bb450513          	addi	a0,a0,-1100 # 80008298 <digits+0x258>
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	e50080e7          	jalr	-432(ra) # 8000053c <panic>
    panic("sched interruptible");
    800026f4:	00006517          	auipc	a0,0x6
    800026f8:	bb450513          	addi	a0,a0,-1100 # 800082a8 <digits+0x268>
    800026fc:	ffffe097          	auipc	ra,0xffffe
    80002700:	e40080e7          	jalr	-448(ra) # 8000053c <panic>

0000000080002704 <yield>:
{
    80002704:	1101                	addi	sp,sp,-32
    80002706:	ec06                	sd	ra,24(sp)
    80002708:	e822                	sd	s0,16(sp)
    8000270a:	e426                	sd	s1,8(sp)
    8000270c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000270e:	fffff097          	auipc	ra,0xfffff
    80002712:	582080e7          	jalr	1410(ra) # 80001c90 <myproc>
    80002716:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	702080e7          	jalr	1794(ra) # 80000e1a <acquire>
  p->state = RUNNABLE;
    80002720:	478d                	li	a5,3
    80002722:	cc9c                	sw	a5,24(s1)
  sched();
    80002724:	00000097          	auipc	ra,0x0
    80002728:	f0a080e7          	jalr	-246(ra) # 8000262e <sched>
  release(&p->lock);
    8000272c:	8526                	mv	a0,s1
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	7a0080e7          	jalr	1952(ra) # 80000ece <release>
}
    80002736:	60e2                	ld	ra,24(sp)
    80002738:	6442                	ld	s0,16(sp)
    8000273a:	64a2                	ld	s1,8(sp)
    8000273c:	6105                	addi	sp,sp,32
    8000273e:	8082                	ret

0000000080002740 <set_priority>:
{
    80002740:	7139                	addi	sp,sp,-64
    80002742:	fc06                	sd	ra,56(sp)
    80002744:	f822                	sd	s0,48(sp)
    80002746:	f426                	sd	s1,40(sp)
    80002748:	f04a                	sd	s2,32(sp)
    8000274a:	ec4e                	sd	s3,24(sp)
    8000274c:	e852                	sd	s4,16(sp)
    8000274e:	e456                	sd	s5,8(sp)
    80002750:	0080                	addi	s0,sp,64
    80002752:	8aaa                	mv	s5,a0
    80002754:	8a2e                	mv	s4,a1
  for (p = proc; p < &proc[NPROC]; p++)
    80002756:	00230497          	auipc	s1,0x230
    8000275a:	af248493          	addi	s1,s1,-1294 # 80232248 <proc>
    if (p->state == RUNNABLE)
    8000275e:	490d                	li	s2,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002760:	0023b997          	auipc	s3,0x23b
    80002764:	ce898993          	addi	s3,s3,-792 # 8023d448 <tickslock>
    80002768:	a839                	j	80002786 <set_priority+0x46>
          yield();
    8000276a:	00000097          	auipc	ra,0x0
    8000276e:	f9a080e7          	jalr	-102(ra) # 80002704 <yield>
    80002772:	a081                	j	800027b2 <set_priority+0x72>
    release(&p->lock);
    80002774:	8526                	mv	a0,s1
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	758080e7          	jalr	1880(ra) # 80000ece <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000277e:	2c848493          	addi	s1,s1,712
    80002782:	05348263          	beq	s1,s3,800027c6 <set_priority+0x86>
    acquire(&p->lock);
    80002786:	8526                	mv	a0,s1
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	692080e7          	jalr	1682(ra) # 80000e1a <acquire>
    if (p->state == RUNNABLE)
    80002790:	4c9c                	lw	a5,24(s1)
    80002792:	ff2791e3          	bne	a5,s2,80002774 <set_priority+0x34>
      if (pid == p->pid)
    80002796:	589c                	lw	a5,48(s1)
    80002798:	fd479ee3          	bne	a5,s4,80002774 <set_priority+0x34>
        temp = p->priority;
    8000279c:	2c04a903          	lw	s2,704(s1)
        p->priority = np;
    800027a0:	2d54a023          	sw	s5,704(s1)
        release(&p->lock);
    800027a4:	8526                	mv	a0,s1
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	728080e7          	jalr	1832(ra) # 80000ece <release>
        if (temp > np)
    800027ae:	fb2acee3          	blt	s5,s2,8000276a <set_priority+0x2a>
}
    800027b2:	854a                	mv	a0,s2
    800027b4:	70e2                	ld	ra,56(sp)
    800027b6:	7442                	ld	s0,48(sp)
    800027b8:	74a2                	ld	s1,40(sp)
    800027ba:	7902                	ld	s2,32(sp)
    800027bc:	69e2                	ld	s3,24(sp)
    800027be:	6a42                	ld	s4,16(sp)
    800027c0:	6aa2                	ld	s5,8(sp)
    800027c2:	6121                	addi	sp,sp,64
    800027c4:	8082                	ret
  int temp = -1;
    800027c6:	597d                	li	s2,-1
    800027c8:	b7ed                	j	800027b2 <set_priority+0x72>

00000000800027ca <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800027ca:	7179                	addi	sp,sp,-48
    800027cc:	f406                	sd	ra,40(sp)
    800027ce:	f022                	sd	s0,32(sp)
    800027d0:	ec26                	sd	s1,24(sp)
    800027d2:	e84a                	sd	s2,16(sp)
    800027d4:	e44e                	sd	s3,8(sp)
    800027d6:	1800                	addi	s0,sp,48
    800027d8:	89aa                	mv	s3,a0
    800027da:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027dc:	fffff097          	auipc	ra,0xfffff
    800027e0:	4b4080e7          	jalr	1204(ra) # 80001c90 <myproc>
    800027e4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	634080e7          	jalr	1588(ra) # 80000e1a <acquire>
  release(lk);
    800027ee:	854a                	mv	a0,s2
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	6de080e7          	jalr	1758(ra) # 80000ece <release>

  // Go to sleep.
  p->chan = chan;
    800027f8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800027fc:	4789                	li	a5,2
    800027fe:	cc9c                	sw	a5,24(s1)

  sched();
    80002800:	00000097          	auipc	ra,0x0
    80002804:	e2e080e7          	jalr	-466(ra) # 8000262e <sched>

  // Tidy up.
  p->chan = 0;
    80002808:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000280c:	8526                	mv	a0,s1
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	6c0080e7          	jalr	1728(ra) # 80000ece <release>
  acquire(lk);
    80002816:	854a                	mv	a0,s2
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	602080e7          	jalr	1538(ra) # 80000e1a <acquire>
}
    80002820:	70a2                	ld	ra,40(sp)
    80002822:	7402                	ld	s0,32(sp)
    80002824:	64e2                	ld	s1,24(sp)
    80002826:	6942                	ld	s2,16(sp)
    80002828:	69a2                	ld	s3,8(sp)
    8000282a:	6145                	addi	sp,sp,48
    8000282c:	8082                	ret

000000008000282e <waitx>:
{
    8000282e:	711d                	addi	sp,sp,-96
    80002830:	ec86                	sd	ra,88(sp)
    80002832:	e8a2                	sd	s0,80(sp)
    80002834:	e4a6                	sd	s1,72(sp)
    80002836:	e0ca                	sd	s2,64(sp)
    80002838:	fc4e                	sd	s3,56(sp)
    8000283a:	f852                	sd	s4,48(sp)
    8000283c:	f456                	sd	s5,40(sp)
    8000283e:	f05a                	sd	s6,32(sp)
    80002840:	ec5e                	sd	s7,24(sp)
    80002842:	e862                	sd	s8,16(sp)
    80002844:	e466                	sd	s9,8(sp)
    80002846:	e06a                	sd	s10,0(sp)
    80002848:	1080                	addi	s0,sp,96
    8000284a:	8b2a                	mv	s6,a0
    8000284c:	8bae                	mv	s7,a1
    8000284e:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    80002850:	fffff097          	auipc	ra,0xfffff
    80002854:	440080e7          	jalr	1088(ra) # 80001c90 <myproc>
    80002858:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000285a:	0022e517          	auipc	a0,0x22e
    8000285e:	63650513          	addi	a0,a0,1590 # 80230e90 <wait_lock>
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	5b8080e7          	jalr	1464(ra) # 80000e1a <acquire>
    havekids = 0;
    8000286a:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    8000286c:	4a15                	li	s4,5
        havekids = 1;
    8000286e:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002870:	0023b997          	auipc	s3,0x23b
    80002874:	bd898993          	addi	s3,s3,-1064 # 8023d448 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002878:	0022ed17          	auipc	s10,0x22e
    8000287c:	618d0d13          	addi	s10,s10,1560 # 80230e90 <wait_lock>
    80002880:	a8e9                	j	8000295a <waitx+0x12c>
          pid = np->pid;
    80002882:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002886:	2a84a783          	lw	a5,680(s1)
    8000288a:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->ctime - np->rtime;
    8000288e:	2a04a703          	lw	a4,672(s1)
    80002892:	9f3d                	addw	a4,a4,a5
    80002894:	2ac4a783          	lw	a5,684(s1)
    80002898:	9f99                	subw	a5,a5,a4
    8000289a:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7fdb67d8>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000289e:	000b0e63          	beqz	s6,800028ba <waitx+0x8c>
    800028a2:	4691                	li	a3,4
    800028a4:	02c48613          	addi	a2,s1,44
    800028a8:	85da                	mv	a1,s6
    800028aa:	05093503          	ld	a0,80(s2)
    800028ae:	fffff097          	auipc	ra,0xfffff
    800028b2:	00a080e7          	jalr	10(ra) # 800018b8 <copyout>
    800028b6:	04054363          	bltz	a0,800028fc <waitx+0xce>
          freeproc(np);
    800028ba:	8526                	mv	a0,s1
    800028bc:	fffff097          	auipc	ra,0xfffff
    800028c0:	586080e7          	jalr	1414(ra) # 80001e42 <freeproc>
          release(&np->lock);
    800028c4:	8526                	mv	a0,s1
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	608080e7          	jalr	1544(ra) # 80000ece <release>
          release(&wait_lock);
    800028ce:	0022e517          	auipc	a0,0x22e
    800028d2:	5c250513          	addi	a0,a0,1474 # 80230e90 <wait_lock>
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	5f8080e7          	jalr	1528(ra) # 80000ece <release>
}
    800028de:	854e                	mv	a0,s3
    800028e0:	60e6                	ld	ra,88(sp)
    800028e2:	6446                	ld	s0,80(sp)
    800028e4:	64a6                	ld	s1,72(sp)
    800028e6:	6906                	ld	s2,64(sp)
    800028e8:	79e2                	ld	s3,56(sp)
    800028ea:	7a42                	ld	s4,48(sp)
    800028ec:	7aa2                	ld	s5,40(sp)
    800028ee:	7b02                	ld	s6,32(sp)
    800028f0:	6be2                	ld	s7,24(sp)
    800028f2:	6c42                	ld	s8,16(sp)
    800028f4:	6ca2                	ld	s9,8(sp)
    800028f6:	6d02                	ld	s10,0(sp)
    800028f8:	6125                	addi	sp,sp,96
    800028fa:	8082                	ret
            release(&np->lock);
    800028fc:	8526                	mv	a0,s1
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	5d0080e7          	jalr	1488(ra) # 80000ece <release>
            release(&wait_lock);
    80002906:	0022e517          	auipc	a0,0x22e
    8000290a:	58a50513          	addi	a0,a0,1418 # 80230e90 <wait_lock>
    8000290e:	ffffe097          	auipc	ra,0xffffe
    80002912:	5c0080e7          	jalr	1472(ra) # 80000ece <release>
            return -1;
    80002916:	59fd                	li	s3,-1
    80002918:	b7d9                	j	800028de <waitx+0xb0>
    for (np = proc; np < &proc[NPROC]; np++)
    8000291a:	2c848493          	addi	s1,s1,712
    8000291e:	03348463          	beq	s1,s3,80002946 <waitx+0x118>
      if (np->parent == p)
    80002922:	7c9c                	ld	a5,56(s1)
    80002924:	ff279be3          	bne	a5,s2,8000291a <waitx+0xec>
        acquire(&np->lock);
    80002928:	8526                	mv	a0,s1
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	4f0080e7          	jalr	1264(ra) # 80000e1a <acquire>
        if (np->state == ZOMBIE)
    80002932:	4c9c                	lw	a5,24(s1)
    80002934:	f54787e3          	beq	a5,s4,80002882 <waitx+0x54>
        release(&np->lock);
    80002938:	8526                	mv	a0,s1
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	594080e7          	jalr	1428(ra) # 80000ece <release>
        havekids = 1;
    80002942:	8756                	mv	a4,s5
    80002944:	bfd9                	j	8000291a <waitx+0xec>
    if (!havekids || p->killed)
    80002946:	c305                	beqz	a4,80002966 <waitx+0x138>
    80002948:	02892783          	lw	a5,40(s2)
    8000294c:	ef89                	bnez	a5,80002966 <waitx+0x138>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000294e:	85ea                	mv	a1,s10
    80002950:	854a                	mv	a0,s2
    80002952:	00000097          	auipc	ra,0x0
    80002956:	e78080e7          	jalr	-392(ra) # 800027ca <sleep>
    havekids = 0;
    8000295a:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000295c:	00230497          	auipc	s1,0x230
    80002960:	8ec48493          	addi	s1,s1,-1812 # 80232248 <proc>
    80002964:	bf7d                	j	80002922 <waitx+0xf4>
      release(&wait_lock);
    80002966:	0022e517          	auipc	a0,0x22e
    8000296a:	52a50513          	addi	a0,a0,1322 # 80230e90 <wait_lock>
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	560080e7          	jalr	1376(ra) # 80000ece <release>
      return -1;
    80002976:	59fd                	li	s3,-1
    80002978:	b79d                	j	800028de <waitx+0xb0>

000000008000297a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000297a:	7139                	addi	sp,sp,-64
    8000297c:	fc06                	sd	ra,56(sp)
    8000297e:	f822                	sd	s0,48(sp)
    80002980:	f426                	sd	s1,40(sp)
    80002982:	f04a                	sd	s2,32(sp)
    80002984:	ec4e                	sd	s3,24(sp)
    80002986:	e852                	sd	s4,16(sp)
    80002988:	e456                	sd	s5,8(sp)
    8000298a:	0080                	addi	s0,sp,64
    8000298c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000298e:	00230497          	auipc	s1,0x230
    80002992:	8ba48493          	addi	s1,s1,-1862 # 80232248 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002996:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002998:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000299a:	0023b917          	auipc	s2,0x23b
    8000299e:	aae90913          	addi	s2,s2,-1362 # 8023d448 <tickslock>
    800029a2:	a811                	j	800029b6 <wakeup+0x3c>
      }
      release(&p->lock);
    800029a4:	8526                	mv	a0,s1
    800029a6:	ffffe097          	auipc	ra,0xffffe
    800029aa:	528080e7          	jalr	1320(ra) # 80000ece <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800029ae:	2c848493          	addi	s1,s1,712
    800029b2:	03248663          	beq	s1,s2,800029de <wakeup+0x64>
    if (p != myproc())
    800029b6:	fffff097          	auipc	ra,0xfffff
    800029ba:	2da080e7          	jalr	730(ra) # 80001c90 <myproc>
    800029be:	fea488e3          	beq	s1,a0,800029ae <wakeup+0x34>
      acquire(&p->lock);
    800029c2:	8526                	mv	a0,s1
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	456080e7          	jalr	1110(ra) # 80000e1a <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800029cc:	4c9c                	lw	a5,24(s1)
    800029ce:	fd379be3          	bne	a5,s3,800029a4 <wakeup+0x2a>
    800029d2:	709c                	ld	a5,32(s1)
    800029d4:	fd4798e3          	bne	a5,s4,800029a4 <wakeup+0x2a>
        p->state = RUNNABLE;
    800029d8:	0154ac23          	sw	s5,24(s1)
    800029dc:	b7e1                	j	800029a4 <wakeup+0x2a>
    }
  }
}
    800029de:	70e2                	ld	ra,56(sp)
    800029e0:	7442                	ld	s0,48(sp)
    800029e2:	74a2                	ld	s1,40(sp)
    800029e4:	7902                	ld	s2,32(sp)
    800029e6:	69e2                	ld	s3,24(sp)
    800029e8:	6a42                	ld	s4,16(sp)
    800029ea:	6aa2                	ld	s5,8(sp)
    800029ec:	6121                	addi	sp,sp,64
    800029ee:	8082                	ret

00000000800029f0 <reparent>:
{
    800029f0:	7179                	addi	sp,sp,-48
    800029f2:	f406                	sd	ra,40(sp)
    800029f4:	f022                	sd	s0,32(sp)
    800029f6:	ec26                	sd	s1,24(sp)
    800029f8:	e84a                	sd	s2,16(sp)
    800029fa:	e44e                	sd	s3,8(sp)
    800029fc:	e052                	sd	s4,0(sp)
    800029fe:	1800                	addi	s0,sp,48
    80002a00:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a02:	00230497          	auipc	s1,0x230
    80002a06:	84648493          	addi	s1,s1,-1978 # 80232248 <proc>
      pp->parent = initproc;
    80002a0a:	00006a17          	auipc	s4,0x6
    80002a0e:	1dea0a13          	addi	s4,s4,478 # 80008be8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a12:	0023b997          	auipc	s3,0x23b
    80002a16:	a3698993          	addi	s3,s3,-1482 # 8023d448 <tickslock>
    80002a1a:	a029                	j	80002a24 <reparent+0x34>
    80002a1c:	2c848493          	addi	s1,s1,712
    80002a20:	01348d63          	beq	s1,s3,80002a3a <reparent+0x4a>
    if (pp->parent == p)
    80002a24:	7c9c                	ld	a5,56(s1)
    80002a26:	ff279be3          	bne	a5,s2,80002a1c <reparent+0x2c>
      pp->parent = initproc;
    80002a2a:	000a3503          	ld	a0,0(s4)
    80002a2e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002a30:	00000097          	auipc	ra,0x0
    80002a34:	f4a080e7          	jalr	-182(ra) # 8000297a <wakeup>
    80002a38:	b7d5                	j	80002a1c <reparent+0x2c>
}
    80002a3a:	70a2                	ld	ra,40(sp)
    80002a3c:	7402                	ld	s0,32(sp)
    80002a3e:	64e2                	ld	s1,24(sp)
    80002a40:	6942                	ld	s2,16(sp)
    80002a42:	69a2                	ld	s3,8(sp)
    80002a44:	6a02                	ld	s4,0(sp)
    80002a46:	6145                	addi	sp,sp,48
    80002a48:	8082                	ret

0000000080002a4a <exit>:
{
    80002a4a:	7179                	addi	sp,sp,-48
    80002a4c:	f406                	sd	ra,40(sp)
    80002a4e:	f022                	sd	s0,32(sp)
    80002a50:	ec26                	sd	s1,24(sp)
    80002a52:	e84a                	sd	s2,16(sp)
    80002a54:	e44e                	sd	s3,8(sp)
    80002a56:	e052                	sd	s4,0(sp)
    80002a58:	1800                	addi	s0,sp,48
    80002a5a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002a5c:	fffff097          	auipc	ra,0xfffff
    80002a60:	234080e7          	jalr	564(ra) # 80001c90 <myproc>
    80002a64:	89aa                	mv	s3,a0
  if (p == initproc)
    80002a66:	00006797          	auipc	a5,0x6
    80002a6a:	1827b783          	ld	a5,386(a5) # 80008be8 <initproc>
    80002a6e:	0d050493          	addi	s1,a0,208
    80002a72:	15050913          	addi	s2,a0,336
    80002a76:	02a79363          	bne	a5,a0,80002a9c <exit+0x52>
    panic("init exiting");
    80002a7a:	00006517          	auipc	a0,0x6
    80002a7e:	84650513          	addi	a0,a0,-1978 # 800082c0 <digits+0x280>
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	aba080e7          	jalr	-1350(ra) # 8000053c <panic>
      fileclose(f);
    80002a8a:	00002097          	auipc	ra,0x2
    80002a8e:	70c080e7          	jalr	1804(ra) # 80005196 <fileclose>
      p->ofile[fd] = 0;
    80002a92:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002a96:	04a1                	addi	s1,s1,8
    80002a98:	01248563          	beq	s1,s2,80002aa2 <exit+0x58>
    if (p->ofile[fd])
    80002a9c:	6088                	ld	a0,0(s1)
    80002a9e:	f575                	bnez	a0,80002a8a <exit+0x40>
    80002aa0:	bfdd                	j	80002a96 <exit+0x4c>
  begin_op();
    80002aa2:	00002097          	auipc	ra,0x2
    80002aa6:	230080e7          	jalr	560(ra) # 80004cd2 <begin_op>
  iput(p->cwd);
    80002aaa:	1509b503          	ld	a0,336(s3)
    80002aae:	00002097          	auipc	ra,0x2
    80002ab2:	a38080e7          	jalr	-1480(ra) # 800044e6 <iput>
  end_op();
    80002ab6:	00002097          	auipc	ra,0x2
    80002aba:	296080e7          	jalr	662(ra) # 80004d4c <end_op>
  p->cwd = 0;
    80002abe:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002ac2:	0022e497          	auipc	s1,0x22e
    80002ac6:	3ce48493          	addi	s1,s1,974 # 80230e90 <wait_lock>
    80002aca:	8526                	mv	a0,s1
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	34e080e7          	jalr	846(ra) # 80000e1a <acquire>
  reparent(p);
    80002ad4:	854e                	mv	a0,s3
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	f1a080e7          	jalr	-230(ra) # 800029f0 <reparent>
  wakeup(p->parent);
    80002ade:	0389b503          	ld	a0,56(s3)
    80002ae2:	00000097          	auipc	ra,0x0
    80002ae6:	e98080e7          	jalr	-360(ra) # 8000297a <wakeup>
  acquire(&p->lock);
    80002aea:	854e                	mv	a0,s3
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	32e080e7          	jalr	814(ra) # 80000e1a <acquire>
  p->xstate = status;
    80002af4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002af8:	4795                	li	a5,5
    80002afa:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002afe:	00006797          	auipc	a5,0x6
    80002b02:	0f27a783          	lw	a5,242(a5) # 80008bf0 <ticks>
    80002b06:	2af9a623          	sw	a5,684(s3)
  release(&wait_lock);
    80002b0a:	8526                	mv	a0,s1
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	3c2080e7          	jalr	962(ra) # 80000ece <release>
  sched();
    80002b14:	00000097          	auipc	ra,0x0
    80002b18:	b1a080e7          	jalr	-1254(ra) # 8000262e <sched>
  panic("zombie exit");
    80002b1c:	00005517          	auipc	a0,0x5
    80002b20:	7b450513          	addi	a0,a0,1972 # 800082d0 <digits+0x290>
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	a18080e7          	jalr	-1512(ra) # 8000053c <panic>

0000000080002b2c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002b2c:	7179                	addi	sp,sp,-48
    80002b2e:	f406                	sd	ra,40(sp)
    80002b30:	f022                	sd	s0,32(sp)
    80002b32:	ec26                	sd	s1,24(sp)
    80002b34:	e84a                	sd	s2,16(sp)
    80002b36:	e44e                	sd	s3,8(sp)
    80002b38:	1800                	addi	s0,sp,48
    80002b3a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002b3c:	0022f497          	auipc	s1,0x22f
    80002b40:	70c48493          	addi	s1,s1,1804 # 80232248 <proc>
    80002b44:	0023b997          	auipc	s3,0x23b
    80002b48:	90498993          	addi	s3,s3,-1788 # 8023d448 <tickslock>
  {
    acquire(&p->lock);
    80002b4c:	8526                	mv	a0,s1
    80002b4e:	ffffe097          	auipc	ra,0xffffe
    80002b52:	2cc080e7          	jalr	716(ra) # 80000e1a <acquire>
    if (p->pid == pid)
    80002b56:	589c                	lw	a5,48(s1)
    80002b58:	01278d63          	beq	a5,s2,80002b72 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002b5c:	8526                	mv	a0,s1
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	370080e7          	jalr	880(ra) # 80000ece <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002b66:	2c848493          	addi	s1,s1,712
    80002b6a:	ff3491e3          	bne	s1,s3,80002b4c <kill+0x20>
  }
  return -1;
    80002b6e:	557d                	li	a0,-1
    80002b70:	a829                	j	80002b8a <kill+0x5e>
      p->killed = 1;
    80002b72:	4785                	li	a5,1
    80002b74:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002b76:	4c98                	lw	a4,24(s1)
    80002b78:	4789                	li	a5,2
    80002b7a:	00f70f63          	beq	a4,a5,80002b98 <kill+0x6c>
      release(&p->lock);
    80002b7e:	8526                	mv	a0,s1
    80002b80:	ffffe097          	auipc	ra,0xffffe
    80002b84:	34e080e7          	jalr	846(ra) # 80000ece <release>
      return 0;
    80002b88:	4501                	li	a0,0
}
    80002b8a:	70a2                	ld	ra,40(sp)
    80002b8c:	7402                	ld	s0,32(sp)
    80002b8e:	64e2                	ld	s1,24(sp)
    80002b90:	6942                	ld	s2,16(sp)
    80002b92:	69a2                	ld	s3,8(sp)
    80002b94:	6145                	addi	sp,sp,48
    80002b96:	8082                	ret
        p->state = RUNNABLE;
    80002b98:	478d                	li	a5,3
    80002b9a:	cc9c                	sw	a5,24(s1)
    80002b9c:	b7cd                	j	80002b7e <kill+0x52>

0000000080002b9e <setkilled>:

void setkilled(struct proc *p)
{
    80002b9e:	1101                	addi	sp,sp,-32
    80002ba0:	ec06                	sd	ra,24(sp)
    80002ba2:	e822                	sd	s0,16(sp)
    80002ba4:	e426                	sd	s1,8(sp)
    80002ba6:	1000                	addi	s0,sp,32
    80002ba8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	270080e7          	jalr	624(ra) # 80000e1a <acquire>
  p->killed = 1;
    80002bb2:	4785                	li	a5,1
    80002bb4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	316080e7          	jalr	790(ra) # 80000ece <release>
}
    80002bc0:	60e2                	ld	ra,24(sp)
    80002bc2:	6442                	ld	s0,16(sp)
    80002bc4:	64a2                	ld	s1,8(sp)
    80002bc6:	6105                	addi	sp,sp,32
    80002bc8:	8082                	ret

0000000080002bca <killed>:

int killed(struct proc *p)
{
    80002bca:	1101                	addi	sp,sp,-32
    80002bcc:	ec06                	sd	ra,24(sp)
    80002bce:	e822                	sd	s0,16(sp)
    80002bd0:	e426                	sd	s1,8(sp)
    80002bd2:	e04a                	sd	s2,0(sp)
    80002bd4:	1000                	addi	s0,sp,32
    80002bd6:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002bd8:	ffffe097          	auipc	ra,0xffffe
    80002bdc:	242080e7          	jalr	578(ra) # 80000e1a <acquire>
  k = p->killed;
    80002be0:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002be4:	8526                	mv	a0,s1
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	2e8080e7          	jalr	744(ra) # 80000ece <release>
  return k;
}
    80002bee:	854a                	mv	a0,s2
    80002bf0:	60e2                	ld	ra,24(sp)
    80002bf2:	6442                	ld	s0,16(sp)
    80002bf4:	64a2                	ld	s1,8(sp)
    80002bf6:	6902                	ld	s2,0(sp)
    80002bf8:	6105                	addi	sp,sp,32
    80002bfa:	8082                	ret

0000000080002bfc <wait>:
{
    80002bfc:	715d                	addi	sp,sp,-80
    80002bfe:	e486                	sd	ra,72(sp)
    80002c00:	e0a2                	sd	s0,64(sp)
    80002c02:	fc26                	sd	s1,56(sp)
    80002c04:	f84a                	sd	s2,48(sp)
    80002c06:	f44e                	sd	s3,40(sp)
    80002c08:	f052                	sd	s4,32(sp)
    80002c0a:	ec56                	sd	s5,24(sp)
    80002c0c:	e85a                	sd	s6,16(sp)
    80002c0e:	e45e                	sd	s7,8(sp)
    80002c10:	e062                	sd	s8,0(sp)
    80002c12:	0880                	addi	s0,sp,80
    80002c14:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002c16:	fffff097          	auipc	ra,0xfffff
    80002c1a:	07a080e7          	jalr	122(ra) # 80001c90 <myproc>
    80002c1e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002c20:	0022e517          	auipc	a0,0x22e
    80002c24:	27050513          	addi	a0,a0,624 # 80230e90 <wait_lock>
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	1f2080e7          	jalr	498(ra) # 80000e1a <acquire>
    havekids = 0;
    80002c30:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002c32:	4a15                	li	s4,5
        havekids = 1;
    80002c34:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002c36:	0023b997          	auipc	s3,0x23b
    80002c3a:	81298993          	addi	s3,s3,-2030 # 8023d448 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002c3e:	0022ec17          	auipc	s8,0x22e
    80002c42:	252c0c13          	addi	s8,s8,594 # 80230e90 <wait_lock>
    80002c46:	a0d1                	j	80002d0a <wait+0x10e>
          pid = pp->pid;
    80002c48:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002c4c:	000b0e63          	beqz	s6,80002c68 <wait+0x6c>
    80002c50:	4691                	li	a3,4
    80002c52:	02c48613          	addi	a2,s1,44
    80002c56:	85da                	mv	a1,s6
    80002c58:	05093503          	ld	a0,80(s2)
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	c5c080e7          	jalr	-932(ra) # 800018b8 <copyout>
    80002c64:	04054163          	bltz	a0,80002ca6 <wait+0xaa>
          freeproc(pp);
    80002c68:	8526                	mv	a0,s1
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	1d8080e7          	jalr	472(ra) # 80001e42 <freeproc>
          release(&pp->lock);
    80002c72:	8526                	mv	a0,s1
    80002c74:	ffffe097          	auipc	ra,0xffffe
    80002c78:	25a080e7          	jalr	602(ra) # 80000ece <release>
          release(&wait_lock);
    80002c7c:	0022e517          	auipc	a0,0x22e
    80002c80:	21450513          	addi	a0,a0,532 # 80230e90 <wait_lock>
    80002c84:	ffffe097          	auipc	ra,0xffffe
    80002c88:	24a080e7          	jalr	586(ra) # 80000ece <release>
}
    80002c8c:	854e                	mv	a0,s3
    80002c8e:	60a6                	ld	ra,72(sp)
    80002c90:	6406                	ld	s0,64(sp)
    80002c92:	74e2                	ld	s1,56(sp)
    80002c94:	7942                	ld	s2,48(sp)
    80002c96:	79a2                	ld	s3,40(sp)
    80002c98:	7a02                	ld	s4,32(sp)
    80002c9a:	6ae2                	ld	s5,24(sp)
    80002c9c:	6b42                	ld	s6,16(sp)
    80002c9e:	6ba2                	ld	s7,8(sp)
    80002ca0:	6c02                	ld	s8,0(sp)
    80002ca2:	6161                	addi	sp,sp,80
    80002ca4:	8082                	ret
            release(&pp->lock);
    80002ca6:	8526                	mv	a0,s1
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	226080e7          	jalr	550(ra) # 80000ece <release>
            release(&wait_lock);
    80002cb0:	0022e517          	auipc	a0,0x22e
    80002cb4:	1e050513          	addi	a0,a0,480 # 80230e90 <wait_lock>
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	216080e7          	jalr	534(ra) # 80000ece <release>
            return -1;
    80002cc0:	59fd                	li	s3,-1
    80002cc2:	b7e9                	j	80002c8c <wait+0x90>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002cc4:	2c848493          	addi	s1,s1,712
    80002cc8:	03348463          	beq	s1,s3,80002cf0 <wait+0xf4>
      if (pp->parent == p)
    80002ccc:	7c9c                	ld	a5,56(s1)
    80002cce:	ff279be3          	bne	a5,s2,80002cc4 <wait+0xc8>
        acquire(&pp->lock);
    80002cd2:	8526                	mv	a0,s1
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	146080e7          	jalr	326(ra) # 80000e1a <acquire>
        if (pp->state == ZOMBIE)
    80002cdc:	4c9c                	lw	a5,24(s1)
    80002cde:	f74785e3          	beq	a5,s4,80002c48 <wait+0x4c>
        release(&pp->lock);
    80002ce2:	8526                	mv	a0,s1
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	1ea080e7          	jalr	490(ra) # 80000ece <release>
        havekids = 1;
    80002cec:	8756                	mv	a4,s5
    80002cee:	bfd9                	j	80002cc4 <wait+0xc8>
    if (!havekids || killed(p))
    80002cf0:	c31d                	beqz	a4,80002d16 <wait+0x11a>
    80002cf2:	854a                	mv	a0,s2
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	ed6080e7          	jalr	-298(ra) # 80002bca <killed>
    80002cfc:	ed09                	bnez	a0,80002d16 <wait+0x11a>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002cfe:	85e2                	mv	a1,s8
    80002d00:	854a                	mv	a0,s2
    80002d02:	00000097          	auipc	ra,0x0
    80002d06:	ac8080e7          	jalr	-1336(ra) # 800027ca <sleep>
    havekids = 0;
    80002d0a:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002d0c:	0022f497          	auipc	s1,0x22f
    80002d10:	53c48493          	addi	s1,s1,1340 # 80232248 <proc>
    80002d14:	bf65                	j	80002ccc <wait+0xd0>
      release(&wait_lock);
    80002d16:	0022e517          	auipc	a0,0x22e
    80002d1a:	17a50513          	addi	a0,a0,378 # 80230e90 <wait_lock>
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	1b0080e7          	jalr	432(ra) # 80000ece <release>
      return -1;
    80002d26:	59fd                	li	s3,-1
    80002d28:	b795                	j	80002c8c <wait+0x90>

0000000080002d2a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002d2a:	7179                	addi	sp,sp,-48
    80002d2c:	f406                	sd	ra,40(sp)
    80002d2e:	f022                	sd	s0,32(sp)
    80002d30:	ec26                	sd	s1,24(sp)
    80002d32:	e84a                	sd	s2,16(sp)
    80002d34:	e44e                	sd	s3,8(sp)
    80002d36:	e052                	sd	s4,0(sp)
    80002d38:	1800                	addi	s0,sp,48
    80002d3a:	84aa                	mv	s1,a0
    80002d3c:	892e                	mv	s2,a1
    80002d3e:	89b2                	mv	s3,a2
    80002d40:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	f4e080e7          	jalr	-178(ra) # 80001c90 <myproc>
  if (user_dst)
    80002d4a:	c08d                	beqz	s1,80002d6c <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002d4c:	86d2                	mv	a3,s4
    80002d4e:	864e                	mv	a2,s3
    80002d50:	85ca                	mv	a1,s2
    80002d52:	6928                	ld	a0,80(a0)
    80002d54:	fffff097          	auipc	ra,0xfffff
    80002d58:	b64080e7          	jalr	-1180(ra) # 800018b8 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002d5c:	70a2                	ld	ra,40(sp)
    80002d5e:	7402                	ld	s0,32(sp)
    80002d60:	64e2                	ld	s1,24(sp)
    80002d62:	6942                	ld	s2,16(sp)
    80002d64:	69a2                	ld	s3,8(sp)
    80002d66:	6a02                	ld	s4,0(sp)
    80002d68:	6145                	addi	sp,sp,48
    80002d6a:	8082                	ret
    memmove((char *)dst, src, len);
    80002d6c:	000a061b          	sext.w	a2,s4
    80002d70:	85ce                	mv	a1,s3
    80002d72:	854a                	mv	a0,s2
    80002d74:	ffffe097          	auipc	ra,0xffffe
    80002d78:	1fe080e7          	jalr	510(ra) # 80000f72 <memmove>
    return 0;
    80002d7c:	8526                	mv	a0,s1
    80002d7e:	bff9                	j	80002d5c <either_copyout+0x32>

0000000080002d80 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002d80:	7179                	addi	sp,sp,-48
    80002d82:	f406                	sd	ra,40(sp)
    80002d84:	f022                	sd	s0,32(sp)
    80002d86:	ec26                	sd	s1,24(sp)
    80002d88:	e84a                	sd	s2,16(sp)
    80002d8a:	e44e                	sd	s3,8(sp)
    80002d8c:	e052                	sd	s4,0(sp)
    80002d8e:	1800                	addi	s0,sp,48
    80002d90:	892a                	mv	s2,a0
    80002d92:	84ae                	mv	s1,a1
    80002d94:	89b2                	mv	s3,a2
    80002d96:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002d98:	fffff097          	auipc	ra,0xfffff
    80002d9c:	ef8080e7          	jalr	-264(ra) # 80001c90 <myproc>
  if (user_src)
    80002da0:	c08d                	beqz	s1,80002dc2 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002da2:	86d2                	mv	a3,s4
    80002da4:	864e                	mv	a2,s3
    80002da6:	85ca                	mv	a1,s2
    80002da8:	6928                	ld	a0,80(a0)
    80002daa:	fffff097          	auipc	ra,0xfffff
    80002dae:	bd2080e7          	jalr	-1070(ra) # 8000197c <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002db2:	70a2                	ld	ra,40(sp)
    80002db4:	7402                	ld	s0,32(sp)
    80002db6:	64e2                	ld	s1,24(sp)
    80002db8:	6942                	ld	s2,16(sp)
    80002dba:	69a2                	ld	s3,8(sp)
    80002dbc:	6a02                	ld	s4,0(sp)
    80002dbe:	6145                	addi	sp,sp,48
    80002dc0:	8082                	ret
    memmove(dst, (char *)src, len);
    80002dc2:	000a061b          	sext.w	a2,s4
    80002dc6:	85ce                	mv	a1,s3
    80002dc8:	854a                	mv	a0,s2
    80002dca:	ffffe097          	auipc	ra,0xffffe
    80002dce:	1a8080e7          	jalr	424(ra) # 80000f72 <memmove>
    return 0;
    80002dd2:	8526                	mv	a0,s1
    80002dd4:	bff9                	j	80002db2 <either_copyin+0x32>

0000000080002dd6 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002dd6:	711d                	addi	sp,sp,-96
    80002dd8:	ec86                	sd	ra,88(sp)
    80002dda:	e8a2                	sd	s0,80(sp)
    80002ddc:	e4a6                	sd	s1,72(sp)
    80002dde:	e0ca                	sd	s2,64(sp)
    80002de0:	fc4e                	sd	s3,56(sp)
    80002de2:	f852                	sd	s4,48(sp)
    80002de4:	f456                	sd	s5,40(sp)
    80002de6:	f05a                	sd	s6,32(sp)
    80002de8:	ec5e                	sd	s7,24(sp)
    80002dea:	e862                	sd	s8,16(sp)
    80002dec:	e466                	sd	s9,8(sp)
    80002dee:	e06a                	sd	s10,0(sp)
    80002df0:	1080                	addi	s0,sp,96
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002df2:	00005517          	auipc	a0,0x5
    80002df6:	6ee50513          	addi	a0,a0,1774 # 800084e0 <states.0+0x178>
    80002dfa:	ffffd097          	auipc	ra,0xffffd
    80002dfe:	78c080e7          	jalr	1932(ra) # 80000586 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002e02:	0022f497          	auipc	s1,0x22f
    80002e06:	59e48493          	addi	s1,s1,1438 # 802323a0 <proc+0x158>
    80002e0a:	0023a997          	auipc	s3,0x23a
    80002e0e:	79698993          	addi	s3,s3,1942 # 8023d5a0 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002e12:	4c15                	li	s8,5
      state = states[p->state];
    else
      state = "???";
    80002e14:	00005a17          	auipc	s4,0x5
    80002e18:	4cca0a13          	addi	s4,s4,1228 # 800082e0 <digits+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002e1c:	00005b97          	auipc	s7,0x5
    80002e20:	4ccb8b93          	addi	s7,s7,1228 # 800082e8 <digits+0x2a8>
    printf("\n");
    80002e24:	00005b17          	auipc	s6,0x5
    80002e28:	6bcb0b13          	addi	s6,s6,1724 # 800084e0 <states.0+0x178>
    printf("Running time : %d\nWaiting time : %d\nState:%s\nPriority:%d\n", p->rtime, p->wtime,state,p->priority);
    80002e2c:	00005a97          	auipc	s5,0x5
    80002e30:	4cca8a93          	addi	s5,s5,1228 # 800082f8 <digits+0x2b8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002e34:	00005c97          	auipc	s9,0x5
    80002e38:	534c8c93          	addi	s9,s9,1332 # 80008368 <states.0>
    80002e3c:	a83d                	j	80002e7a <procdump+0xa4>
    printf("%d %s %s", p->pid, state, p->name);
    80002e3e:	86ca                	mv	a3,s2
    80002e40:	866a                	mv	a2,s10
    80002e42:	ed892583          	lw	a1,-296(s2)
    80002e46:	855e                	mv	a0,s7
    80002e48:	ffffd097          	auipc	ra,0xffffd
    80002e4c:	73e080e7          	jalr	1854(ra) # 80000586 <printf>
    printf("\n");
    80002e50:	855a                	mv	a0,s6
    80002e52:	ffffd097          	auipc	ra,0xffffd
    80002e56:	734080e7          	jalr	1844(ra) # 80000586 <printf>
    printf("Running time : %d\nWaiting time : %d\nState:%s\nPriority:%d\n", p->rtime, p->wtime,state,p->priority);
    80002e5a:	16892703          	lw	a4,360(s2)
    80002e5e:	86ea                	mv	a3,s10
    80002e60:	15892603          	lw	a2,344(s2)
    80002e64:	15092583          	lw	a1,336(s2)
    80002e68:	8556                	mv	a0,s5
    80002e6a:	ffffd097          	auipc	ra,0xffffd
    80002e6e:	71c080e7          	jalr	1820(ra) # 80000586 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002e72:	2c848493          	addi	s1,s1,712
    80002e76:	03348463          	beq	s1,s3,80002e9e <procdump+0xc8>
    if (p->state == UNUSED)
    80002e7a:	8926                	mv	s2,s1
    80002e7c:	ec04a783          	lw	a5,-320(s1)
    80002e80:	dbed                	beqz	a5,80002e72 <procdump+0x9c>
      state = "???";
    80002e82:	8d52                	mv	s10,s4
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002e84:	fafc6de3          	bltu	s8,a5,80002e3e <procdump+0x68>
    80002e88:	02079713          	slli	a4,a5,0x20
    80002e8c:	01d75793          	srli	a5,a4,0x1d
    80002e90:	97e6                	add	a5,a5,s9
    80002e92:	0007bd03          	ld	s10,0(a5)
    80002e96:	fa0d14e3          	bnez	s10,80002e3e <procdump+0x68>
      state = "???";
    80002e9a:	8d52                	mv	s10,s4
    80002e9c:	b74d                	j	80002e3e <procdump+0x68>
  }
}
    80002e9e:	60e6                	ld	ra,88(sp)
    80002ea0:	6446                	ld	s0,80(sp)
    80002ea2:	64a6                	ld	s1,72(sp)
    80002ea4:	6906                	ld	s2,64(sp)
    80002ea6:	79e2                	ld	s3,56(sp)
    80002ea8:	7a42                	ld	s4,48(sp)
    80002eaa:	7aa2                	ld	s5,40(sp)
    80002eac:	7b02                	ld	s6,32(sp)
    80002eae:	6be2                	ld	s7,24(sp)
    80002eb0:	6c42                	ld	s8,16(sp)
    80002eb2:	6ca2                	ld	s9,8(sp)
    80002eb4:	6d02                	ld	s10,0(sp)
    80002eb6:	6125                	addi	sp,sp,96
    80002eb8:	8082                	ret

0000000080002eba <swtch>:
    80002eba:	00153023          	sd	ra,0(a0)
    80002ebe:	00253423          	sd	sp,8(a0)
    80002ec2:	e900                	sd	s0,16(a0)
    80002ec4:	ed04                	sd	s1,24(a0)
    80002ec6:	03253023          	sd	s2,32(a0)
    80002eca:	03353423          	sd	s3,40(a0)
    80002ece:	03453823          	sd	s4,48(a0)
    80002ed2:	03553c23          	sd	s5,56(a0)
    80002ed6:	05653023          	sd	s6,64(a0)
    80002eda:	05753423          	sd	s7,72(a0)
    80002ede:	05853823          	sd	s8,80(a0)
    80002ee2:	05953c23          	sd	s9,88(a0)
    80002ee6:	07a53023          	sd	s10,96(a0)
    80002eea:	07b53423          	sd	s11,104(a0)
    80002eee:	0005b083          	ld	ra,0(a1)
    80002ef2:	0085b103          	ld	sp,8(a1)
    80002ef6:	6980                	ld	s0,16(a1)
    80002ef8:	6d84                	ld	s1,24(a1)
    80002efa:	0205b903          	ld	s2,32(a1)
    80002efe:	0285b983          	ld	s3,40(a1)
    80002f02:	0305ba03          	ld	s4,48(a1)
    80002f06:	0385ba83          	ld	s5,56(a1)
    80002f0a:	0405bb03          	ld	s6,64(a1)
    80002f0e:	0485bb83          	ld	s7,72(a1)
    80002f12:	0505bc03          	ld	s8,80(a1)
    80002f16:	0585bc83          	ld	s9,88(a1)
    80002f1a:	0605bd03          	ld	s10,96(a1)
    80002f1e:	0685bd83          	ld	s11,104(a1)
    80002f22:	8082                	ret

0000000080002f24 <trapinit>:
extern int devintr();

int pagefaulthandler(void *va, pagetable_t pagetable);

void trapinit(void)
{
    80002f24:	1141                	addi	sp,sp,-16
    80002f26:	e406                	sd	ra,8(sp)
    80002f28:	e022                	sd	s0,0(sp)
    80002f2a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002f2c:	00005597          	auipc	a1,0x5
    80002f30:	46c58593          	addi	a1,a1,1132 # 80008398 <states.0+0x30>
    80002f34:	0023a517          	auipc	a0,0x23a
    80002f38:	51450513          	addi	a0,a0,1300 # 8023d448 <tickslock>
    80002f3c:	ffffe097          	auipc	ra,0xffffe
    80002f40:	e4e080e7          	jalr	-434(ra) # 80000d8a <initlock>
}
    80002f44:	60a2                	ld	ra,8(sp)
    80002f46:	6402                	ld	s0,0(sp)
    80002f48:	0141                	addi	sp,sp,16
    80002f4a:	8082                	ret

0000000080002f4c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002f4c:	1141                	addi	sp,sp,-16
    80002f4e:	e422                	sd	s0,8(sp)
    80002f50:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f52:	00004797          	auipc	a5,0x4
    80002f56:	86e78793          	addi	a5,a5,-1938 # 800067c0 <kernelvec>
    80002f5a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002f5e:	6422                	ld	s0,8(sp)
    80002f60:	0141                	addi	sp,sp,16
    80002f62:	8082                	ret

0000000080002f64 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002f64:	1141                	addi	sp,sp,-16
    80002f66:	e406                	sd	ra,8(sp)
    80002f68:	e022                	sd	s0,0(sp)
    80002f6a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	d24080e7          	jalr	-732(ra) # 80001c90 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f74:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002f78:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f7a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002f7e:	00004697          	auipc	a3,0x4
    80002f82:	08268693          	addi	a3,a3,130 # 80007000 <_trampoline>
    80002f86:	00004717          	auipc	a4,0x4
    80002f8a:	07a70713          	addi	a4,a4,122 # 80007000 <_trampoline>
    80002f8e:	8f15                	sub	a4,a4,a3
    80002f90:	040007b7          	lui	a5,0x4000
    80002f94:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002f96:	07b2                	slli	a5,a5,0xc
    80002f98:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f9a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002f9e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002fa0:	18002673          	csrr	a2,satp
    80002fa4:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002fa6:	6d30                	ld	a2,88(a0)
    80002fa8:	6138                	ld	a4,64(a0)
    80002faa:	6585                	lui	a1,0x1
    80002fac:	972e                	add	a4,a4,a1
    80002fae:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002fb0:	6d38                	ld	a4,88(a0)
    80002fb2:	00000617          	auipc	a2,0x0
    80002fb6:	2c860613          	addi	a2,a2,712 # 8000327a <usertrap>
    80002fba:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002fbc:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002fbe:	8612                	mv	a2,tp
    80002fc0:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fc2:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002fc6:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002fca:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fce:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002fd2:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002fd4:	6f18                	ld	a4,24(a4)
    80002fd6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002fda:	6928                	ld	a0,80(a0)
    80002fdc:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002fde:	00004717          	auipc	a4,0x4
    80002fe2:	0be70713          	addi	a4,a4,190 # 8000709c <userret>
    80002fe6:	8f15                	sub	a4,a4,a3
    80002fe8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002fea:	577d                	li	a4,-1
    80002fec:	177e                	slli	a4,a4,0x3f
    80002fee:	8d59                	or	a0,a0,a4
    80002ff0:	9782                	jalr	a5
}
    80002ff2:	60a2                	ld	ra,8(sp)
    80002ff4:	6402                	ld	s0,0(sp)
    80002ff6:	0141                	addi	sp,sp,16
    80002ff8:	8082                	ret

0000000080002ffa <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002ffa:	1101                	addi	sp,sp,-32
    80002ffc:	ec06                	sd	ra,24(sp)
    80002ffe:	e822                	sd	s0,16(sp)
    80003000:	e426                	sd	s1,8(sp)
    80003002:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003004:	0023a497          	auipc	s1,0x23a
    80003008:	44448493          	addi	s1,s1,1092 # 8023d448 <tickslock>
    8000300c:	8526                	mv	a0,s1
    8000300e:	ffffe097          	auipc	ra,0xffffe
    80003012:	e0c080e7          	jalr	-500(ra) # 80000e1a <acquire>
  ticks++;
    80003016:	00006517          	auipc	a0,0x6
    8000301a:	bda50513          	addi	a0,a0,-1062 # 80008bf0 <ticks>
    8000301e:	411c                	lw	a5,0(a0)
    80003020:	2785                	addiw	a5,a5,1
    80003022:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003024:	00000097          	auipc	ra,0x0
    80003028:	956080e7          	jalr	-1706(ra) # 8000297a <wakeup>
  release(&tickslock);
    8000302c:	8526                	mv	a0,s1
    8000302e:	ffffe097          	auipc	ra,0xffffe
    80003032:	ea0080e7          	jalr	-352(ra) # 80000ece <release>
  update_time();
    80003036:	fffff097          	auipc	ra,0xfffff
    8000303a:	1a4080e7          	jalr	420(ra) # 800021da <update_time>
}
    8000303e:	60e2                	ld	ra,24(sp)
    80003040:	6442                	ld	s0,16(sp)
    80003042:	64a2                	ld	s1,8(sp)
    80003044:	6105                	addi	sp,sp,32
    80003046:	8082                	ret

0000000080003048 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003048:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    8000304c:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    8000304e:	0807df63          	bgez	a5,800030ec <devintr+0xa4>
{
    80003052:	1101                	addi	sp,sp,-32
    80003054:	ec06                	sd	ra,24(sp)
    80003056:	e822                	sd	s0,16(sp)
    80003058:	e426                	sd	s1,8(sp)
    8000305a:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    8000305c:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80003060:	46a5                	li	a3,9
    80003062:	00d70d63          	beq	a4,a3,8000307c <devintr+0x34>
  else if (scause == 0x8000000000000001L)
    80003066:	577d                	li	a4,-1
    80003068:	177e                	slli	a4,a4,0x3f
    8000306a:	0705                	addi	a4,a4,1
    return 0;
    8000306c:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    8000306e:	04e78e63          	beq	a5,a4,800030ca <devintr+0x82>
  }
}
    80003072:	60e2                	ld	ra,24(sp)
    80003074:	6442                	ld	s0,16(sp)
    80003076:	64a2                	ld	s1,8(sp)
    80003078:	6105                	addi	sp,sp,32
    8000307a:	8082                	ret
    int irq = plic_claim();
    8000307c:	00004097          	auipc	ra,0x4
    80003080:	84c080e7          	jalr	-1972(ra) # 800068c8 <plic_claim>
    80003084:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80003086:	47a9                	li	a5,10
    80003088:	02f50763          	beq	a0,a5,800030b6 <devintr+0x6e>
    else if (irq == VIRTIO0_IRQ)
    8000308c:	4785                	li	a5,1
    8000308e:	02f50963          	beq	a0,a5,800030c0 <devintr+0x78>
    return 1;
    80003092:	4505                	li	a0,1
    else if (irq)
    80003094:	dcf9                	beqz	s1,80003072 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80003096:	85a6                	mv	a1,s1
    80003098:	00005517          	auipc	a0,0x5
    8000309c:	30850513          	addi	a0,a0,776 # 800083a0 <states.0+0x38>
    800030a0:	ffffd097          	auipc	ra,0xffffd
    800030a4:	4e6080e7          	jalr	1254(ra) # 80000586 <printf>
      plic_complete(irq);
    800030a8:	8526                	mv	a0,s1
    800030aa:	00004097          	auipc	ra,0x4
    800030ae:	842080e7          	jalr	-1982(ra) # 800068ec <plic_complete>
    return 1;
    800030b2:	4505                	li	a0,1
    800030b4:	bf7d                	j	80003072 <devintr+0x2a>
      uartintr();
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	8de080e7          	jalr	-1826(ra) # 80000994 <uartintr>
    if (irq)
    800030be:	b7ed                	j	800030a8 <devintr+0x60>
      virtio_disk_intr();
    800030c0:	00004097          	auipc	ra,0x4
    800030c4:	cf2080e7          	jalr	-782(ra) # 80006db2 <virtio_disk_intr>
    if (irq)
    800030c8:	b7c5                	j	800030a8 <devintr+0x60>
    if (cpuid() == 0)
    800030ca:	fffff097          	auipc	ra,0xfffff
    800030ce:	b9a080e7          	jalr	-1126(ra) # 80001c64 <cpuid>
    800030d2:	c901                	beqz	a0,800030e2 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800030d4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800030d8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800030da:	14479073          	csrw	sip,a5
    return 2;
    800030de:	4509                	li	a0,2
    800030e0:	bf49                	j	80003072 <devintr+0x2a>
      clockintr();
    800030e2:	00000097          	auipc	ra,0x0
    800030e6:	f18080e7          	jalr	-232(ra) # 80002ffa <clockintr>
    800030ea:	b7ed                	j	800030d4 <devintr+0x8c>
}
    800030ec:	8082                	ret

00000000800030ee <kerneltrap>:
{
    800030ee:	7179                	addi	sp,sp,-48
    800030f0:	f406                	sd	ra,40(sp)
    800030f2:	f022                	sd	s0,32(sp)
    800030f4:	ec26                	sd	s1,24(sp)
    800030f6:	e84a                	sd	s2,16(sp)
    800030f8:	e44e                	sd	s3,8(sp)
    800030fa:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030fc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003100:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003104:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003108:	1004f793          	andi	a5,s1,256
    8000310c:	cb85                	beqz	a5,8000313c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000310e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003112:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003114:	ef85                	bnez	a5,8000314c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003116:	00000097          	auipc	ra,0x0
    8000311a:	f32080e7          	jalr	-206(ra) # 80003048 <devintr>
    8000311e:	cd1d                	beqz	a0,8000315c <kerneltrap+0x6e>
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003120:	4789                	li	a5,2
    80003122:	06f50a63          	beq	a0,a5,80003196 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003126:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000312a:	10049073          	csrw	sstatus,s1
}
    8000312e:	70a2                	ld	ra,40(sp)
    80003130:	7402                	ld	s0,32(sp)
    80003132:	64e2                	ld	s1,24(sp)
    80003134:	6942                	ld	s2,16(sp)
    80003136:	69a2                	ld	s3,8(sp)
    80003138:	6145                	addi	sp,sp,48
    8000313a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000313c:	00005517          	auipc	a0,0x5
    80003140:	28450513          	addi	a0,a0,644 # 800083c0 <states.0+0x58>
    80003144:	ffffd097          	auipc	ra,0xffffd
    80003148:	3f8080e7          	jalr	1016(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    8000314c:	00005517          	auipc	a0,0x5
    80003150:	29c50513          	addi	a0,a0,668 # 800083e8 <states.0+0x80>
    80003154:	ffffd097          	auipc	ra,0xffffd
    80003158:	3e8080e7          	jalr	1000(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    8000315c:	85ce                	mv	a1,s3
    8000315e:	00005517          	auipc	a0,0x5
    80003162:	2aa50513          	addi	a0,a0,682 # 80008408 <states.0+0xa0>
    80003166:	ffffd097          	auipc	ra,0xffffd
    8000316a:	420080e7          	jalr	1056(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000316e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003172:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003176:	00005517          	auipc	a0,0x5
    8000317a:	2a250513          	addi	a0,a0,674 # 80008418 <states.0+0xb0>
    8000317e:	ffffd097          	auipc	ra,0xffffd
    80003182:	408080e7          	jalr	1032(ra) # 80000586 <printf>
    panic("kerneltrap");
    80003186:	00005517          	auipc	a0,0x5
    8000318a:	2aa50513          	addi	a0,a0,682 # 80008430 <states.0+0xc8>
    8000318e:	ffffd097          	auipc	ra,0xffffd
    80003192:	3ae080e7          	jalr	942(ra) # 8000053c <panic>
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003196:	fffff097          	auipc	ra,0xfffff
    8000319a:	afa080e7          	jalr	-1286(ra) # 80001c90 <myproc>
    8000319e:	d541                	beqz	a0,80003126 <kerneltrap+0x38>
    800031a0:	fffff097          	auipc	ra,0xfffff
    800031a4:	af0080e7          	jalr	-1296(ra) # 80001c90 <myproc>
    800031a8:	4d18                	lw	a4,24(a0)
    800031aa:	4791                	li	a5,4
    800031ac:	f6f71de3          	bne	a4,a5,80003126 <kerneltrap+0x38>
      yield();
    800031b0:	fffff097          	auipc	ra,0xfffff
    800031b4:	554080e7          	jalr	1364(ra) # 80002704 <yield>
    800031b8:	b7bd                	j	80003126 <kerneltrap+0x38>

00000000800031ba <pagefaulthandler>:

int pagefaulthandler(void *va, pagetable_t pagetable)
{
    800031ba:	7179                	addi	sp,sp,-48
    800031bc:	f406                	sd	ra,40(sp)
    800031be:	f022                	sd	s0,32(sp)
    800031c0:	ec26                	sd	s1,24(sp)
    800031c2:	e84a                	sd	s2,16(sp)
    800031c4:	e44e                	sd	s3,8(sp)
    800031c6:	e052                	sd	s4,0(sp)
    800031c8:	1800                	addi	s0,sp,48
    800031ca:	84aa                	mv	s1,a0
    800031cc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800031ce:	fffff097          	auipc	ra,0xfffff
    800031d2:	ac2080e7          	jalr	-1342(ra) # 80001c90 <myproc>
  if ((uint64)va >= MAXVA || ((uint64)va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE && PGSIZE && (uint64)va <= PGROUNDDOWN(p->trapframe->sp)))
    800031d6:	57fd                	li	a5,-1
    800031d8:	83e9                	srli	a5,a5,0x1a
    800031da:	0897e663          	bltu	a5,s1,80003266 <pagefaulthandler+0xac>
    800031de:	6d38                	ld	a4,88(a0)
    800031e0:	77fd                	lui	a5,0xfffff
    800031e2:	7b18                	ld	a4,48(a4)
    800031e4:	8f7d                	and	a4,a4,a5
    800031e6:	97ba                	add	a5,a5,a4
    800031e8:	00f4e463          	bltu	s1,a5,800031f0 <pagefaulthandler+0x36>
    800031ec:	06977f63          	bgeu	a4,s1,8000326a <pagefaulthandler+0xb0>

  pte_t *pte;
  uint64 pa;
  uint flags;
  va = (void*)PGROUNDDOWN((uint64)va);
  pte = walk(pagetable,(uint64)va,0);
    800031f0:	4601                	li	a2,0
    800031f2:	75fd                	lui	a1,0xfffff
    800031f4:	8de5                	and	a1,a1,s1
    800031f6:	854a                	mv	a0,s2
    800031f8:	ffffe097          	auipc	ra,0xffffe
    800031fc:	000080e7          	jalr	ra # 800011f8 <walk>
    80003200:	84aa                	mv	s1,a0
  if(pte == 0)
    80003202:	c535                	beqz	a0,8000326e <pagefaulthandler+0xb4>
  {
    return -1;
  }
  pa = PTE2PA(*pte);
    80003204:	611c                	ld	a5,0(a0)
    80003206:	00a7d913          	srli	s2,a5,0xa
    8000320a:	0932                	slli	s2,s2,0xc
  if(pa == 0)
    8000320c:	06090363          	beqz	s2,80003272 <pagefaulthandler+0xb8>
  {
    return -1;
  }
  flags = PTE_FLAGS(*pte);
    80003210:	0007871b          	sext.w	a4,a5
  if(flags & PTE_C)
    80003214:	1007f793          	andi	a5,a5,256
    *pte = PA2PTE(mem) |flags;
    kfree((void*)pa);
    return 0;
  }

  return 0;
    80003218:	4501                	li	a0,0
  if(flags & PTE_C)
    8000321a:	eb89                	bnez	a5,8000322c <pagefaulthandler+0x72>
    8000321c:	70a2                	ld	ra,40(sp)
    8000321e:	7402                	ld	s0,32(sp)
    80003220:	64e2                	ld	s1,24(sp)
    80003222:	6942                	ld	s2,16(sp)
    80003224:	69a2                	ld	s3,8(sp)
    80003226:	6a02                	ld	s4,0(sp)
    80003228:	6145                	addi	sp,sp,48
    8000322a:	8082                	ret
    flags = (flags | PTE_W) & (~PTE_C);
    8000322c:	2ff77713          	andi	a4,a4,767
    80003230:	00476993          	ori	s3,a4,4
    mem = kalloc();
    80003234:	ffffe097          	auipc	ra,0xffffe
    80003238:	a04080e7          	jalr	-1532(ra) # 80000c38 <kalloc>
    8000323c:	8a2a                	mv	s4,a0
    if(mem == 0)
    8000323e:	cd05                	beqz	a0,80003276 <pagefaulthandler+0xbc>
    memmove(mem,(void*)pa,PGSIZE);
    80003240:	6605                	lui	a2,0x1
    80003242:	85ca                	mv	a1,s2
    80003244:	ffffe097          	auipc	ra,0xffffe
    80003248:	d2e080e7          	jalr	-722(ra) # 80000f72 <memmove>
    *pte = PA2PTE(mem) |flags;
    8000324c:	00ca5a13          	srli	s4,s4,0xc
    80003250:	0a2a                	slli	s4,s4,0xa
    80003252:	0149e733          	or	a4,s3,s4
    80003256:	e098                	sd	a4,0(s1)
    kfree((void*)pa);
    80003258:	854a                	mv	a0,s2
    8000325a:	ffffd097          	auipc	ra,0xffffd
    8000325e:	78a080e7          	jalr	1930(ra) # 800009e4 <kfree>
    return 0;
    80003262:	4501                	li	a0,0
    80003264:	bf65                	j	8000321c <pagefaulthandler+0x62>
    return -2;
    80003266:	5579                	li	a0,-2
    80003268:	bf55                	j	8000321c <pagefaulthandler+0x62>
    8000326a:	5579                	li	a0,-2
    8000326c:	bf45                	j	8000321c <pagefaulthandler+0x62>
    return -1;
    8000326e:	557d                	li	a0,-1
    80003270:	b775                	j	8000321c <pagefaulthandler+0x62>
    return -1;
    80003272:	557d                	li	a0,-1
    80003274:	b765                	j	8000321c <pagefaulthandler+0x62>
      return -1;
    80003276:	557d                	li	a0,-1
    80003278:	b755                	j	8000321c <pagefaulthandler+0x62>

000000008000327a <usertrap>:
{
    8000327a:	1101                	addi	sp,sp,-32
    8000327c:	ec06                	sd	ra,24(sp)
    8000327e:	e822                	sd	s0,16(sp)
    80003280:	e426                	sd	s1,8(sp)
    80003282:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003284:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80003288:	1007f793          	andi	a5,a5,256
    8000328c:	eba5                	bnez	a5,800032fc <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000328e:	00003797          	auipc	a5,0x3
    80003292:	53278793          	addi	a5,a5,1330 # 800067c0 <kernelvec>
    80003296:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000329a:	fffff097          	auipc	ra,0xfffff
    8000329e:	9f6080e7          	jalr	-1546(ra) # 80001c90 <myproc>
    800032a2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800032a4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032a6:	14102773          	csrr	a4,sepc
    800032aa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032ac:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    800032b0:	47a1                	li	a5,8
    800032b2:	04f70d63          	beq	a4,a5,8000330c <usertrap+0x92>
  else if ((which_dev = devintr()) != 0)
    800032b6:	00000097          	auipc	ra,0x0
    800032ba:	d92080e7          	jalr	-622(ra) # 80003048 <devintr>
    800032be:	e935                	bnez	a0,80003332 <usertrap+0xb8>
    800032c0:	14202773          	csrr	a4,scause
  else if ((r_scause() == 13 || r_scause() == 15))
    800032c4:	47b5                	li	a5,13
    800032c6:	00f70763          	beq	a4,a5,800032d4 <usertrap+0x5a>
    800032ca:	14202773          	csrr	a4,scause
    800032ce:	47bd                	li	a5,15
    800032d0:	08f71c63          	bne	a4,a5,80003368 <usertrap+0xee>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800032d4:	143027f3          	csrr	a5,stval
    if(r_stval() == 0)
    800032d8:	c3d1                	beqz	a5,8000335c <usertrap+0xe2>
    800032da:	14302573          	csrr	a0,stval
    int res = pagefaulthandler((void *)r_stval(), p->pagetable);
    800032de:	68ac                	ld	a1,80(s1)
    800032e0:	00000097          	auipc	ra,0x0
    800032e4:	eda080e7          	jalr	-294(ra) # 800031ba <pagefaulthandler>
    if (res == -1 || res == -2)
    800032e8:	2509                	addiw	a0,a0,2
    800032ea:	4785                	li	a5,1
    800032ec:	04a7e363          	bltu	a5,a0,80003332 <usertrap+0xb8>
      setkilled(p);
    800032f0:	8526                	mv	a0,s1
    800032f2:	00000097          	auipc	ra,0x0
    800032f6:	8ac080e7          	jalr	-1876(ra) # 80002b9e <setkilled>
    800032fa:	a825                	j	80003332 <usertrap+0xb8>
    panic("usertrap: not from user mode");
    800032fc:	00005517          	auipc	a0,0x5
    80003300:	14450513          	addi	a0,a0,324 # 80008440 <states.0+0xd8>
    80003304:	ffffd097          	auipc	ra,0xffffd
    80003308:	238080e7          	jalr	568(ra) # 8000053c <panic>
    if (killed(p))
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	8be080e7          	jalr	-1858(ra) # 80002bca <killed>
    80003314:	ed15                	bnez	a0,80003350 <usertrap+0xd6>
    p->trapframe->epc += 4;
    80003316:	6cb8                	ld	a4,88(s1)
    80003318:	6f1c                	ld	a5,24(a4)
    8000331a:	0791                	addi	a5,a5,4
    8000331c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000331e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003322:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003326:	10079073          	csrw	sstatus,a5
    syscall();
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	20a080e7          	jalr	522(ra) # 80003534 <syscall>
  if (killed(p))
    80003332:	8526                	mv	a0,s1
    80003334:	00000097          	auipc	ra,0x0
    80003338:	896080e7          	jalr	-1898(ra) # 80002bca <killed>
    8000333c:	e13d                	bnez	a0,800033a2 <usertrap+0x128>
  usertrapret();
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	c26080e7          	jalr	-986(ra) # 80002f64 <usertrapret>
}
    80003346:	60e2                	ld	ra,24(sp)
    80003348:	6442                	ld	s0,16(sp)
    8000334a:	64a2                	ld	s1,8(sp)
    8000334c:	6105                	addi	sp,sp,32
    8000334e:	8082                	ret
      exit(-1);
    80003350:	557d                	li	a0,-1
    80003352:	fffff097          	auipc	ra,0xfffff
    80003356:	6f8080e7          	jalr	1784(ra) # 80002a4a <exit>
    8000335a:	bf75                	j	80003316 <usertrap+0x9c>
      setkilled(p);
    8000335c:	8526                	mv	a0,s1
    8000335e:	00000097          	auipc	ra,0x0
    80003362:	840080e7          	jalr	-1984(ra) # 80002b9e <setkilled>
    80003366:	bf95                	j	800032da <usertrap+0x60>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003368:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000336c:	5890                	lw	a2,48(s1)
    8000336e:	00005517          	auipc	a0,0x5
    80003372:	0f250513          	addi	a0,a0,242 # 80008460 <states.0+0xf8>
    80003376:	ffffd097          	auipc	ra,0xffffd
    8000337a:	210080e7          	jalr	528(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000337e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003382:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003386:	00005517          	auipc	a0,0x5
    8000338a:	10a50513          	addi	a0,a0,266 # 80008490 <states.0+0x128>
    8000338e:	ffffd097          	auipc	ra,0xffffd
    80003392:	1f8080e7          	jalr	504(ra) # 80000586 <printf>
    setkilled(p);
    80003396:	8526                	mv	a0,s1
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	806080e7          	jalr	-2042(ra) # 80002b9e <setkilled>
    800033a0:	bf49                	j	80003332 <usertrap+0xb8>
    exit(-1);
    800033a2:	557d                	li	a0,-1
    800033a4:	fffff097          	auipc	ra,0xfffff
    800033a8:	6a6080e7          	jalr	1702(ra) # 80002a4a <exit>
    800033ac:	bf49                	j	8000333e <usertrap+0xc4>

00000000800033ae <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	e426                	sd	s1,8(sp)
    800033b6:	1000                	addi	s0,sp,32
    800033b8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800033ba:	fffff097          	auipc	ra,0xfffff
    800033be:	8d6080e7          	jalr	-1834(ra) # 80001c90 <myproc>
  switch (n) {
    800033c2:	4795                	li	a5,5
    800033c4:	0497e163          	bltu	a5,s1,80003406 <argraw+0x58>
    800033c8:	048a                	slli	s1,s1,0x2
    800033ca:	00005717          	auipc	a4,0x5
    800033ce:	22e70713          	addi	a4,a4,558 # 800085f8 <states.0+0x290>
    800033d2:	94ba                	add	s1,s1,a4
    800033d4:	409c                	lw	a5,0(s1)
    800033d6:	97ba                	add	a5,a5,a4
    800033d8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800033da:	6d3c                	ld	a5,88(a0)
    800033dc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;          // a0 to a5 are arguments, a7 is number of arguments
  }
  panic("argraw");
  return -1;
}
    800033de:	60e2                	ld	ra,24(sp)
    800033e0:	6442                	ld	s0,16(sp)
    800033e2:	64a2                	ld	s1,8(sp)
    800033e4:	6105                	addi	sp,sp,32
    800033e6:	8082                	ret
    return p->trapframe->a1;
    800033e8:	6d3c                	ld	a5,88(a0)
    800033ea:	7fa8                	ld	a0,120(a5)
    800033ec:	bfcd                	j	800033de <argraw+0x30>
    return p->trapframe->a2;
    800033ee:	6d3c                	ld	a5,88(a0)
    800033f0:	63c8                	ld	a0,128(a5)
    800033f2:	b7f5                	j	800033de <argraw+0x30>
    return p->trapframe->a3;
    800033f4:	6d3c                	ld	a5,88(a0)
    800033f6:	67c8                	ld	a0,136(a5)
    800033f8:	b7dd                	j	800033de <argraw+0x30>
    return p->trapframe->a4;
    800033fa:	6d3c                	ld	a5,88(a0)
    800033fc:	6bc8                	ld	a0,144(a5)
    800033fe:	b7c5                	j	800033de <argraw+0x30>
    return p->trapframe->a5;          // a0 to a5 are arguments, a7 is number of arguments
    80003400:	6d3c                	ld	a5,88(a0)
    80003402:	6fc8                	ld	a0,152(a5)
    80003404:	bfe9                	j	800033de <argraw+0x30>
  panic("argraw");
    80003406:	00005517          	auipc	a0,0x5
    8000340a:	0aa50513          	addi	a0,a0,170 # 800084b0 <states.0+0x148>
    8000340e:	ffffd097          	auipc	ra,0xffffd
    80003412:	12e080e7          	jalr	302(ra) # 8000053c <panic>

0000000080003416 <fetchaddr>:
{
    80003416:	1101                	addi	sp,sp,-32
    80003418:	ec06                	sd	ra,24(sp)
    8000341a:	e822                	sd	s0,16(sp)
    8000341c:	e426                	sd	s1,8(sp)
    8000341e:	e04a                	sd	s2,0(sp)
    80003420:	1000                	addi	s0,sp,32
    80003422:	84aa                	mv	s1,a0
    80003424:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003426:	fffff097          	auipc	ra,0xfffff
    8000342a:	86a080e7          	jalr	-1942(ra) # 80001c90 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000342e:	653c                	ld	a5,72(a0)
    80003430:	02f4f863          	bgeu	s1,a5,80003460 <fetchaddr+0x4a>
    80003434:	00848713          	addi	a4,s1,8
    80003438:	02e7e663          	bltu	a5,a4,80003464 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000343c:	46a1                	li	a3,8
    8000343e:	8626                	mv	a2,s1
    80003440:	85ca                	mv	a1,s2
    80003442:	6928                	ld	a0,80(a0)
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	538080e7          	jalr	1336(ra) # 8000197c <copyin>
    8000344c:	00a03533          	snez	a0,a0
    80003450:	40a00533          	neg	a0,a0
}
    80003454:	60e2                	ld	ra,24(sp)
    80003456:	6442                	ld	s0,16(sp)
    80003458:	64a2                	ld	s1,8(sp)
    8000345a:	6902                	ld	s2,0(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret
    return -1;
    80003460:	557d                	li	a0,-1
    80003462:	bfcd                	j	80003454 <fetchaddr+0x3e>
    80003464:	557d                	li	a0,-1
    80003466:	b7fd                	j	80003454 <fetchaddr+0x3e>

0000000080003468 <fetchstr>:
{
    80003468:	7179                	addi	sp,sp,-48
    8000346a:	f406                	sd	ra,40(sp)
    8000346c:	f022                	sd	s0,32(sp)
    8000346e:	ec26                	sd	s1,24(sp)
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	e44e                	sd	s3,8(sp)
    80003474:	1800                	addi	s0,sp,48
    80003476:	892a                	mv	s2,a0
    80003478:	84ae                	mv	s1,a1
    8000347a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000347c:	fffff097          	auipc	ra,0xfffff
    80003480:	814080e7          	jalr	-2028(ra) # 80001c90 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003484:	86ce                	mv	a3,s3
    80003486:	864a                	mv	a2,s2
    80003488:	85a6                	mv	a1,s1
    8000348a:	6928                	ld	a0,80(a0)
    8000348c:	ffffe097          	auipc	ra,0xffffe
    80003490:	57e080e7          	jalr	1406(ra) # 80001a0a <copyinstr>
    80003494:	00054e63          	bltz	a0,800034b0 <fetchstr+0x48>
  return strlen(buf);
    80003498:	8526                	mv	a0,s1
    8000349a:	ffffe097          	auipc	ra,0xffffe
    8000349e:	bf6080e7          	jalr	-1034(ra) # 80001090 <strlen>
}
    800034a2:	70a2                	ld	ra,40(sp)
    800034a4:	7402                	ld	s0,32(sp)
    800034a6:	64e2                	ld	s1,24(sp)
    800034a8:	6942                	ld	s2,16(sp)
    800034aa:	69a2                	ld	s3,8(sp)
    800034ac:	6145                	addi	sp,sp,48
    800034ae:	8082                	ret
    return -1;
    800034b0:	557d                	li	a0,-1
    800034b2:	bfc5                	j	800034a2 <fetchstr+0x3a>

00000000800034b4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800034b4:	1101                	addi	sp,sp,-32
    800034b6:	ec06                	sd	ra,24(sp)
    800034b8:	e822                	sd	s0,16(sp)
    800034ba:	e426                	sd	s1,8(sp)
    800034bc:	1000                	addi	s0,sp,32
    800034be:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800034c0:	00000097          	auipc	ra,0x0
    800034c4:	eee080e7          	jalr	-274(ra) # 800033ae <argraw>
    800034c8:	2501                	sext.w	a0,a0
    800034ca:	c088                	sw	a0,0(s1)

  if(*ip < 0)
    800034cc:	957d                	srai	a0,a0,0x3f
  {
    return -1;
  }

  return 0;
}
    800034ce:	2501                	sext.w	a0,a0
    800034d0:	60e2                	ld	ra,24(sp)
    800034d2:	6442                	ld	s0,16(sp)
    800034d4:	64a2                	ld	s1,8(sp)
    800034d6:	6105                	addi	sp,sp,32
    800034d8:	8082                	ret

00000000800034da <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800034da:	1101                	addi	sp,sp,-32
    800034dc:	ec06                	sd	ra,24(sp)
    800034de:	e822                	sd	s0,16(sp)
    800034e0:	e426                	sd	s1,8(sp)
    800034e2:	1000                	addi	s0,sp,32
    800034e4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800034e6:	00000097          	auipc	ra,0x0
    800034ea:	ec8080e7          	jalr	-312(ra) # 800033ae <argraw>
    800034ee:	e088                	sd	a0,0(s1)
  return 0;
}
    800034f0:	4501                	li	a0,0
    800034f2:	60e2                	ld	ra,24(sp)
    800034f4:	6442                	ld	s0,16(sp)
    800034f6:	64a2                	ld	s1,8(sp)
    800034f8:	6105                	addi	sp,sp,32
    800034fa:	8082                	ret

00000000800034fc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800034fc:	7179                	addi	sp,sp,-48
    800034fe:	f406                	sd	ra,40(sp)
    80003500:	f022                	sd	s0,32(sp)
    80003502:	ec26                	sd	s1,24(sp)
    80003504:	e84a                	sd	s2,16(sp)
    80003506:	1800                	addi	s0,sp,48
    80003508:	84ae                	mv	s1,a1
    8000350a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000350c:	fd840593          	addi	a1,s0,-40
    80003510:	00000097          	auipc	ra,0x0
    80003514:	fca080e7          	jalr	-54(ra) # 800034da <argaddr>
  return fetchstr(addr, buf, max);
    80003518:	864a                	mv	a2,s2
    8000351a:	85a6                	mv	a1,s1
    8000351c:	fd843503          	ld	a0,-40(s0)
    80003520:	00000097          	auipc	ra,0x0
    80003524:	f48080e7          	jalr	-184(ra) # 80003468 <fetchstr>
}
    80003528:	70a2                	ld	ra,40(sp)
    8000352a:	7402                	ld	s0,32(sp)
    8000352c:	64e2                	ld	s1,24(sp)
    8000352e:	6942                	ld	s2,16(sp)
    80003530:	6145                	addi	sp,sp,48
    80003532:	8082                	ret

0000000080003534 <syscall>:
[SYS_set_priority]  "set_priority",
};

void
syscall(void)
{
    80003534:	715d                	addi	sp,sp,-80
    80003536:	e486                	sd	ra,72(sp)
    80003538:	e0a2                	sd	s0,64(sp)
    8000353a:	fc26                	sd	s1,56(sp)
    8000353c:	f84a                	sd	s2,48(sp)
    8000353e:	f44e                	sd	s3,40(sp)
    80003540:	f052                	sd	s4,32(sp)
    80003542:	ec56                	sd	s5,24(sp)
    80003544:	e85a                	sd	s6,16(sp)
    80003546:	e45e                	sd	s7,8(sp)
    80003548:	0880                	addi	s0,sp,80
  int num;
  struct proc *p = myproc();
    8000354a:	ffffe097          	auipc	ra,0xffffe
    8000354e:	746080e7          	jalr	1862(ra) # 80001c90 <myproc>
    80003552:	8a2a                	mv	s4,a0


  num = p->trapframe->a7;   // contains the integer than corresponds to sycall in syscall.h, check user/initcode.S
    80003554:	6d3c                	ld	a5,88(a0)
    80003556:	0a87ba83          	ld	s5,168(a5)
    8000355a:	000a8b1b          	sext.w	s6,s5

  int len_args = syscalls_num[num];     
    8000355e:	002b1793          	slli	a5,s6,0x2
    80003562:	00005717          	auipc	a4,0x5
    80003566:	0ae70713          	addi	a4,a4,174 # 80008610 <syscalls_num>
    8000356a:	973e                	add	a4,a4,a5
    8000356c:	00072983          	lw	s3,0(a4)

  int arguments_decval[num];
    80003570:	07bd                	addi	a5,a5,15
    80003572:	9bc1                	andi	a5,a5,-16
    80003574:	40f10133          	sub	sp,sp,a5
    80003578:	8b8a                	mv	s7,sp
  for(int i = 0; i < len_args;i++)
    8000357a:	01305f63          	blez	s3,80003598 <syscall+0x64>
    8000357e:	895e                	mv	s2,s7
    80003580:	4481                	li	s1,0
  {
    arguments_decval[i] = argraw(i);      // 6 arguments are stored in registers a0 - a5 in integer form, we simply wish to extract this
    80003582:	8526                	mv	a0,s1
    80003584:	00000097          	auipc	ra,0x0
    80003588:	e2a080e7          	jalr	-470(ra) # 800033ae <argraw>
    8000358c:	00a92023          	sw	a0,0(s2)
  for(int i = 0; i < len_args;i++)
    80003590:	2485                	addiw	s1,s1,1
    80003592:	0911                	addi	s2,s2,4
    80003594:	fe9997e3          	bne	s3,s1,80003582 <syscall+0x4e>
  }
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003598:	3afd                	addiw	s5,s5,-1
    8000359a:	47e9                	li	a5,26
    8000359c:	0957e563          	bltu	a5,s5,80003626 <syscall+0xf2>
    800035a0:	003b1713          	slli	a4,s6,0x3
    800035a4:	00005797          	auipc	a5,0x5
    800035a8:	06c78793          	addi	a5,a5,108 # 80008610 <syscalls_num>
    800035ac:	97ba                	add	a5,a5,a4
    800035ae:	77bc                	ld	a5,104(a5)
    800035b0:	cbbd                	beqz	a5,80003626 <syscall+0xf2>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800035b2:	058a3483          	ld	s1,88(s4)
    800035b6:	9782                	jalr	a5
    800035b8:	f8a8                	sd	a0,112(s1)
    if(p->mask & 1 << num)
    800035ba:	168a2783          	lw	a5,360(s4)
    800035be:	4167d7bb          	sraw	a5,a5,s6
    800035c2:	8b85                	andi	a5,a5,1
    800035c4:	c3d1                	beqz	a5,80003648 <syscall+0x114>
    {
      printf("%d: syscall %s (",p->pid,syscall_names[num]);
    800035c6:	0b0e                	slli	s6,s6,0x3
    800035c8:	00005797          	auipc	a5,0x5
    800035cc:	04878793          	addi	a5,a5,72 # 80008610 <syscalls_num>
    800035d0:	97da                	add	a5,a5,s6
    800035d2:	1487b603          	ld	a2,328(a5)
    800035d6:	030a2583          	lw	a1,48(s4)
    800035da:	00005517          	auipc	a0,0x5
    800035de:	ede50513          	addi	a0,a0,-290 # 800084b8 <states.0+0x150>
    800035e2:	ffffd097          	auipc	ra,0xffffd
    800035e6:	fa4080e7          	jalr	-92(ra) # 80000586 <printf>
      for(int i = 0; i < len_args;i++)
    800035ea:	03305263          	blez	s3,8000360e <syscall+0xda>
    800035ee:	84de                	mv	s1,s7
    800035f0:	098a                	slli	s3,s3,0x2
    800035f2:	9bce                	add	s7,s7,s3
      {
        printf("%d ",arguments_decval[i]);              // interesting note : trace and shell output are both intermixed, since both use the write command
    800035f4:	00005917          	auipc	s2,0x5
    800035f8:	edc90913          	addi	s2,s2,-292 # 800084d0 <states.0+0x168>
    800035fc:	408c                	lw	a1,0(s1)
    800035fe:	854a                	mv	a0,s2
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	f86080e7          	jalr	-122(ra) # 80000586 <printf>
      for(int i = 0; i < len_args;i++)
    80003608:	0491                	addi	s1,s1,4
    8000360a:	ff7499e3          	bne	s1,s7,800035fc <syscall+0xc8>
      }
      printf("\b) -> %d\n",p->trapframe->a0);
    8000360e:	058a3783          	ld	a5,88(s4)
    80003612:	7bac                	ld	a1,112(a5)
    80003614:	00005517          	auipc	a0,0x5
    80003618:	ec450513          	addi	a0,a0,-316 # 800084d8 <states.0+0x170>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	f6a080e7          	jalr	-150(ra) # 80000586 <printf>
    80003624:	a015                	j	80003648 <syscall+0x114>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003626:	86da                	mv	a3,s6
    80003628:	158a0613          	addi	a2,s4,344
    8000362c:	030a2583          	lw	a1,48(s4)
    80003630:	00005517          	auipc	a0,0x5
    80003634:	eb850513          	addi	a0,a0,-328 # 800084e8 <states.0+0x180>
    80003638:	ffffd097          	auipc	ra,0xffffd
    8000363c:	f4e080e7          	jalr	-178(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003640:	058a3783          	ld	a5,88(s4)
    80003644:	577d                	li	a4,-1
    80003646:	fbb8                	sd	a4,112(a5)
  }
}
    80003648:	fb040113          	addi	sp,s0,-80
    8000364c:	60a6                	ld	ra,72(sp)
    8000364e:	6406                	ld	s0,64(sp)
    80003650:	74e2                	ld	s1,56(sp)
    80003652:	7942                	ld	s2,48(sp)
    80003654:	79a2                	ld	s3,40(sp)
    80003656:	7a02                	ld	s4,32(sp)
    80003658:	6ae2                	ld	s5,24(sp)
    8000365a:	6b42                	ld	s6,16(sp)
    8000365c:	6ba2                	ld	s7,8(sp)
    8000365e:	6161                	addi	sp,sp,80
    80003660:	8082                	ret

0000000080003662 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003662:	1101                	addi	sp,sp,-32
    80003664:	ec06                	sd	ra,24(sp)
    80003666:	e822                	sd	s0,16(sp)
    80003668:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000366a:	fec40593          	addi	a1,s0,-20
    8000366e:	4501                	li	a0,0
    80003670:	00000097          	auipc	ra,0x0
    80003674:	e44080e7          	jalr	-444(ra) # 800034b4 <argint>
  exit(n);
    80003678:	fec42503          	lw	a0,-20(s0)
    8000367c:	fffff097          	auipc	ra,0xfffff
    80003680:	3ce080e7          	jalr	974(ra) # 80002a4a <exit>
  return 0;  // not reached
}
    80003684:	4501                	li	a0,0
    80003686:	60e2                	ld	ra,24(sp)
    80003688:	6442                	ld	s0,16(sp)
    8000368a:	6105                	addi	sp,sp,32
    8000368c:	8082                	ret

000000008000368e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000368e:	1141                	addi	sp,sp,-16
    80003690:	e406                	sd	ra,8(sp)
    80003692:	e022                	sd	s0,0(sp)
    80003694:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003696:	ffffe097          	auipc	ra,0xffffe
    8000369a:	5fa080e7          	jalr	1530(ra) # 80001c90 <myproc>
}
    8000369e:	5908                	lw	a0,48(a0)
    800036a0:	60a2                	ld	ra,8(sp)
    800036a2:	6402                	ld	s0,0(sp)
    800036a4:	0141                	addi	sp,sp,16
    800036a6:	8082                	ret

00000000800036a8 <sys_fork>:

uint64
sys_fork(void)
{
    800036a8:	1141                	addi	sp,sp,-16
    800036aa:	e406                	sd	ra,8(sp)
    800036ac:	e022                	sd	s0,0(sp)
    800036ae:	0800                	addi	s0,sp,16
  return fork();
    800036b0:	fffff097          	auipc	ra,0xfffff
    800036b4:	9da080e7          	jalr	-1574(ra) # 8000208a <fork>
}
    800036b8:	60a2                	ld	ra,8(sp)
    800036ba:	6402                	ld	s0,0(sp)
    800036bc:	0141                	addi	sp,sp,16
    800036be:	8082                	ret

00000000800036c0 <sys_wait>:

uint64
sys_wait(void)
{
    800036c0:	1101                	addi	sp,sp,-32
    800036c2:	ec06                	sd	ra,24(sp)
    800036c4:	e822                	sd	s0,16(sp)
    800036c6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800036c8:	fe840593          	addi	a1,s0,-24
    800036cc:	4501                	li	a0,0
    800036ce:	00000097          	auipc	ra,0x0
    800036d2:	e0c080e7          	jalr	-500(ra) # 800034da <argaddr>
  return wait(p);
    800036d6:	fe843503          	ld	a0,-24(s0)
    800036da:	fffff097          	auipc	ra,0xfffff
    800036de:	522080e7          	jalr	1314(ra) # 80002bfc <wait>
}
    800036e2:	60e2                	ld	ra,24(sp)
    800036e4:	6442                	ld	s0,16(sp)
    800036e6:	6105                	addi	sp,sp,32
    800036e8:	8082                	ret

00000000800036ea <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800036ea:	7179                	addi	sp,sp,-48
    800036ec:	f406                	sd	ra,40(sp)
    800036ee:	f022                	sd	s0,32(sp)
    800036f0:	ec26                	sd	s1,24(sp)
    800036f2:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800036f4:	fdc40593          	addi	a1,s0,-36
    800036f8:	4501                	li	a0,0
    800036fa:	00000097          	auipc	ra,0x0
    800036fe:	dba080e7          	jalr	-582(ra) # 800034b4 <argint>
  addr = myproc()->sz;
    80003702:	ffffe097          	auipc	ra,0xffffe
    80003706:	58e080e7          	jalr	1422(ra) # 80001c90 <myproc>
    8000370a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000370c:	fdc42503          	lw	a0,-36(s0)
    80003710:	fffff097          	auipc	ra,0xfffff
    80003714:	91e080e7          	jalr	-1762(ra) # 8000202e <growproc>
    80003718:	00054863          	bltz	a0,80003728 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000371c:	8526                	mv	a0,s1
    8000371e:	70a2                	ld	ra,40(sp)
    80003720:	7402                	ld	s0,32(sp)
    80003722:	64e2                	ld	s1,24(sp)
    80003724:	6145                	addi	sp,sp,48
    80003726:	8082                	ret
    return -1;
    80003728:	54fd                	li	s1,-1
    8000372a:	bfcd                	j	8000371c <sys_sbrk+0x32>

000000008000372c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000372c:	7139                	addi	sp,sp,-64
    8000372e:	fc06                	sd	ra,56(sp)
    80003730:	f822                	sd	s0,48(sp)
    80003732:	f426                	sd	s1,40(sp)
    80003734:	f04a                	sd	s2,32(sp)
    80003736:	ec4e                	sd	s3,24(sp)
    80003738:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000373a:	fcc40593          	addi	a1,s0,-52
    8000373e:	4501                	li	a0,0
    80003740:	00000097          	auipc	ra,0x0
    80003744:	d74080e7          	jalr	-652(ra) # 800034b4 <argint>
  acquire(&tickslock);
    80003748:	0023a517          	auipc	a0,0x23a
    8000374c:	d0050513          	addi	a0,a0,-768 # 8023d448 <tickslock>
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	6ca080e7          	jalr	1738(ra) # 80000e1a <acquire>
  ticks0 = ticks;
    80003758:	00005917          	auipc	s2,0x5
    8000375c:	49892903          	lw	s2,1176(s2) # 80008bf0 <ticks>
  while(ticks - ticks0 < n){
    80003760:	fcc42783          	lw	a5,-52(s0)
    80003764:	cf9d                	beqz	a5,800037a2 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003766:	0023a997          	auipc	s3,0x23a
    8000376a:	ce298993          	addi	s3,s3,-798 # 8023d448 <tickslock>
    8000376e:	00005497          	auipc	s1,0x5
    80003772:	48248493          	addi	s1,s1,1154 # 80008bf0 <ticks>
    if(killed(myproc())){
    80003776:	ffffe097          	auipc	ra,0xffffe
    8000377a:	51a080e7          	jalr	1306(ra) # 80001c90 <myproc>
    8000377e:	fffff097          	auipc	ra,0xfffff
    80003782:	44c080e7          	jalr	1100(ra) # 80002bca <killed>
    80003786:	ed15                	bnez	a0,800037c2 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003788:	85ce                	mv	a1,s3
    8000378a:	8526                	mv	a0,s1
    8000378c:	fffff097          	auipc	ra,0xfffff
    80003790:	03e080e7          	jalr	62(ra) # 800027ca <sleep>
  while(ticks - ticks0 < n){
    80003794:	409c                	lw	a5,0(s1)
    80003796:	412787bb          	subw	a5,a5,s2
    8000379a:	fcc42703          	lw	a4,-52(s0)
    8000379e:	fce7ece3          	bltu	a5,a4,80003776 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800037a2:	0023a517          	auipc	a0,0x23a
    800037a6:	ca650513          	addi	a0,a0,-858 # 8023d448 <tickslock>
    800037aa:	ffffd097          	auipc	ra,0xffffd
    800037ae:	724080e7          	jalr	1828(ra) # 80000ece <release>
  return 0;
    800037b2:	4501                	li	a0,0
}
    800037b4:	70e2                	ld	ra,56(sp)
    800037b6:	7442                	ld	s0,48(sp)
    800037b8:	74a2                	ld	s1,40(sp)
    800037ba:	7902                	ld	s2,32(sp)
    800037bc:	69e2                	ld	s3,24(sp)
    800037be:	6121                	addi	sp,sp,64
    800037c0:	8082                	ret
      release(&tickslock);
    800037c2:	0023a517          	auipc	a0,0x23a
    800037c6:	c8650513          	addi	a0,a0,-890 # 8023d448 <tickslock>
    800037ca:	ffffd097          	auipc	ra,0xffffd
    800037ce:	704080e7          	jalr	1796(ra) # 80000ece <release>
      return -1;
    800037d2:	557d                	li	a0,-1
    800037d4:	b7c5                	j	800037b4 <sys_sleep+0x88>

00000000800037d6 <sys_kill>:

uint64
sys_kill(void)
{
    800037d6:	1101                	addi	sp,sp,-32
    800037d8:	ec06                	sd	ra,24(sp)
    800037da:	e822                	sd	s0,16(sp)
    800037dc:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800037de:	fec40593          	addi	a1,s0,-20
    800037e2:	4501                	li	a0,0
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	cd0080e7          	jalr	-816(ra) # 800034b4 <argint>
  return kill(pid);
    800037ec:	fec42503          	lw	a0,-20(s0)
    800037f0:	fffff097          	auipc	ra,0xfffff
    800037f4:	33c080e7          	jalr	828(ra) # 80002b2c <kill>
}
    800037f8:	60e2                	ld	ra,24(sp)
    800037fa:	6442                	ld	s0,16(sp)
    800037fc:	6105                	addi	sp,sp,32
    800037fe:	8082                	ret

0000000080003800 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003800:	1101                	addi	sp,sp,-32
    80003802:	ec06                	sd	ra,24(sp)
    80003804:	e822                	sd	s0,16(sp)
    80003806:	e426                	sd	s1,8(sp)
    80003808:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000380a:	0023a517          	auipc	a0,0x23a
    8000380e:	c3e50513          	addi	a0,a0,-962 # 8023d448 <tickslock>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	608080e7          	jalr	1544(ra) # 80000e1a <acquire>
  xticks = ticks;
    8000381a:	00005497          	auipc	s1,0x5
    8000381e:	3d64a483          	lw	s1,982(s1) # 80008bf0 <ticks>
  release(&tickslock);
    80003822:	0023a517          	auipc	a0,0x23a
    80003826:	c2650513          	addi	a0,a0,-986 # 8023d448 <tickslock>
    8000382a:	ffffd097          	auipc	ra,0xffffd
    8000382e:	6a4080e7          	jalr	1700(ra) # 80000ece <release>
  return xticks;
}
    80003832:	02049513          	slli	a0,s1,0x20
    80003836:	9101                	srli	a0,a0,0x20
    80003838:	60e2                	ld	ra,24(sp)
    8000383a:	6442                	ld	s0,16(sp)
    8000383c:	64a2                	ld	s1,8(sp)
    8000383e:	6105                	addi	sp,sp,32
    80003840:	8082                	ret

0000000080003842 <sys_trace>:

uint64 sys_trace(void)
{
    80003842:	1101                	addi	sp,sp,-32
    80003844:	ec06                	sd	ra,24(sp)
    80003846:	e822                	sd	s0,16(sp)
    80003848:	1000                	addi	s0,sp,32
  int mask;

  int f = argint(0,&mask);
    8000384a:	fec40593          	addi	a1,s0,-20
    8000384e:	4501                	li	a0,0
    80003850:	00000097          	auipc	ra,0x0
    80003854:	c64080e7          	jalr	-924(ra) # 800034b4 <argint>

  if(f < 0)
  {
    return -1;
    80003858:	57fd                	li	a5,-1
  if(f < 0)
    8000385a:	00054b63          	bltz	a0,80003870 <sys_trace+0x2e>
  }

  struct proc *p = myproc();
    8000385e:	ffffe097          	auipc	ra,0xffffe
    80003862:	432080e7          	jalr	1074(ra) # 80001c90 <myproc>
  p->mask = mask;
    80003866:	fec42783          	lw	a5,-20(s0)
    8000386a:	16f52423          	sw	a5,360(a0)

  return 0; 
    8000386e:	4781                	li	a5,0
}
    80003870:	853e                	mv	a0,a5
    80003872:	60e2                	ld	ra,24(sp)
    80003874:	6442                	ld	s0,16(sp)
    80003876:	6105                	addi	sp,sp,32
    80003878:	8082                	ret

000000008000387a <sys_sigalarm>:

uint64 sys_sigalarm(void)
{
    8000387a:	1101                	addi	sp,sp,-32
    8000387c:	ec06                	sd	ra,24(sp)
    8000387e:	e822                	sd	s0,16(sp)
    80003880:	1000                	addi	s0,sp,32
  int ticks;
  uint64 handler;

 argint(0,&ticks);
    80003882:	fec40593          	addi	a1,s0,-20
    80003886:	4501                	li	a0,0
    80003888:	00000097          	auipc	ra,0x0
    8000388c:	c2c080e7          	jalr	-980(ra) # 800034b4 <argint>
 argaddr(1,&handler);
    80003890:	fe040593          	addi	a1,s0,-32
    80003894:	4505                	li	a0,1
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	c44080e7          	jalr	-956(ra) # 800034da <argaddr>
  
  struct proc* p = myproc();
    8000389e:	ffffe097          	auipc	ra,0xffffe
    800038a2:	3f2080e7          	jalr	1010(ra) # 80001c90 <myproc>

  p->ticks = ticks;
    800038a6:	fec42783          	lw	a5,-20(s0)
    800038aa:	16f52623          	sw	a5,364(a0)
  p->handler = handler;
    800038ae:	fe043783          	ld	a5,-32(s0)
    800038b2:	16f53c23          	sd	a5,376(a0)
  p->elapsed_ticks = 0;
    800038b6:	16052823          	sw	zero,368(a0)

  return 0;
}
    800038ba:	4501                	li	a0,0
    800038bc:	60e2                	ld	ra,24(sp)
    800038be:	6442                	ld	s0,16(sp)
    800038c0:	6105                	addi	sp,sp,32
    800038c2:	8082                	ret

00000000800038c4 <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    800038c4:	1101                	addi	sp,sp,-32
    800038c6:	ec06                	sd	ra,24(sp)
    800038c8:	e822                	sd	s0,16(sp)
    800038ca:	e426                	sd	s1,8(sp)
    800038cc:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    800038ce:	ffffe097          	auipc	ra,0xffffe
    800038d2:	3c2080e7          	jalr	962(ra) # 80001c90 <myproc>
    800038d6:	84aa                	mv	s1,a0

  // Recover saved trapframe.
  //*p->trapframe = p->saved_tf;    //was failing test 2
  // if trapframe not recovered , test 0,2,3 were passing
  memmove(p->trapframe,&(p->saved_tf),sizeof(struct trapframe)); // currently passing tests 0,1,2
    800038d8:	12000613          	li	a2,288
    800038dc:	18050593          	addi	a1,a0,384
    800038e0:	6d28                	ld	a0,88(a0)
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	690080e7          	jalr	1680(ra) # 80000f72 <memmove>

  // p->trapframe->a0 = p->saved_tf.a0;

  p->elapsed_ticks = 0;
    800038ea:	1604a823          	sw	zero,368(s1)

  return p->saved_tf.a0;    // This is the return value of sigreturn, the state of a0 reg in the saved trapframe
}
    800038ee:	1f04b503          	ld	a0,496(s1)
    800038f2:	60e2                	ld	ra,24(sp)
    800038f4:	6442                	ld	s0,16(sp)
    800038f6:	64a2                	ld	s1,8(sp)
    800038f8:	6105                	addi	sp,sp,32
    800038fa:	8082                	ret

00000000800038fc <sys_waitx>:

uint64
sys_waitx(void)
{
    800038fc:	7139                	addi	sp,sp,-64
    800038fe:	fc06                	sd	ra,56(sp)
    80003900:	f822                	sd	s0,48(sp)
    80003902:	f426                	sd	s1,40(sp)
    80003904:	f04a                	sd	s2,32(sp)
    80003906:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003908:	fd840593          	addi	a1,s0,-40
    8000390c:	4501                	li	a0,0
    8000390e:	00000097          	auipc	ra,0x0
    80003912:	bcc080e7          	jalr	-1076(ra) # 800034da <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003916:	fd040593          	addi	a1,s0,-48
    8000391a:	4505                	li	a0,1
    8000391c:	00000097          	auipc	ra,0x0
    80003920:	bbe080e7          	jalr	-1090(ra) # 800034da <argaddr>
  argaddr(2, &addr2);
    80003924:	fc840593          	addi	a1,s0,-56
    80003928:	4509                	li	a0,2
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	bb0080e7          	jalr	-1104(ra) # 800034da <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003932:	fc040613          	addi	a2,s0,-64
    80003936:	fc440593          	addi	a1,s0,-60
    8000393a:	fd843503          	ld	a0,-40(s0)
    8000393e:	fffff097          	auipc	ra,0xfffff
    80003942:	ef0080e7          	jalr	-272(ra) # 8000282e <waitx>
    80003946:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80003948:	ffffe097          	auipc	ra,0xffffe
    8000394c:	348080e7          	jalr	840(ra) # 80001c90 <myproc>
    80003950:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003952:	4691                	li	a3,4
    80003954:	fc440613          	addi	a2,s0,-60
    80003958:	fd043583          	ld	a1,-48(s0)
    8000395c:	6928                	ld	a0,80(a0)
    8000395e:	ffffe097          	auipc	ra,0xffffe
    80003962:	f5a080e7          	jalr	-166(ra) # 800018b8 <copyout>
    return -1;
    80003966:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003968:	00054f63          	bltz	a0,80003986 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    8000396c:	4691                	li	a3,4
    8000396e:	fc040613          	addi	a2,s0,-64
    80003972:	fc843583          	ld	a1,-56(s0)
    80003976:	68a8                	ld	a0,80(s1)
    80003978:	ffffe097          	auipc	ra,0xffffe
    8000397c:	f40080e7          	jalr	-192(ra) # 800018b8 <copyout>
    80003980:	00054a63          	bltz	a0,80003994 <sys_waitx+0x98>
    return -1;
  return ret;
    80003984:	87ca                	mv	a5,s2
}
    80003986:	853e                	mv	a0,a5
    80003988:	70e2                	ld	ra,56(sp)
    8000398a:	7442                	ld	s0,48(sp)
    8000398c:	74a2                	ld	s1,40(sp)
    8000398e:	7902                	ld	s2,32(sp)
    80003990:	6121                	addi	sp,sp,64
    80003992:	8082                	ret
    return -1;
    80003994:	57fd                	li	a5,-1
    80003996:	bfc5                	j	80003986 <sys_waitx+0x8a>

0000000080003998 <sys_set_tickets>:

uint64
sys_set_tickets(void){
    80003998:	1101                	addi	sp,sp,-32
    8000399a:	ec06                	sd	ra,24(sp)
    8000399c:	e822                	sd	s0,16(sp)
    8000399e:	1000                	addi	s0,sp,32
    int num;
    int f1 = argint(0,&num);
    800039a0:	fec40593          	addi	a1,s0,-20
    800039a4:	4501                	li	a0,0
    800039a6:	00000097          	auipc	ra,0x0
    800039aa:	b0e080e7          	jalr	-1266(ra) # 800034b4 <argint>

    if(f1 < 0)
    {
      return -1;
    800039ae:	57fd                	li	a5,-1
    if(f1 < 0)
    800039b0:	00054e63          	bltz	a0,800039cc <sys_set_tickets+0x34>
    }
    myproc()->tickets+=num;
    800039b4:	ffffe097          	auipc	ra,0xffffe
    800039b8:	2dc080e7          	jalr	732(ra) # 80001c90 <myproc>
    800039bc:	2c452703          	lw	a4,708(a0)
    800039c0:	fec42783          	lw	a5,-20(s0)
    800039c4:	9fb9                	addw	a5,a5,a4
    800039c6:	2cf52223          	sw	a5,708(a0)
    return 0;
    800039ca:	4781                	li	a5,0
}
    800039cc:	853e                	mv	a0,a5
    800039ce:	60e2                	ld	ra,24(sp)
    800039d0:	6442                	ld	s0,16(sp)
    800039d2:	6105                	addi	sp,sp,32
    800039d4:	8082                	ret

00000000800039d6 <sys_set_priority>:

uint64
sys_set_priority(void){
    800039d6:	7139                	addi	sp,sp,-64
    800039d8:	fc06                	sd	ra,56(sp)
    800039da:	f822                	sd	s0,48(sp)
    800039dc:	f426                	sd	s1,40(sp)
    800039de:	f04a                	sd	s2,32(sp)
    800039e0:	ec4e                	sd	s3,24(sp)
    800039e2:	e852                	sd	s4,16(sp)
    800039e4:	0080                	addi	s0,sp,64
    int np, pid ;
    int temp = 101;

    int f1 = argint(0,&np);
    800039e6:	fcc40593          	addi	a1,s0,-52
    800039ea:	4501                	li	a0,0
    800039ec:	00000097          	auipc	ra,0x0
    800039f0:	ac8080e7          	jalr	-1336(ra) # 800034b4 <argint>
    800039f4:	84aa                	mv	s1,a0
    int f2 = argint(1,&pid);
    800039f6:	fc840593          	addi	a1,s0,-56
    800039fa:	4505                	li	a0,1
    800039fc:	00000097          	auipc	ra,0x0
    80003a00:	ab8080e7          	jalr	-1352(ra) # 800034b4 <argint>

    // If the input format is wrong then exit
    if(f1 < 0 || f2 < 0){
    80003a04:	8cc9                	or	s1,s1,a0
    80003a06:	2481                	sext.w	s1,s1
    80003a08:	0804c163          	bltz	s1,80003a8a <sys_set_priority+0xb4>
        return -1;
    }
    struct proc *p;
    for(p = proc; p < &proc[NPROC]; p++){
    80003a0c:	0022f497          	auipc	s1,0x22f
    80003a10:	83c48493          	addi	s1,s1,-1988 # 80232248 <proc>
    int temp = 101;
    80003a14:	06500a13          	li	s4,101
        // Locking the process
        acquire(&p->lock);

        // Finding the process and checking if new_priority is in the
        // correct range of values
        if(p->pid == pid && np >= 0 && np <= 100){
    80003a18:	06400993          	li	s3,100
    for(p = proc; p < &proc[NPROC]; p++){
    80003a1c:	0023a917          	auipc	s2,0x23a
    80003a20:	a2c90913          	addi	s2,s2,-1492 # 8023d448 <tickslock>
    80003a24:	a811                	j	80003a38 <sys_set_priority+0x62>

            // Switching the priority
            p->priority = np;
        }
        // Unlock the process
        release(&p->lock);
    80003a26:	8526                	mv	a0,s1
    80003a28:	ffffd097          	auipc	ra,0xffffd
    80003a2c:	4a6080e7          	jalr	1190(ra) # 80000ece <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80003a30:	2c848493          	addi	s1,s1,712
    80003a34:	03248963          	beq	s1,s2,80003a66 <sys_set_priority+0x90>
        acquire(&p->lock);
    80003a38:	8526                	mv	a0,s1
    80003a3a:	ffffd097          	auipc	ra,0xffffd
    80003a3e:	3e0080e7          	jalr	992(ra) # 80000e1a <acquire>
        if(p->pid == pid && np >= 0 && np <= 100){
    80003a42:	5898                	lw	a4,48(s1)
    80003a44:	fc842783          	lw	a5,-56(s0)
    80003a48:	fcf71fe3          	bne	a4,a5,80003a26 <sys_set_priority+0x50>
    80003a4c:	fcc42783          	lw	a5,-52(s0)
    80003a50:	fcf9ebe3          	bltu	s3,a5,80003a26 <sys_set_priority+0x50>
            p->stime = 0;
    80003a54:	2a04ac23          	sw	zero,696(s1)
            p->rtime = 0;
    80003a58:	2a04a423          	sw	zero,680(s1)
            temp = p->priority;
    80003a5c:	2c04aa03          	lw	s4,704(s1)
            p->priority = np;
    80003a60:	2cf4a023          	sw	a5,704(s1)
    80003a64:	b7c9                	j	80003a26 <sys_set_priority+0x50>
    }
    // If the new priority is lesser than old then yield to cpu
    if(temp > np)
    80003a66:	fcc42783          	lw	a5,-52(s0)
    80003a6a:	0147cb63          	blt	a5,s4,80003a80 <sys_set_priority+0xaa>
        yield();


    // Return the old priority
    return temp;
    80003a6e:	8552                	mv	a0,s4

    80003a70:	70e2                	ld	ra,56(sp)
    80003a72:	7442                	ld	s0,48(sp)
    80003a74:	74a2                	ld	s1,40(sp)
    80003a76:	7902                	ld	s2,32(sp)
    80003a78:	69e2                	ld	s3,24(sp)
    80003a7a:	6a42                	ld	s4,16(sp)
    80003a7c:	6121                	addi	sp,sp,64
    80003a7e:	8082                	ret
        yield();
    80003a80:	fffff097          	auipc	ra,0xfffff
    80003a84:	c84080e7          	jalr	-892(ra) # 80002704 <yield>
    80003a88:	b7dd                	j	80003a6e <sys_set_priority+0x98>
        return -1;
    80003a8a:	557d                	li	a0,-1
    80003a8c:	b7d5                	j	80003a70 <sys_set_priority+0x9a>

0000000080003a8e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003a8e:	7179                	addi	sp,sp,-48
    80003a90:	f406                	sd	ra,40(sp)
    80003a92:	f022                	sd	s0,32(sp)
    80003a94:	ec26                	sd	s1,24(sp)
    80003a96:	e84a                	sd	s2,16(sp)
    80003a98:	e44e                	sd	s3,8(sp)
    80003a9a:	e052                	sd	s4,0(sp)
    80003a9c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003a9e:	00005597          	auipc	a1,0x5
    80003aa2:	d9a58593          	addi	a1,a1,-614 # 80008838 <syscall_names+0xe0>
    80003aa6:	0023a517          	auipc	a0,0x23a
    80003aaa:	9ba50513          	addi	a0,a0,-1606 # 8023d460 <bcache>
    80003aae:	ffffd097          	auipc	ra,0xffffd
    80003ab2:	2dc080e7          	jalr	732(ra) # 80000d8a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003ab6:	00242797          	auipc	a5,0x242
    80003aba:	9aa78793          	addi	a5,a5,-1622 # 80245460 <bcache+0x8000>
    80003abe:	00242717          	auipc	a4,0x242
    80003ac2:	c0a70713          	addi	a4,a4,-1014 # 802456c8 <bcache+0x8268>
    80003ac6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003aca:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003ace:	0023a497          	auipc	s1,0x23a
    80003ad2:	9aa48493          	addi	s1,s1,-1622 # 8023d478 <bcache+0x18>
    b->next = bcache.head.next;
    80003ad6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003ad8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003ada:	00005a17          	auipc	s4,0x5
    80003ade:	d66a0a13          	addi	s4,s4,-666 # 80008840 <syscall_names+0xe8>
    b->next = bcache.head.next;
    80003ae2:	2b893783          	ld	a5,696(s2)
    80003ae6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003ae8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003aec:	85d2                	mv	a1,s4
    80003aee:	01048513          	addi	a0,s1,16
    80003af2:	00001097          	auipc	ra,0x1
    80003af6:	496080e7          	jalr	1174(ra) # 80004f88 <initsleeplock>
    bcache.head.next->prev = b;
    80003afa:	2b893783          	ld	a5,696(s2)
    80003afe:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003b00:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003b04:	45848493          	addi	s1,s1,1112
    80003b08:	fd349de3          	bne	s1,s3,80003ae2 <binit+0x54>
  }
}
    80003b0c:	70a2                	ld	ra,40(sp)
    80003b0e:	7402                	ld	s0,32(sp)
    80003b10:	64e2                	ld	s1,24(sp)
    80003b12:	6942                	ld	s2,16(sp)
    80003b14:	69a2                	ld	s3,8(sp)
    80003b16:	6a02                	ld	s4,0(sp)
    80003b18:	6145                	addi	sp,sp,48
    80003b1a:	8082                	ret

0000000080003b1c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003b1c:	7179                	addi	sp,sp,-48
    80003b1e:	f406                	sd	ra,40(sp)
    80003b20:	f022                	sd	s0,32(sp)
    80003b22:	ec26                	sd	s1,24(sp)
    80003b24:	e84a                	sd	s2,16(sp)
    80003b26:	e44e                	sd	s3,8(sp)
    80003b28:	1800                	addi	s0,sp,48
    80003b2a:	892a                	mv	s2,a0
    80003b2c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003b2e:	0023a517          	auipc	a0,0x23a
    80003b32:	93250513          	addi	a0,a0,-1742 # 8023d460 <bcache>
    80003b36:	ffffd097          	auipc	ra,0xffffd
    80003b3a:	2e4080e7          	jalr	740(ra) # 80000e1a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003b3e:	00242497          	auipc	s1,0x242
    80003b42:	bda4b483          	ld	s1,-1062(s1) # 80245718 <bcache+0x82b8>
    80003b46:	00242797          	auipc	a5,0x242
    80003b4a:	b8278793          	addi	a5,a5,-1150 # 802456c8 <bcache+0x8268>
    80003b4e:	02f48f63          	beq	s1,a5,80003b8c <bread+0x70>
    80003b52:	873e                	mv	a4,a5
    80003b54:	a021                	j	80003b5c <bread+0x40>
    80003b56:	68a4                	ld	s1,80(s1)
    80003b58:	02e48a63          	beq	s1,a4,80003b8c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003b5c:	449c                	lw	a5,8(s1)
    80003b5e:	ff279ce3          	bne	a5,s2,80003b56 <bread+0x3a>
    80003b62:	44dc                	lw	a5,12(s1)
    80003b64:	ff3799e3          	bne	a5,s3,80003b56 <bread+0x3a>
      b->refcnt++;
    80003b68:	40bc                	lw	a5,64(s1)
    80003b6a:	2785                	addiw	a5,a5,1
    80003b6c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003b6e:	0023a517          	auipc	a0,0x23a
    80003b72:	8f250513          	addi	a0,a0,-1806 # 8023d460 <bcache>
    80003b76:	ffffd097          	auipc	ra,0xffffd
    80003b7a:	358080e7          	jalr	856(ra) # 80000ece <release>
      acquiresleep(&b->lock);
    80003b7e:	01048513          	addi	a0,s1,16
    80003b82:	00001097          	auipc	ra,0x1
    80003b86:	440080e7          	jalr	1088(ra) # 80004fc2 <acquiresleep>
      return b;
    80003b8a:	a8b9                	j	80003be8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003b8c:	00242497          	auipc	s1,0x242
    80003b90:	b844b483          	ld	s1,-1148(s1) # 80245710 <bcache+0x82b0>
    80003b94:	00242797          	auipc	a5,0x242
    80003b98:	b3478793          	addi	a5,a5,-1228 # 802456c8 <bcache+0x8268>
    80003b9c:	00f48863          	beq	s1,a5,80003bac <bread+0x90>
    80003ba0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003ba2:	40bc                	lw	a5,64(s1)
    80003ba4:	cf81                	beqz	a5,80003bbc <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003ba6:	64a4                	ld	s1,72(s1)
    80003ba8:	fee49de3          	bne	s1,a4,80003ba2 <bread+0x86>
  panic("bget: no buffers");
    80003bac:	00005517          	auipc	a0,0x5
    80003bb0:	c9c50513          	addi	a0,a0,-868 # 80008848 <syscall_names+0xf0>
    80003bb4:	ffffd097          	auipc	ra,0xffffd
    80003bb8:	988080e7          	jalr	-1656(ra) # 8000053c <panic>
      b->dev = dev;
    80003bbc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003bc0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003bc4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003bc8:	4785                	li	a5,1
    80003bca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003bcc:	0023a517          	auipc	a0,0x23a
    80003bd0:	89450513          	addi	a0,a0,-1900 # 8023d460 <bcache>
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	2fa080e7          	jalr	762(ra) # 80000ece <release>
      acquiresleep(&b->lock);
    80003bdc:	01048513          	addi	a0,s1,16
    80003be0:	00001097          	auipc	ra,0x1
    80003be4:	3e2080e7          	jalr	994(ra) # 80004fc2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003be8:	409c                	lw	a5,0(s1)
    80003bea:	cb89                	beqz	a5,80003bfc <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003bec:	8526                	mv	a0,s1
    80003bee:	70a2                	ld	ra,40(sp)
    80003bf0:	7402                	ld	s0,32(sp)
    80003bf2:	64e2                	ld	s1,24(sp)
    80003bf4:	6942                	ld	s2,16(sp)
    80003bf6:	69a2                	ld	s3,8(sp)
    80003bf8:	6145                	addi	sp,sp,48
    80003bfa:	8082                	ret
    virtio_disk_rw(b, 0);
    80003bfc:	4581                	li	a1,0
    80003bfe:	8526                	mv	a0,s1
    80003c00:	00003097          	auipc	ra,0x3
    80003c04:	f82080e7          	jalr	-126(ra) # 80006b82 <virtio_disk_rw>
    b->valid = 1;
    80003c08:	4785                	li	a5,1
    80003c0a:	c09c                	sw	a5,0(s1)
  return b;
    80003c0c:	b7c5                	j	80003bec <bread+0xd0>

0000000080003c0e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003c0e:	1101                	addi	sp,sp,-32
    80003c10:	ec06                	sd	ra,24(sp)
    80003c12:	e822                	sd	s0,16(sp)
    80003c14:	e426                	sd	s1,8(sp)
    80003c16:	1000                	addi	s0,sp,32
    80003c18:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003c1a:	0541                	addi	a0,a0,16
    80003c1c:	00001097          	auipc	ra,0x1
    80003c20:	440080e7          	jalr	1088(ra) # 8000505c <holdingsleep>
    80003c24:	cd01                	beqz	a0,80003c3c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003c26:	4585                	li	a1,1
    80003c28:	8526                	mv	a0,s1
    80003c2a:	00003097          	auipc	ra,0x3
    80003c2e:	f58080e7          	jalr	-168(ra) # 80006b82 <virtio_disk_rw>
}
    80003c32:	60e2                	ld	ra,24(sp)
    80003c34:	6442                	ld	s0,16(sp)
    80003c36:	64a2                	ld	s1,8(sp)
    80003c38:	6105                	addi	sp,sp,32
    80003c3a:	8082                	ret
    panic("bwrite");
    80003c3c:	00005517          	auipc	a0,0x5
    80003c40:	c2450513          	addi	a0,a0,-988 # 80008860 <syscall_names+0x108>
    80003c44:	ffffd097          	auipc	ra,0xffffd
    80003c48:	8f8080e7          	jalr	-1800(ra) # 8000053c <panic>

0000000080003c4c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003c4c:	1101                	addi	sp,sp,-32
    80003c4e:	ec06                	sd	ra,24(sp)
    80003c50:	e822                	sd	s0,16(sp)
    80003c52:	e426                	sd	s1,8(sp)
    80003c54:	e04a                	sd	s2,0(sp)
    80003c56:	1000                	addi	s0,sp,32
    80003c58:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003c5a:	01050913          	addi	s2,a0,16
    80003c5e:	854a                	mv	a0,s2
    80003c60:	00001097          	auipc	ra,0x1
    80003c64:	3fc080e7          	jalr	1020(ra) # 8000505c <holdingsleep>
    80003c68:	c925                	beqz	a0,80003cd8 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003c6a:	854a                	mv	a0,s2
    80003c6c:	00001097          	auipc	ra,0x1
    80003c70:	3ac080e7          	jalr	940(ra) # 80005018 <releasesleep>

  acquire(&bcache.lock);
    80003c74:	00239517          	auipc	a0,0x239
    80003c78:	7ec50513          	addi	a0,a0,2028 # 8023d460 <bcache>
    80003c7c:	ffffd097          	auipc	ra,0xffffd
    80003c80:	19e080e7          	jalr	414(ra) # 80000e1a <acquire>
  b->refcnt--;
    80003c84:	40bc                	lw	a5,64(s1)
    80003c86:	37fd                	addiw	a5,a5,-1
    80003c88:	0007871b          	sext.w	a4,a5
    80003c8c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003c8e:	e71d                	bnez	a4,80003cbc <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003c90:	68b8                	ld	a4,80(s1)
    80003c92:	64bc                	ld	a5,72(s1)
    80003c94:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003c96:	68b8                	ld	a4,80(s1)
    80003c98:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003c9a:	00241797          	auipc	a5,0x241
    80003c9e:	7c678793          	addi	a5,a5,1990 # 80245460 <bcache+0x8000>
    80003ca2:	2b87b703          	ld	a4,696(a5)
    80003ca6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003ca8:	00242717          	auipc	a4,0x242
    80003cac:	a2070713          	addi	a4,a4,-1504 # 802456c8 <bcache+0x8268>
    80003cb0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003cb2:	2b87b703          	ld	a4,696(a5)
    80003cb6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003cb8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003cbc:	00239517          	auipc	a0,0x239
    80003cc0:	7a450513          	addi	a0,a0,1956 # 8023d460 <bcache>
    80003cc4:	ffffd097          	auipc	ra,0xffffd
    80003cc8:	20a080e7          	jalr	522(ra) # 80000ece <release>
}
    80003ccc:	60e2                	ld	ra,24(sp)
    80003cce:	6442                	ld	s0,16(sp)
    80003cd0:	64a2                	ld	s1,8(sp)
    80003cd2:	6902                	ld	s2,0(sp)
    80003cd4:	6105                	addi	sp,sp,32
    80003cd6:	8082                	ret
    panic("brelse");
    80003cd8:	00005517          	auipc	a0,0x5
    80003cdc:	b9050513          	addi	a0,a0,-1136 # 80008868 <syscall_names+0x110>
    80003ce0:	ffffd097          	auipc	ra,0xffffd
    80003ce4:	85c080e7          	jalr	-1956(ra) # 8000053c <panic>

0000000080003ce8 <bpin>:

void
bpin(struct buf *b) {
    80003ce8:	1101                	addi	sp,sp,-32
    80003cea:	ec06                	sd	ra,24(sp)
    80003cec:	e822                	sd	s0,16(sp)
    80003cee:	e426                	sd	s1,8(sp)
    80003cf0:	1000                	addi	s0,sp,32
    80003cf2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003cf4:	00239517          	auipc	a0,0x239
    80003cf8:	76c50513          	addi	a0,a0,1900 # 8023d460 <bcache>
    80003cfc:	ffffd097          	auipc	ra,0xffffd
    80003d00:	11e080e7          	jalr	286(ra) # 80000e1a <acquire>
  b->refcnt++;
    80003d04:	40bc                	lw	a5,64(s1)
    80003d06:	2785                	addiw	a5,a5,1
    80003d08:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003d0a:	00239517          	auipc	a0,0x239
    80003d0e:	75650513          	addi	a0,a0,1878 # 8023d460 <bcache>
    80003d12:	ffffd097          	auipc	ra,0xffffd
    80003d16:	1bc080e7          	jalr	444(ra) # 80000ece <release>
}
    80003d1a:	60e2                	ld	ra,24(sp)
    80003d1c:	6442                	ld	s0,16(sp)
    80003d1e:	64a2                	ld	s1,8(sp)
    80003d20:	6105                	addi	sp,sp,32
    80003d22:	8082                	ret

0000000080003d24 <bunpin>:

void
bunpin(struct buf *b) {
    80003d24:	1101                	addi	sp,sp,-32
    80003d26:	ec06                	sd	ra,24(sp)
    80003d28:	e822                	sd	s0,16(sp)
    80003d2a:	e426                	sd	s1,8(sp)
    80003d2c:	1000                	addi	s0,sp,32
    80003d2e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003d30:	00239517          	auipc	a0,0x239
    80003d34:	73050513          	addi	a0,a0,1840 # 8023d460 <bcache>
    80003d38:	ffffd097          	auipc	ra,0xffffd
    80003d3c:	0e2080e7          	jalr	226(ra) # 80000e1a <acquire>
  b->refcnt--;
    80003d40:	40bc                	lw	a5,64(s1)
    80003d42:	37fd                	addiw	a5,a5,-1
    80003d44:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003d46:	00239517          	auipc	a0,0x239
    80003d4a:	71a50513          	addi	a0,a0,1818 # 8023d460 <bcache>
    80003d4e:	ffffd097          	auipc	ra,0xffffd
    80003d52:	180080e7          	jalr	384(ra) # 80000ece <release>
}
    80003d56:	60e2                	ld	ra,24(sp)
    80003d58:	6442                	ld	s0,16(sp)
    80003d5a:	64a2                	ld	s1,8(sp)
    80003d5c:	6105                	addi	sp,sp,32
    80003d5e:	8082                	ret

0000000080003d60 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003d60:	1101                	addi	sp,sp,-32
    80003d62:	ec06                	sd	ra,24(sp)
    80003d64:	e822                	sd	s0,16(sp)
    80003d66:	e426                	sd	s1,8(sp)
    80003d68:	e04a                	sd	s2,0(sp)
    80003d6a:	1000                	addi	s0,sp,32
    80003d6c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003d6e:	00d5d59b          	srliw	a1,a1,0xd
    80003d72:	00242797          	auipc	a5,0x242
    80003d76:	dca7a783          	lw	a5,-566(a5) # 80245b3c <sb+0x1c>
    80003d7a:	9dbd                	addw	a1,a1,a5
    80003d7c:	00000097          	auipc	ra,0x0
    80003d80:	da0080e7          	jalr	-608(ra) # 80003b1c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003d84:	0074f713          	andi	a4,s1,7
    80003d88:	4785                	li	a5,1
    80003d8a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003d8e:	14ce                	slli	s1,s1,0x33
    80003d90:	90d9                	srli	s1,s1,0x36
    80003d92:	00950733          	add	a4,a0,s1
    80003d96:	05874703          	lbu	a4,88(a4)
    80003d9a:	00e7f6b3          	and	a3,a5,a4
    80003d9e:	c69d                	beqz	a3,80003dcc <bfree+0x6c>
    80003da0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003da2:	94aa                	add	s1,s1,a0
    80003da4:	fff7c793          	not	a5,a5
    80003da8:	8f7d                	and	a4,a4,a5
    80003daa:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003dae:	00001097          	auipc	ra,0x1
    80003db2:	0f6080e7          	jalr	246(ra) # 80004ea4 <log_write>
  brelse(bp);
    80003db6:	854a                	mv	a0,s2
    80003db8:	00000097          	auipc	ra,0x0
    80003dbc:	e94080e7          	jalr	-364(ra) # 80003c4c <brelse>
}
    80003dc0:	60e2                	ld	ra,24(sp)
    80003dc2:	6442                	ld	s0,16(sp)
    80003dc4:	64a2                	ld	s1,8(sp)
    80003dc6:	6902                	ld	s2,0(sp)
    80003dc8:	6105                	addi	sp,sp,32
    80003dca:	8082                	ret
    panic("freeing free block");
    80003dcc:	00005517          	auipc	a0,0x5
    80003dd0:	aa450513          	addi	a0,a0,-1372 # 80008870 <syscall_names+0x118>
    80003dd4:	ffffc097          	auipc	ra,0xffffc
    80003dd8:	768080e7          	jalr	1896(ra) # 8000053c <panic>

0000000080003ddc <balloc>:
{
    80003ddc:	711d                	addi	sp,sp,-96
    80003dde:	ec86                	sd	ra,88(sp)
    80003de0:	e8a2                	sd	s0,80(sp)
    80003de2:	e4a6                	sd	s1,72(sp)
    80003de4:	e0ca                	sd	s2,64(sp)
    80003de6:	fc4e                	sd	s3,56(sp)
    80003de8:	f852                	sd	s4,48(sp)
    80003dea:	f456                	sd	s5,40(sp)
    80003dec:	f05a                	sd	s6,32(sp)
    80003dee:	ec5e                	sd	s7,24(sp)
    80003df0:	e862                	sd	s8,16(sp)
    80003df2:	e466                	sd	s9,8(sp)
    80003df4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003df6:	00242797          	auipc	a5,0x242
    80003dfa:	d2e7a783          	lw	a5,-722(a5) # 80245b24 <sb+0x4>
    80003dfe:	cff5                	beqz	a5,80003efa <balloc+0x11e>
    80003e00:	8baa                	mv	s7,a0
    80003e02:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003e04:	00242b17          	auipc	s6,0x242
    80003e08:	d1cb0b13          	addi	s6,s6,-740 # 80245b20 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003e0c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003e0e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003e10:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003e12:	6c89                	lui	s9,0x2
    80003e14:	a061                	j	80003e9c <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003e16:	97ca                	add	a5,a5,s2
    80003e18:	8e55                	or	a2,a2,a3
    80003e1a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003e1e:	854a                	mv	a0,s2
    80003e20:	00001097          	auipc	ra,0x1
    80003e24:	084080e7          	jalr	132(ra) # 80004ea4 <log_write>
        brelse(bp);
    80003e28:	854a                	mv	a0,s2
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	e22080e7          	jalr	-478(ra) # 80003c4c <brelse>
  bp = bread(dev, bno);
    80003e32:	85a6                	mv	a1,s1
    80003e34:	855e                	mv	a0,s7
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	ce6080e7          	jalr	-794(ra) # 80003b1c <bread>
    80003e3e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003e40:	40000613          	li	a2,1024
    80003e44:	4581                	li	a1,0
    80003e46:	05850513          	addi	a0,a0,88
    80003e4a:	ffffd097          	auipc	ra,0xffffd
    80003e4e:	0cc080e7          	jalr	204(ra) # 80000f16 <memset>
  log_write(bp);
    80003e52:	854a                	mv	a0,s2
    80003e54:	00001097          	auipc	ra,0x1
    80003e58:	050080e7          	jalr	80(ra) # 80004ea4 <log_write>
  brelse(bp);
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	dee080e7          	jalr	-530(ra) # 80003c4c <brelse>
}
    80003e66:	8526                	mv	a0,s1
    80003e68:	60e6                	ld	ra,88(sp)
    80003e6a:	6446                	ld	s0,80(sp)
    80003e6c:	64a6                	ld	s1,72(sp)
    80003e6e:	6906                	ld	s2,64(sp)
    80003e70:	79e2                	ld	s3,56(sp)
    80003e72:	7a42                	ld	s4,48(sp)
    80003e74:	7aa2                	ld	s5,40(sp)
    80003e76:	7b02                	ld	s6,32(sp)
    80003e78:	6be2                	ld	s7,24(sp)
    80003e7a:	6c42                	ld	s8,16(sp)
    80003e7c:	6ca2                	ld	s9,8(sp)
    80003e7e:	6125                	addi	sp,sp,96
    80003e80:	8082                	ret
    brelse(bp);
    80003e82:	854a                	mv	a0,s2
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	dc8080e7          	jalr	-568(ra) # 80003c4c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003e8c:	015c87bb          	addw	a5,s9,s5
    80003e90:	00078a9b          	sext.w	s5,a5
    80003e94:	004b2703          	lw	a4,4(s6)
    80003e98:	06eaf163          	bgeu	s5,a4,80003efa <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003e9c:	41fad79b          	sraiw	a5,s5,0x1f
    80003ea0:	0137d79b          	srliw	a5,a5,0x13
    80003ea4:	015787bb          	addw	a5,a5,s5
    80003ea8:	40d7d79b          	sraiw	a5,a5,0xd
    80003eac:	01cb2583          	lw	a1,28(s6)
    80003eb0:	9dbd                	addw	a1,a1,a5
    80003eb2:	855e                	mv	a0,s7
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	c68080e7          	jalr	-920(ra) # 80003b1c <bread>
    80003ebc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ebe:	004b2503          	lw	a0,4(s6)
    80003ec2:	000a849b          	sext.w	s1,s5
    80003ec6:	8762                	mv	a4,s8
    80003ec8:	faa4fde3          	bgeu	s1,a0,80003e82 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003ecc:	00777693          	andi	a3,a4,7
    80003ed0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003ed4:	41f7579b          	sraiw	a5,a4,0x1f
    80003ed8:	01d7d79b          	srliw	a5,a5,0x1d
    80003edc:	9fb9                	addw	a5,a5,a4
    80003ede:	4037d79b          	sraiw	a5,a5,0x3
    80003ee2:	00f90633          	add	a2,s2,a5
    80003ee6:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003eea:	00c6f5b3          	and	a1,a3,a2
    80003eee:	d585                	beqz	a1,80003e16 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ef0:	2705                	addiw	a4,a4,1
    80003ef2:	2485                	addiw	s1,s1,1
    80003ef4:	fd471ae3          	bne	a4,s4,80003ec8 <balloc+0xec>
    80003ef8:	b769                	j	80003e82 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003efa:	00005517          	auipc	a0,0x5
    80003efe:	98e50513          	addi	a0,a0,-1650 # 80008888 <syscall_names+0x130>
    80003f02:	ffffc097          	auipc	ra,0xffffc
    80003f06:	684080e7          	jalr	1668(ra) # 80000586 <printf>
  return 0;
    80003f0a:	4481                	li	s1,0
    80003f0c:	bfa9                	j	80003e66 <balloc+0x8a>

0000000080003f0e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003f0e:	7179                	addi	sp,sp,-48
    80003f10:	f406                	sd	ra,40(sp)
    80003f12:	f022                	sd	s0,32(sp)
    80003f14:	ec26                	sd	s1,24(sp)
    80003f16:	e84a                	sd	s2,16(sp)
    80003f18:	e44e                	sd	s3,8(sp)
    80003f1a:	e052                	sd	s4,0(sp)
    80003f1c:	1800                	addi	s0,sp,48
    80003f1e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003f20:	47ad                	li	a5,11
    80003f22:	02b7e863          	bltu	a5,a1,80003f52 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003f26:	02059793          	slli	a5,a1,0x20
    80003f2a:	01e7d593          	srli	a1,a5,0x1e
    80003f2e:	00b504b3          	add	s1,a0,a1
    80003f32:	0504a903          	lw	s2,80(s1)
    80003f36:	06091e63          	bnez	s2,80003fb2 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003f3a:	4108                	lw	a0,0(a0)
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	ea0080e7          	jalr	-352(ra) # 80003ddc <balloc>
    80003f44:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003f48:	06090563          	beqz	s2,80003fb2 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003f4c:	0524a823          	sw	s2,80(s1)
    80003f50:	a08d                	j	80003fb2 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003f52:	ff45849b          	addiw	s1,a1,-12
    80003f56:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003f5a:	0ff00793          	li	a5,255
    80003f5e:	08e7e563          	bltu	a5,a4,80003fe8 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003f62:	08052903          	lw	s2,128(a0)
    80003f66:	00091d63          	bnez	s2,80003f80 <bmap+0x72>
      addr = balloc(ip->dev);
    80003f6a:	4108                	lw	a0,0(a0)
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	e70080e7          	jalr	-400(ra) # 80003ddc <balloc>
    80003f74:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003f78:	02090d63          	beqz	s2,80003fb2 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003f7c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003f80:	85ca                	mv	a1,s2
    80003f82:	0009a503          	lw	a0,0(s3)
    80003f86:	00000097          	auipc	ra,0x0
    80003f8a:	b96080e7          	jalr	-1130(ra) # 80003b1c <bread>
    80003f8e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003f90:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003f94:	02049713          	slli	a4,s1,0x20
    80003f98:	01e75593          	srli	a1,a4,0x1e
    80003f9c:	00b784b3          	add	s1,a5,a1
    80003fa0:	0004a903          	lw	s2,0(s1)
    80003fa4:	02090063          	beqz	s2,80003fc4 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003fa8:	8552                	mv	a0,s4
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	ca2080e7          	jalr	-862(ra) # 80003c4c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003fb2:	854a                	mv	a0,s2
    80003fb4:	70a2                	ld	ra,40(sp)
    80003fb6:	7402                	ld	s0,32(sp)
    80003fb8:	64e2                	ld	s1,24(sp)
    80003fba:	6942                	ld	s2,16(sp)
    80003fbc:	69a2                	ld	s3,8(sp)
    80003fbe:	6a02                	ld	s4,0(sp)
    80003fc0:	6145                	addi	sp,sp,48
    80003fc2:	8082                	ret
      addr = balloc(ip->dev);
    80003fc4:	0009a503          	lw	a0,0(s3)
    80003fc8:	00000097          	auipc	ra,0x0
    80003fcc:	e14080e7          	jalr	-492(ra) # 80003ddc <balloc>
    80003fd0:	0005091b          	sext.w	s2,a0
      if(addr){
    80003fd4:	fc090ae3          	beqz	s2,80003fa8 <bmap+0x9a>
        a[bn] = addr;
    80003fd8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003fdc:	8552                	mv	a0,s4
    80003fde:	00001097          	auipc	ra,0x1
    80003fe2:	ec6080e7          	jalr	-314(ra) # 80004ea4 <log_write>
    80003fe6:	b7c9                	j	80003fa8 <bmap+0x9a>
  panic("bmap: out of range");
    80003fe8:	00005517          	auipc	a0,0x5
    80003fec:	8b850513          	addi	a0,a0,-1864 # 800088a0 <syscall_names+0x148>
    80003ff0:	ffffc097          	auipc	ra,0xffffc
    80003ff4:	54c080e7          	jalr	1356(ra) # 8000053c <panic>

0000000080003ff8 <iget>:
{
    80003ff8:	7179                	addi	sp,sp,-48
    80003ffa:	f406                	sd	ra,40(sp)
    80003ffc:	f022                	sd	s0,32(sp)
    80003ffe:	ec26                	sd	s1,24(sp)
    80004000:	e84a                	sd	s2,16(sp)
    80004002:	e44e                	sd	s3,8(sp)
    80004004:	e052                	sd	s4,0(sp)
    80004006:	1800                	addi	s0,sp,48
    80004008:	89aa                	mv	s3,a0
    8000400a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000400c:	00242517          	auipc	a0,0x242
    80004010:	b3450513          	addi	a0,a0,-1228 # 80245b40 <itable>
    80004014:	ffffd097          	auipc	ra,0xffffd
    80004018:	e06080e7          	jalr	-506(ra) # 80000e1a <acquire>
  empty = 0;
    8000401c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000401e:	00242497          	auipc	s1,0x242
    80004022:	b3a48493          	addi	s1,s1,-1222 # 80245b58 <itable+0x18>
    80004026:	00243697          	auipc	a3,0x243
    8000402a:	5c268693          	addi	a3,a3,1474 # 802475e8 <log>
    8000402e:	a039                	j	8000403c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004030:	02090b63          	beqz	s2,80004066 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004034:	08848493          	addi	s1,s1,136
    80004038:	02d48a63          	beq	s1,a3,8000406c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000403c:	449c                	lw	a5,8(s1)
    8000403e:	fef059e3          	blez	a5,80004030 <iget+0x38>
    80004042:	4098                	lw	a4,0(s1)
    80004044:	ff3716e3          	bne	a4,s3,80004030 <iget+0x38>
    80004048:	40d8                	lw	a4,4(s1)
    8000404a:	ff4713e3          	bne	a4,s4,80004030 <iget+0x38>
      ip->ref++;
    8000404e:	2785                	addiw	a5,a5,1
    80004050:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004052:	00242517          	auipc	a0,0x242
    80004056:	aee50513          	addi	a0,a0,-1298 # 80245b40 <itable>
    8000405a:	ffffd097          	auipc	ra,0xffffd
    8000405e:	e74080e7          	jalr	-396(ra) # 80000ece <release>
      return ip;
    80004062:	8926                	mv	s2,s1
    80004064:	a03d                	j	80004092 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004066:	f7f9                	bnez	a5,80004034 <iget+0x3c>
    80004068:	8926                	mv	s2,s1
    8000406a:	b7e9                	j	80004034 <iget+0x3c>
  if(empty == 0)
    8000406c:	02090c63          	beqz	s2,800040a4 <iget+0xac>
  ip->dev = dev;
    80004070:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004074:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004078:	4785                	li	a5,1
    8000407a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000407e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004082:	00242517          	auipc	a0,0x242
    80004086:	abe50513          	addi	a0,a0,-1346 # 80245b40 <itable>
    8000408a:	ffffd097          	auipc	ra,0xffffd
    8000408e:	e44080e7          	jalr	-444(ra) # 80000ece <release>
}
    80004092:	854a                	mv	a0,s2
    80004094:	70a2                	ld	ra,40(sp)
    80004096:	7402                	ld	s0,32(sp)
    80004098:	64e2                	ld	s1,24(sp)
    8000409a:	6942                	ld	s2,16(sp)
    8000409c:	69a2                	ld	s3,8(sp)
    8000409e:	6a02                	ld	s4,0(sp)
    800040a0:	6145                	addi	sp,sp,48
    800040a2:	8082                	ret
    panic("iget: no inodes");
    800040a4:	00005517          	auipc	a0,0x5
    800040a8:	81450513          	addi	a0,a0,-2028 # 800088b8 <syscall_names+0x160>
    800040ac:	ffffc097          	auipc	ra,0xffffc
    800040b0:	490080e7          	jalr	1168(ra) # 8000053c <panic>

00000000800040b4 <fsinit>:
fsinit(int dev) {
    800040b4:	7179                	addi	sp,sp,-48
    800040b6:	f406                	sd	ra,40(sp)
    800040b8:	f022                	sd	s0,32(sp)
    800040ba:	ec26                	sd	s1,24(sp)
    800040bc:	e84a                	sd	s2,16(sp)
    800040be:	e44e                	sd	s3,8(sp)
    800040c0:	1800                	addi	s0,sp,48
    800040c2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800040c4:	4585                	li	a1,1
    800040c6:	00000097          	auipc	ra,0x0
    800040ca:	a56080e7          	jalr	-1450(ra) # 80003b1c <bread>
    800040ce:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800040d0:	00242997          	auipc	s3,0x242
    800040d4:	a5098993          	addi	s3,s3,-1456 # 80245b20 <sb>
    800040d8:	02000613          	li	a2,32
    800040dc:	05850593          	addi	a1,a0,88
    800040e0:	854e                	mv	a0,s3
    800040e2:	ffffd097          	auipc	ra,0xffffd
    800040e6:	e90080e7          	jalr	-368(ra) # 80000f72 <memmove>
  brelse(bp);
    800040ea:	8526                	mv	a0,s1
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	b60080e7          	jalr	-1184(ra) # 80003c4c <brelse>
  if(sb.magic != FSMAGIC)
    800040f4:	0009a703          	lw	a4,0(s3)
    800040f8:	102037b7          	lui	a5,0x10203
    800040fc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004100:	02f71263          	bne	a4,a5,80004124 <fsinit+0x70>
  initlog(dev, &sb);
    80004104:	00242597          	auipc	a1,0x242
    80004108:	a1c58593          	addi	a1,a1,-1508 # 80245b20 <sb>
    8000410c:	854a                	mv	a0,s2
    8000410e:	00001097          	auipc	ra,0x1
    80004112:	b2c080e7          	jalr	-1236(ra) # 80004c3a <initlog>
}
    80004116:	70a2                	ld	ra,40(sp)
    80004118:	7402                	ld	s0,32(sp)
    8000411a:	64e2                	ld	s1,24(sp)
    8000411c:	6942                	ld	s2,16(sp)
    8000411e:	69a2                	ld	s3,8(sp)
    80004120:	6145                	addi	sp,sp,48
    80004122:	8082                	ret
    panic("invalid file system");
    80004124:	00004517          	auipc	a0,0x4
    80004128:	7a450513          	addi	a0,a0,1956 # 800088c8 <syscall_names+0x170>
    8000412c:	ffffc097          	auipc	ra,0xffffc
    80004130:	410080e7          	jalr	1040(ra) # 8000053c <panic>

0000000080004134 <iinit>:
{
    80004134:	7179                	addi	sp,sp,-48
    80004136:	f406                	sd	ra,40(sp)
    80004138:	f022                	sd	s0,32(sp)
    8000413a:	ec26                	sd	s1,24(sp)
    8000413c:	e84a                	sd	s2,16(sp)
    8000413e:	e44e                	sd	s3,8(sp)
    80004140:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004142:	00004597          	auipc	a1,0x4
    80004146:	79e58593          	addi	a1,a1,1950 # 800088e0 <syscall_names+0x188>
    8000414a:	00242517          	auipc	a0,0x242
    8000414e:	9f650513          	addi	a0,a0,-1546 # 80245b40 <itable>
    80004152:	ffffd097          	auipc	ra,0xffffd
    80004156:	c38080e7          	jalr	-968(ra) # 80000d8a <initlock>
  for(i = 0; i < NINODE; i++) {
    8000415a:	00242497          	auipc	s1,0x242
    8000415e:	a0e48493          	addi	s1,s1,-1522 # 80245b68 <itable+0x28>
    80004162:	00243997          	auipc	s3,0x243
    80004166:	49698993          	addi	s3,s3,1174 # 802475f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000416a:	00004917          	auipc	s2,0x4
    8000416e:	77e90913          	addi	s2,s2,1918 # 800088e8 <syscall_names+0x190>
    80004172:	85ca                	mv	a1,s2
    80004174:	8526                	mv	a0,s1
    80004176:	00001097          	auipc	ra,0x1
    8000417a:	e12080e7          	jalr	-494(ra) # 80004f88 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000417e:	08848493          	addi	s1,s1,136
    80004182:	ff3498e3          	bne	s1,s3,80004172 <iinit+0x3e>
}
    80004186:	70a2                	ld	ra,40(sp)
    80004188:	7402                	ld	s0,32(sp)
    8000418a:	64e2                	ld	s1,24(sp)
    8000418c:	6942                	ld	s2,16(sp)
    8000418e:	69a2                	ld	s3,8(sp)
    80004190:	6145                	addi	sp,sp,48
    80004192:	8082                	ret

0000000080004194 <ialloc>:
{
    80004194:	7139                	addi	sp,sp,-64
    80004196:	fc06                	sd	ra,56(sp)
    80004198:	f822                	sd	s0,48(sp)
    8000419a:	f426                	sd	s1,40(sp)
    8000419c:	f04a                	sd	s2,32(sp)
    8000419e:	ec4e                	sd	s3,24(sp)
    800041a0:	e852                	sd	s4,16(sp)
    800041a2:	e456                	sd	s5,8(sp)
    800041a4:	e05a                	sd	s6,0(sp)
    800041a6:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800041a8:	00242717          	auipc	a4,0x242
    800041ac:	98472703          	lw	a4,-1660(a4) # 80245b2c <sb+0xc>
    800041b0:	4785                	li	a5,1
    800041b2:	04e7f863          	bgeu	a5,a4,80004202 <ialloc+0x6e>
    800041b6:	8aaa                	mv	s5,a0
    800041b8:	8b2e                	mv	s6,a1
    800041ba:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800041bc:	00242a17          	auipc	s4,0x242
    800041c0:	964a0a13          	addi	s4,s4,-1692 # 80245b20 <sb>
    800041c4:	00495593          	srli	a1,s2,0x4
    800041c8:	018a2783          	lw	a5,24(s4)
    800041cc:	9dbd                	addw	a1,a1,a5
    800041ce:	8556                	mv	a0,s5
    800041d0:	00000097          	auipc	ra,0x0
    800041d4:	94c080e7          	jalr	-1716(ra) # 80003b1c <bread>
    800041d8:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800041da:	05850993          	addi	s3,a0,88
    800041de:	00f97793          	andi	a5,s2,15
    800041e2:	079a                	slli	a5,a5,0x6
    800041e4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800041e6:	00099783          	lh	a5,0(s3)
    800041ea:	cf9d                	beqz	a5,80004228 <ialloc+0x94>
    brelse(bp);
    800041ec:	00000097          	auipc	ra,0x0
    800041f0:	a60080e7          	jalr	-1440(ra) # 80003c4c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800041f4:	0905                	addi	s2,s2,1
    800041f6:	00ca2703          	lw	a4,12(s4)
    800041fa:	0009079b          	sext.w	a5,s2
    800041fe:	fce7e3e3          	bltu	a5,a4,800041c4 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80004202:	00004517          	auipc	a0,0x4
    80004206:	6ee50513          	addi	a0,a0,1774 # 800088f0 <syscall_names+0x198>
    8000420a:	ffffc097          	auipc	ra,0xffffc
    8000420e:	37c080e7          	jalr	892(ra) # 80000586 <printf>
  return 0;
    80004212:	4501                	li	a0,0
}
    80004214:	70e2                	ld	ra,56(sp)
    80004216:	7442                	ld	s0,48(sp)
    80004218:	74a2                	ld	s1,40(sp)
    8000421a:	7902                	ld	s2,32(sp)
    8000421c:	69e2                	ld	s3,24(sp)
    8000421e:	6a42                	ld	s4,16(sp)
    80004220:	6aa2                	ld	s5,8(sp)
    80004222:	6b02                	ld	s6,0(sp)
    80004224:	6121                	addi	sp,sp,64
    80004226:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80004228:	04000613          	li	a2,64
    8000422c:	4581                	li	a1,0
    8000422e:	854e                	mv	a0,s3
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	ce6080e7          	jalr	-794(ra) # 80000f16 <memset>
      dip->type = type;
    80004238:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000423c:	8526                	mv	a0,s1
    8000423e:	00001097          	auipc	ra,0x1
    80004242:	c66080e7          	jalr	-922(ra) # 80004ea4 <log_write>
      brelse(bp);
    80004246:	8526                	mv	a0,s1
    80004248:	00000097          	auipc	ra,0x0
    8000424c:	a04080e7          	jalr	-1532(ra) # 80003c4c <brelse>
      return iget(dev, inum);
    80004250:	0009059b          	sext.w	a1,s2
    80004254:	8556                	mv	a0,s5
    80004256:	00000097          	auipc	ra,0x0
    8000425a:	da2080e7          	jalr	-606(ra) # 80003ff8 <iget>
    8000425e:	bf5d                	j	80004214 <ialloc+0x80>

0000000080004260 <iupdate>:
{
    80004260:	1101                	addi	sp,sp,-32
    80004262:	ec06                	sd	ra,24(sp)
    80004264:	e822                	sd	s0,16(sp)
    80004266:	e426                	sd	s1,8(sp)
    80004268:	e04a                	sd	s2,0(sp)
    8000426a:	1000                	addi	s0,sp,32
    8000426c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000426e:	415c                	lw	a5,4(a0)
    80004270:	0047d79b          	srliw	a5,a5,0x4
    80004274:	00242597          	auipc	a1,0x242
    80004278:	8c45a583          	lw	a1,-1852(a1) # 80245b38 <sb+0x18>
    8000427c:	9dbd                	addw	a1,a1,a5
    8000427e:	4108                	lw	a0,0(a0)
    80004280:	00000097          	auipc	ra,0x0
    80004284:	89c080e7          	jalr	-1892(ra) # 80003b1c <bread>
    80004288:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000428a:	05850793          	addi	a5,a0,88
    8000428e:	40d8                	lw	a4,4(s1)
    80004290:	8b3d                	andi	a4,a4,15
    80004292:	071a                	slli	a4,a4,0x6
    80004294:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80004296:	04449703          	lh	a4,68(s1)
    8000429a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000429e:	04649703          	lh	a4,70(s1)
    800042a2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800042a6:	04849703          	lh	a4,72(s1)
    800042aa:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800042ae:	04a49703          	lh	a4,74(s1)
    800042b2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800042b6:	44f8                	lw	a4,76(s1)
    800042b8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800042ba:	03400613          	li	a2,52
    800042be:	05048593          	addi	a1,s1,80
    800042c2:	00c78513          	addi	a0,a5,12
    800042c6:	ffffd097          	auipc	ra,0xffffd
    800042ca:	cac080e7          	jalr	-852(ra) # 80000f72 <memmove>
  log_write(bp);
    800042ce:	854a                	mv	a0,s2
    800042d0:	00001097          	auipc	ra,0x1
    800042d4:	bd4080e7          	jalr	-1068(ra) # 80004ea4 <log_write>
  brelse(bp);
    800042d8:	854a                	mv	a0,s2
    800042da:	00000097          	auipc	ra,0x0
    800042de:	972080e7          	jalr	-1678(ra) # 80003c4c <brelse>
}
    800042e2:	60e2                	ld	ra,24(sp)
    800042e4:	6442                	ld	s0,16(sp)
    800042e6:	64a2                	ld	s1,8(sp)
    800042e8:	6902                	ld	s2,0(sp)
    800042ea:	6105                	addi	sp,sp,32
    800042ec:	8082                	ret

00000000800042ee <idup>:
{
    800042ee:	1101                	addi	sp,sp,-32
    800042f0:	ec06                	sd	ra,24(sp)
    800042f2:	e822                	sd	s0,16(sp)
    800042f4:	e426                	sd	s1,8(sp)
    800042f6:	1000                	addi	s0,sp,32
    800042f8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800042fa:	00242517          	auipc	a0,0x242
    800042fe:	84650513          	addi	a0,a0,-1978 # 80245b40 <itable>
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	b18080e7          	jalr	-1256(ra) # 80000e1a <acquire>
  ip->ref++;
    8000430a:	449c                	lw	a5,8(s1)
    8000430c:	2785                	addiw	a5,a5,1
    8000430e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004310:	00242517          	auipc	a0,0x242
    80004314:	83050513          	addi	a0,a0,-2000 # 80245b40 <itable>
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	bb6080e7          	jalr	-1098(ra) # 80000ece <release>
}
    80004320:	8526                	mv	a0,s1
    80004322:	60e2                	ld	ra,24(sp)
    80004324:	6442                	ld	s0,16(sp)
    80004326:	64a2                	ld	s1,8(sp)
    80004328:	6105                	addi	sp,sp,32
    8000432a:	8082                	ret

000000008000432c <ilock>:
{
    8000432c:	1101                	addi	sp,sp,-32
    8000432e:	ec06                	sd	ra,24(sp)
    80004330:	e822                	sd	s0,16(sp)
    80004332:	e426                	sd	s1,8(sp)
    80004334:	e04a                	sd	s2,0(sp)
    80004336:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004338:	c115                	beqz	a0,8000435c <ilock+0x30>
    8000433a:	84aa                	mv	s1,a0
    8000433c:	451c                	lw	a5,8(a0)
    8000433e:	00f05f63          	blez	a5,8000435c <ilock+0x30>
  acquiresleep(&ip->lock);
    80004342:	0541                	addi	a0,a0,16
    80004344:	00001097          	auipc	ra,0x1
    80004348:	c7e080e7          	jalr	-898(ra) # 80004fc2 <acquiresleep>
  if(ip->valid == 0){
    8000434c:	40bc                	lw	a5,64(s1)
    8000434e:	cf99                	beqz	a5,8000436c <ilock+0x40>
}
    80004350:	60e2                	ld	ra,24(sp)
    80004352:	6442                	ld	s0,16(sp)
    80004354:	64a2                	ld	s1,8(sp)
    80004356:	6902                	ld	s2,0(sp)
    80004358:	6105                	addi	sp,sp,32
    8000435a:	8082                	ret
    panic("ilock");
    8000435c:	00004517          	auipc	a0,0x4
    80004360:	5ac50513          	addi	a0,a0,1452 # 80008908 <syscall_names+0x1b0>
    80004364:	ffffc097          	auipc	ra,0xffffc
    80004368:	1d8080e7          	jalr	472(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000436c:	40dc                	lw	a5,4(s1)
    8000436e:	0047d79b          	srliw	a5,a5,0x4
    80004372:	00241597          	auipc	a1,0x241
    80004376:	7c65a583          	lw	a1,1990(a1) # 80245b38 <sb+0x18>
    8000437a:	9dbd                	addw	a1,a1,a5
    8000437c:	4088                	lw	a0,0(s1)
    8000437e:	fffff097          	auipc	ra,0xfffff
    80004382:	79e080e7          	jalr	1950(ra) # 80003b1c <bread>
    80004386:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004388:	05850593          	addi	a1,a0,88
    8000438c:	40dc                	lw	a5,4(s1)
    8000438e:	8bbd                	andi	a5,a5,15
    80004390:	079a                	slli	a5,a5,0x6
    80004392:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004394:	00059783          	lh	a5,0(a1)
    80004398:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000439c:	00259783          	lh	a5,2(a1)
    800043a0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800043a4:	00459783          	lh	a5,4(a1)
    800043a8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800043ac:	00659783          	lh	a5,6(a1)
    800043b0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800043b4:	459c                	lw	a5,8(a1)
    800043b6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800043b8:	03400613          	li	a2,52
    800043bc:	05b1                	addi	a1,a1,12
    800043be:	05048513          	addi	a0,s1,80
    800043c2:	ffffd097          	auipc	ra,0xffffd
    800043c6:	bb0080e7          	jalr	-1104(ra) # 80000f72 <memmove>
    brelse(bp);
    800043ca:	854a                	mv	a0,s2
    800043cc:	00000097          	auipc	ra,0x0
    800043d0:	880080e7          	jalr	-1920(ra) # 80003c4c <brelse>
    ip->valid = 1;
    800043d4:	4785                	li	a5,1
    800043d6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800043d8:	04449783          	lh	a5,68(s1)
    800043dc:	fbb5                	bnez	a5,80004350 <ilock+0x24>
      panic("ilock: no type");
    800043de:	00004517          	auipc	a0,0x4
    800043e2:	53250513          	addi	a0,a0,1330 # 80008910 <syscall_names+0x1b8>
    800043e6:	ffffc097          	auipc	ra,0xffffc
    800043ea:	156080e7          	jalr	342(ra) # 8000053c <panic>

00000000800043ee <iunlock>:
{
    800043ee:	1101                	addi	sp,sp,-32
    800043f0:	ec06                	sd	ra,24(sp)
    800043f2:	e822                	sd	s0,16(sp)
    800043f4:	e426                	sd	s1,8(sp)
    800043f6:	e04a                	sd	s2,0(sp)
    800043f8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800043fa:	c905                	beqz	a0,8000442a <iunlock+0x3c>
    800043fc:	84aa                	mv	s1,a0
    800043fe:	01050913          	addi	s2,a0,16
    80004402:	854a                	mv	a0,s2
    80004404:	00001097          	auipc	ra,0x1
    80004408:	c58080e7          	jalr	-936(ra) # 8000505c <holdingsleep>
    8000440c:	cd19                	beqz	a0,8000442a <iunlock+0x3c>
    8000440e:	449c                	lw	a5,8(s1)
    80004410:	00f05d63          	blez	a5,8000442a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004414:	854a                	mv	a0,s2
    80004416:	00001097          	auipc	ra,0x1
    8000441a:	c02080e7          	jalr	-1022(ra) # 80005018 <releasesleep>
}
    8000441e:	60e2                	ld	ra,24(sp)
    80004420:	6442                	ld	s0,16(sp)
    80004422:	64a2                	ld	s1,8(sp)
    80004424:	6902                	ld	s2,0(sp)
    80004426:	6105                	addi	sp,sp,32
    80004428:	8082                	ret
    panic("iunlock");
    8000442a:	00004517          	auipc	a0,0x4
    8000442e:	4f650513          	addi	a0,a0,1270 # 80008920 <syscall_names+0x1c8>
    80004432:	ffffc097          	auipc	ra,0xffffc
    80004436:	10a080e7          	jalr	266(ra) # 8000053c <panic>

000000008000443a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000443a:	7179                	addi	sp,sp,-48
    8000443c:	f406                	sd	ra,40(sp)
    8000443e:	f022                	sd	s0,32(sp)
    80004440:	ec26                	sd	s1,24(sp)
    80004442:	e84a                	sd	s2,16(sp)
    80004444:	e44e                	sd	s3,8(sp)
    80004446:	e052                	sd	s4,0(sp)
    80004448:	1800                	addi	s0,sp,48
    8000444a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000444c:	05050493          	addi	s1,a0,80
    80004450:	08050913          	addi	s2,a0,128
    80004454:	a021                	j	8000445c <itrunc+0x22>
    80004456:	0491                	addi	s1,s1,4
    80004458:	01248d63          	beq	s1,s2,80004472 <itrunc+0x38>
    if(ip->addrs[i]){
    8000445c:	408c                	lw	a1,0(s1)
    8000445e:	dde5                	beqz	a1,80004456 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004460:	0009a503          	lw	a0,0(s3)
    80004464:	00000097          	auipc	ra,0x0
    80004468:	8fc080e7          	jalr	-1796(ra) # 80003d60 <bfree>
      ip->addrs[i] = 0;
    8000446c:	0004a023          	sw	zero,0(s1)
    80004470:	b7dd                	j	80004456 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004472:	0809a583          	lw	a1,128(s3)
    80004476:	e185                	bnez	a1,80004496 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004478:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000447c:	854e                	mv	a0,s3
    8000447e:	00000097          	auipc	ra,0x0
    80004482:	de2080e7          	jalr	-542(ra) # 80004260 <iupdate>
}
    80004486:	70a2                	ld	ra,40(sp)
    80004488:	7402                	ld	s0,32(sp)
    8000448a:	64e2                	ld	s1,24(sp)
    8000448c:	6942                	ld	s2,16(sp)
    8000448e:	69a2                	ld	s3,8(sp)
    80004490:	6a02                	ld	s4,0(sp)
    80004492:	6145                	addi	sp,sp,48
    80004494:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004496:	0009a503          	lw	a0,0(s3)
    8000449a:	fffff097          	auipc	ra,0xfffff
    8000449e:	682080e7          	jalr	1666(ra) # 80003b1c <bread>
    800044a2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800044a4:	05850493          	addi	s1,a0,88
    800044a8:	45850913          	addi	s2,a0,1112
    800044ac:	a021                	j	800044b4 <itrunc+0x7a>
    800044ae:	0491                	addi	s1,s1,4
    800044b0:	01248b63          	beq	s1,s2,800044c6 <itrunc+0x8c>
      if(a[j])
    800044b4:	408c                	lw	a1,0(s1)
    800044b6:	dde5                	beqz	a1,800044ae <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800044b8:	0009a503          	lw	a0,0(s3)
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	8a4080e7          	jalr	-1884(ra) # 80003d60 <bfree>
    800044c4:	b7ed                	j	800044ae <itrunc+0x74>
    brelse(bp);
    800044c6:	8552                	mv	a0,s4
    800044c8:	fffff097          	auipc	ra,0xfffff
    800044cc:	784080e7          	jalr	1924(ra) # 80003c4c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800044d0:	0809a583          	lw	a1,128(s3)
    800044d4:	0009a503          	lw	a0,0(s3)
    800044d8:	00000097          	auipc	ra,0x0
    800044dc:	888080e7          	jalr	-1912(ra) # 80003d60 <bfree>
    ip->addrs[NDIRECT] = 0;
    800044e0:	0809a023          	sw	zero,128(s3)
    800044e4:	bf51                	j	80004478 <itrunc+0x3e>

00000000800044e6 <iput>:
{
    800044e6:	1101                	addi	sp,sp,-32
    800044e8:	ec06                	sd	ra,24(sp)
    800044ea:	e822                	sd	s0,16(sp)
    800044ec:	e426                	sd	s1,8(sp)
    800044ee:	e04a                	sd	s2,0(sp)
    800044f0:	1000                	addi	s0,sp,32
    800044f2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800044f4:	00241517          	auipc	a0,0x241
    800044f8:	64c50513          	addi	a0,a0,1612 # 80245b40 <itable>
    800044fc:	ffffd097          	auipc	ra,0xffffd
    80004500:	91e080e7          	jalr	-1762(ra) # 80000e1a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004504:	4498                	lw	a4,8(s1)
    80004506:	4785                	li	a5,1
    80004508:	02f70363          	beq	a4,a5,8000452e <iput+0x48>
  ip->ref--;
    8000450c:	449c                	lw	a5,8(s1)
    8000450e:	37fd                	addiw	a5,a5,-1
    80004510:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004512:	00241517          	auipc	a0,0x241
    80004516:	62e50513          	addi	a0,a0,1582 # 80245b40 <itable>
    8000451a:	ffffd097          	auipc	ra,0xffffd
    8000451e:	9b4080e7          	jalr	-1612(ra) # 80000ece <release>
}
    80004522:	60e2                	ld	ra,24(sp)
    80004524:	6442                	ld	s0,16(sp)
    80004526:	64a2                	ld	s1,8(sp)
    80004528:	6902                	ld	s2,0(sp)
    8000452a:	6105                	addi	sp,sp,32
    8000452c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000452e:	40bc                	lw	a5,64(s1)
    80004530:	dff1                	beqz	a5,8000450c <iput+0x26>
    80004532:	04a49783          	lh	a5,74(s1)
    80004536:	fbf9                	bnez	a5,8000450c <iput+0x26>
    acquiresleep(&ip->lock);
    80004538:	01048913          	addi	s2,s1,16
    8000453c:	854a                	mv	a0,s2
    8000453e:	00001097          	auipc	ra,0x1
    80004542:	a84080e7          	jalr	-1404(ra) # 80004fc2 <acquiresleep>
    release(&itable.lock);
    80004546:	00241517          	auipc	a0,0x241
    8000454a:	5fa50513          	addi	a0,a0,1530 # 80245b40 <itable>
    8000454e:	ffffd097          	auipc	ra,0xffffd
    80004552:	980080e7          	jalr	-1664(ra) # 80000ece <release>
    itrunc(ip);
    80004556:	8526                	mv	a0,s1
    80004558:	00000097          	auipc	ra,0x0
    8000455c:	ee2080e7          	jalr	-286(ra) # 8000443a <itrunc>
    ip->type = 0;
    80004560:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004564:	8526                	mv	a0,s1
    80004566:	00000097          	auipc	ra,0x0
    8000456a:	cfa080e7          	jalr	-774(ra) # 80004260 <iupdate>
    ip->valid = 0;
    8000456e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004572:	854a                	mv	a0,s2
    80004574:	00001097          	auipc	ra,0x1
    80004578:	aa4080e7          	jalr	-1372(ra) # 80005018 <releasesleep>
    acquire(&itable.lock);
    8000457c:	00241517          	auipc	a0,0x241
    80004580:	5c450513          	addi	a0,a0,1476 # 80245b40 <itable>
    80004584:	ffffd097          	auipc	ra,0xffffd
    80004588:	896080e7          	jalr	-1898(ra) # 80000e1a <acquire>
    8000458c:	b741                	j	8000450c <iput+0x26>

000000008000458e <iunlockput>:
{
    8000458e:	1101                	addi	sp,sp,-32
    80004590:	ec06                	sd	ra,24(sp)
    80004592:	e822                	sd	s0,16(sp)
    80004594:	e426                	sd	s1,8(sp)
    80004596:	1000                	addi	s0,sp,32
    80004598:	84aa                	mv	s1,a0
  iunlock(ip);
    8000459a:	00000097          	auipc	ra,0x0
    8000459e:	e54080e7          	jalr	-428(ra) # 800043ee <iunlock>
  iput(ip);
    800045a2:	8526                	mv	a0,s1
    800045a4:	00000097          	auipc	ra,0x0
    800045a8:	f42080e7          	jalr	-190(ra) # 800044e6 <iput>
}
    800045ac:	60e2                	ld	ra,24(sp)
    800045ae:	6442                	ld	s0,16(sp)
    800045b0:	64a2                	ld	s1,8(sp)
    800045b2:	6105                	addi	sp,sp,32
    800045b4:	8082                	ret

00000000800045b6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800045b6:	1141                	addi	sp,sp,-16
    800045b8:	e422                	sd	s0,8(sp)
    800045ba:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800045bc:	411c                	lw	a5,0(a0)
    800045be:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800045c0:	415c                	lw	a5,4(a0)
    800045c2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800045c4:	04451783          	lh	a5,68(a0)
    800045c8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800045cc:	04a51783          	lh	a5,74(a0)
    800045d0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800045d4:	04c56783          	lwu	a5,76(a0)
    800045d8:	e99c                	sd	a5,16(a1)
}
    800045da:	6422                	ld	s0,8(sp)
    800045dc:	0141                	addi	sp,sp,16
    800045de:	8082                	ret

00000000800045e0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800045e0:	457c                	lw	a5,76(a0)
    800045e2:	0ed7e963          	bltu	a5,a3,800046d4 <readi+0xf4>
{
    800045e6:	7159                	addi	sp,sp,-112
    800045e8:	f486                	sd	ra,104(sp)
    800045ea:	f0a2                	sd	s0,96(sp)
    800045ec:	eca6                	sd	s1,88(sp)
    800045ee:	e8ca                	sd	s2,80(sp)
    800045f0:	e4ce                	sd	s3,72(sp)
    800045f2:	e0d2                	sd	s4,64(sp)
    800045f4:	fc56                	sd	s5,56(sp)
    800045f6:	f85a                	sd	s6,48(sp)
    800045f8:	f45e                	sd	s7,40(sp)
    800045fa:	f062                	sd	s8,32(sp)
    800045fc:	ec66                	sd	s9,24(sp)
    800045fe:	e86a                	sd	s10,16(sp)
    80004600:	e46e                	sd	s11,8(sp)
    80004602:	1880                	addi	s0,sp,112
    80004604:	8b2a                	mv	s6,a0
    80004606:	8bae                	mv	s7,a1
    80004608:	8a32                	mv	s4,a2
    8000460a:	84b6                	mv	s1,a3
    8000460c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000460e:	9f35                	addw	a4,a4,a3
    return 0;
    80004610:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004612:	0ad76063          	bltu	a4,a3,800046b2 <readi+0xd2>
  if(off + n > ip->size)
    80004616:	00e7f463          	bgeu	a5,a4,8000461e <readi+0x3e>
    n = ip->size - off;
    8000461a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000461e:	0a0a8963          	beqz	s5,800046d0 <readi+0xf0>
    80004622:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004624:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004628:	5c7d                	li	s8,-1
    8000462a:	a82d                	j	80004664 <readi+0x84>
    8000462c:	020d1d93          	slli	s11,s10,0x20
    80004630:	020ddd93          	srli	s11,s11,0x20
    80004634:	05890613          	addi	a2,s2,88
    80004638:	86ee                	mv	a3,s11
    8000463a:	963a                	add	a2,a2,a4
    8000463c:	85d2                	mv	a1,s4
    8000463e:	855e                	mv	a0,s7
    80004640:	ffffe097          	auipc	ra,0xffffe
    80004644:	6ea080e7          	jalr	1770(ra) # 80002d2a <either_copyout>
    80004648:	05850d63          	beq	a0,s8,800046a2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000464c:	854a                	mv	a0,s2
    8000464e:	fffff097          	auipc	ra,0xfffff
    80004652:	5fe080e7          	jalr	1534(ra) # 80003c4c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004656:	013d09bb          	addw	s3,s10,s3
    8000465a:	009d04bb          	addw	s1,s10,s1
    8000465e:	9a6e                	add	s4,s4,s11
    80004660:	0559f763          	bgeu	s3,s5,800046ae <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80004664:	00a4d59b          	srliw	a1,s1,0xa
    80004668:	855a                	mv	a0,s6
    8000466a:	00000097          	auipc	ra,0x0
    8000466e:	8a4080e7          	jalr	-1884(ra) # 80003f0e <bmap>
    80004672:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004676:	cd85                	beqz	a1,800046ae <readi+0xce>
    bp = bread(ip->dev, addr);
    80004678:	000b2503          	lw	a0,0(s6)
    8000467c:	fffff097          	auipc	ra,0xfffff
    80004680:	4a0080e7          	jalr	1184(ra) # 80003b1c <bread>
    80004684:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004686:	3ff4f713          	andi	a4,s1,1023
    8000468a:	40ec87bb          	subw	a5,s9,a4
    8000468e:	413a86bb          	subw	a3,s5,s3
    80004692:	8d3e                	mv	s10,a5
    80004694:	2781                	sext.w	a5,a5
    80004696:	0006861b          	sext.w	a2,a3
    8000469a:	f8f679e3          	bgeu	a2,a5,8000462c <readi+0x4c>
    8000469e:	8d36                	mv	s10,a3
    800046a0:	b771                	j	8000462c <readi+0x4c>
      brelse(bp);
    800046a2:	854a                	mv	a0,s2
    800046a4:	fffff097          	auipc	ra,0xfffff
    800046a8:	5a8080e7          	jalr	1448(ra) # 80003c4c <brelse>
      tot = -1;
    800046ac:	59fd                	li	s3,-1
  }
  return tot;
    800046ae:	0009851b          	sext.w	a0,s3
}
    800046b2:	70a6                	ld	ra,104(sp)
    800046b4:	7406                	ld	s0,96(sp)
    800046b6:	64e6                	ld	s1,88(sp)
    800046b8:	6946                	ld	s2,80(sp)
    800046ba:	69a6                	ld	s3,72(sp)
    800046bc:	6a06                	ld	s4,64(sp)
    800046be:	7ae2                	ld	s5,56(sp)
    800046c0:	7b42                	ld	s6,48(sp)
    800046c2:	7ba2                	ld	s7,40(sp)
    800046c4:	7c02                	ld	s8,32(sp)
    800046c6:	6ce2                	ld	s9,24(sp)
    800046c8:	6d42                	ld	s10,16(sp)
    800046ca:	6da2                	ld	s11,8(sp)
    800046cc:	6165                	addi	sp,sp,112
    800046ce:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800046d0:	89d6                	mv	s3,s5
    800046d2:	bff1                	j	800046ae <readi+0xce>
    return 0;
    800046d4:	4501                	li	a0,0
}
    800046d6:	8082                	ret

00000000800046d8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800046d8:	457c                	lw	a5,76(a0)
    800046da:	10d7e863          	bltu	a5,a3,800047ea <writei+0x112>
{
    800046de:	7159                	addi	sp,sp,-112
    800046e0:	f486                	sd	ra,104(sp)
    800046e2:	f0a2                	sd	s0,96(sp)
    800046e4:	eca6                	sd	s1,88(sp)
    800046e6:	e8ca                	sd	s2,80(sp)
    800046e8:	e4ce                	sd	s3,72(sp)
    800046ea:	e0d2                	sd	s4,64(sp)
    800046ec:	fc56                	sd	s5,56(sp)
    800046ee:	f85a                	sd	s6,48(sp)
    800046f0:	f45e                	sd	s7,40(sp)
    800046f2:	f062                	sd	s8,32(sp)
    800046f4:	ec66                	sd	s9,24(sp)
    800046f6:	e86a                	sd	s10,16(sp)
    800046f8:	e46e                	sd	s11,8(sp)
    800046fa:	1880                	addi	s0,sp,112
    800046fc:	8aaa                	mv	s5,a0
    800046fe:	8bae                	mv	s7,a1
    80004700:	8a32                	mv	s4,a2
    80004702:	8936                	mv	s2,a3
    80004704:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004706:	00e687bb          	addw	a5,a3,a4
    8000470a:	0ed7e263          	bltu	a5,a3,800047ee <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000470e:	00043737          	lui	a4,0x43
    80004712:	0ef76063          	bltu	a4,a5,800047f2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004716:	0c0b0863          	beqz	s6,800047e6 <writei+0x10e>
    8000471a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000471c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004720:	5c7d                	li	s8,-1
    80004722:	a091                	j	80004766 <writei+0x8e>
    80004724:	020d1d93          	slli	s11,s10,0x20
    80004728:	020ddd93          	srli	s11,s11,0x20
    8000472c:	05848513          	addi	a0,s1,88
    80004730:	86ee                	mv	a3,s11
    80004732:	8652                	mv	a2,s4
    80004734:	85de                	mv	a1,s7
    80004736:	953a                	add	a0,a0,a4
    80004738:	ffffe097          	auipc	ra,0xffffe
    8000473c:	648080e7          	jalr	1608(ra) # 80002d80 <either_copyin>
    80004740:	07850263          	beq	a0,s8,800047a4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004744:	8526                	mv	a0,s1
    80004746:	00000097          	auipc	ra,0x0
    8000474a:	75e080e7          	jalr	1886(ra) # 80004ea4 <log_write>
    brelse(bp);
    8000474e:	8526                	mv	a0,s1
    80004750:	fffff097          	auipc	ra,0xfffff
    80004754:	4fc080e7          	jalr	1276(ra) # 80003c4c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004758:	013d09bb          	addw	s3,s10,s3
    8000475c:	012d093b          	addw	s2,s10,s2
    80004760:	9a6e                	add	s4,s4,s11
    80004762:	0569f663          	bgeu	s3,s6,800047ae <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004766:	00a9559b          	srliw	a1,s2,0xa
    8000476a:	8556                	mv	a0,s5
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	7a2080e7          	jalr	1954(ra) # 80003f0e <bmap>
    80004774:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004778:	c99d                	beqz	a1,800047ae <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000477a:	000aa503          	lw	a0,0(s5)
    8000477e:	fffff097          	auipc	ra,0xfffff
    80004782:	39e080e7          	jalr	926(ra) # 80003b1c <bread>
    80004786:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004788:	3ff97713          	andi	a4,s2,1023
    8000478c:	40ec87bb          	subw	a5,s9,a4
    80004790:	413b06bb          	subw	a3,s6,s3
    80004794:	8d3e                	mv	s10,a5
    80004796:	2781                	sext.w	a5,a5
    80004798:	0006861b          	sext.w	a2,a3
    8000479c:	f8f674e3          	bgeu	a2,a5,80004724 <writei+0x4c>
    800047a0:	8d36                	mv	s10,a3
    800047a2:	b749                	j	80004724 <writei+0x4c>
      brelse(bp);
    800047a4:	8526                	mv	a0,s1
    800047a6:	fffff097          	auipc	ra,0xfffff
    800047aa:	4a6080e7          	jalr	1190(ra) # 80003c4c <brelse>
  }

  if(off > ip->size)
    800047ae:	04caa783          	lw	a5,76(s5)
    800047b2:	0127f463          	bgeu	a5,s2,800047ba <writei+0xe2>
    ip->size = off;
    800047b6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800047ba:	8556                	mv	a0,s5
    800047bc:	00000097          	auipc	ra,0x0
    800047c0:	aa4080e7          	jalr	-1372(ra) # 80004260 <iupdate>

  return tot;
    800047c4:	0009851b          	sext.w	a0,s3
}
    800047c8:	70a6                	ld	ra,104(sp)
    800047ca:	7406                	ld	s0,96(sp)
    800047cc:	64e6                	ld	s1,88(sp)
    800047ce:	6946                	ld	s2,80(sp)
    800047d0:	69a6                	ld	s3,72(sp)
    800047d2:	6a06                	ld	s4,64(sp)
    800047d4:	7ae2                	ld	s5,56(sp)
    800047d6:	7b42                	ld	s6,48(sp)
    800047d8:	7ba2                	ld	s7,40(sp)
    800047da:	7c02                	ld	s8,32(sp)
    800047dc:	6ce2                	ld	s9,24(sp)
    800047de:	6d42                	ld	s10,16(sp)
    800047e0:	6da2                	ld	s11,8(sp)
    800047e2:	6165                	addi	sp,sp,112
    800047e4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800047e6:	89da                	mv	s3,s6
    800047e8:	bfc9                	j	800047ba <writei+0xe2>
    return -1;
    800047ea:	557d                	li	a0,-1
}
    800047ec:	8082                	ret
    return -1;
    800047ee:	557d                	li	a0,-1
    800047f0:	bfe1                	j	800047c8 <writei+0xf0>
    return -1;
    800047f2:	557d                	li	a0,-1
    800047f4:	bfd1                	j	800047c8 <writei+0xf0>

00000000800047f6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800047f6:	1141                	addi	sp,sp,-16
    800047f8:	e406                	sd	ra,8(sp)
    800047fa:	e022                	sd	s0,0(sp)
    800047fc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800047fe:	4639                	li	a2,14
    80004800:	ffffc097          	auipc	ra,0xffffc
    80004804:	7e6080e7          	jalr	2022(ra) # 80000fe6 <strncmp>
}
    80004808:	60a2                	ld	ra,8(sp)
    8000480a:	6402                	ld	s0,0(sp)
    8000480c:	0141                	addi	sp,sp,16
    8000480e:	8082                	ret

0000000080004810 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004810:	7139                	addi	sp,sp,-64
    80004812:	fc06                	sd	ra,56(sp)
    80004814:	f822                	sd	s0,48(sp)
    80004816:	f426                	sd	s1,40(sp)
    80004818:	f04a                	sd	s2,32(sp)
    8000481a:	ec4e                	sd	s3,24(sp)
    8000481c:	e852                	sd	s4,16(sp)
    8000481e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004820:	04451703          	lh	a4,68(a0)
    80004824:	4785                	li	a5,1
    80004826:	00f71a63          	bne	a4,a5,8000483a <dirlookup+0x2a>
    8000482a:	892a                	mv	s2,a0
    8000482c:	89ae                	mv	s3,a1
    8000482e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004830:	457c                	lw	a5,76(a0)
    80004832:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004834:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004836:	e79d                	bnez	a5,80004864 <dirlookup+0x54>
    80004838:	a8a5                	j	800048b0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000483a:	00004517          	auipc	a0,0x4
    8000483e:	0ee50513          	addi	a0,a0,238 # 80008928 <syscall_names+0x1d0>
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	cfa080e7          	jalr	-774(ra) # 8000053c <panic>
      panic("dirlookup read");
    8000484a:	00004517          	auipc	a0,0x4
    8000484e:	0f650513          	addi	a0,a0,246 # 80008940 <syscall_names+0x1e8>
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	cea080e7          	jalr	-790(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000485a:	24c1                	addiw	s1,s1,16
    8000485c:	04c92783          	lw	a5,76(s2)
    80004860:	04f4f763          	bgeu	s1,a5,800048ae <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004864:	4741                	li	a4,16
    80004866:	86a6                	mv	a3,s1
    80004868:	fc040613          	addi	a2,s0,-64
    8000486c:	4581                	li	a1,0
    8000486e:	854a                	mv	a0,s2
    80004870:	00000097          	auipc	ra,0x0
    80004874:	d70080e7          	jalr	-656(ra) # 800045e0 <readi>
    80004878:	47c1                	li	a5,16
    8000487a:	fcf518e3          	bne	a0,a5,8000484a <dirlookup+0x3a>
    if(de.inum == 0)
    8000487e:	fc045783          	lhu	a5,-64(s0)
    80004882:	dfe1                	beqz	a5,8000485a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004884:	fc240593          	addi	a1,s0,-62
    80004888:	854e                	mv	a0,s3
    8000488a:	00000097          	auipc	ra,0x0
    8000488e:	f6c080e7          	jalr	-148(ra) # 800047f6 <namecmp>
    80004892:	f561                	bnez	a0,8000485a <dirlookup+0x4a>
      if(poff)
    80004894:	000a0463          	beqz	s4,8000489c <dirlookup+0x8c>
        *poff = off;
    80004898:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000489c:	fc045583          	lhu	a1,-64(s0)
    800048a0:	00092503          	lw	a0,0(s2)
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	754080e7          	jalr	1876(ra) # 80003ff8 <iget>
    800048ac:	a011                	j	800048b0 <dirlookup+0xa0>
  return 0;
    800048ae:	4501                	li	a0,0
}
    800048b0:	70e2                	ld	ra,56(sp)
    800048b2:	7442                	ld	s0,48(sp)
    800048b4:	74a2                	ld	s1,40(sp)
    800048b6:	7902                	ld	s2,32(sp)
    800048b8:	69e2                	ld	s3,24(sp)
    800048ba:	6a42                	ld	s4,16(sp)
    800048bc:	6121                	addi	sp,sp,64
    800048be:	8082                	ret

00000000800048c0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800048c0:	711d                	addi	sp,sp,-96
    800048c2:	ec86                	sd	ra,88(sp)
    800048c4:	e8a2                	sd	s0,80(sp)
    800048c6:	e4a6                	sd	s1,72(sp)
    800048c8:	e0ca                	sd	s2,64(sp)
    800048ca:	fc4e                	sd	s3,56(sp)
    800048cc:	f852                	sd	s4,48(sp)
    800048ce:	f456                	sd	s5,40(sp)
    800048d0:	f05a                	sd	s6,32(sp)
    800048d2:	ec5e                	sd	s7,24(sp)
    800048d4:	e862                	sd	s8,16(sp)
    800048d6:	e466                	sd	s9,8(sp)
    800048d8:	1080                	addi	s0,sp,96
    800048da:	84aa                	mv	s1,a0
    800048dc:	8b2e                	mv	s6,a1
    800048de:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800048e0:	00054703          	lbu	a4,0(a0)
    800048e4:	02f00793          	li	a5,47
    800048e8:	02f70263          	beq	a4,a5,8000490c <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800048ec:	ffffd097          	auipc	ra,0xffffd
    800048f0:	3a4080e7          	jalr	932(ra) # 80001c90 <myproc>
    800048f4:	15053503          	ld	a0,336(a0)
    800048f8:	00000097          	auipc	ra,0x0
    800048fc:	9f6080e7          	jalr	-1546(ra) # 800042ee <idup>
    80004900:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004902:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004906:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004908:	4b85                	li	s7,1
    8000490a:	a875                	j	800049c6 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    8000490c:	4585                	li	a1,1
    8000490e:	4505                	li	a0,1
    80004910:	fffff097          	auipc	ra,0xfffff
    80004914:	6e8080e7          	jalr	1768(ra) # 80003ff8 <iget>
    80004918:	8a2a                	mv	s4,a0
    8000491a:	b7e5                	j	80004902 <namex+0x42>
      iunlockput(ip);
    8000491c:	8552                	mv	a0,s4
    8000491e:	00000097          	auipc	ra,0x0
    80004922:	c70080e7          	jalr	-912(ra) # 8000458e <iunlockput>
      return 0;
    80004926:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004928:	8552                	mv	a0,s4
    8000492a:	60e6                	ld	ra,88(sp)
    8000492c:	6446                	ld	s0,80(sp)
    8000492e:	64a6                	ld	s1,72(sp)
    80004930:	6906                	ld	s2,64(sp)
    80004932:	79e2                	ld	s3,56(sp)
    80004934:	7a42                	ld	s4,48(sp)
    80004936:	7aa2                	ld	s5,40(sp)
    80004938:	7b02                	ld	s6,32(sp)
    8000493a:	6be2                	ld	s7,24(sp)
    8000493c:	6c42                	ld	s8,16(sp)
    8000493e:	6ca2                	ld	s9,8(sp)
    80004940:	6125                	addi	sp,sp,96
    80004942:	8082                	ret
      iunlock(ip);
    80004944:	8552                	mv	a0,s4
    80004946:	00000097          	auipc	ra,0x0
    8000494a:	aa8080e7          	jalr	-1368(ra) # 800043ee <iunlock>
      return ip;
    8000494e:	bfe9                	j	80004928 <namex+0x68>
      iunlockput(ip);
    80004950:	8552                	mv	a0,s4
    80004952:	00000097          	auipc	ra,0x0
    80004956:	c3c080e7          	jalr	-964(ra) # 8000458e <iunlockput>
      return 0;
    8000495a:	8a4e                	mv	s4,s3
    8000495c:	b7f1                	j	80004928 <namex+0x68>
  len = path - s;
    8000495e:	40998633          	sub	a2,s3,s1
    80004962:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004966:	099c5863          	bge	s8,s9,800049f6 <namex+0x136>
    memmove(name, s, DIRSIZ);
    8000496a:	4639                	li	a2,14
    8000496c:	85a6                	mv	a1,s1
    8000496e:	8556                	mv	a0,s5
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	602080e7          	jalr	1538(ra) # 80000f72 <memmove>
    80004978:	84ce                	mv	s1,s3
  while(*path == '/')
    8000497a:	0004c783          	lbu	a5,0(s1)
    8000497e:	01279763          	bne	a5,s2,8000498c <namex+0xcc>
    path++;
    80004982:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004984:	0004c783          	lbu	a5,0(s1)
    80004988:	ff278de3          	beq	a5,s2,80004982 <namex+0xc2>
    ilock(ip);
    8000498c:	8552                	mv	a0,s4
    8000498e:	00000097          	auipc	ra,0x0
    80004992:	99e080e7          	jalr	-1634(ra) # 8000432c <ilock>
    if(ip->type != T_DIR){
    80004996:	044a1783          	lh	a5,68(s4)
    8000499a:	f97791e3          	bne	a5,s7,8000491c <namex+0x5c>
    if(nameiparent && *path == '\0'){
    8000499e:	000b0563          	beqz	s6,800049a8 <namex+0xe8>
    800049a2:	0004c783          	lbu	a5,0(s1)
    800049a6:	dfd9                	beqz	a5,80004944 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    800049a8:	4601                	li	a2,0
    800049aa:	85d6                	mv	a1,s5
    800049ac:	8552                	mv	a0,s4
    800049ae:	00000097          	auipc	ra,0x0
    800049b2:	e62080e7          	jalr	-414(ra) # 80004810 <dirlookup>
    800049b6:	89aa                	mv	s3,a0
    800049b8:	dd41                	beqz	a0,80004950 <namex+0x90>
    iunlockput(ip);
    800049ba:	8552                	mv	a0,s4
    800049bc:	00000097          	auipc	ra,0x0
    800049c0:	bd2080e7          	jalr	-1070(ra) # 8000458e <iunlockput>
    ip = next;
    800049c4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800049c6:	0004c783          	lbu	a5,0(s1)
    800049ca:	01279763          	bne	a5,s2,800049d8 <namex+0x118>
    path++;
    800049ce:	0485                	addi	s1,s1,1
  while(*path == '/')
    800049d0:	0004c783          	lbu	a5,0(s1)
    800049d4:	ff278de3          	beq	a5,s2,800049ce <namex+0x10e>
  if(*path == 0)
    800049d8:	cb9d                	beqz	a5,80004a0e <namex+0x14e>
  while(*path != '/' && *path != 0)
    800049da:	0004c783          	lbu	a5,0(s1)
    800049de:	89a6                	mv	s3,s1
  len = path - s;
    800049e0:	4c81                	li	s9,0
    800049e2:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800049e4:	01278963          	beq	a5,s2,800049f6 <namex+0x136>
    800049e8:	dbbd                	beqz	a5,8000495e <namex+0x9e>
    path++;
    800049ea:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800049ec:	0009c783          	lbu	a5,0(s3)
    800049f0:	ff279ce3          	bne	a5,s2,800049e8 <namex+0x128>
    800049f4:	b7ad                	j	8000495e <namex+0x9e>
    memmove(name, s, len);
    800049f6:	2601                	sext.w	a2,a2
    800049f8:	85a6                	mv	a1,s1
    800049fa:	8556                	mv	a0,s5
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	576080e7          	jalr	1398(ra) # 80000f72 <memmove>
    name[len] = 0;
    80004a04:	9cd6                	add	s9,s9,s5
    80004a06:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004a0a:	84ce                	mv	s1,s3
    80004a0c:	b7bd                	j	8000497a <namex+0xba>
  if(nameiparent){
    80004a0e:	f00b0de3          	beqz	s6,80004928 <namex+0x68>
    iput(ip);
    80004a12:	8552                	mv	a0,s4
    80004a14:	00000097          	auipc	ra,0x0
    80004a18:	ad2080e7          	jalr	-1326(ra) # 800044e6 <iput>
    return 0;
    80004a1c:	4a01                	li	s4,0
    80004a1e:	b729                	j	80004928 <namex+0x68>

0000000080004a20 <dirlink>:
{
    80004a20:	7139                	addi	sp,sp,-64
    80004a22:	fc06                	sd	ra,56(sp)
    80004a24:	f822                	sd	s0,48(sp)
    80004a26:	f426                	sd	s1,40(sp)
    80004a28:	f04a                	sd	s2,32(sp)
    80004a2a:	ec4e                	sd	s3,24(sp)
    80004a2c:	e852                	sd	s4,16(sp)
    80004a2e:	0080                	addi	s0,sp,64
    80004a30:	892a                	mv	s2,a0
    80004a32:	8a2e                	mv	s4,a1
    80004a34:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a36:	4601                	li	a2,0
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	dd8080e7          	jalr	-552(ra) # 80004810 <dirlookup>
    80004a40:	e93d                	bnez	a0,80004ab6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a42:	04c92483          	lw	s1,76(s2)
    80004a46:	c49d                	beqz	s1,80004a74 <dirlink+0x54>
    80004a48:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a4a:	4741                	li	a4,16
    80004a4c:	86a6                	mv	a3,s1
    80004a4e:	fc040613          	addi	a2,s0,-64
    80004a52:	4581                	li	a1,0
    80004a54:	854a                	mv	a0,s2
    80004a56:	00000097          	auipc	ra,0x0
    80004a5a:	b8a080e7          	jalr	-1142(ra) # 800045e0 <readi>
    80004a5e:	47c1                	li	a5,16
    80004a60:	06f51163          	bne	a0,a5,80004ac2 <dirlink+0xa2>
    if(de.inum == 0)
    80004a64:	fc045783          	lhu	a5,-64(s0)
    80004a68:	c791                	beqz	a5,80004a74 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a6a:	24c1                	addiw	s1,s1,16
    80004a6c:	04c92783          	lw	a5,76(s2)
    80004a70:	fcf4ede3          	bltu	s1,a5,80004a4a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004a74:	4639                	li	a2,14
    80004a76:	85d2                	mv	a1,s4
    80004a78:	fc240513          	addi	a0,s0,-62
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	5a6080e7          	jalr	1446(ra) # 80001022 <strncpy>
  de.inum = inum;
    80004a84:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a88:	4741                	li	a4,16
    80004a8a:	86a6                	mv	a3,s1
    80004a8c:	fc040613          	addi	a2,s0,-64
    80004a90:	4581                	li	a1,0
    80004a92:	854a                	mv	a0,s2
    80004a94:	00000097          	auipc	ra,0x0
    80004a98:	c44080e7          	jalr	-956(ra) # 800046d8 <writei>
    80004a9c:	1541                	addi	a0,a0,-16
    80004a9e:	00a03533          	snez	a0,a0
    80004aa2:	40a00533          	neg	a0,a0
}
    80004aa6:	70e2                	ld	ra,56(sp)
    80004aa8:	7442                	ld	s0,48(sp)
    80004aaa:	74a2                	ld	s1,40(sp)
    80004aac:	7902                	ld	s2,32(sp)
    80004aae:	69e2                	ld	s3,24(sp)
    80004ab0:	6a42                	ld	s4,16(sp)
    80004ab2:	6121                	addi	sp,sp,64
    80004ab4:	8082                	ret
    iput(ip);
    80004ab6:	00000097          	auipc	ra,0x0
    80004aba:	a30080e7          	jalr	-1488(ra) # 800044e6 <iput>
    return -1;
    80004abe:	557d                	li	a0,-1
    80004ac0:	b7dd                	j	80004aa6 <dirlink+0x86>
      panic("dirlink read");
    80004ac2:	00004517          	auipc	a0,0x4
    80004ac6:	e8e50513          	addi	a0,a0,-370 # 80008950 <syscall_names+0x1f8>
    80004aca:	ffffc097          	auipc	ra,0xffffc
    80004ace:	a72080e7          	jalr	-1422(ra) # 8000053c <panic>

0000000080004ad2 <namei>:

struct inode*
namei(char *path)
{
    80004ad2:	1101                	addi	sp,sp,-32
    80004ad4:	ec06                	sd	ra,24(sp)
    80004ad6:	e822                	sd	s0,16(sp)
    80004ad8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004ada:	fe040613          	addi	a2,s0,-32
    80004ade:	4581                	li	a1,0
    80004ae0:	00000097          	auipc	ra,0x0
    80004ae4:	de0080e7          	jalr	-544(ra) # 800048c0 <namex>
}
    80004ae8:	60e2                	ld	ra,24(sp)
    80004aea:	6442                	ld	s0,16(sp)
    80004aec:	6105                	addi	sp,sp,32
    80004aee:	8082                	ret

0000000080004af0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004af0:	1141                	addi	sp,sp,-16
    80004af2:	e406                	sd	ra,8(sp)
    80004af4:	e022                	sd	s0,0(sp)
    80004af6:	0800                	addi	s0,sp,16
    80004af8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004afa:	4585                	li	a1,1
    80004afc:	00000097          	auipc	ra,0x0
    80004b00:	dc4080e7          	jalr	-572(ra) # 800048c0 <namex>
}
    80004b04:	60a2                	ld	ra,8(sp)
    80004b06:	6402                	ld	s0,0(sp)
    80004b08:	0141                	addi	sp,sp,16
    80004b0a:	8082                	ret

0000000080004b0c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004b0c:	1101                	addi	sp,sp,-32
    80004b0e:	ec06                	sd	ra,24(sp)
    80004b10:	e822                	sd	s0,16(sp)
    80004b12:	e426                	sd	s1,8(sp)
    80004b14:	e04a                	sd	s2,0(sp)
    80004b16:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004b18:	00243917          	auipc	s2,0x243
    80004b1c:	ad090913          	addi	s2,s2,-1328 # 802475e8 <log>
    80004b20:	01892583          	lw	a1,24(s2)
    80004b24:	02892503          	lw	a0,40(s2)
    80004b28:	fffff097          	auipc	ra,0xfffff
    80004b2c:	ff4080e7          	jalr	-12(ra) # 80003b1c <bread>
    80004b30:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004b32:	02c92603          	lw	a2,44(s2)
    80004b36:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004b38:	00c05f63          	blez	a2,80004b56 <write_head+0x4a>
    80004b3c:	00243717          	auipc	a4,0x243
    80004b40:	adc70713          	addi	a4,a4,-1316 # 80247618 <log+0x30>
    80004b44:	87aa                	mv	a5,a0
    80004b46:	060a                	slli	a2,a2,0x2
    80004b48:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004b4a:	4314                	lw	a3,0(a4)
    80004b4c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004b4e:	0711                	addi	a4,a4,4
    80004b50:	0791                	addi	a5,a5,4
    80004b52:	fec79ce3          	bne	a5,a2,80004b4a <write_head+0x3e>
  }
  bwrite(buf);
    80004b56:	8526                	mv	a0,s1
    80004b58:	fffff097          	auipc	ra,0xfffff
    80004b5c:	0b6080e7          	jalr	182(ra) # 80003c0e <bwrite>
  brelse(buf);
    80004b60:	8526                	mv	a0,s1
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	0ea080e7          	jalr	234(ra) # 80003c4c <brelse>
}
    80004b6a:	60e2                	ld	ra,24(sp)
    80004b6c:	6442                	ld	s0,16(sp)
    80004b6e:	64a2                	ld	s1,8(sp)
    80004b70:	6902                	ld	s2,0(sp)
    80004b72:	6105                	addi	sp,sp,32
    80004b74:	8082                	ret

0000000080004b76 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b76:	00243797          	auipc	a5,0x243
    80004b7a:	a9e7a783          	lw	a5,-1378(a5) # 80247614 <log+0x2c>
    80004b7e:	0af05d63          	blez	a5,80004c38 <install_trans+0xc2>
{
    80004b82:	7139                	addi	sp,sp,-64
    80004b84:	fc06                	sd	ra,56(sp)
    80004b86:	f822                	sd	s0,48(sp)
    80004b88:	f426                	sd	s1,40(sp)
    80004b8a:	f04a                	sd	s2,32(sp)
    80004b8c:	ec4e                	sd	s3,24(sp)
    80004b8e:	e852                	sd	s4,16(sp)
    80004b90:	e456                	sd	s5,8(sp)
    80004b92:	e05a                	sd	s6,0(sp)
    80004b94:	0080                	addi	s0,sp,64
    80004b96:	8b2a                	mv	s6,a0
    80004b98:	00243a97          	auipc	s5,0x243
    80004b9c:	a80a8a93          	addi	s5,s5,-1408 # 80247618 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ba0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004ba2:	00243997          	auipc	s3,0x243
    80004ba6:	a4698993          	addi	s3,s3,-1466 # 802475e8 <log>
    80004baa:	a00d                	j	80004bcc <install_trans+0x56>
    brelse(lbuf);
    80004bac:	854a                	mv	a0,s2
    80004bae:	fffff097          	auipc	ra,0xfffff
    80004bb2:	09e080e7          	jalr	158(ra) # 80003c4c <brelse>
    brelse(dbuf);
    80004bb6:	8526                	mv	a0,s1
    80004bb8:	fffff097          	auipc	ra,0xfffff
    80004bbc:	094080e7          	jalr	148(ra) # 80003c4c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004bc0:	2a05                	addiw	s4,s4,1
    80004bc2:	0a91                	addi	s5,s5,4
    80004bc4:	02c9a783          	lw	a5,44(s3)
    80004bc8:	04fa5e63          	bge	s4,a5,80004c24 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004bcc:	0189a583          	lw	a1,24(s3)
    80004bd0:	014585bb          	addw	a1,a1,s4
    80004bd4:	2585                	addiw	a1,a1,1
    80004bd6:	0289a503          	lw	a0,40(s3)
    80004bda:	fffff097          	auipc	ra,0xfffff
    80004bde:	f42080e7          	jalr	-190(ra) # 80003b1c <bread>
    80004be2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004be4:	000aa583          	lw	a1,0(s5)
    80004be8:	0289a503          	lw	a0,40(s3)
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	f30080e7          	jalr	-208(ra) # 80003b1c <bread>
    80004bf4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004bf6:	40000613          	li	a2,1024
    80004bfa:	05890593          	addi	a1,s2,88
    80004bfe:	05850513          	addi	a0,a0,88
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	370080e7          	jalr	880(ra) # 80000f72 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004c0a:	8526                	mv	a0,s1
    80004c0c:	fffff097          	auipc	ra,0xfffff
    80004c10:	002080e7          	jalr	2(ra) # 80003c0e <bwrite>
    if(recovering == 0)
    80004c14:	f80b1ce3          	bnez	s6,80004bac <install_trans+0x36>
      bunpin(dbuf);
    80004c18:	8526                	mv	a0,s1
    80004c1a:	fffff097          	auipc	ra,0xfffff
    80004c1e:	10a080e7          	jalr	266(ra) # 80003d24 <bunpin>
    80004c22:	b769                	j	80004bac <install_trans+0x36>
}
    80004c24:	70e2                	ld	ra,56(sp)
    80004c26:	7442                	ld	s0,48(sp)
    80004c28:	74a2                	ld	s1,40(sp)
    80004c2a:	7902                	ld	s2,32(sp)
    80004c2c:	69e2                	ld	s3,24(sp)
    80004c2e:	6a42                	ld	s4,16(sp)
    80004c30:	6aa2                	ld	s5,8(sp)
    80004c32:	6b02                	ld	s6,0(sp)
    80004c34:	6121                	addi	sp,sp,64
    80004c36:	8082                	ret
    80004c38:	8082                	ret

0000000080004c3a <initlog>:
{
    80004c3a:	7179                	addi	sp,sp,-48
    80004c3c:	f406                	sd	ra,40(sp)
    80004c3e:	f022                	sd	s0,32(sp)
    80004c40:	ec26                	sd	s1,24(sp)
    80004c42:	e84a                	sd	s2,16(sp)
    80004c44:	e44e                	sd	s3,8(sp)
    80004c46:	1800                	addi	s0,sp,48
    80004c48:	892a                	mv	s2,a0
    80004c4a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004c4c:	00243497          	auipc	s1,0x243
    80004c50:	99c48493          	addi	s1,s1,-1636 # 802475e8 <log>
    80004c54:	00004597          	auipc	a1,0x4
    80004c58:	d0c58593          	addi	a1,a1,-756 # 80008960 <syscall_names+0x208>
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	12c080e7          	jalr	300(ra) # 80000d8a <initlock>
  log.start = sb->logstart;
    80004c66:	0149a583          	lw	a1,20(s3)
    80004c6a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004c6c:	0109a783          	lw	a5,16(s3)
    80004c70:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004c72:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004c76:	854a                	mv	a0,s2
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	ea4080e7          	jalr	-348(ra) # 80003b1c <bread>
  log.lh.n = lh->n;
    80004c80:	4d30                	lw	a2,88(a0)
    80004c82:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004c84:	00c05f63          	blez	a2,80004ca2 <initlog+0x68>
    80004c88:	87aa                	mv	a5,a0
    80004c8a:	00243717          	auipc	a4,0x243
    80004c8e:	98e70713          	addi	a4,a4,-1650 # 80247618 <log+0x30>
    80004c92:	060a                	slli	a2,a2,0x2
    80004c94:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004c96:	4ff4                	lw	a3,92(a5)
    80004c98:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004c9a:	0791                	addi	a5,a5,4
    80004c9c:	0711                	addi	a4,a4,4
    80004c9e:	fec79ce3          	bne	a5,a2,80004c96 <initlog+0x5c>
  brelse(buf);
    80004ca2:	fffff097          	auipc	ra,0xfffff
    80004ca6:	faa080e7          	jalr	-86(ra) # 80003c4c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004caa:	4505                	li	a0,1
    80004cac:	00000097          	auipc	ra,0x0
    80004cb0:	eca080e7          	jalr	-310(ra) # 80004b76 <install_trans>
  log.lh.n = 0;
    80004cb4:	00243797          	auipc	a5,0x243
    80004cb8:	9607a023          	sw	zero,-1696(a5) # 80247614 <log+0x2c>
  write_head(); // clear the log
    80004cbc:	00000097          	auipc	ra,0x0
    80004cc0:	e50080e7          	jalr	-432(ra) # 80004b0c <write_head>
}
    80004cc4:	70a2                	ld	ra,40(sp)
    80004cc6:	7402                	ld	s0,32(sp)
    80004cc8:	64e2                	ld	s1,24(sp)
    80004cca:	6942                	ld	s2,16(sp)
    80004ccc:	69a2                	ld	s3,8(sp)
    80004cce:	6145                	addi	sp,sp,48
    80004cd0:	8082                	ret

0000000080004cd2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004cd2:	1101                	addi	sp,sp,-32
    80004cd4:	ec06                	sd	ra,24(sp)
    80004cd6:	e822                	sd	s0,16(sp)
    80004cd8:	e426                	sd	s1,8(sp)
    80004cda:	e04a                	sd	s2,0(sp)
    80004cdc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004cde:	00243517          	auipc	a0,0x243
    80004ce2:	90a50513          	addi	a0,a0,-1782 # 802475e8 <log>
    80004ce6:	ffffc097          	auipc	ra,0xffffc
    80004cea:	134080e7          	jalr	308(ra) # 80000e1a <acquire>
  while(1){
    if(log.committing){
    80004cee:	00243497          	auipc	s1,0x243
    80004cf2:	8fa48493          	addi	s1,s1,-1798 # 802475e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004cf6:	4979                	li	s2,30
    80004cf8:	a039                	j	80004d06 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004cfa:	85a6                	mv	a1,s1
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	ffffe097          	auipc	ra,0xffffe
    80004d02:	acc080e7          	jalr	-1332(ra) # 800027ca <sleep>
    if(log.committing){
    80004d06:	50dc                	lw	a5,36(s1)
    80004d08:	fbed                	bnez	a5,80004cfa <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004d0a:	5098                	lw	a4,32(s1)
    80004d0c:	2705                	addiw	a4,a4,1
    80004d0e:	0027179b          	slliw	a5,a4,0x2
    80004d12:	9fb9                	addw	a5,a5,a4
    80004d14:	0017979b          	slliw	a5,a5,0x1
    80004d18:	54d4                	lw	a3,44(s1)
    80004d1a:	9fb5                	addw	a5,a5,a3
    80004d1c:	00f95963          	bge	s2,a5,80004d2e <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004d20:	85a6                	mv	a1,s1
    80004d22:	8526                	mv	a0,s1
    80004d24:	ffffe097          	auipc	ra,0xffffe
    80004d28:	aa6080e7          	jalr	-1370(ra) # 800027ca <sleep>
    80004d2c:	bfe9                	j	80004d06 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004d2e:	00243517          	auipc	a0,0x243
    80004d32:	8ba50513          	addi	a0,a0,-1862 # 802475e8 <log>
    80004d36:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	196080e7          	jalr	406(ra) # 80000ece <release>
      break;
    }
  }
}
    80004d40:	60e2                	ld	ra,24(sp)
    80004d42:	6442                	ld	s0,16(sp)
    80004d44:	64a2                	ld	s1,8(sp)
    80004d46:	6902                	ld	s2,0(sp)
    80004d48:	6105                	addi	sp,sp,32
    80004d4a:	8082                	ret

0000000080004d4c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004d4c:	7139                	addi	sp,sp,-64
    80004d4e:	fc06                	sd	ra,56(sp)
    80004d50:	f822                	sd	s0,48(sp)
    80004d52:	f426                	sd	s1,40(sp)
    80004d54:	f04a                	sd	s2,32(sp)
    80004d56:	ec4e                	sd	s3,24(sp)
    80004d58:	e852                	sd	s4,16(sp)
    80004d5a:	e456                	sd	s5,8(sp)
    80004d5c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004d5e:	00243497          	auipc	s1,0x243
    80004d62:	88a48493          	addi	s1,s1,-1910 # 802475e8 <log>
    80004d66:	8526                	mv	a0,s1
    80004d68:	ffffc097          	auipc	ra,0xffffc
    80004d6c:	0b2080e7          	jalr	178(ra) # 80000e1a <acquire>
  log.outstanding -= 1;
    80004d70:	509c                	lw	a5,32(s1)
    80004d72:	37fd                	addiw	a5,a5,-1
    80004d74:	0007891b          	sext.w	s2,a5
    80004d78:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004d7a:	50dc                	lw	a5,36(s1)
    80004d7c:	e7b9                	bnez	a5,80004dca <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004d7e:	04091e63          	bnez	s2,80004dda <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004d82:	00243497          	auipc	s1,0x243
    80004d86:	86648493          	addi	s1,s1,-1946 # 802475e8 <log>
    80004d8a:	4785                	li	a5,1
    80004d8c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004d8e:	8526                	mv	a0,s1
    80004d90:	ffffc097          	auipc	ra,0xffffc
    80004d94:	13e080e7          	jalr	318(ra) # 80000ece <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004d98:	54dc                	lw	a5,44(s1)
    80004d9a:	06f04763          	bgtz	a5,80004e08 <end_op+0xbc>
    acquire(&log.lock);
    80004d9e:	00243497          	auipc	s1,0x243
    80004da2:	84a48493          	addi	s1,s1,-1974 # 802475e8 <log>
    80004da6:	8526                	mv	a0,s1
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	072080e7          	jalr	114(ra) # 80000e1a <acquire>
    log.committing = 0;
    80004db0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004db4:	8526                	mv	a0,s1
    80004db6:	ffffe097          	auipc	ra,0xffffe
    80004dba:	bc4080e7          	jalr	-1084(ra) # 8000297a <wakeup>
    release(&log.lock);
    80004dbe:	8526                	mv	a0,s1
    80004dc0:	ffffc097          	auipc	ra,0xffffc
    80004dc4:	10e080e7          	jalr	270(ra) # 80000ece <release>
}
    80004dc8:	a03d                	j	80004df6 <end_op+0xaa>
    panic("log.committing");
    80004dca:	00004517          	auipc	a0,0x4
    80004dce:	b9e50513          	addi	a0,a0,-1122 # 80008968 <syscall_names+0x210>
    80004dd2:	ffffb097          	auipc	ra,0xffffb
    80004dd6:	76a080e7          	jalr	1898(ra) # 8000053c <panic>
    wakeup(&log);
    80004dda:	00243497          	auipc	s1,0x243
    80004dde:	80e48493          	addi	s1,s1,-2034 # 802475e8 <log>
    80004de2:	8526                	mv	a0,s1
    80004de4:	ffffe097          	auipc	ra,0xffffe
    80004de8:	b96080e7          	jalr	-1130(ra) # 8000297a <wakeup>
  release(&log.lock);
    80004dec:	8526                	mv	a0,s1
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	0e0080e7          	jalr	224(ra) # 80000ece <release>
}
    80004df6:	70e2                	ld	ra,56(sp)
    80004df8:	7442                	ld	s0,48(sp)
    80004dfa:	74a2                	ld	s1,40(sp)
    80004dfc:	7902                	ld	s2,32(sp)
    80004dfe:	69e2                	ld	s3,24(sp)
    80004e00:	6a42                	ld	s4,16(sp)
    80004e02:	6aa2                	ld	s5,8(sp)
    80004e04:	6121                	addi	sp,sp,64
    80004e06:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e08:	00243a97          	auipc	s5,0x243
    80004e0c:	810a8a93          	addi	s5,s5,-2032 # 80247618 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004e10:	00242a17          	auipc	s4,0x242
    80004e14:	7d8a0a13          	addi	s4,s4,2008 # 802475e8 <log>
    80004e18:	018a2583          	lw	a1,24(s4)
    80004e1c:	012585bb          	addw	a1,a1,s2
    80004e20:	2585                	addiw	a1,a1,1
    80004e22:	028a2503          	lw	a0,40(s4)
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	cf6080e7          	jalr	-778(ra) # 80003b1c <bread>
    80004e2e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004e30:	000aa583          	lw	a1,0(s5)
    80004e34:	028a2503          	lw	a0,40(s4)
    80004e38:	fffff097          	auipc	ra,0xfffff
    80004e3c:	ce4080e7          	jalr	-796(ra) # 80003b1c <bread>
    80004e40:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004e42:	40000613          	li	a2,1024
    80004e46:	05850593          	addi	a1,a0,88
    80004e4a:	05848513          	addi	a0,s1,88
    80004e4e:	ffffc097          	auipc	ra,0xffffc
    80004e52:	124080e7          	jalr	292(ra) # 80000f72 <memmove>
    bwrite(to);  // write the log
    80004e56:	8526                	mv	a0,s1
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	db6080e7          	jalr	-586(ra) # 80003c0e <bwrite>
    brelse(from);
    80004e60:	854e                	mv	a0,s3
    80004e62:	fffff097          	auipc	ra,0xfffff
    80004e66:	dea080e7          	jalr	-534(ra) # 80003c4c <brelse>
    brelse(to);
    80004e6a:	8526                	mv	a0,s1
    80004e6c:	fffff097          	auipc	ra,0xfffff
    80004e70:	de0080e7          	jalr	-544(ra) # 80003c4c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e74:	2905                	addiw	s2,s2,1
    80004e76:	0a91                	addi	s5,s5,4
    80004e78:	02ca2783          	lw	a5,44(s4)
    80004e7c:	f8f94ee3          	blt	s2,a5,80004e18 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004e80:	00000097          	auipc	ra,0x0
    80004e84:	c8c080e7          	jalr	-884(ra) # 80004b0c <write_head>
    install_trans(0); // Now install writes to home locations
    80004e88:	4501                	li	a0,0
    80004e8a:	00000097          	auipc	ra,0x0
    80004e8e:	cec080e7          	jalr	-788(ra) # 80004b76 <install_trans>
    log.lh.n = 0;
    80004e92:	00242797          	auipc	a5,0x242
    80004e96:	7807a123          	sw	zero,1922(a5) # 80247614 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004e9a:	00000097          	auipc	ra,0x0
    80004e9e:	c72080e7          	jalr	-910(ra) # 80004b0c <write_head>
    80004ea2:	bdf5                	j	80004d9e <end_op+0x52>

0000000080004ea4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ea4:	1101                	addi	sp,sp,-32
    80004ea6:	ec06                	sd	ra,24(sp)
    80004ea8:	e822                	sd	s0,16(sp)
    80004eaa:	e426                	sd	s1,8(sp)
    80004eac:	e04a                	sd	s2,0(sp)
    80004eae:	1000                	addi	s0,sp,32
    80004eb0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004eb2:	00242917          	auipc	s2,0x242
    80004eb6:	73690913          	addi	s2,s2,1846 # 802475e8 <log>
    80004eba:	854a                	mv	a0,s2
    80004ebc:	ffffc097          	auipc	ra,0xffffc
    80004ec0:	f5e080e7          	jalr	-162(ra) # 80000e1a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004ec4:	02c92603          	lw	a2,44(s2)
    80004ec8:	47f5                	li	a5,29
    80004eca:	06c7c563          	blt	a5,a2,80004f34 <log_write+0x90>
    80004ece:	00242797          	auipc	a5,0x242
    80004ed2:	7367a783          	lw	a5,1846(a5) # 80247604 <log+0x1c>
    80004ed6:	37fd                	addiw	a5,a5,-1
    80004ed8:	04f65e63          	bge	a2,a5,80004f34 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004edc:	00242797          	auipc	a5,0x242
    80004ee0:	72c7a783          	lw	a5,1836(a5) # 80247608 <log+0x20>
    80004ee4:	06f05063          	blez	a5,80004f44 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004ee8:	4781                	li	a5,0
    80004eea:	06c05563          	blez	a2,80004f54 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004eee:	44cc                	lw	a1,12(s1)
    80004ef0:	00242717          	auipc	a4,0x242
    80004ef4:	72870713          	addi	a4,a4,1832 # 80247618 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004ef8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004efa:	4314                	lw	a3,0(a4)
    80004efc:	04b68c63          	beq	a3,a1,80004f54 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004f00:	2785                	addiw	a5,a5,1
    80004f02:	0711                	addi	a4,a4,4
    80004f04:	fef61be3          	bne	a2,a5,80004efa <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004f08:	0621                	addi	a2,a2,8
    80004f0a:	060a                	slli	a2,a2,0x2
    80004f0c:	00242797          	auipc	a5,0x242
    80004f10:	6dc78793          	addi	a5,a5,1756 # 802475e8 <log>
    80004f14:	97b2                	add	a5,a5,a2
    80004f16:	44d8                	lw	a4,12(s1)
    80004f18:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004f1a:	8526                	mv	a0,s1
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	dcc080e7          	jalr	-564(ra) # 80003ce8 <bpin>
    log.lh.n++;
    80004f24:	00242717          	auipc	a4,0x242
    80004f28:	6c470713          	addi	a4,a4,1732 # 802475e8 <log>
    80004f2c:	575c                	lw	a5,44(a4)
    80004f2e:	2785                	addiw	a5,a5,1
    80004f30:	d75c                	sw	a5,44(a4)
    80004f32:	a82d                	j	80004f6c <log_write+0xc8>
    panic("too big a transaction");
    80004f34:	00004517          	auipc	a0,0x4
    80004f38:	a4450513          	addi	a0,a0,-1468 # 80008978 <syscall_names+0x220>
    80004f3c:	ffffb097          	auipc	ra,0xffffb
    80004f40:	600080e7          	jalr	1536(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004f44:	00004517          	auipc	a0,0x4
    80004f48:	a4c50513          	addi	a0,a0,-1460 # 80008990 <syscall_names+0x238>
    80004f4c:	ffffb097          	auipc	ra,0xffffb
    80004f50:	5f0080e7          	jalr	1520(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004f54:	00878693          	addi	a3,a5,8
    80004f58:	068a                	slli	a3,a3,0x2
    80004f5a:	00242717          	auipc	a4,0x242
    80004f5e:	68e70713          	addi	a4,a4,1678 # 802475e8 <log>
    80004f62:	9736                	add	a4,a4,a3
    80004f64:	44d4                	lw	a3,12(s1)
    80004f66:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004f68:	faf609e3          	beq	a2,a5,80004f1a <log_write+0x76>
  }
  release(&log.lock);
    80004f6c:	00242517          	auipc	a0,0x242
    80004f70:	67c50513          	addi	a0,a0,1660 # 802475e8 <log>
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	f5a080e7          	jalr	-166(ra) # 80000ece <release>
}
    80004f7c:	60e2                	ld	ra,24(sp)
    80004f7e:	6442                	ld	s0,16(sp)
    80004f80:	64a2                	ld	s1,8(sp)
    80004f82:	6902                	ld	s2,0(sp)
    80004f84:	6105                	addi	sp,sp,32
    80004f86:	8082                	ret

0000000080004f88 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004f88:	1101                	addi	sp,sp,-32
    80004f8a:	ec06                	sd	ra,24(sp)
    80004f8c:	e822                	sd	s0,16(sp)
    80004f8e:	e426                	sd	s1,8(sp)
    80004f90:	e04a                	sd	s2,0(sp)
    80004f92:	1000                	addi	s0,sp,32
    80004f94:	84aa                	mv	s1,a0
    80004f96:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004f98:	00004597          	auipc	a1,0x4
    80004f9c:	a1858593          	addi	a1,a1,-1512 # 800089b0 <syscall_names+0x258>
    80004fa0:	0521                	addi	a0,a0,8
    80004fa2:	ffffc097          	auipc	ra,0xffffc
    80004fa6:	de8080e7          	jalr	-536(ra) # 80000d8a <initlock>
  lk->name = name;
    80004faa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004fae:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004fb2:	0204a423          	sw	zero,40(s1)
}
    80004fb6:	60e2                	ld	ra,24(sp)
    80004fb8:	6442                	ld	s0,16(sp)
    80004fba:	64a2                	ld	s1,8(sp)
    80004fbc:	6902                	ld	s2,0(sp)
    80004fbe:	6105                	addi	sp,sp,32
    80004fc0:	8082                	ret

0000000080004fc2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004fc2:	1101                	addi	sp,sp,-32
    80004fc4:	ec06                	sd	ra,24(sp)
    80004fc6:	e822                	sd	s0,16(sp)
    80004fc8:	e426                	sd	s1,8(sp)
    80004fca:	e04a                	sd	s2,0(sp)
    80004fcc:	1000                	addi	s0,sp,32
    80004fce:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004fd0:	00850913          	addi	s2,a0,8
    80004fd4:	854a                	mv	a0,s2
    80004fd6:	ffffc097          	auipc	ra,0xffffc
    80004fda:	e44080e7          	jalr	-444(ra) # 80000e1a <acquire>
  while (lk->locked) {
    80004fde:	409c                	lw	a5,0(s1)
    80004fe0:	cb89                	beqz	a5,80004ff2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004fe2:	85ca                	mv	a1,s2
    80004fe4:	8526                	mv	a0,s1
    80004fe6:	ffffd097          	auipc	ra,0xffffd
    80004fea:	7e4080e7          	jalr	2020(ra) # 800027ca <sleep>
  while (lk->locked) {
    80004fee:	409c                	lw	a5,0(s1)
    80004ff0:	fbed                	bnez	a5,80004fe2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004ff2:	4785                	li	a5,1
    80004ff4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ff6:	ffffd097          	auipc	ra,0xffffd
    80004ffa:	c9a080e7          	jalr	-870(ra) # 80001c90 <myproc>
    80004ffe:	591c                	lw	a5,48(a0)
    80005000:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005002:	854a                	mv	a0,s2
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	eca080e7          	jalr	-310(ra) # 80000ece <release>
}
    8000500c:	60e2                	ld	ra,24(sp)
    8000500e:	6442                	ld	s0,16(sp)
    80005010:	64a2                	ld	s1,8(sp)
    80005012:	6902                	ld	s2,0(sp)
    80005014:	6105                	addi	sp,sp,32
    80005016:	8082                	ret

0000000080005018 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005018:	1101                	addi	sp,sp,-32
    8000501a:	ec06                	sd	ra,24(sp)
    8000501c:	e822                	sd	s0,16(sp)
    8000501e:	e426                	sd	s1,8(sp)
    80005020:	e04a                	sd	s2,0(sp)
    80005022:	1000                	addi	s0,sp,32
    80005024:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005026:	00850913          	addi	s2,a0,8
    8000502a:	854a                	mv	a0,s2
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	dee080e7          	jalr	-530(ra) # 80000e1a <acquire>
  lk->locked = 0;
    80005034:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005038:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000503c:	8526                	mv	a0,s1
    8000503e:	ffffe097          	auipc	ra,0xffffe
    80005042:	93c080e7          	jalr	-1732(ra) # 8000297a <wakeup>
  release(&lk->lk);
    80005046:	854a                	mv	a0,s2
    80005048:	ffffc097          	auipc	ra,0xffffc
    8000504c:	e86080e7          	jalr	-378(ra) # 80000ece <release>
}
    80005050:	60e2                	ld	ra,24(sp)
    80005052:	6442                	ld	s0,16(sp)
    80005054:	64a2                	ld	s1,8(sp)
    80005056:	6902                	ld	s2,0(sp)
    80005058:	6105                	addi	sp,sp,32
    8000505a:	8082                	ret

000000008000505c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000505c:	7179                	addi	sp,sp,-48
    8000505e:	f406                	sd	ra,40(sp)
    80005060:	f022                	sd	s0,32(sp)
    80005062:	ec26                	sd	s1,24(sp)
    80005064:	e84a                	sd	s2,16(sp)
    80005066:	e44e                	sd	s3,8(sp)
    80005068:	1800                	addi	s0,sp,48
    8000506a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000506c:	00850913          	addi	s2,a0,8
    80005070:	854a                	mv	a0,s2
    80005072:	ffffc097          	auipc	ra,0xffffc
    80005076:	da8080e7          	jalr	-600(ra) # 80000e1a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000507a:	409c                	lw	a5,0(s1)
    8000507c:	ef99                	bnez	a5,8000509a <holdingsleep+0x3e>
    8000507e:	4481                	li	s1,0
  release(&lk->lk);
    80005080:	854a                	mv	a0,s2
    80005082:	ffffc097          	auipc	ra,0xffffc
    80005086:	e4c080e7          	jalr	-436(ra) # 80000ece <release>
  return r;
}
    8000508a:	8526                	mv	a0,s1
    8000508c:	70a2                	ld	ra,40(sp)
    8000508e:	7402                	ld	s0,32(sp)
    80005090:	64e2                	ld	s1,24(sp)
    80005092:	6942                	ld	s2,16(sp)
    80005094:	69a2                	ld	s3,8(sp)
    80005096:	6145                	addi	sp,sp,48
    80005098:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000509a:	0284a983          	lw	s3,40(s1)
    8000509e:	ffffd097          	auipc	ra,0xffffd
    800050a2:	bf2080e7          	jalr	-1038(ra) # 80001c90 <myproc>
    800050a6:	5904                	lw	s1,48(a0)
    800050a8:	413484b3          	sub	s1,s1,s3
    800050ac:	0014b493          	seqz	s1,s1
    800050b0:	bfc1                	j	80005080 <holdingsleep+0x24>

00000000800050b2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800050b2:	1141                	addi	sp,sp,-16
    800050b4:	e406                	sd	ra,8(sp)
    800050b6:	e022                	sd	s0,0(sp)
    800050b8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800050ba:	00004597          	auipc	a1,0x4
    800050be:	90658593          	addi	a1,a1,-1786 # 800089c0 <syscall_names+0x268>
    800050c2:	00242517          	auipc	a0,0x242
    800050c6:	66e50513          	addi	a0,a0,1646 # 80247730 <ftable>
    800050ca:	ffffc097          	auipc	ra,0xffffc
    800050ce:	cc0080e7          	jalr	-832(ra) # 80000d8a <initlock>
}
    800050d2:	60a2                	ld	ra,8(sp)
    800050d4:	6402                	ld	s0,0(sp)
    800050d6:	0141                	addi	sp,sp,16
    800050d8:	8082                	ret

00000000800050da <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800050da:	1101                	addi	sp,sp,-32
    800050dc:	ec06                	sd	ra,24(sp)
    800050de:	e822                	sd	s0,16(sp)
    800050e0:	e426                	sd	s1,8(sp)
    800050e2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800050e4:	00242517          	auipc	a0,0x242
    800050e8:	64c50513          	addi	a0,a0,1612 # 80247730 <ftable>
    800050ec:	ffffc097          	auipc	ra,0xffffc
    800050f0:	d2e080e7          	jalr	-722(ra) # 80000e1a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800050f4:	00242497          	auipc	s1,0x242
    800050f8:	65448493          	addi	s1,s1,1620 # 80247748 <ftable+0x18>
    800050fc:	00243717          	auipc	a4,0x243
    80005100:	5ec70713          	addi	a4,a4,1516 # 802486e8 <disk>
    if(f->ref == 0){
    80005104:	40dc                	lw	a5,4(s1)
    80005106:	cf99                	beqz	a5,80005124 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005108:	02848493          	addi	s1,s1,40
    8000510c:	fee49ce3          	bne	s1,a4,80005104 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005110:	00242517          	auipc	a0,0x242
    80005114:	62050513          	addi	a0,a0,1568 # 80247730 <ftable>
    80005118:	ffffc097          	auipc	ra,0xffffc
    8000511c:	db6080e7          	jalr	-586(ra) # 80000ece <release>
  return 0;
    80005120:	4481                	li	s1,0
    80005122:	a819                	j	80005138 <filealloc+0x5e>
      f->ref = 1;
    80005124:	4785                	li	a5,1
    80005126:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005128:	00242517          	auipc	a0,0x242
    8000512c:	60850513          	addi	a0,a0,1544 # 80247730 <ftable>
    80005130:	ffffc097          	auipc	ra,0xffffc
    80005134:	d9e080e7          	jalr	-610(ra) # 80000ece <release>
}
    80005138:	8526                	mv	a0,s1
    8000513a:	60e2                	ld	ra,24(sp)
    8000513c:	6442                	ld	s0,16(sp)
    8000513e:	64a2                	ld	s1,8(sp)
    80005140:	6105                	addi	sp,sp,32
    80005142:	8082                	ret

0000000080005144 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005144:	1101                	addi	sp,sp,-32
    80005146:	ec06                	sd	ra,24(sp)
    80005148:	e822                	sd	s0,16(sp)
    8000514a:	e426                	sd	s1,8(sp)
    8000514c:	1000                	addi	s0,sp,32
    8000514e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005150:	00242517          	auipc	a0,0x242
    80005154:	5e050513          	addi	a0,a0,1504 # 80247730 <ftable>
    80005158:	ffffc097          	auipc	ra,0xffffc
    8000515c:	cc2080e7          	jalr	-830(ra) # 80000e1a <acquire>
  if(f->ref < 1)
    80005160:	40dc                	lw	a5,4(s1)
    80005162:	02f05263          	blez	a5,80005186 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005166:	2785                	addiw	a5,a5,1
    80005168:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000516a:	00242517          	auipc	a0,0x242
    8000516e:	5c650513          	addi	a0,a0,1478 # 80247730 <ftable>
    80005172:	ffffc097          	auipc	ra,0xffffc
    80005176:	d5c080e7          	jalr	-676(ra) # 80000ece <release>
  return f;
}
    8000517a:	8526                	mv	a0,s1
    8000517c:	60e2                	ld	ra,24(sp)
    8000517e:	6442                	ld	s0,16(sp)
    80005180:	64a2                	ld	s1,8(sp)
    80005182:	6105                	addi	sp,sp,32
    80005184:	8082                	ret
    panic("filedup");
    80005186:	00004517          	auipc	a0,0x4
    8000518a:	84250513          	addi	a0,a0,-1982 # 800089c8 <syscall_names+0x270>
    8000518e:	ffffb097          	auipc	ra,0xffffb
    80005192:	3ae080e7          	jalr	942(ra) # 8000053c <panic>

0000000080005196 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005196:	7139                	addi	sp,sp,-64
    80005198:	fc06                	sd	ra,56(sp)
    8000519a:	f822                	sd	s0,48(sp)
    8000519c:	f426                	sd	s1,40(sp)
    8000519e:	f04a                	sd	s2,32(sp)
    800051a0:	ec4e                	sd	s3,24(sp)
    800051a2:	e852                	sd	s4,16(sp)
    800051a4:	e456                	sd	s5,8(sp)
    800051a6:	0080                	addi	s0,sp,64
    800051a8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800051aa:	00242517          	auipc	a0,0x242
    800051ae:	58650513          	addi	a0,a0,1414 # 80247730 <ftable>
    800051b2:	ffffc097          	auipc	ra,0xffffc
    800051b6:	c68080e7          	jalr	-920(ra) # 80000e1a <acquire>
  if(f->ref < 1)
    800051ba:	40dc                	lw	a5,4(s1)
    800051bc:	06f05163          	blez	a5,8000521e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800051c0:	37fd                	addiw	a5,a5,-1
    800051c2:	0007871b          	sext.w	a4,a5
    800051c6:	c0dc                	sw	a5,4(s1)
    800051c8:	06e04363          	bgtz	a4,8000522e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800051cc:	0004a903          	lw	s2,0(s1)
    800051d0:	0094ca83          	lbu	s5,9(s1)
    800051d4:	0104ba03          	ld	s4,16(s1)
    800051d8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800051dc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800051e0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800051e4:	00242517          	auipc	a0,0x242
    800051e8:	54c50513          	addi	a0,a0,1356 # 80247730 <ftable>
    800051ec:	ffffc097          	auipc	ra,0xffffc
    800051f0:	ce2080e7          	jalr	-798(ra) # 80000ece <release>

  if(ff.type == FD_PIPE){
    800051f4:	4785                	li	a5,1
    800051f6:	04f90d63          	beq	s2,a5,80005250 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800051fa:	3979                	addiw	s2,s2,-2
    800051fc:	4785                	li	a5,1
    800051fe:	0527e063          	bltu	a5,s2,8000523e <fileclose+0xa8>
    begin_op();
    80005202:	00000097          	auipc	ra,0x0
    80005206:	ad0080e7          	jalr	-1328(ra) # 80004cd2 <begin_op>
    iput(ff.ip);
    8000520a:	854e                	mv	a0,s3
    8000520c:	fffff097          	auipc	ra,0xfffff
    80005210:	2da080e7          	jalr	730(ra) # 800044e6 <iput>
    end_op();
    80005214:	00000097          	auipc	ra,0x0
    80005218:	b38080e7          	jalr	-1224(ra) # 80004d4c <end_op>
    8000521c:	a00d                	j	8000523e <fileclose+0xa8>
    panic("fileclose");
    8000521e:	00003517          	auipc	a0,0x3
    80005222:	7b250513          	addi	a0,a0,1970 # 800089d0 <syscall_names+0x278>
    80005226:	ffffb097          	auipc	ra,0xffffb
    8000522a:	316080e7          	jalr	790(ra) # 8000053c <panic>
    release(&ftable.lock);
    8000522e:	00242517          	auipc	a0,0x242
    80005232:	50250513          	addi	a0,a0,1282 # 80247730 <ftable>
    80005236:	ffffc097          	auipc	ra,0xffffc
    8000523a:	c98080e7          	jalr	-872(ra) # 80000ece <release>
  }
}
    8000523e:	70e2                	ld	ra,56(sp)
    80005240:	7442                	ld	s0,48(sp)
    80005242:	74a2                	ld	s1,40(sp)
    80005244:	7902                	ld	s2,32(sp)
    80005246:	69e2                	ld	s3,24(sp)
    80005248:	6a42                	ld	s4,16(sp)
    8000524a:	6aa2                	ld	s5,8(sp)
    8000524c:	6121                	addi	sp,sp,64
    8000524e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005250:	85d6                	mv	a1,s5
    80005252:	8552                	mv	a0,s4
    80005254:	00000097          	auipc	ra,0x0
    80005258:	348080e7          	jalr	840(ra) # 8000559c <pipeclose>
    8000525c:	b7cd                	j	8000523e <fileclose+0xa8>

000000008000525e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000525e:	715d                	addi	sp,sp,-80
    80005260:	e486                	sd	ra,72(sp)
    80005262:	e0a2                	sd	s0,64(sp)
    80005264:	fc26                	sd	s1,56(sp)
    80005266:	f84a                	sd	s2,48(sp)
    80005268:	f44e                	sd	s3,40(sp)
    8000526a:	0880                	addi	s0,sp,80
    8000526c:	84aa                	mv	s1,a0
    8000526e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005270:	ffffd097          	auipc	ra,0xffffd
    80005274:	a20080e7          	jalr	-1504(ra) # 80001c90 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005278:	409c                	lw	a5,0(s1)
    8000527a:	37f9                	addiw	a5,a5,-2
    8000527c:	4705                	li	a4,1
    8000527e:	04f76763          	bltu	a4,a5,800052cc <filestat+0x6e>
    80005282:	892a                	mv	s2,a0
    ilock(f->ip);
    80005284:	6c88                	ld	a0,24(s1)
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	0a6080e7          	jalr	166(ra) # 8000432c <ilock>
    stati(f->ip, &st);
    8000528e:	fb840593          	addi	a1,s0,-72
    80005292:	6c88                	ld	a0,24(s1)
    80005294:	fffff097          	auipc	ra,0xfffff
    80005298:	322080e7          	jalr	802(ra) # 800045b6 <stati>
    iunlock(f->ip);
    8000529c:	6c88                	ld	a0,24(s1)
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	150080e7          	jalr	336(ra) # 800043ee <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800052a6:	46e1                	li	a3,24
    800052a8:	fb840613          	addi	a2,s0,-72
    800052ac:	85ce                	mv	a1,s3
    800052ae:	05093503          	ld	a0,80(s2)
    800052b2:	ffffc097          	auipc	ra,0xffffc
    800052b6:	606080e7          	jalr	1542(ra) # 800018b8 <copyout>
    800052ba:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800052be:	60a6                	ld	ra,72(sp)
    800052c0:	6406                	ld	s0,64(sp)
    800052c2:	74e2                	ld	s1,56(sp)
    800052c4:	7942                	ld	s2,48(sp)
    800052c6:	79a2                	ld	s3,40(sp)
    800052c8:	6161                	addi	sp,sp,80
    800052ca:	8082                	ret
  return -1;
    800052cc:	557d                	li	a0,-1
    800052ce:	bfc5                	j	800052be <filestat+0x60>

00000000800052d0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800052d0:	7179                	addi	sp,sp,-48
    800052d2:	f406                	sd	ra,40(sp)
    800052d4:	f022                	sd	s0,32(sp)
    800052d6:	ec26                	sd	s1,24(sp)
    800052d8:	e84a                	sd	s2,16(sp)
    800052da:	e44e                	sd	s3,8(sp)
    800052dc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800052de:	00854783          	lbu	a5,8(a0)
    800052e2:	c3d5                	beqz	a5,80005386 <fileread+0xb6>
    800052e4:	84aa                	mv	s1,a0
    800052e6:	89ae                	mv	s3,a1
    800052e8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800052ea:	411c                	lw	a5,0(a0)
    800052ec:	4705                	li	a4,1
    800052ee:	04e78963          	beq	a5,a4,80005340 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800052f2:	470d                	li	a4,3
    800052f4:	04e78d63          	beq	a5,a4,8000534e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800052f8:	4709                	li	a4,2
    800052fa:	06e79e63          	bne	a5,a4,80005376 <fileread+0xa6>
    ilock(f->ip);
    800052fe:	6d08                	ld	a0,24(a0)
    80005300:	fffff097          	auipc	ra,0xfffff
    80005304:	02c080e7          	jalr	44(ra) # 8000432c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005308:	874a                	mv	a4,s2
    8000530a:	5094                	lw	a3,32(s1)
    8000530c:	864e                	mv	a2,s3
    8000530e:	4585                	li	a1,1
    80005310:	6c88                	ld	a0,24(s1)
    80005312:	fffff097          	auipc	ra,0xfffff
    80005316:	2ce080e7          	jalr	718(ra) # 800045e0 <readi>
    8000531a:	892a                	mv	s2,a0
    8000531c:	00a05563          	blez	a0,80005326 <fileread+0x56>
      f->off += r;
    80005320:	509c                	lw	a5,32(s1)
    80005322:	9fa9                	addw	a5,a5,a0
    80005324:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005326:	6c88                	ld	a0,24(s1)
    80005328:	fffff097          	auipc	ra,0xfffff
    8000532c:	0c6080e7          	jalr	198(ra) # 800043ee <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005330:	854a                	mv	a0,s2
    80005332:	70a2                	ld	ra,40(sp)
    80005334:	7402                	ld	s0,32(sp)
    80005336:	64e2                	ld	s1,24(sp)
    80005338:	6942                	ld	s2,16(sp)
    8000533a:	69a2                	ld	s3,8(sp)
    8000533c:	6145                	addi	sp,sp,48
    8000533e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005340:	6908                	ld	a0,16(a0)
    80005342:	00000097          	auipc	ra,0x0
    80005346:	3c2080e7          	jalr	962(ra) # 80005704 <piperead>
    8000534a:	892a                	mv	s2,a0
    8000534c:	b7d5                	j	80005330 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000534e:	02451783          	lh	a5,36(a0)
    80005352:	03079693          	slli	a3,a5,0x30
    80005356:	92c1                	srli	a3,a3,0x30
    80005358:	4725                	li	a4,9
    8000535a:	02d76863          	bltu	a4,a3,8000538a <fileread+0xba>
    8000535e:	0792                	slli	a5,a5,0x4
    80005360:	00242717          	auipc	a4,0x242
    80005364:	33070713          	addi	a4,a4,816 # 80247690 <devsw>
    80005368:	97ba                	add	a5,a5,a4
    8000536a:	639c                	ld	a5,0(a5)
    8000536c:	c38d                	beqz	a5,8000538e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000536e:	4505                	li	a0,1
    80005370:	9782                	jalr	a5
    80005372:	892a                	mv	s2,a0
    80005374:	bf75                	j	80005330 <fileread+0x60>
    panic("fileread");
    80005376:	00003517          	auipc	a0,0x3
    8000537a:	66a50513          	addi	a0,a0,1642 # 800089e0 <syscall_names+0x288>
    8000537e:	ffffb097          	auipc	ra,0xffffb
    80005382:	1be080e7          	jalr	446(ra) # 8000053c <panic>
    return -1;
    80005386:	597d                	li	s2,-1
    80005388:	b765                	j	80005330 <fileread+0x60>
      return -1;
    8000538a:	597d                	li	s2,-1
    8000538c:	b755                	j	80005330 <fileread+0x60>
    8000538e:	597d                	li	s2,-1
    80005390:	b745                	j	80005330 <fileread+0x60>

0000000080005392 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005392:	00954783          	lbu	a5,9(a0)
    80005396:	10078e63          	beqz	a5,800054b2 <filewrite+0x120>
{
    8000539a:	715d                	addi	sp,sp,-80
    8000539c:	e486                	sd	ra,72(sp)
    8000539e:	e0a2                	sd	s0,64(sp)
    800053a0:	fc26                	sd	s1,56(sp)
    800053a2:	f84a                	sd	s2,48(sp)
    800053a4:	f44e                	sd	s3,40(sp)
    800053a6:	f052                	sd	s4,32(sp)
    800053a8:	ec56                	sd	s5,24(sp)
    800053aa:	e85a                	sd	s6,16(sp)
    800053ac:	e45e                	sd	s7,8(sp)
    800053ae:	e062                	sd	s8,0(sp)
    800053b0:	0880                	addi	s0,sp,80
    800053b2:	892a                	mv	s2,a0
    800053b4:	8b2e                	mv	s6,a1
    800053b6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800053b8:	411c                	lw	a5,0(a0)
    800053ba:	4705                	li	a4,1
    800053bc:	02e78263          	beq	a5,a4,800053e0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800053c0:	470d                	li	a4,3
    800053c2:	02e78563          	beq	a5,a4,800053ec <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800053c6:	4709                	li	a4,2
    800053c8:	0ce79d63          	bne	a5,a4,800054a2 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800053cc:	0ac05b63          	blez	a2,80005482 <filewrite+0xf0>
    int i = 0;
    800053d0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800053d2:	6b85                	lui	s7,0x1
    800053d4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800053d8:	6c05                	lui	s8,0x1
    800053da:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800053de:	a851                	j	80005472 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800053e0:	6908                	ld	a0,16(a0)
    800053e2:	00000097          	auipc	ra,0x0
    800053e6:	22a080e7          	jalr	554(ra) # 8000560c <pipewrite>
    800053ea:	a045                	j	8000548a <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800053ec:	02451783          	lh	a5,36(a0)
    800053f0:	03079693          	slli	a3,a5,0x30
    800053f4:	92c1                	srli	a3,a3,0x30
    800053f6:	4725                	li	a4,9
    800053f8:	0ad76f63          	bltu	a4,a3,800054b6 <filewrite+0x124>
    800053fc:	0792                	slli	a5,a5,0x4
    800053fe:	00242717          	auipc	a4,0x242
    80005402:	29270713          	addi	a4,a4,658 # 80247690 <devsw>
    80005406:	97ba                	add	a5,a5,a4
    80005408:	679c                	ld	a5,8(a5)
    8000540a:	cbc5                	beqz	a5,800054ba <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000540c:	4505                	li	a0,1
    8000540e:	9782                	jalr	a5
    80005410:	a8ad                	j	8000548a <filewrite+0xf8>
      if(n1 > max)
    80005412:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80005416:	00000097          	auipc	ra,0x0
    8000541a:	8bc080e7          	jalr	-1860(ra) # 80004cd2 <begin_op>
      ilock(f->ip);
    8000541e:	01893503          	ld	a0,24(s2)
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	f0a080e7          	jalr	-246(ra) # 8000432c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000542a:	8756                	mv	a4,s5
    8000542c:	02092683          	lw	a3,32(s2)
    80005430:	01698633          	add	a2,s3,s6
    80005434:	4585                	li	a1,1
    80005436:	01893503          	ld	a0,24(s2)
    8000543a:	fffff097          	auipc	ra,0xfffff
    8000543e:	29e080e7          	jalr	670(ra) # 800046d8 <writei>
    80005442:	84aa                	mv	s1,a0
    80005444:	00a05763          	blez	a0,80005452 <filewrite+0xc0>
        f->off += r;
    80005448:	02092783          	lw	a5,32(s2)
    8000544c:	9fa9                	addw	a5,a5,a0
    8000544e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005452:	01893503          	ld	a0,24(s2)
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	f98080e7          	jalr	-104(ra) # 800043ee <iunlock>
      end_op();
    8000545e:	00000097          	auipc	ra,0x0
    80005462:	8ee080e7          	jalr	-1810(ra) # 80004d4c <end_op>

      if(r != n1){
    80005466:	009a9f63          	bne	s5,s1,80005484 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    8000546a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000546e:	0149db63          	bge	s3,s4,80005484 <filewrite+0xf2>
      int n1 = n - i;
    80005472:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80005476:	0004879b          	sext.w	a5,s1
    8000547a:	f8fbdce3          	bge	s7,a5,80005412 <filewrite+0x80>
    8000547e:	84e2                	mv	s1,s8
    80005480:	bf49                	j	80005412 <filewrite+0x80>
    int i = 0;
    80005482:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005484:	033a1d63          	bne	s4,s3,800054be <filewrite+0x12c>
    80005488:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000548a:	60a6                	ld	ra,72(sp)
    8000548c:	6406                	ld	s0,64(sp)
    8000548e:	74e2                	ld	s1,56(sp)
    80005490:	7942                	ld	s2,48(sp)
    80005492:	79a2                	ld	s3,40(sp)
    80005494:	7a02                	ld	s4,32(sp)
    80005496:	6ae2                	ld	s5,24(sp)
    80005498:	6b42                	ld	s6,16(sp)
    8000549a:	6ba2                	ld	s7,8(sp)
    8000549c:	6c02                	ld	s8,0(sp)
    8000549e:	6161                	addi	sp,sp,80
    800054a0:	8082                	ret
    panic("filewrite");
    800054a2:	00003517          	auipc	a0,0x3
    800054a6:	54e50513          	addi	a0,a0,1358 # 800089f0 <syscall_names+0x298>
    800054aa:	ffffb097          	auipc	ra,0xffffb
    800054ae:	092080e7          	jalr	146(ra) # 8000053c <panic>
    return -1;
    800054b2:	557d                	li	a0,-1
}
    800054b4:	8082                	ret
      return -1;
    800054b6:	557d                	li	a0,-1
    800054b8:	bfc9                	j	8000548a <filewrite+0xf8>
    800054ba:	557d                	li	a0,-1
    800054bc:	b7f9                	j	8000548a <filewrite+0xf8>
    ret = (i == n ? n : -1);
    800054be:	557d                	li	a0,-1
    800054c0:	b7e9                	j	8000548a <filewrite+0xf8>

00000000800054c2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800054c2:	7179                	addi	sp,sp,-48
    800054c4:	f406                	sd	ra,40(sp)
    800054c6:	f022                	sd	s0,32(sp)
    800054c8:	ec26                	sd	s1,24(sp)
    800054ca:	e84a                	sd	s2,16(sp)
    800054cc:	e44e                	sd	s3,8(sp)
    800054ce:	e052                	sd	s4,0(sp)
    800054d0:	1800                	addi	s0,sp,48
    800054d2:	84aa                	mv	s1,a0
    800054d4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800054d6:	0005b023          	sd	zero,0(a1)
    800054da:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800054de:	00000097          	auipc	ra,0x0
    800054e2:	bfc080e7          	jalr	-1028(ra) # 800050da <filealloc>
    800054e6:	e088                	sd	a0,0(s1)
    800054e8:	c551                	beqz	a0,80005574 <pipealloc+0xb2>
    800054ea:	00000097          	auipc	ra,0x0
    800054ee:	bf0080e7          	jalr	-1040(ra) # 800050da <filealloc>
    800054f2:	00aa3023          	sd	a0,0(s4)
    800054f6:	c92d                	beqz	a0,80005568 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800054f8:	ffffb097          	auipc	ra,0xffffb
    800054fc:	740080e7          	jalr	1856(ra) # 80000c38 <kalloc>
    80005500:	892a                	mv	s2,a0
    80005502:	c125                	beqz	a0,80005562 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005504:	4985                	li	s3,1
    80005506:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000550a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000550e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005512:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005516:	00003597          	auipc	a1,0x3
    8000551a:	00a58593          	addi	a1,a1,10 # 80008520 <states.0+0x1b8>
    8000551e:	ffffc097          	auipc	ra,0xffffc
    80005522:	86c080e7          	jalr	-1940(ra) # 80000d8a <initlock>
  (*f0)->type = FD_PIPE;
    80005526:	609c                	ld	a5,0(s1)
    80005528:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000552c:	609c                	ld	a5,0(s1)
    8000552e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005532:	609c                	ld	a5,0(s1)
    80005534:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005538:	609c                	ld	a5,0(s1)
    8000553a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000553e:	000a3783          	ld	a5,0(s4)
    80005542:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005546:	000a3783          	ld	a5,0(s4)
    8000554a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000554e:	000a3783          	ld	a5,0(s4)
    80005552:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005556:	000a3783          	ld	a5,0(s4)
    8000555a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000555e:	4501                	li	a0,0
    80005560:	a025                	j	80005588 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005562:	6088                	ld	a0,0(s1)
    80005564:	e501                	bnez	a0,8000556c <pipealloc+0xaa>
    80005566:	a039                	j	80005574 <pipealloc+0xb2>
    80005568:	6088                	ld	a0,0(s1)
    8000556a:	c51d                	beqz	a0,80005598 <pipealloc+0xd6>
    fileclose(*f0);
    8000556c:	00000097          	auipc	ra,0x0
    80005570:	c2a080e7          	jalr	-982(ra) # 80005196 <fileclose>
  if(*f1)
    80005574:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005578:	557d                	li	a0,-1
  if(*f1)
    8000557a:	c799                	beqz	a5,80005588 <pipealloc+0xc6>
    fileclose(*f1);
    8000557c:	853e                	mv	a0,a5
    8000557e:	00000097          	auipc	ra,0x0
    80005582:	c18080e7          	jalr	-1000(ra) # 80005196 <fileclose>
  return -1;
    80005586:	557d                	li	a0,-1
}
    80005588:	70a2                	ld	ra,40(sp)
    8000558a:	7402                	ld	s0,32(sp)
    8000558c:	64e2                	ld	s1,24(sp)
    8000558e:	6942                	ld	s2,16(sp)
    80005590:	69a2                	ld	s3,8(sp)
    80005592:	6a02                	ld	s4,0(sp)
    80005594:	6145                	addi	sp,sp,48
    80005596:	8082                	ret
  return -1;
    80005598:	557d                	li	a0,-1
    8000559a:	b7fd                	j	80005588 <pipealloc+0xc6>

000000008000559c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000559c:	1101                	addi	sp,sp,-32
    8000559e:	ec06                	sd	ra,24(sp)
    800055a0:	e822                	sd	s0,16(sp)
    800055a2:	e426                	sd	s1,8(sp)
    800055a4:	e04a                	sd	s2,0(sp)
    800055a6:	1000                	addi	s0,sp,32
    800055a8:	84aa                	mv	s1,a0
    800055aa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800055ac:	ffffc097          	auipc	ra,0xffffc
    800055b0:	86e080e7          	jalr	-1938(ra) # 80000e1a <acquire>
  if(writable){
    800055b4:	02090d63          	beqz	s2,800055ee <pipeclose+0x52>
    pi->writeopen = 0;
    800055b8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800055bc:	21848513          	addi	a0,s1,536
    800055c0:	ffffd097          	auipc	ra,0xffffd
    800055c4:	3ba080e7          	jalr	954(ra) # 8000297a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800055c8:	2204b783          	ld	a5,544(s1)
    800055cc:	eb95                	bnez	a5,80005600 <pipeclose+0x64>
    release(&pi->lock);
    800055ce:	8526                	mv	a0,s1
    800055d0:	ffffc097          	auipc	ra,0xffffc
    800055d4:	8fe080e7          	jalr	-1794(ra) # 80000ece <release>
    kfree((char*)pi);
    800055d8:	8526                	mv	a0,s1
    800055da:	ffffb097          	auipc	ra,0xffffb
    800055de:	40a080e7          	jalr	1034(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    800055e2:	60e2                	ld	ra,24(sp)
    800055e4:	6442                	ld	s0,16(sp)
    800055e6:	64a2                	ld	s1,8(sp)
    800055e8:	6902                	ld	s2,0(sp)
    800055ea:	6105                	addi	sp,sp,32
    800055ec:	8082                	ret
    pi->readopen = 0;
    800055ee:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800055f2:	21c48513          	addi	a0,s1,540
    800055f6:	ffffd097          	auipc	ra,0xffffd
    800055fa:	384080e7          	jalr	900(ra) # 8000297a <wakeup>
    800055fe:	b7e9                	j	800055c8 <pipeclose+0x2c>
    release(&pi->lock);
    80005600:	8526                	mv	a0,s1
    80005602:	ffffc097          	auipc	ra,0xffffc
    80005606:	8cc080e7          	jalr	-1844(ra) # 80000ece <release>
}
    8000560a:	bfe1                	j	800055e2 <pipeclose+0x46>

000000008000560c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000560c:	711d                	addi	sp,sp,-96
    8000560e:	ec86                	sd	ra,88(sp)
    80005610:	e8a2                	sd	s0,80(sp)
    80005612:	e4a6                	sd	s1,72(sp)
    80005614:	e0ca                	sd	s2,64(sp)
    80005616:	fc4e                	sd	s3,56(sp)
    80005618:	f852                	sd	s4,48(sp)
    8000561a:	f456                	sd	s5,40(sp)
    8000561c:	f05a                	sd	s6,32(sp)
    8000561e:	ec5e                	sd	s7,24(sp)
    80005620:	e862                	sd	s8,16(sp)
    80005622:	1080                	addi	s0,sp,96
    80005624:	84aa                	mv	s1,a0
    80005626:	8aae                	mv	s5,a1
    80005628:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000562a:	ffffc097          	auipc	ra,0xffffc
    8000562e:	666080e7          	jalr	1638(ra) # 80001c90 <myproc>
    80005632:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffb097          	auipc	ra,0xffffb
    8000563a:	7e4080e7          	jalr	2020(ra) # 80000e1a <acquire>
  while(i < n){
    8000563e:	0b405663          	blez	s4,800056ea <pipewrite+0xde>
  int i = 0;
    80005642:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005644:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005646:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000564a:	21c48b93          	addi	s7,s1,540
    8000564e:	a089                	j	80005690 <pipewrite+0x84>
      release(&pi->lock);
    80005650:	8526                	mv	a0,s1
    80005652:	ffffc097          	auipc	ra,0xffffc
    80005656:	87c080e7          	jalr	-1924(ra) # 80000ece <release>
      return -1;
    8000565a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000565c:	854a                	mv	a0,s2
    8000565e:	60e6                	ld	ra,88(sp)
    80005660:	6446                	ld	s0,80(sp)
    80005662:	64a6                	ld	s1,72(sp)
    80005664:	6906                	ld	s2,64(sp)
    80005666:	79e2                	ld	s3,56(sp)
    80005668:	7a42                	ld	s4,48(sp)
    8000566a:	7aa2                	ld	s5,40(sp)
    8000566c:	7b02                	ld	s6,32(sp)
    8000566e:	6be2                	ld	s7,24(sp)
    80005670:	6c42                	ld	s8,16(sp)
    80005672:	6125                	addi	sp,sp,96
    80005674:	8082                	ret
      wakeup(&pi->nread);
    80005676:	8562                	mv	a0,s8
    80005678:	ffffd097          	auipc	ra,0xffffd
    8000567c:	302080e7          	jalr	770(ra) # 8000297a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005680:	85a6                	mv	a1,s1
    80005682:	855e                	mv	a0,s7
    80005684:	ffffd097          	auipc	ra,0xffffd
    80005688:	146080e7          	jalr	326(ra) # 800027ca <sleep>
  while(i < n){
    8000568c:	07495063          	bge	s2,s4,800056ec <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005690:	2204a783          	lw	a5,544(s1)
    80005694:	dfd5                	beqz	a5,80005650 <pipewrite+0x44>
    80005696:	854e                	mv	a0,s3
    80005698:	ffffd097          	auipc	ra,0xffffd
    8000569c:	532080e7          	jalr	1330(ra) # 80002bca <killed>
    800056a0:	f945                	bnez	a0,80005650 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800056a2:	2184a783          	lw	a5,536(s1)
    800056a6:	21c4a703          	lw	a4,540(s1)
    800056aa:	2007879b          	addiw	a5,a5,512
    800056ae:	fcf704e3          	beq	a4,a5,80005676 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800056b2:	4685                	li	a3,1
    800056b4:	01590633          	add	a2,s2,s5
    800056b8:	faf40593          	addi	a1,s0,-81
    800056bc:	0509b503          	ld	a0,80(s3)
    800056c0:	ffffc097          	auipc	ra,0xffffc
    800056c4:	2bc080e7          	jalr	700(ra) # 8000197c <copyin>
    800056c8:	03650263          	beq	a0,s6,800056ec <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800056cc:	21c4a783          	lw	a5,540(s1)
    800056d0:	0017871b          	addiw	a4,a5,1
    800056d4:	20e4ae23          	sw	a4,540(s1)
    800056d8:	1ff7f793          	andi	a5,a5,511
    800056dc:	97a6                	add	a5,a5,s1
    800056de:	faf44703          	lbu	a4,-81(s0)
    800056e2:	00e78c23          	sb	a4,24(a5)
      i++;
    800056e6:	2905                	addiw	s2,s2,1
    800056e8:	b755                	j	8000568c <pipewrite+0x80>
  int i = 0;
    800056ea:	4901                	li	s2,0
  wakeup(&pi->nread);
    800056ec:	21848513          	addi	a0,s1,536
    800056f0:	ffffd097          	auipc	ra,0xffffd
    800056f4:	28a080e7          	jalr	650(ra) # 8000297a <wakeup>
  release(&pi->lock);
    800056f8:	8526                	mv	a0,s1
    800056fa:	ffffb097          	auipc	ra,0xffffb
    800056fe:	7d4080e7          	jalr	2004(ra) # 80000ece <release>
  return i;
    80005702:	bfa9                	j	8000565c <pipewrite+0x50>

0000000080005704 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005704:	715d                	addi	sp,sp,-80
    80005706:	e486                	sd	ra,72(sp)
    80005708:	e0a2                	sd	s0,64(sp)
    8000570a:	fc26                	sd	s1,56(sp)
    8000570c:	f84a                	sd	s2,48(sp)
    8000570e:	f44e                	sd	s3,40(sp)
    80005710:	f052                	sd	s4,32(sp)
    80005712:	ec56                	sd	s5,24(sp)
    80005714:	e85a                	sd	s6,16(sp)
    80005716:	0880                	addi	s0,sp,80
    80005718:	84aa                	mv	s1,a0
    8000571a:	892e                	mv	s2,a1
    8000571c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000571e:	ffffc097          	auipc	ra,0xffffc
    80005722:	572080e7          	jalr	1394(ra) # 80001c90 <myproc>
    80005726:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005728:	8526                	mv	a0,s1
    8000572a:	ffffb097          	auipc	ra,0xffffb
    8000572e:	6f0080e7          	jalr	1776(ra) # 80000e1a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005732:	2184a703          	lw	a4,536(s1)
    80005736:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000573a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000573e:	02f71763          	bne	a4,a5,8000576c <piperead+0x68>
    80005742:	2244a783          	lw	a5,548(s1)
    80005746:	c39d                	beqz	a5,8000576c <piperead+0x68>
    if(killed(pr)){
    80005748:	8552                	mv	a0,s4
    8000574a:	ffffd097          	auipc	ra,0xffffd
    8000574e:	480080e7          	jalr	1152(ra) # 80002bca <killed>
    80005752:	e949                	bnez	a0,800057e4 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005754:	85a6                	mv	a1,s1
    80005756:	854e                	mv	a0,s3
    80005758:	ffffd097          	auipc	ra,0xffffd
    8000575c:	072080e7          	jalr	114(ra) # 800027ca <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005760:	2184a703          	lw	a4,536(s1)
    80005764:	21c4a783          	lw	a5,540(s1)
    80005768:	fcf70de3          	beq	a4,a5,80005742 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000576c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000576e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005770:	05505463          	blez	s5,800057b8 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005774:	2184a783          	lw	a5,536(s1)
    80005778:	21c4a703          	lw	a4,540(s1)
    8000577c:	02f70e63          	beq	a4,a5,800057b8 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005780:	0017871b          	addiw	a4,a5,1
    80005784:	20e4ac23          	sw	a4,536(s1)
    80005788:	1ff7f793          	andi	a5,a5,511
    8000578c:	97a6                	add	a5,a5,s1
    8000578e:	0187c783          	lbu	a5,24(a5)
    80005792:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005796:	4685                	li	a3,1
    80005798:	fbf40613          	addi	a2,s0,-65
    8000579c:	85ca                	mv	a1,s2
    8000579e:	050a3503          	ld	a0,80(s4)
    800057a2:	ffffc097          	auipc	ra,0xffffc
    800057a6:	116080e7          	jalr	278(ra) # 800018b8 <copyout>
    800057aa:	01650763          	beq	a0,s6,800057b8 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800057ae:	2985                	addiw	s3,s3,1
    800057b0:	0905                	addi	s2,s2,1
    800057b2:	fd3a91e3          	bne	s5,s3,80005774 <piperead+0x70>
    800057b6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800057b8:	21c48513          	addi	a0,s1,540
    800057bc:	ffffd097          	auipc	ra,0xffffd
    800057c0:	1be080e7          	jalr	446(ra) # 8000297a <wakeup>
  release(&pi->lock);
    800057c4:	8526                	mv	a0,s1
    800057c6:	ffffb097          	auipc	ra,0xffffb
    800057ca:	708080e7          	jalr	1800(ra) # 80000ece <release>
  return i;
}
    800057ce:	854e                	mv	a0,s3
    800057d0:	60a6                	ld	ra,72(sp)
    800057d2:	6406                	ld	s0,64(sp)
    800057d4:	74e2                	ld	s1,56(sp)
    800057d6:	7942                	ld	s2,48(sp)
    800057d8:	79a2                	ld	s3,40(sp)
    800057da:	7a02                	ld	s4,32(sp)
    800057dc:	6ae2                	ld	s5,24(sp)
    800057de:	6b42                	ld	s6,16(sp)
    800057e0:	6161                	addi	sp,sp,80
    800057e2:	8082                	ret
      release(&pi->lock);
    800057e4:	8526                	mv	a0,s1
    800057e6:	ffffb097          	auipc	ra,0xffffb
    800057ea:	6e8080e7          	jalr	1768(ra) # 80000ece <release>
      return -1;
    800057ee:	59fd                	li	s3,-1
    800057f0:	bff9                	j	800057ce <piperead+0xca>

00000000800057f2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800057f2:	1141                	addi	sp,sp,-16
    800057f4:	e422                	sd	s0,8(sp)
    800057f6:	0800                	addi	s0,sp,16
    800057f8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800057fa:	8905                	andi	a0,a0,1
    800057fc:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800057fe:	8b89                	andi	a5,a5,2
    80005800:	c399                	beqz	a5,80005806 <flags2perm+0x14>
      perm |= PTE_W;
    80005802:	00456513          	ori	a0,a0,4
    return perm;
}
    80005806:	6422                	ld	s0,8(sp)
    80005808:	0141                	addi	sp,sp,16
    8000580a:	8082                	ret

000000008000580c <exec>:

int
exec(char *path, char **argv)
{
    8000580c:	df010113          	addi	sp,sp,-528
    80005810:	20113423          	sd	ra,520(sp)
    80005814:	20813023          	sd	s0,512(sp)
    80005818:	ffa6                	sd	s1,504(sp)
    8000581a:	fbca                	sd	s2,496(sp)
    8000581c:	f7ce                	sd	s3,488(sp)
    8000581e:	f3d2                	sd	s4,480(sp)
    80005820:	efd6                	sd	s5,472(sp)
    80005822:	ebda                	sd	s6,464(sp)
    80005824:	e7de                	sd	s7,456(sp)
    80005826:	e3e2                	sd	s8,448(sp)
    80005828:	ff66                	sd	s9,440(sp)
    8000582a:	fb6a                	sd	s10,432(sp)
    8000582c:	f76e                	sd	s11,424(sp)
    8000582e:	0c00                	addi	s0,sp,528
    80005830:	892a                	mv	s2,a0
    80005832:	dea43c23          	sd	a0,-520(s0)
    80005836:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000583a:	ffffc097          	auipc	ra,0xffffc
    8000583e:	456080e7          	jalr	1110(ra) # 80001c90 <myproc>
    80005842:	84aa                	mv	s1,a0

  begin_op();
    80005844:	fffff097          	auipc	ra,0xfffff
    80005848:	48e080e7          	jalr	1166(ra) # 80004cd2 <begin_op>

  if((ip = namei(path)) == 0){
    8000584c:	854a                	mv	a0,s2
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	284080e7          	jalr	644(ra) # 80004ad2 <namei>
    80005856:	c92d                	beqz	a0,800058c8 <exec+0xbc>
    80005858:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	ad2080e7          	jalr	-1326(ra) # 8000432c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005862:	04000713          	li	a4,64
    80005866:	4681                	li	a3,0
    80005868:	e5040613          	addi	a2,s0,-432
    8000586c:	4581                	li	a1,0
    8000586e:	8552                	mv	a0,s4
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	d70080e7          	jalr	-656(ra) # 800045e0 <readi>
    80005878:	04000793          	li	a5,64
    8000587c:	00f51a63          	bne	a0,a5,80005890 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005880:	e5042703          	lw	a4,-432(s0)
    80005884:	464c47b7          	lui	a5,0x464c4
    80005888:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000588c:	04f70463          	beq	a4,a5,800058d4 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005890:	8552                	mv	a0,s4
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	cfc080e7          	jalr	-772(ra) # 8000458e <iunlockput>
    end_op();
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	4b2080e7          	jalr	1202(ra) # 80004d4c <end_op>
  }
  return -1;
    800058a2:	557d                	li	a0,-1
}
    800058a4:	20813083          	ld	ra,520(sp)
    800058a8:	20013403          	ld	s0,512(sp)
    800058ac:	74fe                	ld	s1,504(sp)
    800058ae:	795e                	ld	s2,496(sp)
    800058b0:	79be                	ld	s3,488(sp)
    800058b2:	7a1e                	ld	s4,480(sp)
    800058b4:	6afe                	ld	s5,472(sp)
    800058b6:	6b5e                	ld	s6,464(sp)
    800058b8:	6bbe                	ld	s7,456(sp)
    800058ba:	6c1e                	ld	s8,448(sp)
    800058bc:	7cfa                	ld	s9,440(sp)
    800058be:	7d5a                	ld	s10,432(sp)
    800058c0:	7dba                	ld	s11,424(sp)
    800058c2:	21010113          	addi	sp,sp,528
    800058c6:	8082                	ret
    end_op();
    800058c8:	fffff097          	auipc	ra,0xfffff
    800058cc:	484080e7          	jalr	1156(ra) # 80004d4c <end_op>
    return -1;
    800058d0:	557d                	li	a0,-1
    800058d2:	bfc9                	j	800058a4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800058d4:	8526                	mv	a0,s1
    800058d6:	ffffc097          	auipc	ra,0xffffc
    800058da:	47e080e7          	jalr	1150(ra) # 80001d54 <proc_pagetable>
    800058de:	8b2a                	mv	s6,a0
    800058e0:	d945                	beqz	a0,80005890 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800058e2:	e7042d03          	lw	s10,-400(s0)
    800058e6:	e8845783          	lhu	a5,-376(s0)
    800058ea:	10078463          	beqz	a5,800059f2 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800058ee:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800058f0:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800058f2:	6c85                	lui	s9,0x1
    800058f4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800058f8:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800058fc:	6a85                	lui	s5,0x1
    800058fe:	a0b5                	j	8000596a <exec+0x15e>
      panic("loadseg: address should exist");
    80005900:	00003517          	auipc	a0,0x3
    80005904:	10050513          	addi	a0,a0,256 # 80008a00 <syscall_names+0x2a8>
    80005908:	ffffb097          	auipc	ra,0xffffb
    8000590c:	c34080e7          	jalr	-972(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80005910:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005912:	8726                	mv	a4,s1
    80005914:	012c06bb          	addw	a3,s8,s2
    80005918:	4581                	li	a1,0
    8000591a:	8552                	mv	a0,s4
    8000591c:	fffff097          	auipc	ra,0xfffff
    80005920:	cc4080e7          	jalr	-828(ra) # 800045e0 <readi>
    80005924:	2501                	sext.w	a0,a0
    80005926:	24a49863          	bne	s1,a0,80005b76 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    8000592a:	012a893b          	addw	s2,s5,s2
    8000592e:	03397563          	bgeu	s2,s3,80005958 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80005932:	02091593          	slli	a1,s2,0x20
    80005936:	9181                	srli	a1,a1,0x20
    80005938:	95de                	add	a1,a1,s7
    8000593a:	855a                	mv	a0,s6
    8000593c:	ffffc097          	auipc	ra,0xffffc
    80005940:	962080e7          	jalr	-1694(ra) # 8000129e <walkaddr>
    80005944:	862a                	mv	a2,a0
    if(pa == 0)
    80005946:	dd4d                	beqz	a0,80005900 <exec+0xf4>
    if(sz - i < PGSIZE)
    80005948:	412984bb          	subw	s1,s3,s2
    8000594c:	0004879b          	sext.w	a5,s1
    80005950:	fcfcf0e3          	bgeu	s9,a5,80005910 <exec+0x104>
    80005954:	84d6                	mv	s1,s5
    80005956:	bf6d                	j	80005910 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005958:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000595c:	2d85                	addiw	s11,s11,1
    8000595e:	038d0d1b          	addiw	s10,s10,56
    80005962:	e8845783          	lhu	a5,-376(s0)
    80005966:	08fdd763          	bge	s11,a5,800059f4 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000596a:	2d01                	sext.w	s10,s10
    8000596c:	03800713          	li	a4,56
    80005970:	86ea                	mv	a3,s10
    80005972:	e1840613          	addi	a2,s0,-488
    80005976:	4581                	li	a1,0
    80005978:	8552                	mv	a0,s4
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	c66080e7          	jalr	-922(ra) # 800045e0 <readi>
    80005982:	03800793          	li	a5,56
    80005986:	1ef51663          	bne	a0,a5,80005b72 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    8000598a:	e1842783          	lw	a5,-488(s0)
    8000598e:	4705                	li	a4,1
    80005990:	fce796e3          	bne	a5,a4,8000595c <exec+0x150>
    if(ph.memsz < ph.filesz)
    80005994:	e4043483          	ld	s1,-448(s0)
    80005998:	e3843783          	ld	a5,-456(s0)
    8000599c:	1ef4e863          	bltu	s1,a5,80005b8c <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800059a0:	e2843783          	ld	a5,-472(s0)
    800059a4:	94be                	add	s1,s1,a5
    800059a6:	1ef4e663          	bltu	s1,a5,80005b92 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    800059aa:	df043703          	ld	a4,-528(s0)
    800059ae:	8ff9                	and	a5,a5,a4
    800059b0:	1e079463          	bnez	a5,80005b98 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800059b4:	e1c42503          	lw	a0,-484(s0)
    800059b8:	00000097          	auipc	ra,0x0
    800059bc:	e3a080e7          	jalr	-454(ra) # 800057f2 <flags2perm>
    800059c0:	86aa                	mv	a3,a0
    800059c2:	8626                	mv	a2,s1
    800059c4:	85ca                	mv	a1,s2
    800059c6:	855a                	mv	a0,s6
    800059c8:	ffffc097          	auipc	ra,0xffffc
    800059cc:	c8a080e7          	jalr	-886(ra) # 80001652 <uvmalloc>
    800059d0:	e0a43423          	sd	a0,-504(s0)
    800059d4:	1c050563          	beqz	a0,80005b9e <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800059d8:	e2843b83          	ld	s7,-472(s0)
    800059dc:	e2042c03          	lw	s8,-480(s0)
    800059e0:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800059e4:	00098463          	beqz	s3,800059ec <exec+0x1e0>
    800059e8:	4901                	li	s2,0
    800059ea:	b7a1                	j	80005932 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800059ec:	e0843903          	ld	s2,-504(s0)
    800059f0:	b7b5                	j	8000595c <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800059f2:	4901                	li	s2,0
  iunlockput(ip);
    800059f4:	8552                	mv	a0,s4
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	b98080e7          	jalr	-1128(ra) # 8000458e <iunlockput>
  end_op();
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	34e080e7          	jalr	846(ra) # 80004d4c <end_op>
  p = myproc();
    80005a06:	ffffc097          	auipc	ra,0xffffc
    80005a0a:	28a080e7          	jalr	650(ra) # 80001c90 <myproc>
    80005a0e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005a10:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005a14:	6985                	lui	s3,0x1
    80005a16:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005a18:	99ca                	add	s3,s3,s2
    80005a1a:	77fd                	lui	a5,0xfffff
    80005a1c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005a20:	4691                	li	a3,4
    80005a22:	6609                	lui	a2,0x2
    80005a24:	964e                	add	a2,a2,s3
    80005a26:	85ce                	mv	a1,s3
    80005a28:	855a                	mv	a0,s6
    80005a2a:	ffffc097          	auipc	ra,0xffffc
    80005a2e:	c28080e7          	jalr	-984(ra) # 80001652 <uvmalloc>
    80005a32:	892a                	mv	s2,a0
    80005a34:	e0a43423          	sd	a0,-504(s0)
    80005a38:	e509                	bnez	a0,80005a42 <exec+0x236>
  if(pagetable)
    80005a3a:	e1343423          	sd	s3,-504(s0)
    80005a3e:	4a01                	li	s4,0
    80005a40:	aa1d                	j	80005b76 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005a42:	75f9                	lui	a1,0xffffe
    80005a44:	95aa                	add	a1,a1,a0
    80005a46:	855a                	mv	a0,s6
    80005a48:	ffffc097          	auipc	ra,0xffffc
    80005a4c:	e3e080e7          	jalr	-450(ra) # 80001886 <uvmclear>
  stackbase = sp - PGSIZE;
    80005a50:	7bfd                	lui	s7,0xfffff
    80005a52:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005a54:	e0043783          	ld	a5,-512(s0)
    80005a58:	6388                	ld	a0,0(a5)
    80005a5a:	c52d                	beqz	a0,80005ac4 <exec+0x2b8>
    80005a5c:	e9040993          	addi	s3,s0,-368
    80005a60:	f9040c13          	addi	s8,s0,-112
    80005a64:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005a66:	ffffb097          	auipc	ra,0xffffb
    80005a6a:	62a080e7          	jalr	1578(ra) # 80001090 <strlen>
    80005a6e:	0015079b          	addiw	a5,a0,1
    80005a72:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005a76:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005a7a:	13796563          	bltu	s2,s7,80005ba4 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005a7e:	e0043d03          	ld	s10,-512(s0)
    80005a82:	000d3a03          	ld	s4,0(s10)
    80005a86:	8552                	mv	a0,s4
    80005a88:	ffffb097          	auipc	ra,0xffffb
    80005a8c:	608080e7          	jalr	1544(ra) # 80001090 <strlen>
    80005a90:	0015069b          	addiw	a3,a0,1
    80005a94:	8652                	mv	a2,s4
    80005a96:	85ca                	mv	a1,s2
    80005a98:	855a                	mv	a0,s6
    80005a9a:	ffffc097          	auipc	ra,0xffffc
    80005a9e:	e1e080e7          	jalr	-482(ra) # 800018b8 <copyout>
    80005aa2:	10054363          	bltz	a0,80005ba8 <exec+0x39c>
    ustack[argc] = sp;
    80005aa6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005aaa:	0485                	addi	s1,s1,1
    80005aac:	008d0793          	addi	a5,s10,8
    80005ab0:	e0f43023          	sd	a5,-512(s0)
    80005ab4:	008d3503          	ld	a0,8(s10)
    80005ab8:	c909                	beqz	a0,80005aca <exec+0x2be>
    if(argc >= MAXARG)
    80005aba:	09a1                	addi	s3,s3,8
    80005abc:	fb8995e3          	bne	s3,s8,80005a66 <exec+0x25a>
  ip = 0;
    80005ac0:	4a01                	li	s4,0
    80005ac2:	a855                	j	80005b76 <exec+0x36a>
  sp = sz;
    80005ac4:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005ac8:	4481                	li	s1,0
  ustack[argc] = 0;
    80005aca:	00349793          	slli	a5,s1,0x3
    80005ace:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdb6768>
    80005ad2:	97a2                	add	a5,a5,s0
    80005ad4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005ad8:	00148693          	addi	a3,s1,1
    80005adc:	068e                	slli	a3,a3,0x3
    80005ade:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005ae2:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005ae6:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005aea:	f57968e3          	bltu	s2,s7,80005a3a <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005aee:	e9040613          	addi	a2,s0,-368
    80005af2:	85ca                	mv	a1,s2
    80005af4:	855a                	mv	a0,s6
    80005af6:	ffffc097          	auipc	ra,0xffffc
    80005afa:	dc2080e7          	jalr	-574(ra) # 800018b8 <copyout>
    80005afe:	0a054763          	bltz	a0,80005bac <exec+0x3a0>
  p->trapframe->a1 = sp;
    80005b02:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005b06:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005b0a:	df843783          	ld	a5,-520(s0)
    80005b0e:	0007c703          	lbu	a4,0(a5)
    80005b12:	cf11                	beqz	a4,80005b2e <exec+0x322>
    80005b14:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005b16:	02f00693          	li	a3,47
    80005b1a:	a039                	j	80005b28 <exec+0x31c>
      last = s+1;
    80005b1c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005b20:	0785                	addi	a5,a5,1
    80005b22:	fff7c703          	lbu	a4,-1(a5)
    80005b26:	c701                	beqz	a4,80005b2e <exec+0x322>
    if(*s == '/')
    80005b28:	fed71ce3          	bne	a4,a3,80005b20 <exec+0x314>
    80005b2c:	bfc5                	j	80005b1c <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80005b2e:	4641                	li	a2,16
    80005b30:	df843583          	ld	a1,-520(s0)
    80005b34:	158a8513          	addi	a0,s5,344
    80005b38:	ffffb097          	auipc	ra,0xffffb
    80005b3c:	526080e7          	jalr	1318(ra) # 8000105e <safestrcpy>
  oldpagetable = p->pagetable;
    80005b40:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005b44:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005b48:	e0843783          	ld	a5,-504(s0)
    80005b4c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005b50:	058ab783          	ld	a5,88(s5)
    80005b54:	e6843703          	ld	a4,-408(s0)
    80005b58:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005b5a:	058ab783          	ld	a5,88(s5)
    80005b5e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005b62:	85e6                	mv	a1,s9
    80005b64:	ffffc097          	auipc	ra,0xffffc
    80005b68:	28c080e7          	jalr	652(ra) # 80001df0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005b6c:	0004851b          	sext.w	a0,s1
    80005b70:	bb15                	j	800058a4 <exec+0x98>
    80005b72:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005b76:	e0843583          	ld	a1,-504(s0)
    80005b7a:	855a                	mv	a0,s6
    80005b7c:	ffffc097          	auipc	ra,0xffffc
    80005b80:	274080e7          	jalr	628(ra) # 80001df0 <proc_freepagetable>
  return -1;
    80005b84:	557d                	li	a0,-1
  if(ip){
    80005b86:	d00a0fe3          	beqz	s4,800058a4 <exec+0x98>
    80005b8a:	b319                	j	80005890 <exec+0x84>
    80005b8c:	e1243423          	sd	s2,-504(s0)
    80005b90:	b7dd                	j	80005b76 <exec+0x36a>
    80005b92:	e1243423          	sd	s2,-504(s0)
    80005b96:	b7c5                	j	80005b76 <exec+0x36a>
    80005b98:	e1243423          	sd	s2,-504(s0)
    80005b9c:	bfe9                	j	80005b76 <exec+0x36a>
    80005b9e:	e1243423          	sd	s2,-504(s0)
    80005ba2:	bfd1                	j	80005b76 <exec+0x36a>
  ip = 0;
    80005ba4:	4a01                	li	s4,0
    80005ba6:	bfc1                	j	80005b76 <exec+0x36a>
    80005ba8:	4a01                	li	s4,0
  if(pagetable)
    80005baa:	b7f1                	j	80005b76 <exec+0x36a>
  sz = sz1;
    80005bac:	e0843983          	ld	s3,-504(s0)
    80005bb0:	b569                	j	80005a3a <exec+0x22e>

0000000080005bb2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005bb2:	7179                	addi	sp,sp,-48
    80005bb4:	f406                	sd	ra,40(sp)
    80005bb6:	f022                	sd	s0,32(sp)
    80005bb8:	ec26                	sd	s1,24(sp)
    80005bba:	e84a                	sd	s2,16(sp)
    80005bbc:	1800                	addi	s0,sp,48
    80005bbe:	892e                	mv	s2,a1
    80005bc0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005bc2:	fdc40593          	addi	a1,s0,-36
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	8ee080e7          	jalr	-1810(ra) # 800034b4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005bce:	fdc42703          	lw	a4,-36(s0)
    80005bd2:	47bd                	li	a5,15
    80005bd4:	02e7eb63          	bltu	a5,a4,80005c0a <argfd+0x58>
    80005bd8:	ffffc097          	auipc	ra,0xffffc
    80005bdc:	0b8080e7          	jalr	184(ra) # 80001c90 <myproc>
    80005be0:	fdc42703          	lw	a4,-36(s0)
    80005be4:	01a70793          	addi	a5,a4,26
    80005be8:	078e                	slli	a5,a5,0x3
    80005bea:	953e                	add	a0,a0,a5
    80005bec:	611c                	ld	a5,0(a0)
    80005bee:	c385                	beqz	a5,80005c0e <argfd+0x5c>
    return -1;
  if(pfd)
    80005bf0:	00090463          	beqz	s2,80005bf8 <argfd+0x46>
    *pfd = fd;
    80005bf4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005bf8:	4501                	li	a0,0
  if(pf)
    80005bfa:	c091                	beqz	s1,80005bfe <argfd+0x4c>
    *pf = f;
    80005bfc:	e09c                	sd	a5,0(s1)
}
    80005bfe:	70a2                	ld	ra,40(sp)
    80005c00:	7402                	ld	s0,32(sp)
    80005c02:	64e2                	ld	s1,24(sp)
    80005c04:	6942                	ld	s2,16(sp)
    80005c06:	6145                	addi	sp,sp,48
    80005c08:	8082                	ret
    return -1;
    80005c0a:	557d                	li	a0,-1
    80005c0c:	bfcd                	j	80005bfe <argfd+0x4c>
    80005c0e:	557d                	li	a0,-1
    80005c10:	b7fd                	j	80005bfe <argfd+0x4c>

0000000080005c12 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005c12:	1101                	addi	sp,sp,-32
    80005c14:	ec06                	sd	ra,24(sp)
    80005c16:	e822                	sd	s0,16(sp)
    80005c18:	e426                	sd	s1,8(sp)
    80005c1a:	1000                	addi	s0,sp,32
    80005c1c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005c1e:	ffffc097          	auipc	ra,0xffffc
    80005c22:	072080e7          	jalr	114(ra) # 80001c90 <myproc>
    80005c26:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005c28:	0d050793          	addi	a5,a0,208
    80005c2c:	4501                	li	a0,0
    80005c2e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005c30:	6398                	ld	a4,0(a5)
    80005c32:	cb19                	beqz	a4,80005c48 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005c34:	2505                	addiw	a0,a0,1
    80005c36:	07a1                	addi	a5,a5,8
    80005c38:	fed51ce3          	bne	a0,a3,80005c30 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005c3c:	557d                	li	a0,-1
}
    80005c3e:	60e2                	ld	ra,24(sp)
    80005c40:	6442                	ld	s0,16(sp)
    80005c42:	64a2                	ld	s1,8(sp)
    80005c44:	6105                	addi	sp,sp,32
    80005c46:	8082                	ret
      p->ofile[fd] = f;
    80005c48:	01a50793          	addi	a5,a0,26
    80005c4c:	078e                	slli	a5,a5,0x3
    80005c4e:	963e                	add	a2,a2,a5
    80005c50:	e204                	sd	s1,0(a2)
      return fd;
    80005c52:	b7f5                	j	80005c3e <fdalloc+0x2c>

0000000080005c54 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005c54:	715d                	addi	sp,sp,-80
    80005c56:	e486                	sd	ra,72(sp)
    80005c58:	e0a2                	sd	s0,64(sp)
    80005c5a:	fc26                	sd	s1,56(sp)
    80005c5c:	f84a                	sd	s2,48(sp)
    80005c5e:	f44e                	sd	s3,40(sp)
    80005c60:	f052                	sd	s4,32(sp)
    80005c62:	ec56                	sd	s5,24(sp)
    80005c64:	e85a                	sd	s6,16(sp)
    80005c66:	0880                	addi	s0,sp,80
    80005c68:	8b2e                	mv	s6,a1
    80005c6a:	89b2                	mv	s3,a2
    80005c6c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005c6e:	fb040593          	addi	a1,s0,-80
    80005c72:	fffff097          	auipc	ra,0xfffff
    80005c76:	e7e080e7          	jalr	-386(ra) # 80004af0 <nameiparent>
    80005c7a:	84aa                	mv	s1,a0
    80005c7c:	14050b63          	beqz	a0,80005dd2 <create+0x17e>
    return 0;

  ilock(dp);
    80005c80:	ffffe097          	auipc	ra,0xffffe
    80005c84:	6ac080e7          	jalr	1708(ra) # 8000432c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005c88:	4601                	li	a2,0
    80005c8a:	fb040593          	addi	a1,s0,-80
    80005c8e:	8526                	mv	a0,s1
    80005c90:	fffff097          	auipc	ra,0xfffff
    80005c94:	b80080e7          	jalr	-1152(ra) # 80004810 <dirlookup>
    80005c98:	8aaa                	mv	s5,a0
    80005c9a:	c921                	beqz	a0,80005cea <create+0x96>
    iunlockput(dp);
    80005c9c:	8526                	mv	a0,s1
    80005c9e:	fffff097          	auipc	ra,0xfffff
    80005ca2:	8f0080e7          	jalr	-1808(ra) # 8000458e <iunlockput>
    ilock(ip);
    80005ca6:	8556                	mv	a0,s5
    80005ca8:	ffffe097          	auipc	ra,0xffffe
    80005cac:	684080e7          	jalr	1668(ra) # 8000432c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005cb0:	4789                	li	a5,2
    80005cb2:	02fb1563          	bne	s6,a5,80005cdc <create+0x88>
    80005cb6:	044ad783          	lhu	a5,68(s5)
    80005cba:	37f9                	addiw	a5,a5,-2
    80005cbc:	17c2                	slli	a5,a5,0x30
    80005cbe:	93c1                	srli	a5,a5,0x30
    80005cc0:	4705                	li	a4,1
    80005cc2:	00f76d63          	bltu	a4,a5,80005cdc <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005cc6:	8556                	mv	a0,s5
    80005cc8:	60a6                	ld	ra,72(sp)
    80005cca:	6406                	ld	s0,64(sp)
    80005ccc:	74e2                	ld	s1,56(sp)
    80005cce:	7942                	ld	s2,48(sp)
    80005cd0:	79a2                	ld	s3,40(sp)
    80005cd2:	7a02                	ld	s4,32(sp)
    80005cd4:	6ae2                	ld	s5,24(sp)
    80005cd6:	6b42                	ld	s6,16(sp)
    80005cd8:	6161                	addi	sp,sp,80
    80005cda:	8082                	ret
    iunlockput(ip);
    80005cdc:	8556                	mv	a0,s5
    80005cde:	fffff097          	auipc	ra,0xfffff
    80005ce2:	8b0080e7          	jalr	-1872(ra) # 8000458e <iunlockput>
    return 0;
    80005ce6:	4a81                	li	s5,0
    80005ce8:	bff9                	j	80005cc6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005cea:	85da                	mv	a1,s6
    80005cec:	4088                	lw	a0,0(s1)
    80005cee:	ffffe097          	auipc	ra,0xffffe
    80005cf2:	4a6080e7          	jalr	1190(ra) # 80004194 <ialloc>
    80005cf6:	8a2a                	mv	s4,a0
    80005cf8:	c529                	beqz	a0,80005d42 <create+0xee>
  ilock(ip);
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	632080e7          	jalr	1586(ra) # 8000432c <ilock>
  ip->major = major;
    80005d02:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005d06:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005d0a:	4905                	li	s2,1
    80005d0c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005d10:	8552                	mv	a0,s4
    80005d12:	ffffe097          	auipc	ra,0xffffe
    80005d16:	54e080e7          	jalr	1358(ra) # 80004260 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005d1a:	032b0b63          	beq	s6,s2,80005d50 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005d1e:	004a2603          	lw	a2,4(s4)
    80005d22:	fb040593          	addi	a1,s0,-80
    80005d26:	8526                	mv	a0,s1
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	cf8080e7          	jalr	-776(ra) # 80004a20 <dirlink>
    80005d30:	06054f63          	bltz	a0,80005dae <create+0x15a>
  iunlockput(dp);
    80005d34:	8526                	mv	a0,s1
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	858080e7          	jalr	-1960(ra) # 8000458e <iunlockput>
  return ip;
    80005d3e:	8ad2                	mv	s5,s4
    80005d40:	b759                	j	80005cc6 <create+0x72>
    iunlockput(dp);
    80005d42:	8526                	mv	a0,s1
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	84a080e7          	jalr	-1974(ra) # 8000458e <iunlockput>
    return 0;
    80005d4c:	8ad2                	mv	s5,s4
    80005d4e:	bfa5                	j	80005cc6 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005d50:	004a2603          	lw	a2,4(s4)
    80005d54:	00003597          	auipc	a1,0x3
    80005d58:	ccc58593          	addi	a1,a1,-820 # 80008a20 <syscall_names+0x2c8>
    80005d5c:	8552                	mv	a0,s4
    80005d5e:	fffff097          	auipc	ra,0xfffff
    80005d62:	cc2080e7          	jalr	-830(ra) # 80004a20 <dirlink>
    80005d66:	04054463          	bltz	a0,80005dae <create+0x15a>
    80005d6a:	40d0                	lw	a2,4(s1)
    80005d6c:	00003597          	auipc	a1,0x3
    80005d70:	cbc58593          	addi	a1,a1,-836 # 80008a28 <syscall_names+0x2d0>
    80005d74:	8552                	mv	a0,s4
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	caa080e7          	jalr	-854(ra) # 80004a20 <dirlink>
    80005d7e:	02054863          	bltz	a0,80005dae <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    80005d82:	004a2603          	lw	a2,4(s4)
    80005d86:	fb040593          	addi	a1,s0,-80
    80005d8a:	8526                	mv	a0,s1
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	c94080e7          	jalr	-876(ra) # 80004a20 <dirlink>
    80005d94:	00054d63          	bltz	a0,80005dae <create+0x15a>
    dp->nlink++;  // for ".."
    80005d98:	04a4d783          	lhu	a5,74(s1)
    80005d9c:	2785                	addiw	a5,a5,1
    80005d9e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005da2:	8526                	mv	a0,s1
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	4bc080e7          	jalr	1212(ra) # 80004260 <iupdate>
    80005dac:	b761                	j	80005d34 <create+0xe0>
  ip->nlink = 0;
    80005dae:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005db2:	8552                	mv	a0,s4
    80005db4:	ffffe097          	auipc	ra,0xffffe
    80005db8:	4ac080e7          	jalr	1196(ra) # 80004260 <iupdate>
  iunlockput(ip);
    80005dbc:	8552                	mv	a0,s4
    80005dbe:	ffffe097          	auipc	ra,0xffffe
    80005dc2:	7d0080e7          	jalr	2000(ra) # 8000458e <iunlockput>
  iunlockput(dp);
    80005dc6:	8526                	mv	a0,s1
    80005dc8:	ffffe097          	auipc	ra,0xffffe
    80005dcc:	7c6080e7          	jalr	1990(ra) # 8000458e <iunlockput>
  return 0;
    80005dd0:	bddd                	j	80005cc6 <create+0x72>
    return 0;
    80005dd2:	8aaa                	mv	s5,a0
    80005dd4:	bdcd                	j	80005cc6 <create+0x72>

0000000080005dd6 <sys_dup>:
{
    80005dd6:	7179                	addi	sp,sp,-48
    80005dd8:	f406                	sd	ra,40(sp)
    80005dda:	f022                	sd	s0,32(sp)
    80005ddc:	ec26                	sd	s1,24(sp)
    80005dde:	e84a                	sd	s2,16(sp)
    80005de0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005de2:	fd840613          	addi	a2,s0,-40
    80005de6:	4581                	li	a1,0
    80005de8:	4501                	li	a0,0
    80005dea:	00000097          	auipc	ra,0x0
    80005dee:	dc8080e7          	jalr	-568(ra) # 80005bb2 <argfd>
    return -1;
    80005df2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005df4:	02054363          	bltz	a0,80005e1a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005df8:	fd843903          	ld	s2,-40(s0)
    80005dfc:	854a                	mv	a0,s2
    80005dfe:	00000097          	auipc	ra,0x0
    80005e02:	e14080e7          	jalr	-492(ra) # 80005c12 <fdalloc>
    80005e06:	84aa                	mv	s1,a0
    return -1;
    80005e08:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005e0a:	00054863          	bltz	a0,80005e1a <sys_dup+0x44>
  filedup(f);
    80005e0e:	854a                	mv	a0,s2
    80005e10:	fffff097          	auipc	ra,0xfffff
    80005e14:	334080e7          	jalr	820(ra) # 80005144 <filedup>
  return fd;
    80005e18:	87a6                	mv	a5,s1
}
    80005e1a:	853e                	mv	a0,a5
    80005e1c:	70a2                	ld	ra,40(sp)
    80005e1e:	7402                	ld	s0,32(sp)
    80005e20:	64e2                	ld	s1,24(sp)
    80005e22:	6942                	ld	s2,16(sp)
    80005e24:	6145                	addi	sp,sp,48
    80005e26:	8082                	ret

0000000080005e28 <sys_read>:
{
    80005e28:	7179                	addi	sp,sp,-48
    80005e2a:	f406                	sd	ra,40(sp)
    80005e2c:	f022                	sd	s0,32(sp)
    80005e2e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005e30:	fd840593          	addi	a1,s0,-40
    80005e34:	4505                	li	a0,1
    80005e36:	ffffd097          	auipc	ra,0xffffd
    80005e3a:	6a4080e7          	jalr	1700(ra) # 800034da <argaddr>
  argint(2, &n);
    80005e3e:	fe440593          	addi	a1,s0,-28
    80005e42:	4509                	li	a0,2
    80005e44:	ffffd097          	auipc	ra,0xffffd
    80005e48:	670080e7          	jalr	1648(ra) # 800034b4 <argint>
  if(argfd(0, 0, &f) < 0)
    80005e4c:	fe840613          	addi	a2,s0,-24
    80005e50:	4581                	li	a1,0
    80005e52:	4501                	li	a0,0
    80005e54:	00000097          	auipc	ra,0x0
    80005e58:	d5e080e7          	jalr	-674(ra) # 80005bb2 <argfd>
    80005e5c:	87aa                	mv	a5,a0
    return -1;
    80005e5e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005e60:	0007cc63          	bltz	a5,80005e78 <sys_read+0x50>
  return fileread(f, p, n);
    80005e64:	fe442603          	lw	a2,-28(s0)
    80005e68:	fd843583          	ld	a1,-40(s0)
    80005e6c:	fe843503          	ld	a0,-24(s0)
    80005e70:	fffff097          	auipc	ra,0xfffff
    80005e74:	460080e7          	jalr	1120(ra) # 800052d0 <fileread>
}
    80005e78:	70a2                	ld	ra,40(sp)
    80005e7a:	7402                	ld	s0,32(sp)
    80005e7c:	6145                	addi	sp,sp,48
    80005e7e:	8082                	ret

0000000080005e80 <sys_write>:
{
    80005e80:	7179                	addi	sp,sp,-48
    80005e82:	f406                	sd	ra,40(sp)
    80005e84:	f022                	sd	s0,32(sp)
    80005e86:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005e88:	fd840593          	addi	a1,s0,-40
    80005e8c:	4505                	li	a0,1
    80005e8e:	ffffd097          	auipc	ra,0xffffd
    80005e92:	64c080e7          	jalr	1612(ra) # 800034da <argaddr>
  argint(2, &n);
    80005e96:	fe440593          	addi	a1,s0,-28
    80005e9a:	4509                	li	a0,2
    80005e9c:	ffffd097          	auipc	ra,0xffffd
    80005ea0:	618080e7          	jalr	1560(ra) # 800034b4 <argint>
  if(argfd(0, 0, &f) < 0)
    80005ea4:	fe840613          	addi	a2,s0,-24
    80005ea8:	4581                	li	a1,0
    80005eaa:	4501                	li	a0,0
    80005eac:	00000097          	auipc	ra,0x0
    80005eb0:	d06080e7          	jalr	-762(ra) # 80005bb2 <argfd>
    80005eb4:	87aa                	mv	a5,a0
    return -1;
    80005eb6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005eb8:	0007cc63          	bltz	a5,80005ed0 <sys_write+0x50>
  return filewrite(f, p, n);
    80005ebc:	fe442603          	lw	a2,-28(s0)
    80005ec0:	fd843583          	ld	a1,-40(s0)
    80005ec4:	fe843503          	ld	a0,-24(s0)
    80005ec8:	fffff097          	auipc	ra,0xfffff
    80005ecc:	4ca080e7          	jalr	1226(ra) # 80005392 <filewrite>
}
    80005ed0:	70a2                	ld	ra,40(sp)
    80005ed2:	7402                	ld	s0,32(sp)
    80005ed4:	6145                	addi	sp,sp,48
    80005ed6:	8082                	ret

0000000080005ed8 <sys_close>:
{
    80005ed8:	1101                	addi	sp,sp,-32
    80005eda:	ec06                	sd	ra,24(sp)
    80005edc:	e822                	sd	s0,16(sp)
    80005ede:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005ee0:	fe040613          	addi	a2,s0,-32
    80005ee4:	fec40593          	addi	a1,s0,-20
    80005ee8:	4501                	li	a0,0
    80005eea:	00000097          	auipc	ra,0x0
    80005eee:	cc8080e7          	jalr	-824(ra) # 80005bb2 <argfd>
    return -1;
    80005ef2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005ef4:	02054463          	bltz	a0,80005f1c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ef8:	ffffc097          	auipc	ra,0xffffc
    80005efc:	d98080e7          	jalr	-616(ra) # 80001c90 <myproc>
    80005f00:	fec42783          	lw	a5,-20(s0)
    80005f04:	07e9                	addi	a5,a5,26
    80005f06:	078e                	slli	a5,a5,0x3
    80005f08:	953e                	add	a0,a0,a5
    80005f0a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005f0e:	fe043503          	ld	a0,-32(s0)
    80005f12:	fffff097          	auipc	ra,0xfffff
    80005f16:	284080e7          	jalr	644(ra) # 80005196 <fileclose>
  return 0;
    80005f1a:	4781                	li	a5,0
}
    80005f1c:	853e                	mv	a0,a5
    80005f1e:	60e2                	ld	ra,24(sp)
    80005f20:	6442                	ld	s0,16(sp)
    80005f22:	6105                	addi	sp,sp,32
    80005f24:	8082                	ret

0000000080005f26 <sys_fstat>:
{
    80005f26:	1101                	addi	sp,sp,-32
    80005f28:	ec06                	sd	ra,24(sp)
    80005f2a:	e822                	sd	s0,16(sp)
    80005f2c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005f2e:	fe040593          	addi	a1,s0,-32
    80005f32:	4505                	li	a0,1
    80005f34:	ffffd097          	auipc	ra,0xffffd
    80005f38:	5a6080e7          	jalr	1446(ra) # 800034da <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005f3c:	fe840613          	addi	a2,s0,-24
    80005f40:	4581                	li	a1,0
    80005f42:	4501                	li	a0,0
    80005f44:	00000097          	auipc	ra,0x0
    80005f48:	c6e080e7          	jalr	-914(ra) # 80005bb2 <argfd>
    80005f4c:	87aa                	mv	a5,a0
    return -1;
    80005f4e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005f50:	0007ca63          	bltz	a5,80005f64 <sys_fstat+0x3e>
  return filestat(f, st);
    80005f54:	fe043583          	ld	a1,-32(s0)
    80005f58:	fe843503          	ld	a0,-24(s0)
    80005f5c:	fffff097          	auipc	ra,0xfffff
    80005f60:	302080e7          	jalr	770(ra) # 8000525e <filestat>
}
    80005f64:	60e2                	ld	ra,24(sp)
    80005f66:	6442                	ld	s0,16(sp)
    80005f68:	6105                	addi	sp,sp,32
    80005f6a:	8082                	ret

0000000080005f6c <sys_link>:
{
    80005f6c:	7169                	addi	sp,sp,-304
    80005f6e:	f606                	sd	ra,296(sp)
    80005f70:	f222                	sd	s0,288(sp)
    80005f72:	ee26                	sd	s1,280(sp)
    80005f74:	ea4a                	sd	s2,272(sp)
    80005f76:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f78:	08000613          	li	a2,128
    80005f7c:	ed040593          	addi	a1,s0,-304
    80005f80:	4501                	li	a0,0
    80005f82:	ffffd097          	auipc	ra,0xffffd
    80005f86:	57a080e7          	jalr	1402(ra) # 800034fc <argstr>
    return -1;
    80005f8a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f8c:	10054e63          	bltz	a0,800060a8 <sys_link+0x13c>
    80005f90:	08000613          	li	a2,128
    80005f94:	f5040593          	addi	a1,s0,-176
    80005f98:	4505                	li	a0,1
    80005f9a:	ffffd097          	auipc	ra,0xffffd
    80005f9e:	562080e7          	jalr	1378(ra) # 800034fc <argstr>
    return -1;
    80005fa2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005fa4:	10054263          	bltz	a0,800060a8 <sys_link+0x13c>
  begin_op();
    80005fa8:	fffff097          	auipc	ra,0xfffff
    80005fac:	d2a080e7          	jalr	-726(ra) # 80004cd2 <begin_op>
  if((ip = namei(old)) == 0){
    80005fb0:	ed040513          	addi	a0,s0,-304
    80005fb4:	fffff097          	auipc	ra,0xfffff
    80005fb8:	b1e080e7          	jalr	-1250(ra) # 80004ad2 <namei>
    80005fbc:	84aa                	mv	s1,a0
    80005fbe:	c551                	beqz	a0,8000604a <sys_link+0xde>
  ilock(ip);
    80005fc0:	ffffe097          	auipc	ra,0xffffe
    80005fc4:	36c080e7          	jalr	876(ra) # 8000432c <ilock>
  if(ip->type == T_DIR){
    80005fc8:	04449703          	lh	a4,68(s1)
    80005fcc:	4785                	li	a5,1
    80005fce:	08f70463          	beq	a4,a5,80006056 <sys_link+0xea>
  ip->nlink++;
    80005fd2:	04a4d783          	lhu	a5,74(s1)
    80005fd6:	2785                	addiw	a5,a5,1
    80005fd8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005fdc:	8526                	mv	a0,s1
    80005fde:	ffffe097          	auipc	ra,0xffffe
    80005fe2:	282080e7          	jalr	642(ra) # 80004260 <iupdate>
  iunlock(ip);
    80005fe6:	8526                	mv	a0,s1
    80005fe8:	ffffe097          	auipc	ra,0xffffe
    80005fec:	406080e7          	jalr	1030(ra) # 800043ee <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005ff0:	fd040593          	addi	a1,s0,-48
    80005ff4:	f5040513          	addi	a0,s0,-176
    80005ff8:	fffff097          	auipc	ra,0xfffff
    80005ffc:	af8080e7          	jalr	-1288(ra) # 80004af0 <nameiparent>
    80006000:	892a                	mv	s2,a0
    80006002:	c935                	beqz	a0,80006076 <sys_link+0x10a>
  ilock(dp);
    80006004:	ffffe097          	auipc	ra,0xffffe
    80006008:	328080e7          	jalr	808(ra) # 8000432c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000600c:	00092703          	lw	a4,0(s2)
    80006010:	409c                	lw	a5,0(s1)
    80006012:	04f71d63          	bne	a4,a5,8000606c <sys_link+0x100>
    80006016:	40d0                	lw	a2,4(s1)
    80006018:	fd040593          	addi	a1,s0,-48
    8000601c:	854a                	mv	a0,s2
    8000601e:	fffff097          	auipc	ra,0xfffff
    80006022:	a02080e7          	jalr	-1534(ra) # 80004a20 <dirlink>
    80006026:	04054363          	bltz	a0,8000606c <sys_link+0x100>
  iunlockput(dp);
    8000602a:	854a                	mv	a0,s2
    8000602c:	ffffe097          	auipc	ra,0xffffe
    80006030:	562080e7          	jalr	1378(ra) # 8000458e <iunlockput>
  iput(ip);
    80006034:	8526                	mv	a0,s1
    80006036:	ffffe097          	auipc	ra,0xffffe
    8000603a:	4b0080e7          	jalr	1200(ra) # 800044e6 <iput>
  end_op();
    8000603e:	fffff097          	auipc	ra,0xfffff
    80006042:	d0e080e7          	jalr	-754(ra) # 80004d4c <end_op>
  return 0;
    80006046:	4781                	li	a5,0
    80006048:	a085                	j	800060a8 <sys_link+0x13c>
    end_op();
    8000604a:	fffff097          	auipc	ra,0xfffff
    8000604e:	d02080e7          	jalr	-766(ra) # 80004d4c <end_op>
    return -1;
    80006052:	57fd                	li	a5,-1
    80006054:	a891                	j	800060a8 <sys_link+0x13c>
    iunlockput(ip);
    80006056:	8526                	mv	a0,s1
    80006058:	ffffe097          	auipc	ra,0xffffe
    8000605c:	536080e7          	jalr	1334(ra) # 8000458e <iunlockput>
    end_op();
    80006060:	fffff097          	auipc	ra,0xfffff
    80006064:	cec080e7          	jalr	-788(ra) # 80004d4c <end_op>
    return -1;
    80006068:	57fd                	li	a5,-1
    8000606a:	a83d                	j	800060a8 <sys_link+0x13c>
    iunlockput(dp);
    8000606c:	854a                	mv	a0,s2
    8000606e:	ffffe097          	auipc	ra,0xffffe
    80006072:	520080e7          	jalr	1312(ra) # 8000458e <iunlockput>
  ilock(ip);
    80006076:	8526                	mv	a0,s1
    80006078:	ffffe097          	auipc	ra,0xffffe
    8000607c:	2b4080e7          	jalr	692(ra) # 8000432c <ilock>
  ip->nlink--;
    80006080:	04a4d783          	lhu	a5,74(s1)
    80006084:	37fd                	addiw	a5,a5,-1
    80006086:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000608a:	8526                	mv	a0,s1
    8000608c:	ffffe097          	auipc	ra,0xffffe
    80006090:	1d4080e7          	jalr	468(ra) # 80004260 <iupdate>
  iunlockput(ip);
    80006094:	8526                	mv	a0,s1
    80006096:	ffffe097          	auipc	ra,0xffffe
    8000609a:	4f8080e7          	jalr	1272(ra) # 8000458e <iunlockput>
  end_op();
    8000609e:	fffff097          	auipc	ra,0xfffff
    800060a2:	cae080e7          	jalr	-850(ra) # 80004d4c <end_op>
  return -1;
    800060a6:	57fd                	li	a5,-1
}
    800060a8:	853e                	mv	a0,a5
    800060aa:	70b2                	ld	ra,296(sp)
    800060ac:	7412                	ld	s0,288(sp)
    800060ae:	64f2                	ld	s1,280(sp)
    800060b0:	6952                	ld	s2,272(sp)
    800060b2:	6155                	addi	sp,sp,304
    800060b4:	8082                	ret

00000000800060b6 <sys_unlink>:
{
    800060b6:	7151                	addi	sp,sp,-240
    800060b8:	f586                	sd	ra,232(sp)
    800060ba:	f1a2                	sd	s0,224(sp)
    800060bc:	eda6                	sd	s1,216(sp)
    800060be:	e9ca                	sd	s2,208(sp)
    800060c0:	e5ce                	sd	s3,200(sp)
    800060c2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800060c4:	08000613          	li	a2,128
    800060c8:	f3040593          	addi	a1,s0,-208
    800060cc:	4501                	li	a0,0
    800060ce:	ffffd097          	auipc	ra,0xffffd
    800060d2:	42e080e7          	jalr	1070(ra) # 800034fc <argstr>
    800060d6:	18054163          	bltz	a0,80006258 <sys_unlink+0x1a2>
  begin_op();
    800060da:	fffff097          	auipc	ra,0xfffff
    800060de:	bf8080e7          	jalr	-1032(ra) # 80004cd2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800060e2:	fb040593          	addi	a1,s0,-80
    800060e6:	f3040513          	addi	a0,s0,-208
    800060ea:	fffff097          	auipc	ra,0xfffff
    800060ee:	a06080e7          	jalr	-1530(ra) # 80004af0 <nameiparent>
    800060f2:	84aa                	mv	s1,a0
    800060f4:	c979                	beqz	a0,800061ca <sys_unlink+0x114>
  ilock(dp);
    800060f6:	ffffe097          	auipc	ra,0xffffe
    800060fa:	236080e7          	jalr	566(ra) # 8000432c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800060fe:	00003597          	auipc	a1,0x3
    80006102:	92258593          	addi	a1,a1,-1758 # 80008a20 <syscall_names+0x2c8>
    80006106:	fb040513          	addi	a0,s0,-80
    8000610a:	ffffe097          	auipc	ra,0xffffe
    8000610e:	6ec080e7          	jalr	1772(ra) # 800047f6 <namecmp>
    80006112:	14050a63          	beqz	a0,80006266 <sys_unlink+0x1b0>
    80006116:	00003597          	auipc	a1,0x3
    8000611a:	91258593          	addi	a1,a1,-1774 # 80008a28 <syscall_names+0x2d0>
    8000611e:	fb040513          	addi	a0,s0,-80
    80006122:	ffffe097          	auipc	ra,0xffffe
    80006126:	6d4080e7          	jalr	1748(ra) # 800047f6 <namecmp>
    8000612a:	12050e63          	beqz	a0,80006266 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000612e:	f2c40613          	addi	a2,s0,-212
    80006132:	fb040593          	addi	a1,s0,-80
    80006136:	8526                	mv	a0,s1
    80006138:	ffffe097          	auipc	ra,0xffffe
    8000613c:	6d8080e7          	jalr	1752(ra) # 80004810 <dirlookup>
    80006140:	892a                	mv	s2,a0
    80006142:	12050263          	beqz	a0,80006266 <sys_unlink+0x1b0>
  ilock(ip);
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	1e6080e7          	jalr	486(ra) # 8000432c <ilock>
  if(ip->nlink < 1)
    8000614e:	04a91783          	lh	a5,74(s2)
    80006152:	08f05263          	blez	a5,800061d6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006156:	04491703          	lh	a4,68(s2)
    8000615a:	4785                	li	a5,1
    8000615c:	08f70563          	beq	a4,a5,800061e6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006160:	4641                	li	a2,16
    80006162:	4581                	li	a1,0
    80006164:	fc040513          	addi	a0,s0,-64
    80006168:	ffffb097          	auipc	ra,0xffffb
    8000616c:	dae080e7          	jalr	-594(ra) # 80000f16 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006170:	4741                	li	a4,16
    80006172:	f2c42683          	lw	a3,-212(s0)
    80006176:	fc040613          	addi	a2,s0,-64
    8000617a:	4581                	li	a1,0
    8000617c:	8526                	mv	a0,s1
    8000617e:	ffffe097          	auipc	ra,0xffffe
    80006182:	55a080e7          	jalr	1370(ra) # 800046d8 <writei>
    80006186:	47c1                	li	a5,16
    80006188:	0af51563          	bne	a0,a5,80006232 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000618c:	04491703          	lh	a4,68(s2)
    80006190:	4785                	li	a5,1
    80006192:	0af70863          	beq	a4,a5,80006242 <sys_unlink+0x18c>
  iunlockput(dp);
    80006196:	8526                	mv	a0,s1
    80006198:	ffffe097          	auipc	ra,0xffffe
    8000619c:	3f6080e7          	jalr	1014(ra) # 8000458e <iunlockput>
  ip->nlink--;
    800061a0:	04a95783          	lhu	a5,74(s2)
    800061a4:	37fd                	addiw	a5,a5,-1
    800061a6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800061aa:	854a                	mv	a0,s2
    800061ac:	ffffe097          	auipc	ra,0xffffe
    800061b0:	0b4080e7          	jalr	180(ra) # 80004260 <iupdate>
  iunlockput(ip);
    800061b4:	854a                	mv	a0,s2
    800061b6:	ffffe097          	auipc	ra,0xffffe
    800061ba:	3d8080e7          	jalr	984(ra) # 8000458e <iunlockput>
  end_op();
    800061be:	fffff097          	auipc	ra,0xfffff
    800061c2:	b8e080e7          	jalr	-1138(ra) # 80004d4c <end_op>
  return 0;
    800061c6:	4501                	li	a0,0
    800061c8:	a84d                	j	8000627a <sys_unlink+0x1c4>
    end_op();
    800061ca:	fffff097          	auipc	ra,0xfffff
    800061ce:	b82080e7          	jalr	-1150(ra) # 80004d4c <end_op>
    return -1;
    800061d2:	557d                	li	a0,-1
    800061d4:	a05d                	j	8000627a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800061d6:	00003517          	auipc	a0,0x3
    800061da:	85a50513          	addi	a0,a0,-1958 # 80008a30 <syscall_names+0x2d8>
    800061de:	ffffa097          	auipc	ra,0xffffa
    800061e2:	35e080e7          	jalr	862(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061e6:	04c92703          	lw	a4,76(s2)
    800061ea:	02000793          	li	a5,32
    800061ee:	f6e7f9e3          	bgeu	a5,a4,80006160 <sys_unlink+0xaa>
    800061f2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800061f6:	4741                	li	a4,16
    800061f8:	86ce                	mv	a3,s3
    800061fa:	f1840613          	addi	a2,s0,-232
    800061fe:	4581                	li	a1,0
    80006200:	854a                	mv	a0,s2
    80006202:	ffffe097          	auipc	ra,0xffffe
    80006206:	3de080e7          	jalr	990(ra) # 800045e0 <readi>
    8000620a:	47c1                	li	a5,16
    8000620c:	00f51b63          	bne	a0,a5,80006222 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006210:	f1845783          	lhu	a5,-232(s0)
    80006214:	e7a1                	bnez	a5,8000625c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006216:	29c1                	addiw	s3,s3,16
    80006218:	04c92783          	lw	a5,76(s2)
    8000621c:	fcf9ede3          	bltu	s3,a5,800061f6 <sys_unlink+0x140>
    80006220:	b781                	j	80006160 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006222:	00003517          	auipc	a0,0x3
    80006226:	82650513          	addi	a0,a0,-2010 # 80008a48 <syscall_names+0x2f0>
    8000622a:	ffffa097          	auipc	ra,0xffffa
    8000622e:	312080e7          	jalr	786(ra) # 8000053c <panic>
    panic("unlink: writei");
    80006232:	00003517          	auipc	a0,0x3
    80006236:	82e50513          	addi	a0,a0,-2002 # 80008a60 <syscall_names+0x308>
    8000623a:	ffffa097          	auipc	ra,0xffffa
    8000623e:	302080e7          	jalr	770(ra) # 8000053c <panic>
    dp->nlink--;
    80006242:	04a4d783          	lhu	a5,74(s1)
    80006246:	37fd                	addiw	a5,a5,-1
    80006248:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000624c:	8526                	mv	a0,s1
    8000624e:	ffffe097          	auipc	ra,0xffffe
    80006252:	012080e7          	jalr	18(ra) # 80004260 <iupdate>
    80006256:	b781                	j	80006196 <sys_unlink+0xe0>
    return -1;
    80006258:	557d                	li	a0,-1
    8000625a:	a005                	j	8000627a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000625c:	854a                	mv	a0,s2
    8000625e:	ffffe097          	auipc	ra,0xffffe
    80006262:	330080e7          	jalr	816(ra) # 8000458e <iunlockput>
  iunlockput(dp);
    80006266:	8526                	mv	a0,s1
    80006268:	ffffe097          	auipc	ra,0xffffe
    8000626c:	326080e7          	jalr	806(ra) # 8000458e <iunlockput>
  end_op();
    80006270:	fffff097          	auipc	ra,0xfffff
    80006274:	adc080e7          	jalr	-1316(ra) # 80004d4c <end_op>
  return -1;
    80006278:	557d                	li	a0,-1
}
    8000627a:	70ae                	ld	ra,232(sp)
    8000627c:	740e                	ld	s0,224(sp)
    8000627e:	64ee                	ld	s1,216(sp)
    80006280:	694e                	ld	s2,208(sp)
    80006282:	69ae                	ld	s3,200(sp)
    80006284:	616d                	addi	sp,sp,240
    80006286:	8082                	ret

0000000080006288 <sys_open>:

uint64
sys_open(void)
{
    80006288:	7131                	addi	sp,sp,-192
    8000628a:	fd06                	sd	ra,184(sp)
    8000628c:	f922                	sd	s0,176(sp)
    8000628e:	f526                	sd	s1,168(sp)
    80006290:	f14a                	sd	s2,160(sp)
    80006292:	ed4e                	sd	s3,152(sp)
    80006294:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80006296:	f4c40593          	addi	a1,s0,-180
    8000629a:	4505                	li	a0,1
    8000629c:	ffffd097          	auipc	ra,0xffffd
    800062a0:	218080e7          	jalr	536(ra) # 800034b4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800062a4:	08000613          	li	a2,128
    800062a8:	f5040593          	addi	a1,s0,-176
    800062ac:	4501                	li	a0,0
    800062ae:	ffffd097          	auipc	ra,0xffffd
    800062b2:	24e080e7          	jalr	590(ra) # 800034fc <argstr>
    800062b6:	87aa                	mv	a5,a0
    return -1;
    800062b8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800062ba:	0a07c863          	bltz	a5,8000636a <sys_open+0xe2>

  begin_op();
    800062be:	fffff097          	auipc	ra,0xfffff
    800062c2:	a14080e7          	jalr	-1516(ra) # 80004cd2 <begin_op>

  if(omode & O_CREATE){
    800062c6:	f4c42783          	lw	a5,-180(s0)
    800062ca:	2007f793          	andi	a5,a5,512
    800062ce:	cbdd                	beqz	a5,80006384 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    800062d0:	4681                	li	a3,0
    800062d2:	4601                	li	a2,0
    800062d4:	4589                	li	a1,2
    800062d6:	f5040513          	addi	a0,s0,-176
    800062da:	00000097          	auipc	ra,0x0
    800062de:	97a080e7          	jalr	-1670(ra) # 80005c54 <create>
    800062e2:	84aa                	mv	s1,a0
    if(ip == 0){
    800062e4:	c951                	beqz	a0,80006378 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800062e6:	04449703          	lh	a4,68(s1)
    800062ea:	478d                	li	a5,3
    800062ec:	00f71763          	bne	a4,a5,800062fa <sys_open+0x72>
    800062f0:	0464d703          	lhu	a4,70(s1)
    800062f4:	47a5                	li	a5,9
    800062f6:	0ce7ec63          	bltu	a5,a4,800063ce <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800062fa:	fffff097          	auipc	ra,0xfffff
    800062fe:	de0080e7          	jalr	-544(ra) # 800050da <filealloc>
    80006302:	892a                	mv	s2,a0
    80006304:	c56d                	beqz	a0,800063ee <sys_open+0x166>
    80006306:	00000097          	auipc	ra,0x0
    8000630a:	90c080e7          	jalr	-1780(ra) # 80005c12 <fdalloc>
    8000630e:	89aa                	mv	s3,a0
    80006310:	0c054a63          	bltz	a0,800063e4 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006314:	04449703          	lh	a4,68(s1)
    80006318:	478d                	li	a5,3
    8000631a:	0ef70563          	beq	a4,a5,80006404 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000631e:	4789                	li	a5,2
    80006320:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80006324:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006328:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000632c:	f4c42783          	lw	a5,-180(s0)
    80006330:	0017c713          	xori	a4,a5,1
    80006334:	8b05                	andi	a4,a4,1
    80006336:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000633a:	0037f713          	andi	a4,a5,3
    8000633e:	00e03733          	snez	a4,a4
    80006342:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006346:	4007f793          	andi	a5,a5,1024
    8000634a:	c791                	beqz	a5,80006356 <sys_open+0xce>
    8000634c:	04449703          	lh	a4,68(s1)
    80006350:	4789                	li	a5,2
    80006352:	0cf70063          	beq	a4,a5,80006412 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80006356:	8526                	mv	a0,s1
    80006358:	ffffe097          	auipc	ra,0xffffe
    8000635c:	096080e7          	jalr	150(ra) # 800043ee <iunlock>
  end_op();
    80006360:	fffff097          	auipc	ra,0xfffff
    80006364:	9ec080e7          	jalr	-1556(ra) # 80004d4c <end_op>

  return fd;
    80006368:	854e                	mv	a0,s3
}
    8000636a:	70ea                	ld	ra,184(sp)
    8000636c:	744a                	ld	s0,176(sp)
    8000636e:	74aa                	ld	s1,168(sp)
    80006370:	790a                	ld	s2,160(sp)
    80006372:	69ea                	ld	s3,152(sp)
    80006374:	6129                	addi	sp,sp,192
    80006376:	8082                	ret
      end_op();
    80006378:	fffff097          	auipc	ra,0xfffff
    8000637c:	9d4080e7          	jalr	-1580(ra) # 80004d4c <end_op>
      return -1;
    80006380:	557d                	li	a0,-1
    80006382:	b7e5                	j	8000636a <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80006384:	f5040513          	addi	a0,s0,-176
    80006388:	ffffe097          	auipc	ra,0xffffe
    8000638c:	74a080e7          	jalr	1866(ra) # 80004ad2 <namei>
    80006390:	84aa                	mv	s1,a0
    80006392:	c905                	beqz	a0,800063c2 <sys_open+0x13a>
    ilock(ip);
    80006394:	ffffe097          	auipc	ra,0xffffe
    80006398:	f98080e7          	jalr	-104(ra) # 8000432c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000639c:	04449703          	lh	a4,68(s1)
    800063a0:	4785                	li	a5,1
    800063a2:	f4f712e3          	bne	a4,a5,800062e6 <sys_open+0x5e>
    800063a6:	f4c42783          	lw	a5,-180(s0)
    800063aa:	dba1                	beqz	a5,800062fa <sys_open+0x72>
      iunlockput(ip);
    800063ac:	8526                	mv	a0,s1
    800063ae:	ffffe097          	auipc	ra,0xffffe
    800063b2:	1e0080e7          	jalr	480(ra) # 8000458e <iunlockput>
      end_op();
    800063b6:	fffff097          	auipc	ra,0xfffff
    800063ba:	996080e7          	jalr	-1642(ra) # 80004d4c <end_op>
      return -1;
    800063be:	557d                	li	a0,-1
    800063c0:	b76d                	j	8000636a <sys_open+0xe2>
      end_op();
    800063c2:	fffff097          	auipc	ra,0xfffff
    800063c6:	98a080e7          	jalr	-1654(ra) # 80004d4c <end_op>
      return -1;
    800063ca:	557d                	li	a0,-1
    800063cc:	bf79                	j	8000636a <sys_open+0xe2>
    iunlockput(ip);
    800063ce:	8526                	mv	a0,s1
    800063d0:	ffffe097          	auipc	ra,0xffffe
    800063d4:	1be080e7          	jalr	446(ra) # 8000458e <iunlockput>
    end_op();
    800063d8:	fffff097          	auipc	ra,0xfffff
    800063dc:	974080e7          	jalr	-1676(ra) # 80004d4c <end_op>
    return -1;
    800063e0:	557d                	li	a0,-1
    800063e2:	b761                	j	8000636a <sys_open+0xe2>
      fileclose(f);
    800063e4:	854a                	mv	a0,s2
    800063e6:	fffff097          	auipc	ra,0xfffff
    800063ea:	db0080e7          	jalr	-592(ra) # 80005196 <fileclose>
    iunlockput(ip);
    800063ee:	8526                	mv	a0,s1
    800063f0:	ffffe097          	auipc	ra,0xffffe
    800063f4:	19e080e7          	jalr	414(ra) # 8000458e <iunlockput>
    end_op();
    800063f8:	fffff097          	auipc	ra,0xfffff
    800063fc:	954080e7          	jalr	-1708(ra) # 80004d4c <end_op>
    return -1;
    80006400:	557d                	li	a0,-1
    80006402:	b7a5                	j	8000636a <sys_open+0xe2>
    f->type = FD_DEVICE;
    80006404:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006408:	04649783          	lh	a5,70(s1)
    8000640c:	02f91223          	sh	a5,36(s2)
    80006410:	bf21                	j	80006328 <sys_open+0xa0>
    itrunc(ip);
    80006412:	8526                	mv	a0,s1
    80006414:	ffffe097          	auipc	ra,0xffffe
    80006418:	026080e7          	jalr	38(ra) # 8000443a <itrunc>
    8000641c:	bf2d                	j	80006356 <sys_open+0xce>

000000008000641e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000641e:	7175                	addi	sp,sp,-144
    80006420:	e506                	sd	ra,136(sp)
    80006422:	e122                	sd	s0,128(sp)
    80006424:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006426:	fffff097          	auipc	ra,0xfffff
    8000642a:	8ac080e7          	jalr	-1876(ra) # 80004cd2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000642e:	08000613          	li	a2,128
    80006432:	f7040593          	addi	a1,s0,-144
    80006436:	4501                	li	a0,0
    80006438:	ffffd097          	auipc	ra,0xffffd
    8000643c:	0c4080e7          	jalr	196(ra) # 800034fc <argstr>
    80006440:	02054963          	bltz	a0,80006472 <sys_mkdir+0x54>
    80006444:	4681                	li	a3,0
    80006446:	4601                	li	a2,0
    80006448:	4585                	li	a1,1
    8000644a:	f7040513          	addi	a0,s0,-144
    8000644e:	00000097          	auipc	ra,0x0
    80006452:	806080e7          	jalr	-2042(ra) # 80005c54 <create>
    80006456:	cd11                	beqz	a0,80006472 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006458:	ffffe097          	auipc	ra,0xffffe
    8000645c:	136080e7          	jalr	310(ra) # 8000458e <iunlockput>
  end_op();
    80006460:	fffff097          	auipc	ra,0xfffff
    80006464:	8ec080e7          	jalr	-1812(ra) # 80004d4c <end_op>
  return 0;
    80006468:	4501                	li	a0,0
}
    8000646a:	60aa                	ld	ra,136(sp)
    8000646c:	640a                	ld	s0,128(sp)
    8000646e:	6149                	addi	sp,sp,144
    80006470:	8082                	ret
    end_op();
    80006472:	fffff097          	auipc	ra,0xfffff
    80006476:	8da080e7          	jalr	-1830(ra) # 80004d4c <end_op>
    return -1;
    8000647a:	557d                	li	a0,-1
    8000647c:	b7fd                	j	8000646a <sys_mkdir+0x4c>

000000008000647e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000647e:	7135                	addi	sp,sp,-160
    80006480:	ed06                	sd	ra,152(sp)
    80006482:	e922                	sd	s0,144(sp)
    80006484:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006486:	fffff097          	auipc	ra,0xfffff
    8000648a:	84c080e7          	jalr	-1972(ra) # 80004cd2 <begin_op>
  argint(1, &major);
    8000648e:	f6c40593          	addi	a1,s0,-148
    80006492:	4505                	li	a0,1
    80006494:	ffffd097          	auipc	ra,0xffffd
    80006498:	020080e7          	jalr	32(ra) # 800034b4 <argint>
  argint(2, &minor);
    8000649c:	f6840593          	addi	a1,s0,-152
    800064a0:	4509                	li	a0,2
    800064a2:	ffffd097          	auipc	ra,0xffffd
    800064a6:	012080e7          	jalr	18(ra) # 800034b4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800064aa:	08000613          	li	a2,128
    800064ae:	f7040593          	addi	a1,s0,-144
    800064b2:	4501                	li	a0,0
    800064b4:	ffffd097          	auipc	ra,0xffffd
    800064b8:	048080e7          	jalr	72(ra) # 800034fc <argstr>
    800064bc:	02054b63          	bltz	a0,800064f2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800064c0:	f6841683          	lh	a3,-152(s0)
    800064c4:	f6c41603          	lh	a2,-148(s0)
    800064c8:	458d                	li	a1,3
    800064ca:	f7040513          	addi	a0,s0,-144
    800064ce:	fffff097          	auipc	ra,0xfffff
    800064d2:	786080e7          	jalr	1926(ra) # 80005c54 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800064d6:	cd11                	beqz	a0,800064f2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800064d8:	ffffe097          	auipc	ra,0xffffe
    800064dc:	0b6080e7          	jalr	182(ra) # 8000458e <iunlockput>
  end_op();
    800064e0:	fffff097          	auipc	ra,0xfffff
    800064e4:	86c080e7          	jalr	-1940(ra) # 80004d4c <end_op>
  return 0;
    800064e8:	4501                	li	a0,0
}
    800064ea:	60ea                	ld	ra,152(sp)
    800064ec:	644a                	ld	s0,144(sp)
    800064ee:	610d                	addi	sp,sp,160
    800064f0:	8082                	ret
    end_op();
    800064f2:	fffff097          	auipc	ra,0xfffff
    800064f6:	85a080e7          	jalr	-1958(ra) # 80004d4c <end_op>
    return -1;
    800064fa:	557d                	li	a0,-1
    800064fc:	b7fd                	j	800064ea <sys_mknod+0x6c>

00000000800064fe <sys_chdir>:

uint64
sys_chdir(void)
{
    800064fe:	7135                	addi	sp,sp,-160
    80006500:	ed06                	sd	ra,152(sp)
    80006502:	e922                	sd	s0,144(sp)
    80006504:	e526                	sd	s1,136(sp)
    80006506:	e14a                	sd	s2,128(sp)
    80006508:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000650a:	ffffb097          	auipc	ra,0xffffb
    8000650e:	786080e7          	jalr	1926(ra) # 80001c90 <myproc>
    80006512:	892a                	mv	s2,a0
  
  begin_op();
    80006514:	ffffe097          	auipc	ra,0xffffe
    80006518:	7be080e7          	jalr	1982(ra) # 80004cd2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000651c:	08000613          	li	a2,128
    80006520:	f6040593          	addi	a1,s0,-160
    80006524:	4501                	li	a0,0
    80006526:	ffffd097          	auipc	ra,0xffffd
    8000652a:	fd6080e7          	jalr	-42(ra) # 800034fc <argstr>
    8000652e:	04054b63          	bltz	a0,80006584 <sys_chdir+0x86>
    80006532:	f6040513          	addi	a0,s0,-160
    80006536:	ffffe097          	auipc	ra,0xffffe
    8000653a:	59c080e7          	jalr	1436(ra) # 80004ad2 <namei>
    8000653e:	84aa                	mv	s1,a0
    80006540:	c131                	beqz	a0,80006584 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006542:	ffffe097          	auipc	ra,0xffffe
    80006546:	dea080e7          	jalr	-534(ra) # 8000432c <ilock>
  if(ip->type != T_DIR){
    8000654a:	04449703          	lh	a4,68(s1)
    8000654e:	4785                	li	a5,1
    80006550:	04f71063          	bne	a4,a5,80006590 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006554:	8526                	mv	a0,s1
    80006556:	ffffe097          	auipc	ra,0xffffe
    8000655a:	e98080e7          	jalr	-360(ra) # 800043ee <iunlock>
  iput(p->cwd);
    8000655e:	15093503          	ld	a0,336(s2)
    80006562:	ffffe097          	auipc	ra,0xffffe
    80006566:	f84080e7          	jalr	-124(ra) # 800044e6 <iput>
  end_op();
    8000656a:	ffffe097          	auipc	ra,0xffffe
    8000656e:	7e2080e7          	jalr	2018(ra) # 80004d4c <end_op>
  p->cwd = ip;
    80006572:	14993823          	sd	s1,336(s2)
  return 0;
    80006576:	4501                	li	a0,0
}
    80006578:	60ea                	ld	ra,152(sp)
    8000657a:	644a                	ld	s0,144(sp)
    8000657c:	64aa                	ld	s1,136(sp)
    8000657e:	690a                	ld	s2,128(sp)
    80006580:	610d                	addi	sp,sp,160
    80006582:	8082                	ret
    end_op();
    80006584:	ffffe097          	auipc	ra,0xffffe
    80006588:	7c8080e7          	jalr	1992(ra) # 80004d4c <end_op>
    return -1;
    8000658c:	557d                	li	a0,-1
    8000658e:	b7ed                	j	80006578 <sys_chdir+0x7a>
    iunlockput(ip);
    80006590:	8526                	mv	a0,s1
    80006592:	ffffe097          	auipc	ra,0xffffe
    80006596:	ffc080e7          	jalr	-4(ra) # 8000458e <iunlockput>
    end_op();
    8000659a:	ffffe097          	auipc	ra,0xffffe
    8000659e:	7b2080e7          	jalr	1970(ra) # 80004d4c <end_op>
    return -1;
    800065a2:	557d                	li	a0,-1
    800065a4:	bfd1                	j	80006578 <sys_chdir+0x7a>

00000000800065a6 <sys_exec>:

uint64
sys_exec(void)
{
    800065a6:	7121                	addi	sp,sp,-448
    800065a8:	ff06                	sd	ra,440(sp)
    800065aa:	fb22                	sd	s0,432(sp)
    800065ac:	f726                	sd	s1,424(sp)
    800065ae:	f34a                	sd	s2,416(sp)
    800065b0:	ef4e                	sd	s3,408(sp)
    800065b2:	eb52                	sd	s4,400(sp)
    800065b4:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800065b6:	e4840593          	addi	a1,s0,-440
    800065ba:	4505                	li	a0,1
    800065bc:	ffffd097          	auipc	ra,0xffffd
    800065c0:	f1e080e7          	jalr	-226(ra) # 800034da <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800065c4:	08000613          	li	a2,128
    800065c8:	f5040593          	addi	a1,s0,-176
    800065cc:	4501                	li	a0,0
    800065ce:	ffffd097          	auipc	ra,0xffffd
    800065d2:	f2e080e7          	jalr	-210(ra) # 800034fc <argstr>
    800065d6:	87aa                	mv	a5,a0
    return -1;
    800065d8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800065da:	0c07c263          	bltz	a5,8000669e <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    800065de:	10000613          	li	a2,256
    800065e2:	4581                	li	a1,0
    800065e4:	e5040513          	addi	a0,s0,-432
    800065e8:	ffffb097          	auipc	ra,0xffffb
    800065ec:	92e080e7          	jalr	-1746(ra) # 80000f16 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800065f0:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800065f4:	89a6                	mv	s3,s1
    800065f6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800065f8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800065fc:	00391513          	slli	a0,s2,0x3
    80006600:	e4040593          	addi	a1,s0,-448
    80006604:	e4843783          	ld	a5,-440(s0)
    80006608:	953e                	add	a0,a0,a5
    8000660a:	ffffd097          	auipc	ra,0xffffd
    8000660e:	e0c080e7          	jalr	-500(ra) # 80003416 <fetchaddr>
    80006612:	02054a63          	bltz	a0,80006646 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80006616:	e4043783          	ld	a5,-448(s0)
    8000661a:	c3b9                	beqz	a5,80006660 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000661c:	ffffa097          	auipc	ra,0xffffa
    80006620:	61c080e7          	jalr	1564(ra) # 80000c38 <kalloc>
    80006624:	85aa                	mv	a1,a0
    80006626:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000662a:	cd11                	beqz	a0,80006646 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000662c:	6605                	lui	a2,0x1
    8000662e:	e4043503          	ld	a0,-448(s0)
    80006632:	ffffd097          	auipc	ra,0xffffd
    80006636:	e36080e7          	jalr	-458(ra) # 80003468 <fetchstr>
    8000663a:	00054663          	bltz	a0,80006646 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    8000663e:	0905                	addi	s2,s2,1
    80006640:	09a1                	addi	s3,s3,8
    80006642:	fb491de3          	bne	s2,s4,800065fc <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006646:	f5040913          	addi	s2,s0,-176
    8000664a:	6088                	ld	a0,0(s1)
    8000664c:	c921                	beqz	a0,8000669c <sys_exec+0xf6>
    kfree(argv[i]);
    8000664e:	ffffa097          	auipc	ra,0xffffa
    80006652:	396080e7          	jalr	918(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006656:	04a1                	addi	s1,s1,8
    80006658:	ff2499e3          	bne	s1,s2,8000664a <sys_exec+0xa4>
  return -1;
    8000665c:	557d                	li	a0,-1
    8000665e:	a081                	j	8000669e <sys_exec+0xf8>
      argv[i] = 0;
    80006660:	0009079b          	sext.w	a5,s2
    80006664:	078e                	slli	a5,a5,0x3
    80006666:	fd078793          	addi	a5,a5,-48
    8000666a:	97a2                	add	a5,a5,s0
    8000666c:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80006670:	e5040593          	addi	a1,s0,-432
    80006674:	f5040513          	addi	a0,s0,-176
    80006678:	fffff097          	auipc	ra,0xfffff
    8000667c:	194080e7          	jalr	404(ra) # 8000580c <exec>
    80006680:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006682:	f5040993          	addi	s3,s0,-176
    80006686:	6088                	ld	a0,0(s1)
    80006688:	c901                	beqz	a0,80006698 <sys_exec+0xf2>
    kfree(argv[i]);
    8000668a:	ffffa097          	auipc	ra,0xffffa
    8000668e:	35a080e7          	jalr	858(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006692:	04a1                	addi	s1,s1,8
    80006694:	ff3499e3          	bne	s1,s3,80006686 <sys_exec+0xe0>
  return ret;
    80006698:	854a                	mv	a0,s2
    8000669a:	a011                	j	8000669e <sys_exec+0xf8>
  return -1;
    8000669c:	557d                	li	a0,-1
}
    8000669e:	70fa                	ld	ra,440(sp)
    800066a0:	745a                	ld	s0,432(sp)
    800066a2:	74ba                	ld	s1,424(sp)
    800066a4:	791a                	ld	s2,416(sp)
    800066a6:	69fa                	ld	s3,408(sp)
    800066a8:	6a5a                	ld	s4,400(sp)
    800066aa:	6139                	addi	sp,sp,448
    800066ac:	8082                	ret

00000000800066ae <sys_pipe>:

uint64
sys_pipe(void)
{
    800066ae:	7139                	addi	sp,sp,-64
    800066b0:	fc06                	sd	ra,56(sp)
    800066b2:	f822                	sd	s0,48(sp)
    800066b4:	f426                	sd	s1,40(sp)
    800066b6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800066b8:	ffffb097          	auipc	ra,0xffffb
    800066bc:	5d8080e7          	jalr	1496(ra) # 80001c90 <myproc>
    800066c0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800066c2:	fd840593          	addi	a1,s0,-40
    800066c6:	4501                	li	a0,0
    800066c8:	ffffd097          	auipc	ra,0xffffd
    800066cc:	e12080e7          	jalr	-494(ra) # 800034da <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800066d0:	fc840593          	addi	a1,s0,-56
    800066d4:	fd040513          	addi	a0,s0,-48
    800066d8:	fffff097          	auipc	ra,0xfffff
    800066dc:	dea080e7          	jalr	-534(ra) # 800054c2 <pipealloc>
    return -1;
    800066e0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800066e2:	0c054463          	bltz	a0,800067aa <sys_pipe+0xfc>
  fd0 = -1;
    800066e6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800066ea:	fd043503          	ld	a0,-48(s0)
    800066ee:	fffff097          	auipc	ra,0xfffff
    800066f2:	524080e7          	jalr	1316(ra) # 80005c12 <fdalloc>
    800066f6:	fca42223          	sw	a0,-60(s0)
    800066fa:	08054b63          	bltz	a0,80006790 <sys_pipe+0xe2>
    800066fe:	fc843503          	ld	a0,-56(s0)
    80006702:	fffff097          	auipc	ra,0xfffff
    80006706:	510080e7          	jalr	1296(ra) # 80005c12 <fdalloc>
    8000670a:	fca42023          	sw	a0,-64(s0)
    8000670e:	06054863          	bltz	a0,8000677e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006712:	4691                	li	a3,4
    80006714:	fc440613          	addi	a2,s0,-60
    80006718:	fd843583          	ld	a1,-40(s0)
    8000671c:	68a8                	ld	a0,80(s1)
    8000671e:	ffffb097          	auipc	ra,0xffffb
    80006722:	19a080e7          	jalr	410(ra) # 800018b8 <copyout>
    80006726:	02054063          	bltz	a0,80006746 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000672a:	4691                	li	a3,4
    8000672c:	fc040613          	addi	a2,s0,-64
    80006730:	fd843583          	ld	a1,-40(s0)
    80006734:	0591                	addi	a1,a1,4
    80006736:	68a8                	ld	a0,80(s1)
    80006738:	ffffb097          	auipc	ra,0xffffb
    8000673c:	180080e7          	jalr	384(ra) # 800018b8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006740:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006742:	06055463          	bgez	a0,800067aa <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006746:	fc442783          	lw	a5,-60(s0)
    8000674a:	07e9                	addi	a5,a5,26
    8000674c:	078e                	slli	a5,a5,0x3
    8000674e:	97a6                	add	a5,a5,s1
    80006750:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006754:	fc042783          	lw	a5,-64(s0)
    80006758:	07e9                	addi	a5,a5,26
    8000675a:	078e                	slli	a5,a5,0x3
    8000675c:	94be                	add	s1,s1,a5
    8000675e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006762:	fd043503          	ld	a0,-48(s0)
    80006766:	fffff097          	auipc	ra,0xfffff
    8000676a:	a30080e7          	jalr	-1488(ra) # 80005196 <fileclose>
    fileclose(wf);
    8000676e:	fc843503          	ld	a0,-56(s0)
    80006772:	fffff097          	auipc	ra,0xfffff
    80006776:	a24080e7          	jalr	-1500(ra) # 80005196 <fileclose>
    return -1;
    8000677a:	57fd                	li	a5,-1
    8000677c:	a03d                	j	800067aa <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000677e:	fc442783          	lw	a5,-60(s0)
    80006782:	0007c763          	bltz	a5,80006790 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006786:	07e9                	addi	a5,a5,26
    80006788:	078e                	slli	a5,a5,0x3
    8000678a:	97a6                	add	a5,a5,s1
    8000678c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006790:	fd043503          	ld	a0,-48(s0)
    80006794:	fffff097          	auipc	ra,0xfffff
    80006798:	a02080e7          	jalr	-1534(ra) # 80005196 <fileclose>
    fileclose(wf);
    8000679c:	fc843503          	ld	a0,-56(s0)
    800067a0:	fffff097          	auipc	ra,0xfffff
    800067a4:	9f6080e7          	jalr	-1546(ra) # 80005196 <fileclose>
    return -1;
    800067a8:	57fd                	li	a5,-1
}
    800067aa:	853e                	mv	a0,a5
    800067ac:	70e2                	ld	ra,56(sp)
    800067ae:	7442                	ld	s0,48(sp)
    800067b0:	74a2                	ld	s1,40(sp)
    800067b2:	6121                	addi	sp,sp,64
    800067b4:	8082                	ret
	...

00000000800067c0 <kernelvec>:
    800067c0:	7111                	addi	sp,sp,-256
    800067c2:	e006                	sd	ra,0(sp)
    800067c4:	e40a                	sd	sp,8(sp)
    800067c6:	e80e                	sd	gp,16(sp)
    800067c8:	ec12                	sd	tp,24(sp)
    800067ca:	f016                	sd	t0,32(sp)
    800067cc:	f41a                	sd	t1,40(sp)
    800067ce:	f81e                	sd	t2,48(sp)
    800067d0:	fc22                	sd	s0,56(sp)
    800067d2:	e0a6                	sd	s1,64(sp)
    800067d4:	e4aa                	sd	a0,72(sp)
    800067d6:	e8ae                	sd	a1,80(sp)
    800067d8:	ecb2                	sd	a2,88(sp)
    800067da:	f0b6                	sd	a3,96(sp)
    800067dc:	f4ba                	sd	a4,104(sp)
    800067de:	f8be                	sd	a5,112(sp)
    800067e0:	fcc2                	sd	a6,120(sp)
    800067e2:	e146                	sd	a7,128(sp)
    800067e4:	e54a                	sd	s2,136(sp)
    800067e6:	e94e                	sd	s3,144(sp)
    800067e8:	ed52                	sd	s4,152(sp)
    800067ea:	f156                	sd	s5,160(sp)
    800067ec:	f55a                	sd	s6,168(sp)
    800067ee:	f95e                	sd	s7,176(sp)
    800067f0:	fd62                	sd	s8,184(sp)
    800067f2:	e1e6                	sd	s9,192(sp)
    800067f4:	e5ea                	sd	s10,200(sp)
    800067f6:	e9ee                	sd	s11,208(sp)
    800067f8:	edf2                	sd	t3,216(sp)
    800067fa:	f1f6                	sd	t4,224(sp)
    800067fc:	f5fa                	sd	t5,232(sp)
    800067fe:	f9fe                	sd	t6,240(sp)
    80006800:	8effc0ef          	jal	ra,800030ee <kerneltrap>
    80006804:	6082                	ld	ra,0(sp)
    80006806:	6122                	ld	sp,8(sp)
    80006808:	61c2                	ld	gp,16(sp)
    8000680a:	7282                	ld	t0,32(sp)
    8000680c:	7322                	ld	t1,40(sp)
    8000680e:	73c2                	ld	t2,48(sp)
    80006810:	7462                	ld	s0,56(sp)
    80006812:	6486                	ld	s1,64(sp)
    80006814:	6526                	ld	a0,72(sp)
    80006816:	65c6                	ld	a1,80(sp)
    80006818:	6666                	ld	a2,88(sp)
    8000681a:	7686                	ld	a3,96(sp)
    8000681c:	7726                	ld	a4,104(sp)
    8000681e:	77c6                	ld	a5,112(sp)
    80006820:	7866                	ld	a6,120(sp)
    80006822:	688a                	ld	a7,128(sp)
    80006824:	692a                	ld	s2,136(sp)
    80006826:	69ca                	ld	s3,144(sp)
    80006828:	6a6a                	ld	s4,152(sp)
    8000682a:	7a8a                	ld	s5,160(sp)
    8000682c:	7b2a                	ld	s6,168(sp)
    8000682e:	7bca                	ld	s7,176(sp)
    80006830:	7c6a                	ld	s8,184(sp)
    80006832:	6c8e                	ld	s9,192(sp)
    80006834:	6d2e                	ld	s10,200(sp)
    80006836:	6dce                	ld	s11,208(sp)
    80006838:	6e6e                	ld	t3,216(sp)
    8000683a:	7e8e                	ld	t4,224(sp)
    8000683c:	7f2e                	ld	t5,232(sp)
    8000683e:	7fce                	ld	t6,240(sp)
    80006840:	6111                	addi	sp,sp,256
    80006842:	10200073          	sret
    80006846:	00000013          	nop
    8000684a:	00000013          	nop
    8000684e:	0001                	nop

0000000080006850 <timervec>:
    80006850:	34051573          	csrrw	a0,mscratch,a0
    80006854:	e10c                	sd	a1,0(a0)
    80006856:	e510                	sd	a2,8(a0)
    80006858:	e914                	sd	a3,16(a0)
    8000685a:	6d0c                	ld	a1,24(a0)
    8000685c:	7110                	ld	a2,32(a0)
    8000685e:	6194                	ld	a3,0(a1)
    80006860:	96b2                	add	a3,a3,a2
    80006862:	e194                	sd	a3,0(a1)
    80006864:	4589                	li	a1,2
    80006866:	14459073          	csrw	sip,a1
    8000686a:	6914                	ld	a3,16(a0)
    8000686c:	6510                	ld	a2,8(a0)
    8000686e:	610c                	ld	a1,0(a0)
    80006870:	34051573          	csrrw	a0,mscratch,a0
    80006874:	30200073          	mret
	...

000000008000687a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000687a:	1141                	addi	sp,sp,-16
    8000687c:	e422                	sd	s0,8(sp)
    8000687e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006880:	0c0007b7          	lui	a5,0xc000
    80006884:	4705                	li	a4,1
    80006886:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006888:	c3d8                	sw	a4,4(a5)
}
    8000688a:	6422                	ld	s0,8(sp)
    8000688c:	0141                	addi	sp,sp,16
    8000688e:	8082                	ret

0000000080006890 <plicinithart>:

void
plicinithart(void)
{
    80006890:	1141                	addi	sp,sp,-16
    80006892:	e406                	sd	ra,8(sp)
    80006894:	e022                	sd	s0,0(sp)
    80006896:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006898:	ffffb097          	auipc	ra,0xffffb
    8000689c:	3cc080e7          	jalr	972(ra) # 80001c64 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800068a0:	0085171b          	slliw	a4,a0,0x8
    800068a4:	0c0027b7          	lui	a5,0xc002
    800068a8:	97ba                	add	a5,a5,a4
    800068aa:	40200713          	li	a4,1026
    800068ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800068b2:	00d5151b          	slliw	a0,a0,0xd
    800068b6:	0c2017b7          	lui	a5,0xc201
    800068ba:	97aa                	add	a5,a5,a0
    800068bc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800068c0:	60a2                	ld	ra,8(sp)
    800068c2:	6402                	ld	s0,0(sp)
    800068c4:	0141                	addi	sp,sp,16
    800068c6:	8082                	ret

00000000800068c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800068c8:	1141                	addi	sp,sp,-16
    800068ca:	e406                	sd	ra,8(sp)
    800068cc:	e022                	sd	s0,0(sp)
    800068ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800068d0:	ffffb097          	auipc	ra,0xffffb
    800068d4:	394080e7          	jalr	916(ra) # 80001c64 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800068d8:	00d5151b          	slliw	a0,a0,0xd
    800068dc:	0c2017b7          	lui	a5,0xc201
    800068e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800068e2:	43c8                	lw	a0,4(a5)
    800068e4:	60a2                	ld	ra,8(sp)
    800068e6:	6402                	ld	s0,0(sp)
    800068e8:	0141                	addi	sp,sp,16
    800068ea:	8082                	ret

00000000800068ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800068ec:	1101                	addi	sp,sp,-32
    800068ee:	ec06                	sd	ra,24(sp)
    800068f0:	e822                	sd	s0,16(sp)
    800068f2:	e426                	sd	s1,8(sp)
    800068f4:	1000                	addi	s0,sp,32
    800068f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800068f8:	ffffb097          	auipc	ra,0xffffb
    800068fc:	36c080e7          	jalr	876(ra) # 80001c64 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006900:	00d5151b          	slliw	a0,a0,0xd
    80006904:	0c2017b7          	lui	a5,0xc201
    80006908:	97aa                	add	a5,a5,a0
    8000690a:	c3c4                	sw	s1,4(a5)
}
    8000690c:	60e2                	ld	ra,24(sp)
    8000690e:	6442                	ld	s0,16(sp)
    80006910:	64a2                	ld	s1,8(sp)
    80006912:	6105                	addi	sp,sp,32
    80006914:	8082                	ret

0000000080006916 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006916:	1141                	addi	sp,sp,-16
    80006918:	e406                	sd	ra,8(sp)
    8000691a:	e022                	sd	s0,0(sp)
    8000691c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000691e:	479d                	li	a5,7
    80006920:	04a7cc63          	blt	a5,a0,80006978 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006924:	00242797          	auipc	a5,0x242
    80006928:	dc478793          	addi	a5,a5,-572 # 802486e8 <disk>
    8000692c:	97aa                	add	a5,a5,a0
    8000692e:	0187c783          	lbu	a5,24(a5)
    80006932:	ebb9                	bnez	a5,80006988 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006934:	00451693          	slli	a3,a0,0x4
    80006938:	00242797          	auipc	a5,0x242
    8000693c:	db078793          	addi	a5,a5,-592 # 802486e8 <disk>
    80006940:	6398                	ld	a4,0(a5)
    80006942:	9736                	add	a4,a4,a3
    80006944:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006948:	6398                	ld	a4,0(a5)
    8000694a:	9736                	add	a4,a4,a3
    8000694c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006950:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006954:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006958:	97aa                	add	a5,a5,a0
    8000695a:	4705                	li	a4,1
    8000695c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006960:	00242517          	auipc	a0,0x242
    80006964:	da050513          	addi	a0,a0,-608 # 80248700 <disk+0x18>
    80006968:	ffffc097          	auipc	ra,0xffffc
    8000696c:	012080e7          	jalr	18(ra) # 8000297a <wakeup>
}
    80006970:	60a2                	ld	ra,8(sp)
    80006972:	6402                	ld	s0,0(sp)
    80006974:	0141                	addi	sp,sp,16
    80006976:	8082                	ret
    panic("free_desc 1");
    80006978:	00002517          	auipc	a0,0x2
    8000697c:	0f850513          	addi	a0,a0,248 # 80008a70 <syscall_names+0x318>
    80006980:	ffffa097          	auipc	ra,0xffffa
    80006984:	bbc080e7          	jalr	-1092(ra) # 8000053c <panic>
    panic("free_desc 2");
    80006988:	00002517          	auipc	a0,0x2
    8000698c:	0f850513          	addi	a0,a0,248 # 80008a80 <syscall_names+0x328>
    80006990:	ffffa097          	auipc	ra,0xffffa
    80006994:	bac080e7          	jalr	-1108(ra) # 8000053c <panic>

0000000080006998 <virtio_disk_init>:
{
    80006998:	1101                	addi	sp,sp,-32
    8000699a:	ec06                	sd	ra,24(sp)
    8000699c:	e822                	sd	s0,16(sp)
    8000699e:	e426                	sd	s1,8(sp)
    800069a0:	e04a                	sd	s2,0(sp)
    800069a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800069a4:	00002597          	auipc	a1,0x2
    800069a8:	0ec58593          	addi	a1,a1,236 # 80008a90 <syscall_names+0x338>
    800069ac:	00242517          	auipc	a0,0x242
    800069b0:	e6450513          	addi	a0,a0,-412 # 80248810 <disk+0x128>
    800069b4:	ffffa097          	auipc	ra,0xffffa
    800069b8:	3d6080e7          	jalr	982(ra) # 80000d8a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800069bc:	100017b7          	lui	a5,0x10001
    800069c0:	4398                	lw	a4,0(a5)
    800069c2:	2701                	sext.w	a4,a4
    800069c4:	747277b7          	lui	a5,0x74727
    800069c8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800069cc:	14f71b63          	bne	a4,a5,80006b22 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800069d0:	100017b7          	lui	a5,0x10001
    800069d4:	43dc                	lw	a5,4(a5)
    800069d6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800069d8:	4709                	li	a4,2
    800069da:	14e79463          	bne	a5,a4,80006b22 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069de:	100017b7          	lui	a5,0x10001
    800069e2:	479c                	lw	a5,8(a5)
    800069e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800069e6:	12e79e63          	bne	a5,a4,80006b22 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800069ea:	100017b7          	lui	a5,0x10001
    800069ee:	47d8                	lw	a4,12(a5)
    800069f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069f2:	554d47b7          	lui	a5,0x554d4
    800069f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800069fa:	12f71463          	bne	a4,a5,80006b22 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800069fe:	100017b7          	lui	a5,0x10001
    80006a02:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a06:	4705                	li	a4,1
    80006a08:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a0a:	470d                	li	a4,3
    80006a0c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006a0e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006a10:	c7ffe6b7          	lui	a3,0xc7ffe
    80006a14:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47db5f37>
    80006a18:	8f75                	and	a4,a4,a3
    80006a1a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a1c:	472d                	li	a4,11
    80006a1e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006a20:	5bbc                	lw	a5,112(a5)
    80006a22:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006a26:	8ba1                	andi	a5,a5,8
    80006a28:	10078563          	beqz	a5,80006b32 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006a2c:	100017b7          	lui	a5,0x10001
    80006a30:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006a34:	43fc                	lw	a5,68(a5)
    80006a36:	2781                	sext.w	a5,a5
    80006a38:	10079563          	bnez	a5,80006b42 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006a3c:	100017b7          	lui	a5,0x10001
    80006a40:	5bdc                	lw	a5,52(a5)
    80006a42:	2781                	sext.w	a5,a5
  if(max == 0)
    80006a44:	10078763          	beqz	a5,80006b52 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006a48:	471d                	li	a4,7
    80006a4a:	10f77c63          	bgeu	a4,a5,80006b62 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80006a4e:	ffffa097          	auipc	ra,0xffffa
    80006a52:	1ea080e7          	jalr	490(ra) # 80000c38 <kalloc>
    80006a56:	00242497          	auipc	s1,0x242
    80006a5a:	c9248493          	addi	s1,s1,-878 # 802486e8 <disk>
    80006a5e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006a60:	ffffa097          	auipc	ra,0xffffa
    80006a64:	1d8080e7          	jalr	472(ra) # 80000c38 <kalloc>
    80006a68:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006a6a:	ffffa097          	auipc	ra,0xffffa
    80006a6e:	1ce080e7          	jalr	462(ra) # 80000c38 <kalloc>
    80006a72:	87aa                	mv	a5,a0
    80006a74:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006a76:	6088                	ld	a0,0(s1)
    80006a78:	cd6d                	beqz	a0,80006b72 <virtio_disk_init+0x1da>
    80006a7a:	00242717          	auipc	a4,0x242
    80006a7e:	c7673703          	ld	a4,-906(a4) # 802486f0 <disk+0x8>
    80006a82:	cb65                	beqz	a4,80006b72 <virtio_disk_init+0x1da>
    80006a84:	c7fd                	beqz	a5,80006b72 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006a86:	6605                	lui	a2,0x1
    80006a88:	4581                	li	a1,0
    80006a8a:	ffffa097          	auipc	ra,0xffffa
    80006a8e:	48c080e7          	jalr	1164(ra) # 80000f16 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006a92:	00242497          	auipc	s1,0x242
    80006a96:	c5648493          	addi	s1,s1,-938 # 802486e8 <disk>
    80006a9a:	6605                	lui	a2,0x1
    80006a9c:	4581                	li	a1,0
    80006a9e:	6488                	ld	a0,8(s1)
    80006aa0:	ffffa097          	auipc	ra,0xffffa
    80006aa4:	476080e7          	jalr	1142(ra) # 80000f16 <memset>
  memset(disk.used, 0, PGSIZE);
    80006aa8:	6605                	lui	a2,0x1
    80006aaa:	4581                	li	a1,0
    80006aac:	6888                	ld	a0,16(s1)
    80006aae:	ffffa097          	auipc	ra,0xffffa
    80006ab2:	468080e7          	jalr	1128(ra) # 80000f16 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006ab6:	100017b7          	lui	a5,0x10001
    80006aba:	4721                	li	a4,8
    80006abc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006abe:	4098                	lw	a4,0(s1)
    80006ac0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006ac4:	40d8                	lw	a4,4(s1)
    80006ac6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006aca:	6498                	ld	a4,8(s1)
    80006acc:	0007069b          	sext.w	a3,a4
    80006ad0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006ad4:	9701                	srai	a4,a4,0x20
    80006ad6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006ada:	6898                	ld	a4,16(s1)
    80006adc:	0007069b          	sext.w	a3,a4
    80006ae0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006ae4:	9701                	srai	a4,a4,0x20
    80006ae6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006aea:	4705                	li	a4,1
    80006aec:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006aee:	00e48c23          	sb	a4,24(s1)
    80006af2:	00e48ca3          	sb	a4,25(s1)
    80006af6:	00e48d23          	sb	a4,26(s1)
    80006afa:	00e48da3          	sb	a4,27(s1)
    80006afe:	00e48e23          	sb	a4,28(s1)
    80006b02:	00e48ea3          	sb	a4,29(s1)
    80006b06:	00e48f23          	sb	a4,30(s1)
    80006b0a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006b0e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006b12:	0727a823          	sw	s2,112(a5)
}
    80006b16:	60e2                	ld	ra,24(sp)
    80006b18:	6442                	ld	s0,16(sp)
    80006b1a:	64a2                	ld	s1,8(sp)
    80006b1c:	6902                	ld	s2,0(sp)
    80006b1e:	6105                	addi	sp,sp,32
    80006b20:	8082                	ret
    panic("could not find virtio disk");
    80006b22:	00002517          	auipc	a0,0x2
    80006b26:	f7e50513          	addi	a0,a0,-130 # 80008aa0 <syscall_names+0x348>
    80006b2a:	ffffa097          	auipc	ra,0xffffa
    80006b2e:	a12080e7          	jalr	-1518(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006b32:	00002517          	auipc	a0,0x2
    80006b36:	f8e50513          	addi	a0,a0,-114 # 80008ac0 <syscall_names+0x368>
    80006b3a:	ffffa097          	auipc	ra,0xffffa
    80006b3e:	a02080e7          	jalr	-1534(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80006b42:	00002517          	auipc	a0,0x2
    80006b46:	f9e50513          	addi	a0,a0,-98 # 80008ae0 <syscall_names+0x388>
    80006b4a:	ffffa097          	auipc	ra,0xffffa
    80006b4e:	9f2080e7          	jalr	-1550(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80006b52:	00002517          	auipc	a0,0x2
    80006b56:	fae50513          	addi	a0,a0,-82 # 80008b00 <syscall_names+0x3a8>
    80006b5a:	ffffa097          	auipc	ra,0xffffa
    80006b5e:	9e2080e7          	jalr	-1566(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006b62:	00002517          	auipc	a0,0x2
    80006b66:	fbe50513          	addi	a0,a0,-66 # 80008b20 <syscall_names+0x3c8>
    80006b6a:	ffffa097          	auipc	ra,0xffffa
    80006b6e:	9d2080e7          	jalr	-1582(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80006b72:	00002517          	auipc	a0,0x2
    80006b76:	fce50513          	addi	a0,a0,-50 # 80008b40 <syscall_names+0x3e8>
    80006b7a:	ffffa097          	auipc	ra,0xffffa
    80006b7e:	9c2080e7          	jalr	-1598(ra) # 8000053c <panic>

0000000080006b82 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006b82:	7159                	addi	sp,sp,-112
    80006b84:	f486                	sd	ra,104(sp)
    80006b86:	f0a2                	sd	s0,96(sp)
    80006b88:	eca6                	sd	s1,88(sp)
    80006b8a:	e8ca                	sd	s2,80(sp)
    80006b8c:	e4ce                	sd	s3,72(sp)
    80006b8e:	e0d2                	sd	s4,64(sp)
    80006b90:	fc56                	sd	s5,56(sp)
    80006b92:	f85a                	sd	s6,48(sp)
    80006b94:	f45e                	sd	s7,40(sp)
    80006b96:	f062                	sd	s8,32(sp)
    80006b98:	ec66                	sd	s9,24(sp)
    80006b9a:	e86a                	sd	s10,16(sp)
    80006b9c:	1880                	addi	s0,sp,112
    80006b9e:	8a2a                	mv	s4,a0
    80006ba0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006ba2:	00c52c83          	lw	s9,12(a0)
    80006ba6:	001c9c9b          	slliw	s9,s9,0x1
    80006baa:	1c82                	slli	s9,s9,0x20
    80006bac:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006bb0:	00242517          	auipc	a0,0x242
    80006bb4:	c6050513          	addi	a0,a0,-928 # 80248810 <disk+0x128>
    80006bb8:	ffffa097          	auipc	ra,0xffffa
    80006bbc:	262080e7          	jalr	610(ra) # 80000e1a <acquire>
  for(int i = 0; i < 3; i++){
    80006bc0:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006bc2:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006bc4:	00242b17          	auipc	s6,0x242
    80006bc8:	b24b0b13          	addi	s6,s6,-1244 # 802486e8 <disk>
  for(int i = 0; i < 3; i++){
    80006bcc:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006bce:	00242c17          	auipc	s8,0x242
    80006bd2:	c42c0c13          	addi	s8,s8,-958 # 80248810 <disk+0x128>
    80006bd6:	a095                	j	80006c3a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006bd8:	00fb0733          	add	a4,s6,a5
    80006bdc:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006be0:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006be2:	0207c563          	bltz	a5,80006c0c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006be6:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006be8:	0591                	addi	a1,a1,4
    80006bea:	05560d63          	beq	a2,s5,80006c44 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006bee:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006bf0:	00242717          	auipc	a4,0x242
    80006bf4:	af870713          	addi	a4,a4,-1288 # 802486e8 <disk>
    80006bf8:	87ca                	mv	a5,s2
    if(disk.free[i]){
    80006bfa:	01874683          	lbu	a3,24(a4)
    80006bfe:	fee9                	bnez	a3,80006bd8 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006c00:	2785                	addiw	a5,a5,1
    80006c02:	0705                	addi	a4,a4,1
    80006c04:	fe979be3          	bne	a5,s1,80006bfa <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006c08:	57fd                	li	a5,-1
    80006c0a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    80006c0c:	00c05e63          	blez	a2,80006c28 <virtio_disk_rw+0xa6>
    80006c10:	060a                	slli	a2,a2,0x2
    80006c12:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006c16:	0009a503          	lw	a0,0(s3)
    80006c1a:	00000097          	auipc	ra,0x0
    80006c1e:	cfc080e7          	jalr	-772(ra) # 80006916 <free_desc>
      for(int j = 0; j < i; j++)
    80006c22:	0991                	addi	s3,s3,4
    80006c24:	ffa999e3          	bne	s3,s10,80006c16 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006c28:	85e2                	mv	a1,s8
    80006c2a:	00242517          	auipc	a0,0x242
    80006c2e:	ad650513          	addi	a0,a0,-1322 # 80248700 <disk+0x18>
    80006c32:	ffffc097          	auipc	ra,0xffffc
    80006c36:	b98080e7          	jalr	-1128(ra) # 800027ca <sleep>
  for(int i = 0; i < 3; i++){
    80006c3a:	f9040993          	addi	s3,s0,-112
{
    80006c3e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006c40:	864a                	mv	a2,s2
    80006c42:	b775                	j	80006bee <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006c44:	f9042503          	lw	a0,-112(s0)
    80006c48:	00a50713          	addi	a4,a0,10
    80006c4c:	0712                	slli	a4,a4,0x4

  if(write)
    80006c4e:	00242797          	auipc	a5,0x242
    80006c52:	a9a78793          	addi	a5,a5,-1382 # 802486e8 <disk>
    80006c56:	00e786b3          	add	a3,a5,a4
    80006c5a:	01703633          	snez	a2,s7
    80006c5e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006c60:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006c64:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006c68:	f6070613          	addi	a2,a4,-160
    80006c6c:	6394                	ld	a3,0(a5)
    80006c6e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006c70:	00870593          	addi	a1,a4,8
    80006c74:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006c76:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006c78:	0007b803          	ld	a6,0(a5)
    80006c7c:	9642                	add	a2,a2,a6
    80006c7e:	46c1                	li	a3,16
    80006c80:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006c82:	4585                	li	a1,1
    80006c84:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006c88:	f9442683          	lw	a3,-108(s0)
    80006c8c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006c90:	0692                	slli	a3,a3,0x4
    80006c92:	9836                	add	a6,a6,a3
    80006c94:	058a0613          	addi	a2,s4,88
    80006c98:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006c9c:	0007b803          	ld	a6,0(a5)
    80006ca0:	96c2                	add	a3,a3,a6
    80006ca2:	40000613          	li	a2,1024
    80006ca6:	c690                	sw	a2,8(a3)
  if(write)
    80006ca8:	001bb613          	seqz	a2,s7
    80006cac:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006cb0:	00166613          	ori	a2,a2,1
    80006cb4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006cb8:	f9842603          	lw	a2,-104(s0)
    80006cbc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006cc0:	00250693          	addi	a3,a0,2
    80006cc4:	0692                	slli	a3,a3,0x4
    80006cc6:	96be                	add	a3,a3,a5
    80006cc8:	58fd                	li	a7,-1
    80006cca:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006cce:	0612                	slli	a2,a2,0x4
    80006cd0:	9832                	add	a6,a6,a2
    80006cd2:	f9070713          	addi	a4,a4,-112
    80006cd6:	973e                	add	a4,a4,a5
    80006cd8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006cdc:	6398                	ld	a4,0(a5)
    80006cde:	9732                	add	a4,a4,a2
    80006ce0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006ce2:	4609                	li	a2,2
    80006ce4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006ce8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006cec:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006cf0:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006cf4:	6794                	ld	a3,8(a5)
    80006cf6:	0026d703          	lhu	a4,2(a3)
    80006cfa:	8b1d                	andi	a4,a4,7
    80006cfc:	0706                	slli	a4,a4,0x1
    80006cfe:	96ba                	add	a3,a3,a4
    80006d00:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006d04:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006d08:	6798                	ld	a4,8(a5)
    80006d0a:	00275783          	lhu	a5,2(a4)
    80006d0e:	2785                	addiw	a5,a5,1
    80006d10:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006d14:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006d18:	100017b7          	lui	a5,0x10001
    80006d1c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006d20:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006d24:	00242917          	auipc	s2,0x242
    80006d28:	aec90913          	addi	s2,s2,-1300 # 80248810 <disk+0x128>
  while(b->disk == 1) {
    80006d2c:	4485                	li	s1,1
    80006d2e:	00b79c63          	bne	a5,a1,80006d46 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006d32:	85ca                	mv	a1,s2
    80006d34:	8552                	mv	a0,s4
    80006d36:	ffffc097          	auipc	ra,0xffffc
    80006d3a:	a94080e7          	jalr	-1388(ra) # 800027ca <sleep>
  while(b->disk == 1) {
    80006d3e:	004a2783          	lw	a5,4(s4)
    80006d42:	fe9788e3          	beq	a5,s1,80006d32 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006d46:	f9042903          	lw	s2,-112(s0)
    80006d4a:	00290713          	addi	a4,s2,2
    80006d4e:	0712                	slli	a4,a4,0x4
    80006d50:	00242797          	auipc	a5,0x242
    80006d54:	99878793          	addi	a5,a5,-1640 # 802486e8 <disk>
    80006d58:	97ba                	add	a5,a5,a4
    80006d5a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006d5e:	00242997          	auipc	s3,0x242
    80006d62:	98a98993          	addi	s3,s3,-1654 # 802486e8 <disk>
    80006d66:	00491713          	slli	a4,s2,0x4
    80006d6a:	0009b783          	ld	a5,0(s3)
    80006d6e:	97ba                	add	a5,a5,a4
    80006d70:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006d74:	854a                	mv	a0,s2
    80006d76:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006d7a:	00000097          	auipc	ra,0x0
    80006d7e:	b9c080e7          	jalr	-1124(ra) # 80006916 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006d82:	8885                	andi	s1,s1,1
    80006d84:	f0ed                	bnez	s1,80006d66 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006d86:	00242517          	auipc	a0,0x242
    80006d8a:	a8a50513          	addi	a0,a0,-1398 # 80248810 <disk+0x128>
    80006d8e:	ffffa097          	auipc	ra,0xffffa
    80006d92:	140080e7          	jalr	320(ra) # 80000ece <release>
}
    80006d96:	70a6                	ld	ra,104(sp)
    80006d98:	7406                	ld	s0,96(sp)
    80006d9a:	64e6                	ld	s1,88(sp)
    80006d9c:	6946                	ld	s2,80(sp)
    80006d9e:	69a6                	ld	s3,72(sp)
    80006da0:	6a06                	ld	s4,64(sp)
    80006da2:	7ae2                	ld	s5,56(sp)
    80006da4:	7b42                	ld	s6,48(sp)
    80006da6:	7ba2                	ld	s7,40(sp)
    80006da8:	7c02                	ld	s8,32(sp)
    80006daa:	6ce2                	ld	s9,24(sp)
    80006dac:	6d42                	ld	s10,16(sp)
    80006dae:	6165                	addi	sp,sp,112
    80006db0:	8082                	ret

0000000080006db2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006db2:	1101                	addi	sp,sp,-32
    80006db4:	ec06                	sd	ra,24(sp)
    80006db6:	e822                	sd	s0,16(sp)
    80006db8:	e426                	sd	s1,8(sp)
    80006dba:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006dbc:	00242497          	auipc	s1,0x242
    80006dc0:	92c48493          	addi	s1,s1,-1748 # 802486e8 <disk>
    80006dc4:	00242517          	auipc	a0,0x242
    80006dc8:	a4c50513          	addi	a0,a0,-1460 # 80248810 <disk+0x128>
    80006dcc:	ffffa097          	auipc	ra,0xffffa
    80006dd0:	04e080e7          	jalr	78(ra) # 80000e1a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006dd4:	10001737          	lui	a4,0x10001
    80006dd8:	533c                	lw	a5,96(a4)
    80006dda:	8b8d                	andi	a5,a5,3
    80006ddc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006dde:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006de2:	689c                	ld	a5,16(s1)
    80006de4:	0204d703          	lhu	a4,32(s1)
    80006de8:	0027d783          	lhu	a5,2(a5)
    80006dec:	04f70863          	beq	a4,a5,80006e3c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006df0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006df4:	6898                	ld	a4,16(s1)
    80006df6:	0204d783          	lhu	a5,32(s1)
    80006dfa:	8b9d                	andi	a5,a5,7
    80006dfc:	078e                	slli	a5,a5,0x3
    80006dfe:	97ba                	add	a5,a5,a4
    80006e00:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006e02:	00278713          	addi	a4,a5,2
    80006e06:	0712                	slli	a4,a4,0x4
    80006e08:	9726                	add	a4,a4,s1
    80006e0a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006e0e:	e721                	bnez	a4,80006e56 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006e10:	0789                	addi	a5,a5,2
    80006e12:	0792                	slli	a5,a5,0x4
    80006e14:	97a6                	add	a5,a5,s1
    80006e16:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006e18:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006e1c:	ffffc097          	auipc	ra,0xffffc
    80006e20:	b5e080e7          	jalr	-1186(ra) # 8000297a <wakeup>

    disk.used_idx += 1;
    80006e24:	0204d783          	lhu	a5,32(s1)
    80006e28:	2785                	addiw	a5,a5,1
    80006e2a:	17c2                	slli	a5,a5,0x30
    80006e2c:	93c1                	srli	a5,a5,0x30
    80006e2e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006e32:	6898                	ld	a4,16(s1)
    80006e34:	00275703          	lhu	a4,2(a4)
    80006e38:	faf71ce3          	bne	a4,a5,80006df0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006e3c:	00242517          	auipc	a0,0x242
    80006e40:	9d450513          	addi	a0,a0,-1580 # 80248810 <disk+0x128>
    80006e44:	ffffa097          	auipc	ra,0xffffa
    80006e48:	08a080e7          	jalr	138(ra) # 80000ece <release>
}
    80006e4c:	60e2                	ld	ra,24(sp)
    80006e4e:	6442                	ld	s0,16(sp)
    80006e50:	64a2                	ld	s1,8(sp)
    80006e52:	6105                	addi	sp,sp,32
    80006e54:	8082                	ret
      panic("virtio_disk_intr status");
    80006e56:	00002517          	auipc	a0,0x2
    80006e5a:	d0250513          	addi	a0,a0,-766 # 80008b58 <syscall_names+0x400>
    80006e5e:	ffff9097          	auipc	ra,0xffff9
    80006e62:	6de080e7          	jalr	1758(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
