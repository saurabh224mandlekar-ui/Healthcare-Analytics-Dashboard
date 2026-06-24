create database Axon_Healthcare;
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100),
    specialty VARCHAR(50),
    phone_number VARCHAR(30),
    years_of_experience INT,
    hospital_affiliation VARCHAR(150),
    hospital_clinic VARCHAR(150),
    email VARCHAR(100)
);
SELECT * FROM doctors;

CREATE TABLE lab_results (
    lab_result_id INT PRIMARY KEY,
    visit_id INT,
    test_name VARCHAR(50),
    test_date DATE,
    units VARCHAR(20),
    comments VARCHAR(100),
    test_result VARCHAR(20),
    reference_range VARCHAR(30)
);
SELECT * FROM lab_results;

CREATE TABLE patients (
    PatientID INT,
    Gender VARCHAR(10),
    DateOfBirth DATE,
    Age INT,
    BloodType VARCHAR(3),
    InsuranceProvider VARCHAR(100),
    State VARCHAR(50),
    City VARCHAR(50),
    Country VARCHAR(50),
    PolicyNumber VARCHAR(50),
    MedicalHistory VARCHAR(100),
    Race VARCHAR(50),
    Ethnicity VARCHAR(50),
    MaritalStatus VARCHAR(20),
    FirstName VARCHAR(50),
    LastName VARCHAR(100),
    ChronicConditions VARCHAR(100),
    Allergies VARCHAR(100)
);

SELECT * FROM patients;

SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/patients.csv'
INTO TABLE patients
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    PatientID,
    Gender,
    DateOfBirth,
    Age,
    BloodType,
    InsuranceProvider,
    State,
    City,
    Country,
    PolicyNumber,
    MedicalHistory,
    Race,
    Ethnicity,
    MaritalStatus,
    FirstName,
    LastName,
    ChronicConditions,
    Allergies
);



CREATE TABLE Treatment (
    TreatmentID INT PRIMARY KEY,
    VisitID INT,
    Medication VARCHAR(50),
    Dosage VARCHAR(20),
    Instruction VARCHAR(50),
    TreatmentCost DECIMAL(10,2),
    TreatmentType1 VARCHAR(50),
    TreatmentType2 VARCHAR(50),
    Status VARCHAR(20),
    Cost DECIMAL(10,2),
    Outcome VARCHAR(20),
    TreatmentDescription VARCHAR(100)
);
select *from treatment;

CREATE TABLE Visit (
    VisitID INT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    VisitDate DATE,
    Diagnosis VARCHAR(50),
    FollowUp VARCHAR(10),
    VisitType VARCHAR(50),
    VisitStatus VARCHAR(20),
    DiagnosisCode VARCHAR(20),
    ReasonForVisit VARCHAR(100),
    PrescribedMedications VARCHAR(100)
);
select *from visit;


SELECT 
    p.PatientID,p.FirstName,p.LastName,p.Gender,p.DateOfBirth,p.Age,p.BloodType,p.InsuranceProvider,p.City,p.State,p.Country,
    p.PolicyNumber,p.MedicalHistory,p.Race,p.Ethnicity,p.MaritalStatus,p.ChronicConditions,p.Allergies,d.doctor_id,d.doctor_name,
    d.specialty,d.phone_number AS doctor_phone,d.years_of_experience,d.hospital_affiliation,d.hospital_clinic,d.email,v.VisitID,
    v.VisitDate,v.Diagnosis,v.FollowUp,v.VisitType,v.VisitStatus,v.DiagnosisCode,v.ReasonForVisit,v.PrescribedMedications,
    t.TreatmentID,t.Medication,t.Dosage,t.Instruction,t.TreatmentCost,t.TreatmentType1,t.TreatmentType2,t.Status,t.Cost,
    t.Outcome,t.TreatmentDescription,l.lab_result_id,l.test_name,l.test_date,l.units,l.comments,l.test_result,l.reference_range

FROM axon_healthcare.patients p
JOIN axon_healthcare.visit v ON p.PatientID = v.PatientID
JOIN axon_healthcare.doctors d ON v.DoctorID = d.doctor_id
LEFT JOIN axon_healthcare.treatment t ON v.VisitID = t.VisitID
LEFT JOIN axon_healthcare.lab_results l ON v.VisitID = l.visit_id
ORDER BY v.VisitDate DESC;


