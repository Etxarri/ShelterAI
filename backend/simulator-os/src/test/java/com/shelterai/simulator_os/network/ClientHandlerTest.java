package com.shelterai.simulator_os.network;

import com.shelterai.simulator_os.core.ShelterManager;
import com.shelterai.simulator_os.model.Refugee;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.Socket;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ClientHandlerTest {

    @Mock
    private Socket socket;

    @Mock
    private ShelterManager shelterManager;

    private ByteArrayOutputStream outContent;

    @BeforeEach
    void init() throws IOException {
        outContent = new ByteArrayOutputStream();
        
        // ✅ CORRECCIÓN AQUÍ: Usamos lenient()
        // Esto le dice a Mockito: "Prepara esto, pero si un test (como el de excepción)
        // no llega a usarlo, no lances error".
        lenient().when(socket.getOutputStream()).thenReturn(outContent);
    }

    // TEST 1: ADD Correcto
    @Test
    void testHandleAddCommandSuccess() throws IOException {
        String input = "ADD:Juan:ANCIANO\n";
        setupInput(input);

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();

        verify(shelterManager, times(1)).addRefugeeToGlobalQueue(any(Refugee.class));
        
        String output = outContent.toString();
        assertTrue(output.contains("\"status\":\"OK\""));
        assertTrue(output.contains("\"event\":\"REGISTERED\""));
    }

    // TEST 2: Formato incorrecto
    @Test
    void testHandleAddCommandInvalidFormat() throws IOException {
        String input = "ADD:SoloNombre\n"; 
        setupInput(input);

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();

        verify(shelterManager, never()).addRefugeeToGlobalQueue(any());
        assertTrue(outContent.toString().contains("\"message\":\"Incorrect format\""));
    }

    // TEST 3: Comando vacío después de ADD exitoso
    @Test
    void testMultipleCommands() throws IOException {
        String input = "ADD:Maria:ELDER\n";
        setupInput(input);

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();

        verify(shelterManager, times(1)).addRefugeeToGlobalQueue(any(Refugee.class));
        assertTrue(outContent.toString().contains("\"status\":\"OK\""));
    }

    // TEST 4: SET_CAPACITY
    @Test
    void testHandleSetCapacityCommand() throws IOException {
        String input = "SET_CAPACITY:Norte:50\n";
        setupInput(input);

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();

        verify(shelterManager, times(1)).updateCapacity("Norte", 50);
        assertTrue(outContent.toString().contains("\"event\":\"CAPACITY_CHANGED\""));
    }

    // TEST 5: Comando desconocido
    @Test
    void testUnknownCommand() throws IOException {
        String input = "EXPLOTAR:AHORA\n";
        setupInput(input);

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();

        assertTrue(outContent.toString().contains("\"message\":\"Unknown command\""));
    }

    // TEST 6: Línea vacía
    @Test
    void testEmptyLine() throws IOException {
        setupInput(":\n"); // Simula línea vacía o split fallido

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();
        
        verifyNoInteractions(shelterManager);
    }

    // TEST 7: Excepción (EL QUE DABA PROBLEMAS)
    @Test
    void testHandleException() throws IOException {
        // Hacemos que falle al intentar obtener el input
        when(socket.getInputStream()).thenThrow(new IOException("Error simulado"));

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run(); 
        
        // Gracias a lenient(), ya no importa que getOutputStream no se llame.
        verify(socket, times(1)).close();
    }

    private void setupInput(String data) throws IOException {
        ByteArrayInputStream in = new ByteArrayInputStream(data.getBytes());
        when(socket.getInputStream()).thenReturn(in);
    }
}