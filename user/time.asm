
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/fcntl.h"

int 
main(int argc, char ** argv) 
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
   c:	892a                	mv	s2,a0
   e:	84ae                	mv	s1,a1
  int pid = fork();
  10:	00000097          	auipc	ra,0x0
  14:	31c080e7          	jalr	796(ra) # 32c <fork>
  if(pid < 0) {
  18:	02054a63          	bltz	a0,4c <main+0x4c>
    printf("fork(): failed\n");
    exit(1);
  } else if(pid == 0) {
  1c:	ed39                	bnez	a0,7a <main+0x7a>
    if(argc == 1) {
  1e:	4785                	li	a5,1
  20:	04f90363          	beq	s2,a5,66 <main+0x66>
      sleep(10);
      exit(0);
    } else {
      exec(argv[1], argv + 1);
  24:	00848593          	addi	a1,s1,8
  28:	6488                	ld	a0,8(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	342080e7          	jalr	834(ra) # 36c <exec>
      printf("exec(): failed\n");
  32:	00001517          	auipc	a0,0x1
  36:	84e50513          	addi	a0,a0,-1970 # 880 <malloc+0xfc>
  3a:	00000097          	auipc	ra,0x0
  3e:	692080e7          	jalr	1682(ra) # 6cc <printf>
      exit(1);
  42:	4505                	li	a0,1
  44:	00000097          	auipc	ra,0x0
  48:	2f0080e7          	jalr	752(ra) # 334 <exit>
    printf("fork(): failed\n");
  4c:	00001517          	auipc	a0,0x1
  50:	82450513          	addi	a0,a0,-2012 # 870 <malloc+0xec>
  54:	00000097          	auipc	ra,0x0
  58:	678080e7          	jalr	1656(ra) # 6cc <printf>
    exit(1);
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	2d6080e7          	jalr	726(ra) # 334 <exit>
      sleep(10);
  66:	4529                	li	a0,10
  68:	00000097          	auipc	ra,0x0
  6c:	35c080e7          	jalr	860(ra) # 3c4 <sleep>
      exit(0);
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	2c2080e7          	jalr	706(ra) # 334 <exit>
    }  
  } else {
    int rtime, wtime;
    waitx(0, &wtime, &rtime);
  7a:	fd840613          	addi	a2,s0,-40
  7e:	fdc40593          	addi	a1,s0,-36
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	368080e7          	jalr	872(ra) # 3ec <waitx>
    // similar to wait
    printf("\nwaiting:%d\nrunning:%d\n", wtime, rtime);
  8c:	fd842603          	lw	a2,-40(s0)
  90:	fdc42583          	lw	a1,-36(s0)
  94:	00000517          	auipc	a0,0x0
  98:	7fc50513          	addi	a0,a0,2044 # 890 <malloc+0x10c>
  9c:	00000097          	auipc	ra,0x0
  a0:	630080e7          	jalr	1584(ra) # 6cc <printf>
  }
  exit(0);
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	28e080e7          	jalr	654(ra) # 334 <exit>

00000000000000ae <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e406                	sd	ra,8(sp)
  b2:	e022                	sd	s0,0(sp)
  b4:	0800                	addi	s0,sp,16
  extern int main();
  main();
  b6:	00000097          	auipc	ra,0x0
  ba:	f4a080e7          	jalr	-182(ra) # 0 <main>
  exit(0);
  be:	4501                	li	a0,0
  c0:	00000097          	auipc	ra,0x0
  c4:	274080e7          	jalr	628(ra) # 334 <exit>

00000000000000c8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ce:	87aa                	mv	a5,a0
  d0:	0585                	addi	a1,a1,1
  d2:	0785                	addi	a5,a5,1
  d4:	fff5c703          	lbu	a4,-1(a1)
  d8:	fee78fa3          	sb	a4,-1(a5)
  dc:	fb75                	bnez	a4,d0 <strcpy+0x8>
    ;
  return os;
}
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	cb91                	beqz	a5,102 <strcmp+0x1e>
  f0:	0005c703          	lbu	a4,0(a1)
  f4:	00f71763          	bne	a4,a5,102 <strcmp+0x1e>
    p++, q++;
  f8:	0505                	addi	a0,a0,1
  fa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  fc:	00054783          	lbu	a5,0(a0)
 100:	fbe5                	bnez	a5,f0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 102:	0005c503          	lbu	a0,0(a1)
}
 106:	40a7853b          	subw	a0,a5,a0
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strlen>:

