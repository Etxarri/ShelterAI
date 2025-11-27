package com.shelterai.api_service.controller;

import com.shelterai.api_service.model.Shelter;
import com.shelterai.api_service.service.ShelterService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/shelters")
public class ShelterController {
    
    @Autowired
    private ShelterService shelterService;
    
    @GetMapping
    public ResponseEntity<List<Shelter>> getAllShelters() {
        return ResponseEntity.ok(shelterService.getAllShelters());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Shelter> getShelterById(@PathVariable Long id) {
        return shelterService.getShelterById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/available")
    public ResponseEntity<List<Shelter>> getAvailableShelters() {
        return ResponseEntity.ok(shelterService.getAvailableShelters());
    }
    
    @PostMapping
    public ResponseEntity<Shelter> createShelter(@RequestBody Shelter shelter) {
        Shelter createdShelter = shelterService.createShelter(shelter);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdShelter);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Shelter> updateShelter(@PathVariable Long id, @RequestBody Shelter shelter) {
        try {
            Shelter updatedShelter = shelterService.updateShelter(id, shelter);
            return ResponseEntity.ok(updatedShelter);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteShelter(@PathVariable Long id) {
        shelterService.deleteShelter(id);
        return ResponseEntity.noContent().build();
    }
}
