-- CASO 1: INFORME ANÁLISIS DE FACTURAS
SELECT
    NUMFACTURA                                      AS "N° Factura",
    TO_CHAR(FECHA, 'DD "de" Month', 'NLS_DATE_LANGUAGE=SPANISH') AS "Fecha Emisión",
    LPAD(RUTCLIENTE, 10, '0')                       AS "RUT Cliente",
    TO_CHAR(NETO, 'FML999G999G990', 'NLS_CURRENCY=$') AS "Monto Neto",
    TO_CHAR(IVA, 'FML999G999G990', 'NLS_CURRENCY=$')  AS "Monto Iva",
    TO_CHAR(TOTAL, 'FML999G999G990', 'NLS_CURRENCY=$') AS "Total Factura",
    CASE
        WHEN TOTAL <= 50000 THEN 'Bajo'
        WHEN TOTAL > 50000 AND TOTAL <= 100000 THEN 'Medio'
        ELSE 'Alto'
    END                                             AS "Categoría Monto",
    CASE CODPAGO
        WHEN 1 THEN 'EFECTIVO'
        WHEN 2 THEN 'TARJETA DEBITO'
        WHEN 3 THEN 'TARJETA CREDITO'
        ELSE 'CHEQUE'
    END                                             AS "Forma de pago"
FROM
    FACTURA
WHERE
    EXTRACT(YEAR FROM FECHA) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY
    FECHA DESC,
    NETO DESC;
    
    
    
-- CASO 2: INFORME CLASIFICACIÓN DE CLIENTES

SELECT
    LPAD(RUTCLIENTE, 14, '*')                       AS "RUT",
    NOMBRE                                          AS "Cliente",
    NVL(TO_CHAR(TELEFONO), 'Sin teléfono')           AS "TELÉFONO",
    NVL(TO_CHAR(CODCOMUNA), 'Sin comuna')            AS "COMUNA",
    ESTADO                                          AS "ESTADO",
    CASE
        WHEN (SALDO / CREDITO) < 0.5 THEN 'Bueno (' || TO_CHAR(CREDITO - SALDO, 'FML999G999G990', 'NLS_CURRENCY=$') || ')'
        WHEN (SALDO / CREDITO) BETWEEN 0.5 AND 0.8 THEN 'Regular (' || TO_CHAR(SALDO, 'FML999G999G990', 'NLS_CURRENCY=$') || ')'
        ELSE 'Crítico'
    END                                             AS "Estado Crédito",
    NVL(UPPER(SUBSTR(MAIL, INSTR(MAIL, '@') + 1)), 'Correo no registrado') AS "Dominio Correo"
FROM
    CLIENTE
WHERE
    ESTADO = 'A' AND CREDITO > 0
ORDER BY
    NOMBRE ASC;
    
-- CASO 3: INFORME STOCK DE PRODUCTOS
SELECT
    CODPRODUCTO                                     AS "ID",
    DESCRIPCION                                     AS "Descripción de Producto",
    NVL(TO_CHAR(VALORCOMPRADOLAR, '9G990D00') || ' USD', 'Sin registro') AS "Compra en USD",
    NVL(TO_CHAR(ROUND(VALORCOMPRADOLAR * &TIPOCAMBIO_DOLAR), 'FML999G999G990', 'NLS_CURRENCY=$') || ' PESOS', 'Sin registro') AS "USD convertido",
    TOTALSTOCK                                      AS "Stock",
    CASE
        WHEN TOTALSTOCK IS NULL THEN 'Sin datos'
        WHEN TOTALSTOCK < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
        WHEN TOTALSTOCK BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END                                             AS "Alerta Stock",
    CASE
        WHEN TOTALSTOCK > 80 THEN TO_CHAR(ROUND(VUNITARIO * 0.9), 'FML999G999G990', 'NLS_CURRENCY=$') 
        ELSE 'N/A'
    END                                             AS "Precio Oferta"
FROM
    PRODUCTO
WHERE
    LOWER(DESCRIPCION) LIKE '%zapato%' AND PROCEDENCIA = 'I' 
ORDER BY
    CODPRODUCTO DESC;
