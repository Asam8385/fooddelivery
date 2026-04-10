
-- Chapter 3: Thames Freight Rail (TFR) - Sample Data
-- Target: Microsoft SQL Server (T-SQL)
-- Run AFTER chapter2_create_tables.sql


USE ThamesFreightRail;



-- 1. LOCOMOTIVE CLASSES

INSERT INTO LocomotiveClass (ClassID, ClassName, SerialPrefix, MaxTowingWeightTonnes, LengthMetres) VALUES
(7, 'Class 07', '07', 1500.0, 16.4),
(8, 'Class 08', '08', 1600.0, 17.8),
(9, 'Class 09', '09', 2000.0, 21.4);



-- 2. LOCOMOTIVES (13 total: 5 + 5 + 3)

INSERT INTO Locomotive (SerialNumber, ClassID, FamiliarName) VALUES
('07100', 7, NULL),
('07101', 7, 'Red Arrow'),
('07102', 7, NULL),
('07103', 7, 'Tug'),
('07104', 7, NULL),
('08200', 8, NULL),
('08201', 8, 'Buckets'),
('08202', 8, NULL),
('08203', 8, NULL),
('08204', 8, NULL),
('09001', 9, 'Rapid Bullet'),
('09002', 9, NULL),
('09003', 9, NULL);



-- 3. WAN TYPES

INSERT INTO WanType (TypeID, TypeName, SerialPrefix, Description, TareWeightTonnes, MaxPayloadTonnes, LengthMetres) VALUES
(90, 'Flat wan',    '90', 'A low-sided open wan for the transportation of cable drums and machinery.',                    21.0, 66.0, 14.6),
(91, 'Open wan',    '91', 'A high-sided open-box wan for the transportation of scrap steel.',                             33.0, 69.0, 16.2),
(92, 'Covered wan', '92', 'A plastic sheeting covered wan for the transportation of palletised ods and general car.', 23.5, 66.5, 20.6),
(93, 'Car carrier',   '93', 'A covered wan for the transportation of cars and vans.',                                       35.0, 15.0, 24.3),
(94, 'Tank wan',    '94', 'A stainless steel chemical tank for the transportation of petroleum and industrial products.',    27.3, 62.7, 18.9);



-- 4. FREIGHT WANS (65 sample wans)


-- Flat wans (10 of 30 owned)
INSERT INTO FreightWan (SerialNumber, TypeID) VALUES
('90001', 90), ('90002', 90), ('90003', 90), ('90004', 90), ('90005', 90),
('90006', 90), ('90007', 90), ('90008', 90), ('90009', 90), ('90010', 90);

-- Open wans (10 of 30 owned)
INSERT INTO FreightWan (SerialNumber, TypeID) VALUES
('91001', 91), ('91002', 91), ('91003', 91), ('91004', 91), ('91005', 91),
('91006', 91), ('91007', 91), ('91008', 91), ('91009', 91), ('91010', 91);

-- Covered wans (15 of 40 owned)
INSERT INTO FreightWan (SerialNumber, TypeID) VALUES
('92001', 92), ('92002', 92), ('92003', 92), ('92004', 92), ('92005', 92),
('92006', 92), ('92007', 92), ('92008', 92), ('92009', 92), ('92010', 92),
('92011', 92), ('92012', 92), ('92013', 92), ('92014', 92), ('92015', 92);

-- Car carriers (10 of 15 owned)
INSERT INTO FreightWan (SerialNumber, TypeID) VALUES
('93001', 93), ('93002', 93), ('93003', 93), ('93004', 93), ('93005', 93),
('93006', 93), ('93007', 93), ('93008', 93), ('93009', 93), ('93010', 93);

-- Tank wans (20 of 20 owned)
INSERT INTO FreightWan (SerialNumber, TypeID) VALUES
('94001', 94), ('94002', 94), ('94003', 94), ('94004', 94), ('94005', 94),
('94006', 94), ('94007', 94), ('94008', 94), ('94009', 94), ('94010', 94),
('94011', 94), ('94012', 94), ('94013', 94), ('94014', 94), ('94015', 94),
('94016', 94), ('94017', 94), ('94018', 94), ('94019', 94), ('94020', 94);



