package com.otherTest;

import java.io.*;
import java.net.*;

public class Server
{
   private int port = -1;
   private  DatagramSocket serverSocket = null;

   public Server( int portIn ) {
      port = portIn;
      try {
          serverSocket = new DatagramSocket(9876);
      }
      catch( SocketException e ) {
          System.out.println("Socket could not be opened" + e);
          System.exit(-1);
      }
   }

   public void go() {

      byte[] receiveData = new byte[1024];
      byte[] sendData = new byte[1024];

      while( true ) {

          try {
              DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
              serverSocket.receive(receivePacket);

              String sentence = new String( receivePacket.getData());
              System.out.println("RECEIVED: " + sentence);
              String capitalizedSentence = sentence.toUpperCase();
              sendData = capitalizedSentence.getBytes();

              InetAddress destIP = receivePacket.getAddress();
              int destPort = receivePacket.getPort();

              DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, destIP, destPort);
              serverSocket.send(sendPacket);
          }
          catch( IOException e) {
              System.out.println("Socket i/o problem");
              System.exit(-2);
          }
      }
   }

   public static void main( String[] args ) {
       Server server = new Server( 9876 );
       server.go();
   }

}
