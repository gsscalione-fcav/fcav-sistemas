/*
	VIEW VW_FCAV_CONFIG_PLANO_PGTO
Descri��o:
	View criada para auxiliar na cria��o dos grupos de alunos.
	Traz somente os cursos que possuem matricula avulsa.
Autor: Gabriel S.S.
Data: 24/03/2017
*/


ALTER VIEW VW_FCAV_CONFIG_PLANO_PGTO
AS
SELECT 
	CS.CURSO,
	CS.NOME AS NOME_CURSO,
	OC.OFERTA_DE_CURSO,
	ISNULL(OC.CONCURSO, 'VENDA DIRETA') AS CONCURSO,
	OC.DTINI AS DTINI_INSC,
	OC.DTFIM AS DTFIM_INSC,
	CASE WHEN DTFIM >= GETDATE() AND DTINI <= GETDATE() THEN 'Aberta'
		 WHEN DTFIM >= GETDATE() AND DTINI >= GETDATE() THEN 'N�o Iniciado'
	ELSE 'Encerrada'
	END AS SIT_INSCRICAO,
	TU.TURMA,
	MIN(TU.DT_INICIO) AS DT_INI_TURMA,
	MAX(TU.DT_FIM) AS DT_FIM_TURMA,
	MONTH(MIN(TU.DT_INICIO)) AS MES_INI_TURMA,
	OC.ANO_INGRESSO,
	OC.PER_INGRESSO,
	CR.PRAZO_CONC_PREV AS PRAZO_CONCLUSAO,
	CR.TIPO_PRAZO_CONCL,
	CS.FL_FIELD_09 AS INVESTIMENTO,
	ISNULL(OC.FL_FIELD_05,TU.FL_FIELD_01)  AS FL_VALOR_DIVULGADO,
	
	ISNULL(PO.DESCRICAO,'N�O CADASTRADO') AS PLANO_PGTO,
	PO.PLANOPAG,
	PO.MES_INICIAL,
	PO.NUM_PARCELAS AS PARCELAS_MENS,
	
	
	CASE WHEN SM.SERVICO IS NULL THEN 0
	ELSE
		1
	END AS PARCELA_MATRI,
	
	CASE WHEN CS.FACULDADE NOT IN ('ATUAL','PALES') THEN 
		ISNULL(SM.SERVICO,'N�O CADASTRADO')
	ELSE
		'N�O APLIC�VEL'
	END AS SERVICO_MATRICULA,
	
	CASE WHEN CS.FACULDADE NOT IN ('ATUAL','PALES') THEN 
	(SELECT CAST(VSP.CUSTO_UNITARIO AS DECIMAL(10,2)) 
	 FROM LY_VALOR_SERV_PERIODO VSP
		WHERE VSP.SERVICO = SM.SERVICO
		AND VSP.ANO = SM.ANO
		AND VSP.PERIODO = SM.PERIODO) 
	ELSE
		0
	END AS VALOR_MATRI,
	
	CASE WHEN CS.FACULDADE NOT IN ('PALES') THEN 
		ISNULL(CR.SERVICO,'N�O VINCULADO') 
	ELSE
		'N�O APLIC�VEL'
	END AS SERVICO_MENSALIDADE,
	
	(SELECT CAST(VSP.CUSTO_UNITARIO AS DECIMAL(10,2)) FROM LY_VALOR_SERV_PERIODO VSP
		WHERE VSP.SERVICO = CR.SERVICO
		AND VSP.ANO = OC.ANO_INGRESSO
		AND VSP.PERIODO = OC.PER_INGRESSO) AS VALOR_MENS,
	
	------------------------------------------
	
	'G01_'+TU.TURMA AS GRUPO_TURMA,
	(SELECT CAST(VSP.CUSTO_UNITARIO AS DECIMAL(10,2)) FROM LY_VALOR_SERV_PERIODO VSP
		WHERE VSP.SERVICO = CR.SERVICO
		AND VSP.ANO = OC.ANO_INGRESSO
		AND VSP.PERIODO = OC.PER_INGRESSO) + 
	CASE WHEN CS.FACULDADE NOT IN ('ATUAL','PALES') THEN 
	(SELECT ISNULL (CAST(VSP.CUSTO_UNITARIO AS DECIMAL(10,2)),0)  
	 FROM LY_VALOR_SERV_PERIODO VSP
		WHERE VSP.SERVICO = SM.SERVICO
		AND VSP.ANO = SM.ANO
		AND VSP.PERIODO = SM.PERIODO) 
	ELSE
		0
	END AS VALOR_SOMADO,
	
	(PO.NUM_PARCELAS + 1) AS NUM_PARCELAS_NOVA,
	
	'MENS' + CAST((PO.NUM_PARCELAS + 1)AS VARCHAR)+'X' AS PLANPAGPADRAO_NOVO,
	CAST(((SELECT CAST(VSP.CUSTO_UNITARIO AS DECIMAL) FROM LY_VALOR_SERV_PERIODO VSP
		WHERE VSP.SERVICO = CR.SERVICO
		AND VSP.ANO = OC.ANO_INGRESSO
		AND VSP.PERIODO = OC.PER_INGRESSO) + 
	CASE WHEN CS.FACULDADE NOT IN ('ATUAL','PALES') THEN 
	(SELECT ISNULL (CAST(VSP.CUSTO_UNITARIO AS NUMERIC),0)  
	 FROM LY_VALOR_SERV_PERIODO VSP
		WHERE VSP.SERVICO = SM.SERVICO
		AND VSP.ANO = SM.ANO
		AND VSP.PERIODO = SM.PERIODO) 
	ELSE
		0
	END) / (PO.NUM_PARCELAS + 1) AS DECIMAL(10,2)) AS PARCELAS_MENSAIS,
	
	CASE WHEN (PO.NUM_PARCELAS + 1) > PRAZO_CONC_PREV THEN
		(PO.MES_INICIAL - 1)
	ELSE PO.MES_INICIAL
	END AS MES_INI_FINAN_NOVO
		