-- 5. STATIONS (20 stations on the TFR network)

SET IDENTITY_INSERT Station ON;
INSERT INTO Station (StationID, StationName) VALUES
(1,  'Plymouth'),
(2,  'Exeter'),
(3,  'Taunton'),
(4,  'Bristol'),
(5,  'Cardiff'),
(6,  'Swansea'),
(7,  'Birmingham'),
(8,  'Rugby'),
(9,  'London Euston'),
(10, 'Crewe'),
(11, 'Manchester'),
(12, 'Sheffield'),
(13, 'Leeds'),
(14, 'York'),
(15, 'Newcastle'),
(16, 'Edinburgh'),
(17, 'Glasw'),
(18, 'Preston'),
(19, 'Carlisle'),
(20, 'Nottingham');
SET IDENTITY_INSERT Station OFF;



-- 6. STAGES (network connections with distances in miles)
-- Each stage stored once; queries handle bidirectionality.

INSERT INTO Stage (StartStationID, EndStationID, DistanceMiles) VALUES
(1,  2,  57.0),   -- Plymouth - Exeter
(2,  3,  45.0),   -- Exeter - Taunton
(3,  4,  45.0),   -- Taunton - Bristol
(4,  5,  40.0),   -- Bristol - Cardiff
(5,  6,  45.0),   -- Cardiff - Swansea
(4,  7,  62.0),   -- Bristol - Birmingham
(7,  8,  34.0),   -- Birmingham - Rugby
(8,  9,  82.0),   -- Rugby - London Euston
(7,  10, 50.0),   -- Birmingham - Crewe
(10, 11, 36.0),   -- Crewe - Manchester
(7,  12, 75.0),   -- Birmingham - Sheffield
(12, 13, 35.0),   -- Sheffield - Leeds
(13, 14, 25.0),   -- Leeds - York
(14, 15, 80.0),   -- York - Newcastle
(15, 16, 125.0),  -- Newcastle - Edinburgh
(16, 17, 47.0),   -- Edinburgh - Glasw
(10, 18, 46.0),   -- Crewe - Preston
(18, 19, 90.0),   -- Preston - Carlisle
(19, 17, 100.0),  -- Carlisle - Glasw
(7,  20, 50.0),   -- Birmingham - Nottingham
(11, 13, 43.0);   -- Manchester - Leeds



-- 7. ODS TYPES

SET IDENTITY_INSERT odsType ON;
INSERT INTO odsType (odsTypeID, Description, UnitWeightTonnes, UnitVolumeCubicMetres) VALUES
(1, 'Cement',                          1.0000, NULL),
(2, 'Cars',                            1.2000, NULL),
(3, 'Perishable ods (pallets)',       0.8000, NULL),
(4, 'Mineral oil',                      1.0000, NULL),
(5, 'Scrap steel',                      1.0000, NULL),
(6, 'Cable drums',                      0.5000, NULL),
(7, 'Petroleum products',               1.0000, NULL);
SET IDENTITY_INSERT odsType OFF;



-- 8. WAN-ODS COMPATIBILITY

INSERT INTO WanodsCompatibility (TypeID, odsTypeID, MaxUnitsPerWan) VALUES
(94, 1, NULL),   -- Tank wan carries Cement (weight-limited)
(93, 2, 15),     -- Car carrier carries Cars (max 15 by space)
(92, 3, NULL),   -- Covered wan carries Perishable pallets (weight-limited)
(94, 4, NULL),   -- Tank wan carries Mineral oil (weight-limited)
(91, 5, NULL),   -- Open wan carries Scrap steel (weight-limited)
(90, 6, NULL),   -- Flat wan carries Cable drums (weight-limited)
(94, 7, NULL);   -- Tank wan carries Petroleum products (weight-limited)



-- 9. CUSTOMERS

