-- Create Attributes

-- Electric Range
SELECT dbo.create_attribute('Mixed WLTP Range', 'Electric Range', 'km', true, true, true);
SELECT dbo.create_attribute('City WLTP Range', 'Electric Range', 'km', true, true, true);
SELECT dbo.create_attribute('Combined Cycle Consumption', 'Electric Range', 'kWh/100km', true, true, true);

-- PERFORMANCE
SELECT dbo.create_attribute('Max Power', 'Performance', 'kW (hp)', true, true, true);
SELECT dbo.create_attribute('Max Torque', 'Performance', 'Nm', true, true, true);
SELECT dbo.create_attribute('Max Speed', 'Performance', 'km/h', true, true, true);
SELECT dbo.create_attribute('0 - 100 km/h Time', 'Performance', 's', true, true, true);
SELECT dbo.create_attribute('0 - 50 km/h Time', 'Performance', 's', true, true, true);

-- TRANSMISSION
SELECT dbo.create_attribute('Number of Gears', 'Transmission', '-', true, true, true);

-- BATTERY
SELECT dbo.create_attribute('Gross Capacity', 'Battery', 'kWh', true, true, true);
SELECT dbo.create_attribute('Usable Capacity', 'Battery', 'kWh', true, true, true);
SELECT dbo.create_attribute('Technology', 'Battery', '-', true, true, true);
SELECT dbo.create_attribute('Voltage', 'Battery', 'V', true, true, true);
SELECT dbo.create_attribute('Battery Weight', 'Battery', 'kg', true, true, true);

-- CHARGING TIME
SELECT dbo.create_attribute('Home Outlet 3 kW AC 13A 0-100%', 'Charging', 'min', true, true, true);
SELECT dbo.create_attribute('Public Charging 11 kW AC 16A 0-100%', 'Charging', 'min', true, true, true);
SELECT dbo.create_attribute('Fast Charge 50 kW DC 0-80%', 'Charging', 'min', true, true, true);
SELECT dbo.create_attribute('Fast Charge 85 kW DC 0-80%', 'Charging', 'min', true, true, true);

