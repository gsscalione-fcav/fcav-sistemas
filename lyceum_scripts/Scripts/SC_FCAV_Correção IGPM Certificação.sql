************************************

-- SELECT PARA LEVANTAR OS CASOS E CONFERIR 

	 DECLARE @PERCENT AS FLOAT
	 SET @PERCENT = '10.8074' 

	 SELECT SC6010.R_E_C_N_O_, 
	 C6_DESC,C5_EMISSAO,
	 C6_DTULREA, 
	 C6_DTANTRJ, 
	 C5_CLIENTE, 
	 C6_NUM, 
	 C6_ITEM, 
	 C9_PEDIDO, 
	 C6_PRCVEN, 
	 C6_VALOR,
	 CAST(C6_ULTVAL * (1+@PERCENT / 100) AS numeric (10,2)) AS VALOR_CORRETO, 
	 C6_ULTVAL, 
	 C6_VALORIG, 
	 C6_ULTREAJ,
	 
	 @PERCENT AS INDICE_CORRETO,
	 
	 ' ' AS ESPACO
		--,SC6010.* 
	FROM SC6010 
		INNER JOIN SC5010 ON C6_NUM = C5_NUM
		LEFT OUTER JOIN SC9010 ON C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM
	WHERE --C6_NUM = '193020'
			SC6010.D_E_L_E_T_ = ''
		--AND SC9010.D_E_L_E_T_ = ''
		--AND C6_DTULREA = '20010201'
		AND C9_PEDIDO IS NULL
		--AND C6_ULTREAJ  = '17.9409'  --<>('0')
		--AND C6_NUM IN ('192773')
		--AND  C5_NUM = '192783'
		AND C5_EMISSAO between '20181101' and '20181130'
	ORDER BY
		C6_DTULREA
 
 
 ***********************************************

-- UPDATE DE ALTERA��O 

	 DECLARE @PERCENT AS FLOAT
	 SET @PERCENT = '10.0496' 

	 UPDATE SC6010
	 SET C6_VALOR = CAST(C6_ULTVAL * (1+@PERCENT / 100) AS numeric (10,2)),
		C6_PRCVEN = CAST(C6_ULTVAL * (1+@PERCENT / 100) AS numeric (10,2)),
		C6_ULTREAJ = @PERCENT,
		C6_DTULREA = '20181001'
	FROM	SC6010 
	WHERE	R_E_C_N_O_ IN 
	(
'256210',
'256211',
'265010',
'265011',
'265012',
'265013',
'265014',
'265015',
'265085',
'265086',
'265087',
'265088',
'265089',
'265090',
'265119',
'265120',
'265121',
'265122',
'265123',
'265124',
'265125',
'265126',
'265257',
'265258',
'265259',
'265260',
'265261',
'265262',
'265400',
'265401',
'265402',
'265403',
'265404',
'265405',
'265424',
'265425',
'265426',
'265427',
'265428',
'265429',
'255836',
'255837',
'265071',
'265072',
'265073',
'265074',
'265075',
'265155',
'265156',
'265157',
'265158',
'265159',
'265160',
'265476',
'265477',
'265478',
'265479',
'265480',
'265481',
'256199',
'256200',
'264616',
'264617',
'264618',
'264619',
'264620',
'264621',
'264622',
'264661',
'264662',
'264663',
'264664',
'264665',
'264666',
'264835',
'264836',
'264837',
'264838',
'264839',
'265131',
'265132',
'265133',
'265134',
'265135',
'265136',
'265137',
'264630',
'264631',
'264632',
'264633',
'264634',
'264813',
'264814',
'264815',
'264816',
'264817',
'264818',
'264908',
'264909',
'264910',
'264911',
'264912',
'265096',
'265097',
'265098',
'265099',
'265100',
'265101',
'265210',
'265211',
'265212',
'265213',
'265214',
'265215',
'265216',
'265233',
'265234',
'265235',
'265236',
'265237',
'265238',
'255780',
'255858',
'255859',
'255881',
'255882',
'256185',
'256186',
'256221',
'256222',
'264711',
'264712',
'264713',
'264714',
'264715',
'264716',
'264717',
'264718',
'264719',
'264720',
'264721',
'264722',
'264723',
'264724',
'264725',
'264726',
'264727',
'264728',
'264729',
'264730',
'264731',
'264732',
'264733',
'264734',
'264735',
'264736',
'264737',
'264738',
'264739',
'264740',
'264741',
'264742',
'264743',
'264744',
'265300',
'265301',
'265302',
'265303',
'265304',
'265305',
'255847',
'255848',
'255956',
'255957',
'256034',
'256035',
'264685',
'264686',
'264687',
'264688',
'264689',
'264969',
'264970',
'264971',
'264972',
'264973',
'264974',
'265143',
'265144',
'265145',
'265146',
'265147',
'265148',
'265196',
'265197',
'265198',
'265199',
'265200',
'265201',
'265275',
'265276',
'265277',
'265278',
'265279',
'265280',
'265286',
'265287',
'265288',
'265289',
'265290',
'265291',
'265371',
'265372',
'265373',
'265374',
'265375',
'255770',
'255870',
'255871',
'255898',
'255927',
'255928',
'265046',
'265047',
'265048',
'265043',
'265044',
'265045',
'265054',
'265055',
'265056',
'265057',
'265058',
'265059',
'265359',
'265360',
'265361',
'265362',
'265363',
'265364',
'265413',
'265414',
'265415',
'265416',
'265417',
'265418',
'255825',
'255826',
'256175',
'256176',
'256254',
'256255',
'256299',
'256300',
'264605',
'264606',
'264607',
'264608',
'264609',
'264610',
'264611',
'264673',
'264674',
'264675',
'264676',
'264677',
'264925',
'264926',
'264927',
'264928',
'264929',
'265334',
'265335',
'265336',
'265337',
'265338',
'265339'
	)