uint
strlen(const char *s)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cf91                	beqz	a5,136 <strlen+0x26>
 11c:	0505                	addi	a0,a0,1
 11e:	87aa                	mv	a5,a0
 120:	86be                	mv	a3,a5
 122:	0785                	addi	a5,a5,1
 124:	fff7c703          	lbu	a4,-1(a5)
 128:	ff65                	bnez	a4,120 <strlen+0x10>
 12a:	40a6853b          	subw	a0,a3,a0
 12e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret
  for(n = 0; s[n]; n++)
 136:	4501                	li	a0,0
 138:	bfe5                	j	130 <strlen+0x20>

000000000000013a <memset>:

void*
memset(void *dst, int c, uint n)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 140:	ca19                	beqz	a2,156 <memset+0x1c>
 142:	87aa                	mv	a5,a0
 144:	1602                	slli	a2,a2,0x20
 146:	9201                	srli	a2,a2,0x20
 148:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 14c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 150:	0785                	addi	a5,a5,1
 152:	fee79de3          	bne	a5,a4,14c <memset+0x12>
  }
  return dst;
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret

000000000000015c <strchr>:

char*
strchr(const char *s, char c)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e422                	sd	s0,8(sp)
 160:	0800                	addi	s0,sp,16
  for(; *s; s++)
 162:	00054783          	lbu	a5,0(a0)
 166:	cb99                	beqz	a5,17c <strchr+0x20>
    if(*s == c)
 168:	00f58763          	beq	a1,a5,176 <strchr+0x1a>
  for(; *s; s++)
 16c:	0505                	addi	a0,a0,1
 16e:	00054783          	lbu	a5,0(a0)
 172:	fbfd                	bnez	a5,168 <strchr+0xc>
      return (char*)s;
  return 0;
 174:	4501                	li	a0,0
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret
  return 0;
 17c:	4501                	li	a0,0
 17e:	bfe5                	j	176 <strchr+0x1a>

0000000000000180 <gets>:

char*
gets(char *buf, int max)
{
 180:	711d                	addi	sp,sp,-96
 182:	ec86                	sd	ra,88(sp)
 184:	e8a2                	sd	s0,80(sp)
 186:	e4a6                	sd	s1,72(sp)
 188:	e0ca                	sd	s2,64(sp)
 18a:	fc4e                	sd	s3,56(sp)
 18c:	f852                	sd	s4,48(sp)
 18e:	f456                	sd	s5,40(sp)
 190:	f05a                	sd	s6,32(sp)
 192:	ec5e                	sd	s7,24(sp)
 194:	1080                	addi	s0,sp,96
 196:	8baa                	mv	s7,a0
 198:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19a:	892a                	mv	s2,a0
 19c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 19e:	4aa9                	li	s5,10
 1a0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a2:	89a6                	mv	s3,s1
 1a4:	2485                	addiw	s1,s1,1
 1a6:	0344d863          	bge	s1,s4,1d6 <gets+0x56>
    cc = read(0, &c, 1);
 1aa:	4605                	li	a2,1
 1ac:	faf40593          	addi	a1,s0,-81
 1b0:	4501                	li	a0,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	19a080e7          	jalr	410(ra) # 34c <read>
    if(cc < 1)
 1ba:	00a05e63          	blez	a0,1d6 <gets+0x56>
    buf[i++] = c;
 1be:	faf44783          	lbu	a5,-81(s0)
 1c2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c6:	01578763          	beq	a5,s5,1d4 <gets+0x54>
 1ca:	0905                	addi	s2,s2,1
 1cc:	fd679be3          	bne	a5,s6,1a2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1d0:	89a6                	mv	s3,s1
 1d2:	a011                	j	1d6 <gets+0x56>
 1d4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d6:	99de                	add	s3,s3,s7
 1d8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1dc:	855e                	mv	a0,s7
 1de:	60e6                	ld	ra,88(sp)
 1e0:	6446                	ld	s0,80(sp)
 1e2:	64a6                	ld	s1,72(sp)
 1e4:	6906                	ld	s2,64(sp)
 1e6:	79e2                	ld	s3,56(sp)
 1e8:	7a42                	ld	s4,48(sp)
 1ea:	7aa2                	ld	s5,40(sp)
 1ec:	7b02                	ld	s6,32(sp)
 1ee:	6be2                	ld	s7,24(sp)
 1f0:	6125                	addi	sp,sp,96
 1f2:	8082                	ret

00000000000001f4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f4:	1101                	addi	sp,sp,-32
 1f6:	ec06                	sd	ra,24(sp)
 1f8:	e822                	sd	s0,16(sp)
 1fa:	e426                	sd	s1,8(sp)
 1fc:	e04a                	sd	s2,0(sp)
 1fe:	1000                	addi	s0,sp,32
 200:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 202:	4581                	li	a1,0
 204:	00000097          	auipc	ra,0x0
 208:	170080e7          	jalr	368(ra) # 374 <open>
  if(fd < 0)
 20c:	02054563          	bltz	a0,236 <stat+0x42>
 210:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 212:	85ca                	mv	a1,s2
 214:	00000097          	auipc	ra,0x0
 218:	178080e7          	jalr	376(ra) # 38c <fstat>
 21c:	892a                	mv	s2,a0
  close(fd);
 21e:	8526                	mv	a0,s1
 220:	00000097          	auipc	ra,0x0
 224:	13c080e7          	jalr	316(ra) # 35c <close>
  return r;
}
 228:	854a                	mv	a0,s2
 22a:	60e2                	ld	ra,24(sp)
 22c:	6442                	ld	s0,16(sp)
 22e:	64a2                	ld	s1,8(sp)
 230:	6902                	ld	s2,0(sp)
 232:	6105                	addi	sp,sp,32
 234:	8082                	ret
    return -1;
 236:	597d                	li	s2,-1
 238:	bfc5                	j	228 <stat+0x34>

