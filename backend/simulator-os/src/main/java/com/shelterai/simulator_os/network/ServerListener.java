package com.shelterai.simulator_os.network;

import com.shelterai.simulator_os.core.ShelterManager;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ServerListener {

    private final int port;
    private final ShelterManager shelterManager;
    
    private volatile boolean running = false;
    private Thread listenerThread;
    
    // IMPORTANTE: Variable de clase, no local
    private ServerSocket serverSocket; 

    public ServerListener(int port) {
        this.port = port;
        this.shelterManager = new ShelterManager();
    }

    public void start() {
        if (running) return;

        running = true;
        listenerThread = new Thread(() -> {
            try {
                // ✅ CORRECCIÓN: Asignamos a this.serverSocket
                this.serverSocket = new ServerSocket(port);
                System.out.println("[NET] Server listening in port " + port);

                while (running && !serverSocket.isClosed()) {
                    try {
                        Socket clientSocket = serverSocket.accept();
                        new Thread(new ClientHandler(clientSocket, shelterManager)).start();
                    } catch (IOException e) {
                        if (running) e.printStackTrace();
                    }
                }
            } catch (IOException e) {
                System.err.println("No se pudo iniciar el servidor en puerto " + port);
            } finally {
                running = false;
            }
        });

        listenerThread.start();
    }

    public void stop() {
        running = false;
        try {
            if (serverSocket != null && !serverSocket.isClosed()) {
                serverSocket.close();
            }
        } catch (IOException ignored) {}
        
        if (listenerThread != null) {
            listenerThread.interrupt();
        }
    }

    public boolean isRunning() {
        return running;
    }
}