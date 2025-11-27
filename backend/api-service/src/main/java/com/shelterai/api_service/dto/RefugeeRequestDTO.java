package com.shelterai.api_service.dto;

public class RefugeeRequestDTO {
    
    private String name;
    private String countryOfOrigin;
    private String age;
    private String gender;
    private Integer familySize;
    private Boolean hasChildren;
    private Boolean hasMedicalNeeds;
    private String medicalConditions;
    private String preferredLanguage;
    private Boolean hasDisabilities;
    private String urgencyLevel;
    private String currentLocation;
    private String email;
    private String phoneNumber;
    
    // Getters and Setters
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
    
    public String getUrgencyLevel() {
        return urgencyLevel;
    }
    
    public void setUrgencyLevel(String urgencyLevel) {
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
}
