SELECT 
	*
FROM
	LY_BOLETO
	WHERE
BOLETO IN (125760,159227)

 
 Boletos recusados no banco


UPDATE LY_BOLETO
SET
	ENVIADO = 'N'
WHERE
BOLETO IN (159203,158618,
159138,147463,137147,147617,
159205,159217,125760,159227,
136536,147576,158591,158612,
159218)



select * from 
	LY_ITEM_LANC WHERE
BOLETO IN (159203,158618,
159138,147463,137147,147617,
159205,159217,125760,159227,
136536,147576,158591,158612,
159218)
and CODIGO_LANC = 'acordo'

159218

select 
	* from LY_GRADE
where 
	CURRICULO = 'CEAI 2018/1'