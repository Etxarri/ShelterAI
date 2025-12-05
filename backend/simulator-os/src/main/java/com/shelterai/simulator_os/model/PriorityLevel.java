package com.shelterai.simulator_os.model;

public enum PriorityLevel {
    ELDERLY(4),    // Máxima prioridad
    PREGNANT(3),
    CHILD(2),
    ADULT(1);      // Mínima prioridad

    private final int value;
    PriorityLevel(int value) { this.value = value; }
    public int getValue() { return value; }

    public static PriorityLevel fromString(String text) {
        if (text == null) return ADULT;
        switch (text.toUpperCase().trim()) {
            case "ANCIANO": case "ELDERLY": return ELDERLY;
            case "EMBARAZADA": case "PREGNANT": return PREGNANT;
            case "NINO": case "NIÑO": case "CHILD": return CHILD;
            default: return ADULT;
        }
    }
}
