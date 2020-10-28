
SELECT 
		al.ALUNO,
		al.NOME_COMPL,
		cb.COBRANCA,
		cb.BOLETO,
		cb.DATA_DE_VENCIMENTO,
		--cv.VALOR,
		NUMERO_RPS ,
		DATA_EMISSAO_RPS ,
		DATA_ENVIO_RPS ,
		VALOR_SERVICO_RPS ,
		VALOR_DEDUCAO_RPS ,
		NUMERO_NFE ,
		DATA_EMISSAO_NFE ,
		OBS ,
		LINK_RPS ,
		EMPRESA,
		NOTA_FISCAL_SERIE ,
		VALOR_DESCONTO_RPS ,
		DT_SOLICITA_CANCEL_RPS ,
		MOTIVO_CANCEL_RPS  
		into #cobrancas_valores
FROM LY_BOLETO bo
		inner join VW_COBRANCA_BOLETO cb
			on cb.BOLETO = bo.BOLETO
		inner join LY_ALUNO al
			on al.ALUNO = cb.ALUNO
	where bo.NUMERO_RPS is not null
		and bo.NUMERO_NFE is null


--SELECT * FROM #cobrancas_valores order by BOLETO


SELECT count(boleto) RPSNaoEnviada FROM #cobrancas_valores WHERE DATA_ENVIO_RPS IS NULL

SELECT count(boleto) EnvioRPS FROM #cobrancas_valores WHERE DATA_ENVIO_RPS IS NOT NULL


drop table #cobrancas_valores
--188339


