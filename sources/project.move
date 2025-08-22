module MyModule::EmergencyResponse {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing an emergency incident
    struct Emergency has store, key {
        severity_level: u8,     // 1-5 scale (5 being most critical)
        resources_needed: u64,  // Amount of resources/funds needed
        resources_allocated: u64, // Resources currently allocated
        is_resolved: bool,      // Status of the emergency
    }

    /// Function to report a new emergency incident
    public fun report_emergency(
        coordinator: &signer, 
        severity_level: u8, 
        resources_needed: u64
    ) {
        // Ensure severity level is within valid range (1-5)
        assert!(severity_level >= 1 && severity_level <= 5, 1);
        assert!(resources_needed > 0, 2);

        let emergency = Emergency {
            severity_level,
            resources_needed,
            resources_allocated: 0,
            is_resolved: false,
        };
        move_to(coordinator, emergency);
    }

    /// Function to allocate resources to an emergency
    public fun allocate_resources(
        resource_provider: &signer,
        emergency_coordinator: address,
        amount: u64
    ) acquires Emergency {
        let emergency = borrow_global_mut<Emergency>(emergency_coordinator);
        
        // Ensure emergency is not already resolved
        assert!(!emergency.is_resolved, 3);
        
        // Transfer funds from provider to coordinator
        let resources = coin::withdraw<AptosCoin>(resource_provider, amount);
        coin::deposit<AptosCoin>(emergency_coordinator, resources);
        
        // Update allocated resources
        emergency.resources_allocated = emergency.resources_allocated + amount;
        
        // Mark as resolved if enough resources are allocated
        if (emergency.resources_allocated >= emergency.resources_needed) {
            emergency.is_resolved = true;
        };
    }
}



