/*
	VIEW VW_FCAV_AVAL_RESULTADO

	Finalidade: Retorna o resultado das avaliações docentes aplicadas

Autor: Gabriel S. Scalione
Data: 16/05/2019

SELECT * FROM VW_FCAV_AVAL_RESULTADO ORDER BY CURSO, TURMA, COD_AVAL, QUESTAO

*/



ALTER VIEW VW_FCAV_AVAL_RESULTADO
AS

With RESULTADO_AVALIACAO
as (
SELECT 
	replace(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(APLICACAO,'_',''),'DIS',''),'DO',''),'INFR',''),'INF',''),'CCE','CE'),' ','') AS COD_AVAL,
	*
FROM 
	FCAV_AVALIACAO_DOCENTE

	),

	result_aval_aux as (

	SELECT 
		CURSO,
		NOME_CURSO,
		TURMA,
		COD_AVAL,
		AVALIADO,
		NOME_AVALIADO,
		QUESTAO,
		PERGUNTAS,
		NOTA,
		COUNT(ISNULL(NOTA,0)) AS QTDE

	FROM 
		RESULTADO_AVALIACAO
	WHERE TIPO_QUESTAO = 'objetiva'
	GROUP BY CURSO,
		NOME_CURSO,
		TURMA,
		COD_AVAL,
		AVALIADO,
		NOME_AVALIADO,
		QUESTAO,
		PERGUNTAS,
		NOTA
),
resultado_em_coluna AS
(
	--------------------------------------------------------------
	-- Transformando linha em coluna
	--------------------------------------------------------------

	select * from (
		select 
			CURSO,
			NOME_CURSO,
			TURMA,
			AVALIADO,
			NOME_AVALIADO,
			COD_AVAL,
			QUESTAO,
			PERGUNTAS,
			NOTA,
			sum(ISNULL(QTDE,0)) AS QTDE
		from result_aval_aux
		group by CURSO,
			NOME_CURSO,
			TURMA,
			COD_AVAL,
			AVALIADO,
			NOME_AVALIADO,
			QUESTAO,
			PERGUNTAS,
			NOTA
		) em_linha
		pivot(sum(QTDE) for NOTA in ([Excelente],[Bom],[Regular],[Ruim],[Pessimo])) em_colunas
		--order by 1
)

----------------------------------
-- consulta

select 
	CURSO,
	NOME_CURSO,
	TURMA,
	AVALIADO,
	NOME_AVALIADO,
	COD_AVAL,
	QUESTAO,
	PERGUNTAS,
	(ISNULL(Excelente,0) + ISNULL(Bom,0) + ISNULL(Regular,0) + ISNULL(Ruim,0) + ISNULL(Pessimo,0)) as QTDE_PREENCHIDA,
	ISNULL(Excelente,0) AS Excelente,
	ISNULL(Bom,0) AS Bom,
	ISNULL(Regular,0) AS Regular,
	ISNULL(Ruim,0) AS Ruim,
	ISNULL(Pessimo,0) AS Pessimo
from 
	resultado_em_coluna rc
