package com.shelterai.simulator_os.model;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ModelTest {

    // --- TESTS DE PRIORITY LEVEL ---

    @Test
    void testPriorityLevelFromString() {
        assertEquals(PriorityLevel.ELDERLY, PriorityLevel.fromString("ANCIANO"));
        assertEquals(PriorityLevel.ELDERLY, PriorityLevel.fromString("elderly"));
        
        assertEquals(PriorityLevel.PREGNANT, PriorityLevel.fromString("EMBARAZADA"));
        assertEquals(PriorityLevel.CHILD, PriorityLevel.fromString("NIÑO"));
        assertEquals(PriorityLevel.CHILD, PriorityLevel.fromString("child"));
        
        // Caso por defecto
        assertEquals(PriorityLevel.ADULT, PriorityLevel.fromString("CUALQUIER COSA"));
        assertEquals(PriorityLevel.ADULT, PriorityLevel.fromString(null));
    }

    @Test
    void testPriorityValues() {
        // Verificar que los valores numéricos son correctos (Mayor valor = Mayor prioridad)
        assertTrue(PriorityLevel.ELDERLY.getValue() > PriorityLevel.ADULT.getValue());
    }

    // --- TESTS DE REFUGEE ---

    @Test
    void testRefugeeCreation() {
        Refugee r = new Refugee("Juan", PriorityLevel.ADULT, 5000);
        assertEquals("Juan", r.getId());
        assertEquals(PriorityLevel.ADULT, r.getPriority());
        assertEquals(5000, r.getProcessingTimeMs());
    }

    @Test
    void testRefugeeComparison() {
        // Escenario: r1 es ANCIANO (Prio 4), r2 es NIÑO (Prio 2)
        Refugee r1 = new Refugee("Abuelo", PriorityLevel.ELDERLY, 1000);
        Refugee r2 = new Refugee("Niño", PriorityLevel.CHILD, 1000);

        // compareTo debe devolver negativo si r1 es "mayor" prioridad (va antes en la cola)
        // Nota: PriorityBlockingQueue ordena ascendente, pero tu lógica hace: other - this
        // Si other(4) - this(2) = positivo -> other va antes.
        // Si other(2) - this(4) = negativo -> this va antes.
        
        // Verificamos que r1 tiene más prioridad que r2
        assertTrue(r1.compareTo(r2) < 0, "El anciano debería ir antes que el niño");
    }

    @Test
    void testRefugeeComparisonSamePriority() throws InterruptedException {
        // Escenario: Dos adultos. El que llega antes, va antes.
        Refugee r1 = new Refugee("Adulto1", PriorityLevel.ADULT, 1000);
        Thread.sleep(10); // Pequeña pausa para asegurar timestamp distinto
        Refugee r2 = new Refugee("Adulto2", PriorityLevel.ADULT, 1000);

        // r1 llegó antes (timestamp menor). r1 - r2 debería ser negativo
        assertTrue(r1.compareTo(r2) < 0, "El primero en llegar debería ser atendido antes");
    }
}
