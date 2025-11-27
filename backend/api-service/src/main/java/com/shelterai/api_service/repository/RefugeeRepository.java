package com.shelterai.api_service.repository;

import com.shelterai.api_service.model.Refugee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RefugeeRepository extends JpaRepository<Refugee, Long> {
    
    List<Refugee> findByAssignedShelterIsNull();
    
    List<Refugee> findByUrgencyLevel(Refugee.UrgencyLevel urgencyLevel);
    
    List<Refugee> findByCountryOfOrigin(String countryOfOrigin);
}
