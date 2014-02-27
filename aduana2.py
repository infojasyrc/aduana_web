'''
Created on Feb 13, 2014

@author: Jose Antonio Sal y Rosas Celi
'''

from captcha2 import Captcha2
from utils.commands import Commands
import os
import random
import re
import unicodedata
import urllib, urllib2
import ConfigParser
from datetime import datetime
from string import replace


class Aduana2(object):

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
        
        self.dict_urls = self.read_config()
    
    def get_cookie(self):
        init_time = datetime.now()
        
        req1 = urllib2.Request(self.dict_urls["captcha"])
        response = urllib2.urlopen(req1)
        cookie = response.headers.get('Set-Cookie')
        cookie_value = cookie.split(";")[0].strip()
        
        image_file = self.filename+".jpg"
        dst = os.path.join(self.captcha_folder, image_file)
        with open(dst, 'w') as f: f.write(response.read())
        f.close()
        
        final_time = datetime.now()
        
        print "Tiempo de Obtencion de Imagen y Cookie: %s" % (final_time-init_time)
        
        return cookie_value, dst
    
    def post_data_form(self, cookie, captcha):
        init_time = datetime.now()
        
        post_data_dict = {"codi_aduan": self.cod_aduana, "ano_prese": self.ano_prese,
                          "codi_regi": self.cod_registro, "nume_corre": self.num_orden,
                          "nume_sufi": "00", "Prov":"1",
                          "tipo_doc": self.tipo_doc, "codigo": captcha,
                          }
        
        post_data_encoded = urllib.urlencode(post_data_dict)
        # Use the cookie is subsequent requests
        req2 = urllib2.Request(self.dict_urls["form"], post_data_encoded)
        req2.add_header('cookie', cookie)
        response = urllib2.urlopen(req2)
        
        final_time = datetime.now()
        
        print "Tiempo de Obtencion de Fomulario Web: %s" % (final_time-init_time)
        
        return response
    
    def get_captcha(self, image_file):
        init_time = datetime.now()
        
        self.obj_captcha = Captcha2()
        self.obj_captcha.set_parameters(self.filename, self.captcha_folder)
        self.obj_captcha.execute(image_file)
        text = self.obj_captcha.get_text_captcha()
        
        final_time = datetime.now()
        
        print "Tiempo de Obtencion de captcha: %s" % (final_time-init_time)

        return text
    
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
    
    def save_data(self, final_html):
        launcher = os.path.join(self.bin_folder,"projectaduana")
        
        command = '%s "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s"' % (launcher, self.empresa,
                                                                       self.cod_aduana, self.ano_prese,
                                                                       self.cod_registro, self.num_dua,
                                                                       self.num_orden, self.tipo_doc,
                                                                       self.option, final_html)
        
        return command
    
    def get_html_file(self):
        launcher = os.path.join(self.bin_folder,"projectaduana")
        
        command = '%s "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s"' % (launcher, self.empresa,
                                                                  self.cod_aduana, self.ano_prese,
                                                                  self.cod_registro, self.num_dua,
                                                                  self.num_orden, self.tipo_doc, self.option)
        return command
    
    def read_html(self, html_file):
        init_time = datetime.now()        
        new_data = ""
        
        if os.path.exists(html_file):
            tmp_file = open(html_file,"r")
            for line in tmp_file:
                if line.strip() == '' or line.strip() == '\n':
                    continue
                else:
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
        else:
            final_name = ""
        
        final_time = datetime.now()
        print "Tiempo de Formateo de HTML: %s" % (final_time-init_time)
        
        return final_name
    
    def read_config(self):
        config_file = os.path.join(self.bin_folder,"config.ini")
        
        config = ConfigParser.ConfigParser()
        config.read(config_file)
        
        dict_urls = {"captcha": str(config.get('basic','url_captcha')),
                     "final": str(config.get('basic','url_final')),
                     "form": str(config.get('basic','url_final')),
                     }
        
        return dict_urls
    
    def execute(self):
        obj_command = Commands()
        
        if self.option == "1":
            while True:
                cookie, final_image = self.get_cookie() 
                
                captcha = self.get_captcha(final_image)
                #print captcha
                    
                if len(captcha) > 2 and len(captcha) <= 4:
                    response = self.post_data_form(cookie, captcha)
                    
                    if response.code == 200:
                        html_file = self.filename+".html"
                        
                        final_html = os.path.join(self.captcha_folder, html_file)
                        with open(final_html, 'w') as f: f.write(response.read())
                        f.close()
                        
                        format_final_html = self.read_html(final_html)
                        
                        final_cmmd = self.save_data(format_final_html)
                        
                        init_time = datetime.now()
                        obj_command.execute_command(final_cmmd)
                        final_time = datetime.now()
                        print "Tiempo de Ejecucion en Oracle: %s" % (final_time-init_time)
                        
                        dict_save = obj_command.get_final_result()
                        
                        if dict_save["message"] == None:
                            self.final_result = ""
                        else:
                            self.final_result = self.final_html
                                                       
                        break
                        
                    else:
                        continue
                    
                else:
                    self.clean_data(final_image)
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
    
    aduana = Aduana2()
    aduana.set_parameters(empresa, cod_aduana, ano_prese, cod_registro, num_orden, num_dua, tipo_doc, option)
    init_time = datetime.now()
    aduana.execute()
    final_time = datetime.now()
    print "Tiempo total: %s" % (final_time-init_time)
    #aduana.clean_data()
    print aduana.get_result()
    