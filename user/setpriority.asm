
user/_setpriority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/param.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int main(int argc, char *argv[]){
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
        exit(1);
    }
#endif
    return 0;
    exit(0);
   6:	4501                	li	a0,0
   8:	6422                	ld	s0,8(sp)
   a:	0141                	addi	sp,sp,16
   c:	8082                	ret

000000000000000e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
   e:	1141                	addi	sp,sp,-16
  10:	e406                	sd	ra,8(sp)
  12:	e022                	sd	s0,0(sp)
  14:	0800                	addi	s0,sp,16
  extern int main();
  main();
  16:	00000097          	auipc	ra,0x0
  1a:	fea080e7          	jalr	-22(ra) # 0 <main>
  exit(0);
  1e:	4501                	li	a0,0
  20:	00000097          	auipc	ra,0x0
  24:	274080e7          	jalr	628(ra) # 294 <exit>

0000000000000028 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  28:	1141                	addi	sp,sp,-16
  2a:	e422                	sd	s0,8(sp)
  2c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  2e:	87aa                	mv	a5,a0
  30:	0585                	addi	a1,a1,1
  32:	0785                	addi	a5,a5,1
  34:	fff5c703          	lbu	a4,-1(a1)
  38:	fee78fa3          	sb	a4,-1(a5)
  3c:	fb75                	bnez	a4,30 <strcpy+0x8>
    ;
  return os;
}
  3e:	6422                	ld	s0,8(sp)
  40:	0141                	addi	sp,sp,16
  42:	8082                	ret

0000000000000044 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  44:	1141                	addi	sp,sp,-16
  46:	e422                	sd	s0,8(sp)
  48:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  4a:	00054783          	lbu	a5,0(a0)
  4e:	cb91                	beqz	a5,62 <strcmp+0x1e>
  50:	0005c703          	lbu	a4,0(a1)
  54:	00f71763          	bne	a4,a5,62 <strcmp+0x1e>
    p++, q++;
  58:	0505                	addi	a0,a0,1
  5a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  5c:	00054783          	lbu	a5,0(a0)
  60:	fbe5                	bnez	a5,50 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  62:	0005c503          	lbu	a0,0(a1)
}
  66:	40a7853b          	subw	a0,a5,a0
  6a:	6422                	ld	s0,8(sp)
  6c:	0141                	addi	sp,sp,16
  6e:	8082                	ret

0000000000000070 <strlen>:

uint
strlen(const char *s)
{
  70:	1141                	addi	sp,sp,-16
  72:	e422                	sd	s0,8(sp)
  74:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  76:	00054783          	lbu	a5,0(a0)
  7a:	cf91                	beqz	a5,96 <strlen+0x26>
  7c:	0505                	addi	a0,a0,1
  7e:	87aa                	mv	a5,a0
  80:	86be                	mv	a3,a5
  82:	0785                	addi	a5,a5,1
  84:	fff7c703          	lbu	a4,-1(a5)
  88:	ff65                	bnez	a4,80 <strlen+0x10>
  8a:	40a6853b          	subw	a0,a3,a0
  8e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  90:	6422                	ld	s0,8(sp)
  92:	0141                	addi	sp,sp,16
  94:	8082                	ret
  for(n = 0; s[n]; n++)
  96:	4501                	li	a0,0
  98:	bfe5                	j	90 <strlen+0x20>

000000000000009a <memset>:

void*
memset(void *dst, int c, uint n)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a0:	ca19                	beqz	a2,b6 <memset+0x1c>
  a2:	87aa                	mv	a5,a0
  a4:	1602                	slli	a2,a2,0x20
  a6:	9201                	srli	a2,a2,0x20
  a8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b0:	0785                	addi	a5,a5,1
  b2:	fee79de3          	bne	a5,a4,ac <memset+0x12>
  }
  return dst;
}
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret

00000000000000bc <strchr>:

char*
strchr(const char *s, char c)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	cb99                	beqz	a5,dc <strchr+0x20>
    if(*s == c)
  c8:	00f58763          	beq	a1,a5,d6 <strchr+0x1a>
  for(; *s; s++)
  cc:	0505                	addi	a0,a0,1
  ce:	00054783          	lbu	a5,0(a0)
  d2:	fbfd                	bnez	a5,c8 <strchr+0xc>
      return (char*)s;
  return 0;
  d4:	4501                	li	a0,0
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret
  return 0;
  dc:	4501                	li	a0,0
  de:	bfe5                	j	d6 <strchr+0x1a>

