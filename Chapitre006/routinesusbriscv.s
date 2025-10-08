/* Routines riscv gestion communication USB */
/*  CDC pour communication avec Putty */
/* version ok le 4/10/2025  message> 128 car */
/* améliorations */ 
# 
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPicoRisc.inc"   


.equ MAIN_CTRL,          0x40   
.equ SIE_CTRL,           0x4C
.equ SIE_STATUS,         0x50

.equ USB_BUFF_STATUS,    0x58
.equ USB_MUXING,         0x74
.equ USB_PWR,            0x78
.equ USB_INTR,           0x8C
.equ USB_INTE,           0x90
.equ USB_INTF,           0x94
.equ USB_INTS,           0x98
.equ USB_NUM_ENDPOINTS, 16

.equ USBCTRL_DPRAM_BASE, 0x50100000 
.equ USB_DPRAM_SIZE,     4096
.equ USBCTRL_BASE,       0x50100000
.equ USBCTRL_REGS_BASE,  0x50110000

.equ USB_USB_MUXING_TO_PHY_BITS,   0x00000001
.equ USB_USB_MUXING_SOFTCON_BITS,   0x00000008
.equ USB_MAIN_CTRL_CONTROLLER_EN_BITS,   0x00000001
.equ USB_SIE_CTRL_EP0_INT_1BUF_BITS,   0x20000000
.equ USB_SIE_CTRL_PULLUP_EN_BITS,    0x00010000
.equ USB_SIE_STATUS_SETUP_REC_BITS,   0x00020000
.equ USB_SIE_STATUS_BUS_RESET_BITS,   0x00080000

.equ USB_INTS_BUFF_STATUS_BITS,   0x00000010
.equ USB_INTS_BUS_RESET_BITS,     0x00001000
.equ USB_INTS_SETUP_REQ_BITS,     0x00010000
 

.equ USB_USB_PWR_VBUS_DETECT_BITS,   0x00000004
.equ USB_USB_PWR_VBUS_DETECT_OVERRIDE_EN_BITS,   0x00000008
.equ USBCTRL_IRQ,      14

.equ USB_DT_DEVICE,    0x01
.equ USB_DT_CONFIG,    0x02
.equ USB_DT_STRING,    0x03
.equ USB_DT_INTERFACE, 0x04
.equ USB_DT_ENDPOINT,  0x05
.equ USB_DT_QUALIFIER, 0x06
.equ USB_DT_INTERFACE_ASSOC,  0xB
.equ USB_DT_CDC,       0x24

.equ USB_CLASS_USE_INTERFACE, 0x00
.equ USB_CLASS_CDC_CONTROL,  0x02
.equ USB_CLASS_CDC_DATA,     0x0A

.equ USB_TRANSFER_TYPE_CONTROL,     0x0
.equ USB_TRANSFER_TYPE_ISOCHRONOUS, 0x1
.equ USB_TRANSFER_TYPE_BULK,        0x2
.equ USB_TRANSFER_TYPE_INTERRUPT,   0x3
.equ USB_TRANSFER_TYPE_BITS,        0x3

.equ USB_BUF_CTRL_FULL,      0x00008000
.equ USB_BUF_CTRL_LAST,      0x00004000
.equ USB_BUF_CTRL_DATA0_PID, 0x00000000
.equ USB_BUF_CTRL_DATA1_PID, 0x00002000
.equ USB_BUF_CTRL_SEL,       0x00001000
.equ USB_BUF_CTRL_STALL,     0x00000800
.equ USB_BUF_CTRL_AVAIL,     0x00000400
.equ USB_BUF_CTRL_LEN_MASK,  0x000003FF
.equ USB_BUF_CTRL_LEN_LSB,   0

.equ USB_REQUEST_GET_STATUS, 0x0
.equ USB_REQUEST_CLEAR_FEATURE, 0x01
.equ USB_REQUEST_SET_FEATURE, 0x03
.equ USB_REQUEST_SET_ADDRESS, 0x05
.equ USB_REQUEST_GET_DESCRIPTOR, 0x06
.equ USB_REQUEST_SET_DESCRIPTOR, 0x07
.equ USB_REQUEST_GET_CONFIGURATION, 0x08
.equ USB_REQUEST_SET_CONFIGURATION, 0x09
.equ USB_REQUEST_GET_INTERFACE, 0x0a
.equ USB_REQUEST_SET_INTERFACE, 0x0b
.equ USB_REQUEST_SYNC_FRAME, 0x0c

.equ USB_SET_CDC_LINE_CODING,         0x20
.equ USB_GET_CDC_LINE_CODING,         0x21
.equ USB_CDC_CONTROL_LINE_STATE,      0x22
.equ USB_CDC_SEND_BREAK,              0x23

.equ USB_DIR_OUT, 0x00
.equ USB_DIR_IN,  0x80

.equ EP0_IN_ADDR,  (USB_DIR_IN  | 0)
.equ EP0_OUT_ADDR, (USB_DIR_OUT | 0)
.equ EP1_IN_ADDR,  (USB_DIR_IN | 1)
.equ EP1_OUT_ADDR, (USB_DIR_OUT | 1)
.equ EP2_IN_ADDR,  (USB_DIR_IN  | 2)
.equ EP2_OUT_ADDR, (USB_DIR_OUT  | 2)
#.equ EP3_IN_ADDR,  (USB_DIR_IN  | 3)


.equ EP_CTRL_ENABLE_BITS, (1u << 31u)
.equ EP_CTRL_DOUBLE_BUFFERED_BITS, (1u << 30)
.equ EP_CTRL_INTERRUPT_PER_BUFFER, (1u << 29)
.equ EP_CTRL_INTERRUPT_PER_DOUBLE_BUFFER, (1u << 28)
.equ EP_CTRL_INTERRUPT_ON_NAK, (1u << 16)
.equ EP_CTRL_INTERRUPT_ON_STALL, (1u << 17)
.equ EP_CTRL_BUFFER_TYPE_LSB, 26
.equ EP_CTRL_HOST_INTERRUPT_INTERVAL_LSB, 16
 
.equ TAILLEPAQUET, 64        # non modifiable
/********************************************/
/*        STRUCTURES                  */
/********************************************/
/* structures USB device dpram  */
    .struct  0
udpd_setup_packet:                                 # setup packet
    .struct  udpd_setup_packet + 8 
udpd_ctrl:                                         # In + out 
    .struct  udpd_ctrl + 8 * (USB_NUM_ENDPOINTS - 1)
udpd_buf_ctrl:                                     # In + out 
    .struct  udpd_buf_ctrl + 8 * (USB_NUM_ENDPOINTS)
udpd_ep0_buf_a:                                    # 
    .struct  udpd_ep0_buf_a + 64                   #  0x40
udpd_ep0_buf_b:                                    # 
    .struct  udpd_ep0_buf_b + 64                   #  0x40
udpd_epx_data:                                     # 
    .struct  udpd_epx_data + ( USB_DPRAM_SIZE - 0x180)          # 
udpd_fin:

/* structures USB setup packet  */
    .struct  0
pkt_bmRequestType:                            # 
    .struct  pkt_bmRequestType + 1
pkt_bRequest:                                 # 
    .struct  pkt_bRequest + 1
pkt_wValue:                                   # 
    .struct  pkt_wValue + 2
pkt_wIndex:                                   # 
    .struct  pkt_wIndex + 2
pkt_wLength:                                  # 
    .struct  pkt_wLength + 2

/* structure usb_device_descriptor  */
    .struct  0
udd_bLength:                                 # taille de la structure
    .struct  udd_bLength + 1 
udd_bDescriptorType:                         # 
    .struct  udd_bDescriptorType + 1 
udd_bcdUSB:                         # 
    .struct  udd_bcdUSB + 2
