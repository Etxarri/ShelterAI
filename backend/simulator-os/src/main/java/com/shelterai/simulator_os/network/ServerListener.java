package com.shelterai.simulator_os.network;

import com.shelterai.simulator_os.core.ShelterManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ServerListener {

    // 1. Definimos el Logger
    private static final Logger logger = LoggerFactory.getLogger(ServerListener.class);

    private final int port;
    private final ShelterManager shelterManager;

    private volatile boolean running = false;
    private Thread listenerThread;
    
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
                this.serverSocket = new ServerSocket(port);
                
                // 2. Usamos logger.info en lugar de System.out
                logger.info("[NET] Multi-Shelter Server listening in port {}", port);

                while (running && !serverSocket.isClosed()) {
                    try {
                        Socket clientSocket = serverSocket.accept();
                        new Thread(new ClientHandler(clientSocket, shelterManager)).start();
                    } catch (IOException e) {
                        // 3. Usamos logger.error en lugar de e.printStackTrace()
                        // Solo logueamos si el servidor sigue corriendo (no si fue un stop intencional)
                        if (running) {
                            logger.error("Error aceptando conexión del cliente", e);
                        }
                    }
                }
            } catch (IOException e) {
                logger.error("No se pudo iniciar el servidor en puerto {}", port, e);
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
        } catch (IOException e) {
            // Logueamos a nivel debug o info, ya que cerrar es esperado
            logger.debug("Error al cerrar el socket del servidor", e);
        }
        
        if (listenerThread != null) {
            listenerThread.interrupt();
        }
    }

    public boolean isRunning() {
        return running;
    }
}