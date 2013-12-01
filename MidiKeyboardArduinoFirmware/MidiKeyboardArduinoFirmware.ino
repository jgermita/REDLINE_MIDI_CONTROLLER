#define ENABLE_NUNCHUCK  //Comment these definitions out as necessary
#define ENABLE_TURNTABLE //They act to disable the components if they are not used

#ifdef ENABLE_TURNTABLE
#include <Wire.h>
#endif

#ifdef ENABLE_NUNCHUCK
#include <WiiChuck.h>
#endif

#include <MIDI.h>


#define LED 13   		// LED pin on Arduino board

WiiChuck nc = WiiChuck();


void setup() {
  pinMode(LED, OUTPUT);
  MIDI.begin(4);
  
  #ifdef ENABLE_NUNCHUCK
  nc.begin();
  nc.update();
  #endif

}

/*
  loop method
*/
void loop() {
  processStick();    //Process stick method
  
  //#ifdef ENABLE_NUNCHUCK    //compiler stuff to not compile if this component is enabled
  processNunchuk();
  //#endif
  
  #ifdef ENABLE_TURNTABLE
  processTurntable();
  #endif
}

int prevX = 0, x = 0;
int prevY = 0, y = 0;

/*
  Analog stick processing method
  
*/
void processStick() { 
  prevX = x;
  prevY = y;

  x = map(analogRead(0), 0, 1024, 0, 127);
  y = map(analogRead(1), 0, 1024, 0, 127);
  
  if(prevX != x) {
    MIDI.sendControlChange(1, x, 3);
    sndBlink();
  }
  
  if(prevY != y) {
    MIDI.sendControlChange(2, y, 3);
    sndBlink();
  }
}

#ifdef ENABLE_NUNCHUCK
void processNunchuk() {
  nc.update();
  int nc_x = nc.readJoyX();
  int nc_y = nc.readJoyY();
  int nc_acc_x = nc.readAccelX();
  int nc_acc_y = nc.readAccelY();
  int nc_acc_z = nc.readAccelZ();
  boolean nc_c = nc.cPressed();
  boolean nc_z = nc.zPressed();
  
  MIDI.sendControlChange(1, nc_x, 4);
  MIDI.sendControlChange(2, nc_y, 4);
  MIDI.sendControlChange(3, nc_acc_x, 4);
  MIDI.sendControlChange(4, nc_acc_y, 4);
  MIDI.sendControlChange(5, nc_acc_z, 4);
  MIDI.sendNoteOn(1, (nc_c) ? 127 : 0, 4);
  MIDI.sendNoteOn(2, (nc_z) ? 127 : 0, 4);
  sndBlink();
}
#endif

#ifdef ENABLE_TURNTABLE
void processTurntable() {
  int tt_dir;
  int tt_disp;
  boolean tt_red;
  boolean tt_green;
  boolean tt_blue;
  Wire.beginTransmission((byte)14);
  Wire.write((byte)0);
  Wire.requestFrom((byte)14, (byte)23);
  
  while(Wire.available()) {
    if(Wire.available() == 20) {
      byte raw = Wire.read();
      //binary to boolean logic on buttons here
      tt_red = ((raw >> 1) - 2);
      tt_green = (raw >> 2);
      tt_blue = (raw % 2);
    } else if(Wire.available() == 21) {
      tt_disp = Wire.read();
    } else if(Wire.available() == 22) {
      tt_dir = Wire.read();
    }
  }
  
  Wire.endTransmission();
  
  MIDI.sendControlChange(1, (.5*tt_disp*tt_dir) + 64, 5);
  MIDI.sendNoteOn(1, (tt_red) ? 127 : 0, 5);
  MIDI.sendNoteOn(2, (tt_green) ? 127 : 0, 5);
  MIDI.sendNoteOn(3, (tt_blue) ? 127 : 0, 5);
  sndBlink();
}
#endif

void sndBlink() {
  digitalWrite(LED, HIGH);
  digitalWrite(LED, LOW);
}