udd_bDeviceClass:                         # 
    .struct  udd_bDeviceClass + 1 
udd_bDeviceSubClass:                         # 
    .struct  udd_bDeviceSubClass + 1 
udd_bDeviceProtocol:                         # 
    .struct  udd_bDeviceProtocol + 1 
udd_bMaxPacketSize0:                         # 
    .struct  udd_bMaxPacketSize0 + 1 
udd_idVendor:                         # 
    .struct  udd_idVendor + 2 
udd_idProduct:                         # 
    .struct  udd_idProduct + 2
udd_bcdDevice:                         # 
    .struct  udd_bcdDevice + 2
udd_iManufacturer:                         # 
    .struct  udd_iManufacturer + 1
udd_iProduct:                         # 
    .struct  udd_iProduct + 1
udd_iSerialNumber:                         # 
    .struct  udd_iSerialNumber + 1
udd_bNumConfigurations:                         # 
    .struct  udd_bNumConfigurations + 1
udd_fin:

/* structure usb_endpoint_descriptor  */
    .struct  0
ued_bLength:                                 # taille de la structure 7
    .struct  ued_bLength + 1 
ued_bDescriptorType:                         # 
    .struct  ued_bDescriptorType + 1 
ued_bEndpointAddress:                        # 
    .struct  ued_bEndpointAddress + 1 
ued_bmAttributes:                            # 
    .struct  ued_bmAttributes + 1 
ued_wMaxPacketSize:                          # 
    .struct  ued_wMaxPacketSize + 2 
ued_bInterval:                               # 
    .struct  ued_bInterval + 1 
ued_fin:

/* structure usb_endpoint_configuration      */ 
    .struct  0
uec_descriptor:                       # 
    .struct  uec_descriptor + 4
uec_handler:                       # 
    .struct  uec_handler + 4
uec_endpoint_control:                       # 
    .struct  uec_endpoint_control + 4
uec_buffer_control:                       # 
    .struct  uec_buffer_control + 4
uec_data_buffer:                       # 
    .struct  uec_data_buffer + 4
uec_next_pid:                       # 
    .struct  uec_next_pid + 4
uec_fin:
/* line_info   */
    .struct  0
line_dte_rate:                                 # taux de transmission
    .struct  line_dte_rate + 4 
line_char_format:                              # format
    .struct  line_char_format + 1
line_parity_type:                              # parité
    .struct  line_parity_type + 1
line_data_bits:                                 # 
    .struct  line_data_bits + 1 
line_fin:
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data                 # INFO: data
szRetourLigne:       .asciz "\r\n"
bDev_addr:           .byte  0          # adresse du periphérique
.align 2
iConfigured:         .int 0
should_set_address:  .int FALSE        # true si l'adresse du periphérique est renseignée
.global iConfigured                    # pour utilisation par les programmes appelants

/* voir les descriptions de ces entités  https:#www.usbmadesimple.co.uk  */
device_descriptor:
bLength:             .byte  18                      # longueur descriptif
bDescriptorType:     .byte  USB_DT_DEVICE
bcdUSB:              .hword 0x0200
bDeviceClass:        .byte USB_CLASS_USE_INTERFACE  # Specified in interface descriptor
bDeviceSubClass:     .byte  0                       # No subclass
bDeviceProtocol:     .byte  0                       # No protocol
bMaxPacketSize0:     .byte  64                      # Max packet size for ep0
idVendor:            .hword 0x2E8A                  # Your vendor id
idProduct:           .hword 0x000A                  # Your product ID
bcdDevice:           .hword  0x0100                 # N° device revision number modif 01/09/2021 0x0100
iManufacturer:       .byte   0                      # Manufacturer string index
iProduct:            .byte   0                      # Product string index
iSerialNumber:       .byte   0                      # No serial number
bNumConfigurations:  .byte  1                       # One configuration
.equ LGDEVICE,    . - device_descriptor

interface_association_descriptor:
inta_bLength:            .byte  8
inta_bDescriptorType:    .byte USB_DT_INTERFACE_ASSOC 
inta_first_interface:    .byte 0
inta_interface_count:    .byte 2
inta_function_class:     .byte 2
inta_function_subclass:  .byte 2
inta_function_protocol:  .byte 1
inta_function:           .byte 0 
.equ LGINTASSO,    . - interface_association_descriptor

interface_descriptor:
int_bLength:            .byte  9
int_bDescriptorType:    .byte USB_DT_INTERFACE
int_bInterfaceNumber:   .byte 0
int_bAlternateSetting:  .byte 0
int_bNumEndpoints:      .byte 1    # Interface has 1 endpoints
int_bInterfaceClass:    .byte USB_CLASS_CDC_CONTROL
int_bInterfaceSubClass: .byte 2
int_bInterfaceProtocol: .byte 0
int_iInterface:         .byte 0
.equ LGINTERFACE,    . - interface_descriptor

interface1_descriptor:
int1_bLength:            .byte  9
int1_bDescriptorType:    .byte USB_DT_INTERFACE
int1_bInterfaceNumber:   .byte 1
int1_bAlternateSetting:  .byte 0
int1_bNumEndpoints:      .byte 2    # cet interface a 2 endpoints
int1_bInterfaceClass:    .byte USB_CLASS_CDC_DATA
int1_bInterfaceSubClass: .byte 0
int1_bInterfaceProtocol: .byte 0
int1_iInterface:         .byte 0
.equ LGINTERFACE1,    . - interface1_descriptor

cdc_header_descriptor:
cdch_bLength:            .byte  5
cdch_bDescriptorType:    .byte USB_DT_CDC
cdch_sub_type:           .byte 0
#filler:                  .byte 0             # VIM dernière modif
cdch_bcd:                .hword 0x1001
.equ LGCDCHEAD,       . - cdc_header_descriptor

cdc_acm_descriptor:
cdca_bLength:            .byte  4
cdca_bDescriptorType:    .byte USB_DT_CDC
cdca_sub_type:           .byte 2
cdca_capabilities:       .byte 0x6
.equ LGCDCACM,      . - cdc_acm_descriptor

cdc_union_descriptor:
cdcu_bLength:            .byte  5
cdcu_bDescriptorType:    .byte USB_DT_CDC
cdcu_sub_type:           .byte 6
cdcu_master_interface:   .byte 0
cdcu_slave_interface:    .byte 1
.equ LGCDCUNION,    . - cdc_union_descriptor

cdc_call_descriptor:
cdcca_bLength:            .byte  5
cdcca_bDescriptorType:    .byte USB_DT_CDC
cdcca_sub_type:           .byte 1
cdcca_capabilities:       .byte 0
cdcca_data_interface:     .byte 1
.equ LGCDCCALL,     . - cdc_call_descriptor
 
.align 4
config_descriptor:
confd_bLength:          .byte   9
confd_bDescriptorType:  .byte  USB_DT_CONFIG
confd_wTotalLength:     .hword  75        # taille totale des descriptifs

confd_bNumInterfaces:      .byte  2
confd_bConfigurationValue: .byte  1       # Configuration 1
confd_iConfiguration:      .byte 0        # No string
confd.bmAttributes:        .byte 0xC0     # attributes: self powered, no remote wakeup
                                          #  Modif ancien 0x80
confd.bMaxPower:           .byte 0x32     # 100 ma
.equ  LGCONFDESC,    . - config_descriptor

stVendor:   .asciz        "Raspberry Pi"    # Nom vendeur : Ne fonctionne pas dans cette version
stProduct:  .asciz        "Pico Test Device2" # Nom du produit : Ne fonctionne pas dans cette version

.align 2
endpoint1: 
             .byte 7                # taille structure
             .byte USB_DT_ENDPOINT  # type
             .byte EP1_IN_ADDR      # IN to host
             .byte USB_TRANSFER_TYPE_INTERRUPT
             .hword  16             # taille du paquet
             .byte  64              # intervalle
  .equ LGENDP1,   . - endpoint1
  