SET IDENTITY_INSERT Customer ON;
INSERT INTO Customer (CustomerID, CompanyName, ContactName, Address, Phone, Email) VALUES
(1, 'Plymouth Cement Co.',     'John Brown',   '12 Harbour Street, Plymouth PL1 1AA',       '01752 500100', 'john.brown@plymouthcement.co.uk'),
(2, 'Midlands Auto Ltd.',      'Sarah Green',  '45 Motor Way, Birmingham B1 2CD',            '0121 555 0200', 'sarah.green@midlandsauto.co.uk'),
(3, 'Freshods Logistics',    'Mike White',   '78 Market Road, Manchester M2 3EF',           '0161 444 0300', 'mike.white@freshods.co.uk'),
(4, 'Northern Oil Supplies',   'Emma Davis',   '22 Refinery Lane, Manchester M3 4GH',         '0161 333 0400', 'emma.davis@northernoil.co.uk'),
(5, 'York Building Materials', 'Tom Wilson',   '15 Construction Yard, York YO1 5IJ',          '01904 600500', 'tom.wilson@yorkbuilding.co.uk');
SET IDENTITY_INSERT Customer OFF;



-- 10. DRIVERS

SET IDENTITY_INSERT Driver ON;
INSERT INTO Driver (DriverID, FullName, DateOfBirth, Address, Phone, Email, EmploymentStartDate, TDLNumber, TDLExpiryDate) VALUES
(1, 'Bert Smith',       '1975-03-15', '10 Railway Terrace, Plymouth PL2 1AB',   '07700 100001', 'bert.smith@tfr.co.uk',       '2005-06-01', 'TDL-2020-001', '2030-06-01'),
(2, 'Edward Jones',     '1980-07-22', '25 Station Road, Bristol BS1 2CD',        '07700 100002', 'edward.jones@tfr.co.uk',     '2008-09-15', 'TDL-2020-002', '2030-09-15'),
(3, 'Alice Cooper',     '1985-11-08', '5 Engine Close, Birmingham B3 3EF',       '07700 100003', 'alice.cooper@tfr.co.uk',     '2010-03-01', 'TDL-2021-003', '2031-03-01'),
(4, 'David Brown',      '1978-01-30', '42 Track Lane, Manchester M4 4GH',        '07700 100004', 'david.brown@tfr.co.uk',      '2003-01-10', 'TDL-2019-004', '2029-01-10'),
(5, 'Sarah Williams',   '1982-05-18', '8 Signal Way, Leeds LS1 5IJ',             '07700 100005', 'sarah.williams@tfr.co.uk',   '2012-07-20', 'TDL-2022-005', '2032-07-20'),
(6, 'James Taylor',     '1990-09-12', '17 Depot Street, Glasw G1 6KL',         '07700 100006', 'james.taylor@tfr.co.uk',     '2015-11-05', 'TDL-2023-006', '2033-11-05'),
(7, 'Helen Clark',      '1987-04-25', '33 ods Yard, Edinburgh EH1 7MN',        '07700 100007', 'helen.clark@tfr.co.uk',      '2011-02-28', 'TDL-2021-007', '2031-02-28'),
(8, 'Robert Martin',    '1976-12-03', '60 Marshalling Road, Crewe CW1 8OP',      '07700 100008', 'robert.martin@tfr.co.uk',    '2001-04-15', 'TDL-2020-008', '2030-04-15');
SET IDENTITY_INSERT Driver OFF;



-- 11. DRIVER QUALIFICATIONS

INSERT INTO DriverQualification (DriverID, ClassID, CertificateDate) VALUES
(1, 7, '2020-06-01'),   -- Bert Smith:     Class 07
(1, 8, '2020-06-01'),   -- Bert Smith:     Class 08
(2, 7, '2020-09-15'),   -- Edward Jones:   Class 07
(2, 9, '2020-09-15'),   -- Edward Jones:   Class 09
(3, 7, '2021-03-01'),   -- Alice Cooper:   Class 07
(3, 8, '2021-03-01'),   -- Alice Cooper:   Class 08
(3, 9, '2021-03-01'),   -- Alice Cooper:   Class 09
(4, 8, '2019-01-10'),   -- David Brown:    Class 08
(4, 9, '2019-01-10'),   -- David Brown:    Class 09
(5, 7, '2022-07-20'),   -- Sarah Williams: Class 07
(5, 8, '2022-07-20'),   -- Sarah Williams: Class 08
(6, 9, '2023-11-05'),   -- James Taylor:   Class 09
(7, 7, '2021-02-28'),   -- Helen Clark:    Class 07
(7, 9, '2021-02-28'),   -- Helen Clark:    Class 09
(8, 7, '2020-04-15'),   -- Robert Martin:  Class 07
(8, 8, '2020-04-15'),   -- Robert Martin:  Class 08
(8, 9, '2020-04-15');   -- Robert Martin:  Class 09



