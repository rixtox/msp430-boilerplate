#include <driverlib.h>

#include "timer.h"

void Timer_initLED( void ) {
    // Set P1.0 to output direction
    GPIO_setAsOutputPin(
        TIMER_LED_PORT,
        TIMER_LED_PIN
    );
}

void Timer_initComparator( uint8_t cmpValue ) {
    // Start timer in continuous mode sourced by SMCLK
    Timer_A_initContinuousModeParam initContParam = {
        .clockSource = TIMER_A_CLOCKSOURCE_SMCLK,
        .clockSourceDivider = TIMER_A_CLOCKSOURCE_DIVIDER_32,
        .timerInterruptEnable_TAIE = TIMER_A_TAIE_INTERRUPT_DISABLE,
        .timerClear = TIMER_A_DO_CLEAR,
        .startTimer = false
    };
    Timer_A_initContinuousMode( TIMER_A1_BASE, &initContParam );

    // Initiaze compare mode
    Timer_A_clearCaptureCompareInterrupt( TIMER_A1_BASE,
                                          TIMER_A_CAPTURECOMPARE_REGISTER_0
                                        );
    Timer_A_initCompareModeParam initCompParam = {
        .compareRegister = TIMER_A_CAPTURECOMPARE_REGISTER_0,
        .compareInterruptEnable = TIMER_A_CAPTURECOMPARE_INTERRUPT_ENABLE,
        .compareOutputMode = TIMER_A_OUTPUTMODE_OUTBITVALUE,
        .compareValue = cmpValue
    };
    Timer_A_initCompareMode( TIMER_A1_BASE, &initCompParam );
    Timer_A_startCounter( TIMER_A1_BASE,
                          TIMER_A_CONTINUOUS_MODE
                        );
}
