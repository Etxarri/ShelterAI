package com.shelterai.api_service.service;

import com.shelterai.api_service.dto.RefugeeRequestDTO;
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
    
    public Refugee createRefugee(RefugeeRequestDTO dto) {
        Refugee refugee = new Refugee();
        refugee.setName(dto.getName());
        refugee.setCountryOfOrigin(dto.getCountryOfOrigin());
        refugee.setAge(dto.getAge());
        refugee.setGender(dto.getGender());
        refugee.setFamilySize(dto.getFamilySize());
        refugee.setHasChildren(dto.getHasChildren());
        refugee.setHasMedicalNeeds(dto.getHasMedicalNeeds());
        refugee.setMedicalConditions(dto.getMedicalConditions());
        refugee.setPreferredLanguage(dto.getPreferredLanguage());
        refugee.setHasDisabilities(dto.getHasDisabilities());
        
        if (dto.getUrgencyLevel() != null) {
            refugee.setUrgencyLevel(Refugee.UrgencyLevel.valueOf(dto.getUrgencyLevel()));
        }
        
        refugee.setCurrentLocation(dto.getCurrentLocation());
        refugee.setEmail(dto.getEmail());
        refugee.setPhoneNumber(dto.getPhoneNumber());
        
        return refugeeRepository.save(refugee);
    }
    
    public List<Refugee> getUnassignedRefugees() {
        return refugeeRepository.findByAssignedShelterIsNull();
    }
    
    public void deleteRefugee(Long id) {
        refugeeRepository.deleteById(id);
    }
}
