-- PRY2205_Exp1_S3_Grupo17_DiegoAlvarez.sql
-- Autor: Diego Alvarez
-- Asignatura: PRY2205 - Consulta de Bases de Datos
-- Semana 3 - Aplicando funciones de agrupación
-- Descripción: Solución de los casos 1, 2 y 3 para ASOCIADOS

SELECT 
    TO_CHAR(numrut_cli, '99G999G999') || '-' || dvrut_cli AS "RUT Cliente",
    INITCAP(nombre_cli) || ' ' || INITCAP(appaterno_cli) || ' ' || INITCAP(apmaterno_cli) AS "Nombre Completo Cliente",
    INITCAP(direccion_cli) AS "Dirección Cliente",
    '$' || TO_CHAR(renta_cli, '999G999') AS "Renta Cliente",
    SUBSTR(TO_CHAR(celular_cli), 1, 2) || '-' || SUBSTR(TO_CHAR(celular_cli), 3, 3) || '-' || SUBSTR(TO_CHAR(celular_cli), 6) AS "Celular Cliente",  
    CASE 
        WHEN renta_cli > 500000 THEN 'TRAMO 1'
        WHEN renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        ELSE 'TRAMO 4'
    END AS "Trama Renta Cliente"
FROM CLIENTE
WHERE renta_cli BETWEEN &RENTA_MINIMA AND &RENTA_MAXIMA
  AND celular_cli IS NOT NULL
ORDER BY "Nombre Completo Cliente" ASC;

-- CASO 2: Sueldo Promedio por Categoría de Empleado

SELECT 
    ce.id_categoria_emp                                         AS "CODIGO_CATEGORIA",
    ce.desc_categoria_emp                                       AS "DESCRIPCION_CATEGORIA",
    COUNT(e.numrut_emp)                                         AS "CANTIDAD_EMPLEADOS",
    CASE 
        WHEN s.id_sucursal = 10 THEN 'Sucursal Las Condes'
        WHEN s.id_sucursal = 20 THEN 'Sucursal Santiago Centro'
        WHEN s.id_sucursal = 30 THEN 'Sucursal Providencia'
        WHEN s.id_sucursal = 40 THEN 'Sucursal Vitacura'
    END                                                         AS "SUCURSAL",
    '$' || TO_CHAR(ROUND(AVG(e.sueldo_emp)), '9G999G999')       AS "SUELDO_PROMEDIO"
FROM EMPLEADO e
JOIN CATEGORIA_EMPLEADO ce ON e.id_categoria_emp = ce.id_categoria_emp
JOIN SUCURSAL s          ON e.id_sucursal      = s.id_sucursal
GROUP BY ce.id_categoria_emp,
         ce.desc_categoria_emp,
         s.id_sucursal
HAVING AVG(e.sueldo_emp) > &SUELDO_PROMEDIO_MINIMO
ORDER BY AVG(e.sueldo_emp) DESC;


--CASO 3: Arriendo Promedio por Tipo de Propiedad


SELECT 
    tp.id_tipo_propiedad                                        AS "CODIGO_TIPO",
    CASE 
        WHEN tp.id_tipo_propiedad = 'A' THEN 'CASA'
        WHEN tp.id_tipo_propiedad = 'B' THEN 'DEPARTAMENTO'
        WHEN tp.id_tipo_propiedad = 'C' THEN 'LOCAL'
        WHEN tp.id_tipo_propiedad = 'D' THEN 'PARCELA SIN CASA'
        WHEN tp.id_tipo_propiedad = 'E' THEN 'PARCELA CON CASA'
    END                                                         AS "DESCRIPCION_TIPO",
    COUNT(p.nro_propiedad)                                      AS "TOTAL_PROPIEDADES",
    '$' || TO_CHAR(ROUND(AVG(p.valor_arriendo)), '999G999G999') AS "PROMEDIO_ARRIENDO",
    TO_CHAR(ROUND(AVG(p.superficie), 2), '999D99')              AS "PROMEDIO_SUPERFICIE",
    '$' || TO_CHAR(ROUND(AVG(p.valor_arriendo / p.superficie)), '999G999') AS "VALOR_ARRIENDO_M2",
    CASE 
        WHEN AVG(p.valor_arriendo / p.superficie) < 5000  THEN 'Económico'
        WHEN AVG(p.valor_arriendo / p.superficie) <= 10000 THEN 'Medio'
        ELSE 'Alto'
    END                                                         AS "CLASIFICACION"
FROM PROPIEDAD p
JOIN TIPO_PROPIEDAD tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
WHERE p.superficie > 0
GROUP BY tp.id_tipo_propiedad
HAVING AVG(p.valor_arriendo / p.superficie) > 1000
ORDER BY AVG(p.valor_arriendo / p.superficie) DESC;

