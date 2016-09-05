#include <stdbool.h>
#include <descriptors.h>

#define KEYBOARD_HID_INTFNUM HID0_INTFNUM

#define KEYBOARD_BUTTON1_PORT GPIO_PORT_P2
#define KEYBOARD_BUTTON1_PIN GPIO_PIN1
#define KEYBOARD_BUTTON2_PORT GPIO_PORT_P1
#define KEYBOARD_BUTTON2_PIN GPIO_PIN1
#define KEYBOARD_BUTTON1_BIT 0
#define KEYBOARD_BUTTON2_BIT 1

extern volatile bool KeyboardSendCompleted;

void Keyboard_initMatrix( void );
bool Keyboard_matrixChanged( void );
void Keyboard_sendChanges( void );