.align 2
endpoint2: 
             .byte 7               # taille structure
             .byte USB_DT_ENDPOINT # type
             .byte EP2_OUT_ADDR    # OUT from host
             .byte USB_TRANSFER_TYPE_BULK
             .hword  TAILLEPAQUET            # taille maxi du paquet
             .byte  0
  .equ LGENDP2,   . - endpoint2
.align 2
endpoint2IN: 
             .byte 7               # taille structure
             .byte USB_DT_ENDPOINT # type
             .byte EP2_IN_ADDR     #  IN to host
             .byte USB_TRANSFER_TYPE_BULK
             .hword  TAILLEPAQUET            # taille maxi du paquet
             .byte  0
#  .equ LGENDP2,   . - endpoint2IN
.align 2
ep0_out: 
             .byte 7               # taille structure
             .byte USB_DT_ENDPOINT
             .byte EP0_OUT_ADDR    #  OUT from host
             .byte USB_TRANSFER_TYPE_CONTROL
             .hword  TAILLEPAQUET
             .byte  0
  .equ LGDESCRIPT,   . - ep0_out
.align 2
ep0_in: 
             .byte 7                # taille structure
             .byte USB_DT_ENDPOINT
             .byte EP0_IN_ADDR      # IN to host
             .byte USB_TRANSFER_TYPE_CONTROL
             .hword  TAILLEPAQUET
             .byte  0

.align 2
dev_config:
cfg_device_descriptor:     .int device_descriptor
cfg_interface_descriptor:  .int interface_descriptor
cfg_config_descriptor:     .int config_descriptor
cfg_lang_descriptor:       .byte   4,  0x03, 0x09, 0x04 # length, bDescriptorType == String Descriptor,
                                        # language id = us english
cfg_descriptor_strings:    .int stVendor
                           .int stProduct
cfg_endpoints:
                        .int ep0_out
                        .int ep0OutHandler
                        .int 0                   # NA for EP0
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl + 4
                        .int USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
                        .int 0
 
    .equ LGCFGENDPOINT, . - cfg_endpoints
             #2ième
                        .int ep0_in
                        .int ep0InHandler
                        .int 0                   # NA for EP0
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl
                        .int USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
                        .int 0
                         # &usb_dpram->ep0_buf_a[0],

            # 3ième nouveau
                        .int endpoint1
                        .int ep1InHandler
                        .int USBCTRL_DPRAM_BASE+udpd_ctrl          # in poste 0 Modif
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl + 8  # in poste 1
                        .int USBCTRL_DPRAM_BASE+udpd_epx_data 
                        .int 0
 
             # 4ième nouveau
                        .int endpoint2
                        .int ep2OutHandler
                        .int USBCTRL_DPRAM_BASE+udpd_ctrl + 8 + 4  # out poste 1 OUT Modif
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl+16 + 4 # out poste 2 OUT
                        .int USBCTRL_DPRAM_BASE+udpd_epx_data+128  #
                        .int 0
             # 5ième nouveau
                        .int endpoint2IN
                        .int ep2InHandler
                        .int USBCTRL_DPRAM_BASE+udpd_ctrl + 8   # in poste 2 IN Modif
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl+16 # in poste 3 IN
                        .int USBCTRL_DPRAM_BASE+udpd_epx_data+64
                        .int 0
             # fin
                        .fill LGCFGENDPOINT * 28,1,0 
.align 4
stLine_info:
                        .int 115200        #
                        .byte 1
                        .byte 0
                        .byte 8
                        
.align 4
.global __soft_vector_table          # INFO: vector table
__soft_vector_table:     .skip 52 * 4
                        
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss                                 # INFO: bss
.global iCptCarTrace,sBufferTrace,sBufferTrace1
.align 4
iTopSaisieOk:  .skip 4
iTopXmodem:    .skip 4
iCptCarSaisi:  .skip 4
iCptCarTrace:  .skip 4

sBufferRec:    .skip 1080
sEp0_buf:      .skip 160
/**********************************...-..--**/
/* SECTION CODE                              */
/**********************************************/
.text
.global initUsbDevice,envoyerMessage,recevoirMessage,envoyerCar,recevoirCar,recevoirCarMod
/**********************************************/
/* init connexion usb                         */
/**********************************************/
initUsbDevice:                      # INFO: initUsbDevice
    addi    sp, sp, -8
    sw      ra, 0(sp)
    li t1,RESETS_RESET_USBCTRL_BITS       # reset usb 
    li t0,RESETS_BASE + ATOMIC_CLEAR
    li t2,RESETS_BASE + ATOMIC_SET
    sw t1,RESETS_RESET(t2)                # set bit usb
    sw t1,RESETS_RESET(t0)                # clear bit usb
	
    li t0,RESETS_BASE
1:                                # boucle attente reset ok
    lw  t2,RESETS_DONE(t0)
    and t2,t2,t1
    beqz t2,1b  
     
    li t0,USBCTRL_DPRAM_BASE  
    li t1,udpd_fin / 4
    li t3,0
2:                           # boucle raz zone USB
    add t2,t0,t3
    sw x0,(t2)
    addi t3,t3,4
    blt t3,t1,2b
                              # voir 3.8.4. Interrupts and Exceptions
    li t0,USBCTRL_IRQ         # N° du poste IRQ USBs
    sll t0,t0,2               # 4 octets par poste 
    la  t1,__soft_vector_table      
    add t0,t0,t1
    la t2,isr_irq14           # adresse de la fonction à appeler
    sw t2,(t0)
    
                              # Autoriser interruption usb 14
    li a0,USBCTRL_IRQ + 16    # N° du poste IRQ USBs + déplacement
    li a1,1                   # partie haute du registre
    sll a0,a1,a0              # soit la valeur 0x40000000
    csrc    0xbe2,a0          # MEIFA Register
    csrs    0xbe0,a0          # MEIEA Register  
    
   
    la	a0,__VECTOR_TABLE     # voir 3.8
    addi a0,a0,1              # pour appel vectoriel voir la doc 
    csrw  mtvec,a0            # stocke l'adresse de la VTOR
    li t0,0b10001000
    csrs 0x300,t0             # 1 dans MSTATUS.MIE
    li t0,0b100000000000
    csrs 0x344,t0             # 1 bit MEIP MIP Register
    csrs 0x304,t0             # 1 bit MEIP MIE Register
    
    
    li t2,USB_USB_MUXING_TO_PHY_BITS | USB_USB_MUXING_SOFTCON_BITS
    li t0,USBCTRL_REGS_BASE
    sw t2,USB_MUXING(t0)
    
    li t2,USB_USB_PWR_VBUS_DETECT_BITS | USB_USB_PWR_VBUS_DETECT_OVERRIDE_EN_BITS
    sw t2,USB_PWR(t0)
    li t2,USB_MAIN_CTRL_CONTROLLER_EN_BITS
    sw t2,MAIN_CTRL(t0)
    
    li t2,USB_SIE_CTRL_EP0_INT_1BUF_BITS
   # li t2,USB_SIE_CTRL_PULLUP_EN_BITS
    sw t2,SIE_CTRL(t0)
    
    li t2,USB_INTS_BUFF_STATUS_BITS | USB_INTS_BUS_RESET_BITS | USB_INTS_SETUP_REQ_BITS
    sw t2,USB_INTE(t0)
    
    call usbSetupEndpoints
    
    li t0,USBCTRL_REGS_BASE + ATOMIC_SET
    li t2,USB_SIE_CTRL_PULLUP_EN_BITS
    sw t2,SIE_CTRL(t0) 
   
 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 

