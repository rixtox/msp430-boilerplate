# MSP430 Boilerplate

This is a template project for MSP430 C projects. It's a "bare-metal" project,
meaning no IDE is required for compiling, debuging and flashing. There comes a
toolchain setup script to download and install most of the depending cross-
platform tools such as the MSP430 cross compiler, device memory mapping
definition and peripheral header files, basic hardware abstraction drivers, USB
stack library, and etc. All those dependencies will be installed into the
`toolchain` sub-folder. Nothing will be written out of the root of the project
directory.

## Supported OS for Toolchains

* Windows (with MSYS2 or Cygwin)
* Mac OS X (tested on OS X El Capitan 10.11.6)
* Linux (tested on Ubuntu precise 12.04.5)

## Use of Toolchain Setup Script

For Linux systems, you need to install basic build tools and `libtool` to build
the SRecord tool which only ships in source code for Linux platforms.

```bash
apt-get dist-upgrade
apt-get update
apt-get install build-essential libtool-bin libboost-dev libgcrypt11-dev curl git unzip
```

Then you can clone this repository and run the `setup_toolchain.sh` script
inside. All depending tools should be set up after finishes.

For Windows, please read [this instruction][1].

## Building

Use `make` for compiling the project and libraries source code, linking, and
generating flashing-ready binary files. With the defalut Makefile configuration,
all compiled ELF objects will be placed in the sub-directories of `build/`
folder with their relative source file path to the project root folder. The
linked ELF binary will be placed under `build/` and named after the project name
defined in the Makefile, and ends with `.elf` extension. Similarly, an Intel HEX
format binary file is generated with `.hex` extension, and also a `.txt` file
for TI-TXT flashing binary format.

There are several variables you might want to change in `Makefile`:

* `PROJECT` defines your project name, and will be used in the output binary
  file names.
* `DEVICE` defines the CPU you are targeting. You can check the list of possible
  values by taking the header file names inside `toolchain/devices/include`
  folder.
* `DRIVERLIB` specifies the version of driverlib to be used. Find the one
  relating to your CPU model inside `toolchain/driverlib/driverlib` folder.

## Flashing

You can program the flash on your CPU with the TI-TXT flashing-ready binary file
using the `MSP430Flasher` utility provided by Texas Instruments.

```bash
make flash
```

## Debugging with GDB

There are many ways you can debug the program. The TI MSP430 GCC full version
installed in your toolchain ships with a GDB agent that acts as a debugging
proxy between the FET module on your MSP development board or programmer, and
the GDB client. To start the GDB agent, run

```bash
make agent
```

Then in a separate terminal window, start the GDB session with

```bash
make debug
```

This Makefile job automatically connects to the local 55000 port which the GDB
agent is listenning to, and downloads the binary with `load` GDB command. You
are all set to start debugging your program right away.

## Debugging with CCSv6

As many of you may prefer a graphical interface when it comes to debugging, the
Texas Instruments Code Composer Studio v6 would be a great choice for the job.
As we know, the CCS ships with TI's proprietary compiler that limits to 16KB
binary size for community users. However, we are using the GCC version of the
compiler which has no limits to all users. We can therefore import to CCS as a
Makefile project and use it as our build and debug environment.

Follow [these instructions][2] to setup and debug in CCS.

## Folder Structures

```
.
├── build/                  # Building output folder
│   ├── $(PROJECT).elf      # ELF binary file
│   ├── $(PROJECT).hex      # Intel HEX format binary file
│   ├── $(PROJECT).txt      # TI-TXT flashing binary file
│   └── ...                 # Folders storing other object files
├── toolchain/              # Toolchain install folder generated by the setup script
│   ├── driverlib/          # Device independent basic hardware abstraction drivers
│   ├── flasher/            # TI provided FET programmer CLI front-end client
│   ├── msp430-gcc/         # TI MSP430 GCC full version with GDB agent utility and device headers
│   ├── srecord/            # SRecord EPROM manipulation tool to convert Intel HEX to TI-TXT format
│   ├── usblib/             # TI provided USB driver stack
│   └── ...                 # More to be added in the future
├── src/                    # Project source code
├── Makefile
├── README.md
├── setup_toolchain.sh      # Toolchain setup script
└── ...
```

[1]: https://github.com/rixtox/msp430-boilerplate/wiki/Windows-Toolchain-Setup-Instruction
[2]: https://github.com/rixtox/msp430-boilerplate/wiki/Import-and-Debug-with-CCSv6