000000000000023a <atoi>:

int
atoi(const char *s)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 240:	00054683          	lbu	a3,0(a0)
 244:	fd06879b          	addiw	a5,a3,-48
 248:	0ff7f793          	zext.b	a5,a5
 24c:	4625                	li	a2,9
 24e:	02f66863          	bltu	a2,a5,27e <atoi+0x44>
 252:	872a                	mv	a4,a0
  n = 0;
 254:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 256:	0705                	addi	a4,a4,1
 258:	0025179b          	slliw	a5,a0,0x2
 25c:	9fa9                	addw	a5,a5,a0
 25e:	0017979b          	slliw	a5,a5,0x1
 262:	9fb5                	addw	a5,a5,a3
 264:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 268:	00074683          	lbu	a3,0(a4)
 26c:	fd06879b          	addiw	a5,a3,-48
 270:	0ff7f793          	zext.b	a5,a5
 274:	fef671e3          	bgeu	a2,a5,256 <atoi+0x1c>
  return n;
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  n = 0;
 27e:	4501                	li	a0,0
 280:	bfe5                	j	278 <atoi+0x3e>

0000000000000282 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 288:	02b57463          	bgeu	a0,a1,2b0 <memmove+0x2e>
    while(n-- > 0)
 28c:	00c05f63          	blez	a2,2aa <memmove+0x28>
 290:	1602                	slli	a2,a2,0x20
 292:	9201                	srli	a2,a2,0x20
 294:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 298:	872a                	mv	a4,a0
      *dst++ = *src++;
 29a:	0585                	addi	a1,a1,1
 29c:	0705                	addi	a4,a4,1
 29e:	fff5c683          	lbu	a3,-1(a1)
 2a2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a6:	fee79ae3          	bne	a5,a4,29a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
    dst += n;
 2b0:	00c50733          	add	a4,a0,a2
    src += n;
 2b4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b6:	fec05ae3          	blez	a2,2aa <memmove+0x28>
 2ba:	fff6079b          	addiw	a5,a2,-1
 2be:	1782                	slli	a5,a5,0x20
 2c0:	9381                	srli	a5,a5,0x20
 2c2:	fff7c793          	not	a5,a5
 2c6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c8:	15fd                	addi	a1,a1,-1
 2ca:	177d                	addi	a4,a4,-1
 2cc:	0005c683          	lbu	a3,0(a1)
 2d0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d4:	fee79ae3          	bne	a5,a4,2c8 <memmove+0x46>
 2d8:	bfc9                	j	2aa <memmove+0x28>

00000000000002da <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e422                	sd	s0,8(sp)
 2de:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e0:	ca05                	beqz	a2,310 <memcmp+0x36>
 2e2:	fff6069b          	addiw	a3,a2,-1
 2e6:	1682                	slli	a3,a3,0x20
 2e8:	9281                	srli	a3,a3,0x20
 2ea:	0685                	addi	a3,a3,1
 2ec:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ee:	00054783          	lbu	a5,0(a0)
 2f2:	0005c703          	lbu	a4,0(a1)
 2f6:	00e79863          	bne	a5,a4,306 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2fa:	0505                	addi	a0,a0,1
    p2++;
 2fc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fe:	fed518e3          	bne	a0,a3,2ee <memcmp+0x14>
  }
  return 0;
 302:	4501                	li	a0,0
 304:	a019                	j	30a <memcmp+0x30>
      return *p1 - *p2;
 306:	40e7853b          	subw	a0,a5,a4
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  return 0;
 310:	4501                	li	a0,0
 312:	bfe5                	j	30a <memcmp+0x30>

