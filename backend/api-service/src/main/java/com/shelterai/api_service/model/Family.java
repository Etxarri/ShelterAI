package com.shelterai.api_service.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "families")
public class Family {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "family_name", length = 100)
    private String familyName;
    
    @Column(name = "family_size")
    private Integer familySize;
    
    @Column(name = "head_of_family_id")
    private Long headOfFamilyId;
    
    @Column(name = "notes", length = 500)
    private String notes;
    
    @OneToMany(mappedBy = "family", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Refugee> members = new ArrayList<>();
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public Family() {
    }
    
    public Family(String familyName, Integer familySize) {
        this.familyName = familyName;
        this.familySize = familySize;
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
    
    public String getFamilyName() {
        return familyName;
    }
    
    public void setFamilyName(String familyName) {
        this.familyName = familyName;
    }
    
    public Integer getFamilySize() {
        return familySize;
    }
    
    public void setFamilySize(Integer familySize) {
        this.familySize = familySize;
    }
    
    public Long getHeadOfFamilyId() {
        return headOfFamilyId;
    }
    
    public void setHeadOfFamilyId(Long headOfFamilyId) {
        this.headOfFamilyId = headOfFamilyId;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public List<Refugee> getMembers() {
        return members;
    }
    
    public void setMembers(List<Refugee> members) {
        this.members = members;
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
