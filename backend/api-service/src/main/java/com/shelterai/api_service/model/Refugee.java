package com.shelterai.api_service.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "refugees")
public class Refugee {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String name;
    
    @Column(name = "country_of_origin", length = 100)
    private String countryOfOrigin;
    
    @Column(length = 10)
    private String age;
    
    @Column(length = 20)
    private String gender;
    
    @Column(name = "family_size")
    private Integer familySize;
    
    @Column(name = "has_children")
    private Boolean hasChildren;
    
    @Column(name = "has_medical_needs")
    private Boolean hasMedicalNeeds;
    
    @Column(name = "medical_conditions", length = 500)
    private String medicalConditions;
    
    @Column(name = "preferred_language", length = 50)
    private String preferredLanguage;
    
    @Column(name = "has_disabilities")
    private Boolean hasDisabilities;
    
    @Column(name = "urgency_level")
    @Enumerated(EnumType.STRING)
    private UrgencyLevel urgencyLevel;
    
    @Column(name = "current_location", length = 200)
    private String currentLocation;
    
    @Column(length = 100)
    private String email;
    
    @Column(name = "phone_number", length = 20)
    private String phoneNumber;
    
    @ManyToOne
    @JoinColumn(name = "assigned_shelter_id")
    private Shelter assignedShelter;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public enum UrgencyLevel {
        LOW, MEDIUM, HIGH, CRITICAL
    }
    
    // Constructors
    public Refugee() {
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
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getCountryOfOrigin() {
        return countryOfOrigin;
    }
    
    public void setCountryOfOrigin(String countryOfOrigin) {
        this.countryOfOrigin = countryOfOrigin;
    }
    
    public String getAge() {
        return age;
    }
    
    public void setAge(String age) {
        this.age = age;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public Integer getFamilySize() {
        return familySize;
    }
    
    public void setFamilySize(Integer familySize) {
        this.familySize = familySize;
    }
    
    public Boolean getHasChildren() {
        return hasChildren;
    }
    
    public void setHasChildren(Boolean hasChildren) {
        this.hasChildren = hasChildren;
    }
    
    public Boolean getHasMedicalNeeds() {
        return hasMedicalNeeds;
    }
    
    public void setHasMedicalNeeds(Boolean hasMedicalNeeds) {
        this.hasMedicalNeeds = hasMedicalNeeds;
    }
    
    public String getMedicalConditions() {
        return medicalConditions;
    }
    
    public void setMedicalConditions(String medicalConditions) {
        this.medicalConditions = medicalConditions;
    }
    
    public String getPreferredLanguage() {
        return preferredLanguage;
    }
    
    public void setPreferredLanguage(String preferredLanguage) {
        this.preferredLanguage = preferredLanguage;
    }
    
    public Boolean getHasDisabilities() {
        return hasDisabilities;
    }
    
    public void setHasDisabilities(Boolean hasDisabilities) {
        this.hasDisabilities = hasDisabilities;
    }
    
    public UrgencyLevel getUrgencyLevel() {
        return urgencyLevel;
    }
    
    public void setUrgencyLevel(UrgencyLevel urgencyLevel) {
        this.urgencyLevel = urgencyLevel;
    }
    
    public String getCurrentLocation() {
        return currentLocation;
    }
    
    public void setCurrentLocation(String currentLocation) {
        this.currentLocation = currentLocation;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public Shelter getAssignedShelter() {
        return assignedShelter;
    }
    
    public void setAssignedShelter(Shelter assignedShelter) {
        this.assignedShelter = assignedShelter;
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
