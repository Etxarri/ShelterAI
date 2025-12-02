package com.shelterai.api_service.controller;

import com.shelterai.api_service.model.Assignment;
import com.shelterai.api_service.service.AssignmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/assignments")
public class AssignmentController {
    
    @Autowired
    private AssignmentService assignmentService;
    
    @GetMapping
    public ResponseEntity<List<Assignment>> getAllAssignments() {
        return ResponseEntity.ok(assignmentService.getAllAssignments());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Assignment> getAssignmentById(@PathVariable Long id) {
        return assignmentService.getAssignmentById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/refugee/{refugeeId}")
    public ResponseEntity<List<Assignment>> getAssignmentsByRefugee(@PathVariable Long refugeeId) {
        return ResponseEntity.ok(assignmentService.getAssignmentsByRefugee(refugeeId));
    }
    
    @GetMapping("/shelter/{shelterId}")
    public ResponseEntity<List<Assignment>> getAssignmentsByShelter(@PathVariable Long shelterId) {
        return ResponseEntity.ok(assignmentService.getAssignmentsByShelter(shelterId));
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Assignment>> getAssignmentsByStatus(@PathVariable String status) {
        return ResponseEntity.ok(assignmentService.getAssignmentsByStatus(status));
    }
    
    @PostMapping
    public ResponseEntity<Assignment> createAssignment(@RequestBody Assignment assignment) {
        Assignment createdAssignment = assignmentService.createAssignment(assignment);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdAssignment);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Assignment> updateAssignment(@PathVariable Long id, @RequestBody Assignment assignment) {
        try {
            Assignment updatedAssignment = assignmentService.updateAssignment(id, assignment);
            return ResponseEntity.ok(updatedAssignment);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAssignment(@PathVariable Long id) {
        assignmentService.deleteAssignment(id);
        return ResponseEntity.noContent().build();
    }
}
