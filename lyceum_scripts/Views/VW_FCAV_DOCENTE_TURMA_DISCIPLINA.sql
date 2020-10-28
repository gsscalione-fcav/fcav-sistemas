--* ***************************************************************  
--*  
--*  ***VIEW VW_FCAV_DOCENTE_TURMA_DISCIPLINA ***  
--*   
--* DESCRICAO:  
--* - View que trás as informações de turma e as disciplinas que o professor está ministrando.  
--* Tanto do Lyceum como do Icoruja, através do UNION e Linked Server.  
--*  
--* PARAMETROS:  
--* - Sem parâmetro  
--*   
--* USO:  
--*  - O uso será para o academico e para o Helbert na parte do Moodle  
--*  
--* ALTERAÇÕES:  
--*  10.03.2014 - Acrescentado a data de inicio de disciplina e o docente que irá ministra-la.  
--*  14.01.2015 - Alterado a consulta referente a parte do Icoruja para trazer todos os docentes cadastrados nas disciplinas.  
--*  05.05.2015 - Adicionado filtro no Select para as disciplinas do Lyceum para trazer apenas turmas como "Aberta"  
--*  
--* Autor: Gabriel S. Scalione  
--* Data de criação: 11/12/2013  
--*  
--* ***************************************************************  
  
--USE LYCEUM  
  
--IF OBJECT_ID ('VW_FCAV_DOCENTE_TURMA_DISCIPLINA','V') IS NOT NULL  
-- DROP VIEW VW_FCAV_DOCENTE_TURMA_DISCIPLINA  
--GO  
  
    
CREATE VIEW VW_FCAV_DOCENTE_TURMA_DISCIPLINA AS    
SELECT    
 TUR.CURSO AS CURSO,    
 TUR.TURMA,    
 CAST(TUR.ANO AS VARCHAR)+ '/' + CAST(TUR.SEMESTRE AS VARCHAR)AS ANO_SEMESTRE,    
 TUR.DISCIPLINA AS DISCIPLINA,    
 DIS.NOME AS NOME_DISCIPLINA,    
 MIN(DATA) AS DATA_INICIO_DISCIPLINA,    
 DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(LTRIM(RTRIM(DOC.NOME_COMPL))) AS DOCENTE,    
 CPF AS CPF,    
 LOWER(E_MAIL) AS E_MAIL,    
 'Lyceum' AS SISTEMA    
FROM    
 LY_TURMA TUR    
 INNER JOIN LY_DISCIPLINA DIS ON (TUR.DISCIPLINA = DIS.DISCIPLINA)    
 INNER JOIN LY_AGENDA AGE ON (TUR.TURMA = AGE.TURMA AND TUR.DISCIPLINA = AGE.DISCIPLINA AND TUR.SEMESTRE = AGE.SEMESTRE)    
 INNER JOIN LY_DOCENTE DOC ON (DOC.NUM_FUNC = AGE.NUM_FUNC)    
  
WHERE TUR.CLASSIFICACAO != 'Cancelada'  
  
GROUP BY     
 TUR.CURSO, TUR.TURMA, TUR.ANO, TUR.SEMESTRE, TUR.DISCIPLINA, DIS.NOME, DOC.NOME_COMPL, CPF, E_MAIL    
  
-- A PARTE ABAIXO TRAZIA OS DADOS DO ICORUJA E HOJE NÃO SERÁ MAIS NECESSÁRIO.  
     
--UNION    
--------------------------------------------    
----ICORUJA    
--SELECT DISTINCT    
-- CUR_CODCUR collate Latin1_General_CI_AI AS CURSO,    
-- TUR_CODTUR collate Latin1_General_CI_AI AS TURMA,    
-- PEL_DESCRI collate Latin1_General_CI_AI AS ANO_SEMESTRE,    
-- DIS_DISTEL collate Latin1_General_CI_AI AS DISCIPLINA,    
-- DIS_DESDIS collate Latin1_General_CI_AI AS NOME_DISCIPLINA,    
-- (    
--  SELECT --consulta tosca para trazer a data inicial das disciplinas    
--   CAD_DATA     
--   FROM    
--   LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CRONOGRAMA_AULA_MESTRE    
--   INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CRONOGRAMA_AULA_DATA on (CAM_ID = CAD_CAMID)    
--   INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CRONOGRAMA_AULA ON (CAU_CADID = CAD_ID)    
--   INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CRONOGRAMA_AULA_PROF on (CAP_CAUID = CAU_ID)    
--   INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_TURMA_DISCIP on (CAM_TDIID = TDI_TURDISID)    
--   INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_DISCIPLINA DISC2 on (TDI_DISCID = DIS_DISID)    
--   INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_TURMA TUR2 on (TDI_TURID = TUR_ID)    
--  WHERE    
--   CAU_NROAULA = '1'     
--   AND DISC2.DIS_DISTEL = DISC1.DIS_DISTEL     
--   AND TUR2.TUR_CODTUR = TUR1.TUR_CODTUR     
--  GROUP BY CAD_DATA    
-- ) AS DATA_INICIO_DISCIPLINA,    
-- dbo.FN_FCAV_PRIMEIRA_MAIUSCULA(LTRIM(RTRIM(PES_NOME))) collate Latin1_General_CI_AI AS DOCENTE,    
-- PES_NRODOC1 collate Latin1_General_CI_AI AS CPF,    
-- LOWER(PES_EMAIL) collate Latin1_General_CI_AI AS E_MAIL,    
-- 'Icoruja' as SISTEMA    
--FROM    
-- LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CRONOGRAMA_AULA_MESTRE    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CRONOGRAMA_AULA_DATA on (CAM_ID = CAD_CAMID)    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CRONOGRAMA_AULA ON (CAU_CADID = CAD_ID)    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CRONOGRAMA_AULA_PROF on (CAP_CAUID = CAU_ID)    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_PESSOA on (CAP_PESID = PES_ID)    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_TURMA_DISCIP on (CAM_TDIID = TDI_TURDISID)    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_DISCIPLINA DISC1 on (TDI_DISCID = DIS_DISID)    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_TURMA TUR1 on (TDI_TURID = TUR_ID)    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_PERIODO_LETIVO ON (TUR_PERID = PEL_PERID)    
-- INNER JOIN LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_CURSO ON (TUR_CURID = CUR_ID)    
--GROUP BY     
-- CUR_CODCUR, TUR_CODTUR, PEL_DESCRI, DIS_DESDIS, DIS_DISTEL, PES_NOME, PES_NRODOC1, PES_EMAIL