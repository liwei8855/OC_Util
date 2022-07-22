// Copyright (c) 2013, Facebook, Inc.
// All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//   * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//   * Neither the name Facebook nor the names of its contributors may be used to
//     endorse or promote products derived from this software without specific
//     prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "fishhook.h"

#include <dlfcn.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/vm_map.h>
#include <mach/vm_region.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

#ifdef __LP64__
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segment_command_t;
typedef struct section_64 section_t;
typedef struct nlist_64 nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT_64
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
typedef struct section section_t;
typedef struct nlist nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT
#endif

#ifndef SEG_DATA_CONST
#define SEG_DATA_CONST  "__DATA_CONST"
#endif

struct rebindings_entry {
  struct rebinding *rebindings; //rebinding数组
  size_t rebindings_nel;
  struct rebindings_entry *next;
};
#pragma mark - 传入的需要hook的rebinding数组
//_rebindings_head 被声明为一个指向 rebindings_entry 结构体的静态指针变量
static struct rebindings_entry *_rebindings_head;
//构建rebindings_head 分配内存空间等
static int prepend_rebindings(struct rebindings_entry **rebindings_head,
                              struct rebinding rebindings[],
                              size_t nel) {
  struct rebindings_entry *new_entry = (struct rebindings_entry *) malloc(sizeof(struct rebindings_entry));
  if (!new_entry) {
    return -1;
  }
  new_entry->rebindings = (struct rebinding *) malloc(sizeof(struct rebinding) * nel);
  if (!new_entry->rebindings) {
    free(new_entry);
    return -1;
  }
  memcpy(new_entry->rebindings, rebindings, sizeof(struct rebinding) * nel);
  new_entry->rebindings_nel = nel;
    //头插法，rebindings_head链表头
  new_entry->next = *rebindings_head;
  *rebindings_head = new_entry;
  return 0;
}

