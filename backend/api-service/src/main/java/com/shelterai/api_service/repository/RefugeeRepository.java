package com.shelterai.api_service.repository;

import com.shelterai.api_service.model.Refugee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RefugeeRepository extends JpaRepository<Refugee, Long> {
    
    List<Refugee> findByFamilyId(Long familyId);
    
    List<Refugee> findByVulnerabilityScoreGreaterThanEqual(Double score);
    
    List<Refugee> findByNationality(String nationality);
}
