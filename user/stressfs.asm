
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	8ea78793          	addi	a5,a5,-1814 # 900 <malloc+0x11e>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	8a450513          	addi	a0,a0,-1884 # 8d0 <malloc+0xee>
  34:	00000097          	auipc	ra,0x0
  38:	6f6080e7          	jalr	1782(ra) # 72a <printf>
  memset(data, 'a', sizeof(data));
  3c:	20000613          	li	a2,512
  40:	06100593          	li	a1,97
  44:	dd040513          	addi	a0,s0,-560
  48:	00000097          	auipc	ra,0x0
  4c:	150080e7          	jalr	336(ra) # 198 <memset>

  for(i = 0; i < 4; i++)
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
    if(fork() > 0)
  54:	00000097          	auipc	ra,0x0
  58:	336080e7          	jalr	822(ra) # 38a <fork>
  5c:	00a04563          	bgtz	a0,66 <main+0x66>
  for(i = 0; i < 4; i++)
  60:	2485                	addiw	s1,s1,1
  62:	ff2499e3          	bne	s1,s2,54 <main+0x54>
      break;

  printf("write %d\n", i);
  66:	85a6                	mv	a1,s1
  68:	00001517          	auipc	a0,0x1
  6c:	88050513          	addi	a0,a0,-1920 # 8e8 <malloc+0x106>
  70:	00000097          	auipc	ra,0x0
  74:	6ba080e7          	jalr	1722(ra) # 72a <printf>

  path[8] += i;
  78:	fd844783          	lbu	a5,-40(s0)
  7c:	9fa5                	addw	a5,a5,s1
  7e:	fcf40c23          	sb	a5,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  82:	20200593          	li	a1,514
  86:	fd040513          	addi	a0,s0,-48
  8a:	00000097          	auipc	ra,0x0
  8e:	348080e7          	jalr	840(ra) # 3d2 <open>
  92:	892a                	mv	s2,a0
  94:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  96:	20000613          	li	a2,512
  9a:	dd040593          	addi	a1,s0,-560
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	312080e7          	jalr	786(ra) # 3b2 <write>
  for(i = 0; i < 20; i++)
  a8:	34fd                	addiw	s1,s1,-1
  aa:	f4f5                	bnez	s1,96 <main+0x96>
  close(fd);
  ac:	854a                	mv	a0,s2
  ae:	00000097          	auipc	ra,0x0
  b2:	30c080e7          	jalr	780(ra) # 3ba <close>

  printf("read\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	84250513          	addi	a0,a0,-1982 # 8f8 <malloc+0x116>
  be:	00000097          	auipc	ra,0x0
  c2:	66c080e7          	jalr	1644(ra) # 72a <printf>

  fd = open(path, O_RDONLY);
  c6:	4581                	li	a1,0
  c8:	fd040513          	addi	a0,s0,-48
  cc:	00000097          	auipc	ra,0x0
  d0:	306080e7          	jalr	774(ra) # 3d2 <open>
  d4:	892a                	mv	s2,a0
  d6:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  d8:	20000613          	li	a2,512
  dc:	dd040593          	addi	a1,s0,-560
  e0:	854a                	mv	a0,s2
  e2:	00000097          	auipc	ra,0x0
  e6:	2c8080e7          	jalr	712(ra) # 3aa <read>
  for (i = 0; i < 20; i++)
  ea:	34fd                	addiw	s1,s1,-1
  ec:	f4f5                	bnez	s1,d8 <main+0xd8>
  close(fd);
  ee:	854a                	mv	a0,s2
  f0:	00000097          	auipc	ra,0x0
  f4:	2ca080e7          	jalr	714(ra) # 3ba <close>

  wait(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	2a0080e7          	jalr	672(ra) # 39a <wait>

  exit(0);
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	28e080e7          	jalr	654(ra) # 392 <exit>

000000000000010c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	addi	s0,sp,16
  extern int main();
  main();
 114:	00000097          	auipc	ra,0x0
 118:	eec080e7          	jalr	-276(ra) # 0 <main>
  exit(0);
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	274080e7          	jalr	628(ra) # 392 <exit>

0000000000000126 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12c:	87aa                	mv	a5,a0
 12e:	0585                	addi	a1,a1,1
 130:	0785                	addi	a5,a5,1
 132:	fff5c703          	lbu	a4,-1(a1)
 136:	fee78fa3          	sb	a4,-1(a5)
 13a:	fb75                	bnez	a4,12e <strcpy+0x8>
    ;
  return os;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 148:	00054783          	lbu	a5,0(a0)
 14c:	cb91                	beqz	a5,160 <strcmp+0x1e>
 14e:	0005c703          	lbu	a4,0(a1)
 152:	00f71763          	bne	a4,a5,160 <strcmp+0x1e>
    p++, q++;
 156:	0505                	addi	a0,a0,1
 158:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbe5                	bnez	a5,14e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 160:	0005c503          	lbu	a0,0(a1)
}
 164:	40a7853b          	subw	a0,a5,a0
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strlen>:

uint
strlen(const char *s)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 174:	00054783          	lbu	a5,0(a0)
 178:	cf91                	beqz	a5,194 <strlen+0x26>
 17a:	0505                	addi	a0,a0,1
 17c:	87aa                	mv	a5,a0
 17e:	86be                	mv	a3,a5
 180:	0785                	addi	a5,a5,1
 182:	fff7c703          	lbu	a4,-1(a5)
 186:	ff65                	bnez	a4,17e <strlen+0x10>
 188:	40a6853b          	subw	a0,a3,a0
 18c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret
  for(n = 0; s[n]; n++)
 194:	4501                	li	a0,0
 196:	bfe5                	j	18e <strlen+0x20>

0000000000000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19e:	ca19                	beqz	a2,1b4 <memset+0x1c>
 1a0:	87aa                	mv	a5,a0
 1a2:	1602                	slli	a2,a2,0x20
 1a4:	9201                	srli	a2,a2,0x20
 1a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1aa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ae:	0785                	addi	a5,a5,1
 1b0:	fee79de3          	bne	a5,a4,1aa <memset+0x12>
  }
  return dst;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strchr>:

