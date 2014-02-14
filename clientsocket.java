/**
 * Created by Jose Antonio Sal y Rosas Celi on 2/13/14.
 */

import java.net.*;
import java.io.*;

public class clientsocket {

    public static void initClient(String host, int port) {
        Socket sc;
        BufferedReader in = null;

        try {
            /*conectar a un servidor en localhost con puerto 5000*/
            sc = new Socket(host , port);

            in = new BufferedReader(new InputStreamReader(sc.getInputStream()));
            String line;
            while ((line = in.readLine()) != null) {
                System.out.println(line);
            }

            } catch(Exception e ) {
            System.out.println("Error: "+e.getMessage());
        }
    }

    public static void main(String[] args){
        String host = "172.16.105.35";
        int port=11111;

        initClient(host, port);
    }
}
