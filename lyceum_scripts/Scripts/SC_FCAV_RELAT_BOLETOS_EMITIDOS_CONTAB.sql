SELECT DISTINCT vw_fcav_extrato_financeiro2.aluno, 
                vw_fcav_extrato_financeiro2.nome_compl, 
                vw_fcav_extrato_financeiro2.turma, 
                vw_fcav_extrato_financeiro2.data_de_vencimento, 
                vw_fcav_extrato_financeiro2.descricao, 
                vw_fcav_extrato_financeiro2.cobranca, 
                vw_fcav_extrato_financeiro2.data_de_emissao, 
                vw_fcav_extrato_financeiro2.situacao_boleto, 
                vw_fcav_extrato_financeiro2.valor_pagar, 
                vw_fcav_extrato_financeiro2.valor_pago, 
                ly_aluno.sit_aluno, 
                vw_fcav_extrato_financeiro2.juros_multa, 
                vw_fcav_extrato_financeiro2.descont, 
                vw_fcav_extrato_financeiro2.valor_acordado, 
                vw_fcav_extrato_financeiro2.outros_enc, 
                vw_fcav_extrato_financeiro2.ajuste, 
                vw_fcav_extrato_financeiro2.valor_faturado, 
                vw_fcav_extrato_financeiro2.centro_de_custo, 
                vw_fcav_extrato_financeiro2.bolsa, 
                vw_fcav_extrato_financeiro2.data_emissao_rps, 
                vw_fcav_extrato_financeiro2.numero_rps, 
                vw_fcav_extrato_financeiro2.diferenca 
FROM   lyceum.dbo.vw_fcav_extrato_financeiro2 VW_FCAV_EXTRATO_FINANCEIRO2 
       INNER JOIN lyceum.dbo.ly_aluno LY_ALUNO 
               ON ( 
       ( ( vw_fcav_extrato_financeiro2.aluno = ly_aluno.aluno ) 
         AND ( vw_fcav_extrato_financeiro2.curso = ly_aluno.curso )) 
       AND ( vw_fcav_extrato_financeiro2.turno = ly_aluno.turno ) ) 
                  AND ( 
       vw_fcav_extrato_financeiro2.curriculo = ly_aluno.curriculo ) 
WHERE  vw_fcav_extrato_financeiro2.COBRANCA in ('35580')
ORDER  BY vw_fcav_extrato_financeiro2.turma, 
          vw_fcav_extrato_financeiro2.nome_compl, 
          vw_fcav_extrato_financeiro2.cobranca 


		  SELECT 
			* FROM LY_ITEM_LANC 
			WHERE COBRANCA = 21957

		SELECT 
			COBRANCA,
			DESCRICAO,
			VALOR
		FROM LY_ITEM_CRED
		WHERE 
			COBRANCA = 21529
		AND TIPO_ENCARGO IS NULL
		AND TIPODESCONTO IS NULL



		SELECT 