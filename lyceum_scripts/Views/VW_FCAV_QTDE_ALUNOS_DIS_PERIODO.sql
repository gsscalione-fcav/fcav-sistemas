IF EXISTS (SELECT * 
           FROM   sys.VIEWS 
           WHERE  NAME = 'VW_FCAV_QTDE_ALUNOS_DIS_PERIODO') 
  DROP VIEW VW_FCAV_QTDE_ALUNOS_DIS_PERIODO 

go 


CREATE VIEW VW_FCAV_QTDE_ALUNOS_DIS_PERIODO
AS 

SELECT
	TU.UNIDADE_RESPONSAVEL,
	QA.DISCIPLINA,
	QA.NOME_DISCIPLINA,
	QA.CURSO,
	QA.TURMA,
	QA.ANO,
	QA.SEMESTRE,
	QA.NUM_FUNC AS COD_DOCENTE,
	QA.DOCENTE,
	TU.DT_INICIO,
	TU.DT_FIM,
	DBO.FN_FCAV_DIA_SEMANA_EXT(TU.DT_INICIO) AS DIA_SEMANA,
	SUM(quantidade_alunos_ativos) AS QTDE_ALUNOS_ATIVOS,
	SUM(quantidade_alunos_trancados) AS QTDE_ALUNOS_TRANCADOS,
	SUM(quantidade_alunos_desistentes) AS QTDE_ALUNOS_DESISTENTES
	
FROM 
	VW_FCAV_QUANTIDADE_ALUNOS_DISCIPLINAS QA
	INNER JOIN LY_TURMA TU
		ON TU.DISCIPLINA = QA.DISCIPLINA
		AND TU.TURMA = QA.TURMA
		AND TU.NUM_FUNC = QA.NUM_FUNC
		AND TU.ANO = QA.ANO
		AND TU.SEMESTRE = QA.SEMESTRE
		
GROUP BY 
	QA.ANO,
	QA.SEMESTRE,
	TU.DT_INICIO,
	TU.DT_FIM,
	TU.UNIDADE_RESPONSAVEL,
	QA.CURSO,
	QA.TURMA,
	QA.DISCIPLINA,
	QA.NOME_DISCIPLINA,
	QA.NUM_FUNC,
	QA.DOCENTE
	