char*
strchr(const char *s, char c)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cb99                	beqz	a5,1da <strchr+0x20>
    if(*s == c)
 1c6:	00f58763          	beq	a1,a5,1d4 <strchr+0x1a>
  for(; *s; s++)
 1ca:	0505                	addi	a0,a0,1
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	fbfd                	bnez	a5,1c6 <strchr+0xc>
      return (char*)s;
  return 0;
 1d2:	4501                	li	a0,0
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  return 0;
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strchr+0x1a>

00000000000001de <gets>:

char*
gets(char *buf, int max)
{
 1de:	711d                	addi	sp,sp,-96
 1e0:	ec86                	sd	ra,88(sp)
 1e2:	e8a2                	sd	s0,80(sp)
 1e4:	e4a6                	sd	s1,72(sp)
 1e6:	e0ca                	sd	s2,64(sp)
 1e8:	fc4e                	sd	s3,56(sp)
 1ea:	f852                	sd	s4,48(sp)
 1ec:	f456                	sd	s5,40(sp)
 1ee:	f05a                	sd	s6,32(sp)
 1f0:	ec5e                	sd	s7,24(sp)
 1f2:	1080                	addi	s0,sp,96
 1f4:	8baa                	mv	s7,a0
 1f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f8:	892a                	mv	s2,a0
 1fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fc:	4aa9                	li	s5,10
 1fe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 200:	89a6                	mv	s3,s1
 202:	2485                	addiw	s1,s1,1
 204:	0344d863          	bge	s1,s4,234 <gets+0x56>
    cc = read(0, &c, 1);
 208:	4605                	li	a2,1
 20a:	faf40593          	addi	a1,s0,-81
 20e:	4501                	li	a0,0
 210:	00000097          	auipc	ra,0x0
 214:	19a080e7          	jalr	410(ra) # 3aa <read>
    if(cc < 1)
 218:	00a05e63          	blez	a0,234 <gets+0x56>
    buf[i++] = c;
 21c:	faf44783          	lbu	a5,-81(s0)
 220:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 224:	01578763          	beq	a5,s5,232 <gets+0x54>
 228:	0905                	addi	s2,s2,1
 22a:	fd679be3          	bne	a5,s6,200 <gets+0x22>
  for(i=0; i+1 < max; ){
 22e:	89a6                	mv	s3,s1
 230:	a011                	j	234 <gets+0x56>
 232:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 234:	99de                	add	s3,s3,s7
 236:	00098023          	sb	zero,0(s3)
  return buf;
}
 23a:	855e                	mv	a0,s7
 23c:	60e6                	ld	ra,88(sp)
 23e:	6446                	ld	s0,80(sp)
 240:	64a6                	ld	s1,72(sp)
 242:	6906                	ld	s2,64(sp)
 244:	79e2                	ld	s3,56(sp)
 246:	7a42                	ld	s4,48(sp)
 248:	7aa2                	ld	s5,40(sp)
 24a:	7b02                	ld	s6,32(sp)
 24c:	6be2                	ld	s7,24(sp)
 24e:	6125                	addi	sp,sp,96
 250:	8082                	ret

0000000000000252 <stat>:

int
stat(const char *n, struct stat *st)
{
 252:	1101                	addi	sp,sp,-32
 254:	ec06                	sd	ra,24(sp)
 256:	e822                	sd	s0,16(sp)
 258:	e426                	sd	s1,8(sp)
 25a:	e04a                	sd	s2,0(sp)
 25c:	1000                	addi	s0,sp,32
 25e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 260:	4581                	li	a1,0
 262:	00000097          	auipc	ra,0x0
 266:	170080e7          	jalr	368(ra) # 3d2 <open>
  if(fd < 0)
 26a:	02054563          	bltz	a0,294 <stat+0x42>
 26e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 270:	85ca                	mv	a1,s2
 272:	00000097          	auipc	ra,0x0
 276:	178080e7          	jalr	376(ra) # 3ea <fstat>
 27a:	892a                	mv	s2,a0
  close(fd);
 27c:	8526                	mv	a0,s1
 27e:	00000097          	auipc	ra,0x0
 282:	13c080e7          	jalr	316(ra) # 3ba <close>
  return r;
}
 286:	854a                	mv	a0,s2
 288:	60e2                	ld	ra,24(sp)
 28a:	6442                	ld	s0,16(sp)
 28c:	64a2                	ld	s1,8(sp)
 28e:	6902                	ld	s2,0(sp)
 290:	6105                	addi	sp,sp,32
 292:	8082                	ret
    return -1;
 294:	597d                	li	s2,-1
 296:	bfc5                	j	286 <stat+0x34>

0000000000000298 <atoi>:

int
atoi(const char *s)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29e:	00054683          	lbu	a3,0(a0)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	4625                	li	a2,9
 2ac:	02f66863          	bltu	a2,a5,2dc <atoi+0x44>
 2b0:	872a                	mv	a4,a0
  n = 0;
 2b2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b4:	0705                	addi	a4,a4,1
 2b6:	0025179b          	slliw	a5,a0,0x2
 2ba:	9fa9                	addw	a5,a5,a0
 2bc:	0017979b          	slliw	a5,a5,0x1
 2c0:	9fb5                	addw	a5,a5,a3
 2c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c6:	00074683          	lbu	a3,0(a4)
 2ca:	fd06879b          	addiw	a5,a3,-48
 2ce:	0ff7f793          	zext.b	a5,a5
 2d2:	fef671e3          	bgeu	a2,a5,2b4 <atoi+0x1c>
  return n;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret
  n = 0;
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <atoi+0x3e>

00000000000002e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e6:	02b57463          	bgeu	a0,a1,30e <memmove+0x2e>
    while(n-- > 0)
 2ea:	00c05f63          	blez	a2,308 <memmove+0x28>
 2ee:	1602                	slli	a2,a2,0x20
 2f0:	9201                	srli	a2,a2,0x20
 2f2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f8:	0585                	addi	a1,a1,1
 2fa:	0705                	addi	a4,a4,1
 2fc:	fff5c683          	lbu	a3,-1(a1)
 300:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 304:	fee79ae3          	bne	a5,a4,2f8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
    dst += n;
 30e:	00c50733          	add	a4,a0,a2
    src += n;
 312:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 314:	fec05ae3          	blez	a2,308 <memmove+0x28>
 318:	fff6079b          	addiw	a5,a2,-1
 31c:	1782                	slli	a5,a5,0x20
 31e:	9381                	srli	a5,a5,0x20
 320:	fff7c793          	not	a5,a5
 324:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 326:	15fd                	addi	a1,a1,-1
 328:	177d                	addi	a4,a4,-1
 32a:	0005c683          	lbu	a3,0(a1)
 32e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 332:	fee79ae3          	bne	a5,a4,326 <memmove+0x46>
 336:	bfc9                	j	308 <memmove+0x28>

0000000000000338 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33e:	ca05                	beqz	a2,36e <memcmp+0x36>
 340:	fff6069b          	addiw	a3,a2,-1
 344:	1682                	slli	a3,a3,0x20
 346:	9281                	srli	a3,a3,0x20
 348:	0685                	addi	a3,a3,1
 34a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 34c:	00054783          	lbu	a5,0(a0)
 350:	0005c703          	lbu	a4,0(a1)
 354:	00e79863          	bne	a5,a4,364 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 358:	0505                	addi	a0,a0,1
    p2++;
 35a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 35c:	fed518e3          	bne	a0,a3,34c <memcmp+0x14>
  }
  return 0;
 360:	4501                	li	a0,0
 362:	a019                	j	368 <memcmp+0x30>
      return *p1 - *p2;
 364:	40e7853b          	subw	a0,a5,a4
}
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret
  return 0;
 36e:	4501                	li	a0,0
 370:	bfe5                	j	368 <memcmp+0x30>

