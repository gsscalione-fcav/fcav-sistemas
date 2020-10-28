--* ***************************************************************              
--*              
--*  *** VIEW VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA ***              
--*               
--* DESCRICAO:              
--* - Versão 2 da mesma view, mas agora trazendo os que estão somente na LY_HISTMATRICULA          
--*              
--* PARAMETROS:              
--* -             
--*              
--* USO:              
--* - Relatório financeiro que traz info do Microsiga e do Lyceum gerado no Microsiga.           
--*              
--* ALTERAÇÕES:            
--*  13/03/2017: Retirado o filtro que impedia de trazer os alunos que possuem teste no nome. Gabriel        
--*  31/08/2017: Ajuste da view pois estava trazendo resultado em duplicidade. Gabriel      
--*              
--*         select * from VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA2 where turma = 'CEQP T 55' AND SIT_MATRICULA = 'Matriculado' and tipo_ingresso != 'Dependência' and sit_detalhe = 'Curricular'    
--* Autor: João Paulo              
--* Data de criação: 06/05/2016          
--*              
--* ***************************************************************              
ALTER VIEW VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA         
AS          
          
      
WITH RESUMO_MATRICULA_E_PRE_MATRICULA      
AS (SELECT          
    AL.CURSO,                  
    MA.TURMA,          
    AL.PESSOA,          
    AL.CANDIDATO,          
    MA.ALUNO,          
    AL.NOME_COMPL,          
    AL.ANO_INGRESSO,          
    AL.SEM_INGRESSO,          
    AL.SIT_ALUNO,          
    AL.DT_INGRESSO AS DT_MATRICULA,          
    CASE          
        WHEN SIT_MATRICULA LIKE 'Aprovado' OR          
            SIT_MATRICULA LIKE 'Rep Nota' OR          
            SIT_MATRICULA LIKE 'Rep Freq' OR          
            SIT_MATRICULA LIKE 'Trancado' THEN 'Matriculado'          
        ELSE SIT_MATRICULA          
    END AS SIT_MATRICULA,      
    SIT_DETALHE,      
    'S' AS ALOCADO,          
    AL.TIPO_INGRESSO,          
    AL.TURMA_PREF          
          
FROM LY_MATRICULA MA          
INNER JOIN LY_ALUNO AL          
    ON (AL.ALUNO = MA.ALUNO)         
          
WHERE NOME_COMPL NOT LIKE '%teste%'          
AND MA.SIT_MATRICULA NOT LIKE 'Dispensado'          
AND AL.SIT_ALUNO NOT LIKE 'Cancelado'          
          
GROUP BY AL.CURSO,                
         MA.TURMA,          
         AL.PESSOA,          
         AL.CANDIDATO,          
         MA.ALUNO,          
         AL.DT_INGRESSO,          
         AL.NOME_COMPL,          
         AL.ANO_INGRESSO,          
         AL.SEM_INGRESSO,          
         AL.SIT_ALUNO,          
         SIT_MATRICULA,      
         SIT_DETALHE,          
         AL.TIPO_INGRESSO,          
         AL.TURMA_PREF          
          
UNION ALL          
          
SELECT       ----Traz os alunos que estão no histórico, são alunos de turmas que tiveram o fechamento do período letivo.                
    AL.CURSO,              
    HI.TURMA,          
    AL.PESSOA,          
    AL.CANDIDATO,          
    HI.ALUNO,          
    AL.NOME_COMPL,          
    AL.ANO_INGRESSO,          
    AL.SEM_INGRESSO,          
    AL.SIT_ALUNO,          
    AL.DT_INGRESSO AS DT_MATRICULA,          
    CASE          
        WHEN SITUACAO_HIST LIKE 'Aprovado' OR          
            SITUACAO_HIST LIKE 'Rep Nota' OR          
            SITUACAO_HIST LIKE 'Rep Freq' OR          
            SITUACAO_HIST LIKE 'Trancado' THEN 'Matriculado'          
        ELSE SITUACAO_HIST          
    END AS SIT_MATRICULA,      
    SIT_DETALHE,         
    'S' AS ALOCADO,          
    AL.TIPO_INGRESSO,          
    AL.TURMA_PREF          
FROM LY_HISTMATRICULA HI          
INNER JOIN LY_ALUNO AL          
    ON (AL.ALUNO = HI.ALUNO)          
          
WHERE NOME_COMPL NOT LIKE '%teste%'          
AND HI.SITUACAO_HIST NOT LIKE 'Dispensado'          
AND AL.SIT_ALUNO NOT LIKE 'Cancelado'          
          
GROUP BY AL.CURSO,                  
         HI.TURMA,          
         AL.PESSOA,          
         AL.CANDIDATO,          
         HI.ALUNO,          
         AL.NOME_COMPL,          
         AL.ANO_INGRESSO,          
         AL.SEM_INGRESSO,          
         AL.SIT_ALUNO,         
         AL.DT_INGRESSO,          
   SITUACAO_HIST,      
         SIT_DETALHE,      
         AL.TIPO_INGRESSO,          
         AL.TURMA_PREF          
          
UNION ALL          
          
          
SELECT          
    AL.CURSO,                 
    PM.TURMA,          
    AL.PESSOA,          
    AL.CANDIDATO,          
    PM.ALUNO,          
    AL.NOME_COMPL,          
    AL.ANO_INGRESSO,          
    AL.SEM_INGRESSO,          
    AL.SIT_ALUNO,          
    AL.DT_INGRESSO AS DT_MATRICULA,          
    'Pre-Matriculado' SIT_MATRICULA,      
    PM.SIT_DETALHE,         
    PM.ALOCADO,          
    AL.TIPO_INGRESSO,          
    AL.TURMA_PREF          
FROM LY_PRE_MATRICULA PM          
INNER JOIN LY_ALUNO AL          
    ON (PM.ALUNO = AL.ALUNO)          
          
WHERE NOME_COMPL NOT LIKE '%teste%'          
--AND MA.SIT_MATRICULA NOT LIKE 'Dispensado'               
--AND AL.ALUNO = 'C201500253'             
AND AL.SIT_ALUNO NOT LIKE 'Cancelado'          
          
GROUP BY AL.CURSO,          
         AL.TURNO,          
         AL.CURRICULO,          
         PM.TURMA,          
         AL.PESSOA,          
         AL.CANDIDATO,          
         PM.ALUNO,          
         AL.NOME_COMPL,          
         AL.ANO_INGRESSO,          
         AL.SEM_INGRESSO,          
         AL.SIT_ALUNO,          
         AL.DT_INGRESSO,          
		 PM.SIT_DETALHE,         
         PM.ALOCADO,          
         AL.TIPO_INGRESSO,          
         AL.TURMA_PREF          
          
UNION ALL          
          
SELECT          
          
    AL.CURSO,              
    AL.TURMA_PREF,          
    AL.PESSOA,          
    AL.CANDIDATO,          
    AL.ALUNO,          
    AL.NOME_COMPL,          
    AL.ANO_INGRESSO,          
    AL.SEM_INGRESSO,          
    AL.SIT_ALUNO,          
    AL.DT_INGRESSO AS DT_MATRICULA,          
    'Cancelado' AS SIT_MATRICULA,          
    'NA' ALOCADO,      
    'Cancelado' AS SIT_DETALHE,      
    AL.TIPO_INGRESSO,          
    AL.TURMA_PREF          
FROM LY_ALUNO AL          
          
WHERE NOME_COMPL NOT LIKE '%teste%'          
AND AL.SIT_ALUNO LIKE 'Cancelado'          
          
GROUP BY AL.CURSO,          
         AL.TURNO,          
         AL.CURRICULO,          
         AL.PESSOA,          
         AL.CANDIDATO,          
         AL.ALUNO,          
         AL.NOME_COMPL,          
         AL.ANO_INGRESSO,          
         AL.SEM_INGRESSO,          
         AL.SIT_ALUNO,          
         AL.DT_INGRESSO,          
         AL.TIPO_INGRESSO,          
         AL.TURMA_PREF) --FIM WITH          
          
          
