#include <driverlib.h>

#include <descriptors.h>
#include <USB_API/USB_Common/device.h>
#include <USB_API/USB_Common/usb.h>
#include <USB_API/USB_HID_API/UsbHid.h>

#include "keyboard.h"

typedef struct {
    uint8_t modifiers;
    uint8_t reserved;
    uint8_t keys[6];
} KeyReport;

typedef union {
    uint8_t keyArray[8];
    KeyReport keyReport;
} KeyUnion;

uint8_t currentButtonState = 0;
uint8_t previousButtonState = 0;

#define swapButtonStates() \
    currentButtonState ^= previousButtonState; \
    previousButtonState ^= currentButtonState; \
    currentButtonState ^= previousButtonState;

volatile bool KeyboardSendCompleted = true;
KeyUnion keyUnion = { { 0 } };

void Keyboard_initMatrix( void ) {
    GPIO_setAsInputPinWithPullUpResistor(
        KEYBOARD_BUTTON1_PORT,
        KEYBOARD_BUTTON1_PIN );
    GPIO_setAsInputPinWithPullUpResistor(
        KEYBOARD_BUTTON2_PORT,
        KEYBOARD_BUTTON2_PIN );
}

bool Keyboard_matrixChanged( void ) {
    swapButtonStates();
    if ( GPIO_getInputPinValue(
                KEYBOARD_BUTTON1_PORT,
                KEYBOARD_BUTTON1_PIN
            ) == GPIO_INPUT_PIN_LOW ) {
        currentButtonState |= ( 1 << KEYBOARD_BUTTON1_BIT );
        keyUnion.keyReport.keys[0] = 0x04;
    } else {
        currentButtonState &= ~( 1 << KEYBOARD_BUTTON1_BIT );
        keyUnion.keyReport.keys[0] = 0x00;
    }
    if ( GPIO_getInputPinValue(
                KEYBOARD_BUTTON2_PORT,
                KEYBOARD_BUTTON2_PIN
            ) == GPIO_INPUT_PIN_LOW ) {
        currentButtonState |= ( 1 << KEYBOARD_BUTTON2_BIT );
        keyUnion.keyReport.keys[1] = 0x05;
    } else {
        currentButtonState &= ~( 1 << KEYBOARD_BUTTON2_BIT );
        keyUnion.keyReport.keys[1] = 0x00;
    }
    return ( currentButtonState != previousButtonState );
}

void Keyboard_sendChanges( void ) {
    keyboard_sendReport();
}

void keyboard_sendReport()
{
    // while ( !KeyboardSendCompleted );
    // KeyboardSendCompleted = false;
    USBHID_sendReport( keyUnion.keyArray, KEYBOARD_HID_INTFNUM );
}


