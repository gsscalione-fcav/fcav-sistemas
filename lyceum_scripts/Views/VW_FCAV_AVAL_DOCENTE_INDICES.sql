/*         
 VIEW VW_FCAV_AVAL_DOCENTE_INDICES         
  
 Finalidade: Traz o indice de aprovação de rejeição do docente da turma.  
  
 Autor: Gabriel SS  
 Data: 13/06/2018  
         
*/   
  
  
ALTER VIEW VW_FCAV_AVAL_DOCENTE_INDICES  
AS  


SELECT 
	* 
FROM 
	VW_FCAV_AVAL_INDICES_GERAL 
WHERE
	ASPECTO = 'DOCENTE'