-- 12. CONSIGNMENTS (based on typical ods assignments)

SET IDENTITY_INSERT Consignment ON;
INSERT INTO Consignment (ConsignmentID, CustomerID, odsTypeID, Quantity, TotalWeightTonnes, CollectionStationID, DeliveryStationID) VALUES
(1, 1, 1, 1000.00, 1000.00, 1,  7),   -- Plymouth Cement Co.:     1000 tonnes cement,               Plymouth → Birmingham
(2, 2, 2, 200.00,  240.00,  8,  6),   -- Midlands Auto Ltd.:      200 cars @ 1.2t each = 240t,      Rugby → Swansea
(3, 3, 3, 500.00,  400.00,  7,  9),   -- Freshods Logistics:    500 pallets @ 0.8t each = 400t,   Birmingham → London Euston
(4, 4, 4, 1000.00, 1000.00, 11, 17),  -- Northern Oil Supplies:   1000 tonnes mineral oil,          Manchester → Glasw
(5, 5, 1, 2000.00, 2000.00, 14, 16);  -- York Building Materials: 2000 tonnes cement,               York → Edinburgh
SET IDENTITY_INSERT Consignment OFF;



-- 13. TRAINS
--
-- Train 1: Plymouth → Birmingham, 1000t cement
--   Locomotive 07100 (Class 07, max tow 1500t, length 16.4m)
--   16 tank wans: tare = 16 × 27.3 = 436.8t
--   Gross = 436.8 + 1000 = 1436.8t (< 1500t ✓)
--   Length = 16.4 + 16 × 18.9 = 318.8m (< 400m ✓)
--
-- Train 2: Birmingham → London Euston, 400t palletised ods
--   Locomotive 08200 (Class 08, max tow 1600t, length 17.8m)
--   7 covered wans: tare = 7 × 23.5 = 164.5t
--   Gross = 164.5 + 400 = 564.5t (< 1600t ✓)
--   Length = 17.8 + 7 × 20.6 = 162.0m (< 400m ✓)
--
-- Train 3: York → Edinburgh, 250t cement (partial consignment 5)
--   Locomotive 09001 (Class 09, max tow 2000t, length 21.4m)
--   4 tank wans: tare = 4 × 27.3 = 109.2t
--   Gross = 109.2 + 250 = 359.2t (< 2000t ✓)
--   Length = 21.4 + 4 × 18.9 = 97.0m (< 400m ✓)

SET IDENTITY_INSERT Train ON;
INSERT INTO Train (TrainID, LocomotiveSerial, DriverID, CoDriverID, TotalLengthMetres, GrossFreightWeightTonnes) VALUES
(1, '07100', 1, 2, 318.8, 1436.8),  -- Bert Smith & Edward Jones,  both qualified Class 07
(2, '08200', 3, 5, 162.0, 564.5),   -- Alice Cooper & Sarah Williams, both qualified Class 08
(3, '09001', 7, 6, 97.0,  359.2);   -- Helen Clark & James Taylor, both qualified Class 09
SET IDENTITY_INSERT Train OFF;



-- 14. TRAIN-CONSIGNMENT ASSIGNMENTS

INSERT INTO TrainConsignment (TrainID, ConsignmentID) VALUES
(1, 1),  -- Train 1 carries Consignment 1 (1000t cement, Plymouth → Birmingham)
(2, 3),  -- Train 2 carries Consignment 3 (400t pallets, Birmingham → London Euston)
(3, 5);  -- Train 3 carries Consignment 5 (partial: 250t of 2000t cement, York → Edinburgh)