00000000000000e0 <gets>:

char*
gets(char *buf, int max)
{
  e0:	711d                	addi	sp,sp,-96
  e2:	ec86                	sd	ra,88(sp)
  e4:	e8a2                	sd	s0,80(sp)
  e6:	e4a6                	sd	s1,72(sp)
  e8:	e0ca                	sd	s2,64(sp)
  ea:	fc4e                	sd	s3,56(sp)
  ec:	f852                	sd	s4,48(sp)
  ee:	f456                	sd	s5,40(sp)
  f0:	f05a                	sd	s6,32(sp)
  f2:	ec5e                	sd	s7,24(sp)
  f4:	1080                	addi	s0,sp,96
  f6:	8baa                	mv	s7,a0
  f8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fa:	892a                	mv	s2,a0
  fc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
  fe:	4aa9                	li	s5,10
 100:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 102:	89a6                	mv	s3,s1
 104:	2485                	addiw	s1,s1,1
 106:	0344d863          	bge	s1,s4,136 <gets+0x56>
    cc = read(0, &c, 1);
 10a:	4605                	li	a2,1
 10c:	faf40593          	addi	a1,s0,-81
 110:	4501                	li	a0,0
 112:	00000097          	auipc	ra,0x0
 116:	19a080e7          	jalr	410(ra) # 2ac <read>
    if(cc < 1)
 11a:	00a05e63          	blez	a0,136 <gets+0x56>
    buf[i++] = c;
 11e:	faf44783          	lbu	a5,-81(s0)
 122:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 126:	01578763          	beq	a5,s5,134 <gets+0x54>
 12a:	0905                	addi	s2,s2,1
 12c:	fd679be3          	bne	a5,s6,102 <gets+0x22>
  for(i=0; i+1 < max; ){
 130:	89a6                	mv	s3,s1
 132:	a011                	j	136 <gets+0x56>
 134:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 136:	99de                	add	s3,s3,s7
 138:	00098023          	sb	zero,0(s3)
  return buf;
}
 13c:	855e                	mv	a0,s7
 13e:	60e6                	ld	ra,88(sp)
 140:	6446                	ld	s0,80(sp)
 142:	64a6                	ld	s1,72(sp)
 144:	6906                	ld	s2,64(sp)
 146:	79e2                	ld	s3,56(sp)
 148:	7a42                	ld	s4,48(sp)
 14a:	7aa2                	ld	s5,40(sp)
 14c:	7b02                	ld	s6,32(sp)
 14e:	6be2                	ld	s7,24(sp)
 150:	6125                	addi	sp,sp,96
 152:	8082                	ret

0000000000000154 <stat>:

int
stat(const char *n, struct stat *st)
{
 154:	1101                	addi	sp,sp,-32
 156:	ec06                	sd	ra,24(sp)
 158:	e822                	sd	s0,16(sp)
 15a:	e426                	sd	s1,8(sp)
 15c:	e04a                	sd	s2,0(sp)
 15e:	1000                	addi	s0,sp,32
 160:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 162:	4581                	li	a1,0
 164:	00000097          	auipc	ra,0x0
 168:	170080e7          	jalr	368(ra) # 2d4 <open>
  if(fd < 0)
 16c:	02054563          	bltz	a0,196 <stat+0x42>
 170:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 172:	85ca                	mv	a1,s2
 174:	00000097          	auipc	ra,0x0
 178:	178080e7          	jalr	376(ra) # 2ec <fstat>
 17c:	892a                	mv	s2,a0
  close(fd);
 17e:	8526                	mv	a0,s1
 180:	00000097          	auipc	ra,0x0
 184:	13c080e7          	jalr	316(ra) # 2bc <close>
  return r;
}
 188:	854a                	mv	a0,s2
 18a:	60e2                	ld	ra,24(sp)
 18c:	6442                	ld	s0,16(sp)
 18e:	64a2                	ld	s1,8(sp)
 190:	6902                	ld	s2,0(sp)
 192:	6105                	addi	sp,sp,32
 194:	8082                	ret
    return -1;
 196:	597d                	li	s2,-1
 198:	bfc5                	j	188 <stat+0x34>

000000000000019a <atoi>:

int
atoi(const char *s)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a0:	00054683          	lbu	a3,0(a0)
 1a4:	fd06879b          	addiw	a5,a3,-48
 1a8:	0ff7f793          	zext.b	a5,a5
 1ac:	4625                	li	a2,9
 1ae:	02f66863          	bltu	a2,a5,1de <atoi+0x44>
 1b2:	872a                	mv	a4,a0
  n = 0;
 1b4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1b6:	0705                	addi	a4,a4,1
 1b8:	0025179b          	slliw	a5,a0,0x2
 1bc:	9fa9                	addw	a5,a5,a0
 1be:	0017979b          	slliw	a5,a5,0x1
 1c2:	9fb5                	addw	a5,a5,a3
 1c4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c8:	00074683          	lbu	a3,0(a4)
 1cc:	fd06879b          	addiw	a5,a3,-48
 1d0:	0ff7f793          	zext.b	a5,a5
 1d4:	fef671e3          	bgeu	a2,a5,1b6 <atoi+0x1c>
  return n;
}
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret
  n = 0;
 1de:	4501                	li	a0,0
 1e0:	bfe5                	j	1d8 <atoi+0x3e>

