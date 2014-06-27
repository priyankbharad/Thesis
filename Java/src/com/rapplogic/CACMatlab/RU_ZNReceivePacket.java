package com.rapplogic.CACMatlab;

import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.zigbee.ZNetRxResponse;


public class RU_ZNReceivePacket {
	String comPort;
	XBeeResponse response;
	ZNetRxResponse rx;
	
	public RU_ZNReceivePacket(String s[]) throws Exception
	{
		//System.out.println(s);
		comPort=s[0];
		XBee xbee = new XBee();		
		xbee.open(comPort,Integer.parseInt(s[1]));
		boolean flag=true;
		response = xbee.getResponse();
		rx = (ZNetRxResponse) response;
		xbee.close();
	}
	public String getPacketData()
	{
		String out="";
		int[] a=rx.getData();
		for(int i=0;i<a.length;i++)
		{
			char ch=(char)a[i];
			out=out+ch;
		}
		return out;
	}
	public static void main(String args[])
	{
		
	}
}