SELECT * FROM SZ6010 WHERE Z6_CODIND = '0001'


/* 
 --******************************************
 -- QUERY DA ROTINA PARA SELECIONAR OS CASOS

 SELECT
	 SC5.C5_NUM,SC5.C5_NOTA,SC5.C5_SERIE,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_CONTRAT,SC5.C5_DTCONTR,SC5.C5_MESREAJ,
	 SC5.C5_CODIND,SC5.C5_DTPROCE,SC5.C5_DTINIRJ,SC5.C5_EMISSAO,
	 SC6.C6_PRODUTO,SC6.C6_DESCRI,SC6.C6_NOTA,SC6.C6_SERIE,SC6.C6_DTULREA,SC6.C6_ENTREG,SC6.C6_NUM,
	 SC6.C6_CLI,SC6.C6_LOJA,SC6.C6_ITEM 
FROM 
	 SC5010  SC5 
		 INNER JOIN SC6010  AS SC6 
				ON  C5_FILIAL	= C6_FILIAL 
				AND SC5.C5_NUM	= SC6.C6_NUM 
				AND C5_CLIENT	= C6_CLI 
				AND C5_LOJACLI	= C6_LOJA 

WHERE 
		 SC5.C5_CONTRAT <> ''		-- NUMERO DO CONTRATO
	 AND SC5.C5_DTCONTR <> ' '		-- DATA DO CONTRATO
	 AND SC5.C5_MESREAJ <> ' '		-- MES DE REAJUSTE DO COTRATO
	 AND SC5.C5_CODIND <> ' '		-- CODIGO DO INDICE DE REAJUSTE
	 AND SC5.C5_DTINIRJ <> ' '		-- DATA INICIAL PARA REAJUSTE
	 AND SC5.C5_FV_EDU  = ' '		-- NUMERACAO PARA TITULOS IMPORTADOS DO ICORUJA
	 AND SC5.D_E_L_E_T_ <> '*'
	 AND SC6.C6_NOTA = ' '			-- NUMERO DA NOTA
	 AND SC6.C6_SERIE = ' '			-- SERIE DA NOTA
	 AND SC6.D_E_L_E_T_ <> '*'
	 
	 --AND SC6.C6_DTULREA LIKE '201810%'
	 -- AND SC6.C6_NUM = '193020'

	 ORDER BY SC6.C6_NUM,SC6.C6_ENTREG,SC6.C6_ITEM 


	-- SZ5010

	-- TABELA DE TAXAS
	 SELECT *
	 FROM SZ6010
	 WHERE Z6_CODIND = '0001' AND Z6_ANOTAXA = '18' AND Z6_MESTAXA = '08'



	*/
