ALTER PROCEDURE s_Altera_Config_Plugin_Boleto  
    (  
     @p_boleto numeric(10),  
     @p_id varchar(2000) output,  
     @p_chave_id varchar(2000) output,  
     @p_substitui char(1) output  
    )  
    AS  
    BEGIN  
    -- [IN�CIO] Customiza��o - N�o escreva c�digo antes desta linha  
   SET @p_substitui = 'N'  
    -- [FIM] Customiza��o - N�o escreva c�digo ap�s esta linha  
    RETURN  
    END