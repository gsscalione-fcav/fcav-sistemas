
select * from ly_turma where TURMA = 'ceai t 30' order by DT_INICIO

WITH ALUNOS_TURMA AS 
(
SELECT 
	CURSO, TURMA_PREF AS TURMA, ALUNO
FROM 
	VW_FCAV_INFO_ALUNOS_LYCEUM
WHERE SIT_MATRICULA = 'Matriculado'
and DT_FIM_TURMA >=GETDATE()
AND CURSO = 'CEAI'
--AND TURMA_PREF = 'CEAI T 32'
GROUP BY CURSO, TURMA_PREF,ALUNO),

ALUNOS_MATRICULADOS AS 
(
SELECT 
	CURSO, TURMA, COUNT(aluno) TOTAL_MATR
FROM 
	ALUNOS_TURMA
GROUP BY CURSO, TURMA),

ALUNOS_BOLSISTAS AS (
SELECT CURSO,
	TURMA_PREF AS TURMA,
	ALUNO,
	TIPO_BOLSA,
	CASE when PERC_VALOR = 'Valor' then 'Acerto' 
	else 'Bolsistas '+ cast(cast(VALOR*100 as decimal(10,0))as varchar)+'%' end AS BOLSA
	
FROM VW_FCAV_INFO_ALUNOS_LYCEUM
WHERE SIT_MATRICULA = 'Matriculado'
and DT_FIM_TURMA >= getdate()
AND CURSO = 'CEAI'
--AND TURMA_PREF = 'CEAI T 32'
AND TURMA NOT LIKE '%SAB%'
AND TIPO_BOLSA IS NOT NULL
GROUP BY CURSO,
	TURMA_PREF,
	ALUNO,
	TIPO_BOLSA,
	PERC_VALOR,
	VALOR),

BOLSISTAS AS (
SELECT CURSO,
	TURMA,
	TIPO_BOLSA,
	BOLSA,
	COUNT(ALUNO) AS QTD_ALUNOS
	
FROM ALUNOS_BOLSISTAS
GROUP BY CURSO,
	TURMA,
	TIPO_BOLSA,
	BOLSA
)



SELECT 
	AM.CURSO,
	AM.TURMA,
	AM.TOTAL_MATR,
	BO.BOLSA,
	BO.QTD_ALUNOS
FROM ALUNOS_MATRICULADOS AM
	INNER JOIN BOLSISTAS BO
		ON BO.CURSO = AM.CURSO
		AND BO.TURMA = AM.TURMA
ORDER BY BO.BOLSA