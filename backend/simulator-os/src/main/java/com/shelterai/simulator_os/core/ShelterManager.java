package com.shelterai.simulator_os.core;

import com.shelterai.simulator_os.model.Refugee;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.Map;
import java.util.stream.Collectors;

public class ShelterManager {

    // --- CAMBIO CLAVE: LA COLA ES GLOBAL Y COMPARTIDA ---
    private final BlockingQueue<Refugee> globalQueue = new PriorityBlockingQueue<>();
    
    private final Map<String, Shelter> shelters = new ConcurrentHashMap<>();

    public ShelterManager() {
        // Pasamos la cola global a los refugios
        createShelter("North", 3);
        createShelter("South", 3);
    }

    public void createShelter(String id, int capacity) {
        if (!shelters.containsKey(id)) {
            // Le pasamos la 'globalQueue' al refugio para que chupe de ahí
            Shelter newShelter = new Shelter(id, capacity, globalQueue);
            shelters.put(id, newShelter);
            new Thread(newShelter).start();
        }
    }

    // Método simple: Solo añade a la cola global (ya no decide destino)
    public void addRefugeeToGlobalQueue(Refugee refugee) {
        globalQueue.add(refugee);
        System.out.println("[WAITING ROOM] " + refugee.getId() + " entered in the global queue. (Total waiting: " + globalQueue.size() + ")");
    }

    public void updateCapacity(String shelterId, int capacity) {
        Shelter target = shelters.get(shelterId);
        if (target != null) target.setCapacity(capacity);
    }

    public String getAllStatuses() {
        String jsonList = shelters.values().stream()
                .map(Shelter::getStatusJson)
                .collect(Collectors.joining(","));
        // Añadimos info de la cola global al JSON
        return String.format("{\"global_queue\": %d, \"shelters\": [%s]}", globalQueue.size(), jsonList);
    }
}