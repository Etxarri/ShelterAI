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
                        // Formato esperado: ADD:NOMBRE:PRIORIDAD
                        if (parts.length >= 3) {
                            String name = parts[1];
                            String prioStr = parts[2];
                            
                            int randomTime = ThreadLocalRandom.current().nextInt(5000, 10000);
                            Refugee r = new Refugee(name, PriorityLevel.fromString(prioStr), randomTime);
                            
                            // Añadimos a la cola global
                            manager.addRefugeeToGlobalQueue(r);

                            // --- CAMBIO CLAVE: RESPUESTA EN JSON PARA NODE-RED ---
                            // Esto permite que Node-RED lea los datos y mande el Telegram/Email
                            String jsonResponse = String.format(
                                "{\"status\":\"OK\", \"event\":\"REGISTERED\", \"refugee\":\"%s\", \"priority\":\"%s\", \"message\":\"Ingresado en cola global correctamente\"}", 
                                name, prioStr
                            );
                            out.println(jsonResponse);

                        } else {
                            out.println("{\"status\":\"ERROR\", \"message\":\"Formato incorrecto\"}");
                        }
                        break;

                    case "STATUS":
                        // El manager ya devuelve JSON, así que lo enviamos tal cual
                        out.println(manager.getAllStatuses());
                        break;

                    case "SET_CAPACITY":
                        if (parts.length == 3) {
                            manager.updateCapacity(parts[1], Integer.parseInt(parts[2]));
                            out.println("{\"status\":\"OK\", \"event\":\"CAPACITY_CHANGED\", \"target\":\"" + parts[1] + "\"}");
                        }
                        break;
                    default:
                        out.println("{\"status\":\"ERROR\", \"message\":\"Comando desconocido\"}");
                }
            }
        } catch (Exception e) {
            // Error de conexión
        } finally {
            try { clientSocket.close(); } catch (Exception e) {}
        }
    }
}