ARMGNU ?= "C:\PrincipalA\Outils\tools\bin\riscv32-unknown-elf"

AOPS =   -mabi=ilp32

all : chap6.uf2

chap6.uf2: chap6.elf
	C:\PrincipalA\Outils\picotool uf2 convert chap6.elf chap6.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap6.o : chap6.s 
	$(ARMGNU)-as  $(AOPS) chap6.s -o chap6.o
    
    
chap6.elf : chap6.o  routinesRisc.o routinesusbriscv.o
	$(ARMGNU)-ld  -T memmap.ld  chap6.o routinesRisc.o routinesusbriscv.o -o chap6.elf  -M >chap6_map.txt
	$(ARMGNU)-objdump -D chap6.elf > chap6.list

routinesRisc.o : ./routinesRisc.s ./constantesPicoRisc.inc
	$(ARMGNU)-as  $(AOPS) ./routinesRisc.s -o ./routinesRisc.o
    
routinesusbriscv.o : ./routinesusbriscv.s ./constantesPicoRisc.inc
	$(ARMGNU)-as  $(AOPS) ./routinesusbriscv.s -o ./routinesusbriscv.o
    
