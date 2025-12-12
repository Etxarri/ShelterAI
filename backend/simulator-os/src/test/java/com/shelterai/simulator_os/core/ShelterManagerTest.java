package com.shelterai.simulator_os.core;

import com.shelterai.simulator_os.model.PriorityLevel;
import com.shelterai.simulator_os.model.Refugee;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ShelterManagerTest {

    private ShelterManager manager;

    @BeforeEach
    void setUp() {
        manager = new ShelterManager();
    }

    @Test
    void testInitialization() {
        String jsonStatus = manager.getAllStatuses();
        
        assertTrue(jsonStatus.contains("Norte"));
        assertTrue(jsonStatus.contains("Sur"));
        // Al inicio debe estar vacía
        assertTrue(jsonStatus.contains("global_queue\": 0"));
    }

    @Test
    void testAddRefugeeToGlobalQueue() throws InterruptedException {
        // 🔴 FIX: Saturamos el sistema para evitar Race Condition
        // Capacidad total = 3 (Norte) + 3 (Sur) = 6 camas.
        // Si añadimos 1 solo, se lo comen al instante y la cola da 0.
        
        // Añadimos 10 refugiados con un tiempo de proceso largo (2000ms)
        // para asegurar que las camas se quedan ocupadas un rato.
        for (int i = 0; i < 10; i++) {
            Refugee r = new Refugee("R" + i, PriorityLevel.ADULT, 2000);
            manager.addRefugeeToGlobalQueue(r);
        }
        
        // Damos un respiro mínimo para que los hilos cojan los primeros 6
        Thread.sleep(100);

        String jsonStatus = manager.getAllStatuses();
        
        // Hemos metido 10. Las camas son 6. Deberían quedar aprox 4 en cola.
        // Lo importante es que YA NO ES 0.
        assertFalse(jsonStatus.contains("global_queue\": 0"), "La cola no debería estar vacía, el sistema está saturado");
        
        // Opcional: Verificar que hay refugios ocupados
        // assertTrue(jsonStatus.contains("used\": 3"));
    }

    @Test
    void testCreateShelter() {
        manager.createShelter("Este", 10);
        
        String jsonStatus = manager.getAllStatuses();
        assertTrue(jsonStatus.contains("Este"));
        assertTrue(jsonStatus.contains("capacity\": 10"));
    }

    @Test
    void testUpdateCapacity() {
        manager.updateCapacity("Norte", 50);
        
        String jsonStatus = manager.getAllStatuses();
        assertTrue(jsonStatus.contains("\"id\": \"Norte\", \"capacity\": 50"));
    }
    
    @Test
    void testUpdateCapacityNonExistent() {
        assertDoesNotThrow(() -> manager.updateCapacity("FANTASMA", 100));
    }
}