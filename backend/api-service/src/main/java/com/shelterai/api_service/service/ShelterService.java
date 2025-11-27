package com.shelterai.api_service.service;

import com.shelterai.api_service.model.Shelter;
import com.shelterai.api_service.repository.ShelterRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ShelterService {
    
    @Autowired
    private ShelterRepository shelterRepository;
    
    public List<Shelter> getAllShelters() {
        return shelterRepository.findAll();
    }
    
    public Optional<Shelter> getShelterById(Long id) {
        return shelterRepository.findById(id);
    }
    
    public Shelter createShelter(Shelter shelter) {
        return shelterRepository.save(shelter);
    }
    
    public Shelter updateShelter(Long id, Shelter shelterDetails) {
        Shelter shelter = shelterRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shelter not found with id: " + id));
        
        shelter.setName(shelterDetails.getName());
        shelter.setAddress(shelterDetails.getAddress());
        shelter.setPhoneNumber(shelterDetails.getPhoneNumber());
        shelter.setEmail(shelterDetails.getEmail());
        shelter.setMaxCapacity(shelterDetails.getMaxCapacity());
        shelter.setCurrentOccupancy(shelterDetails.getCurrentOccupancy());
        
        return shelterRepository.save(shelter);
    }
    
    public void deleteShelter(Long id) {
        shelterRepository.deleteById(id);
    }
    
    public List<Shelter> getAvailableShelters() {
        return shelterRepository.findAll().stream()
                .filter(shelter -> shelter.getCurrentOccupancy() < shelter.getMaxCapacity())
                .toList();
    }
}
