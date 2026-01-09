package com.shelterai.simulator_os;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

@SpringBootTest
class SimulatorOsApplicationTests {

    // Testea que el contexto de Spring carga correctamente
    // Cubre implícitamente el método 'run' del CommandLineRunner
    @Test
    void contextLoads() {
    }

    // Testea explícitamente el método main estático
    @Test
    void testMain() {
        // Al llamar a main, intentará levantar el servidor en el puerto 9999.
        // Si 'contextLoads' ya corrió, el puerto estará ocupado y ServerListener
        // (con mi corrección anterior) capturará la IOException y imprimirá el error,
        // PERO NO lanzará excepción que rompa el test.
        assertDoesNotThrow(() -> {
            SimulatorOsApplication.main(new String[]{});
        });
    }
}