/**********************************************/
/*       Initialisation points de terminaison  */
/**********************************************/     
usbSetupEndpoints:            # INFO: usbSetupEndpoints
    addi    sp, sp, -16
    sw      ra, 0(sp) 
    sw      s0, 4(sp) 
    sw      s1, 8(sp) 
    sw      s2, 12(sp) 
    la s0,cfg_endpoints
    li s1,0
    li s2,uec_fin
 1:
    mul t3,s2,s1
    add a0,t3,s0
    lw a1,uec_descriptor(a0)
    beq a1,x0,2f              # boucle si égal à zéro
    lw a1,uec_handler(a0)
    beq a1,x0,2f              # boucle si égal à zéro
    
    call USBSetupEndpoint
    
 2:
    addi s1,s1,1
    li a1,USB_NUM_ENDPOINTS
    blt s1,a1,1b              # boucle si reste endpoint
    
 100:    
    lw      ra, 0(sp)
    lw      s0, 4(sp) 
    lw      s1, 8(sp) 
    lw      s2, 12(sp) 
    addi    sp, sp, 16
    ret 
    
/**********************************************/
/* initialisation un seul  EndPoint voir chapitre 12.7.4.2.2. datasheet RP2350   */
/**********************************************/     
/* a0 contient usb_endpoint_configuration  */
USBSetupEndpoint:               # INFO: usbSetupEndpoint
    addi    sp, sp, -8
    sw      ra, 0(sp) 
    lw t1,uec_endpoint_control(a0)
    beq t1,x0,100f
    lw t0,uec_data_buffer(a0)
    li t1, USBCTRL_DPRAM_BASE
    sub t0,t0,t1 
    li t1,EP_CTRL_ENABLE_BITS
    or t0,t0,t1
    li t1,EP_CTRL_INTERRUPT_PER_BUFFER
    or t0,t0,t1
    lw t1,uec_descriptor(a0)
    lbu t1,ued_bmAttributes(t1)
    slli t2,t1,EP_CTRL_BUFFER_TYPE_LSB
    or t0,t0,t2
    lw t1,uec_endpoint_control(a0)
    sw t0,(t1)
100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret     
/**********************************************/
/* préparation irq 14 interruption USB         */
/**********************************************/ 
.align 4  
isr_irq14:                      # INFO: isrIrq14
    addi    sp, sp, -16
    sw      ra, 0(sp) 
    sw      s0, 4(sp) 
    sw      s1, 8(sp) 

    li t0,USBCTRL_REGS_BASE + USB_INTS
    lw s1,(t0)             # charge le registre de l'interruption
    li s0,0                # init top

    li t1,USB_INTS_SETUP_REQ_BITS
    and t0,s1,t1
    beqz t0,1f
    
    or s0,s0,t1             # maj top 
    li t1,USB_SIE_STATUS_SETUP_REC_BITS
    li t0,USBCTRL_REGS_BASE + ATOMIC_CLEAR
    sw t1,SIE_STATUS(t0)
    call usbHandleSetupPacket
 
1:
    li t1,USB_INTS_BUFF_STATUS_BITS
    and t0,s1,t1
    beqz t0,2f
    
    or s0,s0,t1
    call  usbhandlebuffstatus

2:
    li t1,USB_INTS_BUS_RESET_BITS
    and t0,s1,t1
    beqz t0,3f

    or s0,s0,t1                  # bus reset
    li t1, USB_SIE_STATUS_BUS_RESET_BITS
    li t0,USBCTRL_REGS_BASE + ATOMIC_CLEAR
    sw t1,SIE_STATUS(t0)
    call  usbbusreset 
3:
    xor s0,s0,s1
    beq s0,x0,100f
	li a0,10
    call ledEclats        # erreur 
    call arretUrgent

 100:    
    lw      s0, 4(sp) 
    lw      s1, 8(sp) 
    lw      ra, 0(sp)
    addi    sp, sp, 16
    ret  
/**********************************************/
/* traitement du pâquet d'initialisation           */
/**********************************************/   
usbHandleSetupPacket:                      # INFO: usbHandleSetupPacket
    addi    sp, sp, -16
    sw      ra, 0(sp)  
    sw      s0, 4(sp)  
    sw      s1, 8(sp)  
    sw      s2, 12(sp)
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    li t1,1
    sw t1,uec_next_pid(a0)            # reset pid 
 
    li s0,USBCTRL_DPRAM_BASE          # adresse DPRAM
    lbu s1,pkt_bmRequestType(s0)      # type requete
    
    li s2,0b01100000                 # bits 5 et 6
    and s2,s2,s1                     # extrait ces bits
    li t2,0b0100000                  # si égaux à 01
    bne s2,t2,0f
      
    mv a0,s0
    call usbClassCDC
    j 100f

0:
    lbu t6,pkt_bRequest(s0)
    li t1,USB_DIR_OUT
    bne s1,t1,4f

    li a1,USB_REQUEST_SET_ADDRESS
    bne t6,a1,1f

    mv a0,s0
    call  usbsetdeviceaddress
    j 100f
1:
    li a1,USB_REQUEST_SET_CONFIGURATION
    bne t6,a1,96f

    mv a0,s0
    call usbsetdeviceconfiguration
    j 100f

4: 
    li a1,USB_DIR_IN
    bne s1,a1,97f
    
    li a1,USB_REQUEST_GET_DESCRIPTOR
    bne t6,a1,98f
    lhu s2,pkt_wValue(s0)
    srai s2,s2,8
    li a1,USB_DT_DEVICE
    bne s2,a1,5f
    
    call usbhandledevicedescriptor
    j 100f
5:
    li a1,USB_DT_CONFIG
    bne s2,a1,6f
    mv a0,s0
   
    call usbhandleconfigdescriptor
    j 100f

6:
    li a1,USB_DT_STRING
    bne s2,a1,7f                  # demande chaine caractères
    mv a0,s0
    call usbhandlestringdescriptor
    j 100f

7:    
    li t1,USB_DT_QUALIFIER       # ajout 01/09/21
    bne s2,t1,99f                # non implanté  -> signal 
    # ci dessous doit pouvoir etre supprimé
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    la t1, sEp0_buf
    li t2,1           # TODO: faux à revoir si pb
    sb t2,(t1)
    li a3,0
    call usbstarttransfert
    j 100f

96:
    li a0,10
	call ledEclats
    call arretUrgent
97:
    li a0,10
    call ledEclats
    call arretUrgent
98:
	li a0,10
    call ledEclats
    call arretUrgent
99:
    li a0,10
    call ledEclats
    call arretUrgent
 100:  
    lw      s0, 4(sp)  
    lw      s1, 8(sp)  
    lw      s2, 12(sp)    
    lw      ra, 0(sp)
    addi    sp, sp, 16
    ret 
    
/**********************************************/
/* analyse du registre buffer status pour trouver les buffers concernés  */
/**********************************************/   
usbhandlebuffstatus:                      # INFO: usbhandlebuffstatus
    addi    sp, sp, -20
    sw      ra, 0(sp) 
    sw s0,4(sp)     
    sw s1,8(sp) 
    sw s2,12(sp)
    sw s3,16(sp)
    call attenteCourte
    li t4,USBCTRL_REGS_BASE + USB_BUFF_STATUS
    lw t4,(t4)
    mv s3,t4
    li s0,0
    li s1,USB_NUM_ENDPOINTS
    slli s1,s1,1
    mv s2,s1
    li s1,1
    
1:                   # debut boucle
    bge s0,s2,100f   #   fin ?
    mv t1,s3
    and t1,t1,s1
    beq t1,x0,2f
    li t4,USBCTRL_REGS_BASE + ATOMIC_CLEAR + USB_BUFF_STATUS
    sw s1,(t4)

    mv a0,s0
    srai a0,a0,1
    li a1,1
    and a1,a1,s0
    not a1,a1
    call usbhandlebuffdone
    
    not a0,s1
    and s3,s3,a0
