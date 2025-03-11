CREATE DATABASE Sandelys;
USE Sandelys;

CREATE TEMPORARY TABLE sandelio_operacijos_temp (
    data DATE,
    savaites_diena VARCHAR(20),
    sandelis VARCHAR(50),
    uzduociu_skaicius INT,
    isveztu_paleciu_skaicius FLOAT,
    isrusiuotu_pakuociu_skaicius INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ex.3_cleaned.csv'
INTO TABLE sandelio_operacijos_temp
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM sandelio_operacijos_temp LIMIT 10;

CREATE TABLE sandelio_operacijos (
    data DATE,
    savaites_diena VARCHAR(20),
    sandelis VARCHAR(50),
    uzduociu_skaicius INT,
    isveztu_paleciu_skaicius FLOAT,
    isrusiuotu_pakuociu_skaicius INT
);

INSERT INTO sandelio_operacijos
SELECT * FROM sandelio_operacijos_temp;

SELECT * FROM sandelio_operacijos LIMIT 10;

-- 1. Apskaičiuojame kiekvieno sandėlio bendras sumas pagal tris rodiklius
SELECT 
    sandelis,
    SUM(uzduociu_skaicius) AS total_uzduotys,
    SUM(isveztu_paleciu_skaicius) AS total_paletes,
    SUM(isrusiuotu_pakuociu_skaicius) AS total_pakuotes
FROM sandelio_operacijos
GROUP BY sandelis
ORDER BY total_uzduotys DESC;



-- 2. Apskaičiuojame kiekvieno sandėlio vidutines reikšmes pagal tris rodiklius
SELECT 
    sandelis,
    AVG(uzduociu_skaicius) AS vidutines_uzduotys,
    AVG(isveztu_paleciu_skaicius) AS vidutines_paletes,
    AVG(isrusiuotu_pakuociu_skaicius) AS vidutines_pakuotes
FROM sandelio_operacijos
GROUP BY sandelis
ORDER BY vidutines_uzduotys DESC;



-- 3. Apskaičiuojame kiekvieno sandėlio mažiausias ir didžiausias reikšmes pagal tris rodiklius
SELECT 
    sandelis,
    MIN(uzduociu_skaicius) AS min_uzduotys,
    MAX(uzduociu_skaicius) AS max_uzduotys,
    MIN(isveztu_paleciu_skaicius) AS min_paletes,
    MAX(isveztu_paleciu_skaicius) AS max_paletes,
    MIN(isrusiuotu_pakuociu_skaicius) AS min_pakuotes,
    MAX(isrusiuotu_pakuociu_skaicius) AS max_pakuotes
FROM sandelio_operacijos
GROUP BY sandelis;



-- 4. Randame savaitės dieną su didžiausiu užduočių skaičiumi
SELECT 
    savaites_diena,
    SUM(uzduociu_skaicius) AS total_uzduotys
FROM sandelio_operacijos
GROUP BY savaites_diena
ORDER BY total_uzduotys DESC;


-- 5. Kuri savaitės diena turi daugiausiai išvežtų palečių?
SELECT 
    savaites_diena,
    SUM(isveztu_paleciu_skaicius) AS total_paletes
FROM sandelio_operacijos
GROUP BY savaites_diena
ORDER BY total_paletes DESC;


-- 6. Kuri savaitės diena turi daugiausiai išrūšiuotų pakuočių?
SELECT 
    savaites_diena,
    SUM(isrusiuotu_pakuociu_skaicius) AS total_pakuotes
FROM sandelio_operacijos
GROUP BY savaites_diena
ORDER BY total_pakuotes DESC;



-- 7. Apskaičiuojame, kuris sandėlis dirba efektyviausiai
SELECT 
    sandelis,
    SUM(isveztu_paleciu_skaicius) / SUM(uzduociu_skaicius) AS paletes_per_uzduotis,  -- Vidutinis išvežtų palečių skaičius per vieną užduotį
    SUM(isrusiuotu_pakuociu_skaicius) / SUM(uzduociu_skaicius) AS pakuotes_per_uzduotis  -- Vidutinis išrūšiuotų pakuočių skaičius per vieną užduotį
FROM sandelio_operacijos
GROUP BY sandelis
ORDER BY paletes_per_uzduotis DESC;


-- 8. Randame sandėlius, kurių darbo krūvis labiausiai svyruoja
SELECT 
    sandelis,
    MAX(isveztu_paleciu_skaicius) - MIN(isveztu_paleciu_skaicius) AS paletes_skirtumas,  -- Skirtumas tarp max ir min išvežtų palečių
    MAX(isrusiuotu_pakuociu_skaicius) - MIN(isrusiuotu_pakuociu_skaicius) AS pakuotes_skirtumas  -- Skirtumas tarp max ir min išrūšiuotų pakuočių
FROM sandelio_operacijos
GROUP BY sandelis
ORDER BY paletes_skirtumas DESC;



-- 9.  dienas su anomaliai dideliu užduočių skaičiumi
SELECT 
    data,
    SUM(uzduociu_skaicius) AS total_uzduotys
FROM sandelio_operacijos
GROUP BY data
HAVING total_uzduotys > (SELECT AVG(uzduociu_skaicius) * 1.5 FROM sandelio_operacijos)
ORDER BY total_uzduotys DESC
LIMIT 10;



-- 10. Randame, kurie sandėliai apkrauti skirtingomis savaitės dienomis
SELECT 
    sandelis,
    savaites_diena,
    SUM(uzduociu_skaicius) AS total_uzduotys
FROM sandelio_operacijos
GROUP BY sandelis, savaites_diena
ORDER BY sandelis, total_uzduotys DESC;

-- 10.a. diena su maksimaliu užduočių skaičiumi:
SELECT t.sandelis, t.savaites_diena, t.total_uzduotys
FROM (
    SELECT 
        sandelis,
        savaites_diena,
        SUM(uzduociu_skaicius) AS total_uzduotys,
        RANK() OVER (PARTITION BY sandelis ORDER BY SUM(uzduociu_skaicius) DESC) AS rnk
    FROM sandelio_operacijos
    GROUP BY sandelis, savaites_diena
) t
WHERE t.rnk = 1
ORDER BY total_uzduotys DESC;

-- 11. Randame, kurios savaitės dienos yra labiausiai apkrautos pagal vidutinius rodiklius
SELECT 
    savaites_diena,
    AVG(isveztu_paleciu_skaicius) AS vidutines_paletes,  -- Vidutinis išvežtų palečių skaičius
    AVG(isrusiuotu_pakuociu_skaicius) AS vidutines_pakuotes  -- Vidutinis išrūšiuotų pakuočių skaičius
FROM sandelio_operacijos
GROUP BY savaites_diena
ORDER BY vidutines_paletes DESC;


-- 12. Randame, kurie sandėliai tam tikromis savaitės dienomis patiria perkrovą
SELECT 
    sandelis,
    savaites_diena,
    SUM(uzduociu_skaicius) AS total_uzduotys,
    (SELECT AVG(uzduociu_skaicius) FROM sandelio_operacijos WHERE sandelio_operacijos.sandelis = so.sandelis) AS avg_uzduotys,
    SUM(uzduociu_skaicius) / (SELECT AVG(uzduociu_skaicius) FROM sandelio_operacijos WHERE sandelio_operacijos.sandelis = so.sandelis) AS uzduotys_vs_avg
FROM sandelio_operacijos so
GROUP BY sandelis, savaites_diena
HAVING uzduotys_vs_avg > 2
ORDER BY uzduotys_vs_avg DESC;


-- 13. Randame, kurie sandėliai tam tikrais mėnesiais patiria didžiausią apkrovą
SELECT 
    MONTH(data) AS menuo,
    sandelis,
    SUM(uzduociu_skaicius) AS total_uzduotys
FROM sandelio_operacijos
GROUP BY menuo, sandelis
ORDER BY total_uzduotys DESC;


-- 14. Randame dienas, kai užduočių skaičius buvo mažiausias
SELECT 
    data,
    SUM(uzduociu_skaicius) AS total_uzduotys
FROM sandelio_operacijos
GROUP BY data
ORDER BY total_uzduotys ASC
LIMIT 10;


-- 15. Randame sandėlius, kurių darbo krūvis labiausiai svyruoja
SELECT 
    sandelis,
    STDDEV(uzduociu_skaicius) AS uzduociu_std,
    STDDEV(isveztu_paleciu_skaicius) AS paletes_std,
    STDDEV(isrusiuotu_pakuociu_skaicius) AS pakuotes_std
FROM sandelio_operacijos
GROUP BY sandelis
ORDER BY uzduociu_std DESC;


-- 16. Randame savaitines užduočių tendencijas
SELECT 
    YEARWEEK(data) AS savaite,
    SUM(uzduociu_skaicius) AS total_uzduotys
FROM sandelio_operacijos
GROUP BY savaite
ORDER BY savaite ASC;


-- 17. Apskaičiuojame procentinį skirtumą tarp našiausio ir silpniausio sandėlio
WITH produktyvumas AS (
    -- Skaičiuojame bendrą užduočių skaičių kiekviename sandėlyje
    SELECT 
        sandelis,
        SUM(uzduociu_skaicius) AS viso_uzduotys
    FROM sandelio_operacijos
    GROUP BY sandelis
),
max_prod AS (
    -- Randame sandėlį su didžiausiu užduočių skaičiumi
    SELECT MAX(viso_uzduotys) AS max_uzduotys FROM produktyvumas
),
min_prod AS (
    -- Randame sandėlį su mažiausiu užduočių skaičiumi
    SELECT MIN(viso_uzduotys) AS min_uzduotys FROM produktyvumas
)
SELECT 
    (SELECT max_uzduotys FROM max_prod) AS stipriausias_sandelis,
    (SELECT min_uzduotys FROM min_prod) AS silpniausias_sandelis,
    ((SELECT max_uzduotys FROM max_prod) - (SELECT min_uzduotys FROM min_prod)) / (SELECT max_uzduotys FROM max_prod) * 100 AS procentinis_skirtumas
FROM produktyvumas
LIMIT 1;










































