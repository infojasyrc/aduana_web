import com.sun.xml.internal.ws.policy.privateutil.PolicyUtils;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Random;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.text.*;

//import javax.net.ssl.HttpsURLConnection;

public class HttpURLConnectionExample {

    private final String USER_AGENT = "Mozilla/5.0";
    private final String SET_COOKIE = "Set-Cookie";
    private final String EXPIRES = "expires";

    public static String image_file = "";
    public static String prefix_file = "";

    public static void main(String[] args) throws Exception {
        //String cookie_session;
        List<String> cookies;
        String final_cmmd;

        String command = "wine /home/dev/Documents/tesseract/tesseract.exe";
        String default_parameter = "-psm 8 letters";

        HttpURLConnectionExample http = new HttpURLConnectionExample();

        System.out.println("Testing 1 - Send Http GET request");
        cookies = http.sendGet();

        final_cmmd = command + " " + image_file + " " + prefix_file + " " + default_parameter;

        String output = http.executeCommand(final_cmmd);
        String txt_captcha = http.read_txt_file();

        System.out.println(output);

        System.out.println("\nTesting 2 - Send Http POST request");
        //http.sendPost(cookie_session);
        http.sendPost(cookies, txt_captcha);

    }

    public String fill2(int value)
    {
        String erg = String.valueOf(value);

        if (erg.length() < 2)
            erg = "0" + erg;
        return erg;
    }

    public String get_duration(Date date1, Date date2)
    {
        TimeUnit timeUnit = TimeUnit.SECONDS;

        long diffInMillies = date2.getTime() - date1.getTime();
        long s = timeUnit.convert(diffInMillies, TimeUnit.MILLISECONDS);

        long days = s / (24 * 60 * 60);
        long rest = s - (days * 24 * 60 * 60);
        long std =  rest / (60 * 60);
        long rest1 = rest - (std * 60 * 60);
        long min = rest1 / 60;
        long sec = s % 60;

        String dates = "";
        if (days > 0)
            dates += days + " Days ";

        dates += fill2((int) std) + "h ";
        dates += fill2((int) min) + "m ";
        dates += fill2((int) sec) + "s ";

        return dates;
    }

    // HTTP GET request
    //private String sendGet() throws Exception {
    private List<String> sendGet() throws Exception {
        Date tiempo_inicial, tiempo_final;
        tiempo_inicial = new Date();

        String filename, path_to_file;
        Random rand = new Random();

        // nextInt is normally exclusive of the top value,
        // so add 1 to make it inclusive
        int randomNum = rand.nextInt((5 - 0) + 1) + 0;
        DateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmssSSS");
        Date date = new Date();
        filename = dateFormat.format(date)+"_"+String.valueOf(randomNum);
        path_to_file = "/home/dev/IdeaProjects/aduana-captcha/imgs/";
        prefix_file = path_to_file + filename;
        image_file = prefix_file + ".jpg";

        //String url = "http://www.google.com/search?q=mkyong";
        String url = "http://www.aduanet.gob.pe/ol-ad-ao/captcha?accion=image";

        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();

        // optional default is GET
        con.setRequestMethod("GET");

        //add request header
        con.setRequestProperty("User-Agent", USER_AGENT);

        int responseCode = con.getResponseCode();

        System.out.println("\nSending 'GET' request to URL : " + url);
        System.out.println("Response Code : " + responseCode);

        //String cookie_tag = con.getHeaderField(SET_COOKIE);
        //String cookie_value = cookie_tag.split(";")[0];
        List<String> cookies = con.getHeaderFields().get(SET_COOKIE);

        System.out.println(con.getHeaderField(EXPIRES));

        int read = 0;
        byte[] bytes = new byte[1024];

        OutputStream outputStream = new FileOutputStream(new File(image_file));

        InputStream imagen_url = con.getInputStream();
        while ((read = imagen_url.read(bytes)) != -1) {
            outputStream.write(bytes, 0, read);
        }
        /*
        BufferedReader in = new BufferedReader(
                new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer response = new StringBuffer();

        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();
        */

        //System.out.println(response.toString());
        //return cookie_value.split("=")[1].trim();
        //return cookie_tag;

        tiempo_final = new Date();

        System.out.println("Tiempo de ejecucion de Cookie y Captcha: " + get_duration(tiempo_inicial,tiempo_final));

        return cookies;
    }

