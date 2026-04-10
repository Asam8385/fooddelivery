
-- Chapter 2: Thames Freight Rail (TFR) - SQL Table Definitions
-- Target: Microsoft SQL Server (T-SQL)


-- Create and use the database
CREATE DATABASE ThamesFreightRail;

USE ThamesFreightRail;



-- 1. LOCOMOTIVE CLASS
-- Stores locomotive cateries with their specifications.

CREATE TABLE LocomotiveClass (
    ClassID         INT             NOT NULL,
    ClassName       VARCHAR(50)     NOT NULL,
    SerialPrefix    CHAR(2)         NOT NULL,
    MaxTowingWeightTonnes DECIMAL(10,1) NOT NULL,
    LengthMetres    DECIMAL(5,1)    NOT NULL,
    CONSTRAINT PK_LocomotiveClass PRIMARY KEY (ClassID),
    CONSTRAINT UQ_LocomotiveClass_Prefix UNIQUE (SerialPrefix)
);



-- 2. LOCOMOTIVE
-- Individual locomotives identified by 5-digit serial number.

CREATE TABLE Locomotive (
    SerialNumber    CHAR(5)         NOT NULL,
    ClassID         INT             NOT NULL,
    FamiliarName    VARCHAR(100)    NULL,
    IsAvailable     BIT             NOT NULL DEFAULT 1,
    CONSTRAINT PK_Locomotive PRIMARY KEY (SerialNumber),
    CONSTRAINT FK_Locomotive_Class FOREIGN KEY (ClassID)
        REFERENCES LocomotiveClass(ClassID)
);



-- 3. WAN TYPE
-- Cateries of freight wans with their specifications.

CREATE TABLE WanType (
    TypeID          INT             NOT NULL,
    TypeName        VARCHAR(50)     NOT NULL,
    SerialPrefix    CHAR(2)         NOT NULL,
    Description     VARCHAR(500)    NOT NULL,
    TareWeightTonnes  DECIMAL(5,1)  NOT NULL,
    MaxPayloadTonnes  DECIMAL(5,1)  NOT NULL,
    LengthMetres    DECIMAL(5,1)    NOT NULL,
    CONSTRAINT PK_WanType PRIMARY KEY (TypeID),
    CONSTRAINT UQ_WanType_Prefix UNIQUE (SerialPrefix)
);



-- 4. FREIGHT WAN
-- Individual freight wans identified by 5-digit serial number.

CREATE TABLE FreightWan (
    SerialNumber    CHAR(5)         NOT NULL,
    TypeID          INT             NOT NULL,
    IsAvailable     BIT             NOT NULL DEFAULT 1,
    CONSTRAINT PK_FreightWan PRIMARY KEY (SerialNumber),
    CONSTRAINT FK_FreightWan_Type FOREIGN KEY (TypeID)
        REFERENCES WanType(TypeID)
);



-- 5. STATION
-- Rail stations within the TFR network.

CREATE TABLE Station (
    StationID       INT             NOT NULL IDENTITY(1,1),
    StationName     VARCHAR(100)    NOT NULL,
    CONSTRAINT PK_Station PRIMARY KEY (StationID),
    CONSTRAINT UQ_Station_Name UNIQUE (StationName)
);



-- 6. STAGE
-- Connections between two stations with distance.
-- Stages are bidirectional; each connection is stored once.

CREATE TABLE Stage (
    StageID         INT             NOT NULL IDENTITY(1,1),
    StartStationID  INT             NOT NULL,
    EndStationID    INT             NOT NULL,
    DistanceMiles   DECIMAL(6,1)   NOT NULL,
    CONSTRAINT PK_Stage PRIMARY KEY (StageID),
    CONSTRAINT FK_Stage_Start FOREIGN KEY (StartStationID)
        REFERENCES Station(StationID),
    CONSTRAINT FK_Stage_End FOREIGN KEY (EndStationID)
        REFERENCES Station(StationID),
    CONSTRAINT UQ_Stage UNIQUE (StartStationID, EndStationID),
    CONSTRAINT CK_Stage_Different CHECK (StartStationID <> EndStationID)
);



-- 7. ODS TYPE
-- Types of ods that can be transported.

CREATE TABLE odsType (
    odsTypeID     INT             NOT NULL IDENTITY(1,1),
    Description     VARCHAR(200)    NOT NULL,
    UnitWeightTonnes      DECIMAL(8,4) NULL,
    UnitVolumeCubicMetres DECIMAL(8,4) NULL
);

ALTER TABLE odsType ADD CONSTRAINT PK_odsType PRIMARY KEY (odsTypeID);



-- 8. WAN-ODS COMPATIBILITY
-- Defines which wan types can carry which ods types,
-- and optionally the maximum number of units per wan.

CREATE TABLE WanodsCompatibility (
    TypeID          INT             NOT NULL,
    odsTypeID     INT             NOT NULL,
    MaxUnitsPerWan INT            NULL,
    CONSTRAINT PK_WanodsCompat PRIMARY KEY (TypeID, odsTypeID),
    CONSTRAINT FK_WGC_WanType FOREIGN KEY (TypeID)
        REFERENCES WanType(TypeID),
    CONSTRAINT FK_WGC_odsType FOREIGN KEY (odsTypeID)
        REFERENCES odsType(odsTypeID)
);



-- 9. CUSTOMER
-- Companies that commission ods transport.

CREATE TABLE Customer (
    CustomerID      INT             NOT NULL IDENTITY(1,1),
    CompanyName     VARCHAR(200)    NOT NULL,
    ContactName     VARCHAR(200)    NOT NULL,
    Address         VARCHAR(500)    NOT NULL,
    Phone           VARCHAR(20)     NOT NULL,
    Email           VARCHAR(200)    NOT NULL,
    CONSTRAINT PK_Customer PRIMARY KEY (CustomerID)
);



