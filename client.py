'''
Created on Feb 13, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

import sys
import socket


class Client(object):
    
    def __init__(self):
        pass
    
    def execute(self, ip="", in_data="123456"):
        
        arglen=len(sys.argv)
        if arglen<3:
            print('please run as python TCPclient.py <ip_address> <numbers>')
            exit()
        
        data=str()
        #data=data+str(sys.argv[2])
        data=data+str(in_data)
        '''
        for i in range(3,arglen):
            data=data+':'+str(sys.argv[i])
            print data
        '''
        s = socket.socket()        
        port = 11111          
 
        #s.connect((sys.argv[1], port))
        s.connect((ip, port))
        s.send(data)
        result = s.recv(1024)
        s.close
        
        print result

if __name__ == '__main__':
    ip = "172.16.105.35"
    #data = "123456789"
    #data = "118:052242:10:2014"
    data = "001:118:001712:10:2014:032706:0"
    
    client = Client()
    client.execute(ip,data)
     
        