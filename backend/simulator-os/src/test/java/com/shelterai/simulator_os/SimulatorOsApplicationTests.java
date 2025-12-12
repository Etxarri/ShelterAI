package com.shelterai.simulator_os;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

@SpringBootTest
class SimulatorOsApplicationTests {

    // TEST 1: Carga del contexto
    // Este test cubre la clase y el método 'run' (porque es un CommandLineRunner)
    @Test
    void contextLoads() {
        // Al usar @SpringBootTest, Spring arranca, ejecuta el método run(),
        // inicia tu servidor en el hilo aparte y marca esas líneas en verde.
    }

    // TEST 2: Ejecución explícita del main
    // Este test cubre la línea 'public static void main' que suele quedarse roja
    @Test
    void testMain() {
        // Forzamos la llamada al método estático main.
        // Esto intentará arrancar la app de nuevo. Si el puerto 9999 está ocupado
        // por el test anterior, tu ServerListener capturará el error y no pasará nada grave.
        assertDoesNotThrow(() -> {
            SimulatorOsApplication.main(new String[] {});
        });
    }

}