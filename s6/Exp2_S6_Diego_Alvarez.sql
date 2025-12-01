-- Actividad Sumativa Semana 6
-- Diego Alvarez
-- PRY2205 Consulta de Bases de Datos


-- CASO 1: Reporteria de Asesorias
-- profesionales que trabajaron en Banca (sector 3) Y Retail (sector 4)

SELECT 
    p.id_profesional AS "ID",
    p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre AS "PROFESIONAL",
    COUNT(CASE WHEN s.cod_sector = 3 THEN 1 END) AS "NRO ASESORIA BANCA",
    '$' || TO_CHAR(SUM(CASE WHEN s.cod_sector = 3 THEN a.honorario ELSE 0 END), 'FM999G999G999') AS "MONTO_TOTAL_BANCA",
    COUNT(CASE WHEN s.cod_sector = 4 THEN 1 END) AS "NRO ASESORIA RETAIL",
    '$' || TO_CHAR(SUM(CASE WHEN s.cod_sector = 4 THEN a.honorario ELSE 0 END), 'FM999G999G999') AS "MONTO_TOTAL_RETAIL",
    COUNT(*) AS "TOTAL ASESORIAS",
    '$' || TO_CHAR(SUM(a.honorario), 'FM999G999G999') AS "TOTAL HONORARIOS"
FROM 
    profesional p
    JOIN asesoria a ON p.id_profesional = a.id_profesional
    JOIN empresa e ON a.cod_empresa = e.cod_empresa
    JOIN sector s ON e.cod_sector = s.cod_sector
WHERE 
    p.id_profesional IN (
        SELECT a1.id_profesional
        FROM asesoria a1
        JOIN empresa e1 ON a1.cod_empresa = e1.cod_empresa
        WHERE e1.cod_sector = 3
        INTERSECT
        SELECT a2.id_profesional
        FROM asesoria a2
        JOIN empresa e2 ON a2.cod_empresa = e2.cod_empresa
        WHERE e2.cod_sector = 4
    )
    AND s.cod_sector IN (3, 4)
GROUP BY 
    p.id_profesional, 
    p.appaterno, 
    p.apmaterno, 
    p.nombre
ORDER BY 
    p.id_profesional ASC;


-- CASO 2: Resumen de Honorarios
-- crear tabla REPORTE_MES con asesorias finalizadas en abril del año pasado

DROP TABLE REPORTE_MES;

CREATE TABLE REPORTE_MES AS
SELECT 
    p.id_profesional AS ID_PROF,
    p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre AS NOMBRE_COMPLETO,
    pr.nombre_profesion AS NOMBRE_PROFESION,
    c.nom_comuna AS NOM_COMUNA,
    COUNT(a.id_profesional) AS NRO_ASESORIAS,
    ROUND(SUM(a.honorario)) AS MONTO_TOTAL_HONORARIOS,
    ROUND(AVG(a.honorario)) AS PROMEDIO_HONORARIO,
    ROUND(MIN(a.honorario)) AS HONORARIO_MINIMO,
    ROUND(MAX(a.honorario)) AS HONORARIO_MAXIMO
FROM 
    profesional p
    JOIN profesion pr ON p.cod_profesion = pr.cod_profesion
    JOIN comuna c ON p.cod_comuna = c.cod_comuna
    JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE 
    EXTRACT(MONTH FROM a.fin_asesoria) = 4
    AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY 
    p.id_profesional,
    p.appaterno, 
    p.apmaterno, 
    p.nombre,
    pr.nombre_profesion,
    c.nom_comuna
ORDER BY 
    p.id_profesional ASC;

SELECT * FROM REPORTE_MES;


-- CASO 3: Modificacion de Honorarios
-- actualizar sueldo segun honorarios de marzo del año pasado
-- < 1.000.000 -> +10%
-- >= 1.000.000 -> +15%

-- reporte antes de actualizar
SELECT 
    SUM(a.honorario) AS HONORARIO,
    p.id_profesional,
    p.numrun_prof,
    p.sueldo
FROM 
    profesional p
    JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE 
    EXTRACT(MONTH FROM a.fin_asesoria) = 3
    AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY 
    p.id_profesional, 
    p.numrun_prof, 
    p.sueldo
ORDER BY 
    p.id_profesional;

-- update
UPDATE profesional p
SET sueldo = ROUND(
    sueldo + sueldo * (
        CASE 
            WHEN (
                SELECT SUM(a.honorario)
                FROM asesoria a
                WHERE a.id_profesional = p.id_profesional
                  AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
                  AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
            ) < 1000000 
            THEN 0.10
            ELSE 0.15
        END
    )
)
WHERE EXISTS (
    SELECT 1 
    FROM asesoria a
    WHERE a.id_profesional = p.id_profesional
      AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
      AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
);

COMMIT;

-- reporte despues de actualizar
SELECT 
    SUM(a.honorario) AS HONORARIO,
    p.id_profesional,
    p.numrun_prof,
    p.sueldo
FROM 
    profesional p
    JOIN asesoria a ON p.id_profesional = a.id_profesional
WHERE 
    EXTRACT(MONTH FROM a.fin_asesoria) = 3
    AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY 
    p.id_profesional, 
    p.numrun_prof, 
    p.sueldo
ORDER BY 
    p.id_profesional;
