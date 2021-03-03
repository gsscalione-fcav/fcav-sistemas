--***************************************************
--	VW_FCAV_PAGTO_CARTAO
--
--	INFO: View com informações sobre os pagamentos feitos 
--	por cartão de crédito para conferencia na 
--	contabilidade.
--
--	FILTRO: Os resultados exibidos são do mês passado
--	para frente, sempre partindo do dia 01 do mês passado
--
--	ATUALIZACAO: Retirado o filtro de data a pedido da Claudia 20/12/2018
--
--	data: 19/12/2018
--	Autor: João Paulo
--***************************************************

ALTER VIEW VW_FCAV_PAGTO_CARTAO AS

SELECT 
	DATA_INSERCAO AS DATA,
	CONVERT(VARCHAR,DATA_INSERCAO,108) AS HORARIO,
	CUR.CURSO,
	ALU.TURMA,
	TU.CENTRO_DE_CUSTO,
	AL.NOME_COMPL AS NOME_ALUNO,
	AL.SIT_ALUNO,
	ALU.SIT_MATRICULA,
	PPCOB.COBRANCA,
	PPCART.NSU,
	PPCART.VALOR,
	PPCART.COD_AUTORIZACAO,
	PPCART.BANDEIRA,
	PPCART.FINAL_CARTAO,
	PPCART.NUMERO_PARCELAS
 FROM Ly_pedido_pgto PPAGTO 
	INNER JOIN Ly_pedido_pgto_cobrancas PPCOB 
		ON PPAGTO. ID_PEDIDO_PGTO = PPCOB.ID_PEDIDO_PGTO
	INNER JOIN Ly_pedido_pgto_cartoes PPCART
		ON PPCOB.ID_PEDIDO_PGTO = PPCART.ID_PEDIDO_PGTO
	INNER JOIN LY_COBRANCA COB 
		ON (PPCOB.COBRANCA = COB.COBRANCA)
	INNER JOIN LY_CURSO CUR 
		ON COB.CURSO = CUR.CURSO
	INNER JOIN LY_ALUNO AL 
		ON AL.ALUNO = COB.ALUNO
	left JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA ALU
		ON ALU.ALUNO = AL.ALUNO
	left JOIN VW_FCAV_INI_FIM_CURSO_TURMA TU
		ON TU.TURMA = isnull(ALU.TURMA,AL.TURMA_PREF)
	--where PPCART.COD_AUTORIZACAO IN ('617175','585756')
	--WHERE DATA_INSERCAO >= '01'+'/'+CAST(MONTH(DATEADD(MONTH,-1,GETDATE())) AS varchar)+'/'+CAST(YEAR(DATEADD(MONTH,-1,GETDATE())) AS varchar)