0000000000000372 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 372:	1141                	addi	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 37a:	00000097          	auipc	ra,0x0
 37e:	f66080e7          	jalr	-154(ra) # 2e0 <memmove>
}
 382:	60a2                	ld	ra,8(sp)
 384:	6402                	ld	s0,0(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret

000000000000038a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38a:	4885                	li	a7,1
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exit>:
.global exit
exit:
 li a7, SYS_exit
 392:	4889                	li	a7,2
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <wait>:
.global wait
wait:
 li a7, SYS_wait
 39a:	488d                	li	a7,3
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a2:	4891                	li	a7,4
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <read>:
.global read
read:
 li a7, SYS_read
 3aa:	4895                	li	a7,5
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <write>:
.global write
write:
 li a7, SYS_write
 3b2:	48c1                	li	a7,16
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <close>:
.global close
close:
 li a7, SYS_close
 3ba:	48d5                	li	a7,21
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c2:	4899                	li	a7,6
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ca:	489d                	li	a7,7
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <open>:
.global open
open:
 li a7, SYS_open
 3d2:	48bd                	li	a7,15
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3da:	48c5                	li	a7,17
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e2:	48c9                	li	a7,18
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ea:	48a1                	li	a7,8
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <link>:
.global link
link:
 li a7, SYS_link
 3f2:	48cd                	li	a7,19
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fa:	48d1                	li	a7,20
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 402:	48a5                	li	a7,9
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <dup>:
.global dup
dup:
 li a7, SYS_dup
 40a:	48a9                	li	a7,10
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 412:	48ad                	li	a7,11
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 41a:	48b1                	li	a7,12
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 422:	48b5                	li	a7,13
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42a:	48b9                	li	a7,14
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <trace>:
.global trace
trace:
 li a7, SYS_trace
 432:	48d9                	li	a7,22
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 43a:	48dd                	li	a7,23
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 442:	48e1                	li	a7,24
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 44a:	48e5                	li	a7,25
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 452:	48ed                	li	a7,27
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <set_tickets>:
.global set_tickets
set_tickets:
 li a7, SYS_set_tickets
 45a:	48e9                	li	a7,26
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 462:	1101                	addi	sp,sp,-32
 464:	ec06                	sd	ra,24(sp)
 466:	e822                	sd	s0,16(sp)
 468:	1000                	addi	s0,sp,32
 46a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 46e:	4605                	li	a2,1
 470:	fef40593          	addi	a1,s0,-17
 474:	00000097          	auipc	ra,0x0
 478:	f3e080e7          	jalr	-194(ra) # 3b2 <write>
}
 47c:	60e2                	ld	ra,24(sp)
 47e:	6442                	ld	s0,16(sp)
 480:	6105                	addi	sp,sp,32
 482:	8082                	ret

