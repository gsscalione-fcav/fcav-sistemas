SELECT 
	DO.NUM_FUNC DO_NUM_FUNC, 
	DO.NOME_COMPL AS DO_NOME,	
	LOWER(DO.E_MAIL) AS DO_EMAIL, 
	DO.CPF AS DO_CPF,
	CO.NUM_FUNC AS CO_NUM_FUNC,
	CO.CURSO AS CO_CURSO,
	CO.TIPO_COORD as CO_TIPO_COORD,
	WE.*
FROM
	LY_DOCENTE DO 
	LEFT JOIN LY_COORDENACAO CO ON CO.NUM_FUNC = DO.NUM_FUNC
	LEFT JOIN FCAV_WEBUSERS WE ON WE.NOME = DO.NOME_COMPL
WHERE 
	CURSO = 'CEQP'
	--DO.NOME_COMPL like '%D�bora Pretti Ronconi%'
ORDER BY DO.NOME_COMPL, co.CURSO



SELECT * FROM FCAV_WEBUSERS   ORDER by ID DESC

DELETE FCAV_WEBUSERS WHERE ID = 84
go

EXEC PR_FCAV_INSERE_USUARIO_APOIOWEB
	'kelly',
	'144658',
    'Kelly Tomaz',
    'ComercialPTA',
    'jady.silveira@vanzolini.com.br',
    '4',
    NULL,
    NULL,
    NULL
   

UPDATE FCAV_WEBUSERS
SET
	PASS		= 'fgjhqw'
	
WHERE
	ID = 4



