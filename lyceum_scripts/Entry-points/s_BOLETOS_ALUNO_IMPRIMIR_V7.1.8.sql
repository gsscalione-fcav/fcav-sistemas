CREATE procedure s_BOLETOS_ALUNO_IMPRIMIR(      
 @p_aluno [T_CODIGO],      
 @p_substitui varchar(1) output      
)      
as      
-- [INÍCIO]               
set @p_substitui = 'S'      
      
--campos necessários no retorno: codBoleto, dataVencimento, valor,       
--tipoCobranca (de acordo com num_cobranca 0 = Diversos, 1 = Mensalidade, 2 = Serviço, 3 = Acordo, 4 = Outros, 5 = Cheque      
--codBanco, agencia, conta e carteira     
SELECT     
 B.BOLETO AS codBoleto,     
 VW.DATA_DE_VENCIMENTO AS dataVencimento,     
 VW.VALOR AS valor,    
 b.banco as codBanco, b.agencia, b.conta_banco as conta, b.carteira,  
 CASE WHEN IL.CODIGO_LANC LIKE 'M%' THEN 1    
  WHEN IL.CODIGO_LANC = 'ACORDO' THEN 3    
  ELSE 4
 END AS tipoCobranca    
FROM    
 LY_BOLETO B     
 INNER JOIN LY_ITEM_LANC IL ON (B.BOLETO = IL.BOLETO)    
 INNER JOIN VW_COBRANCA VW ON (IL.COBRANCA = VW.COBRANCA)    
     
WHERE    
 VW.ALUNO = @p_aluno   
    AND VW.VALOR  > 0     
GROUP BY    
 B.BOLETO,    
 VW.DATA_DE_VENCIMENTO,     
 VW.VALOR,   
 b.banco,  
 b.agencia,   
 b.conta_banco,   
 b.carteira,  
 IL.CODIGO_LANC  
   
        
RETURN            
-- [FIM] 