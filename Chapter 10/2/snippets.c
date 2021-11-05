/**
 * C Program to set the PIO in motion blinking the LEDs
 */

#include <stdio.h>

#include "pico/stdlib.h"
#include "hardware/pio.h"
#include "hardware/clocks.h"
#include "snippets.pio.h"

const uint LED_PIN1 = 18;
const uint LED_PIN2 = 19;
const uint LED_PIN3 = 20;

#define SLEEP_TIME 200

void blink_pin_forever(PIO pio, uint sm, uint offset, uint pin, uint freq);

int main() {
    int i = 0;
    
    setup_default_uart();

    // todo get free sm
    PIO pio = pio0;
    uint offset = pio_add_program(pio, &snippets_program);
    printf("Loaded program at %d\n", offset);

    while(1)
    {
        i++;
        printf("Busy counting away i = %d\n", i);
    }
}

