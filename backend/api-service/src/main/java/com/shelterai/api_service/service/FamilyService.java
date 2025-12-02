package com.shelterai.api_service.service;

import com.shelterai.api_service.model.Family;
import com.shelterai.api_service.repository.FamilyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FamilyService {
    
    @Autowired
    private FamilyRepository familyRepository;
    
    public List<Family> getAllFamilies() {
        return familyRepository.findAll();
    }
    
    public Optional<Family> getFamilyById(Long id) {
        return familyRepository.findById(id);
    }
    
    public Family createFamily(Family family) {
        return familyRepository.save(family);
    }
    
    public Family updateFamily(Long id, Family familyDetails) {
        Family family = familyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Family not found with id: " + id));
        
        family.setFamilyName(familyDetails.getFamilyName());
        family.setFamilySize(familyDetails.getFamilySize());
        family.setHeadOfFamilyId(familyDetails.getHeadOfFamilyId());
        family.setNotes(familyDetails.getNotes());
        
        return familyRepository.save(family);
    }
    
    public void deleteFamily(Long id) {
        familyRepository.deleteById(id);
    }
    
    public List<Family> getFamiliesBySize(Integer size) {
        return familyRepository.findByFamilySize(size);
    }
}
