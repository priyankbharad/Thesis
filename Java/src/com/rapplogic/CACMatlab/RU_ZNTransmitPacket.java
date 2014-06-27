package com.rapplogic.CACMatlab;

import java.io.IOException;

import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeAddress64;
import com.rapplogic.xbee.api.XBeeException;
import com.rapplogic.xbee.api.zigbee.ZNetTxRequest;

public class RU_ZNTransmitPacket {
	XBee xbee;
	XBeeAddress64 addr64;
	public RU_ZNTransmitPacket(String s[]) throws NumberFormatException, XBeeException
	{
		xbee = new XBee();
		xbee.open(s[0], Integer.parseInt(s[1]));
		addr64 = new XBeeAddress64(0, 0x13, 0xa2, 0, 0x40, 0xb7, 0x94, 0xf0);
		
		
	}
	public void sendData(String s[]) throws IOException
	{
		int code=0;
		int[] data;
		if(s[0].compareToIgnoreCase("digitalWrite")==0)
		{
			code=10;
			data=new int[3];
			data[0]=code;
			//break;
			
		}
		else
		data=new int[2];
		switch(code)
		{
			case 10:data[1]=Integer.parseInt(s[1]);data[2]=Integer.parseInt(s[2]);break;
		}
		ZNetTxRequest request = new ZNetTxRequest(addr64, data);
		
		xbee.sendRequest(request);
		//xbee.close();
	}
	public void closeConnection()
	{
		xbee.close();
	}
	public static void main(String args[])
	{
		
	}
}
