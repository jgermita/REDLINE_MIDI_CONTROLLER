//#include <HardWire.h>
//#include <WireBase.h>

#include "Midi.h"

#define FADE_RATE 20

Midi midi(Serial3);

//HardWire port(1);


void setup()
{

   // port.begin(0x0D);
  //delay(1000);

  // Configure digital pins for input.
  pinMode(BOARD_LED_PIN, OUTPUT);
  pinMode(6, INPUT_PULLUP);
  pinMode(7, INPUT_PULLUP);
  pinMode(8, INPUT_PULLUP);
  pinMode(9, INPUT_PULLUP);
  pinMode(2, OUTPUT);

  pinMode(10, INPUT_ANALOG);
  pinMode(11, INPUT_ANALOG);

  pinMode(3, PWM);
  pinMode(4, PWM);
  pinMode(5, PWM);
  pinMode(27, PWM);
  pinMode(26, OUTPUT);
  pwmWrite(3, 0);
  pwmWrite(4, 0);
  pwmWrite(5, 0);
  pwmWrite(27, 65535);
  pinMode(33, OUTPUT);
  pinMode(32, INPUT);

  int usb_timeout = 0;

  while(!SerialUSB.isConnected()) {
    pwmWrite(3, 0);
    pwmWrite(4, 0);
    pwmWrite(5, 0);
    pwmWrite(27, 65535);
    for(int i = 0; i < 100; i++) {
      tone(26, 440);
    }
    pwmWrite(27, 0);
    pwmWrite(3, 65535);
    pwmWrite(4, 65535);
    pwmWrite(5, 65535);
    delay(250);

    usb_timeout++;
  } 
  

  digitalWrite(2, HIGH);
  delay(250);
  digitalWrite(2, LOW);


  for(int i = 3; i < 6; i++)  {
    for(int j = 0; j <= 65535; j += 1024) {
      pwmWrite(i, j);
      delay(3);
    }
    for(int j = 65535; j >= 0; j -= 1024) {
      pwmWrite(i, j);
      delay(3);
    }
  }
  for(int j = 0; j <= 65535; j += 1024) {
    pwmWrite(27, j);
    delay(3);
  }
  for(int j = 65535; j >= 0; j -= 1024) {
    pwmWrite(27, j);
    delay(3);
  }

  initLED(27);
  midi.begin(0);
}
// MIDI channel to send messages to
int channelOut = 1;

boolean button[] = {
  false, false, false, false};
boolean prevButton[] = {
  false, false, false, false};
boolean prevPlatterButtons[] = {
  false, false, false};
  
boolean red = false, green = false, blue = false;
int stick[] = {
  0, 0};
int prevStick[] = {
  0, 0};

int ledctr[] = {
  65535/16, 65535/16, 65535/16};
byte a[10];
//uint8 b[6];
boolean progMode = false;
int speed = 0, prevSpeed = 0;;

float pos = 0, prevPos = 0;

boolean z = false;
boolean c = false;
void loop()
{
  boolean comms = false;  
 /*
  port.beginTransmission(0x0D);
  port.send(0);
  port.endTransmission();
  port.requestFrom(0x0D, 23);
  comms = port.available() != 0;
  for (int i=0; i <= 22; i++){
    a[i]=port.receive();
  }
  prevSpeed = speed;
  speed = (int)a[20] - (int)a[21];
  speed *= 2;
  
  prevPlatterButtons[0] = green;
  prevPlatterButtons[1] = red;
  prevPlatterButtons[2] = blue;
  
  green = a[19] == 1 || a[19] == 3 || a[19] == 5 || a[19] == 7;
  red = a[19] == 2 || a[19] == 3 || a[19] == 6 || a[19] == 7;
  blue = a[19] == 4 || a[19] == 5 || a[19] == 6 || a[19] == 7;
  */
/*  port.begin(0x52);
  port.beginTransmission(0x52);
  port.send(0x00);
  port.endTransmission();
  port.requestFrom(0x52, 6);
  comms = port.available();
  for(int i = 0; i <= 6; i++) {
    char in = port.receive();
    b[i] = (in ^ 0x17) + 0x17;
  }
  
  z = (b[5] >> 0) & 1;
  c = (b[5] >> 1) & 1;
  
  
  */
  if(digitalRead(32)) {
    progMode = true;
  } else if((!digitalRead(6) || !digitalRead(7) || !digitalRead(8) || !digitalRead(9))) {
    progMode = false;
  }
  if(progMode) { //Programming mode - disables maple midi out and input
    digitalWrite(33, HIGH);
    digitalWrite(26, LOW);
    pwmWrite(3, 0);
    pwmWrite(4, 0);
    pwmWrite(5, 0);
    pwmWrite(27, 0);
  } else if(SerialUSB.isConnected()) {  //USB is connected. process inputs and MIDI outputs
    if((a[19] == 1) || !comms) {
      digitalWrite(33, HIGH);
    } else {
      digitalWrite(33, LOW);
    }
    doWork();
  } else {                            //Error mode. blink and beep till error condition is resolved
    for(int i = 0; i < 100; i++) {
      tone(26, 440);
    }
    delay(250);
  }

}