00000000000001e2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e8:	02b57463          	bgeu	a0,a1,210 <memmove+0x2e>
    while(n-- > 0)
 1ec:	00c05f63          	blez	a2,20a <memmove+0x28>
 1f0:	1602                	slli	a2,a2,0x20
 1f2:	9201                	srli	a2,a2,0x20
 1f4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1f8:	872a                	mv	a4,a0
      *dst++ = *src++;
 1fa:	0585                	addi	a1,a1,1
 1fc:	0705                	addi	a4,a4,1
 1fe:	fff5c683          	lbu	a3,-1(a1)
 202:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 206:	fee79ae3          	bne	a5,a4,1fa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret
    dst += n;
 210:	00c50733          	add	a4,a0,a2
    src += n;
 214:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 216:	fec05ae3          	blez	a2,20a <memmove+0x28>
 21a:	fff6079b          	addiw	a5,a2,-1
 21e:	1782                	slli	a5,a5,0x20
 220:	9381                	srli	a5,a5,0x20
 222:	fff7c793          	not	a5,a5
 226:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 228:	15fd                	addi	a1,a1,-1
 22a:	177d                	addi	a4,a4,-1
 22c:	0005c683          	lbu	a3,0(a1)
 230:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 234:	fee79ae3          	bne	a5,a4,228 <memmove+0x46>
 238:	bfc9                	j	20a <memmove+0x28>

000000000000023a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 240:	ca05                	beqz	a2,270 <memcmp+0x36>
 242:	fff6069b          	addiw	a3,a2,-1
 246:	1682                	slli	a3,a3,0x20
 248:	9281                	srli	a3,a3,0x20
 24a:	0685                	addi	a3,a3,1
 24c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 24e:	00054783          	lbu	a5,0(a0)
 252:	0005c703          	lbu	a4,0(a1)
 256:	00e79863          	bne	a5,a4,266 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 25a:	0505                	addi	a0,a0,1
    p2++;
 25c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 25e:	fed518e3          	bne	a0,a3,24e <memcmp+0x14>
  }
  return 0;
 262:	4501                	li	a0,0
 264:	a019                	j	26a <memcmp+0x30>
      return *p1 - *p2;
 266:	40e7853b          	subw	a0,a5,a4
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
  return 0;
 270:	4501                	li	a0,0
 272:	bfe5                	j	26a <memcmp+0x30>

0000000000000274 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 274:	1141                	addi	sp,sp,-16
 276:	e406                	sd	ra,8(sp)
 278:	e022                	sd	s0,0(sp)
 27a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 27c:	00000097          	auipc	ra,0x0
 280:	f66080e7          	jalr	-154(ra) # 1e2 <memmove>
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 28c:	4885                	li	a7,1
 ecall
 28e:	00000073          	ecall
 ret
 292:	8082                	ret

0000000000000294 <exit>:
.global exit
exit:
 li a7, SYS_exit
 294:	4889                	li	a7,2
 ecall
 296:	00000073          	ecall
 ret
 29a:	8082                	ret

000000000000029c <wait>:
.global wait
wait:
 li a7, SYS_wait
 29c:	488d                	li	a7,3
 ecall
 29e:	00000073          	ecall
 ret
 2a2:	8082                	ret

00000000000002a4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2a4:	4891                	li	a7,4
 ecall
 2a6:	00000073          	ecall
 ret
 2aa:	8082                	ret

00000000000002ac <read>:
.global read
read:
 li a7, SYS_read
 2ac:	4895                	li	a7,5
 ecall
 2ae:	00000073          	ecall
 ret
 2b2:	8082                	ret