0000000000000484 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 484:	7139                	addi	sp,sp,-64
 486:	fc06                	sd	ra,56(sp)
 488:	f822                	sd	s0,48(sp)
 48a:	f426                	sd	s1,40(sp)
 48c:	f04a                	sd	s2,32(sp)
 48e:	ec4e                	sd	s3,24(sp)
 490:	0080                	addi	s0,sp,64
 492:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 494:	c299                	beqz	a3,49a <printint+0x16>
 496:	0805c963          	bltz	a1,528 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 49a:	2581                	sext.w	a1,a1
  neg = 0;
 49c:	4881                	li	a7,0
 49e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4a2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a4:	2601                	sext.w	a2,a2
 4a6:	00000517          	auipc	a0,0x0
 4aa:	4ca50513          	addi	a0,a0,1226 # 970 <digits>
 4ae:	883a                	mv	a6,a4
 4b0:	2705                	addiw	a4,a4,1
 4b2:	02c5f7bb          	remuw	a5,a1,a2
 4b6:	1782                	slli	a5,a5,0x20
 4b8:	9381                	srli	a5,a5,0x20
 4ba:	97aa                	add	a5,a5,a0
 4bc:	0007c783          	lbu	a5,0(a5)
 4c0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c4:	0005879b          	sext.w	a5,a1
 4c8:	02c5d5bb          	divuw	a1,a1,a2
 4cc:	0685                	addi	a3,a3,1
 4ce:	fec7f0e3          	bgeu	a5,a2,4ae <printint+0x2a>
  if(neg)
 4d2:	00088c63          	beqz	a7,4ea <printint+0x66>
    buf[i++] = '-';
 4d6:	fd070793          	addi	a5,a4,-48
 4da:	00878733          	add	a4,a5,s0
 4de:	02d00793          	li	a5,45
 4e2:	fef70823          	sb	a5,-16(a4)
 4e6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ea:	02e05863          	blez	a4,51a <printint+0x96>
 4ee:	fc040793          	addi	a5,s0,-64
 4f2:	00e78933          	add	s2,a5,a4
 4f6:	fff78993          	addi	s3,a5,-1
 4fa:	99ba                	add	s3,s3,a4
 4fc:	377d                	addiw	a4,a4,-1
 4fe:	1702                	slli	a4,a4,0x20
 500:	9301                	srli	a4,a4,0x20
 502:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 506:	fff94583          	lbu	a1,-1(s2)
 50a:	8526                	mv	a0,s1
 50c:	00000097          	auipc	ra,0x0
 510:	f56080e7          	jalr	-170(ra) # 462 <putc>
  while(--i >= 0)
 514:	197d                	addi	s2,s2,-1
 516:	ff3918e3          	bne	s2,s3,506 <printint+0x82>
}
 51a:	70e2                	ld	ra,56(sp)
 51c:	7442                	ld	s0,48(sp)
 51e:	74a2                	ld	s1,40(sp)
 520:	7902                	ld	s2,32(sp)
 522:	69e2                	ld	s3,24(sp)
 524:	6121                	addi	sp,sp,64
 526:	8082                	ret
    x = -xx;
 528:	40b005bb          	negw	a1,a1
    neg = 1;
 52c:	4885                	li	a7,1
    x = -xx;
 52e:	bf85                	j	49e <printint+0x1a>

