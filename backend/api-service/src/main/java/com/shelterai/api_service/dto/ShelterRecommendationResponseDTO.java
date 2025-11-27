package com.shelterai.api_service.dto;

import com.shelterai.api_service.model.Shelter;

public class ShelterRecommendationResponseDTO {
    
    private Long recommendationId;
    private Shelter shelter;
    private Double matchScore;
    private String recommendationReason;
    private Double distanceKm;
    
    public ShelterRecommendationResponseDTO(Long recommendationId, Shelter shelter, Double matchScore, 
                                           String recommendationReason, Double distanceKm) {
        this.recommendationId = recommendationId;
        this.shelter = shelter;
        this.matchScore = matchScore;
        this.recommendationReason = recommendationReason;
        this.distanceKm = distanceKm;
    }
    
    // Getters and Setters
    public Long getRecommendationId() {
        return recommendationId;
    }
    
    public void setRecommendationId(Long recommendationId) {
        this.recommendationId = recommendationId;
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
}