DESCRIBE axon_healthcare.patients;
DESCRIBE axon_healthcare.doctors;
DESCRIBE axon_healthcare.visit;
DESCRIBE axon_healthcare.treatment;
DESCRIBE axon_healthcare.lab_results;

#KPI-1
SELECT COUNT(*) AS total_patients
FROM axon_healthcare.patients;

#KPI-2
SELECT COUNT(*) AS total_doctors
FROM axon_healthcare.doctors;

#KPI-3
SELECT COUNT(*) AS total_visits
FROM axon_healthcare.visit;

#KPI-4
SELECT ROUND(AVG(Age), 1) AS average_age_of_patients
FROM axon_healthcare.patients;

#KPI-5
SELECT Diagnosis, COUNT(*) AS total_cases
FROM axon_healthcare.visit
GROUP BY Diagnosis
ORDER BY total_cases DESC
LIMIT 5;

#KPI-6
SELECT 
  ROUND(100 * SUM(FollowUp = 'Yes') / COUNT(*), 2) AS follow_up_rate_percentage
FROM axon_healthcare.visit;

#KPI-7
SELECT CONCAT('$', ROUND(AVG(TreatmentCost), 2)) AS avg_treatment_cost_per_visit
FROM axon_healthcare.treatment;

#KPI-8
SELECT COUNT(*) AS total_lab_tests_conducted
FROM axon_healthcare.lab_results;

#KPI-9
SELECT 
  ROUND(100 * SUM(CASE WHEN LOWER(test_result) LIKE '%abnormal%' THEN 1 ELSE 0 END) / COUNT(*), 2) AS abnormal_result_percentage
FROM axon_healthcare.lab_results;

#KPI-10
SELECT 
  ROUND(COUNT(DISTINCT PatientID) * 1.0 / COUNT(DISTINCT DoctorID)) AS avg_patients_per_doctor
FROM axon_healthcare.visit;

#KPI-11
SELECT
  CONCAT(ROUND(SUM(COALESCE(TreatmentCost, 0) + COALESCE(Cost, 0)) / 1000000, 2), ' M') AS total_revenue_millions
FROM axon_healthcare.treatment;

##QA Querries
#1. Data Count Validation
SELECT COUNT(*) AS patient_count FROM axon_healthcare.patients;
SELECT COUNT(*) AS visit_count FROM axon_healthcare.visit;
SELECT COUNT(*) AS treatment_count FROM axon_healthcare.treatment;
SELECT COUNT(*) AS lab_result_count FROM axon_healthcare.lab_results;
SELECT COUNT(*) AS doctor_count FROM axon_healthcare.doctors;

#2. Data Completeness Check
SELECT * FROM axon_healthcare.patients 
WHERE FirstName IS NULL OR LastName IS NULL;

SELECT * FROM axon_healthcare.visit 
WHERE VisitType IS NULL OR VisitDate IS NULL;


SELECT * FROM axon_healthcare.treatment 
WHERE Medication IS NULL OR Status IS NULL;


SELECT * FROM axon_healthcare.lab_results 
WHERE Test_Name IS NULL OR Test_Result IS NULL;

#3. Data Consistency Check

SELECT v.VisitID 
FROM axon_healthcare.visit v
LEFT JOIN axon_healthcare.patients p ON v.PatientID = p.PatientID
WHERE p.PatientID IS NULL;


SELECT t.TreatmentID 
FROM axon_healthcare.treatment t
LEFT JOIN axon_healthcare.visit v ON t.VisitID = v.VisitID
WHERE v.VisitID IS NULL;


SELECT l.lab_result_id 
FROM axon_healthcare.lab_results l
LEFT JOIN axon_healthcare.visit v ON l.visit_id = v.VisitID
WHERE v.VisitID IS NULL;

SELECT v.VisitID 
FROM axon_healthcare.visit v
LEFT JOIN axon_healthcare.doctors d ON v.DoctorID = d.doctor_id
WHERE d.doctor_id IS NULL;

#4. Duplicate Records Check

SELECT PatientID, COUNT(*) 
FROM axon_healthcare.patients
GROUP BY PatientID
HAVING COUNT(*) > 1;

SELECT VisitID, COUNT(*) 
FROM axon_healthcare.visit
GROUP BY VisitID
HAVING COUNT(*) > 1;

