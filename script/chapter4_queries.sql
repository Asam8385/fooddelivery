
-- Chapter 4: Thames Freight Rail (TFR) - Test Queries
-- Four queries demonstrating the database meets system requirements.
-- Target: Microsoft SQL Server (T-SQL)


USE ThamesFreightRail;



-- QUERY 1: Complete Train Schedule
--
-- Purpose: Display the full details of a scheduled train including
-- its locomotive, drivers, consignment, allocated wans, route,
-- and journey distance. This demonstrates the system's ability
-- to produce train schedules as required by the specification.


SELECT
    t.TrainID,
    -- Consignment details
    cs.StationName                  AS CollectionFrom,
    ds.StationName                  AS DeliveryTo,
    gt.Description                  AS ods,
    c.TotalWeightTonnes             AS odsWeightTonnes,
    cust.CompanyName                AS Customer,
    -- Locomotive details
    t.LocomotiveSerial,
    lc.ClassName                    AS LocomotiveClass,
    ISNULL(l.FamiliarName, '-')     AS LocomotiveName,
    lc.MaxTowingWeightTonnes,
    -- Driver details
    d1.FullName                     AS Driver,
    d2.FullName                     AS CoDriver,
    -- Train calculations
    t.TotalLengthMetres,
    t.GrossFreightWeightTonnes,
    -- Route as a single string
    (SELECT STRING_AGG(s.StationName, ' -> ') WITHIN GROUP (ORDER BY tr.StopOrder)
     FROM TrainRoute tr
     JOIN Station s ON tr.StationID = s.StationID
     WHERE tr.TrainID = t.TrainID)  AS Route,
    -- Journey distance
    (SELECT SUM(st.DistanceMiles)
     FROM TrainRoute tr1
     JOIN TrainRoute tr2 ON tr1.TrainID = tr2.TrainID
                         AND tr2.StopOrder = tr1.StopOrder + 1
     JOIN Stage st ON (st.StartStationID = tr1.StationID AND st.EndStationID = tr2.StationID)
                   OR (st.StartStationID = tr2.StationID AND st.EndStationID = tr1.StationID)
     WHERE tr1.TrainID = t.TrainID) AS JourneyDistanceMiles,
    -- Wan count
    (SELECT COUNT(*)
     FROM TrainWan tw
     WHERE tw.TrainID = t.TrainID)  AS WanCount,
    -- Wan list
    (SELECT STRING_AGG(tw.WanSerial, ', ')
     FROM TrainWan tw
     WHERE tw.TrainID = t.TrainID)  AS AllocatedWans
FROM Train t
JOIN Locomotive l           ON t.LocomotiveSerial = l.SerialNumber
JOIN LocomotiveClass lc     ON l.ClassID = lc.ClassID
JOIN Driver d1              ON t.DriverID = d1.DriverID
JOIN Driver d2              ON t.CoDriverID = d2.DriverID
JOIN TrainConsignment tc    ON t.TrainID = tc.TrainID
JOIN Consignment c          ON tc.ConsignmentID = c.ConsignmentID
JOIN Customer cust          ON c.CustomerID = cust.CustomerID
JOIN Station cs             ON c.CollectionStationID = cs.StationID
JOIN Station ds             ON c.DeliveryStationID = ds.StationID
JOIN odsType gt           ON c.odsTypeID = gt.odsTypeID
ORDER BY t.TrainID;




-- QUERY 2: Journey Distance Breakdown by Stage
--
-- Purpose: For each train, list the individual stages of the
-- route with the distance per stage and the cumulative total.
-- This demonstrates the system's ability to calculate journey
-- distances from the network of stages held in the database.


WITH RouteStages AS (
    SELECT
        tr1.TrainID,
        tr1.StopOrder,
        s1.StationName          AS FromStation,
        s2.StationName          AS ToStation,
        st.DistanceMiles
    FROM TrainRoute tr1
    JOIN TrainRoute tr2 ON tr1.TrainID = tr2.TrainID
                       AND tr2.StopOrder = tr1.StopOrder + 1
    JOIN Station s1     ON tr1.StationID = s1.StationID
    JOIN Station s2     ON tr2.StationID = s2.StationID
    LEFT JOIN Stage st  ON (st.StartStationID = tr1.StationID AND st.EndStationID = tr2.StationID)
                        OR (st.StartStationID = tr2.StationID AND st.EndStationID = tr1.StationID)
)
SELECT
    TrainID,
    FromStation,
    ToStation,
    DistanceMiles,
    SUM(DistanceMiles) OVER (PARTITION BY TrainID ORDER BY StopOrder) AS CumulativeMiles
FROM RouteStages
ORDER BY TrainID, StopOrder;




-- QUERY 3: Rolling Stock Availability Report
--
-- Purpose: Display a summary of all rolling stock showing
-- total owned, currently available, and currently allocated
-- counts. This demonstrates the system's ability to track
-- rolling stock and availability for allocation to trains.


