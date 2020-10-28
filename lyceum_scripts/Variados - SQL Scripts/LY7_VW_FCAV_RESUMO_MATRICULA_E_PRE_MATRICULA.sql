--* ***************************************************************      
--*      
--*  *** VIEW VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA where aluno = 'E201420120'sit_matricula = 'trancado'***      
--*       
--* DESCRICAO:      
--* - View criada para que trazer de forma resumida a situação das matriculas dos alunos em cada turma.    
--*      
--* PARAMETROS:      
--* -     
--*      
--* USO:      
--* - O uso será para trazer a situação dos alunos nas turmas    
--*      
--* ALTERAÇÕES:      
--*      --Traz também os alunos do histórico
--*      
--* Autor: Gabriel      
--* Data de criação: 07/11/2014      
--*      
--* ***************************************************************      
ALTER VIEW VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA  
AS  

SELECT     
 T.FACULDADE,      
 AL.CURSO,      
 AL.TURNO,      
 AL.CURRICULO,      
 PM.TURMA,  
 CASE WHEN V.DT_FIM < GETDATE() THEN 'Concluido'  
   WHEN V.DT_FIM > GETDATE() THEN 'EmAndamento'  
 END AS STATUS_TURMA,   
 V.CONCURSO,  
 V.OFERTA_DE_CURSO,      
 AL.PESSOA,    
 AL.CANDIDATO,     
 PM.ALUNO,    
 AL.NOME_COMPL,    
 AL.ANO_INGRESSO,    
 AL.SEM_INGRESSO,  
 AL.SIT_ALUNO,  
 PM.DT_INSERCAO AS DT_MATRICULA,    
 'Pre-Matriculado' SIT_MATRICULA,  
 PM.SIT_DETALHE,  
 PM.ALOCADO,  
 AL.TIPO_INGRESSO,  
 AL.TURMA_PREF,  
 T.UNIDADE_RESPONSAVEL  
FROM       
 LY_PRE_MATRICULA PM      
 INNER JOIN LY_ALUNO AL ON (PM.ALUNO = AL.ALUNO)      
 INNER JOIN LY_TURMA T ON PM.TURMA = T.TURMA  
 INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA V ON V.TURMA = T.TURMA  
    
WHERE     
 NOME_COMPL NOT LIKE '%teste%'    
 --AND MA.SIT_MATRICULA NOT LIKE 'Dispensado'   
 --AND AL.ALUNO = 'C201500253'  
 AND AL.SIT_ALUNO NOT LIKE 'Cancelado'    
 
GROUP BY
	 T.FACULDADE,      
 AL.CURSO,      
 AL.TURNO,      
 AL.CURRICULO,      
 PM.TURMA,  
 V.DT_FIM ,  
 V.CONCURSO,  
 V.OFERTA_DE_CURSO,      
 AL.PESSOA,    
 AL.CANDIDATO,     
 PM.ALUNO,    
 AL.NOME_COMPL,    
 AL.ANO_INGRESSO,    
 AL.SEM_INGRESSO,  
 AL.SIT_ALUNO,  
 PM.DT_INSERCAO,
 PM.SIT_DETALHE,  
 PM.ALOCADO,  
 AL.TIPO_INGRESSO,  
 AL.TURMA_PREF,  
 T.UNIDADE_RESPONSAVEL 
     
    
UNION  ALL

SELECT     
 T.FACULDADE,      
 AL.CURSO,      
 AL.TURNO,      
 AL.CURRICULO,      
 T.TURMA,  
 CASE wHEN V.DT_FIM < GETDATE() THEN 'Concluido'  
   when V.DT_FIM > GETDATE() THEN 'EmAndamento'  
 END AS STATUS_TURMA,  
 V.CONCURSO,  
 V.OFERTA_DE_CURSO,    
 AL.PESSOA,    
 AL.CANDIDATO,     
 MA.ALUNO,   
 AL.NOME_COMPL,    
 AL.ANO_INGRESSO,    
 AL.SEM_INGRESSO,  
 AL.SIT_ALUNO,  
 MA.DT_MATRICULA AS DT_MATRICULA,    
  CASE WHEN SIT_MATRICULA LIKE 'Aprovado'       
     OR SIT_MATRICULA LIKE 'Rep Nota'       
     OR SIT_MATRICULA LIKE 'Rep Freq' THEN 'Matriculado'      
   ELSE SIT_MATRICULA      
 END AS SIT_MATRICULA,  
 SIT_DETALHE,  
 'S' ALOCADO,  
 AL.TIPO_INGRESSO,  
 AL.TURMA_PREF,  
 T.UNIDADE_RESPONSAVEL  
FROM       
 LY_ALUNO AL   
 INNER JOIN LY_MATRICULA MA ON (AL.ALUNO = MA.ALUNO)      
 INNER JOIN LY_TURMA T ON MA.TURMA = T.TURMA  
 INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA V ON V.TURMA = T.TURMA  

WHERE     
 NOME_COMPL NOT LIKE '%teste%'    
 AND MA.SIT_MATRICULA NOT LIKE 'Dispensado'  
 AND AL.SIT_ALUNO NOT LIKE 'Cancelado'    
 --AND AL.ALUNO = 'E201410036'
GROUP BY
 T.FACULDADE,      
 AL.CURSO,      
 AL.TURNO,      
 AL.CURRICULO,      
 T.TURMA,  
 V.DT_FIM, 
 V.CONCURSO,  
 V.OFERTA_DE_CURSO,    
 AL.PESSOA,    
 AL.CANDIDATO,     
 MA.ALUNO,
 MA.DT_MATRICULA, 
 AL.NOME_COMPL,    
 AL.ANO_INGRESSO,    
 AL.SEM_INGRESSO,  
 AL.SIT_ALUNO,  
 AL.DT_INGRESSO,    
 SIT_MATRICULA,  
 SIT_DETALHE,  
 AL.TIPO_INGRESSO,  
 AL.TURMA_PREF,  
 T.UNIDADE_RESPONSAVEL 

