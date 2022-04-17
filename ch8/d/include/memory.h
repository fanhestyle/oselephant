#ifndef __KERNEL_MEMORY_H
#define __KERNEL_MEMORY_H

#include "bitmap.h"
#include "stdint.h"

#define PG_SIZE 4096

/***************  位图地址 ********************
 * 因为0xc009f000是内核主线程栈顶，0xc009e000是内核主线程的pcb.
 * 一个页框大小的位图可表示128M内存, 位图位置安排在地址0xc009a000,
 * 这样本系统最大支持4个页框的位图,即512M */
#define MEM_BITMAP_BASE 0xc009a000

/* 0xc0000000是内核从虚拟地址3G起. 0x100000意指跨过低端1M内存,
使虚拟地址在逻辑上连续 */
#define K_HEAP_START 0xc0100000

/* 内存池结构,生成两个实例用于管理内核内存池和用户内存池 */
struct pool {
  struct bitmap pool_bitmap;  // 本内存池用到的位图结构,用于管理物理内存
  uint32_t phy_addr_start;  // 本内存池所管理物理内存的起始地址
  uint32_t pool_size;       // 本内存池字节容量
};

struct virtual_addr {
  struct bitmap vaddr_bitmap;
  uint32_t vaddr_start;
};

struct pool kernel_pool, user_pool;      // 生成内核内存池和用户内存池
struct virtual_addr kernel_vaddr;	 // 此结构是用来给内核分配虚拟地址

void mem_init(void);

#endif