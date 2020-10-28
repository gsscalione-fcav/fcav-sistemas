/*e_mail		-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL, NULL, NULL, 'gabriel.scalione@vanzolini.org.br', NULL, NULL
/*e_mail		-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL, NULL, NULL, 'scalione@gmail.com', NULL, NULL


SELECT boleto, NUMERO_RPS FROM LY_BOLETO 
where 
	BOLETO in (54920,54921)


update LY_BOLETO 
set
	EMPRESA = 'FCAV'
where 
	EMPRESA is null
	
	
	SELECT * FROM HD_TABELAITEM WHERE DESCR = 'RG'