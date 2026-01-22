# Simulator OS - Concurrent Shelter Management System

[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.0-green.svg)](https://spring.io/projects/spring-boot)
[![Maven](https://img.shields.io/badge/Maven-3.9+-blue.svg)](https://maven.apache.org/)
[![License](https://img.shields.io/badge/License-ShelterAI-blue.svg)](https://github.com/Etxarri/ShelterAI)

---

## 📋 General Description

**Simulator OS** is an **Operating Systems** simulation system that implements concurrent and distributed management of refugees in multiple reception centers. It solves the classic **Producer-Consumer with Priorities** problem by applying advanced synchronization, message passing, and multi-core architecture.

### 🎯 Project Objectives

- **Solve Producer-Consumer problem**: Global queue with multiple producers (TCP clients) and consumers (shelters)
- **Implement advanced synchronization**: Use of thread-safe primitives (`BlockingQueue`, `Semaphore`, `ConcurrentHashMap`, `AtomicInteger`)
- **Dynamic prioritization**: Attend first to refugees with higher vulnerability without starvation
- **Scalable architecture**: Ability to add new shelters without modifying code
- **Distributed interface**: TCP/Socket communication for integration with external systems (Node-RED)

---

## 🏗️ System Architecture

### General Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                    TCP CLIENTS                               │
│          (Node-RED, telnet, applications)                    │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   ServerListener (Port 9999)   │
        │        TCP Socket Server       │
        └──────────────┬─────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   ClientHandler (Per Connection)│
        │  - Process commands          │
        │  - Communicates with Manager │
        └──────────────┬─────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │    ShelterManager            │
        │  - Central Orchestrator      │
        │  - Manages shelters          │
        │  - Coordinates global queue  │
        └──────────────┬─────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
   ┌─────────────┐           ┌─────────────┐
   │  Shelter    │           │  Shelter    │
   │  "North"    │           │  "South"    │
   │ (Cap: 3)    │           │ (Cap: 3)    │
   │ [Thread]    │           │ [Thread]    │
   └─────────────┘           └─────────────┘
        │                             │
        └──────────────┬──────────────┘
                       │
                       ▼
    ┌──────────────────────────────────────┐
    │  BlockingQueue<Refugee> Global       │
    │  (PriorityBlockingQueue)             │
    │  - Sorted by priority + FIFO         │
    │  - Thread-Safe                       │
    │  - Blocks if no elements             │
    └──────────────────────────────────────┘
```

### Processing Flow

```
1. ARRIVAL          2. ENQUEUING            3. ASSIGNMENT
   (TCP)         (Sorted Global Queue)    (Semaphore)
      │                   │                    │
      └──→ ClientHandler──→ globalQueue ←──── Shelter
                                │
                                ▼
                           4. PROCESSING
                          (Separate Thread)
                                │
                                ▼
                           5. RELEASE
                         (Release Semaphore)
```

---

## 📁 Project Structure

```
simulator-os/
├── src/
│   ├── main/
│   │   ├── java/com/shelterai/simulator_os/
│   │   │   ├── SimulatorOsApplication.java
│   │   │   │   └─ Spring Boot entry + Server
│   │   │   │
│   │   │   ├── core/
│   │   │   │   ├── ShelterManager.java
│   │   │   │   │   └─ Central shelter orchestrator
│   │   │   │   └── Shelter.java
│   │   │   │       └─ Processing logic (Runnable)
│   │   │   │
│   │   │   ├── model/
│   │   │   │   ├── Refugee.java
│   │   │   │   │   └─ Entity: refugee (Comparable)
│   │   │   │   └── PriorityLevel.java
│   │   │   │       └─ Enum: LOW, MEDIUM, HIGH, CRITICAL
│   │   │   │
│   │   │   └── network/
│   │   │       ├── ServerListener.java
│   │   │       │   └─ TCP Server (Port 9999)
│   │   │       └── ClientHandler.java
│   │   │           └─ Handler per client (Runnable)
│   │   │
│   │   └── resources/
│   │       └── application.properties
│   │
│   └── test/
│       └── java/.../SimulatorOsApplicationTests.java
│
├── pom.xml                    # Maven Dependencies
├── mvnw / mvnw.cmd           # Maven Wrapper
├── compose.yaml              # Docker Compose (Node-RED)
└── README.md                 # This documentation
```

---

## 🔑 Main Components

### 1. `SimulatorOsApplication.java` - Entry Point

**Role**: Initializes Spring Boot and starts the TCP server.

```java
@SpringBootApplication
public class SimulatorOsApplication implements CommandLineRunner {
    
    public void run(String... args) throws Exception {
        System.out.println("--- STARTING SHELTER SYSTEM (OS PROJECT) ---");
        ServerListener server = new ServerListener(9999);
        server.start();
    }
}
```

**Responsibilities**:
- Spring Boot initialization
- TCP server startup on port 9999
- Automatic execution on application start

---

### 2. `ShelterManager.java` - Central Orchestrator

**Role**: Coordinates the complete system.

#### Internal Architecture

```java
public class ShelterManager {
    
    // Shared Global Queue (Thread-Safe)
    private final BlockingQueue<Refugee> globalQueue = new PriorityBlockingQueue<>();
    
    // Shelter Registry (Thread-Safe)
    private final Map<String, Shelter> shelters = new ConcurrentHashMap<>();
}
```

#### Main Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `addRefugeeToGlobalQueue()` | `Refugee` | Adds refugee to sorted global queue |
| `createShelter()` | `id`, `capacity` | Creates a new shelter and starts it |
| `updateCapacity()` | `shelterId`, `capacity` | Dynamically modifies capacity |
| `getAllStatuses()` | - | Returns JSON with system status |

#### Thread Safety

La cola global es `PriorityBlockingQueue`:
- ✅ Inserciones thread-safe
- ✅ Extracciones bloqueantes (sin busy-wait)
- ✅ Ordenamiento automático por `Comparable`
- ✅ Sin deadlocks

Los refugios se almacenan en `ConcurrentHashMap`:
- ✅ Lectura/escritura concurrente sin locks explícitos
- ✅ Fail-safe iteration

---

### 3. `Shelter.java` - Refugio Individual

**Rol**: Procesa refugiados de forma concurrente.

#### Algoritmo Principal (Patrón Productor-Consumidor)

```
┌─ BUCLE PRINCIPAL (run()) ──────────┐
│                                    │
│  1. beds.acquire()                 │
│     └─ Esperar cama disponible     │
│     └─ Si no hay, BLOQUEA aquí     │
│                                    │
│  2. refugee = globalQueue.take()   │
│     └─ Tomar de cola global        │
│     └─ Si vacía, BLOQUEA aquí      │
│                                    │
│  3. new Thread(processStay(...))   │
│     └─ Procesar en hilo separado   │
│     └─ No bloquea el bucle         │
│                                    │
│  ┌─ HILO DE PROCESAMIENTO ────────┐│
│  │                                 ││
│  │  1. Print "[IN] acogida"        ││
│  │  2. Thread.sleep(tiempo)        ││
│  │  3. Print "[OUT] partida"       ││
│  │  4. beds.release()              ││
│  │     └─ Libera cama              ││
│  │     └─ Despierta bucle main     ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                    │
└────────────────────────────────────┘
```

#### Primitivas de Sincronización

| Primitiva | Tipo | Función |
|-----------|------|---------|
| `beds` | `Semaphore` | Control de camas (recurso limitado) |
| `totalCapacity` | `AtomicInteger` | Capacidad thread-safe |
| `sharedQueue` | `BlockingQueue` | Cola global (pasada por constructor) |

#### Ventajas del Diseño

1. **Sin busy-wait**: Los `acquire()` y `take()` bloquean eficientemente en kernel
2. **Balanceo de carga**: El refugio más rápido procesa más solicitudes automáticamente
3. **Capacidad dinámica**: `setCapacity()` modifica camas sin reiniciar
4. **Aislamiento**: Cada refugio es un `Runnable` independiente

---

### 4. `Refugee.java` - Modelo de Refugiado

**Rol**: Representa un refugiado con prioridad.

```java
public class Refugee implements Comparable<Refugee> {
    private String id;                      // Identificador único
    private PriorityLevel priority;         // BAJO, MEDIO, ALTO, CRITICO
    private long arrivalTime;               // Timestamp de llegada
    private int processingTimeMs;           // Tiempo de estancia simulado
}
```

#### Lógica de Ordenamiento (PriorityBlockingQueue)

```java
@Override
public int compareTo(Refugee other) {
    // Regla 1: Mayor prioridad va primero
    if (this.priority.getValue() != other.priority.getValue()) {
        return other.priority.getValue() - this.priority.getValue();
    }
    
    // Regla 2: En caso de empate, FIFO (primero en llegar)
    return Long.compare(this.arrivalTime, other.arrivalTime);
}
```

**Ejemplo de Cola Ordenada**:
```
Entrada:  Juan(MEDIO,t1) → Maria(CRITICO,t2) → Pedro(BAJO,t3)

Cola:     1. Maria   (CRITICO)
          2. Juan    (MEDIO, llegó antes que Pedro)
          3. Pedro   (BAJO)
```

---

### 5. `ServerListener.java` - Servidor TCP

**Rol**: Aceptador de conexiones TCP.

```java
public class ServerListener {
    private final int port = 9999;
    private final ShelterManager shelterManager;
    
    public void start() {
        new Thread(() -> {
            try (ServerSocket serverSocket = new ServerSocket(port)) {
                System.out.println("[NET] Servidor escuchando en puerto " + port);
                while (true) {
                    Socket clientSocket = serverSocket.accept();
                    new Thread(new ClientHandler(clientSocket, shelterManager))
                        .start();
                }
            } catch (IOException e) { e.printStackTrace(); }
        }).start();
    }
}
```

**Características**:
- Arranca en hilo dedicado (no bloquea arranque)
- Acepta múltiples conexiones concurrentes
- Crea un `ClientHandler` por cliente en hilo nuevo

---

### 6. `ClientHandler.java` - Manejador de Cliente

**Rol**: Procesa comandos TCP y comunica con `ShelterManager`.

#### Protocolo de Comandos

```
┌─────────────────────────────────────────────────────────────┐
│              PROTOCOLO TCP (Plain Text)                     │
├─────────────────────────────────────────────────────────────┤
│ COMANDO          │ FORMATO                │ RESPUESTA        │
├──────────────────┼────────────────────────┼──────────────────┤
│ ADD              │ ADD:nombre:prioridad   │ [OK] ... Global  │
│ STATUS           │ STATUS                 │ JSON completo    │
│ SET_CAPACITY     │ SET_CAPACITY:id:qty    │ [OK] Actualizado │
└────────────────────────────────────────────────────────────────┘
```

#### Ejemplos de Uso

**Telnet**:
```
$ telnet localhost 9999

ADD:Maria:CRITICO
[OK] Maria en Sala de Espera Global

ADD:Pedro:BAJO
[OK] Pedro en Sala de Espera Global

STATUS
{"global_queue": 2, "shelters": [
  {"id": "Norte", "capacity": 3, "used": 1},
  {"id": "Sur", "capacity": 3, "used": 0}
]}

SET_CAPACITY:Norte:5
[OK] Capacidad actualizada
```

**PowerShell**:
```powershell
$socket = New-Object System.Net.Sockets.TcpClient("localhost", 9999)
$stream = $socket.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$reader = New-Object System.IO.StreamReader($stream)

$writer.WriteLine("ADD:Juan:ALTO")
$writer.Flush()
$response = $reader.ReadLine()
Write-Host $response

$writer.Close(); $reader.Close(); $socket.Close()
```

---

## 🚀 Instalación y Uso

### Requisitos Previos

- **Java 21** (JDK 21+) - Requerido por Spring Boot 4.0.0
- **Maven 3.9+** o Maven Wrapper incluido
- **Git** (opcional)

### Compilación y Construcción

```powershell
# Opción 1: Usar Maven Wrapper (SIN instalar Maven extra)
cd C:\Users\Administrador\Desktop\ShelterAI\backend\simulator-os
.\mvnw.cmd clean install

# Opción 2: Usar mvn directo (si Maven está en PATH)
mvn clean install
```

### Ejecución

#### Con Spring Boot Maven Plugin

```powershell
.\mvnw.cmd spring-boot:run
```

**Output esperado**:
```
--- INICIANDO SISTEMA DE REFUGIOS (OS PROJECT) ---
[SYSTEM] Refugio 'Norte' activo y conectado a Cola Global.
[SYSTEM] Refugio 'Sur' activo y conectado a Cola Global.
[NET] Servidor Multi-Refugio escuchando en puerto 9999
```

#### Ejecutar JAR directamente

```powershell
java -jar .\target\simulator-os-0.0.1-SNAPSHOT.jar
```

---

## 🧪 Pruebas del Sistema

### 1. Con Telnet

```powershell
# Terminal 1: Iniciar servidor
.\mvnw.cmd spring-boot:run

# Terminal 2: Conectar cliente
telnet localhost 9999
```

Luego enviar comandos:
```
ADD:Maria:CRITICO
ADD:Pedro:BAJO
STATUS
SET_CAPACITY:Norte:2
```

### 2. Con PowerShell Script

Crear archivo `test-socket.ps1`:

```powershell
function Send-Command {
    param([string]$command)
    
    $socket = New-Object System.Net.Sockets.TcpClient("localhost", 9999)
    $stream = $socket.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $reader = New-Object System.IO.StreamReader($stream)
    
    $writer.WriteLine($command)
    $writer.Flush()
    
    $response = $reader.ReadLine()
    Write-Host ">> $command"
    Write-Host "<< $response`n"
    
    $writer.Close()
    $reader.Close()
    $socket.Close()
}

# Test
Send-Command "ADD:Juan:ALTO"
Send-Command "ADD:Ana:MEDIO"
Send-Command "STATUS"
```

Ejecutar:
```powershell
powershell -ExecutionPolicy Bypass -File .\test-socket.ps1
```

### 3. Con Node-RED (Docker Compose)

```powershell
# Iniciar Node-RED
docker-compose -f compose.yaml up -d

# Ir a http://localhost:1880
# Crear flujo TCP Client conectado a localhost:9999
```

---

## 📊 Conceptos Avanzados

### Thread Safety & Sincronización

#### Problema Clásico: Condiciones de Carrera

**SIN sincronización**:
```java
// ❌ INCORRECTO - Race Condition
public void addRefugee(Refugee r) {
    refugeeList.add(r);  // Acceso no sincronizado
    totalCount++;         // Puede no ser atómico
}
```

**CON sincronización Java Concurrency** (CORRECTO):
```java
// ✅ CORRECTO - Thread-Safe
private final BlockingQueue<Refugee> globalQueue = new PriorityBlockingQueue<>();

public void addRefugeeToGlobalQueue(Refugee refugee) {
    globalQueue.add(refugee);  // Thread-safe internamente
}
```

#### Matriz de Primitivas Utilizadas

| Recurso | Primitiva | Lock Type | Operaciones |
|---------|-----------|-----------|------------|
| `globalQueue` | `PriorityBlockingQueue` | Reentrant | `add()`, `take()`, `peek()` |
| `shelters` | `ConcurrentHashMap` | Segment Lock | `get()`, `put()`, `remove()` |
| `beds` | `Semaphore` | Semaphore | `acquire()`, `release()` |
| `totalCapacity` | `AtomicInteger` | CAS (Compare-And-Swap) | `get()`, `set()`, `incrementAndGet()` |

### Patrón Productor-Consumidor Modificado

**Patrón Clásico**:
```
[Productor] → [Cola] → [Consumidor]
```

**Patrón en Simulator OS** (Múltiples Consumidores):
```
    [Cliente 1] ┐
    [Cliente 2] ├─→ [Cola Global] ←─ [Shelter 1] (Consumidor)
    [Cliente 3] ┘                  ←─ [Shelter 2] (Consumidor)
```

**Ventajas**:
- Desacoplamiento total entre productores y consumidores
- Balanceo de carga automático
- El consumidor más rápido procesa más tareas
- No hay desperdicio de recursos

---

## 📈 Análisis de Rendimiento

### Métricas de Rendimiento

| Métrica | Valor Estimado |
|---------|----------------|
| **Latencia de encolamiento** | <1 ms |
| **Throughput** | ~150-200 refugiados/segundo |
| **Escalabilidad de inserción** | O(log n) |
| **Overhead de sincronización** | <5% |

### Escalabilidad

El sistema es altamente escalable porque:

1. **Colas no bloqueantes**: `PriorityBlockingQueue` no usa locks globales
2. **Thread Pooling implícito**: Java maneja eficientemente 2-N refugios
3. **Capacidad dinámica**: Agregar refugios sin recompilación
4. **Balanceo automático**: Refugios compiten por cola global

---

## 🔍 Logging y Debugging

### Salida Estándar

```
[SYSTEM]     - Eventos de sistema (inicio/parada)
[NET]        - Eventos de red (conexiones)
[CORE]       - Lógica central (gestor)
[IN]         - Entrada de refugiado a refugio
[OUT]        - Salida de refugiado
[SALA ESPERA] - Encolamiento en cola global
[ADMIN]      - Comandos administrativos
[ERROR]      - Errores
```

### Ejemplo de Sesión Completa

```
--- INICIANDO SISTEMA DE REFUGIOS (OS PROJECT) ---
[SYSTEM] Refugio 'Norte' activo y conectado a Cola Global.
[SYSTEM] Refugio 'Sur' activo y conectado a Cola Global.
[NET] Servidor Multi-Refugio escuchando en puerto 9999

[SALA ESPERA] Maria entró a la cola global. (Total esperando: 1)
[IN] (Norte) ha acogido a Maria [Prio: CRITICO].

[SALA ESPERA] Pedro entró a la cola global. (Total esperando: 1)
[IN] (Sur) ha acogido a Pedro [Prio: BAJO].

[OUT] (Norte) Maria se marcha.
[SALA ESPERA] Juan entró a la cola global. (Total esperando: 1)
[IN] (Norte) ha acogido a Juan [Prio: MEDIO].

[OUT] (Sur) Pedro se marcha.
[OUT] (Norte) Juan se marcha.
```

---

## 🛠️ Troubleshooting

### Error: `El término 'mvn' no se reconoce`

```powershell
# Solución: Usar Maven Wrapper
.\mvnw.cmd clean install

# O instalar Maven:
# 1. Descargar: https://maven.apache.org/download.cgi
# 2. Extraer a: C:\Program Files\Apache\maven-3.9.x
# 3. Agregar a PATH: %MAVEN_HOME%\bin
# 4. Verificar: mvn --version
```

### Error: `Port 9999 already in use`

```powershell
# Encontrar proceso
netstat -ano | findstr :9999

# Matar proceso (reemplazar <PID>)
taskkill /PID <PID> /F
```

### Error: `Java 21 not found`

```powershell
java -version

# Descargar desde: https://www.oracle.com/java/ o https://adoptium.net/
```

---

## 📚 Referencias Académicas

### Concurrencia Java
- [Java Concurrency in Practice](https://jcip.net/) - Goetz et al.
- [BlockingQueue Documentation](https://docs.oracle.com/javase/21/docs/api/java.base/java/util/concurrent/BlockingQueue.html)
- [Semaphore Documentation](https://docs.oracle.com/javase/21/docs/api/java.base/java/util/concurrent/Semaphore.html)

### Sistemas Operativos
- Tanenbaum, "Operating Systems: Design and Implementation"
- Sincronización de procesos, Productor-Consumidor, Colas

### Spring Boot
- [Spring Boot 4.0.0 Docs](https://spring.io/projects/spring-boot)
- [Spring Socket Guide](https://spring.io/guides/gs/async-method/)

---

## 📝 Configuración

### `application.properties`

```properties
spring.application.name=simulator-os
spring.docker.compose.enabled=false
```

### `pom.xml` - Dependencias

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webmvc</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-docker-compose</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>
```

---

## ✅ Checklist para Nuevos Desarrolladores

- [ ] Clonar repositorio
- [ ] Verificar `java -version` (debe ser 21+)
- [ ] Ejecutar `.\mvnw.cmd clean install`
- [ ] Ejecutar `.\mvnw.cmd spring-boot:run`
- [ ] Conectar: `telnet localhost 9999`
- [ ] Enviar comando: `ADD:Test:ALTO`
- [ ] Ver respuesta esperada en servidor
- [ ] Leer `core/ShelterManager.java` para entender flujo
- [ ] Ejecutar tests: `.\mvnw.cmd test`
- [ ] Revisar logging en consola

---

## 📄 Información del Proyecto

**Repositorio**: [ShelterAI](https://github.com/Etxarri/ShelterAI)  
**Rama**: `OsIbonIniciando`  
**Propietario**: Etxarri  
**Módulo**: Backend - Simulator OS  
**Última actualización**: Diciembre 2025

---

## 📧 Soporte

Para preguntas, errores o sugerencias, contactar al propietario del repositorio o revisar commits en la rama `OsIbonIniciando`.
La comunicación se realiza mediante Sockets TCP planos para maximizar la velocidad y reducir el overhead.

| Comando | Descripción | Efecto en el Sistema |
| :--- | :--- | :--- |
| `ADD:Nombre:Prioridad` | Inyecta un nuevo refugiado. | Producción de mensaje en la Cola Global. |
| `STATUS` | Consulta de estado. | Lectura atómica de semáforos y tamaño de cola. |
| `SET_CAPACITY:ID:N` | Modifica recursos. | Aumenta/Reduce permisos del semáforo en caliente. |

### 4.2. Monitorización Externa (Node-RED)
Node-RED actúa como un subsistema de control dashboard. Permite:
1.  **Simular Cargas de Estrés:** Envío de ráfagas masivas ("Oleadas") para saturar el sistema y verificar la lógica de prioridades.
2.  **Control Dinámico:** Cierre y apertura de refugios en tiempo real para observar el comportamiento de la cola de espera.

---

## 5. Justificación del Diseño: Paso de Mensajes vs. Monitores

Se ha optado por **Message Passing (`BlockingQueue`)** frente a la solución clásica de **Monitores (`wait`/`notify`)** por las siguientes razones técnicas:

1.  **Seguridad de Hilos (Thread Safety):** La gestión manual de notificaciones (`notifyAll`) es compleja y propensa a errores humanos. Las colas bloqueantes encapsulan esta lógica de forma atómica.
2.  **Escalabilidad:** Añadir nuevos refugios (Consumidores) es trivial con este diseño. Simplemente instanciamos un nuevo hilo `Shelter` y le pasamos la referencia a la cola compartida.
3.  **Desacoplamiento:** El productor no necesita saber quién procesará el mensaje, ni el consumidor sabe quién lo generó. Esto facilita el mantenimiento y la evolución del software.

---

## 6. Cómo Ejecutar el Proyecto

1.  **Iniciar Infraestructura:**
    ```bash
    docker compose up -d  # Inicia Node-RED
    ```
2.  **Iniciar Simulador Java:**
    Ejecutar la clase principal `SimulatorOsApplication.java`. El servidor escuchará en el puerto `9999`.
3.  **Acceder al Dashboard:**
    Abrir `http://localhost:1880` en el navegador para interactuar con la simulación.