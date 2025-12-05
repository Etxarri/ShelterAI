package com.shelterai.simulator_os.model;

public class Refugee implements Comparable<Refugee> {
    private String id;
    private PriorityLevel priority;
    private long arrivalTime;
    private int processingTimeMs;

    public Refugee(String id, PriorityLevel priority, int processingTimeMs) {
        this.id = id;
        this.priority = priority;
        this.arrivalTime = System.currentTimeMillis();
        this.processingTimeMs = processingTimeMs;
    }

    public String getId() { return id; }
    public PriorityLevel getPriority() { return priority; }
    public int getProcessingTimeMs() { return processingTimeMs; }

    @Override
    public int compareTo(Refugee other) {
        // Lógica clave: Mayor prioridad va antes. Si empate, el que llegó antes.
        if (this.priority.getValue() != other.priority.getValue()) {
            return other.priority.getValue() - this.priority.getValue();
        }
        return Long.compare(this.arrivalTime, other.arrivalTime);
    }
}
