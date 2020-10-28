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
	*
FROM 
	FCAV_AVALIACAO_DOCENTE

	),

	result_aval_aux as (

	SELECT 
		CURSO,
		DISC_AVALIADA,
		TURMA,
		ASPECTO,
		COD_AVAL,
		AVALIADO,
		NOME_AVALIADO,
		QUESTAO,
		PERGUNTAS,
		NOTA,
		COUNT(ISNULL(NOTA,0)) AS QTDE

	FROM 
		RESULTADO_AVALIACAO RA
	WHERE TIPO_QUESTAO = 'Objetiva'
	GROUP BY CURSO,
		DISC_AVALIADA,
		TURMA,
		ASPECTO,
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
			DISC_AVALIADA,
			TURMA,
			ASPECTO,
			AVALIADO,
			NOME_AVALIADO,
			COD_AVAL,
			QUESTAO,
			PERGUNTAS,
			NOTA,
			sum(ISNULL(QTDE,0)) AS QTDE
		from result_aval_aux
		group by CURSO,
			DISC_AVALIADA,
			TURMA,
			ASPECTO,
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
	DISC_AVALIADA,
	TURMA,
	ASPECTO,
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
