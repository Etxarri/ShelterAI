package com.shelterai.simulator_os.network;

import com.shelterai.simulator_os.core.ShelterManager;
import com.shelterai.simulator_os.model.Refugee;
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

    @Test
    void testHandleAddCommandSuccess() throws IOException {
        // Happy Path: ADD correcto
        String input = "ADD:Juan:ANCIANO\n";
        setupSocket(input);

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();

        verify(shelterManager, times(1)).addRefugeeToGlobalQueue(any(Refugee.class));
    }

    @Test
    void testHandleAddCommandInvalidFormat() throws IOException {
        // 🔴 CUBRE LA RAMA ELSE DEL ADD
        String input = "ADD:SoloNombre\n"; // Faltan argumentos
        ByteArrayOutputStream outContent = setupSocket(input);

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();

        // Verificamos que no llama al manager y devuelve error
        verify(shelterManager, never()).addRefugeeToGlobalQueue(any());
        assertTrue(outContent.toString().contains("[ERROR] Use: ADD"));
    }

    @Test
    void testHandleSetCapacityCommand() throws IOException {
        // 🔴 CUBRE EL COMANDO SET_CAPACITY
        String input = "SET_CAPACITY:Norte:50\n";
        ByteArrayOutputStream outContent = setupSocket(input);

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run();

        verify(shelterManager, times(1)).updateCapacity("Norte", 50);
        assertTrue(outContent.toString().contains("[OK] Capacidad actualizada"));
    }

    @Test
    void testHandleException() throws IOException {
        // 🔴 CUBRE EL CATCH (Exception e)
        // Hacemos que el socket lance error al intentar leer
        when(socket.getInputStream()).thenThrow(new IOException("Error de red simulado"));

        ClientHandler handler = new ClientHandler(socket, shelterManager);
        handler.run(); // No debería lanzar excepción, sino capturarla y terminar

        // Si llegamos aquí sin crash, el catch funcionó.
    }

    // Helper para configurar mocks rápido
    private ByteArrayOutputStream setupSocket(String inputData) throws IOException {
        ByteArrayInputStream in = new ByteArrayInputStream(inputData.getBytes());
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        when(socket.getInputStream()).thenReturn(in);
        when(socket.getOutputStream()).thenReturn(out);
        return out;
    }
}