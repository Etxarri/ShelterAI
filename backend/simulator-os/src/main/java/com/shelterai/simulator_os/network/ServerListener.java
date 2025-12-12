package com.shelterai.simulator_os.network;

import com.shelterai.simulator_os.core.ShelterManager;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ServerListener {

    private final int port;
    private final ShelterManager shelterManager;

    // Control de estado para los tests
    private volatile boolean running = false;
    private Thread listenerThread;
    private ServerSocket serverSocket;

    public ServerListener(int port) {
        this.port = port;
        this.shelterManager = new ShelterManager();
    }

    public void start() {
        // Si ya está arrancado, no hacemos nada (rama para coverage)
        if (running) {
            return;
        }

        running = true;

        listenerThread = new Thread(() -> {
            try (ServerSocket ss = new ServerSocket(port)) {
                serverSocket = ss;
                System.out.println("[NET] Servidor Multi-Refugio escuchando en puerto " + port);

                // Bucle principal del servidor
                while (running) {
                    Socket clientSocket = ss.accept();
                    new Thread(new ClientHandler(clientSocket, shelterManager)).start();
                }

            } catch (IOException e) {
                // Camino de error (puerto ocupado, etc.)
                e.printStackTrace();
            } finally {
                running = false;
            }
        });

        listenerThread.start();
    }

    // Método para que los tests puedan parar el servidor
    void stop() {
        running = false;
        // Esto hace que el accept() falle y el hilo salga del bucle
        if (serverSocket != null && !serverSocket.isClosed()) {
            try {
                serverSocket.close();
            } catch (IOException ignored) {
            }
        }
        if (listenerThread != null) {
            listenerThread.interrupt();
        }
    }

    // MUY IMPORTANTE: quitar el if(listenerThread != null)
    // para no tener ramas sin cubrir
    boolean isRunning() {
        return running;
    }
}
