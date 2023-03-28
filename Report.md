# OSN Assignment 4
## Team : 
                Siddharth Mangipudi (2021101060)
                Talib Siddiqui (2021101078)

## Specification 1 : 
### strace (5 marks)
strace command is of the form :

>                    strace mask command <arguments>

 - mask here is an integer, whose bits specify which system calls to trace
 - in order to trace `ith` system call, a program calls strace `1 << i`, where i is  the system call number

Output of strace is in the following form :

>                    "pid of process" : syscall "name_of_syscall" ([decimal value of arguments in registers])-> "return value"



1. Added `$U/_strace` to the `UPROGS` part of the makefile.

2. Added 
    ```cpp
    entry("trace");
    ```
    in `user/usys.pl`.
Doing this will make the makefile invoke the script `user/usys.pl` and produce `user/usys.S`.

3. Add a syscall number to `kernel/syscall.h` .
    ```cpp
    #define SYS_trace 22
    ```

4. Created a user program in `user/strace.c` to generate userspace stubs for the system call.
    ```cpp
    int main(int argc, char *argv[]) {
    char *args[32];

    if(argc < 3 || (argv[1][0] < '0' || argv[1][0] > '9')){             // Case where mask has charecters other than numerical digits
        fprintf(2, "Usage: %s mask command\n", argv[0]);            // writing into the stderr buffer
        exit(1);
    }

    if (trace(atoi(argv[1])) < 0) {
        fprintf(2, "%s: negative mask value given, trace failed\n", argv[0]);
        exit(1);
    }

    for(int i = 2; i < argc && i < 32; i++){
    	args[i-2] = argv[i];               // The command is isolated
    }

    exec(args[0], args);

    exit(0);
    }
    ```

5. Implemented a syscall `sys_trace(void)` in `kernel/sysproc.c` . This implements new syscall to apply `mask` to a process.
```cpp
uint64 sys_trace(void)
{
  int mask;

  int f = argint(0,&mask);

  if(f < 0)
  {
    return -1;
  }

  struct proc *p = myproc();
  p->mask = mask;

  return 0; 
}
```
6. Modify the struct `proc` in `kernel/proc.h` to include the mask value for every process.

7. Modify the `syscall()` function in `kernel/syscall.c` to implement the actual strace printing part. We will also create a struct `syscall_num` which maps the syscall number to the number of registers it uses, this needs to be hardcoded.    
    - `p->trapframe->a0` - contains return value of syscall.
    - `p->trapframe->a7` - contains syscall number of syscall
    - registers `a0-a7` contain the arguments in decimal value.

```cpp
void
syscall(void)
{
  int num;
  struct proc *p = myproc();


  num = p->trapframe->a7;   // contains the integer than corresponds to sycall in syscall.h, check user/initcode.S

  int len_args = syscalls_num[num];     

  int arguments_decval[num];
  for(int i = 0; i < len_args;i++)
  {
    arguments_decval[i] = argraw(i); //argraw extracts value of registers in integer form
  }
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    if(p->mask & 1 << num)
    {
      printf("%d: syscall %s (",p->pid,syscall_names[num]);
      for(int i = 0; i < len_args;i++)
      {
        printf("%d ",arguments_decval[i]);              // interesting note : trace and shell output are both intermixed, since both use the write command
      }
      printf("\b) -> %d\n",p->trapframe->a0);
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}
```

8. In `kernel/proc.c` , add the following lines
```cpp
fork:
+    np->trapframe->a0 = 0;

freeproc:
p->state = UNUSED;

+p->mask = 0;


```

9. Output is displayed on shell - Note that trace and shell output are both intermixed, since both use the write command, for instance, `strace 32 echo hi` would execute echo hi as well, since we are exec()-ing it.    


### Sigalarm and Sigreturn (10 marks)
In this specification, we added a feature to xv6 that periodically alerted a process as it uses CPU time. Each clock cycle of the Hardware clovk is taken as a `tick`.
We implemented a new `sigalarm(interval,handler)` system call, and also `sigreturn()` system call.
If an application calls `alarm(n,fn)`, then after every n ticks of CPU time that the program consumes, the kernel will cause application function `fn` to be called. When `fn` returns, the application picks up where it left off.
- `alarm(n,fn)` is a user defined function, in `alarmtest.c`

Sigreturn restores the trapframe of the process before `handler` was called.

1. Add `$U_alarmtest\` to `UPROGS` in Makefile.
2. Add two syscalls `sys_sigalarm(void)` and `sys_sigreturn(void)` to `kernel/sysproc.c` .
```cpp
uint64 sys_sigalarm(void)
{
  int ticks;
  uint64 handler;

 argint(0,&ticks);
 argaddr(1,&handler);
  
  struct proc* p = myproc();

  p->ticks = ticks;
  p->handler = handler;
  p->elapsed_ticks = 0;

  return 0;
}

