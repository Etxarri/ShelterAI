package com.shelterai.api_service.repository;

import com.shelterai.api_service.model.Assignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AssignmentRepository extends JpaRepository<Assignment, Long> {
    
    List<Assignment> findByRefugeeId(Long refugeeId);
    
    List<Assignment> findByShelterId(Long shelterId);
    
    List<Assignment> findByStatus(String status);
}
