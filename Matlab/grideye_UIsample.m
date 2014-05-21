o=com.rapplogic.CACMatlab.RU_ZNarduinoComm({'COM4' '9600'})
o.sendData({'Monitor','0'})
while(1)
s=o.getReply({'1'})

 b=num2cell(char(s(1,1)))
                     b=reshape(b,8,[])
                     d=cell2num(b)
                     d=d-48
                     out=bwconncomp(d)
                     imshow(d,'InitialMagnification','fit')
                     drawnow
                     end
                     o.sendData({'NodeDiscover'})

 o.closeConnection()