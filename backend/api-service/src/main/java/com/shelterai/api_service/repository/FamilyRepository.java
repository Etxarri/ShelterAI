package com.shelterai.api_service.repository;

import com.shelterai.api_service.model.Family;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FamilyRepository extends JpaRepository<Family, Long> {
    
    List<Family> findByFamilySize(Integer size);
    
    List<Family> findByFamilySizeGreaterThan(Integer size);
}
