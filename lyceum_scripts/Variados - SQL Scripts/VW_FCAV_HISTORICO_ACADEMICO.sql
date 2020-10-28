  
--* ***************************************************************    
--*    
--*  ***VIEW VW_FCAV_HISTORICO_ACADEMICO ***    
--*     
--* Finalidade: Consulta histórico academico dos alunos, por disciplina e docente.     
--*    Utilizado para o relatório da secretaria    
--*     
--*  SELECT * FROM VW_FCAV_HISTORICO_ACADEMICO WHERE ALUNO = 'E201420082'    
--*     
--* Autor: Gabriel S. Scalione    
--* Criado: 12/09/2017    
--*    
--* ***************************************************************    
  
ALTER VIEW VW_FCAV_HISTORICO_ACADEMICO  
AS  
  
SELECT  
    AL.ALUNO,  
    AL.NOME_COMPL,  
    ISNULL(CONVERT(varchar, PE.DT_NASC, 103), '-') AS DT_NASC,  
    PE.RG_NUM,  
    AL.CURSO,  
    MA.TURMA,  
    (SELECT  
        ISNULL(CONVERT(varchar, MIN(CT.DT_INICIO), 103), '-')  
    FROM VW_FCAV_INI_FIM_CURSO_TURMA CT  
    WHERE CT.TURMA = MA.TURMA)  
    AS DT_INICIO,  
    (SELECT  
        ISNULL(CONVERT(varchar, MAX(CT.DT_FIM), 103), '-')  
    FROM VW_FCAV_INI_FIM_CURSO_TURMA CT  
    WHERE CT.TURMA = MA.TURMA)  
    AS DT_FIM,  
    MA.ANO,  
    MA.SEMESTRE,  
    DI.NOME_COMPL AS DISCIPLINA,  
    DO.NOME_COMPL AS DOCENTE,  
    MA.SIT_MATRICULA AS SITUACAO_HIST,  
    MA.SIT_DETALHE,  
    CASE  
        WHEN DI.TEM_NOTA = 'N' THEN 10.00  
        WHEN MA.CONCEITO_FIM = 'A' THEN 10.00  
        WHEN MA.CONCEITO_FIM = 'R' THEN 0.00  
        ELSE CONVERT(decimal(10, 2), ISNULL(STR(MA.CONCEITO_FIM, 15, 2), 0))  
    END AS NOTA_FINAL,  
    CASE WHEN DI.TEM_FREQ = 'N' THEN 100.00  
		 ELSE CONVERT(decimal(10, 2), ISNULL(MA.PERC_PRESFIM, 0) * 100)   
	END AS FREQUENCIA  
FROM LY_ALUNO AL  
INNER JOIN LY_MATRICULA MA  
    ON MA.ALUNO = AL.ALUNO  
INNER JOIN LY_PESSOA PE  
    ON PE.PESSOA = AL.PESSOA  
INNER JOIN LY_AGENDA AG  
    ON AG.DISCIPLINA = MA.DISCIPLINA  
    AND AG.TURMA = MA.TURMA  
    AND AG.ANO = MA.ANO  
    AND AG.SEMESTRE = MA.SEMESTRE  
INNER JOIN LY_DOCENTE DO  
    ON DO.NUM_FUNC = AG.NUM_FUNC  
INNER JOIN LY_CURSO CS  
    ON CS.CURSO = AL.CURSO  
INNER JOIN LY_DISCIPLINA DI  
    ON DI.DISCIPLINA = MA.DISCIPLINA  
   
GROUP BY AL.ALUNO,  
         AL.NOME_COMPL,  
         PE.RG_NUM,  
         PE.DT_NASC,  
         AL.CURSO,  
         MA.TURMA,  
         MA.ANO,  
         MA.SEMESTRE,  
         MA.DISCIPLINA,  
         DI.TEM_NOTA,  
         DI.TEM_FREQ,  
         DI.NOME_COMPL,  
         DO.NOME_COMPL,  
         MA.SIT_MATRICULA,  
         MA.SIT_DETALHE,  
         MA.CONCEITO_FIM,  
         MA.PERC_PRESFIM  
  
UNION ALL  
  
SELECT  
    AL.ALUNO,  
    AL.NOME_COMPL,  
    ISNULL(CONVERT(varchar, PE.DT_NASC, 103), '-') AS DT_NASC,  
    PE.RG_NUM,  
    AL.CURSO,  
    HI.TURMA,  
    (SELECT  
        ISNULL(CONVERT(varchar, MIN(CT.DT_INICIO), 103), '-')  
    FROM VW_FCAV_INI_FIM_CURSO_TURMA CT  
    WHERE CT.TURMA = HI.TURMA)  
    AS DT_INICIO,  
    (SELECT  
        ISNULL(CONVERT(varchar, MAX(CT.DT_FIM), 103), '-')  
    FROM VW_FCAV_INI_FIM_CURSO_TURMA CT  
    WHERE CT.TURMA = HI.TURMA)  
    AS DT_FIM,  
    HI.ANO,  
    HI.SEMESTRE,  
    DI.NOME_COMPL AS DISCIPLINA,  
    DO.NOME_COMPL AS DOCENTE,  
    HI.SITUACAO_HIST,  
    HI.SIT_DETALHE,  
    CASE  
  WHEN DI.TEM_NOTA = 'N' THEN 10.00  
        WHEN HI.NOTA_FINAL = 'A' THEN 10.00  
        WHEN HI.NOTA_FINAL = 'R' THEN 0.00  
        ELSE CONVERT(decimal(10, 2), STR(HI.NOTA_FINAL, 15, 2))  
    END AS NOTA_FINAL,  
 CASE WHEN DI.TEM_FREQ = 'N' THEN 100.00   
    ELSE CONVERT(decimal(10, 2), HI.PERC_PRESENCA * 100)   
    END AS FREQUENCIA  
FROM LY_ALUNO AL  
INNER JOIN LY_HISTMATRICULA HI  
    ON HI.ALUNO = AL.ALUNO  
INNER JOIN LY_PESSOA PE  
    ON PE.PESSOA = AL.PESSOA  
INNER JOIN LY_AGENDA AG  
    ON  AG.DISCIPLINA = HI.DISCIPLINA  
    AND AG.TURMA = HI.TURMA  
    AND AG.ANO = HI.ANO  
    AND AG.SEMESTRE = HI.SEMESTRE  
INNER JOIN LY_DOCENTE DO  
    ON DO.NUM_FUNC = AG.NUM_FUNC  
INNER JOIN LY_CURSO CS  
    ON CS.CURSO = AL.CURSO  
INNER JOIN LY_DISCIPLINA DI  
    ON DI.DISCIPLINA = HI.DISCIPLINA  

GROUP BY AL.ALUNO,  
         AL.NOME_COMPL,  
         PE.RG_NUM,  
         PE.DT_NASC,  
         AL.CURSO,  
         HI.TURMA,  
         HI.ANO,  
         HI.SEMESTRE,  
         DI.NOME_COMPL,  
         DI.TEM_NOTA,  
         DI.TEM_FREQ,  
         DO.NOME_COMPL,  
         HI.SITUACAO_HIST,  
         HI.SIT_DETALHE,  
         HI.NOTA_FINAL,  
         HI.PERC_PRESENCA