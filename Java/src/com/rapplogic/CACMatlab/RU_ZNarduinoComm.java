package com.rapplogic.CACMatlab;

import java.io.IOException;
import java.util.ArrayList;

import com.rapplogic.xbee.api.ApiId;
import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeAddress64;
import com.rapplogic.xbee.api.XBeeException;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.XBeeTimeoutException;
import com.rapplogic.xbee.api.zigbee.ZNetRxResponse;
import com.rapplogic.xbee.api.zigbee.ZNetTxRequest;
import com.rapplogic.xbee.util.ByteUtils;


public class RU_ZNarduinoComm {
	XBee xbee;
	XBeeAddress64 addr64;
	XBeeResponse response;
	ZNetRxResponse rx;
	public RU_ZNarduinoComm(String s[]) throws NumberFormatException, XBeeException
	{
		xbee = new XBee();
		xbee.open(s[0], Integer.parseInt(s[1]));
		
		
	}
	private void accumulateResponse(ArrayList<String[]> res,int cnt)
	{
		
		//ArrayList<String[]> res=new ArrayList<String[]>();
		if(response.getApiId() != ApiId.ZNET_RX_RESPONSE)return ;
		rx = (ZNetRxResponse) response;
		int[] a=rx.getData();
		String temp[]=new String[2];
		temp[0]="";temp[1]="";
		int[] x=(rx.getRemoteAddress64().getAddress());
		
		for(int j=0;j<x.length;j++)
		{
			temp[1]=temp[1]+(ByteUtils.toBase16(x[j]).substring(2,4)+" ");
		}				
		//System.out.println(temp[1]);
		for(int i=0;i<a.length;i++)
		{
			temp[0]=temp[0]+a[i]+" ";
		//cch=(char)a[i];
		//out=out+ch;
		}
		//System.out.println("Pushing inarrayList_"+temp[0]+"__"+temp[1]+"\n-------"+cnt);
		res.add(temp);
		
		//output.add(cnt, temp);
		//out[cnt][0]=temp[0];
		//out[cnt][1]=temp[1];
		
		System.out.println();
		//return res;
		
	}
	private String[][] getReply() 
	{
		//System.out.println("Command Sent..Waiting for response");
		
		ArrayList<String[]> res=new ArrayList<String[]>();
		int cnt=0;
		String[][] out=null;//=new String[2][2];
		
		try {
			while((response=xbee.getResponse(1000))!=null)
				
			{
				accumulateResponse(res,cnt);
			//	System.out.println("Insode loop");
				
			}
			
		} catch (XBeeTimeoutException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			//System.exit(0);
			out=new String[res.size()][2];
			for(int j=0;j<res.size();j++)
			{
				out[j]=res.get(j);
				//System.out.println(res.get(j)[0]+" - "+res.get(j)[1]);
			}
			
		} catch (XBeeException e) {
			// TODO Auto-generated catch block
			//System.exit(0);
			//e.printStackTrace();
		}
		//System.out.println(output.size());
		//out=new String[output.size()][2];
		/*
		for(int j=0;j<2;j++)
		{
			//out[j]=output.get(j);
			System.out.println(out[j][0]+" - "+out[j][1]);
		}*/
		
		return out;	
	}
	public String[][] getReply(String s[]) 
	{
		//System.out.println("Command Sent.... Waiting for response");
		
		//ArrayList<XBeeResponse> res=new ArrayList<XBeeResponse>();
		ArrayList<String[]> res=new ArrayList<String[]>();
		int cnt=0;
		String[][] out=null;//=new String[2][2];
		xbee.clearResponseQueue();
		
		
		try {
			while(cnt<Integer.parseInt(s[0]))
			{
				if((response=xbee.getResponse())!=null)
				{
					accumulateResponse(res,cnt);
					cnt++;
				//	System.out.println("Loop running");
			}}
			out=new String[res.size()][2];
			for(int j=0;j<res.size();j++)
			{
				out[j]=res.get(j);
				//System.out.println(res.get(j)[0]+" - "+res.get(j)[1]);
			}
			
		} catch (XBeeTimeoutException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			//System.exit(0);
			
			
		} catch (XBeeException e) {
			// TODO Auto-generated catch block
			//System.exit(0);
			//e.printStackTrace();
		}
		//
		
		
		return out;	
	}
	public String[][] sendData(String s[]) throws IOException, XBeeException, InterruptedException
	{
		
		int[] data={}; 
		String[][] finalOut;
		if(s.length>1)
			System.out.println(s[1]);
		if(s[0].compareToIgnoreCase("digitalRead")==0)
		{
			
			data=new int[2];
			data[0]=10;
		}
		else if(s[0].compareToIgnoreCase("digitalWrite")==0)
		{
			
			data=new int[3];
			data[0]=20;
		}
		else if(s[0].compareToIgnoreCase("NodeDiscover")==0)
		{
			data=new int[1];
			data[0]=1;
		}
		else if(s[0].compareToIgnoreCase("AssignIdentifier")==0)
		{
			
			data=new int[4];
			data[0]=30;
			
			addr64=new XBeeAddress64(s[1]);
			data[1]=Integer.parseInt(s[2]);
			data[3]=Integer.parseInt(s[4]);
			data[2]=Integer.parseInt(s[3]);
			ZNetTxRequest request = new ZNetTxRequest(addr64, data);
			
			xbee.sendRequest(request);
			finalOut=getReply();
			return finalOut;
			
		}
		
		else if(s[0].compareToIgnoreCase("Monitor")==0)
		{
			data=new int[2];
			data[0]=40;
		}
		else if(s[0].compareToIgnoreCase("RouterComm")==0)
		{
			data=new int[1];
			data[0]=2;
		}
	
		else
		{
			finalOut=new String[1][2];
			finalOut[0][0]="Error";finalOut[0][1]="Invalid Commands";
			return finalOut;
		}
		if(data.length!=s.length)
		{
			finalOut=new String[1][2];
			finalOut[0][0]="Error";finalOut[0][1]="Invalid Arguments";
			return finalOut;
		}
		for (int i=1;i<data.length;i++)
		{
			data[i]=Integer.parseInt(s[i]);
		}
		/*
		switch(data[0])
		{
			case 10:data[1]=Integer.parseInt(s[1]);break;//
			case 20:data[2]=Integer.parseInt(s[2]);data[1]=Integer.parseInt(s[1]);break;
			case 30:data[2]=Integer.parseInt(s[2]);data[1]=Integer.parseInt(s[1]);data[3]=Integer.parseInt[s[3]];break;
		}*/
		addr64 = new XBeeAddress64(0, 0, 0, 0, 0, 0, 0xff, 0xff);
		ZNetTxRequest request = new ZNetTxRequest(addr64, data);
		
		xbee.sendRequest(request);
		finalOut=getReply();
		return finalOut;
		
		
		
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
