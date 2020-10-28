



ALTER VIEW VW_FCAV_DECLARACAO_QUITACAO
AS

SELECT  CS.CURSO, 
		CS.NOME, 
        AL.NOME_COMPL, 
        AL.ALUNO, 
		PE.CPF,
		PE.E_MAIL,
		CQ.RESP,
		RF.TITULAR,
		BL.TIPO_BOLSA,
        CQ.COBRANCA,
		AL.DATA_DE_VENCIMENTO,
		AL.VALOR_FATURADO as VR_PRINCIPAL,
		AL.DESCONTO AS VR_DESCONTO,
		AL.BOLSA AS VR_BOLSA,
		AL.MULTA_JUROS AS VR_ENCARGOS,
		AL.VALOR_PAGO AS VR_PAGO
                
FROM	LY_COBRANCA_QUITADA CQ
        INNER JOIN VW_FCAV_RELAT_BOLETOS_EMITIDOS_CONTAB AL
               ON CQ.ALUNO = AL.ALUNO
			   AND CQ.COBRANCA = AL.COBRANCA
			   AND AL.DESCRICAO NOT LIKE '%ESTORNO%'
	    INNER JOIN LY_ALUNO AN
			   ON AN.ALUNO = AL.ALUNO
        INNER JOIN LY_CURSO CS
               ON AL.CURSO = CS.CURSO 
	    INNER JOIN LY_PESSOA PE
			   ON PE.PESSOA = AN.PESSOA
	    INNER JOIN LY_RESP_FINAN RF
			   ON RF.RESP = CQ.RESP
		LEFT JOIN LY_BOLSA BL
			   ON BL.ALUNO = AL.ALUNO

WHERE  (Year(AL.DATA_DE_VENCIMENTO) = 2018 or CQ.ANO = 2018)
AND AL.SITUACAO_BOLETO = 'Boleto Pago'
AND AL.NOME_COMPL != 'Aluno Editor de Tela'
GROUP BY CS.CURSO, 
		CS.NOME, 
        AL.NOME_COMPL, 
        AL.ALUNO, 
		PE.CPF,
		PE.E_MAIL,
		CQ.RESP,
		RF.TITULAR,
        CQ.COBRANCA,
		BL.TIPO_BOLSA,
		AL.DATA_DE_VENCIMENTO,
		CQ.VALOR_TITULO,
		AL.VALOR_PAGO,
		AL.DESCONTO,
		AL.BOLSA,
		AL.MULTA_JUROS,
		AL.VALOR_FATURADO 

