SELECT
	*
FROM 
	LY_MATRICULA
WHERE
	ALUNO in 
	('E201720051','E201720047','E201720013')
	
	
	
SELECT
	*
FROM 
	LY_CANDIDATO
WHERE
	CANDIDATO IN (SELECT
						CANDIDATO
				  FROM 
						LY_ALUNO
				  WHERE
					 ALUNO in 
				    ('E201720051','E201720047','E201720013')
				 )