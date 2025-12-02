package com.shelterai.api_service.controller;

import com.shelterai.api_service.model.Refugee;
import com.shelterai.api_service.service.RefugeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/refugees")
public class RefugeeController {
    
    @Autowired
    private RefugeeService refugeeService;
    
    @GetMapping
    public ResponseEntity<List<Refugee>> getAllRefugees() {
        return ResponseEntity.ok(refugeeService.getAllRefugees());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Refugee> getRefugeeById(@PathVariable Long id) {
        return refugeeService.getRefugeeById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/family/{familyId}")
    public ResponseEntity<List<Refugee>> getRefugeesByFamily(@PathVariable Long familyId) {
        return ResponseEntity.ok(refugeeService.getRefugeesByFamily(familyId));
    }
    
    @GetMapping("/high-vulnerability")
    public ResponseEntity<List<Refugee>> getHighVulnerabilityRefugees(@RequestParam(defaultValue = "7.0") Double minScore) {
        return ResponseEntity.ok(refugeeService.getHighVulnerabilityRefugees(minScore));
    }
    
    @PostMapping
    public ResponseEntity<Refugee> createRefugee(@RequestBody Refugee refugee) {
        Refugee createdRefugee = refugeeService.createRefugee(refugee);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdRefugee);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Refugee> updateRefugee(@PathVariable Long id, @RequestBody Refugee refugee) {
        try {
            Refugee updatedRefugee = refugeeService.updateRefugee(id, refugee);
            return ResponseEntity.ok(updatedRefugee);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRefugee(@PathVariable Long id) {
        refugeeService.deleteRefugee(id);
        return ResponseEntity.noContent().build();
    }
}
