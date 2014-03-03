package com.isco.semaforo.util;


import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.net.UnknownHostException;

public class Http {
    private final String USER_AGENT = "Mozilla/5.0";
    private final String SET_COOKIE = "Set-Cookie";
    private final String EXPIRES    = "expires";

    private String codi_aduan;
    private String ano_prese;
    private String codi_regi;
    private String num_dua;
    private String tipo_doc;
    private String captcha;
    private String rutaTemp;
    private String cocos;
    private String urlCaptcha       ="http://www.aduanet.gob.pe/ol-ad-ao/captcha?accion=image";
    private String urlConsulta      ="http://www.aduanet.gob.pe/ol-ad-ao/LevanteDuaServlet";
    private String urlResultado     ="http://www.aduanet.gob.pe/ol-ad-ao/aduanas/informao/jsp/LevanteDua.jsp";
    private String resultado = "";
    public Http() {
        this.tipo_doc = "01";
        this.rutaTemp = "c:\\imagen2.jpg";
        this.captcha  = "";
        this.cocos    = "";
    }

    public Http(String codi_aduan, String ano_prese, String codi_regi, String num_dua) {
        this.codi_aduan = codi_aduan;
        this.ano_prese = ano_prese;
        this.codi_regi = codi_regi;
        this.num_dua = num_dua;
        this.tipo_doc = "01";
        this.rutaTemp = "c:\\imagen2.jpg";
        this.captcha  = "";
        this.cocos    = "";
    }
    
    public void setCodi_aduan(String codi_aduan) {
        this.codi_aduan = codi_aduan;
    }

    public void setAno_prese(String ano_prese) {
        this.ano_prese = ano_prese;
    }

    public void setCodi_regi(String codi_regi) {
        this.codi_regi = codi_regi;
    }

    public void setNum_dua(String num_dua) {
        this.num_dua = num_dua;
    }

    public void setTipo_doc(String tipo_doc) {
        this.tipo_doc = tipo_doc;
    }

    public void setRutaTemp(String rutaTemp) {
        this.rutaTemp = rutaTemp;
    }
            
    public String procesar() {
        this.leerCaptcha();
        resultado = this.sendPost();
        return resultado;
    }
    
    private void leerCaptcha(){
        
        try {

            URL url = new URL(urlCaptcha);
            //System.out.println("URL : "+url);
            URLConnection conexion = url.openConnection();
            conexion.setRequestProperty("Content-Type","xml/text");
            conexion.setDoOutput(true);
            conexion.setDoInput(true);

            int i = 0;
            int j=0;

            OutputStream outputStream = new FileOutputStream(new File(rutaTemp));
            int read = 0;
            byte[] bytes = new byte[1024];
            InputStream imagen_url = conexion.getInputStream();
            while ((read = imagen_url.read(bytes)) != -1) {
                outputStream.write(bytes, 0, read);
            }
            outputStream.close();
//            Process p;
//            String ejecutable_ocr="x:\\sistemas\\tesseract\\tesseract.bat c:\\imagen2.jpg c:\\capcha -psm 8 letters";
//            try {
//                p = Runtime.getRuntime().exec(ejecutable_ocr);
//                p.waitFor();
//    //            BufferedReader reader =
//     //                   new BufferedReader(new InputStreamReader(p.getInputStream()));
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
            OCR ocr = new OCR();
            captcha=ocr.obtenerPalabra(rutaTemp);
            System.out.println(captcha);
            j=conexion.getHeaderFields().size();
            String resCookies="";
            for (i=0;i<j;i++) {
                if(conexion.getHeaderFieldKey(i)==null) continue;
                if(conexion.getHeaderFieldKey(i).equals("Set-Cookie")) {
                    resCookies+= conexion.getHeaderField(i);
                    break;
                }
            } 
            
            String aux[]=resCookies.split(";");
            cocos=aux[0];

            }catch(UnknownHostException e){
                System.out.println("Error la pagina no respondio:"+e.getMessage());
            }catch(MalformedURLException e){
                System.out.println("Error URL no reconocido:"+e.getMessage());
            }catch(IOException e){
                System.out.println("Error IO de la pagina:"+e.getMessage());    
            }
    }
    
    private String sendPost(){
       try {
           URL url = new URL(urlConsulta);
           HttpURLConnection connection = (HttpURLConnection) url.openConnection();           
           connection.setDoOutput(true); 
           connection.setInstanceFollowRedirects(true); 
           connection.setRequestMethod("POST"); 
           connection.setConnectTimeout(10000);
           connection.setReadTimeout(10000);

           connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.117 Safari/537.36");
           connection.setRequestProperty("Connection", "keep-alive"); 
           connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded"); 
           connection.setRequestProperty("charset", "utf-8");
           connection.setRequestProperty("Cookie", cocos);
           DataOutputStream wr = new DataOutputStream(connection.getOutputStream ());

           String parametros="codi_aduan="+codi_aduan+"&ano_prese="+ano_prese+"&codi_regi="+codi_regi+"&nume_corre="+num_dua+"&tipo_doc="+tipo_doc+"&digi_veri=&nume_sufi=00&Prov=1&codigo="+captcha;
           
           wr.writeBytes(parametros);
           wr.flush();
           wr.close();
           connection.connect();
                   
           BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
           String line;
           int i = 0;
           while ((line = in.readLine()) != null && i<=200) {
               resultado = resultado + line;
           }
             
           connection.disconnect();

        }catch(UnknownHostException e){
            System.out.println("Error la pagina no respondio:"+e.getMessage());
            //e.printStackTrace();
        }catch(MalformedURLException e){
            System.out.println("Error URL no reconocido:"+e.getMessage());
            //e.printStackTrace();
        }catch(IOException e){
            System.out.println("Error IO de la pagina:"+e.getMessage());
            //e.printStackTrace();
        }

        try {
               URL url = new URL(urlResultado);
               HttpURLConnection connection = (HttpURLConnection) url.openConnection();           
               connection.setDoOutput(true); 
 
               connection.setConnectTimeout(10000);
               connection.setReadTimeout(10000);

               connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.117 Safari/537.36"); 
               connection.setRequestProperty("Connection", "keep-alive"); 
               connection.setRequestProperty("Content-Type", "text/html"); 
               connection.setRequestProperty("Cookie", cocos);
               
               BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
               String line;
               int i = 0;
               while ((line = in.readLine()) != null && i<=200) {
                    resultado = resultado + line;
               }

               connection.disconnect();

        }catch(UnknownHostException e){
               System.out.println("Error la pagina no respondio:"+e.getMessage());
               //e.printStackTrace();
        }catch(MalformedURLException e){
               System.out.println("Error URL no reconocido:"+e.getMessage());
               //e.printStackTrace();
        }catch(IOException e){
               System.out.println("Error IO de la pagina:"+e.getMessage());
               //e.printStackTrace();
        }    
        return resultado;
     } 
        
    private String read_txt_file(String archivo) throws FileNotFoundException, IOException {
        String txt_file = archivo;
        String everything = "";

        BufferedReader br = new BufferedReader(new FileReader(txt_file));
        try {
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();

            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            everything = sb.toString();
        } finally {
            br.close();
        }

        return everything.trim();
    }
    
}
