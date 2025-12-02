package com.shelterai.api_service.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "refugees")
public class Refugee {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String firstName;
    
    @Column(nullable = false, length = 100)
    private String lastName;
    
    @Column(nullable = false)
    private Integer age;
    
    @Column(length = 10)
    private String gender; // M, F, Other
    
    @Column(length = 100)
    private String nationality;
    
    @Column(name = "languages_spoken", length = 200)
    private String languagesSpoken; // Comma-separated
    
    @Column(name = "medical_conditions", length = 500)
    private String medicalConditions;
    
    @Column(name = "has_disability")
    private Boolean hasDisability;
    
    @Column(name = "vulnerability_score")
    private Double vulnerabilityScore; // AI-calculated score
    
    @Column(name = "special_needs", length = 500)
    private String specialNeeds;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "family_id")
    private Family family;
    
    @OneToMany(mappedBy = "refugee", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Assignment> assignments = new ArrayList<>();
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // Constructors
    public Refugee() {
    }
    
    public Refugee(String firstName, String lastName, Integer age, String gender, String nationality) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.age = age;
        this.gender = gender;
        this.nationality = nationality;
        this.hasDisability = false;
        this.vulnerabilityScore = 0.0;
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
    
    public String getFirstName() {
        return firstName;
    }
    
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }
    
    public String getLastName() {
        return lastName;
    }
    
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
    
    public Integer getAge() {
        return age;
    }
    
    public void setAge(Integer age) {
        this.age = age;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public String getNationality() {
        return nationality;
    }
    
    public void setNationality(String nationality) {
        this.nationality = nationality;
    }
    
    public String getLanguagesSpoken() {
        return languagesSpoken;
    }
    
    public void setLanguagesSpoken(String languagesSpoken) {
        this.languagesSpoken = languagesSpoken;
    }
    
    public String getMedicalConditions() {
        return medicalConditions;
    }
    
    public void setMedicalConditions(String medicalConditions) {
        this.medicalConditions = medicalConditions;
    }
    
    public Boolean getHasDisability() {
        return hasDisability;
    }
    
    public void setHasDisability(Boolean hasDisability) {
        this.hasDisability = hasDisability;
    }
    
    public Double getVulnerabilityScore() {
        return vulnerabilityScore;
    }
    
    public void setVulnerabilityScore(Double vulnerabilityScore) {
        this.vulnerabilityScore = vulnerabilityScore;
    }
    
    public String getSpecialNeeds() {
        return specialNeeds;
    }
    
    public void setSpecialNeeds(String specialNeeds) {
        this.specialNeeds = specialNeeds;
    }
    
    public Family getFamily() {
        return family;
    }
    
    public void setFamily(Family family) {
        this.family = family;
    }
    
    public List<Assignment> getAssignments() {
        return assignments;
    }
    
    public void setAssignments(List<Assignment> assignments) {
        this.assignments = assignments;
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
