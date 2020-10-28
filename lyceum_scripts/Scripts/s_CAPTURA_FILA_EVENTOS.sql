CREATE PROCEDURE s_CAPTURA_FILA_EVENTOS  
 @TABELA       VARCHAR(50),  
 @OPERACAO      VARCHAR(20),  
 @CHAVE_OBJETO_1    VARCHAR(50),  
 @CHAVE_OBJETO_2    VARCHAR(50),  
 @CHAVE_OBJETO_3    VARCHAR(50),  
 @CHAVE_OBJETO_4    VARCHAR(50),  
 @CHAVE_OBJETO_5    VARCHAR(50),  
 @CHAVE_OBJETO_6    VARCHAR(50),  
 @CHAVE_OBJETO_7    VARCHAR(50),  
 @CHAVE_OBJETO_8    VARCHAR(50),  
 @CHAVE_OBJETO_9    VARCHAR(50),  
 @CHAVE_OBJETO_10   VARCHAR(50),  
 @SUBSTITUI      VARCHAR(1) OUTPUT  
AS  
BEGIN       
 -- [INÍCIO] Customização - Não escreva código antes desta linha      
   
 SET @SUBSTITUI = 'N'  
   
 -- [FIM] Customização - Não escreva código após esta linha  
RETURN  
END