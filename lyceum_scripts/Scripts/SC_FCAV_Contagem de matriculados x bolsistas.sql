
WITH ALUNOS_TURMA AS 
(
SELECT 
	CURSO, TURMA_PREF AS TURMA, ALUNO
FROM 
	VW_FCAV_INFO_ALUNOS_LYCEUM
WHERE SIT_MATRICULA = 'Matriculado'
and DT_FIM_TURMA >=getdate()
AND CURSO = 'CEAI'
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

	INTO #temporario

FROM ALUNOS_MATRICULADOS AM
	INNER JOIN BOLSISTAS BO
		ON BO.CURSO = AM.CURSO
		AND BO.TURMA = AM.TURMA
ORDER BY BO.BOLSA



------------------------------------------------------------------------------
--transformando linhas em colunas
------------------------------------------------------------------------------
declare @colunas_pivot as nvarchar(max), @comando_sql as nvarchar(max)
set @colunas_pivot = 
		stuff((
			select 
				distinct ',' + quotename(BOLSA) 
			from #temporario 
			for xml path('')
		), 1, 1,'')
print @colunas_pivot
set @comando_sql = '
select * from (
	select 
		CURSO,
		TURMA,
		TOTAL_MATR,
		BOLSA,
		count(QTD_ALUNOS)QTD_ALUNOS
	from #temporario
	 group by CURSO,
		TURMA,
		TOTAL_MATR,
		BOLSA
	) em_linha
	pivot(sum(QTD_ALUNOS) for BOLSA in ('+ @colunas_pivot +')) em_colunas
	order by 1'
print @comando_sql

execute(@comando_sql)

drop table #temporario

