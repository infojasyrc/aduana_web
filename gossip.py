'''
Created on Feb 13, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

import socket
from captcha import Captcha


class Gossip(object):
    
    def __init__(self):
        pass
    
    def trigger(self):
        s = socket.socket()        
        port = 11111  
                     
        s.bind(('', port))        
         
        s.listen(5)
                       
        while True:
            c, addr = s.accept()
            #data=c.recv(1024)    
            #print ('Address:',addr,'Data:',data)
           
            '''
            mylist=list(data.split(':'))
            intlist=list()
            for i in range(0,len(mylist)):
                intlist.append(int(mylist[i]))
            
            intlist.sort()
            '''
            c.send(self.getCaptcha())
            c.close()
    
    def getCaptcha(self):
        obj_captcha = Captcha()
        obj_captcha.execute()
        text = obj_captcha.getTextCaptcha()

        return text

if __name__ == '__main__':
    gossip = Gossip()
    gossip.trigger()
        