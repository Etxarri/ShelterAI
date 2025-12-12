package com.shelterai.simulator_os.network;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ServerListenerTest {

    // TEST 1: Camino feliz, el servidor acepta al menos una conexión
    @Test
    void testServerStartsAndAcceptsConnection() {
        int port = 9990;

        ServerListener server = new ServerListener(port);
        server.start();

        // Esperamos a que arranque
        try { Thread.sleep(300); } catch (InterruptedException ignored) {}

        // Conectamos un cliente real
        assertDoesNotThrow(() -> {
            try (Socket client = new Socket("localhost", port);
                 PrintWriter out = new PrintWriter(client.getOutputStream(), true)) {
                out.println("STATUS");
                Thread.sleep(100);
            }
        });

        // Paramos el servidor para que salga del while(running)
        server.stop();
        try { Thread.sleep(200); } catch (InterruptedException ignored) {}
    }

    // TEST 2: Camino de error -> puerto ocupado, se entra en el catch(IOException)
    @Test
    void testServerFailsOnBusyPort() throws IOException {
        int port = 9991;

        try (ServerSocket blocker = new ServerSocket(port)) {

            ServerListener server = new ServerListener(port);
            server.start();

            // Esperamos a que el hilo intente abrir el mismo puerto y falle
            try { Thread.sleep(300); } catch (InterruptedException ignored) {}

            // El hilo interno terminará en el catch, no hace falta más
            server.stop();
        }
    }

    // TEST 3: Comprobamos isRunning() y el if(running) de start()
    @Test
    void testIsRunningAndSecondStartDoesNothing() {
        int port = 9992;
        ServerListener server = new ServerListener(port);

        // Antes de start(): running = false
        assertFalse(server.isRunning());

        // Primera vez: arranca el servidor
        server.start();
        try { Thread.sleep(200); } catch (InterruptedException ignored) {}
        assertTrue(server.isRunning());

        // Segunda vez: entra en el if(running) { return; }
        server.start();
        try { Thread.sleep(100); } catch (InterruptedException ignored) {}

        // Ahora lo paramos para que salga del while
        server.stop();
        try { Thread.sleep(200); } catch (InterruptedException ignored) {}
        assertFalse(server.isRunning());
    }
}
