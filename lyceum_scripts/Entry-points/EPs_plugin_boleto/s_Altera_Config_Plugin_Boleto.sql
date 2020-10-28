DROP PROCEDURE s_Altera_Config_Plugin_Boleto
GO
CREATE PROCEDURE s_Altera_Config_Plugin_Boleto
(  
     @p_boleto numeric(10),  
     @p_id varchar(2000) output,  
     @p_chave_id varchar(2000) output,  
     @p_substitui char(1) output  
)  
AS  
BEGIN  
-- [INÍCIO] Customização - Não escreva código antes desta linha  
  
    -- Por padrao, define troca id e chave para um valor invalido
    SET @p_substitui = 'S'    
    SET @p_id = 'convenioNaoProgramadoNoEP'
    SET @p_chave_id = 'convenioNaoProgramadoNoEP'

    --
    -- Descobre em qual servidor esta rodando
    --
    -- Servidor de producao 'JUPITER'
    -- Servidor de homologacao 'SATURNO'

    -- Se o servidor atual for o de producao
    DECLARE @producao varchar(10)

    IF (@@SERVERNAME = 'JUPITER')
        SET @producao = 'S'
    ELSE
        SET @producao = 'N'

    --    
    -- Pega os dados do boleto para escolher a conta de plugin que sera usada
    --
    DECLARE @v_banco INT    
    DECLARE @v_conta_banco VARCHAR(20)  
    DECLARE @v_convenio T_CODIGO

    -- Busca banco e conta e convenio do boleto    
    SELECT @v_banco = BANCO, 
           @v_conta_banco = CONTA_BANCO,
           @v_convenio = CONVENIO 
    FROM LY_BOLETO    
    WHERE BOLETO = @p_boleto    
   
    --------------------------------------------------------------------------------------------  
    -- Banco = 33 (SANTANDER) 
    --------------------------------------------------------------------------------------------   

    IF @v_banco = '33'
    BEGIN
        -- Producao
        IF @producao = 'S'
		-- Se for um convenio 211211.6
		IF @v_convenio in ('2112116')
			BEGIN
				SET @p_id = '17839391'     
				SET @p_chave_id = 'J2846nHr'   
			END
		ELSE
			-- Se for um convenio 211214.0
			IF @v_convenio in ('2112140')
				BEGIN
					SET @p_id = '17839392'     
					SET @p_chave_id = 'R6q3Q24$p'   
				END
			ELSE
				-- Se for um convenio 211212.4
				IF @v_convenio in ('2112124')
					BEGIN
						SET @p_id = '17839390'     
						SET @p_chave_id = '7l67K3,Ml'   
					END
        -- Homologacao
        ELSE
		-- Se for um convenio 211211.6
		IF @v_convenio in ('2112116')
			BEGIN
				SET @p_id = '4266907'     
				SET @p_chave_id = 'tl7H11J00'   
			END
		ELSE
			-- Se for um convenio 211214.0
			IF @v_convenio in ('2112140')
				BEGIN
					SET @p_id = '4266908'     
					SET @p_chave_id = 'c21A7-7Mf'   
				END
			ELSE
				-- Se for um convenio 211212.4
				IF @v_convenio in ('2112124')
					BEGIN
						SET @p_id = '4266906'     
						SET @p_chave_id = 'BL2~387sm'   
					END
    END

-- [FIM] Customização - Não escreva código após esta linha  
  
RETURN  
  
END  
  