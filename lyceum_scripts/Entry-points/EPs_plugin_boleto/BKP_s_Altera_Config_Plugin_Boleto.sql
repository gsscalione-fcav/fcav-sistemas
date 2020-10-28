ALTER PROCEDURE s_Altera_Config_Plugin_Boleto  
    (  
     @p_boleto numeric(10),  
     @p_id varchar(2000) output,  
     @p_chave_id varchar(2000) output,  
     @p_substitui char(1) output  
    )  
    AS  
    BEGIN  
    -- [INÍCIO] Customização - Não escreva código antes desta linha  
   SET @p_substitui = 'N'  
    -- [FIM] Customização - Não escreva código após esta linha  
    RETURN  
    END