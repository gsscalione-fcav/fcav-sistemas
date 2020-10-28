SELECT COBRANCA, 
	   BOLETO, 
	   ITEMCOBRANCA, 
	   MA.ALUNO, 
	   PARCELA, 
	   DATA, 
	   VALOR, 
	   DESCRICAO, 
	   MA.TURMA, 
	   MA.CURSO, 
	   MA.TURNO, 
	   MA.CURRICULO, 
	   UNID_FISICA, 
	   IT.DT_INICIO,
	   IT.ANO as ANO_INDICE,
	   IT.MES as MES_INDICE,
	   CASE WHEN DESCRICAO LIKE '%igpm%' then NULL
		else IT.INDICE
		end INDICE_APLICADO
FROM  LY_ITEM_LANC IL
	INNER JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA
		ON MA.ALUNO = IL.ALUNO
	LEFT JOIN VW_FCAV_IGPM_TURMA IT
		ON IT.TURMA = MA.TURMA
WHERE COBRANCA IN (SELECT COBRANCA FROM LY_COBRANCA WHERE DATA_DE_GERACAO = '2020-10-02' )
	  --AND COBRANCA IN (SELECT COBRANCA FROM LY_COBRANCA WHERE DATA_DE_VENCIMENTO = '2020-10-15' )
 	  AND CODIGO_LANC = 'MS'
	  AND COBRANCA IN (SELECT DISTINCT COBRANCA 
					   FROM LY_ITEM_LANC 
					   WHERE DESCRICAO LIKE '%IGPM%')
GROUP BY COBRANCA, 
	BOLETO, 
	ITEMCOBRANCA, 
	MA.ALUNO, 
	PARCELA, 
	DATA, 
	VALOR, 
	DESCRICAO, 
	MA.TURMA, 
	MA.CURSO, 
	MA.TURNO, 
	MA.CURRICULO,  
	UNID_FISICA, 
	IT.DT_INICIO,
	IT.ANO,
	IT.MES,
	IT.INDICE
ORDER BY CURSO, COBRANCA, ITEMCOBRANCA


