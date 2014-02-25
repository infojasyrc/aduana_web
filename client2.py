'''
Created on Feb 25, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

import socket
 
if __name__ == "__main__":
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(("localhost", 11111))
    data = "001:118:021349:40:2013:103086:0"
    sock.sendall(data)
    result = sock.recv(1024)
    print result
    sock.close()