2:
    slli s1,s1,1
    addi s0,s0,1            # increment indice
    j 1b

 100:  
    lw s3,16(sp) 
    lw s2,12(sp)
    lw s1,8(sp)  
    lw s0,4(sp)  
    lw      ra, 0(sp)
    addi    sp, sp, 20
    ret
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*  a0 =  ep_num    et a1  =  in               */
usbhandlebuffdone:            # INFO: usbhandlebuffdone
    addi    sp, sp, -12
    sw      ra, 0(sp)  
    sw s1,4(sp) 
    li t2,0
    li t3,1
    and t3,t3,a1
    beq t3,x0,1f
    li t2,USB_DIR_IN
    
1:
    or t2,t2,a0
    li t5,0                    # i
    li t4,LGCFGENDPOINT
    la t6,cfg_endpoints

2:
    mv t3,t5
    mul t3,t4,t3
    add a0,t6,t3                 # adresse de chaque endpoint
    lw t1,uec_handler(a0)
    beq t1,x0,3f
    
    lw a1,uec_descriptor(a0)
    beq a1,x0,3f
    lbu t3,ued_bEndpointAddress(a1)
    bne t3,t2,3f
    call usbhandleepbuffdone
    j 100f
    
3:
    addi t5,t5,1
    li t3,USB_NUM_ENDPOINTS
    blt t5,t3,2b
    
100:
    lw    s1,4(sp)  
    lw    ra, 0(sp)
    addi  sp, sp, 12
    ret
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*  a0 =  ep               */
usbhandleepbuffdone:           # INFO: usbhandleepbuffdone
    addi    sp, sp, -8
    sw      ra, 0(sp) 
    sw    s1,4(sp)     
    lw t1,uec_buffer_control(a0) 
    lw t1,(t1)                 # adresse controle de la dpram
    li t2,USB_BUF_CTRL_LEN_MASK 
    and a1,t1,t2               #  extraction longueur 
    lw t3,uec_handler(a0)
    lw a0,uec_data_buffer(a0)  # adresse des données
    jalr t3                    # appel routine
    
100:
    lw    s1,4(sp)  
    lw    ra, 0(sp)
    addi  sp, sp, 8
    ret

/**********************************************/
/* reinitialisation du bus usb                   */
/**********************************************/   
usbbusreset:                      # INFO: usbbusreset
    addi    sp, sp, -8
    sw      ra, 0(sp)     
    la t0,bDev_addr               # raz adresse peripherique
    sb x0,(t0)
    la t0,should_set_address
    sw x0,(t0)
    li t0, USBCTRL_REGS_BASE
    sw x0,(t0)
    la t0,iConfigured             # raz du top connexion
    sw x0,(t0)  

 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret  
/**********************************************/
/* SECTION CODE                              */
/**********************************************/   
ep0OutHandler:                      # INFO: ep0OutHandler
    addi    sp, sp, -8
    sw      ra, 0(sp) 
                        # ne fait rien    
 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
ep0InHandler:                 # INFO: ep0InHandler
    addi    sp, sp, -8
    sw      ra, 0(sp) 
    la t2, should_set_address # adresse stockage adresse peripherique
    lw t3,(t2) 
    beq t3,x0,1f              # pas d'adresse du peripherique usb
    
    la t3,bDev_addr           # 
    lbu t3,(t3)               # charge adresse 
    li t0,USBCTRL_REGS_BASE
    sw t3,(t0)                # correspond au registre dev_addr_ctrl
    sw x0,(t2)                # raz adresse stockage
    j 100f
    
1:                            # renvoi non ok (à verifier)
    li a0,EP0_OUT_ADDR
    call usbgetendpointconfiguration
    li a1,0
    li a2,0
    li a3,0
    call usbstarttransfert
 
 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/**********************************************/
/* traitement envoi host                       */
/**********************************************/
ep1InHandler:                      # INFO: ep1InHandler
    addi    sp, sp, -8
    sw      ra, 0(sp)    
 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/**********************************************/
/* gestion endpoint 2 out                     */
/**********************************************/
/* a0 adresse du buffer de reception */
/* a1 nombre de caracteres */
ep2OutHandler:                      # INFO: ep2OutHandler
    addi    sp, sp, -16
    sw      ra, 0(sp)  
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    mv s1,a0
    mv s2,a1
    la t1,iTopXmodem
    lw t1,(t1)
    li t0,1
    beq t1,t0,4f             # connexion xmodem
    la t1,sBufferRec         # charge l'adresse buffer
    la t2,iCptCarSaisi       #charge adresse du compteur de caractère
    lw t3,(t2)
    lbu s0,(s1)              # charge le caractère
    li t6,0x0D               # car = retour ligne ? x0D
    bne s0,t6,1f
    
0:
    add t6,t1,t3
    sb x0,(t6)
    la t1,iTopSaisieOk
    li t0,1
    sw t0,(t1)
    sw x0,(t2)         # raz  nombre de caractères saisis
                       # et renvoyer retour ligne
    li a0,EP2_IN_ADDR
    call usbgetendpointconfiguration 
    la a1,szRetourLigne
    li a2,3
    li a3,0
    call usbstarttransfert
    j 100f
1:
    add t6,t1,t3
    sb s0,(t6)            # stocke le caractère reçu 
    addi t3,t3,1
    sw t3,(t2)            #  @ stocke le nouveau nombre de caractères
    mv a2,s2              # retourne le caractère saisi
    mv a1,s1
    li a0,EP2_IN_ADDR
    call usbgetendpointconfiguration
    mv a2,s2              # retourne le caractère saisi
    mv a1,s1
    li a3,0
    call usbstarttransfert
    j 100f

4:                       # gestion xmodem
    li t2,0
    la t1,sBufferRec    # charge l adresse buffer
5:                      # recopie des caractères reçus
   add t0,s1,t2
   lbu t3,(t0)
   add t0,t1,t2
   sb t3,(t0)
   addi t2,t2,1
   blt t2,s2,5b         # boucle

   la t1,iCptCarSaisi 
   sw s2,(t1)              # stocke le nombre de caractere reçu

   la t1,iTopSaisieOk      # maj du top saisie
   li t0,1
   sw t0,(t1)

 100:   
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)    
    lw      ra, 0(sp) 
    addi    sp, sp, 16
    ret   
/**********************************************/
/* semble etre un accusé de reception                              */
/**********************************************/ 
 ep2InHandler:                      # INFO: ep2InHandler
    addi    sp, sp, -8
    sw      ra, 0(sp) 
   # li a0,EP2_OUT_ADDR
   # call usbgetendpointconfiguration
    la a0,cfg_endpoints
    addi a0,a0,uec_fin * 3        # 4ieme poste de la liste des endpoints
    
    li a1,0            # message vide
    li a2,TAILLEPAQUET    # obligatoire
    li a3,0            # top message
    call usbstarttransfert   
 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/******************************************************************/
/*     envoie les messages au host                                       */ 
/******************************************************************/
/*  a0 adresse buffer                  */
envoyerMessage:                    # INFO: envoyerMessage
    addi    sp, sp, -8
    sw      ra, 0(sp)   
    sw      s1, 4(sp)
    mv s1,a0
    li a2,0
    
1:                       # boucle calcul longueur 
    add a0,s1,a2
    lbu t0,(a0)
    beq t0,x0,2f
    addi a2,a2,1
    j 1b   

2:
   # li a0,EP3_IN_ADDR
   # call usbgetendpointconfiguration
    la a0,cfg_endpoints
    addi a0,a0,uec_fin * 4    # 5ieme poste de la liste des endpoints
    mv a1,s1
    li a3,1                # top message
    call usbstarttransfert
    
    #li a0,EP3_IN_ADDR
   # call usbgetendpointconfiguration
    la a0,cfg_endpoints
    addi a0,a0,uec_fin * 4     # 5ieme poste de la liste des endpoints
    li a1,0
    li a2,0
    li a3,1               # top message
    call usbstarttransfert
    
