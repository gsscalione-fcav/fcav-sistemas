
--truncate table FCAV_IMPORTCONF_DEB_CRED

--select * 
-- into FCAV_IMPORTCONF_DEB_CRED
--from FCAV_IMPORT_DEB_CRED
truncate table FCAV_IMPORTCONF_DEB_CRED

WITH CONF_DEBITO
AS (SELECT
    IMP_COBRANCA,
    SUM(CAST(VALOR AS money)) AS VALOR
FROM FCAV_IMPORT_DEB_CRED
WHERE TIPO_LANC = '1'
GROUP BY IMP_COBRANCA),

CONF_CRED
AS (SELECT
    IMP_COBRANCA,
    SUM(CAST(VALOR AS money)) * -1 AS VALOR
FROM FCAV_IMPORT_DEB_CRED
WHERE TIPO_LANC = '2'
GROUP BY IMP_COBRANCA),

CONF_SUM
AS (SELECT
    CD.IMP_COBRANCA,
    SUM(ISNULL(CD.VALOR, '0,00') + ISNULL(CC.VALOR, '0,00')) AS CALC
FROM CONF_DEBITO CD
LEFT OUTER JOIN CONF_CRED CC
    ON CD.IMP_COBRANCA = CC.IMP_COBRANCA
GROUP BY CD.IMP_COBRANCA)
SELECT
    TEMP.*
FROM FCAV_IMPORT_DEB_CRED TEMP
INNER JOIN CONF_SUM CONF
    ON TEMP.IMP_COBRANCA = CONF.IMP_COBRANCA
WHERE CONF.CALC <> 0

