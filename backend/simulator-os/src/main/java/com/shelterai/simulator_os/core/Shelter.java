package com.shelterai.simulator_os.core;

import com.shelterai.simulator_os.model.Refugee;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;

public class Shelter implements Runnable {

    private final String shelterId;
    private final BlockingQueue<Refugee> sharedQueue; // Referencia a la cola global
    private final Semaphore beds;
    private final AtomicInteger totalCapacity;
    private volatile boolean running = true;

    // Constructor recibe la cola compartida
    public Shelter(String shelterId, int capacity, BlockingQueue<Refugee> sharedQueue) {
        this.shelterId = shelterId;
        this.totalCapacity = new AtomicInteger(capacity);
        this.sharedQueue = sharedQueue; 
        this.beds = new Semaphore(capacity, true);
    }

    @Override
    public void run() {
        System.out.println("[SYSTEM] Shelter '" + shelterId + "' active and conected to the global Queue.");

        while (running) {
            try {
                // 1. RECLUTAMIENTO: Intentar reservar una cama.
                // Si no hay camas en ESTE refugio, el hilo se duerme aquí.
                beds.acquire();

                // 2. BUSCAR CLIENTE: Ir a la cola global.
                // Si hay cama pero no hay refugiados, espera aquí.
                // Al ser cola compartida, el primero que llegue (Norte o Sur) se lleva al refugiado.
                Refugee refugee = sharedQueue.take();

                // 3. PROCESAR (Hilo independiente para no bloquear la entrada)
                new Thread(() -> processStay(refugee)).start();

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void processStay(Refugee refugee) {
        try {
            System.out.println("[IN] (" + shelterId + ") has taken to " + refugee.getId() + " [Prio: " + refugee.getPriority() + "].");
            
            Thread.sleep(refugee.getProcessingTimeMs());

            System.out.println("[OUT] (" + shelterId + ") " + refugee.getId() + " goes.");
            
            // Liberar cama. Inmediatamente el bucle 'run' (arriba) despertará y cogerá al siguiente de la global.
            beds.release();

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    public void setCapacity(int newCapacity) {
        int diff = newCapacity - totalCapacity.get();
        if (diff > 0) beds.release(diff);
        else if (diff < 0) beds.acquireUninterruptibly(-diff);
        totalCapacity.set(newCapacity);
        System.out.println("[ADMIN] (" + shelterId + ") Capacity: " + newCapacity);
    }

    public String getStatusJson() {
        int used = totalCapacity.get() - beds.availablePermits();
        return String.format("{\"id\": \"%s\", \"capacity\": %d, \"used\": %d}", 
                             shelterId, totalCapacity.get(), used);
    }
}