package com.shelterai.simulator_os.network;

import com.shelterai.simulator_os.core.ShelterManager;
import com.shelterai.simulator_os.model.PriorityLevel;
import com.shelterai.simulator_os.model.Refugee;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.concurrent.ThreadLocalRandom;

public class ClientHandler implements Runnable {
    private final Socket clientSocket;
    private final ShelterManager manager;

    public ClientHandler(Socket socket, ShelterManager manager) {
        this.clientSocket = socket;
        this.manager = manager;
    }

    @Override
    public void run() {
        try (
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)
        ) {
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                String[] parts = inputLine.trim().split(":");
                if (parts.length == 0) continue;

                String command = parts[0].toUpperCase();

                switch (command) {
                    case "ADD": 
                        // PROTOCOLO SIMPLIFICADO: ADD:NOMBRE:PRIORIDAD
                        // (Ya no necesitamos decir el destino, es automático)
                        if (parts.length >= 3) {
                            String name = parts[1];
                            String prioStr = parts[2];
                            
                            int randomTime = ThreadLocalRandom.current().nextInt(5000, 10000);
                            Refugee r = new Refugee(name, PriorityLevel.fromString(prioStr), randomTime);
                            
                            manager.addRefugeeToGlobalQueue(r);
                            out.println("[OK] " + name + " en Sala de Espera Global");
                        } else {
                            out.println("[ERROR] Use: ADD:NOMBRE:PRIORIDAD");
                        }
                        break;

                    case "STATUS":
                        out.println(manager.getAllStatuses());
                        break;

                    case "SET_CAPACITY":
                        // Formato: SET_CAPACITY:REFUGIO_ID:CANTIDAD
                        if (parts.length == 3) {
                            manager.updateCapacity(parts[1], Integer.parseInt(parts[2]));
                            out.println("[OK] Capacidad actualizada");
                        }
                        break;
                    default:
                        out.println("[ERROR] Comando desconocido");
                }
            }
        } catch (Exception e) {
        } finally {
            try { clientSocket.close(); } catch (Exception e) {}
        }
    }
}