0000000000000314 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31c:	00000097          	auipc	ra,0x0
 320:	f66080e7          	jalr	-154(ra) # 282 <memmove>
}
 324:	60a2                	ld	ra,8(sp)
 326:	6402                	ld	s0,0(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret

000000000000032c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 32c:	4885                	li	a7,1
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <exit>:
.global exit
exit:
 li a7, SYS_exit
 334:	4889                	li	a7,2
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <wait>:
.global wait
wait:
 li a7, SYS_wait
 33c:	488d                	li	a7,3
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 344:	4891                	li	a7,4
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <read>:
.global read
read:
 li a7, SYS_read
 34c:	4895                	li	a7,5
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <write>:
.global write
write:
 li a7, SYS_write
 354:	48c1                	li	a7,16
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <close>:
.global close
close:
 li a7, SYS_close
 35c:	48d5                	li	a7,21
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <kill>:
.global kill
kill:
 li a7, SYS_kill
 364:	4899                	li	a7,6
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <exec>:
.global exec
exec:
 li a7, SYS_exec
 36c:	489d                	li	a7,7
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <open>:
.global open
open:
 li a7, SYS_open
 374:	48bd                	li	a7,15
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 37c:	48c5                	li	a7,17
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 384:	48c9                	li	a7,18
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 38c:	48a1                	li	a7,8
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <link>:
.global link
link:
 li a7, SYS_link
 394:	48cd                	li	a7,19
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 39c:	48d1                	li	a7,20
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a4:	48a5                	li	a7,9
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ac:	48a9                	li	a7,10
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b4:	48ad                	li	a7,11
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3bc:	48b1                	li	a7,12
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c4:	48b5                	li	a7,13
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3cc:	48b9                	li	a7,14
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3d4:	48d9                	li	a7,22
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 3dc:	48dd                	li	a7,23
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3e4:	48e1                	li	a7,24
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3ec:	48e5                	li	a7,25
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 3f4:	48ed                	li	a7,27
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <set_tickets>:
.global set_tickets
set_tickets:
 li a7, SYS_set_tickets
 3fc:	48e9                	li	a7,26
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 404:	1101                	addi	sp,sp,-32
 406:	ec06                	sd	ra,24(sp)
 408:	e822                	sd	s0,16(sp)
 40a:	1000                	addi	s0,sp,32
 40c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 410:	4605                	li	a2,1
 412:	fef40593          	addi	a1,s0,-17
 416:	00000097          	auipc	ra,0x0
 41a:	f3e080e7          	jalr	-194(ra) # 354 <write>
}
 41e:	60e2                	ld	ra,24(sp)
 420:	6442                	ld	s0,16(sp)
 422:	6105                	addi	sp,sp,32
 424:	8082                	ret

