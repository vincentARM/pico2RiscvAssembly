ARMGNU ?= "C:\PrincipalA\Outils\tools\bin\riscv32-unknown-elf"

AOPS =   -mabi=ilp32

all : chap5.uf2

chap5.uf2: chap5.elf
	C:\PrincipalA\Outils\picotool uf2 convert chap5.elf chap5.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap5.o : chap5.s 
	$(ARMGNU)-as  $(AOPS) chap5.s -o chap5.o
    
    
chap5.elf : chap5.o  
	$(ARMGNU)-ld  -T memmap.ld  chap5.o -o chap5.elf  -M >chap5_map.txt
	$(ARMGNU)-objdump -D chap5.elf > chap5.list

    
