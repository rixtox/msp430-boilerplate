#!/bin/bash

TOOLCHAIN_DIR="toolchain"

case $OSTYPE in
    darwin* | linux* )
        ;;
    cygwin* | msys* | win32* )
        net session > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            >&2 echo "Please start a terminal in Administrator privilege and run this script again!"
            exit 1
        fi
        ;;
    * )
        >&2 echo "Unsupported OS type: $OSTYPE"
        exit 1
        ;;
esac

mkdir -p "$TOOLCHAIN_DIR"
pushd "$TOOLCHAIN_DIR"

echo "Downloading SRecord EPROM utility..."
DEST="srecord"
case $OSTYPE in
    darwin* )
        FILE="$DEST.tar.gz"
        URL="https://homebrew.bintray.com/bottles/srecord-1.64.el_capitan.bottle.tar.gz"
        ;;
    linux* )
        FILE="$DEST.tar.gz"
        URL="http://downloads.sourceforge.net/project/srecord/srecord/1.64/srecord-1.64.tar.gz"
        ;;
    cygwin* | msys* | win32* )
        FILE="$DEST.zip"
        URL="http://downloads.sourceforge.net/project/srecord/srecord-win32/1.64/srecord-1.64-win32.zip"
        ;;
esac
rm -rf "$DEST" "$FILE" > /dev/null
curl -L -o "$FILE" "$URL"
echo "Extracting SRecord EPROM utility..."
mkdir -p "$DEST"
case $OSTYPE in
    darwin* )
        tar -C "$DEST" --strip-components 2 -zxf "$FILE"
        ;;
    linux* )
        tar -C "$DEST" --strip-components 1 -zxf "$FILE"
        pushd "$DEST"
        echo "Compiling SRecord EPROM utility..."
        ./configure
        make
        popd
        ;;
    cygwin* | msys* | win32* )
        mkdir -p "$DEST/bin"
        unzip -qq -d "$DEST/bin" "$FILE"
        chmod +x "$DEST/bin/"*
        ;;
esac
rm "$FILE"
echo

echo "Downloading MSP Flasher..."
DEST="flasher"
case $OSTYPE in
    darwin* )
        URL="https://bitbucket.org/rixtox/msp430-toolchain/downloads/MSPFlasher-1_03_10_00-osx-installer.app.zip"
        ;;
    linux* )
        if [ $(uname -m) == 'x86_64' ]; then
            URL="https://bitbucket.org/rixtox/msp430-toolchain/downloads/MSPFlasher-1_03_10_00-linux-x64-installer.zip"
        else
            URL="https://bitbucket.org/rixtox/msp430-toolchain/downloads/MSPFlasher-1_03_10_00-linux-installer.zip"
        fi
        ;;
    cygwin* | msys* | win32* )
        URL="https://bitbucket.org/rixtox/msp430-toolchain/downloads/MSPFlasher-1_03_10_00-windows-installer.zip"
        ;;
esac
FILE="$DEST.zip"
rm -rf "$DEST" "$FILE" > /dev/null
curl -L -o "$FILE" "$URL"
echo "Extracting MSP Flasher..."
mkdir -p "$DEST"
unzip -qq -d "$DEST" "$FILE"
case $OSTYPE in
    darwin* )
        mv "$DEST/MSPFlasher-"*"-installer.app" "$DEST/MSPFlasher-installer.app"
        chmod +x "$DEST/MSPFlasher-installer.app/Contents/MacOS/osx-intel"
        "./$DEST/MSPFlasher-installer.app/Contents/MacOS/osx-intel" --mode unattended --prefix "$DEST"
        rm -rf "$DEST/MSPFlasher-installer.app"
        ;;
    linux* )
        mv "$DEST/MSPFlasher-"*"-installer.run" "$DEST/MSPFlasher-installer.run"
        chmod +x "$DEST/MSPFlasher-installer.run"
        "./$DEST/MSPFlasher-installer.run" --mode unattended --prefix "$DEST"
        rm -rf "$DEST/MSPFlasher-installer.run"
        ;;
    cygwin* | msys* | win32* )
        mv "$DEST/MSPFlasher-"*"-installer.exe" "$DEST/MSPFlasher-installer.exe"
        chmod +x "$DEST/MSPFlasher-installer.exe"
        "./$DEST/MSPFlasher-installer.exe" --mode unattended --prefix "$DEST"
        rm -rf "$DEST/MSPFlasher-installer.exe"
        ;;