0000000000000426 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 426:	7139                	addi	sp,sp,-64
 428:	fc06                	sd	ra,56(sp)
 42a:	f822                	sd	s0,48(sp)
 42c:	f426                	sd	s1,40(sp)
 42e:	f04a                	sd	s2,32(sp)
 430:	ec4e                	sd	s3,24(sp)
 432:	0080                	addi	s0,sp,64
 434:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 436:	c299                	beqz	a3,43c <printint+0x16>
 438:	0805c963          	bltz	a1,4ca <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43c:	2581                	sext.w	a1,a1
  neg = 0;
 43e:	4881                	li	a7,0
 440:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 444:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 446:	2601                	sext.w	a2,a2
 448:	00000517          	auipc	a0,0x0
 44c:	4c050513          	addi	a0,a0,1216 # 908 <digits>
 450:	883a                	mv	a6,a4
 452:	2705                	addiw	a4,a4,1
 454:	02c5f7bb          	remuw	a5,a1,a2
 458:	1782                	slli	a5,a5,0x20
 45a:	9381                	srli	a5,a5,0x20
 45c:	97aa                	add	a5,a5,a0
 45e:	0007c783          	lbu	a5,0(a5)
 462:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 466:	0005879b          	sext.w	a5,a1
 46a:	02c5d5bb          	divuw	a1,a1,a2
 46e:	0685                	addi	a3,a3,1
 470:	fec7f0e3          	bgeu	a5,a2,450 <printint+0x2a>
  if(neg)
 474:	00088c63          	beqz	a7,48c <printint+0x66>
    buf[i++] = '-';
 478:	fd070793          	addi	a5,a4,-48
 47c:	00878733          	add	a4,a5,s0
 480:	02d00793          	li	a5,45
 484:	fef70823          	sb	a5,-16(a4)
 488:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 48c:	02e05863          	blez	a4,4bc <printint+0x96>
 490:	fc040793          	addi	a5,s0,-64
 494:	00e78933          	add	s2,a5,a4
 498:	fff78993          	addi	s3,a5,-1
 49c:	99ba                	add	s3,s3,a4
 49e:	377d                	addiw	a4,a4,-1
 4a0:	1702                	slli	a4,a4,0x20
 4a2:	9301                	srli	a4,a4,0x20
 4a4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a8:	fff94583          	lbu	a1,-1(s2)
 4ac:	8526                	mv	a0,s1
 4ae:	00000097          	auipc	ra,0x0
 4b2:	f56080e7          	jalr	-170(ra) # 404 <putc>
  while(--i >= 0)
 4b6:	197d                	addi	s2,s2,-1
 4b8:	ff3918e3          	bne	s2,s3,4a8 <printint+0x82>
}
 4bc:	70e2                	ld	ra,56(sp)
 4be:	7442                	ld	s0,48(sp)
 4c0:	74a2                	ld	s1,40(sp)
 4c2:	7902                	ld	s2,32(sp)
 4c4:	69e2                	ld	s3,24(sp)
 4c6:	6121                	addi	sp,sp,64
 4c8:	8082                	ret
    x = -xx;
 4ca:	40b005bb          	negw	a1,a1
    neg = 1;
 4ce:	4885                	li	a7,1
    x = -xx;
 4d0:	bf85                	j	440 <printint+0x1a>

