package com.shelterai.api_service.controller;

import com.shelterai.api_service.model.Family;
import com.shelterai.api_service.service.FamilyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/families")
public class FamilyController {
    
    @Autowired
    private FamilyService familyService;
    
    @GetMapping
    public ResponseEntity<List<Family>> getAllFamilies() {
        return ResponseEntity.ok(familyService.getAllFamilies());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Family> getFamilyById(@PathVariable Long id) {
        return familyService.getFamilyById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/size/{size}")
    public ResponseEntity<List<Family>> getFamiliesBySize(@PathVariable Integer size) {
        return ResponseEntity.ok(familyService.getFamiliesBySize(size));
    }
    
    @PostMapping
    public ResponseEntity<Family> createFamily(@RequestBody Family family) {
        Family createdFamily = familyService.createFamily(family);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdFamily);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Family> updateFamily(@PathVariable Long id, @RequestBody Family family) {
        try {
            Family updatedFamily = familyService.updateFamily(id, family);
            return ResponseEntity.ok(updatedFamily);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFamily(@PathVariable Long id) {
        familyService.deleteFamily(id);
        return ResponseEntity.noContent().build();
    }
}
