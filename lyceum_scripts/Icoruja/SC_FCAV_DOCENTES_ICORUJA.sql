SELECT 
	dbo.FN_FCAV_PRIMEIRA_MAIUSCULA(LTRIM(RTRIM(PES_NOME))) collate Latin1_General_CI_AI AS DOCENTE,
	PES_NRODOC2 AS RG,
	PES_DATDOC2 AS DATA_EMISSAO,
	PES_ORGEMIDOC2 AS ORGAO_EMISSOR,
	LOWER(PES_EMAIL) collate Latin1_General_CI_AI AS E_MAIL
FROM
	LINKED_ICORUJA.vanzolini_icoruja.dbo.TB_PESSOA
	
WHERE
	--CAU_NROAULA = '1'
	PES_EHPROF = 1
	AND PES_NOME IN ( 'Francisco Carone Filho',
							'Fabio Lombardi Calza',
							'Luciano Mazza',
							'Leo Brunstein',
							'Reinaldo Pacheco da Costa',
							'Eduardo Melchert')