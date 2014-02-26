'''
Created on Feb 25, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

import multiprocessing
import socket
from aduana import Aduana

def handle(connection, address):
    import logging
    logging.basicConfig(level=logging.DEBUG)
    logger = logging.getLogger("process-%r" % (address,))
    try:
        logger.debug("Connected %r at %r", connection, address)
        while True:
            data = connection.recv(1024)
            if data == "":
                logger.debug("Socket closed remotely")
                break
            
            mylist=list(data.split(':'))
            
            empresa = mylist[0].strip()
            cod_aduana = mylist[1].strip()
            num_orden = mylist[2].strip()
            cod_regi = mylist[3].strip()
            ano_prese = mylist[4].strip()
            num_dua = mylist[5].strip()
            tipo_doc = mylist[6].strip()
            option = mylist[7].strip()
            
            result = set_information(empresa, cod_aduana, num_orden, num_dua, cod_regi, ano_prese, tipo_doc, option)
            
            #logger.debug("Received data %r", data)
            logger.debug("Received data %r", data)
            #connection.sendall(data)
            connection.sendall(result)
            
            logger.debug("Sent data")
            #logger.debug("Closing socket")
            #connection.close()
    except:
        logger.exception("Problem handling request")
    
    finally:
        logger.debug("Closing socket")
        connection.close()

def set_information(empresa, cod_aduana, num_orden, num_dua, cod_regi, ano_prese, tipo_doc, option):
    
    aduana = Aduana()
    aduana.set_parameters(empresa, cod_aduana, ano_prese, cod_regi, num_orden, num_dua, tipo_doc, option)
    aduana.execute()
    if option == "1":
        aduana.clean_data()
    
    result = aduana.get_result()
    result += "\n"
    
    return result


class Server(object):
    
    def __init__(self, hostname, port):
        import logging
        self.logger = logging.getLogger("server")
        self.hostname = hostname
        self.port = port
 
    def start(self):
        self.logger.debug("listening")
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.bind((self.hostname, self.port))
        self.socket.listen(1)
 
        while True:
            conn, address = self.socket.accept()
            self.logger.debug("Got connection")
            process = multiprocessing.Process(target=handle, args=(conn, address))
            process.daemon = True
            process.start()
            self.logger.debug("Started process %r", process)


if __name__ == '__main__':
    import logging
    logging.basicConfig(level=logging.DEBUG)
    #server = Server("0.0.0.0", 9000)
    server = Server("0.0.0.0", 11111)
    
    try:
        logging.info("Listening")
        server.start()
    except:
        logging.exception("Unexpected exception")
    finally:
        logging.info("Shutting down")
        for process in multiprocessing.active_children():
            logging.info("Shutting down process %r", process)
            process.terminate()
            process.join()
    logging.info("All done")