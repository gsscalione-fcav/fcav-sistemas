
SELECT DISTINCT 
		COORD.CURSO, 
		DOC.NUM_FUNC, 
		DOC.NOME_COMPL, 
		DOC.CPF, 
		DOC.E_MAIL 
FROM 
	LY_DOCENTE AS DOC 
	INNER JOIN LY_COORDENACAO AS COORD 
		ON COORD.NUM_FUNC = DOC.NUM_FUNC 
WHERE DOC.CPF = '20324492855'



select * from LY_DOCENTE where NUM_FUNC = 9111167