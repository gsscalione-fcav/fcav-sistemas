/*    
 View para consultar os Centros de Custos cadastros na Turma, Hades e MicroSiga.    
     
*/    
    
ALTER VIEW VW_FCAV_CENTRO_CUSTO_TURMA_HADES_SIGA    
AS    
    
SELECT    
 T.TURMA,    
 (SELECT TOP 1 T2.CLASSIFICACAO FROM LY_TURMA T2 WHERE T2.TURMA = T.TURMA AND T2.SERIE = 1) AS SIT_TURMA,     
 (SELECT TOP 1 min(VT.DT_INICIO) FROM LY_TURMA VT WHERE VT.TURMA = T.TURMA group by TURMA) AS DT_INICIO_TURMA,     
 T.CENTRO_DE_CUSTO AS TURMA_CC,    
     
 DESCR AS HADES_TURMA,    
 ITEM as HADES_CC,     
     
     
 LEFT(C.CTT_DESC01,20) AS SIGA_TURMA,    
 C.CTT_CUSTO  AS SIGA_CC,    
     
 CASE WHEN T.CENTRO_DE_CUSTO = ITEM     
    AND T.CENTRO_DE_CUSTO = C.CTT_CUSTO collate Latin1_General_CI_AI    
    AND C.CTT_CUSTO collate Latin1_General_CI_AI = ITEM    
  THEN 'OK'    
  ELSE     
   'NAO_OK'    
  END AS CADASTRO    
     
from     
 HD_TABELAITEM H    
 LEFT JOIN LY_TURMA T ON REPLACE(REPLACE(REPLACE(REPLACE(H.DESCR,' ',''),'.',''),':',''),'-','') =    
       REPLACE(REPLACE(REPLACE(REPLACE(T.TURMA,' ',''),'.',''),':',''),'-','') OR    
       T.CENTRO_DE_CUSTO = ITEM    
 LEFT JOIN DADOSADVP12.dbo.CTT010 C ON REPLACE(REPLACE(REPLACE(REPLACE(C.CTT_DESC01,' ',''),'.',''),':',''),'-','') collate Latin1_General_CI_AI =     
                 REPLACE(REPLACE(REPLACE(REPLACE(H.DESCR,' ',''),'.',''),':',''),'-','') OR    
                 C.CTT_CUSTO collate Latin1_General_CI_AI = ITEM    
WHERE     
 TABELA LIKE '%CENTRO%CUSTO%'     
 --AND T.ANO >= 2016    
 AND T.SERIE = 1    
 AND (SELECT TOP 1  YEAR(min(VT.DT_INICIO)) FROM LY_TURMA VT WHERE VT.TURMA = T.TURMA group by TURMA ) >= 2016    
 AND (SELECT TOP 1 T2.CLASSIFICACAO FROM LY_TURMA T2 WHERE T2.TURMA = T.TURMA AND T2.SERIE = 1)NOT LIKE 'Cancel%'    
 --AND (SELECT TOP 1 T2.CLASSIFICACAO FROM LY_TURMA T2 WHERE T2.TURMA = T.TURMA AND T2.SERIE = 1)NOT LIKE 'EmAndamento'    
 --AND DESCR LIKE 'A-FAI45001.18 T 05%'    
 --AND ITEM IN('630030514', '600033615','630010615 ')    
GROUP BY     
 T.TURMA,    
 T.ANO,    
 --T.CLASSIFICACAO,    
 T.CENTRO_DE_CUSTO,    
 DESCR,    
 ITEM,    
 C.CTT_DESC01,    
 C.CTT_CUSTO    
    
     