uint64 sys_sigreturn(void)
{
  struct proc* p = myproc();

  // Recover saved trapframe.
  
  memmove(p->trapframe,&(p->saved_tf),sizeof(struct trapframe)); // currently passing tests 0,1,2

  p->elapsed_ticks = 0;

  return p->saved_tf.a0;    // This is the return value of sigreturn, the state of a0 reg in the saved trapframe
}
```

3. Add a corresponding syscall number to these two functions in `kernel/syscall.h`
```cpp   
#define SYS_sigalarm  23
#define SYS_sigreturn 24
```
4. Modify the struct `proc` in `kernel/proc.h` To add the following fields:
```cpp
  int ticks;                    // number of cpu ticks
  int elapsed_ticks;            // number of ticks since last call
  uint64 handler;  
  struct trapframe saved_tf;
```
- `ticks` - Interval
- `elapsed_ticks` - Number of  ticks since last interrupt.
- `handler` - self-explanotory.
- `saved_tf` - trapframe before alarm was called.

5. Initialise these variables in `kernel/proc.c`.
```cpp
allocproc():
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

+ p->ticks = 0;
+ p->elapsed_ticks = 0;
+ p->handler = 0;

return p;

```

6. In `kernel/trap.c` , in the function `usertrap` , we need to handle the case where we get a timer interrupt. We need to modify the following section:
```cpp
// give up the CPU if this is a timer interrupt.
  // If the process needs to alarm, we must save current trapframe , call the handler and run function after returning to userspace
  if (which_dev == 2)
  {
    // alarm(n,fn) has been called, now we check if there is an alarm interval
    if (p->ticks > 0)
    {
      p->elapsed_ticks++;
      if (p->elapsed_ticks == p->ticks)
      {
        //*p->saved_tf = p->trapframe
        // Doesn't work, because all it will do is make it point to the trapframe again
        memmove(&(p->saved_tf), p->trapframe, sizeof(struct trapframe));
        // This is the way to saved data that is getting pointed to by a pointer into a struct
        p->trapframe->epc = p->handler; // updating program counter with the function address.
      }
    }
     yield();
  }     
```

7. Run `make qemu` on shell and type `alarmtest` on hell, and check output.

## Specification 3 :
### Copy-on-Write Fork (15 marks)

Copy-on-Write Fork is a Virtual memory management modification which can be applied in kernels.

The goal of copy-on-write (COW) fork() is to defer allocating and copying physical memory pages for the child until the copies are actually needed, if ever. 
COW fork() creates just a pagetable for the child, with PTEs for user memory pointing to the parent's physical pages. 

COW fork() marks all the user PTEs in both parent and child as not writable(remove write prmissions). 

When either process tries to write one of these COW pages, the CPU will force a page fault. The kernel `pagefaulthandler` in `kernel/trap.c` detects this case, allocates a page of physical memory for the faulting process, copies the original page into the new page, and modifies the relevant PTE in the faulting process to refer to the new page, this time with the PTE marked writeable. 

When the page fault handler returns, the user process will be able to write its copy of the page.

Note that a given physical page may be referred to by multiple processes' page tables, and should be freed only when the last reference disappears, so in order to handle this, we can create a struct `ref_count` which has a `spinlock` and an array of number of pages in each page to record this.(acts as a Semaphore)

1. Modify `kernel/vm.c` in the following places:
```cpp
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    .....
    flags = PTE_FLAGS(*pte);
-    if((mem = kalloc()) == 0)
-      goto err;
-    memmove(mem, (char*)pa, PGSIZE);
-    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
-      kfree(mem);
-      goto err;
-    }
+    if(flags & PTE_W)
+    {
+      flags = (flags&(~PTE_W)) | PTE_C;
+      *pte = PA2PTE(pa) | flags ;
+    }

+    if(mappages(new,i,PGSIZE,pa,flags) != 0)
    {
      goto err;
    }

+    safe_increment_references((void*)pa);
    
  ......
```

2. We need to add the following functions to `kernel/kalloc.c` to bookkeep the number of references each page has :
```cpp

struct {
  struct spinlock lock;
  int no_of_references[PGROUNDUP(PHYSTOP) >> 12];        
  // PHYSTOP is the upper bound for RAM usage for both user and kernel space
  // KERNBASE is the address from where the kernel starts
  // Total size = 128*1024*1024 = 2^27 bytes --> 2^27 PTEs
  // Each physical page table has 512 = 2^9 pages in it --> 2^9 * 8 bytes = 2^12 bytes
  // PGROUNDUP rounds it up to nearest 406-multiple
  
}ref_count;

void refcountinit()
{
  initlock(&ref_count.lock,"ref_count");
  acquire(&kmem.lock);            // reason we need to memset is to ensure no other concurrent child process can modify this at the same time, very important
  // memset(ref_count.no_of_references,0,sizeof(int));
  for(int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12);i++)
  {
    ref_count.no_of_references[i] = 0;
  }      
  release(&kmem.lock);
}

