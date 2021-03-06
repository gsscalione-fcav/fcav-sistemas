/*
	VIEW VW_FCAV_AVAL_PARTICIPANTES

Finalidade: Rela��o de alunos matriculados que participaram da avalia��o de curso.

SELECT * FROM VW_FCAV_AVAL_PARTICIPANTES WHERE TURMA = 'CEAI - 2020/2' and 

SELECT * FROM VW_FCAV_AVAL_PARTICIPANTES WHERE TURMA = 'CELOG T 29'

SELECT * FROM LY_ALUNO WHERE ALUNO = 'C201700439'
SELECT * FROM LY_HISTMATRICULA WHERE TURMA = 'CCGP T 49' AND DISCIPLINA = 'CCGP-EPCP' AND SITUACAO_HIST != 'Cancelado'

Autor: Gabriel SS
Data: 26/06/2018
*/

ALTER VIEW VW_FCAV_AVAL_PARTICIPANTES
AS


WITH MATRICULADOS
AS (SELECT
	AL.CURSO,
    MA.TURMA,
	MA.ANO,
	MA.SEMESTRE,
    MA.DISCIPLINA,
	DO.NUM_FUNC,
	CASE WHEN DO.NOME_COMPL = 'Renato Moraes' THEN 'Renato de Oliveira Moraes'
		 WHEN DO.NOME_COMPL = 'Alexandre Lopez Hernandez' THEN 'Alexandre Lopes Hernandez'
		ELSE DO.NOME_COMPL
	END AS DOCENTE,
    MA.ALUNO
FROM LY_MATRICULA MA
	INNER JOIN LY_ALUNO AL
		ON AL.ALUNO = MA.ALUNO
	INNER JOIN LY_AGENDA TU
		ON TU.TURMA = MA.TURMA
		AND TU.DISCIPLINA = MA.DISCIPLINA
		AND TU.ANO = MA.ANO
		AND TU.SEMESTRE = MA.SEMESTRE
	LEFT JOIN LY_DOCENTE DO
		ON DO.NUM_FUNC = TU.NUM_FUNC

WHERE MA.SIT_MATRICULA != 'Cancelado'
	AND AL.SIT_ALUNO != 'Cancelado'
	AND MA.DISCIPLINA NOT LIKE 'CEAI-RESERV'
	AND AL.CURSO NOT LIKE 'CEAI'
	
GROUP BY AL.CURSO,
		 MA.TURMA,
		 MA.ANO,
		 MA.SEMESTRE,
         MA.DISCIPLINA,
         MA.ALUNO,
		 DO.NUM_FUNC,
		 DO.NOME_COMPL

UNION ALL
SELECT
	AL.CURSO,
    HI.TURMA,
	HI.ANO,
	HI.SEMESTRE,
    HI.DISCIPLINA,
	DO.NUM_FUNC, 
	CASE WHEN DO.NOME_COMPL = 'Renato Moraes' THEN 'Renato de Oliveira Moraes'
		 WHEN DO.NOME_COMPL = 'Alexandre Lopez Hernandez' THEN 'Alexandre Lopes Hernandez'
		ELSE DO.NOME_COMPL
	END AS DOCENTE,
    HI.ALUNO
FROM LY_HISTMATRICULA HI
	INNER JOIN LY_ALUNO AL
		ON AL.ALUNO = HI.ALUNO
	INNER JOIN LY_AGENDA TU
		ON TU.TURMA = HI.TURMA
		AND TU.DISCIPLINA = HI.DISCIPLINA
		AND TU.ANO = HI.ANO
		AND TU.SEMESTRE = HI.SEMESTRE
	LEFT JOIN LY_DOCENTE DO
		ON DO.NUM_FUNC = TU.NUM_FUNC

WHERE HI.SITUACAO_HIST != 'Cancelado'
	AND AL.SIT_ALUNO != 'Cancelado'
	AND HI.DISCIPLINA NOT LIKE 'CEAI-RESERV'
	AND AL.CURSO NOT LIKE 'CEAI'
GROUP BY AL.CURSO,
		 HI.TURMA,
		 HI.ANO,
		 HI.SEMESTRE,
         HI.DISCIPLINA,
         HI.ALUNO,
		 DO.NUM_FUNC, 
		 DO.NOME_COMPL

UNION ALL
SELECT
	AL.CURSO,
	CASE WHEN TU.TURMA = 'CEAI T 34 SAB'  AND TU.ANO = 2020 AND TU.SEMESTRE = 3 AND TU.DISCIPLINA = 'CEAI-TCC' THEN TU.TURMA
		ELSE AL.TURMA_CEAI
		END AS TURMA,
	AL.ANO,
	AL.SEMESTRE,
	AL.DISCIPLINA,
	DO.NUM_FUNC,
	CASE WHEN DO.NOME_COMPL = 'Renato Moraes' THEN 'Renato de Oliveira Moraes'
	     WHEN DO.NOME_COMPL = 'Alexandre Lopez Hernandez' THEN 'Alexandre Lopes Hernandez'
		ELSE DO.NOME_COMPL
	END AS DOCENTE,
	AL.ALUNO
FROM
	VW_FCAV_ALUNOS_MATRICULADOS_CEAI AL 
	LEFT JOIN LY_AGENDA TU
		ON TU.TURMA = AL.TURMA_ORIGEM
		AND TU.DISCIPLINA = AL.DISCIPLINA
		AND TU.ANO = AL.ANO
		AND TU.SEMESTRE = AL.SEMESTRE
	LEFT JOIN LY_DOCENTE DO
		ON DO.NUM_FUNC = TU.NUM_FUNC
WHERE 
	AL.DISCIPLINA NOT LIKE 'CEAI-RESERV'
GROUP BY
	AL.CURSO,
	AL.TURMA_CEAI,
	TU.TURMA,
	AL.ANO,
	AL.SEMESTRE,
	AL.DISCIPLINA,
	DO.NUM_FUNC,
	DO.NOME_COMPL,
	AL.ALUNO,
	TU.ANO, 
	TU.SEMESTRE,
	TU.DISCIPLINA
	
	)

--RELA��O DAS TURMAS COM NUMERO DE MATRICULADOS NAS DISCIPLINAS
SELECT
    CS.CURSO,
    CS.NOME AS NOME_CURSO,
    MA.TURMA,
    MA.DISCIPLINA,
	MA.DOCENTE,
    COUNT(MA.ALUNO) MATRICULADOS
FROM LY_AVALIADOR AV
INNER JOIN MATRICULADOS MA
    ON MA.ALUNO = AV.ALUNO
INNER JOIN LY_CURSO CS
    ON CS.CURSO = MA.CURSO

GROUP BY CS.CURSO,
         CS.NOME,
         MA.TURMA,
		 MA.ANO,
		 MA.SEMESTRE,
         MA.DISCIPLINA,
		 MA.DOCENTE