00000000000002b4 <write>:
.global write
write:
 li a7, SYS_write
 2b4:	48c1                	li	a7,16
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <close>:
.global close
close:
 li a7, SYS_close
 2bc:	48d5                	li	a7,21
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2c4:	4899                	li	a7,6
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <exec>:
.global exec
exec:
 li a7, SYS_exec
 2cc:	489d                	li	a7,7
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <open>:
.global open
open:
 li a7, SYS_open
 2d4:	48bd                	li	a7,15
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2dc:	48c5                	li	a7,17
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2e4:	48c9                	li	a7,18
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2ec:	48a1                	li	a7,8
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <link>:
.global link
link:
 li a7, SYS_link
 2f4:	48cd                	li	a7,19
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2fc:	48d1                	li	a7,20
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 304:	48a5                	li	a7,9
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <dup>:
.global dup
dup:
 li a7, SYS_dup
 30c:	48a9                	li	a7,10
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 314:	48ad                	li	a7,11
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 31c:	48b1                	li	a7,12
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 324:	48b5                	li	a7,13
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 32c:	48b9                	li	a7,14
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <trace>:
.global trace
trace:
 li a7, SYS_trace
 334:	48d9                	li	a7,22
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 33c:	48dd                	li	a7,23
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 344:	48e1                	li	a7,24
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 34c:	48e5                	li	a7,25
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 354:	48ed                	li	a7,27
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <set_tickets>:
.global set_tickets
set_tickets:
 li a7, SYS_set_tickets
 35c:	48e9                	li	a7,26
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 364:	1101                	addi	sp,sp,-32
 366:	ec06                	sd	ra,24(sp)
 368:	e822                	sd	s0,16(sp)
 36a:	1000                	addi	s0,sp,32
 36c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 370:	4605                	li	a2,1
 372:	fef40593          	addi	a1,s0,-17
 376:	00000097          	auipc	ra,0x0
 37a:	f3e080e7          	jalr	-194(ra) # 2b4 <write>
}
 37e:	60e2                	ld	ra,24(sp)
 380:	6442                	ld	s0,16(sp)
 382:	6105                	addi	sp,sp,32
 384:	8082                	ret

0000000000000386 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 386:	7139                	addi	sp,sp,-64
 388:	fc06                	sd	ra,56(sp)
 38a:	f822                	sd	s0,48(sp)
 38c:	f426                	sd	s1,40(sp)
 38e:	f04a                	sd	s2,32(sp)
 390:	ec4e                	sd	s3,24(sp)
 392:	0080                	addi	s0,sp,64
 394:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 396:	c299                	beqz	a3,39c <printint+0x16>
 398:	0805c963          	bltz	a1,42a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 39c:	2581                	sext.w	a1,a1
  neg = 0;
 39e:	4881                	li	a7,0
 3a0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3a4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3a6:	2601                	sext.w	a2,a2
 3a8:	00000517          	auipc	a0,0x0
 3ac:	48850513          	addi	a0,a0,1160 # 830 <digits>
 3b0:	883a                	mv	a6,a4
 3b2:	2705                	addiw	a4,a4,1
 3b4:	02c5f7bb          	remuw	a5,a1,a2
 3b8:	1782                	slli	a5,a5,0x20
 3ba:	9381                	srli	a5,a5,0x20
 3bc:	97aa                	add	a5,a5,a0
 3be:	0007c783          	lbu	a5,0(a5)
 3c2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3c6:	0005879b          	sext.w	a5,a1
 3ca:	02c5d5bb          	divuw	a1,a1,a2
 3ce:	0685                	addi	a3,a3,1
 3d0:	fec7f0e3          	bgeu	a5,a2,3b0 <printint+0x2a>
  if(neg)
 3d4:	00088c63          	beqz	a7,3ec <printint+0x66>
    buf[i++] = '-';
 3d8:	fd070793          	addi	a5,a4,-48
 3dc:	00878733          	add	a4,a5,s0
 3e0:	02d00793          	li	a5,45
 3e4:	fef70823          	sb	a5,-16(a4)
 3e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3ec:	02e05863          	blez	a4,41c <printint+0x96>
 3f0:	fc040793          	addi	a5,s0,-64
 3f4:	00e78933          	add	s2,a5,a4
 3f8:	fff78993          	addi	s3,a5,-1
 3fc:	99ba                	add	s3,s3,a4
 3fe:	377d                	addiw	a4,a4,-1
 400:	1702                	slli	a4,a4,0x20
 402:	9301                	srli	a4,a4,0x20
 404:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 408:	fff94583          	lbu	a1,-1(s2)
 40c:	8526                	mv	a0,s1
 40e:	00000097          	auipc	ra,0x0
 412:	f56080e7          	jalr	-170(ra) # 364 <putc>
  while(--i >= 0)
 416:	197d                	addi	s2,s2,-1
 418:	ff3918e3          	bne	s2,s3,408 <printint+0x82>
}
 41c:	70e2                	ld	ra,56(sp)
 41e:	7442                	ld	s0,48(sp)
 420:	74a2                	ld	s1,40(sp)
 422:	7902                	ld	s2,32(sp)
 424:	69e2                	ld	s3,24(sp)
 426:	6121                	addi	sp,sp,64
 428:	8082                	ret
    x = -xx;
 42a:	40b005bb          	negw	a1,a1
    neg = 1;
 42e:	4885                	li	a7,1
    x = -xx;
 430:	bf85                	j	3a0 <printint+0x1a>

