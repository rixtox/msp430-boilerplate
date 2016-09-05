#include <driverlib.h>
#include <USB_API/USB_Common/usb.h>

#include "timer.h"
#include "keyboard.h"

#define COMPARE_VALUE 50000

void main( void )
{
    // Stop WDT
    WDT_A_hold( WDT_A_BASE );

    Timer_initLED();
    Timer_initComparator( COMPARE_VALUE );

    Keyboard_initMatrix();

    // Enable USB interrupts and connect to host if available
    USB_setup( true, true );

    // Enter LPM3
    __bis_SR_register( LPM3_bits + GIE );
    __no_operation();

    while ( true ) {
        if ( Keyboard_matrixChanged() ) {
            Keyboard_sendChanges();
        }
    }
}
