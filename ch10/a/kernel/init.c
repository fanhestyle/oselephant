#include "init.h"

#include "interrupt.h"
#include "memory.h"
#include "print.h"
#include "timer.h"

/*负责初始化所有模块 */
void init_all() {
  put_str("init_all\n");
  idt_init();     // 初始化中断
  mem_init();     // 初始化内存管理系统
  thread_init();  // 初始化线程相关结构
  timer_init();   // 初始化PIT
}