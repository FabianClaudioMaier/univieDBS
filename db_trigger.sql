-- Create tables
CREATE TABLE Kunden (
  KundenID NUMBER PRIMARY KEY,
  Name VARCHAR2(100),
  Adresse VARCHAR2(200),
  Telefonnummer VARCHAR2(20),
  Email VARCHAR2(100)
);

CREATE TABLE Anbieter (
  AnbieterID NUMBER PRIMARY KEY,
  Name VARCHAR2(100),
  Adresse VARCHAR2(200),
  Telefonnummer VARCHAR2(20),
  Email VARCHAR2(100)
);

CREATE TABLE Fahrzeuge (
  FahrzeugID NUMBER PRIMARY KEY,
  Kennzeichen VARCHAR2(20),
  Modell VARCHAR2(100),
  Hersteller VARCHAR2(100),
  Baujahr NUMBER,
  Status VARCHAR2(20)
);

CREATE TABLE Reservierungen (
  ReservierungsID NUMBER PRIMARY KEY,
  KundenID NUMBER,
  FahrzeugID NUMBER,
  Startdatum DATE,
  Enddatum DATE,
  Kosten NUMBER,
  FOREIGN KEY (KundenID) REFERENCES Kunden(KundenID),
  FOREIGN KEY (FahrzeugID) REFERENCES Fahrzeuge(FahrzeugID)
);

CREATE TABLE Transaktionen (
  TransaktionsID NUMBER PRIMARY KEY,
  ReservierungsID NUMBER,
  Betrag NUMBER,
  Zahlungsweise VARCHAR2(50),
  Zahlungsdatum DATE,
  FOREIGN KEY (ReservierungsID) REFERENCES Reservierungen(ReservierungsID)
);

CREATE TABLE Zusatzleistungen (
  LeistungsID NUMBER PRIMARY KEY,
  ReservierungsID NUMBER,
  Beschreibung VARCHAR2(200),
  Kosten NUMBER,
  FOREIGN KEY (ReservierungsID) REFERENCES Reservierungen(ReservierungsID)
);

CREATE TABLE Kunden_Anbieter (
  ID NUMBER PRIMARY KEY,
  KundenID NUMBER,
  AnbieterID NUMBER,
  FOREIGN KEY (KundenID) REFERENCES Kunden(KundenID),
  FOREIGN KEY (AnbieterID) REFERENCES Anbieter(AnbieterID)
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