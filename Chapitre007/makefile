ARMGNU ?= "C:\PrincipalA\Outils\tools\bin\riscv32-unknown-elf"

AOPS =   -mabi=ilp32 -march=rv32i_m_zbs_zicsr_f_zba_zbb

all : chap7.uf2

chap7.uf2: chap7.elf
	C:\PrincipalA\Outils\picotool uf2 convert chap7.elf chap7.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap7.o : chap7.s 
	$(ARMGNU)-as  $(AOPS) chap7.s -o chap7.o
    
    
chap7.elf : chap7.o  routinesRisc.o routinesusbriscv.o
	$(ARMGNU)-ld  -T memmap.ld  chap7.o routinesRisc.o routinesusbriscv.o -o chap7.elf  -M >chap7_map.txt
	$(ARMGNU)-objdump -D chap7.elf > chap7.list

routinesRisc.o : ./routinesRisc.s ./constantesPicoRisc.inc
	$(ARMGNU)-as  $(AOPS) ./routinesRisc.s -o ./routinesRisc.o
    
routinesusbriscv.o : ./routinesusbriscv.s ./constantesPicoRisc.inc
	$(ARMGNU)-as  $(AOPS) ./routinesusbriscv.s -o ./routinesusbriscv.o
    