int runctr = 0;
int sonar = 0, prevSonar = 0;
void doWork() {
  
  runctr++;

  for(int i = 0; i < 4; i++) {
    prevButton[i] = button[i];
    button[i] = !digitalRead(6+i);
    if(button[i] != prevButton[i] && button[i]) {
      midi.sendControlChange(channelOut, 80+i, 127);
    } 
    else if(button[i] != prevButton[i] && !button[i] && i != 0){
      midi.sendControlChange(channelOut, 80+i, 0);
    }
  }
  for(int i = 0; i < 2; i++) {
    prevStick[i] = stick[i];
    stick[i] = analogRead(i+10);
    if(runctr % 50 == 0) { //abs(stick[i] - prevStick[i]) > 7 && 
      int send = map(stick[i], 0, 4096, 0, 127);

      if(i == 0)  {
       // midi.sendControlChange(channelOut, 16+i, send);
      }
    }
  }
  
//  midi.sendControlChange(channelOut, 17, );

  prevSonar = sonar;
  sonar = (int)sonarFilter(analogRead(10));
  SerialUSB.println(sonar);
  //if(sonar !=prevSonar) {
     midi.sendControlChange(channelOut, 17, sonar);
  //}
  
  /*
   if((speed != prevSpeed)) {
    if(green) midi.sendControlChange(channelOut, 34, 64+speed);
    else if(red) midi.sendControlChange(channelOut, 35, 64+speed);
    else if(blue) midi.sendControlChange(channelOut, 36, 64+speed);
  }  
  
   
  if(green != prevPlatterButtons[0]) {
    midi.sendControlChange(channelOut, 30, green ? 127 : 0);
  }
  
  if(red != prevPlatterButtons[1]) {
    midi.sendControlChange(channelOut, 31, red ? 127 : 0);
  }
  
  if(blue != prevPlatterButtons[2]) {
    midi.sendControlChange(channelOut, 32, blue ? 127 : 0);
  }
  */
  
  

  if(!digitalRead(6)) {
    ledctr[0] = 65535;
  } 
  else {
    if(ledctr[0] > 65535/16) {
      ledctr[0]-=FADE_RATE;
    }

  }
  pwmWrite(5, ledctr[0]);

  if(!digitalRead(7)) {
    ledctr[1] = 65535;
  } 
  else {
    if(ledctr[1] > 65535/16) {
      ledctr[1]-=FADE_RATE;
    }
  }
  pwmWrite(4, ledctr[1]);

  if(!digitalRead(9)) {
    ledctr[2] = 65535;
  } 
  else {
    if(ledctr[2] > 65535/16) {
      ledctr[2]-=FADE_RATE;
    }
  }
  pwmWrite(3, ledctr[2]);

  digitalWrite(2, digitalRead(8));

//  doLEDControl(1);
}

void tone(int pin, int freq) {
  digitalWrite(26,HIGH);
  delayMicroseconds((1000000/freq)/2);
  digitalWrite(26, LOW);
  delayMicroseconds((1000000/freq)/2);
}

float accumulator = 0, alpha = 1;
int sonarFilter(int input) {
  input = map(input, 50, 150, 0, 128);
  if(input >=127) input = 127;
  if(input < 0) input = 0;
  input = 127-input;
  accumulator = (alpha * input) + (1.0 - alpha) * accumulator;
  return accumulator;
}
