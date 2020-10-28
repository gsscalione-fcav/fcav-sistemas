/*select * from LY_TURMA where turma
 = 'A-MSP T 01'

exec a_TAGS_CUSTOM_REQUERIMENTO 'E201720021', 'CEAI','NOTURNO','CEAI 2017/2',1,2017,2,NULL
*/
ALTER PROCEDURE  a_TAGS_CUSTOM_REQUERIMENTO  
   @p_aluno T_CODIGO,  
   @p_curso T_CODIGO,  
   @p_turno T_CODIGO,  
   @p_curriculo T_CODIGO,  
   @p_serie T_NUMERO,  
   @p_ano T_ANO,   
   @p_periodo T_SEMESTRE,  
   @p_tipoMatricula T_CODIGO   
   AS  
  
		
   
   RETURN