void safe_increment_references(void* pa)
{
  acquire(&ref_count.lock);
  if(ref_count.no_of_references[(uint64)pa >> 12] < 0)
  {
    panic("safe_increment_references");
  }
  ref_count.no_of_references[((uint64)(pa) >> 12)] += 1;       // basically increments the number of references for that page
  release(&ref_count.lock);
}

void safe_decrement_references(void* pa)
{
  acquire(&ref_count.lock);
  if(ref_count.no_of_references[(uint64)pa >> 12] <= 0)
  {
    panic("safe_decrement_references");
  }
  ref_count.no_of_references[((uint64)(pa) >> 12)]  -= 1;
  release(&ref_count.lock);
}

int get_refcount(void *pa)
{
  acquire(&ref_count.lock);
  int result = ref_count.no_of_references[((uint64)(pa) >> 12)];
  if(ref_count.no_of_references[(uint64)pa >> 12] < 0)
  {
    panic("get_page_ref");
  }
  release(&ref_count.lock);
  return result;
}

void reset_refcount(void* pa)
{
  ref_count.no_of_references[((uint64)(pa) >> 12)] = 0;
}

```

We also need to modify `kinit` function here to initialise this struct.
```cpp
kinit:
+     refcountint();
```
Also, for the `kalloc` function, we increment the reference count for each run struct
```cpp
kalloc:
......
if(r)
  {
    memset((char*)r, 5, PGSIZE); // fill with junk
+    safe_increment_references((void*)r);
  }
.....
```

3. We need to modify `kernel/trap.c` in order to handle page-fault exceptions, we define a seperate interrupt routine `pagefaulthandler` .
```cpp
int pagefaulthandler(void *va, pagetable_t pagetable)
{
  struct proc *p = myproc();
  if ((uint64)va >= MAXVA || ((uint64)va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE && PGSIZE && (uint64)va <= PGROUNDDOWN(p->trapframe->sp)))
  {
    return -2;
  }

  pte_t *pte;
  uint64 pa;
  uint flags;
  va = (void*)PGROUNDDOWN((uint64)va);
  pte = walk(pagetable,(uint64)va,0);
  if(pte == 0)
  {
    return -1;
  }
  pa = PTE2PA(*pte);
  if(pa == 0)
  {
    return -1;
  }
  flags = PTE_FLAGS(*pte);
  if(flags & PTE_C)
  {
    flags = (flags | PTE_W) & (~PTE_C);
    char *mem;
    mem = kalloc();
    if(mem == 0)
    {
      return -1;
    }
    memmove(mem,(void*)pa,PGSIZE);
    *pte = PA2PTE(mem) |flags;
    kfree((void*)pa);
    return 0;
  }

  return 0;
}

usertrap:
....
else if ((r_scause() == 13 || r_scause() == 15))      // eroor code in event of page fault exception
  {

    if(r_stval() == 0)      // if the virtual adress where it is faulting is 0
    {
      // p->killed = 1;
      setkilled(p);
    }
    int res = pagefaulthandler((void *)r_stval(), p->pagetable);
    // 0 means all fine
    //-1 means mem is not alloated
    //-2 means address is invalid
    if (res == -1 || res == -2)
    {
      setkilled(p);
      //p->killed = 1;
    }
  }
....  
```
4. We need to only free a page if the number of references to it become zero, in order to do so, we need to modify the `kree` function in `kernel/kalloc.c`
```cpp
kfree():
....
if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
  {
    panic("kfree");
  }

  acquire(&ref_count.lock);
  if(ref_count.no_of_references[(uint64)pa >> 12] <= 0)
  {
    panic("safe_decrement_references");
  }
  ref_count.no_of_references[(uint64)pa >> 12] -= 1;   // decrementing reference
  
  if(ref_count.no_of_references[(uint64)pa >> 12] > 0)
  {
    release(&ref_count.lock);
    return; // can't free the page address yet
  }
  release(&ref_count.lock);

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
....  
```
We need to also increment the number of references in `freerange()` since it will call `kfree()` and decrease the count, so in order to cancel this out we first increase it and then decrease it.
```cpp
for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
  {
    safe_increment_references(p);    // increment page references
    kfree(p);
  }
```
5. Modify `copyout()` in `kernel/vm.c` to use the same scheme as page faults when it encounters a COW page.
```cpp
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0,flags;
  pte_t *pte;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
    {
      return -1;  
    }
    pte = walk(pagetable,va0,0);
    flags = PTE_FLAGS(*pte);
    if(flags & PTE_C)
    {
      pagefaulthandler((void*)va0,pagetable);
      pa0 = walkaddr(pagetable,va0);
    }  
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}
```
6. In order to test if the above implementation is working, add the program `cowtest.c` too the users folder, and consequently add it to the makefile.

Run `make qemu` and run `cowtest` to see the COW functionality works, similarly, run `usertests` in the shell.


