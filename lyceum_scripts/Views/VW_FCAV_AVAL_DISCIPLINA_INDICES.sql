
/*
	VIEW VW_FCAV_AVAL_DISCIPLINA_INDICES

Finalidade: Traz o indice de aprovação e rejeição da disciplina
1ª Avaliação 

Autor: Gabriel
Data: 13/06/2018

*/
ALTER VIEW VW_FCAV_AVAL_DISCIPLINA_INDICES
AS
SELECT 
	* 
FROM 
	VW_FCAV_AVAL_INDICES_GERAL 
WHERE
	ASPECTO = 'DISCIPLINA'