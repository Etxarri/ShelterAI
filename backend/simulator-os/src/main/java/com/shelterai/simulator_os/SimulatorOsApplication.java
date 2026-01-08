package com.shelterai.simulator_os;

import com.shelterai.simulator_os.network.ServerListener;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SimulatorOsApplication implements CommandLineRunner {

	public static void main(String[] args) {
		SpringApplication.run(SimulatorOsApplication.class, args);
	}

	@Override
	public void run(String... args) throws Exception {
		System.out.println("--- INITIALIZING SHELTERS ---");
        // Iniciamos el servidor de sockets en puerto 9999
		ServerListener server = new ServerListener(9999);
		server.start();
	}
}