--------------------------------------------------------------------------------          
SELECT        
    VT.UNIDADE_FISICA AS FACULDADE,          
    VT.CONCURSO,          
    VT.OFERTA_DE_CURSO,          
    VT.UNIDADE_RESPONSAVEL,          
    VT.CURSO,          
    VT.TURNO,          
    VT.CURRICULO,          
    VT.TURMA,          
    (SELECT TOP 1          
        CASE          
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND          
                VT.DT_INICIO > GETDATE() THEN 'Em Inscrição'          
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND          
                (GETDATE() BETWEEN MIN(VT.DT_INICIO) AND max(VT.DT_FIM)) THEN 'Em Andamento'          
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND          
                VT.DT_FIM <= GETDATE() THEN 'Concluido'          
   WHEN CLASSIFICACAO LIKE 'Desativada%' THEN 'Concluido'      
            WHEN CLASSIFICACAO LIKE 'Cancel%' THEN 'Cancelada'  
      
        END              FROM LY_TURMA TU          
    WHERE TU.TURMA = VT.TURMA        
    AND TU.SERIE = 1          
    GROUP BY DT_INICIO,CLASSIFICACAO)          
    AS STATUS_TURMA,          
    PM.PESSOA,          
    PM.CANDIDATO,          
    PM.ALUNO,          
    PM.NOME_COMPL,          
    PM.ANO_INGRESSO,          
    PM.SEM_INGRESSO,          
    PM.SIT_ALUNO,          
    PM.DT_MATRICULA,      
    PM.SIT_MATRICULA,          
    PM.SIT_DETALHE,      
    PM.ALOCADO,          
    PM.TIPO_INGRESSO,         
    PM.TURMA_PREF          
FROM RESUMO_MATRICULA_E_PRE_MATRICULA PM          
INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT  
    ON VT.TURMA = PM.TURMA
INNER JOIN LY_TURMA T
	ON   T.TURMA = VT.TURMA
	AND T.CURRICULO = VT.CURRICULO
--where ALUNO = 'A202000094'
GROUP BY        
 VT.UNIDADE_FISICA,          
    VT.CONCURSO,          
    VT.OFERTA_DE_CURSO,          
    VT.UNIDADE_RESPONSAVEL,         
    VT.TURMA,         
    VT.CURSO,          
    VT.TURNO,          
    VT.CURRICULO,          
    VT.TURMA,    
	PM.TURMA,           
    PM.PESSOA,          
    PM.CANDIDATO,          
    PM.ALUNO,          
    PM.NOME_COMPL,          
    PM.ANO_INGRESSO,          
    PM.SEM_INGRESSO,          
    PM.SIT_ALUNO,          
    PM.DT_MATRICULA,          
    PM.SIT_MATRICULA,      
    PM.SIT_DETALHE,          
    PM.ALOCADO,          
    PM.TIPO_INGRESSO,          
    PM.TURMA_PREF,        
    VT.DT_INICIO,        
    VT.DT_FIM