esac
rm -rf "$FILE"
echo

echo "Downloading MSP430 driver library..."
DEST="driverlib"
FILE="$DEST.zip"
rm -rf "$DEST" "$FILE" > /dev/null
curl -L -o "$FILE" "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSP430_Driver_Library/latest/exports/msp430_driverlib_2_80_00_01.zip"
echo "Extracting MSP430 driver library..."
mkdir -p "$DEST"
unzip -qq -d "$DEST" "$FILE"
f=("$DEST"/*)
mv "$DEST"/*/* "$DEST"
rm -rf "$FILE" "${f[@]}"
echo

echo "Downloading MSP430 USB stack library..."
DEST="usblib"
FILE="$DEST.zip"
rm -rf "$DEST" "$FILE" > /dev/null
curl -L -o "$FILE" "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSP430_USB_Developers_Package/latest/exports/MSP430USBDevelopersPackage_5_10_00_17.zip"
echo "Extracting MSP430 USB stack library..."
mkdir -p "$DEST"
unzip -qq -d "$DEST" "$FILE"
f=("$DEST"/*)
mv "$DEST"/*/* "$DEST"
rm -rf "$FILE" "${f[@]}"
mkdir -p "$DEST/include"
cp -R "$DEST/MSP430_USB_Software/MSP430_USB_API/USB_API" "$DEST/include/"
echo

echo "Downloading MSP430 Bluetooth stack library..."
DEST="bluetooth"
FILE="$DEST.tar.gz"
rm -rf "$DEST" "$FILE" > /dev/null
curl -L -o "$FILE" "https://bitbucket.org/rixtox/msp430-toolchain/downloads/CC256XMSPBTBLESW-v1.5-R2.tar.gz"
echo "Extracting MSP430 Bluetooth stack library..."
mkdir -p "$DEST"
tar -C "$DEST" --strip-components 1 -zxf "$FILE"
rm -rf "$FILE"
echo

echo "Downloading MSP430 GCC compiler..."
DEST="msp430-gcc"
case $OSTYPE in
    darwin* )
        FILE="$DEST.zip"
        URL="https://bitbucket.org/rixtox/msp430-toolchain/downloads/msp430-gcc-full-osx-installer-4.1.0.0.app.zip"
        ;;
    linux* )
        FILE="$DEST.run"
        URL="https://bitbucket.org/rixtox/msp430-toolchain/downloads/msp430-gcc-full-linux-installer-4.1.0.0.run"
        ;;
    cygwin* | msys* | win32* )
        FILE="$DEST.exe"
        URL="https://bitbucket.org/rixtox/msp430-toolchain/downloads/msp430-gcc-full-windows-installer-4.1.0.0.exe"
        ;;
esac
rm -rf "$DEST" "$FILE" > /dev/null
curl -L -o "$FILE" "$URL"
echo "Extracting MSP430 GCC compiler..."
mkdir -p "$DEST"
case $OSTYPE in
    darwin* )
        unzip -qq -d "$DEST" "$FILE"
        mv "$DEST/msp430-gcc-"*"-installer"*".app" "$DEST/msp430-gcc-installer.app"
        chmod +x "$DEST/msp430-gcc-installer.app/Contents/MacOS/osx-intel"
        "./$DEST/msp430-gcc-installer.app/Contents/MacOS/osx-intel" --mode unattended --prefix "$DEST"
        chmod +x "$DEST/bin/gdb_agent_console"
        rm -rf "$DEST/msp430-gcc-installer.app"
        ;;
    linux* )
        chmod +x "$FILE"
        "./$FILE" --mode unattended --prefix "$DEST"
        chmod +x "$DEST/bin/gdb_agent_console"
        ;;
    cygwin* | msys* | win32* )
        "./$FILE" --mode unattended --prefix "$DEST"
        ;;
esac
rm "$FILE"
echo

popd
echo "Development environment setup completed."
