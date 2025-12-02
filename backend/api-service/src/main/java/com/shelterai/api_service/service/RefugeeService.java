package com.shelterai.api_service.service;

import com.shelterai.api_service.model.Refugee;
import com.shelterai.api_service.repository.RefugeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class RefugeeService {
    
    @Autowired
    private RefugeeRepository refugeeRepository;
    
    public List<Refugee> getAllRefugees() {
        return refugeeRepository.findAll();
    }
    
    public Optional<Refugee> getRefugeeById(Long id) {
        return refugeeRepository.findById(id);
    }
    
    public Refugee createRefugee(Refugee refugee) {
        return refugeeRepository.save(refugee);
    }
    
    public Refugee updateRefugee(Long id, Refugee refugeeDetails) {
        Refugee refugee = refugeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Refugee not found with id: " + id));
        
        refugee.setFirstName(refugeeDetails.getFirstName());
        refugee.setLastName(refugeeDetails.getLastName());
        refugee.setAge(refugeeDetails.getAge());
        refugee.setGender(refugeeDetails.getGender());
        refugee.setNationality(refugeeDetails.getNationality());
        refugee.setLanguagesSpoken(refugeeDetails.getLanguagesSpoken());
        refugee.setMedicalConditions(refugeeDetails.getMedicalConditions());
        refugee.setHasDisability(refugeeDetails.getHasDisability());
        refugee.setVulnerabilityScore(refugeeDetails.getVulnerabilityScore());
        refugee.setSpecialNeeds(refugeeDetails.getSpecialNeeds());
        
        return refugeeRepository.save(refugee);
    }
    
    public void deleteRefugee(Long id) {
        refugeeRepository.deleteById(id);
    }
    
    public List<Refugee> getRefugeesByFamily(Long familyId) {
        return refugeeRepository.findByFamilyId(familyId);
    }
    
    public List<Refugee> getHighVulnerabilityRefugees(Double minScore) {
        return refugeeRepository.findByVulnerabilityScoreGreaterThanEqual(minScore);
    }
}
