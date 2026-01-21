package com.shelterai.simulator_os.model;

public enum PriorityLevel {
    ELDERLY(4),
    PREGNANT(3),
    CHILD(2),
    ADULT(1);     

    private final int value;
    PriorityLevel(int value) { this.value = value; }
    public int getValue() { return value; }

    public static PriorityLevel fromString(String text) {
        if (text == null) return ADULT;
        switch (text.toUpperCase().trim()) {
            case "ELDERLY": return ELDERLY;
            case "PREGNANT": return PREGNANT;
            case "CHILD": return CHILD;
            default: return ADULT;
        }
    }
}