-- DIMENSIONS
SELECT dbo.create_attribute('Length', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Height', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Width with Mirrors Folded', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Width with Mirrors', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Wheelbase', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Trunk Volume', 'Dimensions', 'l', true, true, true);
SELECT dbo.create_attribute('Turning Diameter', 'Dimensions', 'm', true, true, true);

-- WHEELS AND TIRES
SELECT dbo.create_attribute('Tire Size', 'Wheels and Tires', '-', true, true, true);
SELECT dbo.create_attribute('Wheel Size', 'Wheels and Tires', 'in', true, true, true);
SELECT dbo.create_attribute('Wheel Type', 'Wheels and Tires', '-', true, true, true);

-- WEIGHT
SELECT dbo.create_attribute('Unladen Weight', 'Weight', 'kg', true, true, true);

-- SAFETY
SELECT dbo.create_attribute('Airbags', 'Safety', '-', true, true, true);

SELECT dbo.create_attribute('Climate Control Zones', 'Interior', '-', true, true, true);
SELECT dbo.create_attribute('Speakers', 'Connectivity', '-', true, true, true);
SELECT dbo.create_attribute('Dashboard Instrumentation Screen Size', 'Connectivity', 'in', true, true, true);
SELECT dbo.create_attribute('Infotainment System Screen Size', 'Connectivity', 'in', true, true, true);
SELECT dbo.create_attribute('Dashboard Color', 'Interior', '-', true, true, true);
SELECT dbo.create_attribute('', '', '-', true, true, true);
SELECT dbo.create_attribute('', '', '-', true, true, true);
SELECT dbo.create_attribute('', '', '-', true, true, true);

-- Create Features

-- STYLE & DESIGN
SELECT dbo.create_feature('Body-colored Painted Bumpers', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Hidden Door Handles', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Body-colored Mirror Caps', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('15" Steel Wheels', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('16" Icon Alloy Wheels', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('17" Bi-color Alloy Wheels', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Chrome Side Strips', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Chrome Window Trim', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Door Sills', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Chrome Door Sills', 'Exterior', null, true, true, true);

-- SAFETY
SELECT dbo.create_feature('ABS with EBD', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Lane Departure Warning with Correction', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Emergency Call e-Call', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Light Sensors', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Driver Fatigue Detection', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Power Steering', 'Safety', null, true, true, true);
SELECT dbo.create_feature('ESP with Hill Holder', 'Safety', null, true, true, true);
SELECT dbo.create_feature('LED Daytime Running Lights', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Electric Parking Brake', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Autonomous Emergency Braking', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Speed Limiter', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Traffic Sign Recognition', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Cruise Control', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Rain Sensors', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Intelligent Speed Limiter', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Automatic High/Low Beam Headlights', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Full LED Infinity Headlights', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Photochromatic Interior Mirror', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Rearview Camera', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Lane Keeping Assist', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Adaptive Cruise Control', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Blind Spot Detection', 'Safety', null, true, true, true);
SELECT dbo.create_feature('360° Radars with Drone View', 'Safety', null, true, true, true);


-- INTERIOR
SELECT dbo.create_feature('Electric Front Windows', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Height-Adjustable Steering Wheel', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Depth-Adjustable Steering Wheel', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Driver Seat with 4-Way Adjustment', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Driver Seat with 6-Way Adjustment', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Wireless Phone Charger', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Heated Front Seats', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Glove Box with UV-C Disinfecting Light', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Automatic Single-Zone Climate Control', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Automatic Dual-Zone Climate Control', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Center Armrest', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Closed Central Console', 'Interior', null, true, true, true);
SELECT dbo.create_feature('50/50 Split-Folding Rear Bench', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Panoramic Glass Roof', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Floor Mats', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Steering Wheel with Controls', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Soft-touch Steering Wheel with Controls', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Bi-color Soft-touch Steering Wheel with Controls', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Electrically Adjustable Exterior Mirrors', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Heated Windshield', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Keyless Entry (Driver Side)', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Keyless Start', 'Interior', null, true, true, true);

-- SOUND & CONNECTIVITY
SELECT dbo.create_feature('Smartphone Holder', 'Connectivity', null, true, true, true);
SELECT dbo.create_feature('Uconnect 7" DAB System', 'Connectivity', null, true, true, true);
SELECT dbo.create_feature('Uconnect 10.25" DAB System with Navigation', 'Connectivity', null, true, true, true);
SELECT dbo.create_feature('Wireless Apple CarPlay / Android Auto', 'Connectivity', null, true, true, true);
SELECT dbo.create_feature('Mopar Connect Box', 'Connectivity', null, true, true, true);

-- ELECTRIC VEHICLE EQUIPMENT
SELECT dbo.create_feature('Type 2 Mode 2 Charging Cable (Home Charging)', 'Charging', null, true, true, true);
SELECT dbo.create_feature('Onboard AC Mono-Triphasé Charger up to 11 kW', 'Charging', null, true, true, true);
SELECT dbo.create_feature('DC Fast Charging up to 50 kW', 'Charging', null, true, true, true);
SELECT dbo.create_feature('DC Fast Charging up to 85 kW', 'Charging', null, true, true, true);
SELECT dbo.create_feature('EV Drive Mode Selector', 'Charging', null, true, true, true);
SELECT dbo.create_feature('Pedestrian Alert System', 'Charging', null, true, true, true);
SELECT dbo.create_feature('Type 2 Mode 3 Charging Cable (Wallbox & Public Charging)', 'Charging', null, true, true, true);


-- BASE HIERARCHY --
DO 
$$
DECLARE
    v_fiat dbo.entity_key;
    v_500 dbo.entity_key;
    v_500_red dbo.entity_key;
    v_500_la_prima dbo.entity_key;
    v_500_op_confort dbo.entity_key;
    v_500_op_style dbo.entity_key;
BEGIN
    v_fiat := dbo.create_entity('Fiat', 'Brand', null::dbo.entity_key, false, true);
    v_500 := dbo.create_entity('500e', 'Model', v_fiat, true, true);
    v_500_red := dbo.create_entity('500e (RED)', 'Variant', v_500, false, true);
    v_500_la_prima := dbo.create_entity('500e La Prima', 'Variant', v_500_red, false, true);

    v_500_op_confort := dbo.create_option_pack(
        v_500_red, 
        'Pack Confort', 
        ARRAY[
            'Center Armrest',
            '50/50 Split-Folding Rear Bench',
            'Blind Spot Detection',
            'Heated Windshield',
            '360° Radars with Drone View',
            'Electrically Adjustable Exterior Mirrors',
            'Heated Front Seats'
        ]);

    v_500_op_style := dbo.create_option_pack(
        v_500_red,
        'Pack Style', 
        ARRAY[
            'Chrome Window Trim',
            '16" Icon Alloy Wheels',
            'Full LED Infinity Headlights',
            'Chrome Door Sills'
        ]);

    /*
    • 6 Airbags -> att
    • 6 haut-parleurs -> att
    • Alerte de franchissement de ligne
    • Appel dʼurgence e-Call
    • Apple CarPlay & Android Auto sans fil 
    • Câble de recharge Mode 3 (recharge publique & wallbox)
    • Caméra de recul
    • Capteurs de pluie & luminosité 
    • Chargeur embarqué 11 kW (AC)
    • Climatisation automatique 
    • Démarrage sans clé
    • Détecteur de fatigue
    • Écran TFT 7” couleur -> att
    • Feux de jour à LED
    • Frein à main électrique 
    • Freinage autonome dʼurgence 
    • Jantes acier 15” -> size et type en att
    • Planche de bord rouge -> att
    • Reconnaissance des panneaux
    • Régulateur & limiteur de vitesse
    • Système Uconnect TM 10,25” -> att
    • Volant noir soft touch

    battery specific:
    • Recharge rapide 50 kW (DC) (petite batterie)
    • Recharge rapide 85 kW (DC) (grosse batterie)

    */
    
    PERFORM dbo.assign_entity_features(
        v_500_red,
        ARRAY[
            ('Lane Keeping Assist', null)::dbo.pair_real,
            ('Emergency Call e-Call', null)::dbo.pair_real,
            ('Wireless Apple CarPlay / Android Auto', null)::dbo.pair_real,
            ('Type 2 Mode 3 Charging Cable (Wallbox & Public Charging)', null)::dbo.pair_real,
            ('Rearview Camera', null)::dbo.pair_real,
            ('Light Sensors', null)::dbo.pair_real,
            ('Rain Sensors', null)::dbo.pair_real,
            ('Onboard AC Mono-Triphasé Charger up to 11 kW', null)::dbo.pair_real,
            ('Automatic Climate Control', null)::dbo.pair_real,
            ('Keyless Start', null)::dbo.pair_real,
            ('Driver Fatigue Detection', null)::dbo.pair_real,
            ('LED Daytime Running Lights', null)::dbo.pair_real,
            ('Electric Parking Brake', null)::dbo.pair_real,
            ('Autonomous Emergency Braking', null)::dbo.pair_real,
            ('15" Steel Wheels', null)::dbo.pair_real,
            ('Traffic Sign Recognition', null)::dbo.pair_real,
            ('Cruise Control', null)::dbo.pair_real,
            ('Speed Limiter', null)::dbo.pair_real,
            ('Soft-touch Steering Wheel with Controls', null)::dbo.pair_real
        ]);
END;
$$;