FROM 
	LY_OFERTA_CURSO OC
	INNER JOIN LY_OPCOES_OFERTA OO
		ON OO.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO
	INNER JOIN LY_CURSO CS 
		ON CS.CURSO = OC.CURSO
	INNER JOIN LY_CURRICULO CR
		ON CR.CURRICULO = OC.CURRICULO
	INNER JOIN LY_TURMA TU
		ON TU.TURMA = OO.TURMA
	LEFT JOIN LY_PLANOS_OFERTADOS PO
		ON PO.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO
	LEFT JOIN LY_SERVICO_MATRICULA SM
		ON SM.CURSO = OC.CURSO
		AND SM.TURNO = OC.TURNO
		AND SM.CURRICULO = OC.CURRICULO
		AND SM.ANO = OC.ANO_INGRESSO
		AND SM.PERIODO = OC.PER_INGRESSO
		AND SM.UNIDADE_FISICA = OC.UNIDADE_FISICA
		
WHERE 
	--tu.TURMA like 'cepsng t 23'
	OC.ANO_INGRESSO >= 2016
	AND OC.CONCURSO IS NOT NULL
	AND TU.UNIDADE_RESPONSAVEL NOT IN ('ATUAL','PALES')
	AND TU.DT_FIM >= GETDATE()
	AND PO.PLANOPAG NOT LIKE ('%AVISTA%')
	AND SM.SERVICO IS NOT NULL

GROUP BY 
	CS.CURSO,
	CS.NOME,
	CS.FACULDADE,
	CS.FL_FIELD_09,
	CR.PRAZO_CONC_PREV,
	CR.TIPO_PRAZO_CONCL,
	OC.OFERTA_DE_CURSO,
	OC.DESCRICAO_COMPL,
	OC.CONCURSO,
	OC.DTINI,
	OC.DTFIM,
	OC.ANO_INGRESSO,
	OC.PER_INGRESSO,
	OC.FL_FIELD_05,
	
	TU.TURMA,
	TU.FL_FIELD_01,

	PO.DESCRICAO,
	PO.NUM_PARCELAS,
	PO.MES_INICIAL,
	PO.PLANOPAG,
	
	SM.ANO,
	SM.PERIODO,
	SM.SERVICO,
	CR.SERVICO