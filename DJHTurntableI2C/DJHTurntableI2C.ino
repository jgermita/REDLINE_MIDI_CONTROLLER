// Wire Master Reader
// by Nicholas Zambetti <http://www.zambetti.com>

// Demonstrates use of the Wire library
// Reads data from an I2C/TWI slave device
// Refer to the "Wire Slave Sender" example for use with this

// Created 29 March 2006

// This example code is in the public domain.


#include <Wire.h>

void setup()
{
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(9600);  // start serial for output
}

void loop()
{
  Wire.beginTransmission(13);
  Wire.write(0);
  Wire.endTransmission();
  int i = 0;

  Wire.requestFrom(13, 23);    // request 6 bytes from slave device #2
  char c = Wire.read(); // receive a byte as character
  int out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
  c = Wire.read(); // receive a byte as character
  out = (int)c;
  Serial.println(out);         // print the character
}




