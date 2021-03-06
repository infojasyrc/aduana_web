'''
Created on Feb 13, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

from captcha import Captcha
from utils.commands import Commands
import os
import random
from datetime import datetime
import ConfigParser
import shutil
import re
from string import replace
import unicodedata


class Aduana(object):

    def __init__(self):
        self.project_folder = os.path.dirname(__file__)
        self.cookies_folder = os.path.join(self.project_folder, "cookies")
        if not os.path.exists(self.cookies_folder):
            os.mkdir(self.cookies_folder)
        
        self.captcha_folder = os.path.join(self.project_folder, "captcha")
        self.bin_folder = os.path.join(self.project_folder, "bin")
        self.final_folder = os.path.join(self.project_folder, "final")
        
        self.filename = ""
        self.url_captcha = ""
        self.ur_final = ""
        self.src_html = ""
        self.final_html = ""
        self.final_result = ""
    
    def set_parameters(self, empresa, cod_aduana, ano_prese, cod_registro, num_orden, num_dua, tipo_doc, option="0"):
        number = random.randint(0,5)
        realtime = datetime.now().strftime("%Y%m%d%H%M%S")
        filename = "%s_%d" % (realtime, number)
        self.filename = filename
        
        self.empresa = empresa
        self.cod_aduana = cod_aduana
        self.ano_prese = ano_prese
        self.cod_registro = cod_registro
        self.num_orden = num_orden
        self.num_dua = num_dua
        self.tipo_doc = tipo_doc
        self.option = option
        
        self.cookie_file = os.path.join(self.cookies_folder, filename+".txt")
        
        self.url_captcha, self.url_form = self.read_config()
    
    def get_captcha(self, image_file):
        self.obj_captcha = Captcha()
        self.obj_captcha.set_parameters(self.filename, self.captcha_folder, self.url_captcha)
        self.obj_captcha.execute(image_file)
        text = self.obj_captcha.get_text_captcha()

        return text
    
    def get_previous_cookie(self):
        # Command:
        # wget --save-cookies '\path\to\cookie_folder\cookies.txt 
        # --keep-session-cookies -r -P \path\to\cookie_folder -nH url
        
        launcher = "wget"
        parameter_cookie = '--save-cookies %s' % self.cookie_file
        parameter_prefix = '-r -P %s'% self.cookies_folder
        parameter_session = '--keep-session-cookies'
        parameter_no_folder = '-nH'
        
        command = "%s %s %s %s %s %s" % (launcher, parameter_cookie, parameter_session,
                                         parameter_prefix, parameter_no_folder, self.url_captcha)
        
        return command
    
    def move_file(self, src, dst):
        try:
            shutil.move(src, dst)
        except IOError:
            print "Error en el archivo de origen: %s" % src
    
    def move_cookie_folder(self):
        tmp_folder = os.path.join(self.cookies_folder, "ol-ad-ao")
        src = os.path.join(tmp_folder,"captcha?accion=image")
        
        dst = os.path.join(self.captcha_folder, self.filename+".jpeg")
        
        self.move_file(src, dst)
        
        return dst
    
    def move_final_destination(self):
        src = os.path.join(self.cookies_folder,"LevanteDuaServlet")
        self.final_html = os.path.join(self.final_folder,self.filename+".html")
        self.move_file(src, self.final_html)
    
    def clean_data(self, image_file=""):
        try:
            os.remove(self.cookie_file)
            txt_file = os.path.join(self.captcha_folder,self.filename+".txt")
            img_file = os.path.join(self.captcha_folder,self.filename+".jpeg")
            
            if os.path.exists(txt_file):
                os.remove(txt_file)
            
            if os.path.exists(img_file):
                os.remove(img_file)
            
            if image_file != "" and os.path.exists(image_file):
                os.remove(image_file)
            
            webpage = os.path.join(self.cookies_folder,"LevanteDuaServlet")
            
            if os.path.exists(webpage):
                os.remove(webpage)
            '''
            if os.path.exists(os.path.join(self.cookies_folder, "ol-ad-ao")):
                os.removedirs(os.path.join(self.cookies_folder, "ol-ad-ao"))
            '''
        except IOError:
            print "Error"
    
    def check_successfull_captcha(self, result_cmmd):
        message_error = "El codigo que muestra la imagen no coincide"
        message_error = message_error.lower()
        
        result_cmmd = result_cmmd.lower()
        
        if result_cmmd.find(message_error) != -1:
            return False
        else:
            return True
    
    def set_command(self, captcha):
        parameter_cod_aduana = 'codi_aduan=%s' % self.cod_aduana
        parameter_ano_prese = 'ano_prese=%s' % self.ano_prese
        parameter_cod_registro = 'codi_regi=%s' % self.cod_registro
        parameter_correlativo = 'nume_corre=%s' % self.num_orden
        parameter_tipo_doc = 'tipo_doc=%s' % self.tipo_doc
        parameter_captcha = 'codigo=%s' % captcha
        
        value_post = '%s&%s&%s&%s&%s&%s' % (parameter_cod_aduana, parameter_ano_prese, parameter_cod_registro,
                                            parameter_correlativo, parameter_tipo_doc, parameter_captcha)
        
        launcher = "wget"
        parameter_cookie = '--load-cookies "%s"' % self.cookie_file
        parameter_prefix = '-P "%s"'% self.cookies_folder
        parameter_session = '--keep-session-cookies'
        parameter_post = '--post-data="%s"' % value_post
        
        command = "%s %s %s %s %s %s" % (launcher, parameter_post, parameter_session, parameter_cookie,
                                         parameter_prefix, self.url_form)
        
        return command
    
    def save_data(self):
        final_name = os.path.join(self.final_folder,"final_"+self.filename+".html")
        
        launcher = os.path.join(self.bin_folder,"projectaduana")
        
        command = '%s "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s"' % (launcher, self.empresa,
                                                                       self.cod_aduana, self.ano_prese,
                                                                       self.cod_registro, self.num_dua,
                                                                       self.num_orden, self.tipo_doc,
                                                                       self.option, final_name)
        
        return command
    
    def get_html_file(self):
        launcher = os.path.join(self.bin_folder,"projectaduana")
        
        command = '%s "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s"' % (launcher, self.empresa,
                                                                  self.cod_aduana, self.ano_prese,
                                                                  self.cod_registro, self.num_dua,
                                                                  self.num_orden, self.tipo_doc, self.option)
        return command
    
    def read_html(self):
        new_data = ""
        if os.path.exists(self.final_html):
            tmp_file = open(self.final_html,"r")
            for line in tmp_file:
                #print line.strip()
                if line.strip() == '' or line.strip() == '\n':
                    continue
                else:
                    #print line.decode('Windows-1252').encode('utf-8')
                    new_data += line.strip().decode('Windows-1252').encode('utf-8')
            tmp_file.close()
        if new_data != "":
            output = re.sub(r'<SCRIPT.*>(.*)</SCRIPT><B', '<B', new_data)
            output = replace(output, "'", '"')
            
            s = ''.join((c for c in unicodedata.normalize('NFD',unicode(output)) if unicodedata.category(c) != 'Mn'))
            new_output = s.decode()
            
            if new_output.find("/ol-ad-ao/captcha?accion=image") != -1:
                new_output = new_output.replace("/ol-ad-ao/captcha?accion=image", "http://www.aduanet.gob.pe/ol-ad-ao/captcha?accion=image")
            
            if new_output.find("/aduanas/images/") != -1:
                new_output = new_output.replace("/aduanas/images/", "http://www.aduanet.gob.pe/aduanas/images/")
            
            final_name = os.path.join(self.final_folder,"final_"+self.filename+".html")
            final_html_file = open(final_name,"w")
            final_html_file.write(new_output)
            final_html_file.close() 
    
    def read_config(self):
        config_file = os.path.join(self.bin_folder,"config.ini")
        
        config = ConfigParser.ConfigParser()
        config.read(config_file)
        
        url_captcha = str(config.get('basic','url_captcha'))
        url_final = str(config.get('basic','url_final'))
        
        return url_captcha, url_final
    
    def execute(self):
        obj_command = Commands()
        
        if self.option == "1":
            while True:
                command_previous_cookie = self.get_previous_cookie()
                #print command_previous_cookie
                obj_command.execute_command(command_previous_cookie)
                dict_result_previous_cookie = obj_command.get_final_result()
                
                if dict_result_previous_cookie["result"]:
                    image_file = self.move_cookie_folder()
                    captcha = self.get_captcha(image_file)
                    print captcha
                    
                    if len(captcha) > 2 and len(captcha) <= 4:
                        command = self.set_command(captcha)
                    
                        obj_command.execute_command(command)
                        dict_final_result = obj_command.get_final_result()
                        
                        if dict_final_result["result"]:
                            if self.check_successfull_captcha(dict_final_result["message"]):
                                self.move_final_destination()
                                self.read_html()
                                final_cmmd = self.save_data()
                                obj_command.execute_command(final_cmmd)
                                dict_save = obj_command.get_final_result()
                                
                                if dict_save["message"] == None:
                                    self.final_result = ""
                                else:
                                    self.final_result = self.final_html
                                                                
                                break
                            else:
                                print dict_final_result["message"]
                                self.clean_data(image_file)
                                continue
                        else:
                            print dict_final_result["message"]
                            self.clean_data(image_file)
                            continue
                    else:
                        self.clean_data(image_file)
                        continue
                            
                else:
                    continue
        # Fin del proceso si la option es 1
        else:
            command = self.get_html_file()
            obj_command.execute_command(command)
            dict_result = obj_command.get_final_result()
            if dict_result["message"] == None:
                self.final_result = ""
            else:
                self.final_result = dict_result["message"]
    
    def get_result(self):
        return self.final_result


if __name__ == '__main__':
    empresa = "001"
    cod_aduana = "118"
    ano_prese = "2014"
    cod_registro = "10"
    num_orden = "001287"
    num_dua = "030541"
    tipo_doc = "01"
    option = "1"
    
    aduana = Aduana()
    aduana.set_parameters(empresa, cod_aduana, ano_prese, cod_registro, num_orden, num_dua, tipo_doc, option)
    
    init_time = datetime.now()
    aduana.execute()
    final_time = datetime.now()
    print "Tiempo total: %s" % (final_time-init_time)
    
    aduana.clean_data()
    print aduana.get_result()
    