package com.shelterai.api_service.controller;

import com.shelterai.api_service.dto.RefugeeRequestDTO;
import com.shelterai.api_service.dto.ShelterRecommendationResponseDTO;
import com.shelterai.api_service.model.Refugee;
import com.shelterai.api_service.model.ShelterRecommendation;
import com.shelterai.api_service.service.AIRecommendationService;
import com.shelterai.api_service.service.RefugeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/refugees")
public class RefugeeController {
    
    @Autowired
    private RefugeeService refugeeService;
    
    @Autowired
    private AIRecommendationService aiRecommendationService;
    
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
    
    @GetMapping("/unassigned")
    public ResponseEntity<List<Refugee>> getUnassignedRefugees() {
        return ResponseEntity.ok(refugeeService.getUnassignedRefugees());
    }
    
    @PostMapping
    public ResponseEntity<Refugee> createRefugee(@RequestBody RefugeeRequestDTO refugeeDTO) {
        Refugee createdRefugee = refugeeService.createRefugee(refugeeDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdRefugee);
    }
    
    /**
     * Main endpoint: Get AI-powered shelter recommendations for a refugee
     */
    @PostMapping("/{id}/recommendations")
    public ResponseEntity<List<ShelterRecommendationResponseDTO>> getShelterRecommendations(@PathVariable Long id) {
        return refugeeService.getRefugeeById(id)
                .map(refugee -> {
                    List<ShelterRecommendation> recommendations = aiRecommendationService.generateRecommendations(refugee);
                    
                    List<ShelterRecommendationResponseDTO> response = recommendations.stream()
                            .map(rec -> new ShelterRecommendationResponseDTO(
                                    rec.getId(),
                                    rec.getShelter(),
                                    rec.getMatchScore(),
                                    rec.getRecommendationReason(),
                                    rec.getDistanceKm()
                            ))
                            .collect(Collectors.toList());
                    
                    return ResponseEntity.ok(response);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRefugee(@PathVariable Long id) {
        refugeeService.deleteRefugee(id);
        return ResponseEntity.noContent().build();
    }
}