#if 0
static int get_protection(void *addr, vm_prot_t *prot, vm_prot_t *max_prot) {
  mach_port_t task = mach_task_self();
  vm_size_t size = 0;
  vm_address_t address = (vm_address_t)addr;
  memory_object_name_t object;
#ifdef __LP64__
  mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
  vm_region_basic_info_data_64_t info;
  kern_return_t info_ret = vm_region_64(
      task, &address, &size, VM_REGION_BASIC_INFO_64, (vm_region_info_64_t)&info, &count, &object);
#else
  mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT;
  vm_region_basic_info_data_t info;
  kern_return_t info_ret = vm_region(task, &address, &size, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &count, &object);
#endif
  if (info_ret == KERN_SUCCESS) {
    if (prot != NULL)
      *prot = info.protection;

    if (max_prot != NULL)
      *max_prot = info.max_protection;

    return 0;
  }

  return -1;
}
#endif
#pragma mark - 最后根据算好的符号表地址和偏移量，找到共享库目标函数的指针,然后将该指针的值（即目标函数的地址）赋值给 *replaced，之后修改该指针的值为我们的 replacement（新的函数地址）
static void perform_rebinding_with_section(struct rebindings_entry *rebindings,
                                           section_t *section,
                                           intptr_t slide,
                                           nlist_t *symtab,
                                           char *strtab,
                                           uint32_t *indirect_symtab) {
  
  //  section的reserved1 + Dynamic Symbol Table 动态符号表的地址 =  indirect_symbol 的地址
  uint32_t *indirect_symbol_indices = indirect_symtab + section->reserved1;
  // slider + section->addr = 符号对应存储函数实现的数组,用来寻找到函数的地址
  void **indirect_symbol_bindings = (void **)((uintptr_t)slide + section->addr);
  // 遍历section 的每一个符号
  for (uint i = 0; i < section->size / sizeof(void *); i++) {
    // 找到符号在Symbol Table表中的索引
    uint32_t symtab_index = indirect_symbol_indices[i];
    if (symtab_index == INDIRECT_SYMBOL_ABS || symtab_index == INDIRECT_SYMBOL_LOCAL ||
        symtab_index == (INDIRECT_SYMBOL_LOCAL   | INDIRECT_SYMBOL_ABS)) {
      continue;
    }
    // 以symtab_index 作为下标,访问symbol table中对应的函数信息
    uint32_t strtab_offset = symtab[symtab_index].n_un.n_strx;
    // 获取symbol_name
    char *symbol_name = strtab + strtab_offset;
    bool symbol_name_longer_than_1 = symbol_name[0] && symbol_name[1];
    struct rebindings_entry *cur = rebindings;
    // 遍历 rebindings
    while (cur) {
      for (uint j = 0; j < cur->rebindings_nel; j++) {
        // 这里 strcmp是判断symbol_name与rebindings 中对应的函数名是否相等,相等即为目标hook函数
        if (symbol_name_longer_than_1 && strcmp(&symbol_name[1], cur->rebindings[j].name) == 0) {
          kern_return_t err;
          // 判断replace.地址不为NULL以及还没有hook过,避免重复交换和空指针
          if (cur->rebindings[j].replaced != NULL && indirect_symbol_bindings[i] != cur->rebindings[j].replacement)
            // 让rebindings[j].repalced 保存 indirect_symbol_bindings[i]的函数地址
            *(cur->rebindings[j].replaced) = indirect_symbol_bindings[i];

          /**
           * 1. Moved the vm protection modifying codes to here to reduce the
           *    changing scope.
           * 2. Adding VM_PROT_WRITE mode unconditionally because vm_region
           *    API on some iOS/Mac reports mismatch vm protection attributes.
           * -- Lianfu Hao Jun 16th, 2021
           **/
          err = vm_protect (mach_task_self (), (uintptr_t)indirect_symbol_bindings, section->size, 0, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
          if (err == KERN_SUCCESS) {
            /**
             * Once we failed to change the vm protection, we
             * MUST NOT continue the following write actions!
             * iOS 15 has corrected the const segments prot.
             * -- Lionfore Hao Jun 11th, 2021
             **/
            
            // 将替换后的方法给原先的方法,也就是替换内容为自定义函数地址
            indirect_symbol_bindings[i] = cur->rebindings[j].replacement;
          }
          //遍历下一个符号
          goto symbol_loop;
        }
      }
      cur = cur->next;
    }
  symbol_loop:;
  }
}
#pragma mark - 按照规则计算各种表的地址和指针在表中的偏移量。
static void rebind_symbols_for_image(struct rebindings_entry *rebindings,
                                     const struct mach_header *header,
                                     intptr_t slide) {
  Dl_info info;
    // 加载当前 mach-O 的所有header
  if (dladdr(header, &info) == 0) {
    return;
  }

  segment_command_t *cur_seg_cmd;
  segment_command_t *linkedit_segment = NULL;
  struct symtab_command* symtab_cmd = NULL;
  struct dysymtab_command* dysymtab_cmd = NULL;
    
    // 找到符号表相关的 command，包括 linkedit segment command、symtab command 和 dysymtab command

  // 跳过header的大小,直接寻找loadcommand
  uintptr_t cur = (uintptr_t)header + sizeof(mach_header_t);
  for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
    cur_seg_cmd = (segment_command_t *)cur;
    if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
      if (strcmp(cur_seg_cmd->segname, SEG_LINKEDIT) == 0) {
        linkedit_segment = cur_seg_cmd;
      }
    } else if (cur_seg_cmd->cmd == LC_SYMTAB) {
      symtab_cmd = (struct symtab_command*)cur_seg_cmd;
    } else if (cur_seg_cmd->cmd == LC_DYSYMTAB) {
      dysymtab_cmd = (struct dysymtab_command*)cur_seg_cmd;
    }
  }

  if (!symtab_cmd || !dysymtab_cmd || !linkedit_segment ||
      !dysymtab_cmd->nindirectsyms) {
    return;
  }
  //获得 base symbol 和 indirect (string table) 符号表
    // 链接时程序的基础地址 = slide的偏移值 +  _ _LINKEDIT.VM_Address - _ _LINKEDIT.File_Offset

  // Find base symbol/string table addresses
  uintptr_t linkedit_base = (uintptr_t)slide + linkedit_segment->vmaddr - linkedit_segment->fileoff;
  // Symbol Table Offset 符号表的地址 = 基址 + 符号表偏移量
  nlist_t *symtab = (nlist_t *)(linkedit_base + symtab_cmd->symoff);
  // String Table  字符串表的地址 = 基址 + 字符串偏移量
  char *strtab = (char *)(linkedit_base + symtab_cmd->stroff);

  // Dynamic Symbol Table 动态符号表的地址 = 基址 + 动态符号表偏移量
  // Get indirect symbol table (array of uint32_t indices into symbol table)
  uint32_t *indirect_symtab = (uint32_t *)(linkedit_base + dysymtab_cmd->indirectsymoff);
  // 重新遍历
  cur = (uintptr_t)header + sizeof(mach_header_t);
  for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
    cur_seg_cmd = (segment_command_t *)cur;
    if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
      //找到DATA和DATA_CONST segment
      if (strcmp(cur_seg_cmd->segname, SEG_DATA) != 0 &&
          strcmp(cur_seg_cmd->segname, SEG_DATA_CONST) != 0) {
        continue;
      }
      // 遍历 number of sections in segment
      for (uint j = 0; j < cur_seg_cmd->nsects; j++) {
        section_t *sect =
          (section_t *)(cur + sizeof(segment_command_t)) + j;
        // 找懒加载表
        if ((sect->flags & SECTION_TYPE) == S_LAZY_SYMBOL_POINTERS) {
          perform_rebinding_with_section(rebindings, sect, slide, symtab, strtab, indirect_symtab);
        }
        // 非懒加载表
        if ((sect->flags & SECTION_TYPE) == S_NON_LAZY_SYMBOL_POINTERS) {
          perform_rebinding_with_section(rebindings, sect, slide, symtab, strtab, indirect_symtab);
        }
      }
    }
  }
}
#pragma mark - 当回调到 _rebind_symbols_for_image 时，会将存着待绑定函数信息的链表作为参数传入，用于符号查找和函数指针的交换，
//第二个参数 header是 当前 image 的头信息，第三个参数 slide是 ASLR 的偏移
static void _rebind_symbols_for_image(const struct mach_header *header,
                                      intptr_t slide) {
    rebind_symbols_for_image(_rebindings_head, header, slide);
}

