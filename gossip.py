'''
Created on Feb 13, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

import socket
from captcha import Captcha
from aduana import Aduana


class Gossip(object):
    
    def __init__(self):
        self.tipo_doc = "01"
    
    def trigger(self):
        s = socket.socket()        
        port = 11111  
                     
        s.bind(('', port))        
         
        s.listen(5)
                       
        while True:
            c, addr = s.accept()
            data=c.recv(1024)    
            print ('Address:',addr,'Data:',data)
           
            mylist=list(data.split(':'))
            '''
            intlist=list()
            for i in range(0,len(mylist)):
                intlist.append(int(mylist[i]))
            
            intlist.sort()
            '''
            cod_aduana = mylist[0].strip()
            num_orden = mylist[1].strip()
            cod_regi = mylist[2].strip()
            ano_prese = mylist[3].strip()
            num_dua = mylist[4].strip()
            
            self.set_information(cod_aduana, num_orden, num_dua, cod_regi, ano_prese)
            
            c.send("")
            c.close()
    
    def set_information(self, cod_aduana, num_orden, num_dua, cod_regi, ano_prese):
        aduana = Aduana()
        aduana.set_parameters(cod_aduana, ano_prese, cod_regi, num_orden, num_dua, self.tipo_doc)
        aduana.execute()
        aduana.clean_data()
    
    def getCaptcha(self):
        obj_captcha = Captcha()
        obj_captcha.execute()
        text = obj_captcha.getTextCaptcha()

        return text

if __name__ == '__main__':
    gossip = Gossip()
    gossip.trigger()
        