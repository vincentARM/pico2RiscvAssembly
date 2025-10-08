ARMGNU ?= "C:\PrincipalA\Outils\tools\bin\riscv32-unknown-elf"

AOPS =   -mabi=ilp32

all : chap4.uf2

chap4.uf2: chap4.elf
	C:\PrincipalA\Outils\picotool uf2 convert chap4.elf chap4.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap4.o : chap4.s 
	$(ARMGNU)-as  $(AOPS) chap4.s -o chap4.o
    
    
chap4.elf : chap4.o  
	$(ARMGNU)-ld  -T memmap.ld  chap4.o -o chap4.elf  -M >chap4_map.txt
	$(ARMGNU)-objdump -D chap4.elf > chap4.list

    
