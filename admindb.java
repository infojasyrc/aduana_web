/**
 * Created by  on 2/25/14.
 */

import java.sql.*;
import java.net.*;
import java.io.*;

public class admindb {

    private static Socket sc;

    public static void initClient(String host, int port, String parametros) {
        //Socket sc;
        BufferedReader in = null;
        //String str = "001:118:021349:40:2013:103086:0";
        String str = parametros;
        try {
            /*conectar a un servidor en localhost con puerto 5000*/
            sc = new Socket(host , port);

            OutputStream os = sc.getOutputStream();
            OutputStreamWriter osw = new OutputStreamWriter(os);
            BufferedWriter bw = new BufferedWriter(osw);

            bw.write(str);
            bw.flush();
            System.out.println("Message sent to the server : "+str);

            //Get the return message from the server
            InputStream is = sc.getInputStream();
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader br = new BufferedReader(isr);
            String message = br.readLine();
            System.out.println("Message received from the server : " +message);
            /*
            in = new BufferedReader(new InputStreamReader(sc.getInputStream()));
            String line;
            while ((line = in.readLine()) != null) {
                System.out.println(line);
            }
            */
        } catch(Exception e ) {
            System.out.println("Error: "+e.getMessage());
        } finally {
            //Closing the socket
            try{
                sc.close();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static Connection conexion() throws Exception{
        Class.forName("oracle.jdbc.driver.OracleDriver");
        String serverName = "172.16.105.194";
        String portNumber = "1521";
        String sid = "orcl";
        String url = "jdbc:oracle:thin:@" + serverName + ":" + portNumber + ":" + sid;
        String username = "sig";
        String password = "sig2009";
        Connection conn = DriverManager.getConnection(url, username, password);
        return conn;
    }

    public static void main(String[] args) {
        try{
            String host = "172.16.105.35";
            int port=11111;
            Connection conn = conexion();
            String test1;

            test1 = "SELECT EMPRESA, NUME_ORDEN, NUM_DUA, CODI_REGI,CODI_ADUAN,ANO_PRESE";
            test1 = test1.concat(" FROM ORDEN WHERE (SYSDATE - FEC_NUMERACION) < 30");
            test1 = test1.concat(" ORDER BY FEC_NUMERACION");

            //declaring statement
            Statement stmt = conn.createStatement();
            //PreparedStatement query1 = conn.prepareStatement(test1);

            ResultSet rows = stmt.executeQuery(test1);

            int count=0;
            while (rows.next()) {
                count+=1;
                String empresa = rows.getString("EMPRESA").trim();
                String num_orden = rows.getString("NUME_ORDEN").trim();
                String num_dua = rows.getString("NUM_DUA").trim();
                String codi_regi = rows.getString("CODI_REGI").trim();
                String codi_aduana = rows.getString("CODI_ADUAN").trim();
                String ano_prese = rows.getString("ANO_PRESE").trim();

                System.out.println("Row #:"+count);
                System.out.println("Empresa: "+empresa);
                System.out.println("Num Orden: "+num_orden.trim());
                System.out.println("Num DUA: "+num_dua.trim());
                System.out.println("Codigo de Registro: "+codi_regi);
                System.out.println("Codigo de Aduana: "+codi_aduana);
                System.out.println("Año Presentacion: "+ano_prese);

                String parametros = empresa+":"+codi_aduana+":"+num_orden+":"+codi_regi+":"+ano_prese+":"+num_dua+":1";
                initClient(host, port, parametros);

            }

            conn.close();

        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (Exception e){
            System.out.print("Error en conexion");
        }
    }
}
