#include <Wire.h>


#include <XBee.h>
#include <EEPROM.h>
const int analogInPin[] = {A0,A1,A2,A3,A4,A5,A6,A7};

boolean isRouter=false;
 char addr = 0x68;
uint8_t text[] = {'0'};
uint8_t shCmd[] = {'N','I'};
XBee xbee = XBee();
XBeeResponse response = XBeeResponse();
// create reusable response objects for responses we expect to handle 
ZBRxResponse rx = ZBRxResponse();
AtCommandRequest atRequest = AtCommandRequest(shCmd);
AtCommandResponse atResponse = AtCommandResponse();
XBeeAddress64 remoteAddress = XBeeAddress64(0x00000000, 0x00000000);


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
float avg_Temp()
{
Wire.beginTransmission(addr);
        Wire.write(0x0E);
        Wire.endTransmission();
        Wire.requestFrom(addr, 2);
        byte lowerLevelTherm = Wire.read();
        byte upperLevelTherm = Wire.read();
  

  int temperatureTherm = ((upperLevelTherm << 8) | lowerLevelTherm);
  
  float celsiusTherm = temperatureTherm * 0.0625;
  return celsiusTherm;
}

void Monitor_event(int x)
{
    
  boolean flag=true;
    ZBTxRequest zbTx;
   uint8_t *out;
   int appID,sizeOut;
   if(x==0)          // To allocate the memory out of the loop
   {
       appID=rx.getData(2);
       sizeOut=0;  
       if(appID==4)
            sizeOut=8;
        else
            sizeOut=64;
          out=new uint8_t[sizeOut];
   }int fiveFramecnt=10;
   boolean sendFlag=false;
   byte pixelTempL=0x80;
   byte pixelTempH=0x81;
   byte lowerLevel,upperLevel;
   float sum=0;
   int cnt=0,temperature;
   float celsius;
        float celsiusTherm;
    while(flag)
    {
      //uint8_t text[];
        
      if(x==0)
      {
        
        celsiusTherm=avg_Temp();
        cnt=0;
         //uint8_t text[64];
        pixelTempL=0x80;
        pixelTempH=0x81;
        for(int pixel = 0; pixel < 64; pixel++){
          
          
          Wire.beginTransmission(addr);
          Serial.println(pixel);
          Serial.println("Pixel");
          Wire.write(pixelTempL);
          Wire.endTransmission();
          Wire.requestFrom(addr, 1);
          lowerLevel = Wire.read();
          Wire.write(pixelTempH);
          Wire.endTransmission();
          Wire.requestFrom(addr, 2);
          upperLevel = Wire.read();
          temperature = ((upperLevel << 8) | lowerLevel);
           if (upperLevel != 0)
           {
             temperature = -(2048 - temperature);
           }
          celsius = temperature * 0.25;
         //--------------------------------------------------------------------------------------
          if(appID==4)
          {
            if(celsius-celsiusTherm>1.4)
            {
              cnt++;
              if(fiveFramecnt>4 && cnt>1)
                fiveFramecnt=0;
              sum+=1;
            }
            //else
              //sum+=0;
            
              
            
             if((pixel+1)%8 == 0){
                 out[pixel/8]=sum;
                 sum=0;
              }
          }
          else
          {
            
            if(cnt>3 || cnt==0)
            fiveFramecnt=0;
           else
           fiveFramecnt=10;
            if(celsius-celsiusTherm>1.4)
            {
              cnt++;
              out[pixel]=1;
            }
            else
            {
              out[pixel]=0;
            }
            }
            pixelTempL = pixelTempL + 2;
            pixelTempH = pixelTempH + 2;
      }
      
      if(fiveFramecnt<=5)
       {
              fiveFramecnt++;
              sendFlag=true;
              zbTx = ZBTxRequest(remoteAddress, out, sizeOut);
       }
       else
              sendFlag=false;
      }
      else if(x<14)
      {
        sendFlag=true;  
        uint8_t text[] = {'0'};
        pinMode(x,INPUT);  
        text[0]=digitalRead(x);
        zbTx = ZBTxRequest(remoteAddress, text, sizeof(text));
      }
      else
      {
        sendFlag=true;  
        uint8_t text[] = {'0'};
        pinMode(analogInPin[x-14],INPUT);  
        int tmp=analogRead(analogInPin[x-14]);
        text[0]=tmp/4;
        zbTx = ZBTxRequest(remoteAddress, text, sizeof(text));
      }
       
      // Serial.println(sizeof(text));
       Serial.println("Sedning Data");
       if(sendFlag)
         xbee.send(zbTx);
       //delay(50);            
       xbee.readPacket();
      delay(25);            
      if (xbee.getResponse().isAvailable()) 
      {
        digitalWrite(13,1);
        if (xbee.getResponse().getApiId() == ZB_RX_RESPONSE) 
        {
          flag=false;
          text[0]=1;
          zbTx = ZBTxRequest(remoteAddress, text, sizeof(text));
           digitalWrite(13,0);
           xbee.send(zbTx);
         delay(50);
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
        uint8_t txt[]={'0'};
        xbee.getResponse().getZBRxResponse(rx);
        delay(100);
        //text[0]=rx.getData(0);
        switch (rx.getData(0)){
        case 1:
          txt[0]=1;
          break; 
        case 2:
          txt[0]=1;
          Router=true;
          break;
        case 10:
          pinMode(rx.getData(1),INPUT);
          txt[0]=digitalRead(rx.getData(1));
          break;
          
        case 20:
          if(rx.getData(2)!=1 && rx.getData(2)!=0)
          {
           txt[0]=0;
            break;
          }
         else
          { 
            pinMode(rx.getData(1),OUTPUT);
            digitalWrite(rx.getData(1),rx.getData(2));
            txt[0]=1;
            break;
          }
         case 30:
         {
           int addr=1;
           //writeEEPROM();
           txt[0]=1;break;
          // EEPROM.write(addr++,rx.getData(1));
           //EEPROM.write(addr++,rx.getData(2));
           //EEPROM.write(addr++,rx.getData(3));break;
         }
         case 40:
         {
           txt[0]=1;
           pinMonitor=rx.getData(1);
           
           Monitor=true;break;  
         }
         case 50:
         {
           
         }
         
        default:
            txt[0]=0;
            break;
          //digitalWrite(13,0);break;
        }
        if(Router==false || isRouter==true)
        {
          remoteAddress = XBeeAddress64(0x00000000, 0x00000000);
          ZBTxRequest zbTx = ZBTxRequest(remoteAddress, txt, sizeof(txt));
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
          ZBTxRequest zbTx = ZBTxRequest(remoteAddress, txt, sizeof(txt));
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
