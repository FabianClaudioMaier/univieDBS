-- Create tables
CREATE TABLE Kunden (
  KundenID INTEGER PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Adresse VARCHAR(200) NOT NULL,
  Telefonnummer VARCHAR(20) NOT NULL,
  Email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Anbieter (
  AnbieterID INTEGER PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Adresse VARCHAR(200) NOT NULL,
  Telefonnummer VARCHAR(20) NOT NULL,
  Email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Fahrzeuge (
  FahrzeugID INTEGER PRIMARY KEY,
  Kennzeichen VARCHAR(20) UNIQUE NOT NULL,
  Modell VARCHAR(100) NOT NULL,
  Hersteller VARCHAR(100) NOT NULL,
  Baujahr INTEGER CHECK (Baujahr > 1885),
  Status VARCHAR(20) DEFAULT 'Available' NOT NULL
);

CREATE TABLE Reservierungen (
  ReservierungsID INTEGER PRIMARY KEY,
  KundenID INTEGER NOT NULL,
  FahrzeugID INTEGER,
  Startdatum DATE NOT NULL,
  Enddatum DATE NOT NULL,
  Kosten INTEGER CHECK (Kosten >= 0),
  FOREIGN KEY (KundenID) REFERENCES Kunden(KundenID) ON DELETE CASCADE,
  FOREIGN KEY (FahrzeugID) REFERENCES Fahrzeuge(FahrzeugID) ON DELETE SET NULL
);

CREATE TABLE Transaktionen (
  TransaktionsID INTEGER PRIMARY KEY,
  ReservierungsID INTEGER NOT NULL,
  Betrag INTEGER CHECK (Betrag >= 0),
  Zahlungsweise VARCHAR(50) NOT NULL,
  Zahlungsdatum DATE DEFAULT SYSDATE,
  FOREIGN KEY (ReservierungsID) REFERENCES Reservierungen(ReservierungsID) ON DELETE CASCADE
);

CREATE TABLE Zusatzleistungen (
  LeistungsID INTEGER PRIMARY KEY,
  ReservierungsID INTEGER NOT NULL,
  Beschreibung VARCHAR(200) NOT NULL,
  Kosten INTEGER CHECK (Kosten >= 0),
  FOREIGN KEY (ReservierungsID) REFERENCES Reservierungen(ReservierungsID) ON DELETE CASCADE
);

CREATE TABLE Kunden_Anbieter (
  ID INTEGER PRIMARY KEY,
  KundenID INTEGER NOT NULL,
  AnbieterID INTEGER NOT NULL,
  FOREIGN KEY (KundenID) REFERENCES Kunden(KundenID) ON DELETE CASCADE,
  FOREIGN KEY (AnbieterID) REFERENCES Anbieter(AnbieterID) ON DELETE CASCADE
);

-- Create sequence for auto-increment
CREATE SEQUENCE Kunden_Anbieter_Seq START WITH 1 INCREMENT BY 1;

-- Create auto-increment trigger
CREATE OR REPLACE TRIGGER auto_increment_Kunden_Anbieter
BEFORE INSERT ON Kunden_Anbieter
FOR EACH ROW
BEGIN
  SELECT Kunden_Anbieter_Seq.NEXTVAL INTO :NEW.ID FROM dual;
END;
/ 

-- Create business logic trigger
CREATE OR REPLACE TRIGGER update_vehicle_status
AFTER INSERT ON Reservierungen
FOR EACH ROW
BEGIN
  UPDATE Fahrzeuge
  SET Status = 'Reserved'
  WHERE FahrzeugID = :NEW.FahrzeugID;
END;
/ 

-- Insert-Into Examples
INSERT INTO Kunden_Anbieter (KundenID, AnbieterID) VALUES (1, 2);
INSERT INTO Kunden_Anbieter (KundenID, AnbieterID) VALUES (3, 4);

INSERT INTO Reservierungen (ReservierungsID, KundenID, FahrzeugID, Startdatum, Enddatum, Kosten) 
VALUES (1, 1, 1, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-10', 'YYYY-MM-DD'), 500);

-- Deletion Rules Examples
-- ON DELETE CASCADE
INSERT INTO Kunden (KundenID, Name, Adresse, Telefonnummer, Email) VALUES (1, 'John Doe', '123 Main St', '123-456-7890', 'john@example.com');
INSERT INTO Fahrzeuge (FahrzeugID, Kennzeichen, Modell, Hersteller, Baujahr, Status) VALUES (1, 'ABC123', 'Model S', 'Tesla', 2020, 'Available');
INSERT INTO Reservierungen (ReservierungsID, KundenID, FahrzeugID, Startdatum, Enddatum, Kosten) VALUES (1, 1, 1, TO_DATE('2023-10-01', 'YYYY-MM-DD'), TO_DATE('2023-10-10', 'YYYY-MM-DD'), 500);
DELETE FROM Kunden WHERE KundenID = 1;
SELECT * FROM Reservierungen WHERE KundenID = 1;

-- ON DELETE SET NULL
INSERT INTO Kunden (KundenID, Name, Adresse, Telefonnummer, Email) VALUES (2, 'Jane Smith', '456 Elm St', '987-654-3210', 'jane@example.com');
INSERT INTO Fahrzeuge (FahrzeugID, Kennzeichen, Modell, Hersteller, Baujahr, Status) VALUES (2, 'XYZ789', 'Model 3', 'Tesla', 2021, 'Available');
INSERT INTO Reservierungen (ReservierungsID, KundenID, FahrzeugID, Startdatum, Enddatum, Kosten) VALUES (2, 2, 2, TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-10', 'YYYY-MM-DD'), 600);
DELETE FROM Fahrzeuge WHERE FahrzeugID = 2;
SELECT * FROM Reservierungen WHERE ReservierungsID = 2;

-- Create a View
CREATE VIEW Kunden_Reservierungen AS
SELECT 
  k.Name AS KundenName,
  k.Email AS KundenEmail,
  f.Modell AS FahrzeugModell,
  f.Hersteller AS FahrzeugHersteller,
  r.Startdatum,
  r.Enddatum,
  r.Kosten
FROM 
  Reservierungen r
JOIN 
  Kunden k ON r.KundenID = k.KundenID
JOIN 
  Fahrzeuge f ON r.FahrzeugID = f.FahrzeugID;

-- Query the View
SELECT * FROM Kunden_Reservierungen;

-- Drop tables
DROP TABLE Transaktionen CASCADE CONSTRAINTS;
DROP TABLE Zusatzleistungen CASCADE CONSTRAINTS;
DROP TABLE Reservierungen CASCADE CONSTRAINTS;
DROP TABLE Fahrzeuge CASCADE CONSTRAINTS;
DROP TABLE Kunden_Anbieter CASCADE CONSTRAINTS;
DROP TABLE Anbieter CASCADE CONSTRAINTS;
DROP TABLE Kunden CASCADE CONSTRAINTS;

-- Drop sequence
DROP SEQUENCE Kunden_Anbieter_Seq;

-- Drop triggers
DROP TRIGGER auto_increment_Kunden_Anbieter;
DROP TRIGGER update_vehicle_status;