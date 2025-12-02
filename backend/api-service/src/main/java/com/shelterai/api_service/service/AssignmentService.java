package com.shelterai.api_service.service;

import com.shelterai.api_service.model.Assignment;
import com.shelterai.api_service.repository.AssignmentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AssignmentService {
    
    @Autowired
    private AssignmentRepository assignmentRepository;
    
    public List<Assignment> getAllAssignments() {
        return assignmentRepository.findAll();
    }
    
    public Optional<Assignment> getAssignmentById(Long id) {
        return assignmentRepository.findById(id);
    }
    
    public Assignment createAssignment(Assignment assignment) {
        return assignmentRepository.save(assignment);
    }
    
    public Assignment updateAssignment(Long id, Assignment assignmentDetails) {
        Assignment assignment = assignmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Assignment not found with id: " + id));
        
        assignment.setStatus(assignmentDetails.getStatus());
        assignment.setPriorityScore(assignmentDetails.getPriorityScore());
        assignment.setExplanation(assignmentDetails.getExplanation());
        assignment.setAssignedBy(assignmentDetails.getAssignedBy());
        assignment.setCheckInDate(assignmentDetails.getCheckInDate());
        assignment.setCheckOutDate(assignmentDetails.getCheckOutDate());
        
        return assignmentRepository.save(assignment);
    }
    
    public void deleteAssignment(Long id) {
        assignmentRepository.deleteById(id);
    }
    
    public List<Assignment> getAssignmentsByRefugee(Long refugeeId) {
        return assignmentRepository.findByRefugeeId(refugeeId);
    }
    
    public List<Assignment> getAssignmentsByShelter(Long shelterId) {
        return assignmentRepository.findByShelterId(shelterId);
    }
    
    public List<Assignment> getAssignmentsByStatus(String status) {
        return assignmentRepository.findByStatus(status);
    }
}