SELECT TreatmentID, COUNT(*) 
FROM axon_healthcare.treatment
GROUP BY TreatmentID
HAVING COUNT(*) > 1;

SELECT lab_result_id, COUNT(*) 
FROM axon_healthcare.lab_results
GROUP BY lab_result_id
HAVING COUNT(*) > 1;

#5. Dashboard Aggregation Check

SELECT
  CONCAT(ROUND(SUM(COALESCE(TreatmentCost, 0) + COALESCE(Cost, 0)) / 1000000, 2), ' M') AS total_revenue_millions
FROM axon_healthcare.treatment;

SELECT ROUND(AVG(Age), 1) AS average_age_of_patients
FROM axon_healthcare.patients;

#6. Performance Testing
EXPLAIN ANALYZE
SELECT * 
FROM axon_healthcare.visit 
WHERE VisitDate BETWEEN '2023-01-01' AND '2023-12-31';


#visualization 

#Average Treatment Cost by Diagnosis
SELECT v.Diagnosis, 
       CONCAT('$',ROUND(AVG(t.TreatmentCost), 2)) AS avg_cost
FROM axon_healthcare.visit v
JOIN axon_healthcare.treatment t ON v.VisitID = t.VisitID
GROUP BY v.Diagnosis
ORDER BY avg_cost DESC;

#Patient Count by Chronic Condition
SELECT ChronicConditions, COUNT(*) AS patient_count
FROM axon_healthcare.patients
GROUP BY ChronicConditions
ORDER BY patient_count DESC;

#Treatment Outcome Distribution
SELECT Outcome, COUNT(*) AS outcome_count
FROM axon_healthcare.treatment
GROUP BY Outcome;

#Monthly Patient Visits
SELECT DATE_FORMAT(VisitDate, '%Y-%m') AS month, COUNT(*) AS visit_count
FROM axon_healthcare.visit
GROUP BY month
ORDER BY month;

#Top 5 Medications Prescribed
SELECT Medication, COUNT(*) AS prescription_count
FROM axon_healthcare.treatment
GROUP BY Medication
ORDER BY prescription_count DESC
LIMIT 5;

#Average Lab Result Count per Visit Type
SELECT 
    v.VisitType,
    p.ChronicConditions,
    COUNT(l.lab_result_id) AS total_lab_results
FROM axon_healthcare.lab_results l
JOIN axon_healthcare.visit v ON l.visit_id = v.VisitID
JOIN axon_healthcare.patients p ON v.PatientID = p.PatientID
GROUP BY v.VisitType, p.ChronicConditions
ORDER BY v.VisitType, total_lab_results DESC;


Desc axon_healthcare.lab_results;
Desc axon_healthcare.visit;
Desc axon_healthcare.patients;

#Pending Lab Tests by City
SELECT 
    p.City,
    COUNT(l.lab_result_id) AS pending_lab_tests
FROM axon_healthcare.lab_results l
JOIN axon_healthcare.visit v ON l.visit_id = v.VisitID
JOIN axon_healthcare.patients p ON v.PatientID = p.PatientID
WHERE l.test_result = 'Pending'
GROUP BY p.City
ORDER BY pending_lab_tests DESC;


#Most Common Allergies
SELECT Allergies, COUNT(*) AS frequency
FROM axon_healthcare.patients
WHERE Allergies IS NOT NULL AND Allergies <> 'None'
GROUP BY Allergies
ORDER BY frequency DESC;

#Failed vs Successful Treatments by Type
SELECT TreatmentType1, Outcome, COUNT(*) AS count
FROM axon_healthcare.treatment
GROUP BY TreatmentType1, Outcome
ORDER BY TreatmentType1;

#Top 5 Doctor-wise Patient Count based on specialty
SELECT *
FROM (
    SELECT 
        d.doctor_name,
        d.specialty,
        COUNT(DISTINCT v.PatientID) AS patient_count,
        ROW_NUMBER() OVER (PARTITION BY d.specialty ORDER BY COUNT(DISTINCT v.PatientID) DESC) AS rn
    FROM axon_healthcare.visit v
    JOIN axon_healthcare.doctors d ON v.DoctorID = d.doctor_id
    GROUP BY d.doctor_name, d.specialty
) ranked
WHERE rn <= 5
ORDER BY specialty, patient_count DESC;

Desc axon_healthcare.doctors;

