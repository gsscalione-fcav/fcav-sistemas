/*
	VIEW 

	CONSULTA PARA TRAZER OS ALUNOS MATRICULADOS AT� 5 DIAS AP�S O INICIO DO CURSO

	APLICADO AO DASHBOARD

Autor: Gabriel S. Scalione
Data: 12/03/2018


*/

ALTER VIEW VW_FCAV_DASHBOARD_MATRICULADOS
AS
SELECT 
	FM.GRUPO_RESP,
	FM.UNID_RESP	,
	FM.CURSO	,
	FM.NOME_CURSO	,
	FM.OFERTA_DE_CURSO	,
	FM.TIPO_INGRESSO	,
	FM.CONCURSO	,
	FM.DTINI_INSCRICAO	,
	FM.DTFIM_INSCRICAO	,
	FM.INSCRICOES	,
	FM.ANO_INICIO	,
	FM.PER_INGRESSO,	
	FM.TURMA	,
	FM.DT_INICIO,	
	FM.DT_FIM	,
	FM.SITUACAO_TURMA	,
	FM.REALIZACAO,
	PESSOA,
	CANDIDATO	,
	ALUNO	,
	NOME_COMPL	,
	ANO_INGRESSO,
	SEM_INGRESSO	,
	SIT_ALUNO	,
	DT_MATRICULA	,
	SIT_MATRICULA,
	MP.TURMA_PREF,
	MP.TIPO_INGRESSO AS TIPO_INSCRICAO,
	RIGHT(CONVERT(CHAR(10),MP.DT_MATRICULA,103),7) AS MES_ANO_MATR

FROM 
	VW_FCAV_DASHBOARD_FECHAMENTO_MATRICULA FM
	INNER JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP
		ON MP.TURMA = FM.TURMA
WHERE
	DT_MATRICULA <= (FM.DT_INICIO + 5)
	--AND SIT_MATRICULA = 'Matriculado' --a planilha de dashboard � que filtra por matriculados
GROUP BY
	FM.GRUPO_RESP,
	FM.UNID_RESP	,
	FM.CURSO	,
	FM.NOME_CURSO	,
	FM.OFERTA_DE_CURSO	,
	FM.TIPO_INGRESSO	,
	FM.CONCURSO	,
	FM.DTINI_INSCRICAO	,
	FM.DTFIM_INSCRICAO	,
	FM.INSCRICOES	,
	FM.ANO_INICIO	,
	FM.PER_INGRESSO,	
	FM.TURMA	,
	FM.DT_INICIO,	
	FM.DT_FIM	,
	FM.SITUACAO_TURMA	,
	FM.REALIZACAO,
	PESSOA,
	CANDIDATO	,
	ALUNO	,
	NOME_COMPL	,
	ANO_INGRESSO,
	SEM_INGRESSO	,
	SIT_ALUNO	,
	DT_MATRICULA	,
	SIT_MATRICULA,
	MP.TURMA_PREF,
	MP.TIPO_INGRESSO
