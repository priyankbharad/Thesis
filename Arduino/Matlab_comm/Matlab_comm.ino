#include <Wire.h>



/**
 * Copyright (c) 2009 Andrew Rapp. All rights reserved.
 *
 * This file is part of XBee-Arduino.
 *
 * XBee-Arduino is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * XBee-Arduino is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XBee-Arduino.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <XBee.h>
#include <EEPROM.h>

/*
This example is for Series 2 XBee
Receives a ZB RX packet and sets a PWM value based on packet data.
Error led is flashed if an unexpected packet is received
*/
boolean isRouter=false;
uint8_t text[] = {'0'};
uint8_t shCmd[] = {'N','I'};
XBee xbee = XBee();
XBeeResponse response = XBeeResponse();
// create reusable response objects for responses we expect to handle 
ZBRxResponse rx = ZBRxResponse();
AtCommandRequest atRequest = AtCommandRequest(shCmd);
AtCommandResponse atResponse = AtCommandResponse();
XBeeAddress64 remoteAddress = XBeeAddress64(0x00000000, 0x00000000);
//void flashLed(int pin, int times, int wait) {
//    
//    for (int i = 0; i < times; i++) {
//      digitalWrite(pin, HIGH);
//      delay(wait);
//      digitalWrite(pin, LOW);
//      
//      if (i + 1 < times) {
//        delay(wait);
//      }
//    }
//}
void writeEEPROM()
{
    int addr=1;
    EEPROM.write(addr++,rx.getData(1));
    EEPROM.write(addr++,rx.getData(2));
    EEPROM.write(addr++,rx.getData(3));
}
void sendAtCommand() {
  

  // send the command
  xbee.send(atRequest);

  // wait up to 5 seconds for the status response
  if (xbee.readPacket(1000)) {
    // got a response!

    // should be an AT command response
    if (xbee.getResponse().getApiId() == AT_COMMAND_RESPONSE) {
      xbee.getResponse().getAtCommandResponse(atResponse);

      if (atResponse.isOk()) {        
          
        //Serial.println("Response : ");    
        //Serial.println(atResponse.getValue()[0]);
        if(atResponse.getValue()[0]==82)
          isRouter=true;
            //nss.print(atResponse.getValue()[i], HEX);
            //nss.print(" ");
          
        }
      } 
      
    } 
       
  }
void Monitor_event(int x)
{
    
  boolean flag=true;
    ZBTxRequest zbTx;
    while(flag)
    {
      //uint8_t text[];
      if(x==0)
      {
        uint8_t text[64];
        byte pixelTempL=0x80;
        byte pixelTempH=0x81;
        char addr = 0x68;
        float celsius;
        Wire.beginTransmission(addr);
        Wire.write(0x0E);
        Wire.endTransmission();
        Wire.requestFrom(addr, 2);
        byte lowerLevelTherm = Wire.read();
        byte upperLevelTherm = Wire.read();
  

  int temperatureTherm = ((upperLevelTherm << 8) | lowerLevelTherm);
  
  float celsiusTherm = temperatureTherm * 0.0625;
        for(int pixel = 0; pixel < 64; pixel++){
          Wire.beginTransmission(addr);
          Serial.println(pixel);
       Serial.println("Pixel");
          Wire.write(pixelTempL);
          Wire.endTransmission();
          Wire.requestFrom(addr, 1);
          byte lowerLevel = Wire.read();
          Wire.write(pixelTempH);
          Wire.endTransmission();
          Wire.requestFrom(addr, 2);
          byte upperLevel = Wire.read();
          int temperature = ((upperLevel << 8) | lowerLevel);
           if (upperLevel != 0)
           {
             temperature = -(2048 - temperature);
           }
          celsius = temperature * 0.25;
          if(celsius>26)
          {
            text[pixel]=1;
          }
          else
          {
            text[pixel]=0;
          }
          pixelTempL = pixelTempL + 2;
          pixelTempH = pixelTempH + 2;
      }
      zbTx = ZBTxRequest(remoteAddress, text, sizeof(text));
      }
      else{
      uint8_t text[] = {'0'};
      pinMode(5,INPUT);  
      text[0]=digitalRead(x);
      zbTx = ZBTxRequest(remoteAddress, text, sizeof(text));
      }
       
       Serial.println(sizeof(text));
       Serial.println("Sedning Data");
       xbee.send(zbTx);
      // delay(50);            
       xbee.readPacket();
      delay(50);            
      if (xbee.getResponse().isAvailable()) 
      {
        digitalWrite(13,1);
        if (xbee.getResponse().getApiId() == ZB_RX_RESPONSE) 
        {
          flag=false;
          text[0]=1;
          ZBTxRequest zbTx = ZBTxRequest(remoteAddress, text, sizeof(text));
           digitalWrite(13,0);
           xbee.send(zbTx);
         delay(250);
        }
      }     
   }
}

void setup() {
pinMode(13,OUTPUT);
  
  // start serial
  Serial.begin(9600);
  xbee.begin(Serial);
  sendAtCommand();
  //flashLed(statusLed, 3, 50);
}
int pinMonitor=0;
// continuously reads packets, looking for ZB Receive or Modem Status
void loop() {
  boolean Monitor=false;
  boolean Router=false;
  
  digitalWrite(13,0);
    xbee.readPacket();
    delay(250);                                                                                                                                                                                                
    if (xbee.getResponse().isAvailable()) 
    {
            if (xbee.getResponse().getApiId() == ZB_RX_RESPONSE) {
        
        xbee.getResponse().getZBRxResponse(rx);
        delay(100);
        //text[0]=rx.getData(0);
        switch (rx.getData(0)){
        case 1:
          text[0]=1;
          break; 
        case 2:
          text[0]=1;
          Router=true;
          break;
        case 10:
          pinMode(rx.getData(1),INPUT);
          text[0]=digitalRead(rx.getData(1));
          break;
          
        case 20:
          if(rx.getData(2)!=1 && rx.getData(2)!=0)
          {
           text[0]=0;
            break;
          }
         else
          { 
            pinMode(rx.getData(1),OUTPUT);
            digitalWrite(rx.getData(1),rx.getData(2));
            text[0]=1;
            break;
          }
         case 30:
         {
           int addr=1;
           //writeEEPROM();
           text[0]=1;break;
          // EEPROM.write(addr++,rx.getData(1));
           //EEPROM.write(addr++,rx.getData(2));
           //EEPROM.write(addr++,rx.getData(3));break;
         }
         case 40:
         {
           text[0]=1;
           pinMonitor=rx.getData(1);
           Monitor=true;break;  
         }
         case 50:
         {
           
         }
         
        default:
            text[0]=0;
            break;
          //digitalWrite(13,0);break;
        }
        if(Router==false || isRouter==true)
        {
          remoteAddress = XBeeAddress64(0x00000000, 0x00000000);
          ZBTxRequest zbTx = ZBTxRequest(remoteAddress, text, sizeof(text));
          //delay(250);
          xbee.send(zbTx);
           delay(250);
           if(Monitor)
             {
               delay(2000);
               Monitor_event(pinMonitor);
             }
        }
        else
        {
          remoteAddress = XBeeAddress64(0x0013A200, 0x40B79481);
          ZBTxRequest zbTx = ZBTxRequest(remoteAddress, text, sizeof(text));
          digitalWrite(13,1);
          delay(250);
          Router=true;
        }
       }
      }
    else //if (xbee.getResponse().isError()) {
    {    
      //nss.print("Error reading packet.  Error code: ");  
      //nss.println(xbee.getResponse().getErrorCode());
    }
}
