/*************************************************************************************
--Select da tabela TB_INSC_INSCRICOES_REALIZADAS para mostrar os Candidato INSCRITOS 
**************************************************************************************/
SELECT
	TUR_CODTUR AS TURMA,
	PES_NOME,
	PES_NRODOC2,
	INR_DATHOR AS DT_INSCRICAO

FROM LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_INSC_INSCRICOES_REALIZADAS 
	inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_INSC_INSREAL_OPC on (inr_id = iro_inrid)
	inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.tb_insc_inscricao_opcao on (ict_id = iro_ictid)
	inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.tb_turma on (ict_turid = tur_id)
	inner join LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_PESSOA on (PES_ID = INR_PESID)
WHERE 
	TUR_CODTUR like 'P-NIPSP T01'
	--PES_NOME NOT LIKE '%teste%'
	--and tur_codtur = 'cegi t 18'
	--AND INR_DATHOR BETWEEN '2013-09-01 00:00:00.000' AND '2013-09-30 23:59:59.999'
	--AND PES_EMAIL NOT LIKE '%@vanzolini%'
--GROUP BY TUR_CODTUR,INR_DATHOR--, INR_PESID,PES_NOME
ORDER BY INR_DATHOR DESC


/****************************************************************
-SELECT da Tabela LY_CANDIDATOS INSCRITOS QUE ESTÃO NO LYCEUM
*****************************************************************/

UNION ALL

SELECT 
	CONCURSO collate Latin1_General_CI_AS AS TURMA,
	CONVERT(VARCHAR(10),DT_INSCRICAO, 103) AS DT_INSCRICAO
	--COUNT(DT_INSCRICAO) AS QTDE_INSCRITO 
FROM 
	LYCEUM.dbo.LY_CANDIDATO
WHERE 
	E_MAIL NOT LIKE '%@vanzolini%'
	and DT_INSCRICAO BETWEEN '2013-09-01 00:00:00.000' AND '2013-09-30 23:59:59.999'
--GROUP BY CONCURSO, DT_INSCRICAO