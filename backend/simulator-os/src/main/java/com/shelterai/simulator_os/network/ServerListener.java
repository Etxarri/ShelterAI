package com.shelterai.simulator_os.network;

import com.shelterai.simulator_os.core.ShelterManager;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ServerListener {
    private final int port;
    private final ShelterManager shelterManager;

    public ServerListener(int port) {
        this.port = port;
        // El Manager ahora inicializa sus propios refugios internamente
        this.shelterManager = new ShelterManager(); 
    }

    public void start() {
        // No necesitamos arrancar el manager como hilo, porque el manager arranca hilos internos
        // por cada refugio que crea.
        
        new Thread(() -> {
            try (ServerSocket serverSocket = new ServerSocket(port)) {
                System.out.println("[NET] Multi-Shelter Server listening in port " + port);
                while (true) {
                    Socket clientSocket = serverSocket.accept();
                    new Thread(new ClientHandler(clientSocket, shelterManager)).start();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }).start();
    }
}


