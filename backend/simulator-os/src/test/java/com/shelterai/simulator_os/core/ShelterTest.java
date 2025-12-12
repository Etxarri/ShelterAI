package com.shelterai.simulator_os.core;

import com.shelterai.simulator_os.model.Refugee;
import org.junit.jupiter.api.Test;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ShelterTest {

    @Test
    void testDecreaseCapacity() {
        // 1. PREPARACIÓN
        // Creamos una cola tonta (no la vamos a usar)
        BlockingQueue<Refugee> queue = new LinkedBlockingQueue<>();
        
        // Creamos un refugio con capacidad 10
        // (Al inicio: Capacidad = 10, Camas libres = 10)
        Shelter shelter = new Shelter("TestUnit", 10, queue);

        // 2. EJECUCIÓN QUE TOCA LA LÍNEA ROJA
        // Bajamos la capacidad a 5.
        // diff = 5 - 10 = -5. 
        // Como diff < 0, entra en el 'else if' y ejecuta 'beds.acquireUninterruptibly(5)'
        // Como hay 10 camas libres y pedimos bloquear 5, funciona al instante.
        shelter.setCapacity(5);

        // 3. VERIFICACIÓN
        // Comprobamos que el cambio se ha aplicado
        String status = shelter.getStatusJson();
        assertTrue(status.contains("capacity\": 5"), "La capacidad debería haber bajado a 5");
    }

    @Test
    void testDecreaseCapacityPermitsChanged() throws Exception {
        BlockingQueue<Refugee> queue = new LinkedBlockingQueue<>();
        Shelter shelter = new Shelter("TestUnit", 10, queue);

        // Accedemos por reflexión al campo 'beds' para comprobar los permisos
        java.lang.reflect.Field bedsField = Shelter.class.getDeclaredField("beds");
        bedsField.setAccessible(true);
        java.util.concurrent.Semaphore beds = (java.util.concurrent.Semaphore) bedsField.get(shelter);

        int before = beds.availablePermits();
        // Reducimos la capacidad: diff = 5 - 10 = -5 -> acquireUninterruptibly(5)
        shelter.setCapacity(5);
        int after = beds.availablePermits();

        // Después de pedir 5 permisos menos, los permisos disponibles deben haber disminuido en 5
        assertTrue(after == before - 5, "Los permisos disponibles deberían haber disminuido en 5");
    }
}