/*  
 Entry-point a_GERA_BOLETO_MATR_AVULSA    
  
 Descrição:   
  É chamada quando for gerado o boleto de matricula avulsa e altera a data de vencimento do boleto, idenficando se responsável é PJ ou PF.  
  
Alteração:  

 07/03/2017 - Toda a codificação foi retirada porque a matricula avulsa não será mais utilizado.
     Por Gabriel SScalione  
  
  
Autor: Ricardo Nunes consultor da Techne  
Data:   
  
*/  
  
ALTER PROCEDURE a_GERA_BOLETO_MATR_AVULSA    
  @p_sessao_id varchar(40),    
  @p_aluno T_CODIGO,     
  @p_ano_letivo T_ANO,     
  @p_periodo_letivo T_SEMESTRE2,     
  @p_regerar_ano T_ANO,    
  @p_regerar_mes T_MES,    
  @p_data_venc T_DATA output    
AS      
    
    
 RETURN