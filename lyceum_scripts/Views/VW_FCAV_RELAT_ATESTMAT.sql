/*  
 VIEW VW_FCAV_RELAT_ATESTMAT   
  
Finalidade: Trazer a rela��o de alunos para o relat�rio de Atestado e Declara��o de Matr�cula emitido pelo Lyceum.
  
Altera��es:  Foi retirado a rela�ao dos Alunos do CEAI, pois o per�odo � diferente. Gabriel 30/08/2019
  
Autor: Jo�o Paulo  
Data: 2018-11-12  
  
  
SELECT * FROM VW_FCAV_RELAT_ATESTMAT WHERE aluno in ('E201910015') order by aluno, ano, semestre  
SELECT * FROM VW_FCAV_MATR_PRE_E_HIST_SERIE WHERE aluno = 'E201720014'  
  
SELECT CASE WHEN (select count(v2.semestre) from VW_FCAV_MATR_PRE_E_HIST_SERIE v2   
  GROUP BY ANO, ALUNO, SEMESTRE HAVING count(v2.semestre) > 2) > 2 THEN 1  
  ELSE 0 END   
     
  
*/  
   
  
ALTER VIEW VW_FCAV_RELAT_ATESTMAT AS  
  
WITH PERIODO_CURSO AS  
(  
 SELECT   
  TU.TURMA,  
  TU.SERIE,  
  TU.ANO,  
  TU.SEMESTRE,  
  MIN(TU.DT_INICIO) AS INICIO,  
  MAX(TU.DT_FIM) AS FIM  
 FROM   
  LY_TURMA TU  
 WHERE   
  UNIDADE_RESPONSAVEL IN ('ATUAL','CAPAC','DIFUS')  
 GROUP BY  
  TU.TURMA,  
  TU.ANO,  
  TU.SEMESTRE,  
  TU.SERIE

 UNION ALL  
 
 SELECT   
  TU.TURMA,  
  TU.SERIE,  
  TU.ANO,  
  TU.SEMESTRE,  
  MIN(CT.DT_INICIO) AS INICIO,  
  MAX(CT.DT_FIM) AS FIM  
 FROM   
  LY_TURMA TU 
  INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA CT 
	ON CT.TURMA = TU.TURMA
 WHERE  
  TU.UNIDADE_RESPONSAVEL = 'ESPEC'  
  AND TU.SEMESTRE IN (1,2,3)  
 GROUP BY  
  TU.TURMA,  
  TU.ANO,  
  TU.SEMESTRE,  
  TU.SERIE  
    
 )  

SELECT distinct--top 1  
 case when tur.CURSO = 'CEAI' then  
  DENSE_RANK() OVER (PARTITION BY VW.ALUNO ORDER BY VW.ANO, VW.SEMESTRE, VW.TURMA)  
 else  
  DENSE_RANK() OVER (PARTITION BY VW.ALUNO ORDER BY VW.ANO, VW.SEMESTRE)  
  
 END AS PERIODO1,   
 VW.ALUNO, AL.NOME_COMPL AS ALU_NOME,  
 VW.ANO, VW.SEMESTRE,  
 ISNULL(PES.RG_NUM, 'RG_NAO_CADASTRADO') AS RG_NUM, 
 CPF, CURSO.NOME,  
 TUR.CURSO,  
 CASE WHEN CURSO.FACULDADE = 'ATUAL' THEN 'Atualiza��o'  
  WHEN CURSO.FACULDADE = 'CAPAC' THEN 'Capacita��o'  
  WHEN CURSO.FACULDADE = 'ESPEC' THEN 'Especializa��o'  
 END AS UNID_RESP,  
 TUR.TURNO,  
 TUR.CURRICULO,  
 TUR.TURMA,  
 CAST(CURR.AULAS_PREVISTAS AS numeric) AS CARGA_HOR,  
 dbo.FN_FCAV_NUM_EXTENSO(CURR.AULAS_PREVISTAS) AS CARGA_HOR_EXT,  
 LOWER(CONVERT(VARCHAR,dbo.FN_FCAV_MES_EXT(MONTH(TUR.DT_INICIO))) +     
  ' � ' + CONVERT(VARCHAR,DBO.FN_FCAV_MES_EXT(MONTH(TUR.DT_FIM))) +     
  ' de ' + CONVERT(VARCHAR,YEAR(TUR.DT_FIM))) AS PERIODO,  
   
  LOWER(CONVERT(VARCHAR,dbo.FN_FCAV_MES_EXT(MONTH(PER.INICIO))) +   
 ' de ' + CONVERT(VARCHAR,YEAR(PER.INICIO))  +  
 ' � ' + CONVERT(VARCHAR,DBO.FN_FCAV_MES_EXT(MONTH(PER.FIM))) +     
 ' de ' + CONVERT(VARCHAR,YEAR(PER.FIM)))   
  AS PERIODO_CURSO,  
  
   (SELECT DESCR FROM HADES.dbo.HD_TABELAITEM WHERE TABELA = 'Gerentes' and ITEM = 'Educa��o') as GERENTE  
FROM VW_FCAV_MATR_PRE_E_HIST_SERIE VW  
INNER JOIN LY_ALUNO AL ON VW.ALUNO = AL.ALUNO  AND AL.CURSO !='CEAI'
INNER JOIN LY_PESSOA PES ON AL.PESSOA = PES.PESSOA  
INNER JOIN LY_CURSO CURSO ON AL.CURSO = CURSO.CURSO AND CURSO.FACULDADE NOT IN ('PALES')  AND CURSO.CURSO !='CEAI'
INNER JOIN LY_TURMA TUR ON VW.TURMA = TUR.TURMA AND VW.ANO = TUR.ANO AND VW.SEMESTRE = TUR.SEMESTRE  
INNER JOIN LY_CURRICULO CURR ON CURR.CURSO = TUR.CURSO AND CURR.TURNO = TUR.TURNO AND CURR.CURRICULO = TUR.CURRICULO  
INNER JOIN PERIODO_CURSO PER ON TUR.TURMA = PER.TURMA AND TUR.ANO = PER.ANO AND TUR.SEMESTRE = PER.SEMESTRE AND TUR.SERIE = PER.SERIE  
 
--WHERE 
--	AL.ALUNO = 'E201730100'
GROUP BY   
 VW.ALUNO, AL.NOME_COMPL,  
 VW.ANO, VW.SEMESTRE, VW.TURMA,  
 PES.RG_NUM, CPF, CURSO.NOME,  
 TUR.CURSO,  
 TUR.TURNO,  
 tur.UNIDADE_RESPONSAVEL,  
 CURSO.FACULDADE,  
 TUR.CURRICULO,  
 TUR.TURMA,  
 TUR.DT_INICIO,  
 TUR.DT_FIM,  
 CURR.AULAS_PREVISTAS,  
 PER.INICIO,  
 PER.FIM  
--ORDER BY PERIODO1 DESC,  
--  TUR.DT_FIM DESC  