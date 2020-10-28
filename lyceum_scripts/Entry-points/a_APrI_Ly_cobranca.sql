    
ALTER PROCEDURE a_APrI_Ly_cobranca    
  @erro VARCHAR(1024) OUTPUT,    
  @cobranca NUMERIC(20, 10) OUTPUT, @aluno VARCHAR(200) OUTPUT, @resp VARCHAR(200) OUTPUT,     
  @ano NUMERIC(20, 10) OUTPUT, @mes NUMERIC(20, 10) OUTPUT, @num_cobranca NUMERIC(20, 10) OUTPUT,     
  @data_de_vencimento DATETIME OUTPUT, @data_de_geracao DATETIME OUTPUT, @data_de_faturamento DATETIME OUTPUT,     
  @lote NUMERIC(20, 10) OUTPUT, @apenas_cobranca VARCHAR(200) OUTPUT, @protesto VARCHAR(200) OUTPUT,     
  @ultimo_item NUMERIC(20, 10) OUTPUT, @ultimo_desc NUMERIC(20, 10) OUTPUT, @ultimo_encargo NUMERIC(20, 10) OUTPUT,     
  @data_de_protesto DATETIME OUTPUT, @data_canc_protesto DATETIME OUTPUT, @ident_contabil VARCHAR(200) OUTPUT,     
  @tipo_doc VARCHAR(200) OUTPUT, @num_doc VARCHAR(200) OUTPUT, @dt_geracao_doc DATETIME OUTPUT,     
  @dt_emissao_doc DATETIME OUTPUT, @gera_doc VARCHAR(200) OUTPUT, @Curso VARCHAR(20) OUTPUT,     
  @Turno VARCHAR(20) OUTPUT, @Curriculo VARCHAR(20) OUTPUT, @Unid_fisica VARCHAR(20) OUTPUT    
AS   
    ----------------------------------------------------------------------------  
    --Verifica se a data de vencimento é menor que a data atual.  
    
  --  IF(@data_de_vencimento IS NULL)
  --  BEGIN
		--SET @data_de_vencimento = GETDATE()
  --  END
       
    
  --  IF(CONVERT(VARCHAR,@data_de_vencimento,102) < CONVERT(VARCHAR,GETDATE(),102))  
  --  BEGIN  
	     
	 -- --Exibe mensagem de erro.  
	 -- set @erro = '!!!!!Data de vencimento informada menor que a data de hoje!!!!!!!'  
  
  --  END  
  
RETURN 