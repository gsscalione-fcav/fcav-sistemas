
alter VIEW VW_FCAV_VOUCHER_CADASTRADOS
AS 
	SELECT OC.CURSO,
		OC.OFERTA_DE_CURSO as OFERTA,
		OC.TURMA_PREF, 
		LV.VOUCHER,
		LV.DESCRICAO,
		LV.DESC_PERC_VALOR,
		LV.DESCONTO,
		LV.QUANTIDADE,
		LV.DT_INI,
		LV.DT_FIM,
		COUNT(CO.ALUNO) TOTAL_UTILIZADO
	FROM LY_LOTE_VOUCHER LV
		LEFT JOIN LY_VOUCHER_CURSO VC
			ON LV.ID_LOTE_VOUCHER = VC.ID_LOTE_VOUCHER
		left join LY_COMPRA_OFERTA CO
			ON CO.ID_LOTE_VOUCHER = LV.ID_LOTE_VOUCHER
		INNER JOIN LY_OFERTA_CURSO OC
			ON OC.OFERTA_DE_CURSO = CO.OFERTA_DE_CURSO
			AND OC.CURSO = VC.CURSO
	GROUP BY OC.CURSO,
		OC.OFERTA_DE_CURSO,
		OC.TURMA_PREF, 
		LV.VOUCHER,
		LV.DESCRICAO,
		LV.DESC_PERC_VALOR,
		LV.DESCONTO,
		LV.QUANTIDADE,
		LV.DT_INI,
		LV.DT_FIM