    // HTTP POST request
    //private void sendPost(String cookie_session) throws Exception {
    private void sendPost(List<String> cookie_session, String txt_captcha) throws Exception {
        /*
        codi_aduan:118-MARITIMA DEL CALLAO
        ano_prese:2014
        codi_regi:10-IMPORTACION DEFINITIVA
        nume_corre:032076
        tipo_doc:01
        digi_veri:
        nume_sufi:00
        Prov:1
        codigo:ZDZI
         */

        Date tiempo_inicial, tiempo_final;
        tiempo_inicial = new Date();

        //String url = "https://selfsolve.apple.com/wcResults.do";
        //String url = "http://www.aduanet.gob.pe/ol-ad-ao/LevanteDuaServlet";
        String url = "http://www.aduanet.gob.pe/aduanas/informao/HR10Poliza.htm";
        String urlParameters = "";
        URL obj = new URL(url);
        //HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();

        //add request header
        con.setRequestMethod("POST");
        con.setRequestProperty("User-Agent", USER_AGENT);
        //con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
        con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=windows-1252");

        //con.setRequestProperty("Cookie", cookie_session);
        for (String cookie : cookie_session) {
            con.setRequestProperty("Cookie", cookie.split(";", 2)[0]);
        }

        urlParameters = "codi_aduan=118&ano_prese=2014&codi_regi=10&nume_corre=032076&tipo_doc=01";
        urlParameters += "&codigo="+txt_captcha;
        urlParameters += "&nume_sufi=00&Prov=1";

        // Send post request
        con.setDoOutput(true);
        DataOutputStream wr = new DataOutputStream(con.getOutputStream());
        wr.writeBytes(urlParameters);
        wr.flush();
        wr.close();

        int responseCode = con.getResponseCode();

        if (responseCode == 200) {
            System.out.println("\nSending 'POST' request to URL : " + url);
            System.out.println("Post parameters : " + urlParameters);
            System.out.println("Response Code : " + responseCode);

            BufferedReader in = new BufferedReader(
                    new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer response = new StringBuffer();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();

            //print result
            System.out.println(response.toString());

        }else{
            if(responseCode == 500){
                String filename;
                Random rand = new Random();

                // nextInt is normally exclusive of the top value,
                // so add 1 to make it inclusive
                int randomNum = rand.nextInt((5 - 0) + 1) + 0;
                DateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmssSSS");
                Date date = new Date();
                filename = dateFormat.format(date)+"_"+String.valueOf(randomNum)+".html";

                int read = 0;
                byte[] bytes = new byte[1024];

                //OutputStream outputStream = new FileOutputStream(new File("/home/dev/IdeaProjects/aduana-captcha/imagen.jpg"));
                OutputStream outputStream = new FileOutputStream(new File("/home/dev/IdeaProjects/aduana-captcha/htmls/"+filename));

                InputStream html_url = con.getInputStream();
                while ((read = html_url.read(bytes)) != -1) {
                    outputStream.write(bytes, 0, read);
                }
            }
            System.out.println("Error obteniendo archivo");
        }

        tiempo_final = new Date();

        System.out.println("Tiempo de ejecucion de Post: " + get_duration(tiempo_inicial,tiempo_final));

    }

    private String executeCommand(String command) {

        StringBuffer output = new StringBuffer();
        Date tiempo_inicial, tiempo_final;
        tiempo_inicial = new Date();

        Process p;
        try {
            p = Runtime.getRuntime().exec(command);
            p.waitFor();
            BufferedReader reader =
                    new BufferedReader(new InputStreamReader(p.getInputStream()));

            String line = "";
            while ((line = reader.readLine())!= null) {
                output.append(line + "\n");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        tiempo_final = new Date();

        System.out.println("Tiempo de Ejecucion del comando: "+ get_duration(tiempo_inicial,tiempo_final));

        return output.toString();

    }

    private String read_txt_file() throws FileNotFoundException, IOException {
        String txt_file = prefix_file+".txt";
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