0000000000000432 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 432:	715d                	addi	sp,sp,-80
 434:	e486                	sd	ra,72(sp)
 436:	e0a2                	sd	s0,64(sp)
 438:	fc26                	sd	s1,56(sp)
 43a:	f84a                	sd	s2,48(sp)
 43c:	f44e                	sd	s3,40(sp)
 43e:	f052                	sd	s4,32(sp)
 440:	ec56                	sd	s5,24(sp)
 442:	e85a                	sd	s6,16(sp)
 444:	e45e                	sd	s7,8(sp)
 446:	e062                	sd	s8,0(sp)
 448:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 44a:	0005c903          	lbu	s2,0(a1)
 44e:	18090c63          	beqz	s2,5e6 <vprintf+0x1b4>
 452:	8aaa                	mv	s5,a0
 454:	8bb2                	mv	s7,a2
 456:	00158493          	addi	s1,a1,1
  state = 0;
 45a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 45c:	02500a13          	li	s4,37
 460:	4b55                	li	s6,21
 462:	a839                	j	480 <vprintf+0x4e>
        putc(fd, c);
 464:	85ca                	mv	a1,s2
 466:	8556                	mv	a0,s5
 468:	00000097          	auipc	ra,0x0
 46c:	efc080e7          	jalr	-260(ra) # 364 <putc>
 470:	a019                	j	476 <vprintf+0x44>
    } else if(state == '%'){
 472:	01498d63          	beq	s3,s4,48c <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 476:	0485                	addi	s1,s1,1
 478:	fff4c903          	lbu	s2,-1(s1)
 47c:	16090563          	beqz	s2,5e6 <vprintf+0x1b4>
    if(state == 0){
 480:	fe0999e3          	bnez	s3,472 <vprintf+0x40>
      if(c == '%'){
 484:	ff4910e3          	bne	s2,s4,464 <vprintf+0x32>
        state = '%';
 488:	89d2                	mv	s3,s4
 48a:	b7f5                	j	476 <vprintf+0x44>
      if(c == 'd'){
 48c:	13490263          	beq	s2,s4,5b0 <vprintf+0x17e>
 490:	f9d9079b          	addiw	a5,s2,-99
 494:	0ff7f793          	zext.b	a5,a5
 498:	12fb6563          	bltu	s6,a5,5c2 <vprintf+0x190>
 49c:	f9d9079b          	addiw	a5,s2,-99
 4a0:	0ff7f713          	zext.b	a4,a5
 4a4:	10eb6f63          	bltu	s6,a4,5c2 <vprintf+0x190>
 4a8:	00271793          	slli	a5,a4,0x2
 4ac:	00000717          	auipc	a4,0x0
 4b0:	32c70713          	addi	a4,a4,812 # 7d8 <malloc+0xf4>
 4b4:	97ba                	add	a5,a5,a4
 4b6:	439c                	lw	a5,0(a5)
 4b8:	97ba                	add	a5,a5,a4
 4ba:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4bc:	008b8913          	addi	s2,s7,8
 4c0:	4685                	li	a3,1
 4c2:	4629                	li	a2,10
 4c4:	000ba583          	lw	a1,0(s7)
 4c8:	8556                	mv	a0,s5
 4ca:	00000097          	auipc	ra,0x0
 4ce:	ebc080e7          	jalr	-324(ra) # 386 <printint>
 4d2:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4d4:	4981                	li	s3,0
 4d6:	b745                	j	476 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4d8:	008b8913          	addi	s2,s7,8
 4dc:	4681                	li	a3,0
 4de:	4629                	li	a2,10
 4e0:	000ba583          	lw	a1,0(s7)
 4e4:	8556                	mv	a0,s5
 4e6:	00000097          	auipc	ra,0x0
 4ea:	ea0080e7          	jalr	-352(ra) # 386 <printint>
 4ee:	8bca                	mv	s7,s2
      state = 0;
 4f0:	4981                	li	s3,0
 4f2:	b751                	j	476 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 4f4:	008b8913          	addi	s2,s7,8
 4f8:	4681                	li	a3,0
 4fa:	4641                	li	a2,16
 4fc:	000ba583          	lw	a1,0(s7)
 500:	8556                	mv	a0,s5
 502:	00000097          	auipc	ra,0x0
 506:	e84080e7          	jalr	-380(ra) # 386 <printint>
 50a:	8bca                	mv	s7,s2
      state = 0;
 50c:	4981                	li	s3,0
 50e:	b7a5                	j	476 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 510:	008b8c13          	addi	s8,s7,8
 514:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 518:	03000593          	li	a1,48
 51c:	8556                	mv	a0,s5
 51e:	00000097          	auipc	ra,0x0
 522:	e46080e7          	jalr	-442(ra) # 364 <putc>
  putc(fd, 'x');
 526:	07800593          	li	a1,120
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	e38080e7          	jalr	-456(ra) # 364 <putc>
 534:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 536:	00000b97          	auipc	s7,0x0
 53a:	2fab8b93          	addi	s7,s7,762 # 830 <digits>
 53e:	03c9d793          	srli	a5,s3,0x3c
 542:	97de                	add	a5,a5,s7
 544:	0007c583          	lbu	a1,0(a5)
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	e1a080e7          	jalr	-486(ra) # 364 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 552:	0992                	slli	s3,s3,0x4
 554:	397d                	addiw	s2,s2,-1
 556:	fe0914e3          	bnez	s2,53e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 55a:	8be2                	mv	s7,s8
      state = 0;
 55c:	4981                	li	s3,0
 55e:	bf21                	j	476 <vprintf+0x44>
        s = va_arg(ap, char*);
 560:	008b8993          	addi	s3,s7,8
 564:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 568:	02090163          	beqz	s2,58a <vprintf+0x158>
        while(*s != 0){
 56c:	00094583          	lbu	a1,0(s2)
 570:	c9a5                	beqz	a1,5e0 <vprintf+0x1ae>
          putc(fd, *s);
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	df0080e7          	jalr	-528(ra) # 364 <putc>
          s++;
 57c:	0905                	addi	s2,s2,1
        while(*s != 0){
 57e:	00094583          	lbu	a1,0(s2)
 582:	f9e5                	bnez	a1,572 <vprintf+0x140>
        s = va_arg(ap, char*);
 584:	8bce                	mv	s7,s3
      state = 0;
 586:	4981                	li	s3,0
 588:	b5fd                	j	476 <vprintf+0x44>
          s = "(null)";
 58a:	00000917          	auipc	s2,0x0
 58e:	24690913          	addi	s2,s2,582 # 7d0 <malloc+0xec>
        while(*s != 0){
 592:	02800593          	li	a1,40
 596:	bff1                	j	572 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 598:	008b8913          	addi	s2,s7,8
 59c:	000bc583          	lbu	a1,0(s7)
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	dc2080e7          	jalr	-574(ra) # 364 <putc>
 5aa:	8bca                	mv	s7,s2
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	b5e1                	j	476 <vprintf+0x44>
        putc(fd, c);
 5b0:	02500593          	li	a1,37
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	dae080e7          	jalr	-594(ra) # 364 <putc>
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	bd5d                	j	476 <vprintf+0x44>
        putc(fd, '%');
 5c2:	02500593          	li	a1,37
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	d9c080e7          	jalr	-612(ra) # 364 <putc>
        putc(fd, c);
 5d0:	85ca                	mv	a1,s2
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	d90080e7          	jalr	-624(ra) # 364 <putc>
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	bd61                	j	476 <vprintf+0x44>
        s = va_arg(ap, char*);
 5e0:	8bce                	mv	s7,s3
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	bd49                	j	476 <vprintf+0x44>
    }
  }
}
 5e6:	60a6                	ld	ra,72(sp)
 5e8:	6406                	ld	s0,64(sp)
 5ea:	74e2                	ld	s1,56(sp)
 5ec:	7942                	ld	s2,48(sp)
 5ee:	79a2                	ld	s3,40(sp)
 5f0:	7a02                	ld	s4,32(sp)
 5f2:	6ae2                	ld	s5,24(sp)
 5f4:	6b42                	ld	s6,16(sp)
 5f6:	6ba2                	ld	s7,8(sp)
 5f8:	6c02                	ld	s8,0(sp)
 5fa:	6161                	addi	sp,sp,80
 5fc:	8082                	ret

00000000000005fe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5fe:	715d                	addi	sp,sp,-80
 600:	ec06                	sd	ra,24(sp)
 602:	e822                	sd	s0,16(sp)
 604:	1000                	addi	s0,sp,32
 606:	e010                	sd	a2,0(s0)
 608:	e414                	sd	a3,8(s0)
 60a:	e818                	sd	a4,16(s0)
 60c:	ec1c                	sd	a5,24(s0)
 60e:	03043023          	sd	a6,32(s0)
 612:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 616:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 61a:	8622                	mv	a2,s0
 61c:	00000097          	auipc	ra,0x0
 620:	e16080e7          	jalr	-490(ra) # 432 <vprintf>
}
 624:	60e2                	ld	ra,24(sp)
 626:	6442                	ld	s0,16(sp)
 628:	6161                	addi	sp,sp,80
 62a:	8082                	ret

000000000000062c <printf>:

void
printf(const char *fmt, ...)
{
 62c:	711d                	addi	sp,sp,-96
 62e:	ec06                	sd	ra,24(sp)
 630:	e822                	sd	s0,16(sp)
 632:	1000                	addi	s0,sp,32
 634:	e40c                	sd	a1,8(s0)
 636:	e810                	sd	a2,16(s0)
 638:	ec14                	sd	a3,24(s0)
 63a:	f018                	sd	a4,32(s0)
 63c:	f41c                	sd	a5,40(s0)
 63e:	03043823          	sd	a6,48(s0)
 642:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 646:	00840613          	addi	a2,s0,8
 64a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 64e:	85aa                	mv	a1,a0
 650:	4505                	li	a0,1
 652:	00000097          	auipc	ra,0x0
 656:	de0080e7          	jalr	-544(ra) # 432 <vprintf>
}
 65a:	60e2                	ld	ra,24(sp)
 65c:	6442                	ld	s0,16(sp)
 65e:	6125                	addi	sp,sp,96
 660:	8082                	ret

0000000000000662 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 662:	1141                	addi	sp,sp,-16
 664:	e422                	sd	s0,8(sp)
 666:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 668:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66c:	00001797          	auipc	a5,0x1
 670:	9947b783          	ld	a5,-1644(a5) # 1000 <freep>
 674:	a02d                	j	69e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 676:	4618                	lw	a4,8(a2)
 678:	9f2d                	addw	a4,a4,a1
 67a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 67e:	6398                	ld	a4,0(a5)
 680:	6310                	ld	a2,0(a4)
 682:	a83d                	j	6c0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 684:	ff852703          	lw	a4,-8(a0)
 688:	9f31                	addw	a4,a4,a2
 68a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 68c:	ff053683          	ld	a3,-16(a0)
 690:	a091                	j	6d4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 692:	6398                	ld	a4,0(a5)
 694:	00e7e463          	bltu	a5,a4,69c <free+0x3a>
 698:	00e6ea63          	bltu	a3,a4,6ac <free+0x4a>
{
 69c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69e:	fed7fae3          	bgeu	a5,a3,692 <free+0x30>
 6a2:	6398                	ld	a4,0(a5)
 6a4:	00e6e463          	bltu	a3,a4,6ac <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a8:	fee7eae3          	bltu	a5,a4,69c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6ac:	ff852583          	lw	a1,-8(a0)
 6b0:	6390                	ld	a2,0(a5)
 6b2:	02059813          	slli	a6,a1,0x20
 6b6:	01c85713          	srli	a4,a6,0x1c
 6ba:	9736                	add	a4,a4,a3
 6bc:	fae60de3          	beq	a2,a4,676 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6c4:	4790                	lw	a2,8(a5)
 6c6:	02061593          	slli	a1,a2,0x20
 6ca:	01c5d713          	srli	a4,a1,0x1c
 6ce:	973e                	add	a4,a4,a5
 6d0:	fae68ae3          	beq	a3,a4,684 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6d4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6d6:	00001717          	auipc	a4,0x1
 6da:	92f73523          	sd	a5,-1750(a4) # 1000 <freep>
}
 6de:	6422                	ld	s0,8(sp)
 6e0:	0141                	addi	sp,sp,16
 6e2:	8082                	ret

00000000000006e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6e4:	7139                	addi	sp,sp,-64
 6e6:	fc06                	sd	ra,56(sp)
 6e8:	f822                	sd	s0,48(sp)
 6ea:	f426                	sd	s1,40(sp)
 6ec:	f04a                	sd	s2,32(sp)
 6ee:	ec4e                	sd	s3,24(sp)
 6f0:	e852                	sd	s4,16(sp)
 6f2:	e456                	sd	s5,8(sp)
 6f4:	e05a                	sd	s6,0(sp)
 6f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6f8:	02051493          	slli	s1,a0,0x20
 6fc:	9081                	srli	s1,s1,0x20
 6fe:	04bd                	addi	s1,s1,15
 700:	8091                	srli	s1,s1,0x4
 702:	0014899b          	addiw	s3,s1,1
 706:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 708:	00001517          	auipc	a0,0x1
 70c:	8f853503          	ld	a0,-1800(a0) # 1000 <freep>
 710:	c515                	beqz	a0,73c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 712:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 714:	4798                	lw	a4,8(a5)
 716:	02977f63          	bgeu	a4,s1,754 <malloc+0x70>
  if(nu < 4096)
 71a:	8a4e                	mv	s4,s3
 71c:	0009871b          	sext.w	a4,s3
 720:	6685                	lui	a3,0x1
 722:	00d77363          	bgeu	a4,a3,728 <malloc+0x44>
 726:	6a05                	lui	s4,0x1
 728:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 72c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 730:	00001917          	auipc	s2,0x1
 734:	8d090913          	addi	s2,s2,-1840 # 1000 <freep>
  if(p == (char*)-1)
 738:	5afd                	li	s5,-1
 73a:	a895                	j	7ae <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 73c:	00001797          	auipc	a5,0x1
 740:	8d478793          	addi	a5,a5,-1836 # 1010 <base>
 744:	00001717          	auipc	a4,0x1
 748:	8af73e23          	sd	a5,-1860(a4) # 1000 <freep>
 74c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 74e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 752:	b7e1                	j	71a <malloc+0x36>
      if(p->s.size == nunits)
 754:	02e48c63          	beq	s1,a4,78c <malloc+0xa8>
        p->s.size -= nunits;
 758:	4137073b          	subw	a4,a4,s3
 75c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 75e:	02071693          	slli	a3,a4,0x20
 762:	01c6d713          	srli	a4,a3,0x1c
 766:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 768:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 76c:	00001717          	auipc	a4,0x1
 770:	88a73a23          	sd	a0,-1900(a4) # 1000 <freep>
      return (void*)(p + 1);
 774:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 778:	70e2                	ld	ra,56(sp)
 77a:	7442                	ld	s0,48(sp)
 77c:	74a2                	ld	s1,40(sp)
 77e:	7902                	ld	s2,32(sp)
 780:	69e2                	ld	s3,24(sp)
 782:	6a42                	ld	s4,16(sp)
 784:	6aa2                	ld	s5,8(sp)
 786:	6b02                	ld	s6,0(sp)
 788:	6121                	addi	sp,sp,64
 78a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 78c:	6398                	ld	a4,0(a5)
 78e:	e118                	sd	a4,0(a0)
 790:	bff1                	j	76c <malloc+0x88>
  hp->s.size = nu;
 792:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 796:	0541                	addi	a0,a0,16
 798:	00000097          	auipc	ra,0x0
 79c:	eca080e7          	jalr	-310(ra) # 662 <free>
  return freep;
 7a0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7a4:	d971                	beqz	a0,778 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a8:	4798                	lw	a4,8(a5)
 7aa:	fa9775e3          	bgeu	a4,s1,754 <malloc+0x70>
    if(p == freep)
 7ae:	00093703          	ld	a4,0(s2)
 7b2:	853e                	mv	a0,a5
 7b4:	fef719e3          	bne	a4,a5,7a6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7b8:	8552                	mv	a0,s4
 7ba:	00000097          	auipc	ra,0x0
 7be:	b62080e7          	jalr	-1182(ra) # 31c <sbrk>
  if(p == (char*)-1)
 7c2:	fd5518e3          	bne	a0,s5,792 <malloc+0xae>
        return 0;
 7c6:	4501                	li	a0,0
 7c8:	bf45                	j	778 <malloc+0x94>
