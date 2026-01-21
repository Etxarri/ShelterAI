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
        // Verificamos que el manager se crea correctamente
        // Simplemente verificamos que el manager no es null y puede operar
        assertNotNull(manager);
        assertDoesNotThrow(() -> manager.addRefugeeToGlobalQueue(
            new Refugee("Test", PriorityLevel.ADULT, 1000)
        ));
    }

    @Test
    void testAddRefugeeToGlobalQueue() throws InterruptedException {
        // Verificamos que los refugiados se pueden añadir sin errores
        Refugee r1 = new Refugee("Refugee1", PriorityLevel.ADULT, 100);
        Refugee r2 = new Refugee("Refugee2", PriorityLevel.ELDERLY, 100);
        
        assertDoesNotThrow(() -> manager.addRefugeeToGlobalQueue(r1));
        assertDoesNotThrow(() -> manager.addRefugeeToGlobalQueue(r2));
        
        // Damos tiempo para que el sistema procese
        Thread.sleep(50);
    }

    @Test
    void testCreateShelter() {
        // Verificamos que se puede crear un nuevo refugio sin errores
        assertDoesNotThrow(() -> manager.createShelter("East", 10));
        
        // Verificamos que no genera excepción al intentar crear uno que ya existe
        assertDoesNotThrow(() -> manager.createShelter("North", 5));
    }

    @Test
    void testUpdateCapacity() {
        // Verificamos que se puede actualizar la capacidad sin errores
        assertDoesNotThrow(() -> manager.updateCapacity("North", 50));
    }
    
    @Test
    void testUpdateCapacityNonExistent() {
        assertDoesNotThrow(() -> manager.updateCapacity("FANTASMA", 100));
    }
}