int rebind_symbols_image(void *header,
                         intptr_t slide,
                         struct rebinding rebindings[],
                         size_t rebindings_nel) {
    struct rebindings_entry *rebindings_head = NULL;
    int retval = prepend_rebindings(&rebindings_head, rebindings, rebindings_nel);
    rebind_symbols_for_image(rebindings_head, (const struct mach_header *) header, slide);
    if (rebindings_head) {
      free(rebindings_head->rebindings);
    }
    free(rebindings_head);
    return retval;
}
#pragma mark - 重绑定函数 成功返回0 失败返回-1， rebindings_nel结构体数组长度
int rebind_symbols(struct rebinding rebindings[], size_t rebindings_nel) {
#pragma mark - 给_rebindings_head初始化：分配空间并赋值
  int retval = prepend_rebindings(&_rebindings_head, rebindings, rebindings_nel);
  if (retval < 0) {
    return retval;
  }
  // If this was the first call, register callback for image additions (which is also invoked for
  // existing images, otherwise, just run on existing images
#pragma mark - 第一次调用,添加回调,对库的装载完成进行监听和回调
  if (!_rebindings_head->next) {
#pragma mark - fishhook 的代码执行时间非常早，所以第一次执行时,要 hook 的库可能还没完成装载，因此如果是第一次调用,会通过一个函数对库的装载完成进行监听和回调
    _dyld_register_func_for_add_image(_rebind_symbols_for_image);
  } else {
    uint32_t c = _dyld_image_count();
#pragma mark - 对已经载入的镜像文件（也就是库）逐一查找目标符号进行 hook
      // 遍历所有 image
    for (uint32_t i = 0; i < c; i++) {
#pragma mark - 已经载入的镜像文件（也就是库）逐一查找目标符号进行 hook。
        ////第二个参数 header是 当前 image 的头信息，第三个参数 slide是 ASLR 的偏移
      _rebind_symbols_for_image(_dyld_get_image_header(i), _dyld_get_image_vmaddr_slide(i));
    }
  }
  return retval;
}
