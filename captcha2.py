'''
Created on Feb 13, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

import urllib
import os
import ConfigParser
from utils.commands import Commands


class Captcha2(object):
    
    def __init__(self):
        self.txt_captcha = ""
        self.output_path = ""
    
    def set_parameters(self, filename, path, url=""):
        self.filename = filename
        self.output_path = path
        self.url = url
    
    def get_image(self):
        img_file = "%s.jpeg" % self.filename
        final_img_file = os.path.join(self.output_path, img_file)
        urllib.urlretrieve(self.url, final_img_file)
        
        return final_img_file     

    def read_config(self):
        project_folder = os.path.dirname(__file__)
        bin_folder = os.path.join(project_folder,"bin")
        config_file = os.path.join(bin_folder,"config.ini")
        
        config = ConfigParser.ConfigParser()
        config.read(config_file)
        
        exe_app = str(config.get('captcha','exe_app'))
        
        return exe_app
    
    def execute_command(self, file_source, file_destination, exe_app): 
        launcher = "wine %s" % exe_app
        default_parameter = "-psm 8 letters"
        
        command = '%s "%s" "%s" %s' % (launcher, file_source, file_destination, default_parameter)
        
        obj_command = Commands()
        obj_command.execute_command(command)
        dict_result = obj_command.get_final_result()
                 
        return dict_result
    
    def read_decode_captcha(self, text_file):
        decode = open(text_file,"r")
        content = decode.readline().strip()
        decode.close()
        
        return content
    
    def execute(self, image=""):
        exe_app = self.read_config()
        
        if image == "":
            file_source = self.get_image()
        else:
            file_source = image

        final_destination = os.path.join(self.output_path, self.filename)
        
        dict_result = self.execute_command(file_source, final_destination, exe_app) 
        
        if dict_result["result"]:
            final_destination = "%s.txt" % final_destination
            content = self.read_decode_captcha(final_destination)
        else:
            content = ""
        
        self.set_text_captcha(content)    
    
    def get_text_captcha(self):
        return self.txt_captcha
    
    def set_text_captcha(self, text=""):
        self.txt_captcha = text
    
    def print_text_captcha(self):
        print self.txt_captcha


if __name__ == '__main__':
    import random
    from datetime import datetime
    
    number = random.randint(0,5)
    realtime = datetime.now().strftime("%Y%m%d%H%M%S")
    filename = "%s_%d" % (realtime, number)
    project_folder = os.path.join(os.path.dirname(__file__), "captcha")
    url = "http://www.aduanet.gob.pe/ol-ad-ao/captcha?accion=image"
    
    aduana = Captcha2()
    aduana.set_parameters(filename, project_folder, url)
    aduana.execute()
    aduana.print_text_captcha()
    