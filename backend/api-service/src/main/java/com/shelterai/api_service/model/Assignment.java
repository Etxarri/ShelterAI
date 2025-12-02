package com.shelterai.api_service.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "assignments")
public class Assignment {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "refugee_id", nullable = false)
    private Refugee refugee;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shelter_id", nullable = false)
    private Shelter shelter;
    
    @Column(name = "assigned_at", nullable = false)
    private LocalDateTime assignedAt;
    
    @Column(name = "status", length = 50)
    private String status; // pending, confirmed, completed, cancelled
    
    @Column(name = "priority_score")
    private Double priorityScore;
    
    @Column(name = "explanation", length = 1000)
    private String explanation; // AI reasoning for the assignment
    
    @Column(name = "assigned_by", length = 100)
    private String assignedBy; // Username or "AI-System"
    
    @Column(name = "check_in_date")
    private LocalDateTime checkInDate;
    
    @Column(name = "check_out_date")
    private LocalDateTime checkOutDate;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public Assignment() {
        this.assignedAt = LocalDateTime.now();
        this.status = "pending";
    }
    
    public Assignment(Refugee refugee, Shelter shelter, String explanation) {
        this.refugee = refugee;
        this.shelter = shelter;
        this.explanation = explanation;
        this.assignedAt = LocalDateTime.now();
        this.status = "pending";
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Refugee getRefugee() {
        return refugee;
    }
    
    public void setRefugee(Refugee refugee) {
        this.refugee = refugee;
    }
    
    public Shelter getShelter() {
        return shelter;
    }
    
    public void setShelter(Shelter shelter) {
        this.shelter = shelter;
    }
    
    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }
    
    public void setAssignedAt(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Double getPriorityScore() {
        return priorityScore;
    }
    
    public void setPriorityScore(Double priorityScore) {
        this.priorityScore = priorityScore;
    }
    
    public String getExplanation() {
        return explanation;
    }
    
    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }
    
    public String getAssignedBy() {
        return assignedBy;
    }
    
    public void setAssignedBy(String assignedBy) {
        this.assignedBy = assignedBy;
    }
    
    public LocalDateTime getCheckInDate() {
        return checkInDate;
    }
    
    public void setCheckInDate(LocalDateTime checkInDate) {
        this.checkInDate = checkInDate;
    }
    
    public LocalDateTime getCheckOutDate() {
        return checkOutDate;
    }
    
    public void setCheckOutDate(LocalDateTime checkOutDate) {
        this.checkOutDate = checkOutDate;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
