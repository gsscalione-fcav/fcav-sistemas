/*
	VIEW VW_FCAV_APOIOWEB_INSCRITOS_VENDA_DIRETA

	Finalidade: Utilizada exclusivamente para as paginas dos cursos de Venda direta do apoioweb,
				onde soma os valores a pagar e pago quando há mais de um responsável financeiro.

Autor: Gabriel S. Scalione
Data: 25/02/2019


select * from VW_FCAV_APOIOWEB_INSCRITOS_VENDA_DIRETA where concurso = 'A-9001.15 T 50'

*/

ALTER VIEW VW_FCAV_APOIOWEB_INSCRITOS_VENDA_DIRETA
AS

SELECT 
	AREA,
	AV.CONCURSO,
	AV.ALUNO,
	AV.DT_INGRESSO,
	SIT_MATRICULA,
	ALOCADO,
	AV.NOME_COMPL,
	E_MAIL,
	TIPO_BOLSA,
	DATA_DE_VENCIMENTO,
	SUM(case when sit_matricula = 'Cancelado' then 0
	     else VALOR_PAGAR end ) AS VALOR_PAGAR,
	SUM(case when sit_matricula = 'Cancelado' then 0
	     else VALOR_PAGO end) AS VALOR_PAGO,
	AL.OBS_ALUNO_FINAN AS FOLLOW_UP
FROM VW_FCAV_ALUNOS_VENDA_DIRETA AV
	INNER JOIN LY_ALUNO AL
		ON AL.ALUNO = AV.ALUNO
WHERE 
	YEAR(INICIO_DO_CURSO) >= 2018
	
GROUP BY AREA,
	AV.CONCURSO,
	AV.ALUNO,
	AV.DT_INGRESSO,
	SIT_MATRICULA,
	ALOCADO,
	AV.NOME_COMPL,
	E_MAIL,
	TIPO_BOLSA,
	DATA_DE_VENCIMENTO,
	AL.OBS_ALUNO_FINAN