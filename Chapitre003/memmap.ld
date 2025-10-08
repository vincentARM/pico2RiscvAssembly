MEMORY
{
  flash     (rx)  : ORIGIN = 0x10000000, LENGTH = 2048k
  ram      (rwx) : ORIGIN = 0x20000000, LENGTH = 0x80000
}

STACK_SIZE = 0x4000;       /* stack core 0 */ 
STACK_SIZE_C1 = 0x2000;   /* stack core 1 */ 

RAM_SIZE =  0x80000;

/* Section Definitions */
SECTIONS
{
    .text :
    {
       /*  KEEP(*(.vectors .vectors.*)) */
        *(.text*)
        *(.rodata*)
    } > flash

    _debutFlashData = . ;
    .data :
    {
      _debutRamData = . ;
        *(.data*);
    } > ram AT > flash
     /* .bss section which is used for uninitialized data */
    . = ALIGN(4); /* aligne bss pour initialisation dans pgm */
     _debutRamBss = . ;
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram
    _finRamBss = . ;


    /* stack section */
    .SC1 (NOLOAD):
    {
        . = ALIGN(8);
     _debutTas = . ;
    . = _debutRamData - . + RAM_SIZE - (STACK_SIZE + STACK_SIZE_C1) ;
    } > ram
    _finTas = . ;

    .stack (NOLOAD):
    {
        . = ALIGN(8);
        . = . + STACK_SIZE;
        _stack = .;
        . = ALIGN(8);
    } > ram
    /* stack section */

    .stack1 (NOLOAD):
    {
        . = ALIGN(8);
        . = . + STACK_SIZE_C1;
        _stack1 = .;
        . = ALIGN(8);
    } > ram


    _end = . ;
}