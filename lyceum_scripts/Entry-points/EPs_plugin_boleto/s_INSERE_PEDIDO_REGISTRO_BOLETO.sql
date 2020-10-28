DROP PROCEDURE s_INSERE_PEDIDO_REGISTRO_BOLETO
GO
CREATE PROCEDURE s_INSERE_PEDIDO_REGISTRO_BOLETO  
 @p_Boleto T_NUMERO,    
 @p_operacao varchar(20),  
 @p_Substitui T_SIMNAO output,  
 @p_Envia_Fila T_SIMNAO output,  
 @p_Registra_Na_Impressao T_SIMNAO output  
AS  
BEGIN  
-- [INÍCIO] Customização - Não escreva código antes desta linha  

    -- Por padrao, o EP nao vai mexer na regra definida na tela de configuracao do registro de boleto
    SET @p_substitui = 'N'  

    -- 28/11/18 - Bruno Franca  
    -- FIX para funcionalidade que o produto nao implementou ainda (ate a versao 7.2.4)
    --  
    -- Todas as operacoes diferentes de Registros nao devem ir para a fila
    IF @p_operacao <> 'Registro' 
    BEGIN
        SET @p_substitui = 'S'  
        SET @p_Envia_Fila = 'N'  
        SET @p_Registra_Na_Impressao = 'N'  
        RETURN
    END

    -- 28/11/18 - Bruno Franca (inclusao de 104, 105, 106, 107_1, 107_2,109)
    --
    -- Trava para garantir que so entram na fila os boletos dos grupos ja implementados

    -- Descobre grupo (unidade) a partir do boleto
    DECLARE @v_grupo_unidade VARCHAR(20)  
    select @v_grupo_unidade = I.GRUPO  
    FROM LY_BOLETO B 
    JOIN LY_AGREGA_ITEM_COBRANCA I ON B.BANCO = I.BANCO 
    AND B.AGENCIA = I.AGENCIA 
    AND B.CONTA_BANCO = I.CONTA_BANCO 
    AND B.CARTEIRA = I.CARTEIRA 
    AND B.CONVENIO = I.CONVENIO  
    WHERE B.BOLETO = @p_Boleto  
    
    -- Se nao for de um grupo ja implementado, garante que nao entra na fila
    IF @v_grupo_unidade NOT IN ('Grupo 001', 'Grupo 002', 'Grupo 003')
    BEGIN  
        SET @p_substitui = 'S'  
        SET @p_Envia_Fila = 'N'  
        SET @p_Registra_Na_Impressao = 'N'  
        RETURN  
    END  

 -- [FIM] Customização - Não escreva código após esta linha  
END  