-- 10. DRIVER
-- Train drivers employed by TFR.

CREATE TABLE Driver (
    DriverID            INT             NOT NULL IDENTITY(1,1),
    FullName            VARCHAR(200)    NOT NULL,
    DateOfBirth         DATE            NOT NULL,
    Address             VARCHAR(500)    NOT NULL,
    Phone               VARCHAR(20)     NOT NULL,
    Email               VARCHAR(200)    NOT NULL,
    EmploymentStartDate DATE            NOT NULL,
    TDLNumber           VARCHAR(20)     NOT NULL,
    TDLExpiryDate       DATE            NOT NULL,
    CONSTRAINT PK_Driver PRIMARY KEY (DriverID),
    CONSTRAINT UQ_Driver_TDL UNIQUE (TDLNumber)
);



-- 11. DRIVER QUALIFICATION
-- Records which drivers are certified for which locomotive classes.

CREATE TABLE DriverQualification (
    DriverID        INT             NOT NULL,
    ClassID         INT             NOT NULL,
    CertificateDate DATE            NOT NULL,
    CONSTRAINT PK_DriverQualification PRIMARY KEY (DriverID, ClassID),
    CONSTRAINT FK_DQ_Driver FOREIGN KEY (DriverID)
        REFERENCES Driver(DriverID),
    CONSTRAINT FK_DQ_Class FOREIGN KEY (ClassID)
        REFERENCES LocomotiveClass(ClassID)
);



-- 12. CONSIGNMENT
-- A ods shipment request from a customer.

CREATE TABLE Consignment (
    ConsignmentID       INT             NOT NULL IDENTITY(1,1),
    CustomerID          INT             NOT NULL,
    odsTypeID         INT             NOT NULL,
    Quantity            DECIMAL(10,2)   NOT NULL,
    TotalWeightTonnes   DECIMAL(10,2)   NOT NULL,
    CollectionStationID INT             NOT NULL,
    DeliveryStationID   INT             NOT NULL,
    CONSTRAINT PK_Consignment PRIMARY KEY (ConsignmentID),
    CONSTRAINT FK_Consignment_Customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Consignment_ods FOREIGN KEY (odsTypeID)
        REFERENCES odsType(odsTypeID),
    CONSTRAINT FK_Consignment_Collection FOREIGN KEY (CollectionStationID)
        REFERENCES Station(StationID),
    CONSTRAINT FK_Consignment_Delivery FOREIGN KEY (DeliveryStationID)
        REFERENCES Station(StationID),
    CONSTRAINT CK_Consignment_Different CHECK (CollectionStationID <> DeliveryStationID)
);



-- 13. TRAIN
-- A scheduled train with a locomotive and two drivers.

CREATE TABLE Train (
    TrainID                 INT             NOT NULL IDENTITY(1,1),
    LocomotiveSerial        CHAR(5)         NOT NULL,
    DriverID                INT             NOT NULL,
    CoDriverID              INT             NOT NULL,
    TotalLengthMetres       DECIMAL(6,1)    NULL,
    GrossFreightWeightTonnes DECIMAL(10,1)  NULL,
    CONSTRAINT PK_Train PRIMARY KEY (TrainID),
    CONSTRAINT FK_Train_Locomotive FOREIGN KEY (LocomotiveSerial)
        REFERENCES Locomotive(SerialNumber),
    CONSTRAINT FK_Train_Driver FOREIGN KEY (DriverID)
        REFERENCES Driver(DriverID),
    CONSTRAINT FK_Train_CoDriver FOREIGN KEY (CoDriverID)
        REFERENCES Driver(DriverID),
    CONSTRAINT CK_Train_DifferentDrivers CHECK (DriverID <> CoDriverID)
);



-- 14. TRAIN-CONSIGNMENT (Many-to-Many)
-- Links trains to the consignments they carry.

CREATE TABLE TrainConsignment (
    TrainID         INT             NOT NULL,
    ConsignmentID   INT             NOT NULL,
    CONSTRAINT PK_TrainConsignment PRIMARY KEY (TrainID, ConsignmentID),
    CONSTRAINT FK_TC_Train FOREIGN KEY (TrainID)
        REFERENCES Train(TrainID),
    CONSTRAINT FK_TC_Consignment FOREIGN KEY (ConsignmentID)
        REFERENCES Consignment(ConsignmentID)
);



-- 15. TRAIN-WAN (Many-to-Many)
-- Records which freight wans are allocated to which train.

CREATE TABLE TrainWan (
    TrainID         INT             NOT NULL,
    WanSerial     CHAR(5)         NOT NULL,
    CONSTRAINT PK_TrainWan PRIMARY KEY (TrainID, WanSerial),
    CONSTRAINT FK_TW_Train FOREIGN KEY (TrainID)
        REFERENCES Train(TrainID),
    CONSTRAINT FK_TW_Wan FOREIGN KEY (WanSerial)
        REFERENCES FreightWan(SerialNumber)
);



-- 16. TRAIN ROUTE
-- Ordered sequence of station stops forming a train's route.

CREATE TABLE TrainRoute (
    TrainID         INT             NOT NULL,
    StopOrder       INT             NOT NULL,
    StationID       INT             NOT NULL,
    CONSTRAINT PK_TrainRoute PRIMARY KEY (TrainID, StopOrder),
    CONSTRAINT FK_TR_Train FOREIGN KEY (TrainID)
        REFERENCES Train(TrainID),
    CONSTRAINT FK_TR_Station FOREIGN KEY (StationID)
        REFERENCES Station(StationID)
);

