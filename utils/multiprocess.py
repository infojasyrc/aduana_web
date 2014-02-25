'''
Created on Feb 25, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

from multiprocessing import Process
from aduana import Aduana


class AduanaProcess(object):
    
    def __init__(self, params):
        pass
    
    def execute(self, empresa, cod_aduana, ano_prese, cod_regi, num_orden, num_dua, tipo_doc, option):
        aduana = Aduana()
        aduana.set_parameters(empresa, cod_aduana, ano_prese, cod_regi, num_orden, num_dua, tipo_doc, option)
        aduana.execute()
        if option == "1":
            aduana.clean_data()
        
        result = aduana.get_result()
        
        return result
    
    def main_process(self):
        p = Process(target=self.execute, args=('bob',))
        p.start()
        p.join()


if __name__ == '__main__':
    new_process = AduanaProcess()
    new_process.execute()