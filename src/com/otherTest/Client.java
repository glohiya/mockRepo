package com.otherTest;
import java.io.*;
import java.net.*;

public class Client {
   
   private String host = "localhost";
   private int port = 9876;
   private InetAddress serverIP = null;
   private DatagramSocket clientSocket = null;

   public Client() {
       try {
           serverIP = InetAddress.getByName( host );
       }
       catch( UnknownHostException e ) {
           System.out.println("Unknown host");
           System.exit(-1);
       }
  
       try {
           clientSocket = new DatagramSocket();
       }
       catch( SocketException e ) {
          System.out.println("Socket could not be opened");
          System.exit(-2);
      }
   }

   public void go() {

       try {
           byte[] sendData = new byte[1024];
           byte[] receiveData = new byte[1024];

           BufferedReader inFromUser = new BufferedReader(new InputStreamReader(System.in));
           String sentence = inFromUser.readLine();
           sendData = sentence.getBytes();

           DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, serverIP, port);
           clientSocket.send(sendPacket);

           DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
           clientSocket.receive(receivePacket);

           String modifiedSentence = new String(receivePacket.getData());
           System.out.println("FROM SERVER:" + modifiedSentence);

           clientSocket.close();
       }
       catch( IOException e ) {
           System.out.println("Socket could not be opened");
           System.exit(-3);
       }
   }

   public static void main( String[] args ) {
       Client client = new Client();
       client.go();
   }
}