00000000000004d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d2:	715d                	addi	sp,sp,-80
 4d4:	e486                	sd	ra,72(sp)
 4d6:	e0a2                	sd	s0,64(sp)
 4d8:	fc26                	sd	s1,56(sp)
 4da:	f84a                	sd	s2,48(sp)
 4dc:	f44e                	sd	s3,40(sp)
 4de:	f052                	sd	s4,32(sp)
 4e0:	ec56                	sd	s5,24(sp)
 4e2:	e85a                	sd	s6,16(sp)
 4e4:	e45e                	sd	s7,8(sp)
 4e6:	e062                	sd	s8,0(sp)
 4e8:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ea:	0005c903          	lbu	s2,0(a1)
 4ee:	18090c63          	beqz	s2,686 <vprintf+0x1b4>
 4f2:	8aaa                	mv	s5,a0
 4f4:	8bb2                	mv	s7,a2
 4f6:	00158493          	addi	s1,a1,1
  state = 0;
 4fa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fc:	02500a13          	li	s4,37
 500:	4b55                	li	s6,21
 502:	a839                	j	520 <vprintf+0x4e>
        putc(fd, c);
 504:	85ca                	mv	a1,s2
 506:	8556                	mv	a0,s5
 508:	00000097          	auipc	ra,0x0
 50c:	efc080e7          	jalr	-260(ra) # 404 <putc>
 510:	a019                	j	516 <vprintf+0x44>
    } else if(state == '%'){
 512:	01498d63          	beq	s3,s4,52c <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 516:	0485                	addi	s1,s1,1
 518:	fff4c903          	lbu	s2,-1(s1)
 51c:	16090563          	beqz	s2,686 <vprintf+0x1b4>
    if(state == 0){
 520:	fe0999e3          	bnez	s3,512 <vprintf+0x40>
      if(c == '%'){
 524:	ff4910e3          	bne	s2,s4,504 <vprintf+0x32>
        state = '%';
 528:	89d2                	mv	s3,s4
 52a:	b7f5                	j	516 <vprintf+0x44>
      if(c == 'd'){
 52c:	13490263          	beq	s2,s4,650 <vprintf+0x17e>
 530:	f9d9079b          	addiw	a5,s2,-99
 534:	0ff7f793          	zext.b	a5,a5
 538:	12fb6563          	bltu	s6,a5,662 <vprintf+0x190>
 53c:	f9d9079b          	addiw	a5,s2,-99
 540:	0ff7f713          	zext.b	a4,a5
 544:	10eb6f63          	bltu	s6,a4,662 <vprintf+0x190>
 548:	00271793          	slli	a5,a4,0x2
 54c:	00000717          	auipc	a4,0x0
 550:	36470713          	addi	a4,a4,868 # 8b0 <malloc+0x12c>
 554:	97ba                	add	a5,a5,a4
 556:	439c                	lw	a5,0(a5)
 558:	97ba                	add	a5,a5,a4
 55a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 55c:	008b8913          	addi	s2,s7,8
 560:	4685                	li	a3,1
 562:	4629                	li	a2,10
 564:	000ba583          	lw	a1,0(s7)
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	ebc080e7          	jalr	-324(ra) # 426 <printint>
 572:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 574:	4981                	li	s3,0
 576:	b745                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 578:	008b8913          	addi	s2,s7,8
 57c:	4681                	li	a3,0
 57e:	4629                	li	a2,10
 580:	000ba583          	lw	a1,0(s7)
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	ea0080e7          	jalr	-352(ra) # 426 <printint>
 58e:	8bca                	mv	s7,s2
      state = 0;
 590:	4981                	li	s3,0
 592:	b751                	j	516 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 594:	008b8913          	addi	s2,s7,8
 598:	4681                	li	a3,0
 59a:	4641                	li	a2,16
 59c:	000ba583          	lw	a1,0(s7)
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e84080e7          	jalr	-380(ra) # 426 <printint>
 5aa:	8bca                	mv	s7,s2
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	b7a5                	j	516 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5b0:	008b8c13          	addi	s8,s7,8
 5b4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5b8:	03000593          	li	a1,48
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e46080e7          	jalr	-442(ra) # 404 <putc>
  putc(fd, 'x');
 5c6:	07800593          	li	a1,120
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	e38080e7          	jalr	-456(ra) # 404 <putc>
 5d4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d6:	00000b97          	auipc	s7,0x0
 5da:	332b8b93          	addi	s7,s7,818 # 908 <digits>
 5de:	03c9d793          	srli	a5,s3,0x3c
 5e2:	97de                	add	a5,a5,s7
 5e4:	0007c583          	lbu	a1,0(a5)
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	e1a080e7          	jalr	-486(ra) # 404 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f2:	0992                	slli	s3,s3,0x4
 5f4:	397d                	addiw	s2,s2,-1
 5f6:	fe0914e3          	bnez	s2,5de <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5fa:	8be2                	mv	s7,s8
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	bf21                	j	516 <vprintf+0x44>
        s = va_arg(ap, char*);
 600:	008b8993          	addi	s3,s7,8
 604:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 608:	02090163          	beqz	s2,62a <vprintf+0x158>
        while(*s != 0){
 60c:	00094583          	lbu	a1,0(s2)
 610:	c9a5                	beqz	a1,680 <vprintf+0x1ae>
          putc(fd, *s);
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	df0080e7          	jalr	-528(ra) # 404 <putc>
          s++;
 61c:	0905                	addi	s2,s2,1
        while(*s != 0){
 61e:	00094583          	lbu	a1,0(s2)
 622:	f9e5                	bnez	a1,612 <vprintf+0x140>
        s = va_arg(ap, char*);
 624:	8bce                	mv	s7,s3
      state = 0;
 626:	4981                	li	s3,0
 628:	b5fd                	j	516 <vprintf+0x44>
          s = "(null)";
 62a:	00000917          	auipc	s2,0x0
 62e:	27e90913          	addi	s2,s2,638 # 8a8 <malloc+0x124>
        while(*s != 0){
 632:	02800593          	li	a1,40
 636:	bff1                	j	612 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 638:	008b8913          	addi	s2,s7,8
 63c:	000bc583          	lbu	a1,0(s7)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	dc2080e7          	jalr	-574(ra) # 404 <putc>
 64a:	8bca                	mv	s7,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b5e1                	j	516 <vprintf+0x44>
        putc(fd, c);
 650:	02500593          	li	a1,37
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	dae080e7          	jalr	-594(ra) # 404 <putc>
      state = 0;
 65e:	4981                	li	s3,0
 660:	bd5d                	j	516 <vprintf+0x44>
        putc(fd, '%');
 662:	02500593          	li	a1,37
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	d9c080e7          	jalr	-612(ra) # 404 <putc>
        putc(fd, c);
 670:	85ca                	mv	a1,s2
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	d90080e7          	jalr	-624(ra) # 404 <putc>
      state = 0;
 67c:	4981                	li	s3,0
 67e:	bd61                	j	516 <vprintf+0x44>
        s = va_arg(ap, char*);
 680:	8bce                	mv	s7,s3
      state = 0;
 682:	4981                	li	s3,0
 684:	bd49                	j	516 <vprintf+0x44>
    }
  }
}
 686:	60a6                	ld	ra,72(sp)
 688:	6406                	ld	s0,64(sp)
 68a:	74e2                	ld	s1,56(sp)
 68c:	7942                	ld	s2,48(sp)
 68e:	79a2                	ld	s3,40(sp)
 690:	7a02                	ld	s4,32(sp)
 692:	6ae2                	ld	s5,24(sp)
 694:	6b42                	ld	s6,16(sp)
 696:	6ba2                	ld	s7,8(sp)
 698:	6c02                	ld	s8,0(sp)
 69a:	6161                	addi	sp,sp,80
 69c:	8082                	ret

000000000000069e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 69e:	715d                	addi	sp,sp,-80
 6a0:	ec06                	sd	ra,24(sp)
 6a2:	e822                	sd	s0,16(sp)
 6a4:	1000                	addi	s0,sp,32
 6a6:	e010                	sd	a2,0(s0)
 6a8:	e414                	sd	a3,8(s0)
 6aa:	e818                	sd	a4,16(s0)
 6ac:	ec1c                	sd	a5,24(s0)
 6ae:	03043023          	sd	a6,32(s0)
 6b2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ba:	8622                	mv	a2,s0
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e16080e7          	jalr	-490(ra) # 4d2 <vprintf>
}
 6c4:	60e2                	ld	ra,24(sp)
 6c6:	6442                	ld	s0,16(sp)
 6c8:	6161                	addi	sp,sp,80
 6ca:	8082                	ret

00000000000006cc <printf>:

void
printf(const char *fmt, ...)
{
 6cc:	711d                	addi	sp,sp,-96
 6ce:	ec06                	sd	ra,24(sp)
 6d0:	e822                	sd	s0,16(sp)
 6d2:	1000                	addi	s0,sp,32
 6d4:	e40c                	sd	a1,8(s0)
 6d6:	e810                	sd	a2,16(s0)
 6d8:	ec14                	sd	a3,24(s0)
 6da:	f018                	sd	a4,32(s0)
 6dc:	f41c                	sd	a5,40(s0)
 6de:	03043823          	sd	a6,48(s0)
 6e2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e6:	00840613          	addi	a2,s0,8
 6ea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ee:	85aa                	mv	a1,a0
 6f0:	4505                	li	a0,1
 6f2:	00000097          	auipc	ra,0x0
 6f6:	de0080e7          	jalr	-544(ra) # 4d2 <vprintf>
}
 6fa:	60e2                	ld	ra,24(sp)
 6fc:	6442                	ld	s0,16(sp)
 6fe:	6125                	addi	sp,sp,96
 700:	8082                	ret

0000000000000702 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 702:	1141                	addi	sp,sp,-16
 704:	e422                	sd	s0,8(sp)
 706:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 708:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70c:	00001797          	auipc	a5,0x1
 710:	8f47b783          	ld	a5,-1804(a5) # 1000 <freep>
 714:	a02d                	j	73e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 716:	4618                	lw	a4,8(a2)
 718:	9f2d                	addw	a4,a4,a1
 71a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 71e:	6398                	ld	a4,0(a5)
 720:	6310                	ld	a2,0(a4)
 722:	a83d                	j	760 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 724:	ff852703          	lw	a4,-8(a0)
 728:	9f31                	addw	a4,a4,a2
 72a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 72c:	ff053683          	ld	a3,-16(a0)
 730:	a091                	j	774 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 732:	6398                	ld	a4,0(a5)
 734:	00e7e463          	bltu	a5,a4,73c <free+0x3a>
 738:	00e6ea63          	bltu	a3,a4,74c <free+0x4a>
{
 73c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73e:	fed7fae3          	bgeu	a5,a3,732 <free+0x30>
 742:	6398                	ld	a4,0(a5)
 744:	00e6e463          	bltu	a3,a4,74c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 748:	fee7eae3          	bltu	a5,a4,73c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 74c:	ff852583          	lw	a1,-8(a0)
 750:	6390                	ld	a2,0(a5)
 752:	02059813          	slli	a6,a1,0x20
 756:	01c85713          	srli	a4,a6,0x1c
 75a:	9736                	add	a4,a4,a3
 75c:	fae60de3          	beq	a2,a4,716 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 760:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 764:	4790                	lw	a2,8(a5)
 766:	02061593          	slli	a1,a2,0x20
 76a:	01c5d713          	srli	a4,a1,0x1c
 76e:	973e                	add	a4,a4,a5
 770:	fae68ae3          	beq	a3,a4,724 <free+0x22>
    p->s.ptr = bp->s.ptr;
 774:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 776:	00001717          	auipc	a4,0x1
 77a:	88f73523          	sd	a5,-1910(a4) # 1000 <freep>
}
 77e:	6422                	ld	s0,8(sp)
 780:	0141                	addi	sp,sp,16
 782:	8082                	ret

0000000000000784 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 784:	7139                	addi	sp,sp,-64
 786:	fc06                	sd	ra,56(sp)
 788:	f822                	sd	s0,48(sp)
 78a:	f426                	sd	s1,40(sp)
 78c:	f04a                	sd	s2,32(sp)
 78e:	ec4e                	sd	s3,24(sp)
 790:	e852                	sd	s4,16(sp)
 792:	e456                	sd	s5,8(sp)
 794:	e05a                	sd	s6,0(sp)
 796:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 798:	02051493          	slli	s1,a0,0x20
 79c:	9081                	srli	s1,s1,0x20
 79e:	04bd                	addi	s1,s1,15
 7a0:	8091                	srli	s1,s1,0x4
 7a2:	0014899b          	addiw	s3,s1,1
 7a6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7a8:	00001517          	auipc	a0,0x1
 7ac:	85853503          	ld	a0,-1960(a0) # 1000 <freep>
 7b0:	c515                	beqz	a0,7dc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b4:	4798                	lw	a4,8(a5)
 7b6:	02977f63          	bgeu	a4,s1,7f4 <malloc+0x70>
  if(nu < 4096)
 7ba:	8a4e                	mv	s4,s3
 7bc:	0009871b          	sext.w	a4,s3
 7c0:	6685                	lui	a3,0x1
 7c2:	00d77363          	bgeu	a4,a3,7c8 <malloc+0x44>
 7c6:	6a05                	lui	s4,0x1
 7c8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7cc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d0:	00001917          	auipc	s2,0x1
 7d4:	83090913          	addi	s2,s2,-2000 # 1000 <freep>
  if(p == (char*)-1)
 7d8:	5afd                	li	s5,-1
 7da:	a895                	j	84e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7dc:	00001797          	auipc	a5,0x1
 7e0:	83478793          	addi	a5,a5,-1996 # 1010 <base>
 7e4:	00001717          	auipc	a4,0x1
 7e8:	80f73e23          	sd	a5,-2020(a4) # 1000 <freep>
 7ec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ee:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f2:	b7e1                	j	7ba <malloc+0x36>
      if(p->s.size == nunits)
 7f4:	02e48c63          	beq	s1,a4,82c <malloc+0xa8>
        p->s.size -= nunits;
 7f8:	4137073b          	subw	a4,a4,s3
 7fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7fe:	02071693          	slli	a3,a4,0x20
 802:	01c6d713          	srli	a4,a3,0x1c
 806:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 808:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80c:	00000717          	auipc	a4,0x0
 810:	7ea73a23          	sd	a0,2036(a4) # 1000 <freep>
      return (void*)(p + 1);
 814:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 818:	70e2                	ld	ra,56(sp)
 81a:	7442                	ld	s0,48(sp)
 81c:	74a2                	ld	s1,40(sp)
 81e:	7902                	ld	s2,32(sp)
 820:	69e2                	ld	s3,24(sp)
 822:	6a42                	ld	s4,16(sp)
 824:	6aa2                	ld	s5,8(sp)
 826:	6b02                	ld	s6,0(sp)
 828:	6121                	addi	sp,sp,64
 82a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 82c:	6398                	ld	a4,0(a5)
 82e:	e118                	sd	a4,0(a0)
 830:	bff1                	j	80c <malloc+0x88>
  hp->s.size = nu;
 832:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 836:	0541                	addi	a0,a0,16
 838:	00000097          	auipc	ra,0x0
 83c:	eca080e7          	jalr	-310(ra) # 702 <free>
  return freep;
 840:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 844:	d971                	beqz	a0,818 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 846:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 848:	4798                	lw	a4,8(a5)
 84a:	fa9775e3          	bgeu	a4,s1,7f4 <malloc+0x70>
    if(p == freep)
 84e:	00093703          	ld	a4,0(s2)
 852:	853e                	mv	a0,a5
 854:	fef719e3          	bne	a4,a5,846 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 858:	8552                	mv	a0,s4
 85a:	00000097          	auipc	ra,0x0
 85e:	b62080e7          	jalr	-1182(ra) # 3bc <sbrk>
  if(p == (char*)-1)
 862:	fd5518e3          	bne	a0,s5,832 <malloc+0xae>
        return 0;
 866:	4501                	li	a0,0
 868:	bf45                	j	818 <malloc+0x94>