UNION ALL 
    
SELECT       ----Traz os alunos que estão no histórico, são alunos de turmas que tiveram o fechamento do período letivo.    
 T.FACULDADE,      
 AL.CURSO,      
 AL.TURNO,      
 AL.CURRICULO,      
 HI.TURMA,  
  CASE WHEN V.DT_FIM < GETDATE() THEN 'Concluido'  
    WHEN V.DT_FIM >= GETDATE() THEN 'EmAndamento'  
 END AS STATUS_TURMA,     
 V.CONCURSO,  
 V.OFERTA_DE_CURSO,       
 AL.PESSOA,    
 AL.CANDIDATO,     
 HI.ALUNO,    
 AL.NOME_COMPL,    
 AL.ANO_INGRESSO,    
 AL.SEM_INGRESSO,   
 AL.SIT_ALUNO,   
 HI.DT_MATRICULA AS DT_MATRICULA,    
  CASE WHEN SITUACAO_HIST LIKE 'Aprovado'       
     OR SITUACAO_HIST LIKE 'Rep Nota'       
     OR SITUACAO_HIST LIKE 'Rep Freq' THEN 'Matriculado'      
   ELSE SITUACAO_HIST      
 END AS SIT_MATRICULA,  
 SIT_DETALHE,  
 'S' ALOCADO,  
 AL.TIPO_INGRESSO,  
 AL.TURMA_PREF,  
 T.UNIDADE_RESPONSAVEL  
FROM       
 LY_HISTMATRICULA HI      
 INNER JOIN LY_ALUNO AL ON (AL.ALUNO = HI.ALUNO)      
 INNER JOIN LY_TURMA T ON HI.TURMA = T.TURMA  
 INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA V ON V.TURMA = T.TURMA  
  
WHERE     
 NOME_COMPL NOT LIKE '%teste%'    
 AND HI.SITUACAO_HIST NOT LIKE 'Dispensado'  
 --AND SITUACAO_HIST NOT LIKE 'Aprovado'       
 --AND SITUACAO_HIST NOT LIKE 'Rep Nota'       
 --AND SITUACAO_HIST NOT LIKE 'Rep Freq'   
 --AND AL.ALUNO = 'E201410050'  
 --AND T.TURMA = 'CEGI-T-18'  
 AND AL.SIT_ALUNO not like 'Cancelado'  
 
 GROUP BY
 
 T.FACULDADE,      
 AL.CURSO,      
 AL.TURNO,      
 AL.CURRICULO,      
 HI.TURMA,  
 V.DT_FIM,     
 V.CONCURSO,  
 V.OFERTA_DE_CURSO,       
 AL.PESSOA,    
 AL.CANDIDATO,     
 HI.ALUNO,    
 AL.NOME_COMPL,    
 AL.ANO_INGRESSO,    
 AL.SEM_INGRESSO,   
 AL.SIT_ALUNO,   
 HI.DT_MATRICULA,    
 SITUACAO_HIST,
 SIT_DETALHE,  
 AL.TIPO_INGRESSO,  
 AL.TURMA_PREF,  
 T.UNIDADE_RESPONSAVEL  
   
UNION  ALL
  
SELECT    
 T.FACULDADE,      
 AL.CURSO,      
 AL.TURNO,      
 AL.CURRICULO,      
 T.TURMA,   
   CASE wHEN V.DT_FIM < GETDATE() THEN 'Concluido'  
   when V.DT_FIM > GETDATE() THEN 'EmAndamento'  
 END AS STATUS_TURMA,      
 V.CONCURSO,  
 V.OFERTA_DE_CURSO,       
 AL.PESSOA,    
 AL.CANDIDATO,     
 AL.ALUNO,    
 AL.NOME_COMPL,    
 AL.ANO_INGRESSO,    
 AL.SEM_INGRESSO,  
 AL.SIT_ALUNO,  
 AL.DT_INGRESSO AS DT_MATRICULA,    
 'Cancelado' AS SIT_MATRICULA,  
 'Curricular' as SIT_DETALHE,  
 'NA' ALOCADO,  
 AL.TIPO_INGRESSO,  
 AL.TURMA_PREF,  
 T.UNIDADE_RESPONSAVEL  
FROM       
 LY_ALUNO AL   
 INNER JOIN LY_TURMA T on t.TURMA = AL.TURMA_PREF  
 INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA V ON V.TURMA = T.TURMA  
    
WHERE     
 NOME_COMPL NOT LIKE '%teste%'    
 AND AL.SIT_ALUNO LIKE 'Cancelado'   
 --AND AL.ALUNO = 'c201500572'   
 
GROUP BY

 T.FACULDADE,      
 AL.CURSO,      
 AL.TURNO,      
 AL.CURRICULO,      
 T.TURMA,   
 V.DT_FIM,      
 V.CONCURSO,  
 V.OFERTA_DE_CURSO,       
 AL.PESSOA,    
 AL.CANDIDATO,     
 AL.ALUNO,    
 AL.NOME_COMPL,    
 AL.ANO_INGRESSO,    
 AL.SEM_INGRESSO,  
 AL.SIT_ALUNO,  
 AL.DT_INGRESSO,     
 AL.TIPO_INGRESSO,  
 AL.TURMA_PREF,  
 T.UNIDADE_RESPONSAVEL  