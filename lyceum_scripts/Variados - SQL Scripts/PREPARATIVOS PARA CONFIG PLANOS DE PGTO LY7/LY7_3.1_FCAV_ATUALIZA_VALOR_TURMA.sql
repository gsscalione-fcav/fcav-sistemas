------------------------------------------------------------------------------------
--ATUALIZAR O VALOR DO SERVI�O DE MENSALIDADE (VALOR DO CURSO).
------------------------------------------------------------------------------------
UPDATE LY_VALOR_SERV_PERIODO
SET
	CUSTO_UNITARIO = VALOR_SOMADO
FROM 
	LY_VALOR_SERV_PERIODO VSP
	INNER JOIN VW_FCAV_CONFIG_PLANO_PGTO CP
		ON CP.SERVICO_MENSALIDADE = VSP.SERVICO
		AND CP.ANO_INGRESSO = VSP.ANO
		AND CP.PER_INGRESSO = VSP.PERIODO


SELECT 
	CURSO,
	TURMA,
	VALOR_SOMADO,
	CUSTO_UNITARIO 
FROM
	LY_VALOR_SERV_PERIODO VSP
	INNER JOIN VW_FCAV_CONFIG_PLANO_PGTO CP
		ON CP.SERVICO_MENSALIDADE = VSP.SERVICO
		AND CP.ANO_INGRESSO = VSP.ANO
		AND CP.PER_INGRESSO = VSP.PERIODO