-- Locomotive availability
SELECT
    lc.ClassName                                                AS StockType,
    COUNT(*)                                                    AS TotalOwned,
    SUM(CASE WHEN l.IsAvailable = 1 THEN 1 ELSE 0 END)        AS Available,
    SUM(CASE WHEN l.IsAvailable = 0 THEN 1 ELSE 0 END)        AS Allocated,
    lc.MaxTowingWeightTonnes                                    AS MaxTowWeight,
    lc.LengthMetres                                             AS Length
FROM Locomotive l
JOIN LocomotiveClass lc ON l.ClassID = lc.ClassID
GROUP BY lc.ClassName, lc.MaxTowingWeightTonnes, lc.LengthMetres

UNION ALL

-- Wan availability
SELECT
    wt.TypeName                                                 AS StockType,
    COUNT(*)                                                    AS TotalOwned,
    SUM(CASE WHEN fw.IsAvailable = 1 THEN 1 ELSE 0 END)        AS Available,
    SUM(CASE WHEN fw.IsAvailable = 0 THEN 1 ELSE 0 END)        AS Allocated,
    wt.MaxPayloadTonnes                                         AS MaxTowWeight,
    wt.LengthMetres                                             AS Length
FROM FreightWan fw
JOIN WanType wt ON fw.TypeID = wt.TypeID
GROUP BY wt.TypeName, wt.MaxPayloadTonnes, wt.LengthMetres

ORDER BY StockType;




-- QUERY 4: Wan Requirement and Feasibility for a Consignment
--
-- Purpose: For each unallocated consignment, determine how many
-- wans of the compatible type are needed, check whether enough
-- wans and an appropriate locomotive are available, and verify
-- that weight and length constraints can be satisfied.
-- This demonstrates the system's ability to plan train allocations.


WITH UnallocatedConsignments AS (
    -- Consignments not yet fully assigned to a train
    SELECT c.*
    FROM Consignment c
    WHERE NOT EXISTS (
        SELECT 1 FROM TrainConsignment tc WHERE tc.ConsignmentID = c.ConsignmentID
    )
),
WanCalc AS (
    SELECT
        uc.ConsignmentID,
        cust.CompanyName,
        gt.Description                              AS odsDescription,
        uc.TotalWeightTonnes,
        cs.StationName                              AS CollectionFrom,
        ds.StationName                              AS DeliveryTo,
        wt.TypeName                                 AS WanType,
        wt.MaxPayloadTonnes,
        wt.TareWeightTonnes,
        wt.LengthMetres                             AS WanLength,
        -- Calculate wans needed
        CEILING(uc.TotalWeightTonnes / wt.MaxPayloadTonnes)             AS WansNeeded,
        -- Total gross weight if fully loaded
        CEILING(uc.TotalWeightTonnes / wt.MaxPayloadTonnes)
            * wt.TareWeightTonnes + uc.TotalWeightTonnes                AS EstGrossWeight,
        -- Total wan length
        CEILING(uc.TotalWeightTonnes / wt.MaxPayloadTonnes)
            * wt.LengthMetres                                           AS EstWanLength,
        -- Available wans of this type
        (SELECT COUNT(*) FROM FreightWan fw
         WHERE fw.TypeID = wt.TypeID AND fw.IsAvailable = 1)           AS AvailableWans
    FROM UnallocatedConsignments uc
    JOIN Customer cust          ON uc.CustomerID = cust.CustomerID
    JOIN odsType gt           ON uc.odsTypeID = gt.odsTypeID
    JOIN Station cs             ON uc.CollectionStationID = cs.StationID
    JOIN Station ds             ON uc.DeliveryStationID = ds.StationID
    JOIN WanodsCompatibility wgc ON uc.odsTypeID = wgc.odsTypeID
    JOIN WanType wt           ON wgc.TypeID = wt.TypeID
)
SELECT
    ConsignmentID,
    CompanyName,
    odsDescription,
    TotalWeightTonnes,
    CollectionFrom,
    DeliveryTo,
    WanType,
    CAST(WansNeeded AS INT) AS WansNeeded,
    AvailableWans,
    CASE
        WHEN AvailableWans >= WansNeeded THEN 'Sufficient'
        ELSE 'Insufficient (need ' + CAST(CAST(WansNeeded - AvailableWans AS INT) AS VARCHAR) + ' more)'
    END AS WanAvailability,
    CAST(EstGrossWeight AS DECIMAL(10,1)) AS EstGrossWeightTonnes,
    -- Find cheapest (smallest suitable) locomotive class
    (SELECT TOP 1 lc.ClassName
     FROM LocomotiveClass lc
     JOIN Locomotive l ON l.ClassID = lc.ClassID AND l.IsAvailable = 1
     WHERE lc.MaxTowingWeightTonnes >= EstGrossWeight
     ORDER BY lc.MaxTowingWeightTonnes ASC)                    AS SuitableLocoClass,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM LocomotiveClass lc
            JOIN Locomotive l ON l.ClassID = lc.ClassID AND l.IsAvailable = 1
            WHERE lc.MaxTowingWeightTonnes >= EstGrossWeight
        ) THEN 'Yes'
        ELSE 'No - exceeds all available loco capacities'
    END AS LocoAvailable
FROM WanCalc
ORDER BY ConsignmentID;

