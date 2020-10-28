/*       
 VIEW VW_FCAV_AVAL_INFRA_INDICES       

 Finalidade: Traz o indice de aprova��o de rejei��o da infra estrutura da turma.

 Autor: Gabriel SS
 Data: 13/06/2018
       
*/ 


ALTER VIEW VW_FCAV_AVAL_INFRA_INDICES
AS

SELECT 
	* 
FROM 
	VW_FCAV_AVAL_INDICES_GERAL 
WHERE
	ASPECTO = 'INFRAESTRUTURA'
