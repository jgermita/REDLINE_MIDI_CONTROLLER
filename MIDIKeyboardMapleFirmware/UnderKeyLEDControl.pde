int led_pin;
int counter = 0;

const int IDLE_MODE = 0;
const int FAST_MODE = 1;

void initLED(int pin) {
  led_pin = pin;
}

void doLEDControl(int mode) {
  counter++;
  switch(mode) {
    case (IDLE_MODE):
    pwmWrite(led_pin, 65535-ledSmooth(counter));
    break;
    case (FAST_MODE):
    pwmWrite(led_pin, 65535-ledSmooth(counter*3));
    break;
    default:
    pwmWrite(led_pin, 65535-ledSmooth(counter));
  }
}

int ledSmooth(int x) {
  return (-65000*abs(sin(x*0.00005)))+65536; //sine wave
}