100:
    lw      s1, 4(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
/******************************************************************/
/*     envoie un caractere au host                                       */ 
/******************************************************************/
/*  a0 contient le caractere                  */
envoyerCar:                    # INFO: envoyerCar
    addi    sp, sp, -12
    sw      ra, 0(sp) 
    sw      s1, 4(sp) 
    sw      a0, 8(sp)        # sauve le car 
    addi s1,sp,8            # et son adresse
    la a0,cfg_endpoints
    addi a0,a0,uec_fin * 4
    mv a1,s1              # adresse du caractere
    li a2,1               # longueur
    li a3,1               # top message
    call usbstarttransfert
    la a0,cfg_endpoints
    addi a0,a0,uec_fin * 4
    li a1,0
    li a2,0
    li a3,1               # top message
    call usbTransfert
    
    lw      ra, 0(sp)
    lw      s1, 4(sp) 
    addi    sp, sp, 12
    ret 
.align 2
/******************************************************************/
/*     reçois les messages du host                                       */ 
/******************************************************************/
/*  a0 adresse buffer                  */
recevoirMessage:                    # INFO: recevoirMessage
    addi    sp, sp, -8
    sw      ra, 0(sp)   
    sw      s0, 4(sp)
    mv s0,a0
    la t0,iTopXmodem    # raz ce top pour ep2Outhandler
    sw x0,(t0)
    li t2,0
    la t4,iTopSaisieOk
    sw t2,(t4)          # raz top saisie
    li t0,1
    
1:
    lw t2,(t4)     # lecture top saisie
    beq t2,t0,2f
    li a0,5
    call attendre
    j 1b
    
2:                      # recopie buffer
    la t1,sBufferRec
    li t2,0

3:
    add t4,t1,t2
    lbu t0,(t4)
    add t4,s0,t2
    sb  t0,(t4)
    beq t0,x0,100f
    addi t2,t2,1
    j 3b
    
  
100:
    lw      s0, 4(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
/******************************************************************/
/*     reçois un caractere du host                                       */ 
/******************************************************************/
/* a0 délai attente */
/* a0 retourne le caractere ou -1 si pas de réponse */
recevoirCar:                    # INFO: recevoirCar
    addi    sp, sp, -20
    sw      ra, 0(sp)   
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      t1, 12(sp)
    sw      t2, 16(sp)
    mv s0,a0
    la s1,iTopSaisieOk
    sw x0,(s1)          # raz top saisie

1:
    lw t2,(s1)     # lecture top saisie
    bne t2,x0,2f
    li a0,1
    call attendre
    addi s0,s0,-1   # decrement délai attente
    ble s0,x0,3f
    j 1b
    
2:                      # recopie buffer
    la t1,sBufferRec
    lbu a0,(t1)       # extrait caractere
    j 100f
3:
    li a0,-1          # pas de réponse
  
100:
    lw      t1, 12(sp)
    lw      t2, 16(sp)
    lw      s1, 8(sp)
    lw      s0, 4(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 20
    ret 
/******************************************************************/
/*     reçois les caracteres par Xmodem du host                                       */ 
/******************************************************************/
/*  a0 délai attente */
/*  a1 adresse buffer */
/* a0 retourne le nombre de caractere ou -1 si pas de réponse */
recevoirCarMod:                    # INFO: recevoirCarMod
    addi    sp, sp, -20
    sw      ra, 0(sp)   
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      t1, 12(sp)
    sw      t2, 16(sp)
    mv s0,a0
    la t0,iTopXmodem    # positionne ce top pour ep2Outhandler
    li t1,1
    sw t1,(t0)
    la s1,iTopSaisieOk
    sw x0,(s1)          # raz top saisie

1:
    lw t2,(s1)           # lecture top saisie
    bne t2,x0,2f
    li a0,5              # 2
    call attenteCourteProg
    addi s0,s0,-1   # decrement délai attente
    ble s0,x0,4f
    j 1b
    
2:                      # recopie buffer
    la s0,iCptCarSaisi
    lw s0,(s0)
    la t1,sBufferRec
    li t2,0
3:
    add t0,t1,t2
    lbu t4,(t0)
    add t0,a1,t2
    sb t4,(t0)
    addi t2,t2,1
    blt t2,s0,3b
   
    la a0,cfg_endpoints
    addi a0,a0,uec_fin * 4    # pour EP3_IN_ADDR
    li a1,0
    li a2,0
    li a3,1                  # top message
    call usbTransfert
    li a0,2                  # 2 bon
    call attenteTresCourte
   # li a0,1
   # call attendre
    mv a0,s0          # retourne le nb de caractere
    j 100f
4:
    li a0,-1          # pas de réponse
  
100:
    lw      t1, 12(sp)
    lw      t2, 16(sp)
    lw      s1, 8(sp)
    lw      s0, 4(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 20
    ret 
/**********************************************/
/* recherche endpoint correspondant à l adresse                             */
/**********************************************/
/* a0 adresse                   */
/* a0 retourne adresse du end point trouvé */
usbgetendpointconfiguration:       # INFO: usbgetendpointconfiguration
    addi    sp, sp, -8
    sw      ra, 0(sp)
    la t1, cfg_endpoints
    li t3,0             # indice
    li t2,uec_fin       # taille du poste  
	li t0,USB_NUM_ENDPOINTS
1:
    mul t4,t2,t3        # calcul déplacement
    add t4,t4,t1        # ajout à l'adresse
    lw t5,uec_descriptor(t4)
    lbu  t5,ued_bEndpointAddress(t5)
    beq t5,a0,2f        # egalité -> trouvé
    addi t3,t3,1
    blt t3,t0,1b             # et boucle
    j 100f
    
2:
    mv a0,t4          # retourne adresse du endpoint trouvé
 100:    
 
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/**********************************************/
/* gestion classe cdc                             */
/**********************************************/    
/* a0 = adresse setup packet                */
usbClassCDC:       # INFO: usbClassCDC
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    mv t4,a0
    lhu s0,pkt_wValue(t4)
    lbu s1,pkt_bRequest(t4)           # requete
    lbu t2,pkt_bmRequestType(t4)      # type requête
    
    li t3,0x80 
    and t2,t2,t3               # extraction direction
    beq t2,x0,4f
                       # 1 = direction device to host
    li t2,USB_GET_CDC_LINE_CODING
    bne s1,t2,1f
    
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    la a1,stLine_info
    li a2,line_fin
    li a3,0
    call usbstarttransfert
    j 100f

1:
    li t2,USB_SET_CDC_LINE_CODING
    bne s1,t2,2f
    la t0,USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
    li t1,0
    la t2,stLine_info

11:
    add t5,t0,t1
    add t4,t2,t1    # voiit util prec T4et t5
    lbu t3,(t5)
    sb t3,(t4)
    addi t1,t1,1
    li t3,line_fin
    blt t1,t3,11b
    
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    li a1,0
    li a2,0
    li a3,0
    call usbstarttransfert
    j 100f

2:
    li t2,USB_CDC_CONTROL_LINE_STATE
    bne s1,t2,3f
    li t0,USBCTRL_REGS_BASE
    lw t2,SIE_STATUS(t0)
    
    li t3,0b01100
    and t2,t2,t3
    srai t2,t2,2
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    li a1,0
    li a2,0
    li a3,0
    call usbstarttransfert
    li a0,5
    call attendre        #  obligatoire
    j 100f
    
3:
    li a0,10
    call ledEclats
    call arretUrgent
4:
                        # direction host to device                    
    li t2, USB_GET_CDC_LINE_CODING 
    bne s1,t2,5f
    
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    la a1,stLine_info
    li a2,line_fin
    li a3,0
    call usbstarttransfert
    j 100f
    
5:
    li t2,USB_SET_CDC_LINE_CODING
    
    bne s1,t2,6f
 
    li t0,USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
    li t1,0
    la t2,stLine_info

51:
    add t4,t0,t1         # voir l'utilisation
    add t5,t2,t1
    lbu  t3,(t4)
    sb  t3,(t5)
    addi t1,t1,1
    li t4,line_fin
    blt t1,t4,51b
    
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    li a1,0
    li a2,0
    li a3,0
    call usbstarttransfert
    li a0,2
    call attendre
    j 100f
    
6:
    li t2,USB_CDC_CONTROL_LINE_STATE
    bne s1,t2,7f
    li a0,EP0_IN_ADDR
    
    call usbgetendpointconfiguration
    li a1,0
    li a2,0
    li a3,0
    call usbstarttransfert
    li a0,5
    call attendre
    li t2,3
    
    bne s0,t2,100f
    
    li a0,EP2_IN_ADDR     # oui envoi message début
    call usbgetendpointconfiguration
    li a1,0
    li a2,0
    li a3,0
    call usbstarttransfert
    la a0,iConfigured
    li t1,TRUE
    sw t1,(a0)
    j 100f
    
7:
    li a0,10
    call ledEclats
    call arretUrgent

 100:  
    lw      s0, 4(sp)
    lw      s1, 8(sp) 
    lw      ra, 0(sp)
    addi    sp, sp, 16
    ret
/**********************************************/
/* reception adresse device                             */
/**********************************************/    
usbsetdeviceaddress:       # INFO: usbsetdeviceaddress
    addi    sp, sp, -8
    sw      ra, 0(sp)
    lhu t1,pkt_wValue(a0)
    li t2,0xFF
    and t2,t2,t1
    la t3,bDev_addr
    sb t2,(t3)
    la t3,should_set_address
    li t2,TRUE
    sw t2,(t3)               # true -> Should_set_address

    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    li a1,0
    li a2,0
    li a3,0
    call usbstarttransfert

 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/**********************************************/
/* recup config device                              */
/**********************************************/    
usbsetdeviceconfiguration:       # INFO: usbsetdeviceconfiguration
    addi    sp, sp, -8
    sw      ra, 0(sp)
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    li a1,0
    li a2,0
    li a3,0
    call usbstarttransfert
 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/**********************************************/
/* gestion requête demande chaine de caractères                             */
/**********************************************/    
usbhandlestringdescriptor:       # INFO: usbhandlestringdescriptor
    addi    sp, sp, -8
    sw      ra, 0(sp)
    lhu t1,pkt_wValue(a0)
    li t2,0xFF
    and t2,t2,t1
    bne t2,x0,1f
                                  # envoi du code langage
    li t4,4
    la t2,sEp0_buf
    la t3,cfg_lang_descriptor
    lw t1,(t3)
    sw t1,(t2)
    j 2f
    
1:  
    la t0,cfg_descriptor_strings          # recherche de la chaine à retourner
    addi t2,t2,-1
    slli t2,t2,2
    add t0,t0,t2
    lw t0,(t0)
     
    call usbpreparestringdescriptor
    mv t4,a0             #  retourne la longueur

2:                            # envoi résultat
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    la a1,sEp0_buf
    mv a2,t4
    li a3,0
    call usbstarttransfert  
 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/**********************************************/
/* preparation chaine en caractères unicode                             */
/**********************************************/    
usbpreparestringdescriptor:       # INFO: usbpreparestringdescriptor
    addi    sp, sp, -8
    sw      ra, 0(sp)
    li t1,0
1:                       # boucle calcul longueur
   add t4,a0,t1
   lbu t2,(t4)
   beq t2,x0,2f
   addi t1,t1,1
   j 1b
   
2:
   slli t1,t1,1
   addi t1,t1,2
   la t3,sEp0_buf
   sb t1,(t3)             #  longueur
   li t6,3                 # type descripteur
   sb t6,1(t3)
   li t6,0
   li t2,2                 #  car 2 caractères déjà stockés
   li t5,0
   
3:
   add a1,a0,t6           # utilise a1
   lbu t4,(a1)           # lit un caractère
   beq t4,x0,4f          # fin de chaine ?
   add a1,t3,t2
   sb t4,(a1)            # le stocke dans 1er octet
   addi t2,t2,1
   add a1,t3,t2
   sb t5,(a1)           # stocke zéro dans 2ième octet
   addi t2,t2,1
   addi t6,t6,1
   j 3b
4:
    mv t0,t1           #  retourne la longueur
100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/**********************************************/
/*  envoi du device descriptif                 */
/**********************************************/    
usbhandledevicedescriptor:       # INFO: usbhandledevicedescriptor
    addi    sp, sp, -8
    sw      ra, 0(sp)
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    li t1,1
    sw t1,uec_next_pid(a0)         # remise à 1 du pid
    la t1,cfg_device_descriptor
    lw a1,(t1)
    li a2,LGDEVICE
    li a3,0
    call usbstarttransfert
 
 100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/**********************************************/
/*  envoi des descriptifs de configuration        */
/**********************************************/    
usbhandleconfigdescriptor:       # INFO: usbhandleconfigdescriptor
    addi    sp, sp, -20
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    sw      s3, 16(sp)
    mv s3,a0
    la t5,sEp0_buf
    la t2,cfg_config_descriptor
    lw t3,(t2)
    li t0,0
    
1:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGCONFDESC
    blt t0,t4,1b
    
    addi t5,t5,LGCONFDESC                # adresse fin de la copie 
    lhu t1,pkt_wLength(s3)             # nombre de caractères demandés
    la t2,confd_wTotalLength
    lhu t2,(t2)
    blt t1,t2,20f
                                      # si inférieur on envoie que l'entête
                                       # sinon recopie de tous les éléments
                                       # interface association
   
    la t3,interface_association_descriptor
    li t0,0
 
2:
    add t4,t3,t0
    lbu t2,(t4)
    add t4,t5,t0
    sb t2,(t4)
    addi t0,t0,1
    li t4,LGINTASSO
    blt t0,t4,2b
    add t5,t5,t4
    
                                # interface communication
    la   t3, cfg_interface_descriptor 
    lw t3,(t3)
    li t0,0    

3:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGINTERFACE
    blt t0,t4,3b
    addi t5,t5,LGINTERFACE
  
    la t3, cdc_header_descriptor
    li t0,0

4:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGCDCHEAD
    blt t0,t4,4b
    addi t5,t5,LGCDCHEAD
    
    la t3,cdc_acm_descriptor
    li t0,0
5:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGCDCACM
    blt t0,t4,5b
    addi t5,t5,LGCDCACM
    
    la t3,cdc_union_descriptor
    li t0,0
    
6:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGCDCUNION
    blt t0,t4,6b
    addi t5,t5,LGCDCUNION
    
    la t3,cdc_call_descriptor
    li t0,0
7:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGCDCCALL
    blt t0,t4,7b
    addi t5,t5,LGCDCCALL
    
    la t3, endpoint1
    li t0,0
8:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGDESCRIPT
    blt t0,t4,8b
    addi t5,t5,LGDESCRIPT
    
   la t3,interface1_descriptor
   li t0,0
9:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGINTERFACE
    blt t0,t4,9b
    addi t5,t5,LGINTERFACE
                              # debut endpoint
    la t6,cfg_endpoints
    li s3,3
    li t0,0
10:                           # boucle de copie des endpoints
    mv t3,s3
    li t4,LGCFGENDPOINT
    mul t3,t4,t3
    add t0,t6,t3              # adresse de chaque endpoint
    
    lw t3,uec_descriptor(t0)
    beq t3,x0,12f

    li t0,0                     # sinon recopie du endpoint
11:
    add t4,t3,t0
    lbu t1,(t4)
    add t4,t5,t0
    sb t1,(t4)
    addi t0,t0,1
    li t4,LGDESCRIPT
    blt t0,t4,11b
    addi t5,t5,LGDESCRIPT

12:
    addi s3,s3,1
    li t4,5
    blt s3,t4,10b

20:                       # envoi descriptif simple ou complet

    mv s1,t5
    li a0,EP0_IN_ADDR
    call usbgetendpointconfiguration
    la a1,sEp0_buf
    mv a2,s1
    sub a2,a2,a1
    mv s1,a2
    li a3,0
    call usbstarttransfert
 
 100:   
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp) 
    lw      ra, 0(sp)
    addi    sp, sp, 20
    ret
/**********************************************/
/* transfer octets                              */
/**********************************************/
# a0 adresse endpoints config uec
# a1 Adresse buffer
# a2  longueur
# a3 top message
usbstarttransfert:       # INFO: usbstarttransfert
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    mv s0,a0
1:
    li t2,TAILLEPAQUET                # taille maxi d'un paquet ?
    ble a2,t2,3f            # taille inferieure

    sub s1,a2,t2
    mv a2,t2
    add s2,a1,t2
    mv a0,s0
    call usbTransfert
    li a0,1                  # attente obligatoire !!!
    call attendre 
    li t3,1
    bne a3,t3,2f

    mv a0,s0
    li a1,0
    li a2,0
    call usbTransfert
    li a0,1                  # attente obligatoire !!!
    call attendre 
2:

    mv a0,s0                 # pointeur uec
    mv a1,s2                 # nouveau début du buffer
    mv a2,s1                 # longueur restante
    j 1b
3:
    call usbTransfert
    li a0,1                  # attente obligatoire !!!
    call attendre
    
 100:  
    lw      s0, 4(sp) 
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 16
    ret
/**********************************************/
/* transfert des octets vers l'hote             */
/**********************************************/    
usbTransfert:                    # INFO: usbTransfert
    addi    sp, sp, -12
    sw      ra, 0(sp)  
    sw      s0, 4(sp)
    mv t6,a0                     # adresse uec
 
    li t5,USB_BUF_CTRL_AVAIL
    or t5,t5,a2
    lw t4,uec_descriptor(t6)       # adresse descriptor uec
    addi t4,t4,ued_bEndpointAddress
    lbu t4,(t4)
    li t3,USB_DIR_IN
    and t4,t4,t3
    beq t4,x0,2f
    
    lw t4,uec_data_buffer(t6)       # buffer
    li t0,0
    
1:                                 # recopie buffer
    add s0,a1,t0
    lbu t3,(s0)
    add s0,t4,t0
    sb t3,(s0)
    addi t0,t0,1
    blt t0,a2,1b
    

    li t1,USB_BUF_CTRL_FULL
    or t5,t5,t1
2:
    lw t2,uec_next_pid(t6)
    beq t2,x0,3f
    li t2,USB_BUF_CTRL_DATA1_PID
    or t5,t5,t2
    j 4f
    
3:
    li t2,USB_BUF_CTRL_DATA0_PID
    or t5,t5,t2
    
4:
    lw t2,uec_next_pid(t6)
    li t1,1
    xor t2,t2,t1
    sw t2,uec_next_pid(t6)
    
    lw t6,uec_buffer_control(t6)
    sw t5,(t6) 

  100:  
    lw      s0, 4(sp)  
    lw      ra, 0(sp)
    addi    sp, sp, 12
    ret   
/**********************************************/
/*         vecteur adresse des routines exceptions    */
/**********************************************/ 
.global   __VECTOR_TABLE
.align 8
__VECTOR_TABLE:
    j appelsoft1           # appel si exceptions
    .skip 8
    j appelsoft1
    .skip 12
    j appelsoft1 
    .skip 12  
 /**********************************************/
/* traitement interruption    voir 3.8.4. Interrupts and exceptions     */
/**********************************************/   
.equ  RVCSR_MEINEXT_OFFSET,          0x00000be4
.equ  RVCSR_MEICONTEXT_OFFSET,       0x00000be5
.equ  RVCSR_MEICONTEXT_CLEARTS_BITS, 0x00000002
isr_riscv_machine_external_irq:           # INFO: isr_riscv_machine_external_irq
# cette routine doit être la 4ième de la __VECTOR_TABLE ci dessus 
# Save all caller saves and temporaries before entering a C ABI function.
# Note mstatus.mie is cleared by hardware on interrupt entry, and
# we're going to leave it clear.
    addi sp, sp, -80
    sw ra, 0(sp)        # save registres
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)
    sw a3, 28(sp)
    sw a4, 32(sp)
    sw a5, 36(sp)
    sw a6, 40(sp)
    sw a7, 44(sp)
    sw t3, 48(sp)
    sw t4, 52(sp)
    sw t5, 56(sp)
    sw t6, 60(sp)
    
    csrr a0, mepc
    csrr a1, mstatus
    sw a0, 64(sp)       # save de ces 2 registres hazard3
    sw a1, 68(sp)  
    csrr t1, RVCSR_MEINEXT_OFFSET
    
save_meicontext:
    # Make sure to set meicontext.clearts to clear+save mie.msie/mtie along
    # with ext IRQ context. We don't let these preempt ext IRQs because they
    # clear meicontext.mreteirq, which breaks __get_current_exception().
    csrrsi a2, RVCSR_MEICONTEXT_OFFSET, RVCSR_MEICONTEXT_CLEARTS_BITS
    sw a2, 72(sp)
 
get_first_irq:
# Sample the current highest-priority active IRQ (left-shifted by 2) from
# meinext. Don't set the `update` bit as we aren't saving/restoring meicontext --
# this is fine, just means you can't check meicontext to see whether you are in an IRQ.
    csrr a0, RVCSR_MEINEXT_OFFSET
    csrrs t0, RVCSR_MEINEXT_OFFSET,1
# MSB will be set if there is no active IRQ at the current priority level
    bltz a0, no_more_irqs
dispatch_irq:
    csrsi mstatus, 0x8
# Load indexed table entry and jump through it. No bounds checking is necessary
# because the hardware will not return a nonexistent IRQ.
    la a1,__soft_vector_table
    add a1, a1, a0
    lw a1,(a1)
    jalr ra, a1
    
    csrci mstatus, 0x8
get_next_irq:
# Get the next-highest-priority IRQ
    csrrs a0, RVCSR_MEINEXT_OFFSET,1
# MSB will be set if there is no active IRQ at the current priority level
    bgez a0, dispatch_irq
no_more_irqs:
# Restore saved context and return from IRQ
    lw a0, 64(sp)
    lw a1, 68(sp)
    lw a2, 72(sp)
    csrw mepc, a0
    csrw mstatus, a1
    csrw RVCSR_MEICONTEXT_OFFSET, a2
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    #lw a0, 16(sp)
    lw a1, 20(sp)
    lw a2, 24(sp)
    lw a3, 28(sp)
    lw a4, 32(sp)
    lw a5, 36(sp)
    lw a6, 40(sp)
    lw a7, 44(sp)
    lw t3, 48(sp)
    lw t4, 52(sp)
    lw t5, 56(sp)
    lw t6, 60(sp)
check_irq_before_exit:
    csrr a0, RVCSR_MEINEXT_OFFSET
    bgez a0, save_meicontext
    lw a0, 16(sp)
    addi sp, sp, 80
    mret

.align 4
/**********************************************/
/* arret d'urgence mettre registre powman      */
/**********************************************/
appelsoft1:                      # INFO: appelsoft1
    addi    sp, sp, -8
    sw      ra, 0(sp) 
    li a0,25
    call initGpioLed
    li a0,10
    call ledEclats
    call arretUrgent
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 

    
    