ALTER PROCEDURE s_INSERE_PEDIDO_REGISTRO_BOLETO  
   @p_Boleto T_NUMERO,    
   @p_operacao varchar(20),  
   @p_Substitui T_SIMNAO output,  
   @p_Envia_Fila T_SIMNAO output,  
   @p_Registra_Na_Impressao T_SIMNAO output  
  
 AS  
   -- [IN�CIO] Customiza��o - N�o escreva c�digo antes desta linha  
   set @p_substitui = 'N'  
   -- [FIM] Customiza��o - N�o escreva c�digo ap�s esta linha