/* fichier des constantes pour riscV */
.equ   FALSE, 0
.equ   TRUE,  1
.equ LED_PIN, 25

.equ ATOMIC_XOR, 0x1000
.equ ATOMIC_SET, 0x2000
.equ ATOMIC_CLEAR, 0x3000

.equ SIO_BASE,        0xD0000000

.equ GPIO_FUNC_SIO,   5


.equ SIOBASE_CPUID  , 0x000 # Processor core identifier
.equ GPIO_IN        , 0x004 # Input value for GPIO pins
.equ GPIO_HI_IN     , 0x008 # Input value for QSPI pins
.equ GPIO_OUT       , 0x010 # GPIO output value
.equ GPIO_HI_OUT    , 0x014 # QSPI output value

.equ GPIO_OUT_SET   , 0x018 # GPIO output value set
.equ GPIO_HI_OUT_SET, 0x01C # QSPI output value set

.equ GPIO_OUT_CLR   , 0x020 # GPIO output value clear
.equ GPIO_HI_OUT_CLR, 0x024 # QSPI output value clear

.equ GPIO_OUT_XOR   , 0x028 # GPIO output value XOR
.equ GPIO_HI_OUT_XOR, 0x02c # QSPI output value XOR
.equ GPIO_OE        , 0x030 # GPIO output enable
.equ GPIO_HI_OE     , 0x034 # QSPI output enable
.equ GPIO_OE_SET    , 0x038 # GPIO output enable set
.equ GPIO_HI_OE_SET , 0x03C # QSPI output enable set
.equ GPIO_OE_CLR    , 0x040 # GPIO output enable clear
.equ GPIO_HI_OE_CLR , 0x044 # QSPI output enable clear
.equ GPIO_OE_XOR    , 0x048 # GPIO output enable XOR
.equ GPIO_HI_OE_XOR , 0x04c # QSPI output enable XOR



.equ GPIO_CTRL,     0x4
.equ PADS_BANK0_BASE, 0x40038000
.equ IO_BANK0_BASE,   0x40028000



.equ RESETS_BASE,     0x40020000 
.equ RESETS_RESET,     0
.equ RESETS_DONE,      8
.equ RESETS_RESET_USBCTRL_BITS,     0x10000000    # bit 28
.equ RESETS_RESET_IO_QSPI_BITS,     0x00000080    # ces sous syst mes ne doivent pas  tre r initialiser
.equ RESETS_RESET_PADS_QSPI_BITS,   0x00000400
.equ RESETS_RESET_PLL_USB_BITS,     0x00008000
.equ RESETS_RESET_PLL_SYS_BITS,     0x00004000



.equ RESET_PARAM, ~(RESETS_RESET_IO_QSPI_BITS | RESETS_RESET_PADS_QSPI_BITS| RESETS_RESET_PLL_USB_BITS |  RESETS_RESET_PLL_SYS_BITS) 
.equ RESET_USB, ~(RESETS_RESET_IO_QSPI_BITS | RESETS_RESET_PADS_QSPI_BITS)



.equ POWMAN_BASE,    0x40100000   # chapitre 6.4
.equ POWMAN_SCRATCH0,       0xb0
.equ POWMAN_SCRATCH1,       0xb4
.equ POWMAN_SCRATCH2,       0xb8

.equ WATCHDOG_BASE,  0x400d8000       # chapitre 12.9
.equ WATCHDOG_CTRL,  0
.equ WATCHDOG_LOAD,  4
.equ WATCHDOG_REASON,  8
.equ WATCHDOG_SCRATCH0,  0x0C
.equ WATCHDOG_SCRATCH1,  0x10
.equ WATCHDOG_SCRATCH2,  0x14
.equ WATCHDOG_SCRATCH3,  0x18
.equ WATCHDOG_SCRATCH4,  0x1C
.equ WATCHDOG_SCRATCH5,  0x20
.equ WATCHDOG_SCRATCH6,  0x24
.equ WATCHDOG_SCRATCH7,  0x28
.equ WATCHDOG_TICK_ENABLE_BITS,   0x00000200
.equ WATCHDOG_CTRL_ENABLE_BITS,   0x40000000

.equ PLL_SYS_BASE,   0x40050000
.equ PLL_USB_BASE,   0x40058000

.equ PSM_BASE,  0x40018000
.equ PSM_FRCE_ON,   0
.equ PSM_FRCE_OFF,   4
.equ PSM_WDSEL,      8
.equ PSM_DONE,       0xC

.equ PSM_WDSEL_BITS,   0x0001ffff
.equ PSM_WDSEL_ROSC_BITS,   0x00000002
.equ PSM_WDSEL_XOSC_BITS,   0x00000003

.equ TICKS_BASE,   0x40108000

.equ CLOCKS_BASE, 0x40010000
.equ CLK_REF_CTRL,      0x30
.equ CLK_SYS_CTRL,      0x3C
.equ CLK_SYS_DIV,       0x40
.equ CLK_SYS_SELECTED,  0x44
.equ CLK_PERI_CTRL,     0x48
.equ CLK_USB_CTRL,      0x60                    # usb horloge
.equ CLK_USB_DIV,       0x64
.equ CLK_USB_SELECTED,   0x68
.equ CLK_SYS_RESUS_CTRL, 0x84

.equ FC0_REF_KHZ,    0x8C
.equ FC0_MIN_KHZ,    0x90
.equ FC0_MAX_KHZ,    0x94
.equ FC0_DELAY,      0x98
.equ FC0_INTERVAL,   0x9C
.equ FC0_SRC,        0xa0
.equ FC0_STATUS,     0xa4
.equ FC0_RESULT,     0xa8
.equ CLOCKS_FC0_STATUS_RUNNING_BITS,   0x00000100
.equ CLOCKS_FC0_STATUS_DONE_BITS,      0x00000010
.equ CLOCKS_FC0_RESULT_KHZ_LSB,        5


# -----------------------------------------------------------------------------
# Crystal Oscillator 
# -----------------------------------------------------------------------------
.equ XOSC_BASE,      0x40048000
.equ XOSC_BASE_AND,  0x40050000
.equ XOSC_CTRL_FREQ_RANGE_VALUE_1_15MHZ,    0xaa0
.equ XOSC_CTRL_ENABLE_VALUE_ENABLE,         0xfab
.equ XOSC_CTRL_ENABLE_LSB,                  12
.equ XOSC_STATUS_STABLE_BITS,               0x80000000


.equ XOSC_CTRL,         0x00     # Crystal Oscillator Control
.equ XOSC_STATUS,       0x04     # Crystal Oscillator Status
.equ XOSC_DORMANT,      0x08     # Crystal Oscillator pause control
.equ XOSC_STARTUP,      0x0c     # Controls the startup delay
.equ XOSC_COUNT,        0x1c     # A down counter running at the XOSC frequency
                                 # which counts to zero and stops.

.equ XOSC_ENABLE_12MHZ, 0xfabaa0
.equ XOSC_DELAY,        47       # ceil((f_crystal * t_stable) / 256)

