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
            
            empresa = mylist[0].strip()
            cod_aduana = mylist[1].strip()
            num_orden = mylist[2].strip()
            cod_regi = mylist[3].strip()
            ano_prese = mylist[4].strip()
            num_dua = mylist[5].strip()
            option = mylist[6].strip()
            
            result = self.set_information(empresa, cod_aduana, num_orden, num_dua, cod_regi, ano_prese, option)
            
            c.send(result)
            c.close()
    
    def set_information(self, empresa, cod_aduana, num_orden, num_dua, cod_regi, ano_prese, option):
        aduana = Aduana()
        aduana.set_parameters(empresa, cod_aduana, ano_prese, cod_regi, num_orden, num_dua, self.tipo_doc, option)
        aduana.execute()
        if option == "1":
            aduana.clean_data()
        
        result = aduana.get_result()
        
        return result
    
    def getCaptcha(self):
        obj_captcha = Captcha()
        obj_captcha.execute()
        text = obj_captcha.getTextCaptcha()

        return text

if __name__ == '__main__':
    gossip = Gossip()
    gossip.trigger()
        