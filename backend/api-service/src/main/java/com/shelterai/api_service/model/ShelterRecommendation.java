package com.shelterai.api_service.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "shelter_recommendations")
public class ShelterRecommendation {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "refugee_id", nullable = false)
    private Refugee refugee;
    
    @ManyToOne
    @JoinColumn(name = "shelter_id", nullable = false)
    private Shelter shelter;
    
    @Column(name = "match_score")
    private Double matchScore; // 0-100 score from AI
    
    @Column(name = "recommendation_reason", length = 1000)
    private String recommendationReason;
    
    @Column(name = "distance_km")
    private Double distanceKm;
    
    @Column(name = "is_accepted")
    private Boolean isAccepted;
    
    @Column(name = "ai_model_version", length = 50)
    private String aiModelVersion;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    // Constructors
    public ShelterRecommendation() {
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
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
    
    public Double getMatchScore() {
        return matchScore;
    }
    
    public void setMatchScore(Double matchScore) {
        this.matchScore = matchScore;
    }
    
    public String getRecommendationReason() {
        return recommendationReason;
    }
    
    public void setRecommendationReason(String recommendationReason) {
        this.recommendationReason = recommendationReason;
    }
    
    public Double getDistanceKm() {
        return distanceKm;
    }
    
    public void setDistanceKm(Double distanceKm) {
        this.distanceKm = distanceKm;
    }
    
    public Boolean getIsAccepted() {
        return isAccepted;
    }
    
    public void setIsAccepted(Boolean isAccepted) {
        this.isAccepted = isAccepted;
    }
    
    public String getAiModelVersion() {
        return aiModelVersion;
    }
    
    public void setAiModelVersion(String aiModelVersion) {
        this.aiModelVersion = aiModelVersion;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
