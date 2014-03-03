/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.isco.semaforo.test;

import com.isco.semaforo.util.Http;

/**
 *
 * @author hbocanegra
 */
public class Test {
    public static void main(String[] args) {
        Http http = new Http("118","2014", "10", "1015");
        System.out.println(http.procesar());
        
    }
    
}
