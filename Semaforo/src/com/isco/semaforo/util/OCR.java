/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.isco.semaforo.util;

import java.awt.image.BufferedImage;
import java.awt.image.RescaleOp;
import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import javax.imageio.ImageIO;

import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;

/**
 *
 * @author hbocanegra
 */
public class OCR {
    
    public OCR(){
    }
    
    // Con el path de un archivo
    public String obtenerPalabra(String archivo){
        String resultado;
        BufferedImage bi;
        File imageFile = new File(archivo);
       
        Tesseract instance = Tesseract.getInstance();  // JNA Interface Mapping
        // Tesseract1 instance = new Tesseract1(); // JNA Direct Mapping
        try {
            ImageIO.scanForPlugins();
            
            bi = oscurecerImagen(imageFile);
            
            resultado = instance.doOCR(bi);
            resultado = ajustarResultado(resultado);
        } catch (TesseractException e) {
            resultado = "Error:"+e.getMessage();
        }
        return resultado;
    }
    
    // Con el BufferedImage
    public String obtenerPalabra(BufferedImage bi){
        String resultado;
       
        Tesseract instance = Tesseract.getInstance();  // JNA Interface Mapping
        // Tesseract1 instance = new Tesseract1(); // JNA Direct Mapping
        try {
            ImageIO.scanForPlugins();
            
            resultado = instance.doOCR(bi);
            resultado = ajustarResultado(resultado);
        } catch (TesseractException e) {
            resultado = "Error:"+e.getMessage();
        }
        return resultado;
    }
    
    // Desde una URL
    public String obtenerPalabraDeUrl(String url){
        String resultado;
        URL imageURL;
        try {
            imageURL = new URL(url);
        } catch (MalformedURLException ex) {
            resultado = ex.getMessage();
            return resultado;
        }

        BufferedImage img;
        try {
            img = ImageIO.read(imageURL);
        } catch (IOException ex) {
            resultado = ex.getMessage();
            return resultado;
        }
        img = oscurecerImagen(img);
        resultado = obtenerPalabra(img);
        
        return resultado;
    }
    
    // Ajuste del OCR del captcha
    private String ajustarResultado(String resultado) {
        String resFinal = resultado;
        resFinal = resFinal.toUpperCase();
        resFinal = resFinal.replace(" ", "");
        return resFinal;
    }
    
    // Desde un archivo
    private BufferedImage oscurecerImagen(File archivo){
        
        BufferedImage bi=null;
        try {
            bi = ImageIO.read(archivo);
        } catch (IOException ex) {
            System.out.println(ex.getMessage());
        }
        
        RescaleOp rescaleOp = new RescaleOp(0.90f, 15, null);
        rescaleOp.filter(bi, bi);
        
        return bi;
    }
    
    //Desde un BufferedImage
    private BufferedImage oscurecerImagen(BufferedImage bi){
        
        RescaleOp rescaleOp = new RescaleOp(0.90f, 15, null);
        rescaleOp.filter(bi, bi);
        
        return bi;
    }

}
