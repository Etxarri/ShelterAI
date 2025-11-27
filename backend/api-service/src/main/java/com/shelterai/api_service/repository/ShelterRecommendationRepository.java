package com.shelterai.api_service.repository;

import com.shelterai.api_service.model.Refugee;
import com.shelterai.api_service.model.ShelterRecommendation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShelterRecommendationRepository extends JpaRepository<ShelterRecommendation, Long> {
    
    List<ShelterRecommendation> findByRefugeeOrderByMatchScoreDesc(Refugee refugee);
    
    List<ShelterRecommendation> findByRefugeeIdOrderByMatchScoreDesc(Long refugeeId);
    
    List<ShelterRecommendation> findByIsAccepted(Boolean isAccepted);
}
