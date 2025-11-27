package com.shelterai.api_service.service;

import com.shelterai.api_service.model.Refugee;
import com.shelterai.api_service.model.Shelter;
import com.shelterai.api_service.model.ShelterRecommendation;
import com.shelterai.api_service.repository.ShelterRecommendationRepository;
import com.shelterai.api_service.repository.ShelterRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class AIRecommendationService {
    
    @Autowired
    private ShelterRepository shelterRepository;
    
    @Autowired
    private ShelterRecommendationRepository recommendationRepository;
    
    /**
     * Generates AI-based shelter recommendations for a refugee
     * TODO: Integrate with trained AI model
     */
    public List<ShelterRecommendation> generateRecommendations(Refugee refugee) {
        List<Shelter> availableShelters = shelterRepository.findByCurrentOccupancyLessThan(
            shelterRepository.findAll().stream()
                .mapToInt(s -> s.getMaxCapacity() != null ? s.getMaxCapacity() : 0)
                .max()
                .orElse(100)
        );
        
        List<ShelterRecommendation> recommendations = new ArrayList<>();
        
        for (Shelter shelter : availableShelters) {
            if (shelter.getCurrentOccupancy() < shelter.getMaxCapacity()) {
                ShelterRecommendation recommendation = new ShelterRecommendation();
                recommendation.setRefugee(refugee);
                recommendation.setShelter(shelter);
                
                // Calculate match score based on refugee needs
                double matchScore = calculateMatchScore(refugee, shelter);
                recommendation.setMatchScore(matchScore);
                
                // Generate recommendation reason
                String reason = generateRecommendationReason(refugee, shelter, matchScore);
                recommendation.setRecommendationReason(reason);
                
                // Calculate distance (placeholder - implement with actual location data)
                recommendation.setDistanceKm(calculateDistance(refugee, shelter));
                
                recommendation.setAiModelVersion("1.0-rule-based");
                recommendation.setIsAccepted(false);
                
                recommendations.add(recommendationRepository.save(recommendation));
            }
        }
        
        // Sort by match score descending
        recommendations.sort((a, b) -> Double.compare(b.getMatchScore(), a.getMatchScore()));
        
        return recommendations.size() > 5 ? recommendations.subList(0, 5) : recommendations;
    }
    
    /**
     * Calculates match score between refugee and shelter
     * TODO: Replace with your trained AI model
     */
    private double calculateMatchScore(Refugee refugee, Shelter shelter) {
        double score = 50.0; // Base score
        
        // Medical needs matching
        if (refugee.getHasMedicalNeeds() != null && refugee.getHasMedicalNeeds() && 
            shelter.getHasMedicalFacilities() != null && shelter.getHasMedicalFacilities()) {
            score += 20.0;
        }
        
        // Children matching
        if (refugee.getHasChildren() != null && refugee.getHasChildren() && 
            shelter.getHasChildcare() != null && shelter.getHasChildcare()) {
            score += 15.0;
        }
        
        // Disability access matching
        if (refugee.getHasDisabilities() != null && refugee.getHasDisabilities() && 
            shelter.getHasDisabilityAccess() != null && shelter.getHasDisabilityAccess()) {
            score += 15.0;
        }
        
        // Language matching
        if (refugee.getPreferredLanguage() != null && shelter.getLanguagesSpoken() != null &&
            shelter.getLanguagesSpoken().contains(refugee.getPreferredLanguage())) {
            score += 10.0;
        }
        
        // Capacity availability
        int available = shelter.getMaxCapacity() - shelter.getCurrentOccupancy();
        if (refugee.getFamilySize() != null && available >= refugee.getFamilySize()) {
            score += 10.0;
        }
        
        // Urgency level adjustment
        if (refugee.getUrgencyLevel() == Refugee.UrgencyLevel.CRITICAL) {
            score += 5.0;
        }
        
        return Math.min(score, 100.0);
    }
    
    private String generateRecommendationReason(Refugee refugee, Shelter shelter, double matchScore) {
        StringBuilder reason = new StringBuilder("Recommended because: ");
        
        List<String> reasons = new ArrayList<>();
        
        if (refugee.getHasMedicalNeeds() != null && refugee.getHasMedicalNeeds() && 
            shelter.getHasMedicalFacilities() != null && shelter.getHasMedicalFacilities()) {
            reasons.add("has medical facilities for your needs");
        }
        
        if (refugee.getHasChildren() != null && refugee.getHasChildren() && 
            shelter.getHasChildcare() != null && shelter.getHasChildcare()) {
            reasons.add("provides childcare services");
        }
        
        if (refugee.getHasDisabilities() != null && refugee.getHasDisabilities() && 
            shelter.getHasDisabilityAccess() != null && shelter.getHasDisabilityAccess()) {
            reasons.add("has disability access");
        }
        
        if (refugee.getPreferredLanguage() != null && shelter.getLanguagesSpoken() != null &&
            shelter.getLanguagesSpoken().contains(refugee.getPreferredLanguage())) {
            reasons.add("staff speaks " + refugee.getPreferredLanguage());
        }
        
        int available = shelter.getMaxCapacity() - shelter.getCurrentOccupancy();
        reasons.add("has " + available + " spaces available");
        
        if (reasons.isEmpty()) {
            return "This shelter has availability and meets basic requirements.";
        }
        
        return reason.append(String.join(", ", reasons)).append(".").toString();
    }
    
    private double calculateDistance(Refugee refugee, Shelter shelter) {
        // TODO: Implement actual distance calculation using coordinates
        // For now, return a placeholder
        return Math.random() * 50; // 0-50 km
    }
}
