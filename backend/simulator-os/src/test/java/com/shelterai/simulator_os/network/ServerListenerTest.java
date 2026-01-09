package com.shelterai.simulator_os.network;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

import static org.junit.jupiter.api.Assertions.*;

class ServerListenerTest {

    private ServerListener server;

    @AfterEach
    void tearDown() {
        if (server != null) {
            server.stop();
        }
    }

    @Test
    void testServerStartsAndAcceptsConnection() {
        int port = 9001; // Puerto único para este test
        server = new ServerListener(port);
        server.start();

        // Esperar a que levante
        assertTimeout(java.time.Duration.ofSeconds(2), () -> {
            while (!server.isRunning()) {
                Thread.sleep(50);
            }
        });

        assertTrue(server.isRunning());

        // Conectar cliente
        assertDoesNotThrow(() -> {
            try (Socket client = new Socket("localhost", port);
                 PrintWriter out = new PrintWriter(client.getOutputStream(), true)) {
                out.println("STATUS");
            }
        });
    }

    @Test
    void testServerFailsOnBusyPort() throws IOException {
        int port = 9002;
        // Ocupamos el puerto intencionadamente
        try (ServerSocket blocker = new ServerSocket(port)) {
            
            server = new ServerListener(port);
            server.start();

            // Damos tiempo a que falle
            try { Thread.sleep(500); } catch (InterruptedException ignored) {}

            // No debería estar corriendo porque el puerto estaba ocupado
            assertFalse(server.isRunning());
        }
    }

    @Test
    void testDoubleStartAndStop() throws InterruptedException {
        int port = 9003;
        server = new ServerListener(port);
        
        server.start();
        // Esperar a que arranque
        Thread.sleep(200);
        assertTrue(server.isRunning());

        // Segundo start no debe hacer nada (ni romper nada)
        server.start();
        assertTrue(server.isRunning());

        // Stop
        server.stop();
        Thread.sleep(200);
        assertFalse(server.isRunning());
    }
}