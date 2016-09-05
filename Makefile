PROJECT = boilerplate
#####################################
DEVICE = MSP430F5529
DRIVERLIB = MSP430F5xx_6xx
#####################################
USB_CDC = 0
USB_HID = 1
USB_MSC = 0
USB_PHDC = 0
#####################################
SRC_DIR = src
OUT_DIR = build
TOOLCHAIN_DIR = toolchain
DRIVERLIB_DIR = $(TOOLCHAIN_DIR)/driverlib/driverlib/$(DRIVERLIB)
USBLIB_DIR = $(TOOLCHAIN_DIR)/usblib/include
#####################################
GCC_DIR = $(TOOLCHAIN_DIR)/msp430-gcc
GCC_BASE = $(GCC_DIR)/bin/msp430-elf-
CC = $(GCC_BASE)gcc
XX = $(GCC_BASE)g++
GDB = $(GCC_BASE)gdb
GDB_AGENT = $(GCC_DIR)/bin/gdb_agent_console
OBJCOPY = $(GCC_BASE)objcopy
OBJDUMP = $(GCC_BASE)objdump
MAKETXT = $(TOOLCHAIN_DIR)/srecord/bin/srec_cat
FLASHER = DYLD_LIBRARY_PATH=$(TOOLCHAIN_DIR)/flasher:${DYLD_LIBRARY_PATH} \
			LD_LIBRARY_PATH=$(TOOLCHAIN_DIR)/flasher:${LD_LIBRARY_PATH} \
			$(TOOLCHAIN_DIR)/flasher/MSP430Flasher
REPLACE = awk
#####################################
INCLUDES += -I $(GCC_DIR)/include
INCLUDES += -I $(GCC_DIR)/msp430-elf/include
INCLUDES += -I $(DRIVERLIB_DIR)
INCLUDES += -I $(USBLIB_DIR)
INCLUDES += -I $(SRC_DIR)/USB_config
#####################################
LIBS += -L $(GCC_DIR)/lib
#####################################
LDFLAGS += -L $(GCC_DIR)/include
LDFLAGS += -T $(USBLIB_DIR)/USB_API/msp430USB.ld
LDFLAGS += -T $(shell echo $(DEVICE) | tr A-Z a-z).ld
LDFLAGS += -mmcu=$(DEVICE) -g -Wl,--gc-sections
#####################################
CFLAGS += -g -O2 -D__$(DEVICE)__ -mmcu=$(DEVICE)
CFLAGS += -ffunction-sections -fdata-sections -DDEPRECATED
#####################################
GDBFLAGS += --ex="tar rem :55000"
GDBFLAGS += --ex="load"
#####################################
SRC += $(shell find $(SRC_DIR) -name "*.c" -type f)
SRC += $(wildcard $(DRIVERLIB_DIR)/*.c)
SRC += $(wildcard $(USBLIB_DIR)/USB_API/USB_Common/*.c)
#####################################
ifeq ($(USB_CDC),1)
	SRC += $(wildcard $(USBLIB_DIR)/USB_API/USB_CDC_API/*.c)
endif
ifeq ($(USB_HID),1)
	SRC += $(wildcard $(USBLIB_DIR)/USB_API/USB_HID_API/*.c)
endif
ifeq ($(USB_MSC),1)
	SRC += $(wildcard $(USBLIB_DIR)/USB_API/USB_MSC_API/*.c)
endif
ifeq ($(USB_PHDC),1)
	SRC += $(wildcard $(USBLIB_DIR)/USB_API/USB_CDC_API/*.c)
endif
#####################################
OBJ += $(patsubst %.c,$(OUT_DIR)/%.o,$(SRC))
#####################################
OUT_ELF = $(OUT_DIR)/$(PROJECT).elf
OUT_HEX = $(OUT_DIR)/$(PROJECT).hex
OUT_TXT = $(OUT_DIR)/$(PROJECT).txt
OUT = $(OUT_ELF) $(OUT_HEX) $(OUT_TXT)
#####################################

all: $(OUT)

$(OUT_DIR)/%.o: %.c
	@echo ============================================
	@echo Compiling $<
	@mkdir -p $(shell dirname $@)
	$(CC) $(INCLUDES) $(LIBS) $(CFLAGS) -c $< -o $@

%.elf: $(OBJ)
	@echo ============================================
	@echo Linking objects and generating output binary
	$(CC) $(LDFLAGS) $(LIBS) $(OBJ) -o $@

%.hex: %.elf
	@echo ============================================
	@echo Generating Intel Hex format output binary
	$(OBJCOPY) -O ihex $< $@

%.txt: %.hex
	@echo ============================================
	@echo Generating TI-TXT format output binary
	$(MAKETXT) -O -TITXT $< -I | $(REPLACE) 'sub("$$", "\r")' > $@

flash: $(OUT_TXT)
	@echo ============================================
	@echo Flashing the target MSP430 device
	$(FLASHER) -v -g -z [VCC] -w $<

debug: $(OUT_ELF)
	$(GDB) $(GDBFLAGS) $<

agent:
	$(GDB_AGENT) $(GCC_DIR)/msp430.dat

clean:
	rm -rf $(OUT_DIR)