-- 15. TRAIN-WAN ALLOCATIONS


-- Train 1: 16 tank wans
INSERT INTO TrainWan (TrainID, WanSerial) VALUES
(1, '94001'), (1, '94002'), (1, '94003'), (1, '94004'),
(1, '94005'), (1, '94006'), (1, '94007'), (1, '94008'),
(1, '94009'), (1, '94010'), (1, '94011'), (1, '94012'),
(1, '94013'), (1, '94014'), (1, '94015'), (1, '94016');

-- Train 2: 7 covered wans
INSERT INTO TrainWan (TrainID, WanSerial) VALUES
(2, '92001'), (2, '92002'), (2, '92003'), (2, '92004'),
(2, '92005'), (2, '92006'), (2, '92007');

-- Train 3: 4 tank wans
INSERT INTO TrainWan (TrainID, WanSerial) VALUES
(3, '94017'), (3, '94018'), (3, '94019'), (3, '94020');



-- 16. TRAIN ROUTES (ordered station stops)


-- Train 1: Plymouth → Exeter → Taunton → Bristol → Birmingham
INSERT INTO TrainRoute (TrainID, StopOrder, StationID) VALUES
(1, 1, 1),   -- Plymouth
(1, 2, 2),   -- Exeter
(1, 3, 3),   -- Taunton
(1, 4, 4),   -- Bristol
(1, 5, 7);   -- Birmingham

-- Train 2: Birmingham → Rugby → London Euston
INSERT INTO TrainRoute (TrainID, StopOrder, StationID) VALUES
(2, 1, 7),   -- Birmingham
(2, 2, 8),   -- Rugby
(2, 3, 9);   -- London Euston

-- Train 3: York → Newcastle → Edinburgh
INSERT INTO TrainRoute (TrainID, StopOrder, StationID) VALUES
(3, 1, 14),  -- York
(3, 2, 15),  -- Newcastle
(3, 3, 16);  -- Edinburgh



-- 17. UPDATE ROLLING STOCK AVAILABILITY
-- Mark allocated items as unavailable.


-- Locomotives allocated to trains
UPDATE Locomotive SET IsAvailable = 0
WHERE SerialNumber IN ('07100', '08200', '09001');

-- Wans allocated to trains
UPDATE FreightWan SET IsAvailable = 0
WHERE SerialNumber IN (
    '94001','94002','94003','94004','94005','94006','94007','94008',
    '94009','94010','94011','94012','94013','94014','94015','94016',
    '94017','94018','94019','94020',
    '92001','92002','92003','92004','92005','92006','92007'
);



-- VERIFICATION: Quick counts to confirm data integrity

SELECT 'LocomotiveClass'      AS TableName, COUNT(*) AS RowCount FROM LocomotiveClass
UNION ALL SELECT 'Locomotive',            COUNT(*) FROM Locomotive
UNION ALL SELECT 'WanType',             COUNT(*) FROM WanType
UNION ALL SELECT 'FreightWan',          COUNT(*) FROM FreightWan
UNION ALL SELECT 'Station',               COUNT(*) FROM Station
UNION ALL SELECT 'Stage',                 COUNT(*) FROM Stage
UNION ALL SELECT 'odsType',             COUNT(*) FROM odsType
UNION ALL SELECT 'WanodsCompat',      COUNT(*) FROM WanodsCompatibility
UNION ALL SELECT 'Customer',              COUNT(*) FROM Customer
UNION ALL SELECT 'Driver',                COUNT(*) FROM Driver
UNION ALL SELECT 'DriverQualification',   COUNT(*) FROM DriverQualification
UNION ALL SELECT 'Consignment',           COUNT(*) FROM Consignment
UNION ALL SELECT 'Train',                 COUNT(*) FROM Train
UNION ALL SELECT 'TrainConsignment',      COUNT(*) FROM TrainConsignment
UNION ALL SELECT 'TrainWan',            COUNT(*) FROM TrainWan
UNION ALL SELECT 'TrainRoute',            COUNT(*) FROM TrainRoute;