0000000000000530 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 530:	715d                	addi	sp,sp,-80
 532:	e486                	sd	ra,72(sp)
 534:	e0a2                	sd	s0,64(sp)
 536:	fc26                	sd	s1,56(sp)
 538:	f84a                	sd	s2,48(sp)
 53a:	f44e                	sd	s3,40(sp)
 53c:	f052                	sd	s4,32(sp)
 53e:	ec56                	sd	s5,24(sp)
 540:	e85a                	sd	s6,16(sp)
 542:	e45e                	sd	s7,8(sp)
 544:	e062                	sd	s8,0(sp)
 546:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 548:	0005c903          	lbu	s2,0(a1)
 54c:	18090c63          	beqz	s2,6e4 <vprintf+0x1b4>
 550:	8aaa                	mv	s5,a0
 552:	8bb2                	mv	s7,a2
 554:	00158493          	addi	s1,a1,1
  state = 0;
 558:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 55a:	02500a13          	li	s4,37
 55e:	4b55                	li	s6,21
 560:	a839                	j	57e <vprintf+0x4e>
        putc(fd, c);
 562:	85ca                	mv	a1,s2
 564:	8556                	mv	a0,s5
 566:	00000097          	auipc	ra,0x0
 56a:	efc080e7          	jalr	-260(ra) # 462 <putc>
 56e:	a019                	j	574 <vprintf+0x44>
    } else if(state == '%'){
 570:	01498d63          	beq	s3,s4,58a <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 574:	0485                	addi	s1,s1,1
 576:	fff4c903          	lbu	s2,-1(s1)
 57a:	16090563          	beqz	s2,6e4 <vprintf+0x1b4>
    if(state == 0){
 57e:	fe0999e3          	bnez	s3,570 <vprintf+0x40>
      if(c == '%'){
 582:	ff4910e3          	bne	s2,s4,562 <vprintf+0x32>
        state = '%';
 586:	89d2                	mv	s3,s4
 588:	b7f5                	j	574 <vprintf+0x44>
      if(c == 'd'){
 58a:	13490263          	beq	s2,s4,6ae <vprintf+0x17e>
 58e:	f9d9079b          	addiw	a5,s2,-99
 592:	0ff7f793          	zext.b	a5,a5
 596:	12fb6563          	bltu	s6,a5,6c0 <vprintf+0x190>
 59a:	f9d9079b          	addiw	a5,s2,-99
 59e:	0ff7f713          	zext.b	a4,a5
 5a2:	10eb6f63          	bltu	s6,a4,6c0 <vprintf+0x190>
 5a6:	00271793          	slli	a5,a4,0x2
 5aa:	00000717          	auipc	a4,0x0
 5ae:	36e70713          	addi	a4,a4,878 # 918 <malloc+0x136>
 5b2:	97ba                	add	a5,a5,a4
 5b4:	439c                	lw	a5,0(a5)
 5b6:	97ba                	add	a5,a5,a4
 5b8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5ba:	008b8913          	addi	s2,s7,8
 5be:	4685                	li	a3,1
 5c0:	4629                	li	a2,10
 5c2:	000ba583          	lw	a1,0(s7)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	ebc080e7          	jalr	-324(ra) # 484 <printint>
 5d0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b745                	j	574 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4681                	li	a3,0
 5dc:	4629                	li	a2,10
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	ea0080e7          	jalr	-352(ra) # 484 <printint>
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b751                	j	574 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4681                	li	a3,0
 5f8:	4641                	li	a2,16
 5fa:	000ba583          	lw	a1,0(s7)
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e84080e7          	jalr	-380(ra) # 484 <printint>
 608:	8bca                	mv	s7,s2
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b7a5                	j	574 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 60e:	008b8c13          	addi	s8,s7,8
 612:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 616:	03000593          	li	a1,48
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e46080e7          	jalr	-442(ra) # 462 <putc>
  putc(fd, 'x');
 624:	07800593          	li	a1,120
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e38080e7          	jalr	-456(ra) # 462 <putc>
 632:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 634:	00000b97          	auipc	s7,0x0
 638:	33cb8b93          	addi	s7,s7,828 # 970 <digits>
 63c:	03c9d793          	srli	a5,s3,0x3c
 640:	97de                	add	a5,a5,s7
 642:	0007c583          	lbu	a1,0(a5)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e1a080e7          	jalr	-486(ra) # 462 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 650:	0992                	slli	s3,s3,0x4
 652:	397d                	addiw	s2,s2,-1
 654:	fe0914e3          	bnez	s2,63c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 658:	8be2                	mv	s7,s8
      state = 0;
 65a:	4981                	li	s3,0
 65c:	bf21                	j	574 <vprintf+0x44>
        s = va_arg(ap, char*);
 65e:	008b8993          	addi	s3,s7,8
 662:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 666:	02090163          	beqz	s2,688 <vprintf+0x158>
        while(*s != 0){
 66a:	00094583          	lbu	a1,0(s2)
 66e:	c9a5                	beqz	a1,6de <vprintf+0x1ae>
          putc(fd, *s);
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	df0080e7          	jalr	-528(ra) # 462 <putc>
          s++;
 67a:	0905                	addi	s2,s2,1
        while(*s != 0){
 67c:	00094583          	lbu	a1,0(s2)
 680:	f9e5                	bnez	a1,670 <vprintf+0x140>
        s = va_arg(ap, char*);
 682:	8bce                	mv	s7,s3
      state = 0;
 684:	4981                	li	s3,0
 686:	b5fd                	j	574 <vprintf+0x44>
          s = "(null)";
 688:	00000917          	auipc	s2,0x0
 68c:	28890913          	addi	s2,s2,648 # 910 <malloc+0x12e>
        while(*s != 0){
 690:	02800593          	li	a1,40
 694:	bff1                	j	670 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 696:	008b8913          	addi	s2,s7,8
 69a:	000bc583          	lbu	a1,0(s7)
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	dc2080e7          	jalr	-574(ra) # 462 <putc>
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b5e1                	j	574 <vprintf+0x44>
        putc(fd, c);
 6ae:	02500593          	li	a1,37
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	dae080e7          	jalr	-594(ra) # 462 <putc>
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bd5d                	j	574 <vprintf+0x44>
        putc(fd, '%');
 6c0:	02500593          	li	a1,37
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	d9c080e7          	jalr	-612(ra) # 462 <putc>
        putc(fd, c);
 6ce:	85ca                	mv	a1,s2
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	d90080e7          	jalr	-624(ra) # 462 <putc>
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bd61                	j	574 <vprintf+0x44>
        s = va_arg(ap, char*);
 6de:	8bce                	mv	s7,s3
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bd49                	j	574 <vprintf+0x44>
    }
  }
}
 6e4:	60a6                	ld	ra,72(sp)
 6e6:	6406                	ld	s0,64(sp)
 6e8:	74e2                	ld	s1,56(sp)
 6ea:	7942                	ld	s2,48(sp)
 6ec:	79a2                	ld	s3,40(sp)
 6ee:	7a02                	ld	s4,32(sp)
 6f0:	6ae2                	ld	s5,24(sp)
 6f2:	6b42                	ld	s6,16(sp)
 6f4:	6ba2                	ld	s7,8(sp)
 6f6:	6c02                	ld	s8,0(sp)
 6f8:	6161                	addi	sp,sp,80
 6fa:	8082                	ret

00000000000006fc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6fc:	715d                	addi	sp,sp,-80
 6fe:	ec06                	sd	ra,24(sp)
 700:	e822                	sd	s0,16(sp)
 702:	1000                	addi	s0,sp,32
 704:	e010                	sd	a2,0(s0)
 706:	e414                	sd	a3,8(s0)
 708:	e818                	sd	a4,16(s0)
 70a:	ec1c                	sd	a5,24(s0)
 70c:	03043023          	sd	a6,32(s0)
 710:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 714:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 718:	8622                	mv	a2,s0
 71a:	00000097          	auipc	ra,0x0
 71e:	e16080e7          	jalr	-490(ra) # 530 <vprintf>
}
 722:	60e2                	ld	ra,24(sp)
 724:	6442                	ld	s0,16(sp)
 726:	6161                	addi	sp,sp,80
 728:	8082                	ret

000000000000072a <printf>:

void
printf(const char *fmt, ...)
{
 72a:	711d                	addi	sp,sp,-96
 72c:	ec06                	sd	ra,24(sp)
 72e:	e822                	sd	s0,16(sp)
 730:	1000                	addi	s0,sp,32
 732:	e40c                	sd	a1,8(s0)
 734:	e810                	sd	a2,16(s0)
 736:	ec14                	sd	a3,24(s0)
 738:	f018                	sd	a4,32(s0)
 73a:	f41c                	sd	a5,40(s0)
 73c:	03043823          	sd	a6,48(s0)
 740:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 744:	00840613          	addi	a2,s0,8
 748:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 74c:	85aa                	mv	a1,a0
 74e:	4505                	li	a0,1
 750:	00000097          	auipc	ra,0x0
 754:	de0080e7          	jalr	-544(ra) # 530 <vprintf>
}
 758:	60e2                	ld	ra,24(sp)
 75a:	6442                	ld	s0,16(sp)
 75c:	6125                	addi	sp,sp,96
 75e:	8082                	ret

0000000000000760 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 760:	1141                	addi	sp,sp,-16
 762:	e422                	sd	s0,8(sp)
 764:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 766:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76a:	00001797          	auipc	a5,0x1
 76e:	8967b783          	ld	a5,-1898(a5) # 1000 <freep>
 772:	a02d                	j	79c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 774:	4618                	lw	a4,8(a2)
 776:	9f2d                	addw	a4,a4,a1
 778:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 77c:	6398                	ld	a4,0(a5)
 77e:	6310                	ld	a2,0(a4)
 780:	a83d                	j	7be <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 782:	ff852703          	lw	a4,-8(a0)
 786:	9f31                	addw	a4,a4,a2
 788:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 78a:	ff053683          	ld	a3,-16(a0)
 78e:	a091                	j	7d2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	6398                	ld	a4,0(a5)
 792:	00e7e463          	bltu	a5,a4,79a <free+0x3a>
 796:	00e6ea63          	bltu	a3,a4,7aa <free+0x4a>
{
 79a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79c:	fed7fae3          	bgeu	a5,a3,790 <free+0x30>
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e6e463          	bltu	a3,a4,7aa <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a6:	fee7eae3          	bltu	a5,a4,79a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7aa:	ff852583          	lw	a1,-8(a0)
 7ae:	6390                	ld	a2,0(a5)
 7b0:	02059813          	slli	a6,a1,0x20
 7b4:	01c85713          	srli	a4,a6,0x1c
 7b8:	9736                	add	a4,a4,a3
 7ba:	fae60de3          	beq	a2,a4,774 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7be:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c2:	4790                	lw	a2,8(a5)
 7c4:	02061593          	slli	a1,a2,0x20
 7c8:	01c5d713          	srli	a4,a1,0x1c
 7cc:	973e                	add	a4,a4,a5
 7ce:	fae68ae3          	beq	a3,a4,782 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7d2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82f73623          	sd	a5,-2004(a4) # 1000 <freep>
}
 7dc:	6422                	ld	s0,8(sp)
 7de:	0141                	addi	sp,sp,16
 7e0:	8082                	ret

00000000000007e2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e2:	7139                	addi	sp,sp,-64
 7e4:	fc06                	sd	ra,56(sp)
 7e6:	f822                	sd	s0,48(sp)
 7e8:	f426                	sd	s1,40(sp)
 7ea:	f04a                	sd	s2,32(sp)
 7ec:	ec4e                	sd	s3,24(sp)
 7ee:	e852                	sd	s4,16(sp)
 7f0:	e456                	sd	s5,8(sp)
 7f2:	e05a                	sd	s6,0(sp)
 7f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f6:	02051493          	slli	s1,a0,0x20
 7fa:	9081                	srli	s1,s1,0x20
 7fc:	04bd                	addi	s1,s1,15
 7fe:	8091                	srli	s1,s1,0x4
 800:	0014899b          	addiw	s3,s1,1
 804:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 806:	00000517          	auipc	a0,0x0
 80a:	7fa53503          	ld	a0,2042(a0) # 1000 <freep>
 80e:	c515                	beqz	a0,83a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 810:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 812:	4798                	lw	a4,8(a5)
 814:	02977f63          	bgeu	a4,s1,852 <malloc+0x70>
  if(nu < 4096)
 818:	8a4e                	mv	s4,s3
 81a:	0009871b          	sext.w	a4,s3
 81e:	6685                	lui	a3,0x1
 820:	00d77363          	bgeu	a4,a3,826 <malloc+0x44>
 824:	6a05                	lui	s4,0x1
 826:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 82a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 82e:	00000917          	auipc	s2,0x0
 832:	7d290913          	addi	s2,s2,2002 # 1000 <freep>
  if(p == (char*)-1)
 836:	5afd                	li	s5,-1
 838:	a895                	j	8ac <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 83a:	00000797          	auipc	a5,0x0
 83e:	7d678793          	addi	a5,a5,2006 # 1010 <base>
 842:	00000717          	auipc	a4,0x0
 846:	7af73f23          	sd	a5,1982(a4) # 1000 <freep>
 84a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 84c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 850:	b7e1                	j	818 <malloc+0x36>
      if(p->s.size == nunits)
 852:	02e48c63          	beq	s1,a4,88a <malloc+0xa8>
        p->s.size -= nunits;
 856:	4137073b          	subw	a4,a4,s3
 85a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 85c:	02071693          	slli	a3,a4,0x20
 860:	01c6d713          	srli	a4,a3,0x1c
 864:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 866:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 86a:	00000717          	auipc	a4,0x0
 86e:	78a73b23          	sd	a0,1942(a4) # 1000 <freep>
      return (void*)(p + 1);
 872:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 876:	70e2                	ld	ra,56(sp)
 878:	7442                	ld	s0,48(sp)
 87a:	74a2                	ld	s1,40(sp)
 87c:	7902                	ld	s2,32(sp)
 87e:	69e2                	ld	s3,24(sp)
 880:	6a42                	ld	s4,16(sp)
 882:	6aa2                	ld	s5,8(sp)
 884:	6b02                	ld	s6,0(sp)
 886:	6121                	addi	sp,sp,64
 888:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 88a:	6398                	ld	a4,0(a5)
 88c:	e118                	sd	a4,0(a0)
 88e:	bff1                	j	86a <malloc+0x88>
  hp->s.size = nu;
 890:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 894:	0541                	addi	a0,a0,16
 896:	00000097          	auipc	ra,0x0
 89a:	eca080e7          	jalr	-310(ra) # 760 <free>
  return freep;
 89e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8a2:	d971                	beqz	a0,876 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a6:	4798                	lw	a4,8(a5)
 8a8:	fa9775e3          	bgeu	a4,s1,852 <malloc+0x70>
    if(p == freep)
 8ac:	00093703          	ld	a4,0(s2)
 8b0:	853e                	mv	a0,a5
 8b2:	fef719e3          	bne	a4,a5,8a4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8b6:	8552                	mv	a0,s4
 8b8:	00000097          	auipc	ra,0x0
 8bc:	b62080e7          	jalr	-1182(ra) # 41a <sbrk>
  if(p == (char*)-1)
 8c0:	fd5518e3          	bne	a0,s5,890 <malloc+0xae>
        return 0;
 8c4:	4501                	li	a0,0
 8c6:	bf45                	j	876 <malloc+0x94>
