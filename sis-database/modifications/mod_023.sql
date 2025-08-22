-- OBJECT: property_phys_chem
-- ISSUE: phys_chem property name: 'Sodium (Na+) - exchangeable %' unit: 'cmol/kg'. Remove the % in the name


UPDATE core.property_phys_chem SET property_phys_chem_id = 'Sodium (Na+) - exchangeable' WHERE property_phys_chem_id = 'Sodium (Na+) - exchangeable %';
