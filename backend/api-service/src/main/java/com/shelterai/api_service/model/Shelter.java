package com.shelterai.api_service.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "shelters")
public class Shelter {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String name;
    
    @Column(length = 500)
    private String address;
    
    @Column(name = "phone_number", length = 20)
    private String phoneNumber;
    
    @Column(length = 100)
    private String email;
    
    @Column(name = "max_capacity")
    private Integer maxCapacity;
    
    @Column(name = "current_occupancy")
    private Integer currentOccupancy;
    
    @Column(name = "has_medical_facilities")
    private Boolean hasMedicalFacilities;
    
    @Column(name = "has_childcare")
    private Boolean hasChildcare;
    
    @Column(name = "has_disability_access")
    private Boolean hasDisabilityAccess;
    
    @Column(name = "languages_spoken", length = 200)
    private String languagesSpoken; // Comma-separated list
    
    @Column(name = "latitude")
    private Double latitude;
    
    @Column(name = "longitude")
    private Double longitude;
    
    @Column(name = "shelter_type", length = 50)
    private String shelterType; // temporary, long-term, emergency
    
    @Column(name = "services_offered", length = 500)
    private String servicesOffered; // Comma-separated list
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public Shelter() {
    }
    
    public Shelter(String name, String address, String phoneNumber, String email, Integer maxCapacity) {
        this.name = name;
        this.address = address;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.maxCapacity = maxCapacity;
        this.currentOccupancy = 0;
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
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public Integer getMaxCapacity() {
        return maxCapacity;
    }
    
    public void setMaxCapacity(Integer maxCapacity) {
        this.maxCapacity = maxCapacity;
    }
    
    public Integer getCurrentOccupancy() {
        return currentOccupancy;
    }
    
    public void setCurrentOccupancy(Integer currentOccupancy) {
        this.currentOccupancy = currentOccupancy;
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
    
    public Boolean getHasMedicalFacilities() {
        return hasMedicalFacilities;
    }
    
    public void setHasMedicalFacilities(Boolean hasMedicalFacilities) {
        this.hasMedicalFacilities = hasMedicalFacilities;
    }
    
    public Boolean getHasChildcare() {
        return hasChildcare;
    }
    
    public void setHasChildcare(Boolean hasChildcare) {
        this.hasChildcare = hasChildcare;
    }
    
    public Boolean getHasDisabilityAccess() {
        return hasDisabilityAccess;
    }
    
    public void setHasDisabilityAccess(Boolean hasDisabilityAccess) {
        this.hasDisabilityAccess = hasDisabilityAccess;
    }
    
    public String getLanguagesSpoken() {
        return languagesSpoken;
    }
    
    public void setLanguagesSpoken(String languagesSpoken) {
        this.languagesSpoken = languagesSpoken;
    }
    
    public Double getLatitude() {
        return latitude;
    }
    
    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }
    
    public Double getLongitude() {
        return longitude;
    }
    
    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }
    
    public String getShelterType() {
        return shelterType;
    }
    
    public void setShelterType(String shelterType) {
        this.shelterType = shelterType;
    }
    
    public String getServicesOffered() {
        return servicesOffered;
    }
    
    public void setServicesOffered(String servicesOffered) {
        this.servicesOffered = servicesOffered;
    }
}
