ARMGNU ?= "C:\PrincipalA\Outils\tools\bin\riscv32-unknown-elf"

AOPS =   -mabi=ilp32

all : chap3.uf2

chap3.uf2: chap3.elf
	C:\PrincipalA\Outils\picotool uf2 convert chap3.elf chap3.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap3.o : chap3.s 
	$(ARMGNU)-as  $(AOPS) chap3.s -o chap3.o
    
    
chap3.elf : chap3.o  
	$(ARMGNU)-ld  -T memmap.ld  chap3.o -o chap3.elf  -M >chap3_map.txt
	$(ARMGNU)-objdump -D chap3.elf > chap3.list

    
