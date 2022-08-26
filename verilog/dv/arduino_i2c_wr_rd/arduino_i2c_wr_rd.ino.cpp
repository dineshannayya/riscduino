// --------------------------------------
// I2C Write and Reading to Memory
//  https://microchipdeveloper.com/i2c:sequential-read
// --------------------------------------
#include <Arduino.h>

#include <Wire.h>

void setup();
void loop();
void setup() {
  Wire.begin();

  Serial.begin(1152000);
  while (!Serial); // Leonardo: wait for Serial Monitor
  Serial.println("\nI2C Write Read");
}

void loop() {

  //----------------------------- 
  // Write & Read to Device #4
  //------------------------------
  // step 1: instruct sensor to read echoes
  Wire.beginTransmission(0x4); // transmit to device #4 (0x0x4)
  Wire.write(byte(0x02));      // sets memory  pointer (0x02)  
  Wire.write(byte(0x11));      // Write Location-0: 0x11
  Wire.write(byte(0x22));      // Write Location-0: 0x22
  Wire.write(byte(0x33));      // Write Location-0: 0x33
  Wire.write(byte(0x44));      // Write Location-0: 0x44
  Wire.write(byte(0x55));      // Write Location-0: 0x55
  Wire.write(byte(0x66));      // Write Location-0: 0x66
  Wire.write(byte(0x77));      // Write Location-0: 0x77
  Wire.write(byte(0x88));      // Write Location-0: 0x88
  Wire.endTransmission();      // stop transmitting

  // step 2: Reset the the memory pointer
  Wire.beginTransmission(0x4); // transmit to device #4 (0x4)
  Wire.write(byte(0x02));      // sets memory pointer (0x02)
  Wire.endTransmission();      // stop transmitting

  // step 3: request reading from sensor
  Wire.requestFrom(0x4, 8);    // request 8 bytes from slave device #4
  Wire.available();
  
  // step 4: receive reading from sensor

  Serial.println("Read Back Data from Port-0x04:"); 
  while(Wire.available())    // slave may send less than requested
  { 
    uint8_t c = Wire.read(); // receive a byte as character
    Serial.println(c,HEX);  // print the character
  }
  Wire.endTransmission();      // stop transmitting

  //----------------------------- 
  // Write & Read to Device #4
  //------------------------------
  // step 1: instruct sensor to read echoes
  Wire.beginTransmission(0x10); // transmit to device #10 (0x10)
  Wire.write(byte(0x20));      // sets memory  pointer (0x20)  
  Wire.write(byte(0x01));      // Write Location-0: 0x11
  Wire.write(byte(0x02));      // Write Location-0: 0x22
  Wire.write(byte(0x03));      // Write Location-0: 0x33
  Wire.write(byte(0x04));      // Write Location-0: 0x44
  Wire.write(byte(0x05));      // Write Location-0: 0x55
  Wire.write(byte(0x06));      // Write Location-0: 0x66
  Wire.write(byte(0x07));      // Write Location-0: 0x77
  Wire.write(byte(0x08));      // Write Location-0: 0x88
  Wire.endTransmission();      // stop transmitting


  // step 2: Reset the the memory pointer
  Wire.beginTransmission(0x10); // transmit to device #10 (0x10)
  Wire.write(byte(0x20));      // sets memory pointer (0x10)
  Wire.endTransmission();      // stop transmitting

  // step 3: request reading from sensor
  Wire.requestFrom(0x10, 8);    // request 8 bytes from slave device #4
  Wire.available();
  
  // step 4: receive reading from sensor

  Serial.println("\nRead Back Data from Port-0x10:"); 
  while(Wire.available())    // slave may send less than requested
  { 
    uint8_t c = Wire.read(); // receive a byte as character
    Serial.println(c,HEX);  // print the character
  }
  Wire.endTransmission();      // stop transmitting

  delay(5000); // Wait 5 seconds for next scan
}

