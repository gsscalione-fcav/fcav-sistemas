  
/*        
  **VW_FCAV_APOIOWEB_INGRESSANTES**        
          
 - VIEW PARA TRAZER A RELAÇÃO DE ALUNOS QUE INGRESSANTES.    
        
  
 SELECT * FROM VW_FCAV_APOIOWEB_INGRESSANTES 
 WHERE turma = 'CEGP T 72'
 order by dt_inscricao desc

 SELECT * FROM vw_fcaV_s WHERE CONCURSO = 'CEAI T 35'
        
Autor: Gabriel S. Scalione         
Criação: 15/08/2019        
  
*/  
  

    
ALTER VIEW VW_FCAV_APOIOWEB_INGRESSANTES  
AS   

	select * from FCAV_APOIOWEB_INGRESSANTES