
ALTER TABLE FCAV_TURMA_DOCENTE 
ADD 
	MEDIA_DOCENTE_DISCIPLINA T_DECIMAL_MEDIO NULL,
	COMENTARIO T_ALFAEXTRALARGE NULL ;  
	
	

ALTER TABLE FCAV_TURMA_DOCENTE DROP COLUMN COMENTARIO ;  

SELECT 
	* 
FROM 
	FCAV_TURMA_DOCENTE
WHERE 
	
	ANO = 2017

