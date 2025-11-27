package com.shelterai.api_service.repository;

import com.shelterai.api_service.model.Shelter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShelterRepository extends JpaRepository<Shelter, Long> {
    
    Optional<Shelter> findByName(String name);
    
    List<Shelter> findByCurrentOccupancyLessThan(Integer capacity);
    
    List<Shelter> findByMaxCapacityGreaterThanEqual(Integer minCapacity);
}
