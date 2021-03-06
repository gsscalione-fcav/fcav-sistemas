
--* ***************************************************************
--*
--*	
--* Finalidade: Consulta histórico academico dos alunos de especialização. 
--*				Utilizado para o relatório da secretaria
--*	
--*	
--*	Autor: Gabriel S. Scalione
--*	Criado: 12/09/2017
--*
--* ***************************************************************


SELECT
	AL.ALUNO,
	PE.NOME_COMPL,
	isnull(CONVERT(VARCHAR, PE.DT_NASC, 103),'-') AS DT_NASC,
	PE.RG_NUM,
    DI.NOME_COMPL AS DISCIPLINA,
    DO.NOME_COMPL AS DOCENTE,
    AL.CURSO,
    CT.TURMA,
    HI.ANO,
    HI.SEMESTRE,
    isnull(CONVERT(VARCHAR, MIN(CT.DT_INICIO), 103),'-') AS DT_INICIO,
    isnull(CONVERT(VARCHAR, MAX(CT.DT_FIM), 103),'-') AS DT_FIM, 
    CONVERT(DECIMAL(10,2), STR(HI.NOTA_FINAL,15,2)) as NOTA_FINAL,
    CONVERT(DECIMAL(10,2), HI.PERC_PRESENCA*100) AS FREQUENCIA,
    HI.SITUACAO_HIST
FROM LY_ALUNO AL
INNER JOIN LY_HISTMATRICULA HI
	ON AL.ALUNO = HI.ALUNO
INNER JOIN LY_PESSOA PE
	ON PE.PESSOA = AL.PESSOA
INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA CT
	ON CT.TURMA = HI.TURMA
	AND CT.TURNO = AL.TURNO
	AND CT.CURSO = AL.CURSO
	AND CT.CURRICULO = AL.CURRICULO
INNER JOIN LY_AGENDA AG
	ON AG.DISCIPLINA = HI.DISCIPLINA
	AND AG.TURMA = HI.TURMA
	AND AG.ANO = HI.ANO
	AND AG.SEMESTRE = HI.SEMESTRE
INNER JOIN LY_DOCENTE DO
	ON DO.NUM_FUNC = AG.NUM_FUNC
INNER JOIN LY_DISCIPLINA DI
	ON DI.DISCIPLINA= HI.DISCIPLINA
--WHERE
--	CT.UNIDADE_RESPONSAVEL = 'ESPEC'
GROUP BY
	DI.NOME_COMPL,
	AL.ALUNO,
	PE.NOME_COMPL,
	PE.DT_NASC,
	PE.RG_NUM,
    HI.ANO,
    HI.SEMESTRE,
    DO.NOME_COMPL,
    AL.CURSO,
    CT.TURMA,
    CT.DT_INICIO,
    CT.DT_FIM,
    HI.NOTA_FINAL,
    HI.PERC_PRESENCA,
    HI.SITUACAO_HIST
   

UNION ALL

SELECT
	AL.ALUNO,
	PE.NOME_COMPL,
	ISNULL(CONVERT(VARCHAR, PE.DT_NASC, 103),'-') AS DT_NASC,
	PE.RG_NUM,
    DI.NOME_COMPL AS DISCIPLINA,
    DO.NOME_COMPL AS DOCENTE,
    AL.CURSO,
    CT.TURMA,
    MA.ANO,
    MA.SEMESTRE,
    ISNULL(CONVERT(VARCHAR, MIN(CT.DT_INICIO), 103),'-') AS DT_INICIO,
    ISNULL(CONVERT(VARCHAR, MAX(CT.DT_FIM), 103),'-') AS DT_FIM, 
    CONVERT(DECIMAL(10,2), ISNULL(STR(MA.CONCEITO_FIM,15,2),0)) as NOTA_FINAL,
    CONVERT(DECIMAL(10,2), ISNULL(MA.PERC_PRESFIM,0)*100) AS FREQUENCIA,
    MA.SIT_MATRICULA AS SITUACAO_HIST
FROM LY_ALUNO AL
INNER JOIN LY_MATRICULA MA
	ON MA.ALUNO = AL.ALUNO 
INNER JOIN LY_PESSOA PE
	ON PE.PESSOA = AL.PESSOA
INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA CT
	ON CT.TURMA = MA.TURMA
	AND CT.TURNO = AL.TURNO
	AND CT.CURSO = AL.CURSO
	AND CT.CURRICULO = AL.CURRICULO
INNER JOIN LY_AGENDA AG
	ON AG.DISCIPLINA = MA.DISCIPLINA
	AND AG.TURMA = MA.TURMA
	AND AG.ANO = MA.ANO
	AND AG.SEMESTRE = MA.SEMESTRE
INNER JOIN LY_DOCENTE DO
	ON DO.NUM_FUNC = AG.NUM_FUNC
INNER JOIN LY_DISCIPLINA DI
	ON DI.DISCIPLINA= MA.DISCIPLINA
--WHERE
--	CT.UNIDADE_RESPONSAVEL = 'ESPEC'
GROUP BY
	DI.NOME_COMPL,
	AL.ALUNO,
	PE.NOME_COMPL,
	PE.DT_NASC,
	PE.RG_NUM,
    MA.ANO,
    MA.SEMESTRE,
    DO.NOME_COMPL,
    AL.CURSO,
    CT.TURMA,
    CT.DT_INICIO,
    CT.DT_FIM,
    MA.CONCEITO_FIM,
    MA.PERC_PRESFIM,
    MA.SIT_MATRICULA