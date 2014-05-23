javaaddpath c:\users\priyank\documents\github\thesis\Matlab\RUarduinoComm.jar;
o=com.rapplogic.CACMatlab.RU_ZNarduinoComm({'COM4' '9600'})
o.sendData({'Monitor','0'})
while(1)
s=o.getReply({'1'})

 b=str2num(char(s(1,1)));
 b=reshape(b,8,[]);
 d=transpose(b)
 
                   %  out=bwconncomp(d)
                     imshow(mat2gray(d,[60 150]),'InitialMagnification','fit')
                     drawnow
                     end
                     o.sendData({'NodeDiscover'})

 o.closeConnection()