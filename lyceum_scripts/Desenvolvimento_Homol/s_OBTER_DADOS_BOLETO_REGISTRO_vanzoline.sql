ALTER PROCEDURE s_OBTER_DADOS_BOLETO_REGISTRO
  (
   @p_boleto numeric(10),
   @p_boleto_candidato T_SIMNAO,
   @p_nome_beneficiario VARCHAR(100) OUTPUT,
   @p_mensagem_cabecalho_boleto VARCHAR(2000) OUTPUT,
   @p_instrucao_linha_1_boleto VARCHAR(2000) OUTPUT,
   @p_instrucao_linha_2_boleto VARCHAR(2000) OUTPUT,
   @p_instrucao_linha_3_boleto VARCHAR(2000) OUTPUT,
   @p_data_validade_boleto T_DATA OUTPUT,
   @p_cpf_cnpj_pagador VARCHAR(100) OUTPUT,
   @p_nome_pagador VARCHAR(100) OUTPUT, 
   @p_logradouro_pagador VARCHAR(100) OUTPUT, 
   @p_bairro_pagador VARCHAR(100) OUTPUT, 
   @p_cidade_pagador VARCHAR(100) OUTPUT, 
   @p_uf_pagador CHAR(2) OUTPUT, 
   @p_cep_pagador VARCHAR(100) OUTPUT, 
   @p_nosso_numero_boleto T_NUMERO_GRANDE OUTPUT, 
   @p_data_vencimento_boleto T_DATA OUTPUT,
   @p_valor_titulo_boleto T_DECIMAL_MEDIO OUTPUT,  
   @p_seu_numero_boleto T_NUMERO_GRANDE OUTPUT, 
   @p_especie_cobranca VARCHAR(100) OUTPUT,  
   @p_data_emissao_boleto T_DATA OUTPUT,	
   @p_valor_abatimento_cobranca T_DECIMAL_MEDIO OUTPUT,	
   @p_valor_juros T_DECIMAL_MEDIO OUTPUT,	
   @p_percentual_juros T_DECIMAL_MEDIO_PRECISO6 OUTPUT,
   @p_data_multa T_DATA OUTPUT,	
   @p_percentual_multa T_DECIMAL_MEDIO OUTPUT,
   @p_data_desconto T_DATA OUTPUT,
   @p_tipo_desconto  VARCHAR(100) OUTPUT,
   @p_valor_desconto T_DECIMAL_MEDIO OUTPUT,
   @p_percentual_desconto T_DECIMAL_MEDIO_PRECISO6 OUTPUT,	
   @p_cod_convenio_beneficiario T_CODIGO OUTPUT,
   @p_tipo_pagador VARCHAR(100) OUTPUT,
   @p_numero_carteira_beneficiario VARCHAR(100) OUTPUT,
   @p_tipo_multa VARCHAR(100) OUTPUT,
   @p_valor_multa T_DECIMAL_MEDIO OUTPUT,
   @p_tipo_registro_controle VARCHAR(100) OUTPUT,
   @p_tipo_cobranca_controle VARCHAR(100) OUTPUT,
   @p_tipo_produto_controle VARCHAR(100) OUTPUT,
   @p_subproduto_controle VARCHAR(100) OUTPUT,
   @p_cpf_cnpj_beneficiario VARCHAR(100) OUTPUT,
   @p_agencia_beneficiario T_ALFASMALL OUTPUT,
   @p_conta_beneficiario T_ALFASMALL OUTPUT,
   @p_digito_verificador_conta_beneficiario CHAR(1) OUTPUT,  
   @p_agencia_debito T_ALFASMALL OUTPUT,
   @p_conta_debito T_ALFASMALL OUTPUT,
   @p_digito_verificador_conta_debito CHAR(1) OUTPUT,
   @p_identificador_titulo_empresa_cobranca VARCHAR(100) OUTPUT,
   @p_uso_banco_cobranca VARCHAR(100) OUTPUT,
   @p_titulo_aceite_cobranca VARCHAR(100) OUTPUT,
   @p_email_pagador VARCHAR(100) OUTPUT,
   @p_cpf_cnpj_sacador_avalista VARCHAR(100) OUTPUT,
   @p_nome_sacador_avalista VARCHAR(100) OUTPUT,
   @p_logradouro_sacador_avalista VARCHAR(100) OUTPUT, 
   @p_bairro_sacador_avalista VARCHAR(100) OUTPUT, 
   @p_cidade_sacador_avalista VARCHAR(100) OUTPUT,
   @p_uf_sacador_avalista CHAR(2) OUTPUT,
   @p_cep_sacador_avalista VARCHAR(10) OUTPUT,
   @p_codigo_moeda_cnab_moeda VARCHAR(100) OUTPUT,
   @p_quantidade_moeda VARCHAR(100) OUTPUT,
   @p_digito_verificador_nosso_numero_boleto CHAR(1) OUTPUT,
   @p_codigo_barras_boleto T_ALFAMEDIUM OUTPUT,
   @p_data_limite_pagamento_boleto T_DATA OUTPUT,
   @p_tipo_pagamento_boleto VARCHAR(100) OUTPUT,
   @p_indicador_pagamento_parcial_cobranca VARCHAR(100) OUTPUT,
   @p_quantidade_pagamento_parcial_cobranca VARCHAR(100) OUTPUT,
   @p_quantidade_parcelas_cobranca VARCHAR(100) OUTPUT,
   @p_instrucao_cobranca_1_cobranca VARCHAR(100) OUTPUT,
   @p_quantidade_dias_1_cobranca VARCHAR(100) OUTPUT,
   @p_data_instrucao_1_cobranca VARCHAR(100) OUTPUT,
   @p_instrucao_cobranca_2_cobranca VARCHAR(100) OUTPUT,
   @p_quantidade_dias_2_cobranca VARCHAR(100) OUTPUT,
   @p_data_instrucao_2_cobranca VARCHAR(100) OUTPUT,
   @p_instrucao_cobranca_3_cobranca VARCHAR(100) OUTPUT,
   @p_quantidade_dias_3_cobranca VARCHAR(100) OUTPUT,
   @p_data_instrucao_3_cobranca VARCHAR(100) OUTPUT,
   @p_data_juros T_DATA OUTPUT,
   @p_tipo_juros VARCHAR(100) OUTPUT,
   @p_tipo_autorizacao_recebimento_divergente VARCHAR(100) OUTPUT,
   @p_tipo_valor_percentual_recebimento_divergente T_DECIMAL_MEDIO_PRECISO OUTPUT,
   @p_valor_minimo_recebimento_divergente T_DECIMAL_MEDIO OUTPUT,
   @p_percentual_minimo_recebimento_divergente T_DECIMAL_MEDIO_PRECISO OUTPUT,
   @p_valor_maximo_recebimento_divergente T_DECIMAL_MEDIO OUTPUT,
   @p_percentual_maximo_recebimento_divergente T_DECIMAL_MEDIO_PRECISO OUTPUT,
   @p_agencia_grupo_rateio T_ALFASMALL OUTPUT,
   @p_conta_grupo_rateio T_ALFASMALL OUTPUT,
   @p_digito_verificador_conta_grupo_rateio CHAR(1) OUTPUT,
   @p_tipo_grupo_rateio VARCHAR(100) OUTPUT,
   @p_valor_percentual_grupo_rateio T_DECIMAL_MEDIO OUTPUT,
   @p_tipo_carteira_titulo_beneficiario VARCHAR(100) OUTPUT,
   @p_expiracao_token_controle VARCHAR(100) OUTPUT,
   @p_sistema_banco_controle VARCHAR(100) OUTPUT,
   @p_tipo_protesto_boleto VARCHAR(100) OUTPUT,
   @p_qt_dias_protesto_boleto T_NUMERO OUTPUT,
   @p_qt_dias_baixa_boleto T_NUMERO OUTPUT,
   @p_cod_banco_beneficiario T_NUMERO_PEQUENO OUTPUT,  
   @p_merchant_id_controle VARCHAR(100) OUTPUT,
   @p_meio_pagamento_cobranca VARCHAR(100) OUTPUT,
   @p_url_logotipo_boleto VARCHAR(100) OUTPUT,
   @p_tipo_renderizacao_boleto VARCHAR(100) OUTPUT,
   @p_token_request_confirmacao_pagamento_controle VARCHAR(100) OUTPUT,
   @p_ip_maquina_cliente_controle VARCHAR(100) OUTPUT,
   @p_user_agent_controle VARCHAR(100) OUTPUT,
   @p_numero_endereco_pagador VARCHAR(100) OUTPUT,
   @p_complemento_pagador VARCHAR(100) OUTPUT,
   @p_agencia_pagador T_ALFASMALL OUTPUT,
   @p_razao_conta_pagador VARCHAR(100) OUTPUT,
   @p_conta_pagador T_ALFASMALL OUTPUT,
   @p_controle_participante_boleto VARCHAR(100) OUTPUT,
   @p_aplicar_multa VARCHAR(100) OUTPUT,
   @p_valor_iof T_DECIMAL_MEDIO OUTPUT,
   @p_debito_automatico_debito VARCHAR(100) OUTPUT,
   @p_rateio_credito VARCHAR(100) OUTPUT,
   @p_endereco_debito_automatico_debito VARCHAR(100) OUTPUT,
   @p_tipo_ocorrencia_cobranca VARCHAR(100) OUTPUT,
   @p_sequencia_registro_boleto VARCHAR(100) OUTPUT,
   @p_primeira_instrucao_boleto VARCHAR(2000) OUTPUT,
   @p_segunda_instrucao_boleto VARCHAR(2000) OUTPUT,
   @p_descricao_compra_controle VARCHAR(100) OUTPUT,
   @p_numero_variacao_carteira_beneficiario VARCHAR(100) OUTPUT,
   @p_codigo_modalidade_titulo_boleto VARCHAR(100) OUTPUT,
   @p_quantidade_dia_protesto_boleto VARCHAR(100) OUTPUT,
   @p_codigo_tipo_juro_mora_juros VARCHAR(100) OUTPUT,
   @p_codigo_aceite_titulo_boleto VARCHAR(100) OUTPUT,
   @p_codigo_tipo_titulo_boleto VARCHAR(100) OUTPUT,
   @p_indicador_permissao_recebimento_parcial_boleto VARCHAR(100) OUTPUT,
   @p_texto_campo_utilizacao_beneficiario_boleto VARCHAR(2000) OUTPUT,
   @p_codigo_tipo_conta_caucao_boleto VARCHAR(100) OUTPUT,
   @p_texto_mensagem_bloqueto_ocorrencia_boleto VARCHAR(2000) OUTPUT,
   @p_numero_inscricao_pagador VARCHAR(100) OUTPUT,
   @p_nome_municipio_pagador VARCHAR(100) OUTPUT,
   @p_texto_numero_telefone_pagador VARCHAR(100) OUTPUT,
   @p_codigo_tipo_inscricao_avalista_pagador VARCHAR(100) OUTPUT,
   @p_numero_inscricao_avalista_pagador VARCHAR(100) OUTPUT,
   @p_nome_avalista_titulo_pagador VARCHAR(100) OUTPUT,
   @p_codigo_chave_usuario_controle VARCHAR(100) OUTPUT,
   @p_codigo_tipo_canal_solicitacao_controle VARCHAR(100) OUTPUT,
   @p_descricao_tipo_titulo_boleto VARCHAR(100) OUTPUT,
   @p_numero_endereco_avalista VARCHAR(100) OUTPUT,
   @p_complemento_endereco_avalista VARCHAR(100) OUTPUT,
   @p_tipo_documento_sacador_avalista VARCHAR(100) OUTPUT,
   @p_tipo_bonificacao VARCHAR(100) OUTPUT,
   @p_perc_desc_bonificacao T_DECIMAL_MEDIO_PRECISO6 OUTPUT,
   @p_valor_desc_bonificacao T_DECIMAL_MEDIO OUTPUT,
   @p_data_limite_desc_bonificacao VARCHAR(100) OUTPUT,
   @p_tipo_emissao_papeleta VARCHAR(100) OUTPUT,
   @p_qtde_parcelas VARCHAR(100) OUTPUT,
   @p_tipo_decurso_prazo VARCHAR(100) OUTPUT,
   @p_qtde_dias_decurso VARCHAR(100) OUTPUT,
   @p_qtde_dias_juros VARCHAR(100) OUTPUT,
   @p_qtde_dias_multa_atraso VARCHAR(100) OUTPUT,
   @p_tipo_protesto_negociacao_protesto VARCHAR(100) OUTPUT,
   @p_qtde_dias_protesto VARCHAR(100) OUTPUT
  )
  AS
  BEGIN
  -- [INÍCIO] Customização - Não escreva código antes desta linha


	-- ########################################################################################################
	--
	-- AJUSTAR MENSAGENS DE INSTRUÇÃO
	--
	-- ########################################################################################################

	DECLARE @v_instrucao_linha3_aux VARCHAR(2000) 
	DECLARE @v_instrucoes VARCHAR(2000)
	DECLARE @v_concurso T_CODIGO -- EM CASO DE SER BOLETO DE CANDIDATO
	DECLARE @ARRAY VARCHAR(8000)
	DECLARE @DELIMITADOR INT
	DECLARE @S VARCHAR(8000)   
	DECLARE @ordem_aux INT
		 
	SET @DELIMITADOR = 100;
	SET @ordem_aux = 3;
		 
	IF ( @p_boleto_candidato = 'N' )
	BEGIN
		SELECT @v_instrucoes = INSTRUCOES FROM LY_BOLETO WITH(NOLOCK) WHERE BOLETO = @p_Boleto;
	END
	ELSE
	BEGIN
		SELECT @v_concurso =  CONCURSO FROM LY_CANDIDATO WITH(NOLOCK) WHERE BOLETO = @p_Boleto;
		SELECT @v_instrucoes = BOLETO_INSTRUCOES FROM LY_CONCURSO WITH(NOLOCK) WHERE CONCURSO = @v_concurso;
	END

	-- PASSA INSTRUCAO PARA A VARIAVEL @ARRAY   
	SET @ARRAY = REPLACE(REPLACE(@v_instrucoes, CHAR(13), ' '), CHAR(10), ' ');

	-- CRIA TABELA TEMPORARIA PARA GUARDAR VALORES
	CREATE TABLE #ARRAY(ORDEM INT IDENTITY(1,1), ITEM_ARRAY VARCHAR(8000))     
		 
	-- PERCORRE ARRAY E QUEBRA A INSTRUÇÃO EM PEDAÇOS DEFINIDOS NO DELIMITADOR
	WHILE LEN(@ARRAY) > 0   
	BEGIN  
		SELECT @S = LTRIM(SUBSTRING(@ARRAY, 1, @DELIMITADOR));   
		INSERT INTO #ARRAY (ITEM_ARRAY) VALUES (@S);
		 				   
		-- REMOVE PARTE DA FRASE RETIRADA
		SELECT @ARRAY = SUBSTRING(@ARRAY, @DELIMITADOR + 1, LEN(@ARRAY))    
	END  
		 
	-- MOSTRANDO O RESULTADO JÁ POPULADO NA TABELA TEMPORÁRIA   
	-- OBTEM VALORES DA TABELA
		 
	-- OBTEM A PRIMEIRA (1ª) INSTRUÇÃO
	SET @p_instrucao_linha_1_boleto = (SELECT LTRIM(RTRIM(ITEM_ARRAY)) AS INSTRUCAO_1 FROM #ARRAY WHERE ITEM_ARRAY IS NOT NULL AND DATALENGTH(ITEM_ARRAY) > 0  AND ORDEM = 1)
		 
	-- OBTEM A SEGUNDA (2ª) INSTRUÇÃO
	SET @p_instrucao_linha_2_boleto = (SELECT LTRIM(RTRIM(ITEM_ARRAY)) AS INSTRUCAO_1 FROM #ARRAY WHERE ITEM_ARRAY IS NOT NULL AND DATALENGTH(ITEM_ARRAY) > 0  AND ORDEM = 2)
		 
	-- OBTEM A TERCEIRA (3ª) INSTRUÇÃO
	SET @p_instrucao_linha_3_boleto = (SELECT LTRIM(RTRIM(ITEM_ARRAY)) AS INSTRUCAO_1 FROM #ARRAY WHERE ITEM_ARRAY IS NOT NULL AND DATALENGTH(ITEM_ARRAY) > 0  AND ORDEM = 3)

	-- REMOVE A TABELA TEMPORARIA
		DROP TABLE #ARRAY   

	-- ########################################################################################################
	--
	-- FIM - AJUSTAR MENSAGENS DE INSTRUÇÃO
	--
	-- ########################################################################################################



  -- [FIM] Customização - Não escreva código após esta linha
  RETURN
  END