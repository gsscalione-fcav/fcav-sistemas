-- ----------------------------------------------------------------------------------------
-- OBTER_DADOS_BOLETO_REGISTRO.sql
-- ----------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM SYSOBJECTS 
           WHERE NAME = 'OBTER_DADOS_BOLETO_REGISTRO' AND TYPE = 'P') 
   DROP PROCEDURE OBTER_DADOS_BOLETO_REGISTRO 
GO 

CREATE PROCEDURE OBTER_DADOS_BOLETO_REGISTRO
(
	-- DADOS COMUNS
	@p_id_pedido_registro_boleto T_NUMERO,
	@p_Id_cliente VARCHAR(8000), 
	@p_chaveId VARCHAR(8000), 
	@p_Boleto T_NUMERO,  
	@p_Boleto_candidato T_SIMNAO,
	@p_operacao VARCHAR(20),
	@p_ehProducao VARCHAR(8000) OUTPUT,
	@p_mensagem_servico_rest VARCHAR(MAX) OUTPUT

)
AS
BEGIN  
-- [INÍCIO]	
	DECLARE @v_concurso T_CODIGO -- EM CASO DE SER BOLETO DE CANDIDATO

	--cursor de encargos
	DECLARE @v_cursor_tipo_calculo T_CODIGO
	DECLARE @v_cursor_valor T_DECIMAL_MEDIO_PRECISO6
	DECLARE @v_cursor_tipo_encargo T_CODIGO

	--cursos de descontos
	DECLARE @v_cursor_tipo_desc	T_TIPO_TAXA
	DECLARE @v_cursor_valor_desconto T_DECIMAL_MEDIO_PRECISO6

	--perde bolsa
	DECLARE @v_perde_bolsa_lanc_deb TABLE(LANC_DEB T_NUMERO)
	DECLARE @v_perde_bolsa_parc T_NUMERO
	DECLARE @v_perde_bolsa_valor  T_DECIMAL_MEDIO
	DECLARE @v_calcula_perda_bolsa INT
	DECLARE @v_data_perda_bolsa	T_DATA
	DECLARE @v_mensagens_desconto TABLE(MENSSAGEM VARCHAR(1000))
	DECLARE @v_aluno T_CODIGO
	DECLARE @v_utiliza_venc_dia_util VARCHAR(1)

	-- INFORMAÇÕES DO BANCO

	DECLARE @v_nome_beneficiario VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_mensagem_cabecalho_boleto VARCHAR(2000)
	DECLARE @v_instrucao_linha_1_boleto VARCHAR(2000)
	DECLARE @v_instrucao_linha_2_boleto VARCHAR(2000)
	DECLARE @v_instrucao_linha_3_boleto VARCHAR(2000)
	DECLARE @v_data_validade_boleto T_DATA
	DECLARE @v_cpf_cnpj_pagador VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_nome_pagador VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_logradouro_pagador VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_bairro_pagador VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_cidade_pagador VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_uf_pagador CHAR(2) -- (OBRIGATÓRIO)
	DECLARE @v_cep_pagador VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_nosso_numero_boleto T_NUMERO_GRANDE -- (OBRIGATÓRIO)
	DECLARE @v_data_vencimento_boleto T_DATA
	DECLARE @v_valor_titulo_boleto T_DECIMAL_MEDIO  -- (OBRIGATÓRIO)
	DECLARE @v_valor_titulo_boleto_desc T_DECIMAL_MEDIO --para cálculo do desconto
	DECLARE @v_seu_numero_boleto T_NUMERO_GRANDE -- (OBRIGATÓRIO)
	DECLARE @v_especie_cobranca VARCHAR(100)  -- (OBRIGATÓRIO)
	DECLARE @v_data_emissao_boleto T_DATA	-- (OBRIGATÓRIO)
	DECLARE @v_valor_abatimento_cobranca T_DECIMAL_MEDIO	
	DECLARE @v_valor_juros T_DECIMAL_MEDIO	
	DECLARE @v_percentual_juros T_DECIMAL_MEDIO_PRECISO6
	DECLARE @v_data_multa T_DATA	
	DECLARE @v_percentual_multa T_DECIMAL_MEDIO
	DECLARE @v_data_desconto T_DATA
	DECLARE @v_tipo_desconto  VARCHAR(100)
	DECLARE @v_valor_desconto T_DECIMAL_MEDIO
	DECLARE @v_percentual_desconto T_DECIMAL_MEDIO_PRECISO6	
	DECLARE @v_cod_convenio_beneficiario T_CODIGO
	DECLARE @v_tipo_pagador VARCHAR(100)	
	DECLARE @v_numero_carteira_beneficiario VARCHAR(100)
	DECLARE @v_tipo_multa VARCHAR(100) 
	DECLARE @v_valor_multa T_DECIMAL_MEDIO
	DECLARE @v_1_Instrucao NUMERIC(2)
	DECLARE @v_2_Instrucao NUMERIC(2)

	-- DADOS ITAU
	DECLARE @v_tipo_registro_controle VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_tipo_cobranca_controle VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_tipo_produto_controle VARCHAR(100) -- (OBRIGATÓRIO) 
	DECLARE @v_subproduto_controle VARCHAR(100) -- (OBRIGATÓRIO) 
	DECLARE @v_cpf_cnpj_beneficiario VARCHAR(100) -- (OBRIGATÓRIO) 
	DECLARE @v_agencia_beneficiario T_ALFASMALL -- (OBRIGATÓRIO) 
	DECLARE @v_conta_beneficiario T_ALFASMALL -- (OBRIGATÓRIO) 
	DECLARE @v_digito_verificador_conta_beneficiario CHAR(1) -- (OBRIGATÓRIO) 
	DECLARE @v_agencia_debito T_ALFASMALL
	DECLARE @v_conta_debito T_ALFASMALL
	DECLARE @v_digito_verificador_conta_debito CHAR(1)
	DECLARE @v_identificador_titulo_empresa_cobranca VARCHAR(100)
	DECLARE @v_uso_banco_cobranca VARCHAR(100)
	DECLARE @v_titulo_aceite_cobranca VARCHAR(100)  -- (OBRIGATÓRIO) 
	DECLARE @v_email_pagador VARCHAR(100)
	DECLARE @v_cpf_cnpj_sacador_avalista VARCHAR(100)
	DECLARE @v_nome_sacador_avalista VARCHAR(100) 
	DECLARE @v_logradouro_sacador_avalista VARCHAR(100) 
	DECLARE @v_bairro_sacador_avalista VARCHAR(100) 
	DECLARE @v_cidade_sacador_avalista VARCHAR(100) 
	DECLARE @v_uf_sacador_avalista CHAR(2) 
	DECLARE @v_cep_sacador_avalista VARCHAR(10)
	DECLARE @v_codigo_moeda_cnab_moeda VARCHAR(100)  -- (OBRIGATÓRIO)
	DECLARE @v_quantidade_moeda VARCHAR(100)
	DECLARE @v_digito_verificador_nosso_numero_boleto CHAR(1) -- (OBRIGATÓRIO)
	DECLARE @v_codigo_barras_boleto T_ALFAMEDIUM
	DECLARE @v_data_limite_pagamento_boleto T_DATA
	DECLARE @v_tipo_pagamento_boleto VARCHAR(100) -- (OBRIGATÓRIO)
	DECLARE @v_indicador_pagamento_parcial_cobranca VARCHAR(100)
	DECLARE @v_quantidade_pagamento_parcial_cobranca VARCHAR(100)
	DECLARE @v_quantidade_parcelas_cobranca VARCHAR(100)
	DECLARE @v_instrucao_cobranca_1_cobranca VARCHAR(100)
	DECLARE @v_quantidade_dias_1_cobranca VARCHAR(100)
	DECLARE @v_data_instrucao_1_cobranca VARCHAR(100)
	DECLARE @v_instrucao_cobranca_2_cobranca VARCHAR(100)
	DECLARE @v_quantidade_dias_2_cobranca VARCHAR(100)
	DECLARE @v_data_instrucao_2_cobranca VARCHAR(100)
	DECLARE @v_instrucao_cobranca_3_cobranca VARCHAR(100)
	DECLARE @v_quantidade_dias_3_cobranca VARCHAR(100)
	DECLARE @v_data_instrucao_3_cobranca VARCHAR(100)
	DECLARE @v_data_juros T_DATA
    DECLARE @v_tipo_juros VARCHAR(100)
	DECLARE @v_tipo_autorizacao_recebimento_divergente VARCHAR(100)
	DECLARE @v_tipo_valor_percentual_recebimento_divergente T_DECIMAL_MEDIO_PRECISO6
	DECLARE @v_valor_minimo_recebimento_divergente T_DECIMAL_MEDIO
	DECLARE @v_percentual_minimo_recebimento_divergente T_DECIMAL_MEDIO_PRECISO6
	DECLARE @v_valor_maximo_recebimento_divergente T_DECIMAL_MEDIO
	DECLARE @v_percentual_maximo_recebimento_divergente T_DECIMAL_MEDIO_PRECISO6
	DECLARE @v_agencia_grupo_rateio T_ALFASMALL
	DECLARE @v_conta_grupo_rateio T_ALFASMALL
	DECLARE @v_digito_verificador_conta_grupo_rateio CHAR(1)
	DECLARE @v_tipo_grupo_rateio VARCHAR(100)
	DECLARE @v_valor_percentual_grupo_rateio T_DECIMAL_MEDIO
	DECLARE @v_tipo_carteira_titulo_beneficiario VARCHAR(100) -- (OBRIGATÓRIO) 
     

	-- DADOS SANTANDER
	DECLARE @v_expiracao_token_controle VARCHAR(100)
	DECLARE @v_sistema_banco_controle VARCHAR(100)
	DECLARE @v_tipo_protesto_boleto VARCHAR(100)
	DECLARE @v_qt_dias_protesto_boleto T_NUMERO
	DECLARE @v_qt_dias_baixa_boleto T_NUMERO
	DECLARE @v_cod_banco_beneficiario T_NUMERO_PEQUENO -- (OBRIGATÓRIO)

	-- DADOS BRADESCO 
	DECLARE @v_merchant_id_controle VARCHAR(100)
	DECLARE @v_meio_pagamento_cobranca VARCHAR(100)
	DECLARE @v_url_logotipo_boleto VARCHAR(100)
	DECLARE @v_tipo_renderizacao_boleto VARCHAR(100)
	DECLARE @v_token_request_confirmacao_pagamento_controle VARCHAR(100)
	DECLARE @v_ip_maquina_cliente_controle VARCHAR(100)
	DECLARE @v_user_agent_controle VARCHAR(100)
	DECLARE @v_numero_endereco_pagador VARCHAR(100)
	DECLARE @v_complemento_pagador VARCHAR(100)
	DECLARE @v_agencia_pagador T_ALFASMALL
	DECLARE @v_razao_conta_pagador VARCHAR(100)
	DECLARE @v_conta_pagador T_ALFASMALL
	DECLARE @v_controle_participante_boleto VARCHAR(100)
	DECLARE @v_aplicar_multa VARCHAR(100)
	DECLARE @v_valor_iof T_DECIMAL_MEDIO
	DECLARE @v_debito_automatico_debito VARCHAR(100)
	DECLARE @v_rateio_credito VARCHAR(100)
	DECLARE @v_endereco_debito_automatico_debito VARCHAR(100)
	DECLARE @v_tipo_ocorrencia_cobranca VARCHAR(100)
	DECLARE @v_sequencia_registro_boleto VARCHAR(100)
	DECLARE @v_primeira_instrucao_boleto VARCHAR(2000)
	DECLARE @v_segunda_instrucao_boleto VARCHAR(2000)
	DECLARE @v_descricao_compra_controle VARCHAR(100)
	DECLARE @v_numero_endereco_avalista VARCHAR(100)
	DECLARE @v_complemento_endereco_avalista VARCHAR(100)
	DECLARE @v_tipo_documento_sacador_avalista VARCHAR(100)
	DECLARE @v_tipo_bonificacao VARCHAR(100)
	DECLARE @v_perc_desc_bonificacao T_DECIMAL_MEDIO_PRECISO6
	DECLARE @v_valor_desc_bonificacao T_DECIMAL_MEDIO
	DECLARE @v_data_limite_desc_bonificacao VARCHAR(100)
	DECLARE @v_tipo_emissao_papeleta VARCHAR(100)
	DECLARE @v_qtde_parcelas VARCHAR(100)
	DECLARE @v_tipo_decurso_prazo VARCHAR(100)
	DECLARE @v_qtde_dias_decurso VARCHAR(100)
	DECLARE @v_qtde_dias_juros VARCHAR(100)
	DECLARE @v_qtde_dias_multa_atraso VARCHAR(100)
	DECLARE @v_tipo_protesto_negociacao_protesto VARCHAR(100)
	DECLARE @v_qtde_dias_protesto VARCHAR(100)


	-- DADOS BANCO DO BRASIL
	DECLARE @v_numero_variacao_carteira_beneficiario VARCHAR(100)
	DECLARE @v_codigo_modalidade_titulo_boleto VARCHAR(100)
	DECLARE @v_quantidade_dia_protesto_boleto VARCHAR(100)
	DECLARE @v_codigo_tipo_juro_mora_juros VARCHAR(100)
	DECLARE @v_codigo_aceite_titulo_boleto VARCHAR(100)
	DECLARE @v_codigo_tipo_titulo_boleto VARCHAR(100)
	DECLARE @v_indicador_permissao_recebimento_parcial_boleto VARCHAR(100)
	DECLARE @v_texto_campo_utilizacao_beneficiario_boleto VARCHAR(2000)
	DECLARE @v_codigo_tipo_conta_caucao_boleto VARCHAR(100)
	DECLARE @v_texto_mensagem_bloqueto_ocorrencia_boleto VARCHAR(2000)
	DECLARE @v_numero_inscricao_pagador VARCHAR(100)
	DECLARE @v_nome_municipio_pagador VARCHAR(100)
	DECLARE @v_texto_numero_telefone_pagador VARCHAR(100)
	DECLARE @v_codigo_tipo_inscricao_avalista_pagador VARCHAR(100)
	DECLARE @v_numero_inscricao_avalista_pagador VARCHAR(100)
	DECLARE @v_nome_avalista_titulo_pagador VARCHAR(100)
	DECLARE @v_codigo_chave_usuario_controle VARCHAR(100)
	DECLARE @v_codigo_tipo_canal_solicitacao_controle VARCHAR(100)
	DECLARE @v_descricao_tipo_titulo_boleto VARCHAR(100)

	----------------------------------------------------------------------------------------
	-- FLUXO DO PROCESSO:
	-- 1º Identifica se é boleto de candidato ou aluno
	-- 2º Identifica a operação (registro/alteração/remoção) caso seja boleto de candidato
	-- 3º busca os dados do boleto
	----------------------------------------------------------------------------------------

	IF @p_Boleto IS NOT NULL
	BEGIN
	
		SELECT @v_utiliza_venc_dia_util = ISNULL(SUBSTRING(VALOR_TEXTO,1,1),'S') 
		FROM LY_PARAM_CONFIGURACAO 
		WHERE CHAVE = (SELECT CHAVE FROM LY_CONFIGURACAO WHERE CONFIGURACAO = 'configGatewayBoleto')
		AND NOME = 'utilizaVencDiaUtil'


		IF ISNULL(@p_Boleto_candidato, 'N') = 'N'
		BEGIN -- OBTEM DADOS DO BOLETO DE ALUNO
		
			-- OBTEM VALOR DO DOCUMENTO
			IF EXISTS (SELECT TOP 1 1 FROM LY_ITEM_LANC WITH(NOLOCK) WHERE BOLETO = @p_Boleto AND VALOR IS NOT NULL)
			BEGIN
				SET @v_valor_titulo_boleto = (SELECT ISNULL(SUM(VALOR), 0) VALOR FROM LY_ITEM_LANC WITH(NOLOCK) WHERE BOLETO = @p_Boleto GROUP BY BOLETO)
			END

			IF EXISTS (SELECT TOP 1 1 FROM LY_ITEM_CRED WITH(NOLOCK) WHERE BOLETO = @p_Boleto AND VALOR IS NOT NULL)
			BEGIN
				SET @v_valor_titulo_boleto = ISNULL(@v_valor_titulo_boleto, 0 ) + (SELECT ISNULL(SUM(VALOR), 0) VALOR FROM LY_ITEM_CRED WITH(NOLOCK) WHERE BOLETO = @p_Boleto GROUP BY BOLETO)
			END	

			--Obtem para cálculo do desconto antecipado
			SELECT @v_valor_titulo_boleto_desc =  SUM (I.VALOR)  FROM LY_ITEM_LANC I 
						LEFT OUTER JOIN LY_COD_LANC C ON I.CODIGO_LANC = C.CODIGO_LANC 
						LEFT OUTER JOIN LY_BOLSA B ON B.NUM_BOLSA = I.NUM_BOLSA AND B.ALUNO = I.ALUNO 
						LEFT OUTER JOIN LY_TIPO_BOLSA T ON T.TIPO_BOLSA = B.TIPO_BOLSA 
						Where i.BOLETO = @p_Boleto
						AND  ((I.NUM_BOLSA IS NULL AND C.DESC_ANTECIPADO = 'S' OR I.CODIGO_LANC is null or I.CODIGO_LANC = 'Acerto') 
							 OR (I.NUM_BOLSA IS NOT NULL AND T.DESC_ANTECIPADO = 'S'))

			IF EXISTS (SELECT TOP 1 1 FROM LY_ITEM_CRED WITH(NOLOCK) WHERE BOLETO = @p_Boleto AND VALOR IS NOT NULL)
			BEGIN
				SET @v_valor_titulo_boleto_desc = ISNULL(@v_valor_titulo_boleto_desc, 0 ) + (SELECT ISNULL(SUM(VALOR), 0) VALOR FROM LY_ITEM_CRED WITH(NOLOCK) WHERE BOLETO = @p_Boleto GROUP BY BOLETO)
			END	


			SET @v_seu_numero_boleto = @p_Boleto

			SELECT  
				@v_nosso_numero_boleto = bo.NOSSO_NUMERO,
				@v_digito_verificador_nosso_numero_boleto = NULL, -- 'calculado no plugin'
				@v_data_emissao_boleto = bo.DATA_PROC,
				@v_data_validade_boleto = bu.DATA_VALIDADE	
			FROM LY_BOLETO bo WITH(NOLOCK) 
				LEFT JOIN LY_BOLETO_UNIFICADO bu on bo.BOLETO = bu.ID_BOLETO
			WHERE bo.BOLETO = @p_Boleto

			-- OBTEM A DATA DE VENCIMENTO
			SELECT @v_data_vencimento_boleto = MAX(co.DATA_DE_VENCIMENTO)
			FROM LY_ITEM_LANC itemLanc WITH(NOLOCK)
			INNER JOIN LY_COBRANCA co ON co.COBRANCA = itemLanc.COBRANCA
			WHERE itemLanc.BOLETO = @p_Boleto

			-- OBTEM INFORMAÇÕES DO PAGADOR
			SELECT @v_cpf_cnpj_pagador = isnull(rf.CPF_TITULAR, rf.CGC_TITULAR),
				   @v_tipo_pagador = CASE isnull(rf.CGC_TITULAR, '') WHEN '' THEN '01' ELSE '02' END,   
				   @v_nome_pagador = rf.TITULAR,
				   @v_logradouro_pagador = rf.ENDERECO,
				   @v_bairro_pagador = rf.BAIRRO,
				   @v_cidade_pagador = m.NOME,
				   @v_uf_pagador = m.UF,
				   @v_cep_pagador = rf.CEP,
				   @v_email_pagador = rf.E_MAIL,
				   @v_numero_endereco_pagador = rf.END_NUM,
				   @v_complemento_pagador = rf.END_COMPL
			FROM LY_ITEM_LANC itemLanc WITH(NOLOCK)
			INNER JOIN LY_COBRANCA co ON co.COBRANCA = itemLanc.COBRANCA
			INNER JOIN LY_RESP_FINAN rf ON rf.RESP = co.RESP
--			INNER JOIN LY_PESSOA p ON p.PESSOA = rf.PESSOA
			LEFT JOIN HD_MUNICIPIO m ON m.MUNICIPIO = rf.END_MUNICIPIO
			WHERE itemLanc.BOLETO = @p_Boleto

			
			SET @v_numero_inscricao_pagador = @v_cpf_cnpj_pagador
			SET @v_nome_municipio_pagador = @v_cidade_pagador							

			IF ISNULL( @p_operacao, '') = 'Registro'
			BEGIN
				SET @v_tipo_registro_controle = '1'
			END
			ELSE IF ISNULL( @p_operacao, '') = 'Alteracao'
			BEGIN
				SET @v_tipo_registro_controle = '2'
			END

			SET @v_tipo_cobranca_controle = '1' -- SIGNIFICA QUE É PARA BOLETOS

			-- OBTEM O INFORMAÇÕES DO BANCO DO BOLETO
			SELECT @v_agencia_beneficiario = b.AGENCIA,
				   @v_conta_beneficiario = b.CONTA_BANCO,
				   @v_digito_verificador_conta_beneficiario = SUBSTRING(CONVERT(VARCHAR, b.CONTA_BANCO), LEN(CONVERT(VARCHAR, b.CONTA_BANCO)), LEN(CONVERT(VARCHAR, b.CONTA_BANCO))),
				   @v_cod_banco_beneficiario = b.BANCO,
				   @v_cod_convenio_beneficiario = b.CONVENIO,
				   @v_numero_carteira_beneficiario = b.CARTEIRA
			FROM LY_BOLETO b 
			WHERE b.BOLETO = @p_Boleto

			SELECT DISTINCT TOP 1 @v_cpf_cnpj_beneficiario = ue.CGC,
								  @v_nome_beneficiario = ue.NOME_COMP
			FROM LY_ITEM_LANC il 
				INNER JOIN LY_COBRANCA cob ON cob.COBRANCA = il.COBRANCA
				INNER JOIN LY_ALUNO alu ON alu.ALUNO = cob.ALUNO
				INNER JOIN LY_CURSO c ON c.CURSO = alu.CURSO 
				INNER JOIN LY_UNIDADE_ENSINO ue ON ue.UNIDADE_ENS = c.FACULDADE
			WHERE il.BOLETO = @p_Boleto

			SET @v_titulo_aceite_cobranca = 'S' -- identifica que é um boleto de cobrança

			SET @v_codigo_moeda_cnab_moeda = '09' -- IDENTIFICA QUE COBRANÇA SERÁ EXPRESSÃO EM REAL (R$)

			SET @v_tipo_pagamento_boleto = '3' --Pagamento com data de vencimento determinada

			SET @v_tipo_carteira_titulo_beneficiario = @v_numero_carteira_beneficiario
			SET @v_numero_variacao_carteira_beneficiario = @v_numero_carteira_beneficiario

			SET @v_tipo_protesto_boleto = '0' -- NAO PROTESTAR

--			SET @v_tipo_pagador = '01' -- INDICA QUE SERÁ INFORMADO O CPF DO PAGADOR

			SET @v_meio_pagamento_cobranca = '300' -- valor fixo: 300 - Uso do Bradesco

			SET @v_tipo_renderizacao_boleto = '2' -- PDF

			SET @v_valor_iof = '00' -- campo não sera utilizado (BRADESCO)

			SET @v_debito_automatico_debito = 'False' -- campo não sera utilizado (BRADESCO)
			SET @v_rateio_credito = 'False' -- campo não sera utilizado (BRADESCO)
			SET @v_endereco_debito_automatico_debito = '00' -- campo não sera utilizado (BRADESCO)
			SET @v_tipo_ocorrencia_cobranca = '01' -- identifica a ocorrencia como Remessa

			SET @v_sequencia_registro_boleto = '00' -- campo não sera utilizado (BRADESCO)
			SET @v_primeira_instrucao_boleto = '00' -- campo não sera utilizado (BRADESCO)
			SET @v_segunda_instrucao_boleto = '00' -- campo não sera utilizado (BRADESCO)

			SELECT @v_descricao_compra_controle = il.DESCRICAO
			FROM LY_ITEM_LANC il WITH(NOLOCK) 
			INNER JOIN LY_BOLETO b 
				ON b.BOLETO = il.BOLETO
			WHERE b.BOLETO = @p_Boleto

			SET @v_codigo_modalidade_titulo_boleto = '1' -- modalidade simples (BANCO DO BRASIL)

			SET @v_codigo_tipo_juro_mora_juros = '0' -- não informado (BANCO DO BRASIL)
			SET @v_codigo_aceite_titulo_boleto = 'A' -- significa 'ACEITE' (BANCO DO BRASIL)

			SET @v_codigo_tipo_conta_caucao_boleto = '0'

			SET @v_codigo_tipo_canal_solicitacao_controle = '5' -- IB-WEBSERVICE (BANCO DO BRASIL)
		
			/*
				INICIO TRATAMENTO DE PERDA BOLSA
			    VERIFICA SE TEM PERDA BOLSA 
			**/

			-- BUSCA LANC_DEB
				INSERT INTO  @v_perde_bolsa_lanc_deb 
				SELECT DISTINCT LANC.LANC_DEB
				 From LY_ITEM_LANC LANC, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE 
				Where (LANC.NUM_BOLSA = B.NUM_BOLSA) AND  
						(LANC.ALUNO = B.ALUNO) AND 
						(B.TIPO_BOLSA = TB.TIPO_BOLSA) AND  
						(TB.TIPO_ENCARGO = TE.TIPO_ENCARGO) AND 
						(TE.CATEGORIA = 'PerdaBolsa') AND  (LANC.BOLETO =  @p_Boleto ) AND LANC.LANC_DEB IS NOT NULL 
				group by LANC.lanc_deb;


				IF EXISTS (SELECT TOP 1 1 FROM @v_perde_bolsa_lanc_deb) 
					BEGIN 
						-- BUSCA PARCELA
						SET @v_perde_bolsa_parc=
						(SELECT MAX(LANC.PARCELA) 
							From LY_ITEM_LANC LANC, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE  
							Where 
						(LANC.NUM_BOLSA = B.NUM_BOLSA) AND  (LANC.ALUNO = B.ALUNO) AND 
						(B.TIPO_BOLSA = TB.TIPO_BOLSA) AND  (TB.TIPO_ENCARGO = TE.TIPO_ENCARGO) AND 
						(TE.CATEGORIA = 'PerdaBolsa') AND (LANC.BOLETO =  @p_Boleto ) AND LANC.LANC_DEB IS NOT NULL  
							AND NOT EXISTS (SELECT 1 FROM LY_ITEM_CRED WHERE COBRANCA = LANC.COBRANCA AND TIPO_ENCARGO='Perde_Bolsa'));
					END
				ELSE 
					BEGIN
						SET @v_perde_bolsa_parc=NULL 
					END

				-- BUSCA VALOR DA BOLSA	  
				IF EXISTS (SELECT TOP 1 1 FROM @v_perde_bolsa_lanc_deb) AND @v_perde_bolsa_parc IS NOT NULL
					BEGIN
						SET @v_perde_bolsa_valor=
						(SELECT SUM(LANC.VALOR) VALOR_PAGO_TOT 
						FROM LY_ITEM_LANC LANC, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE  
						Where 
						(LANC.NUM_BOLSA = B.NUM_BOLSA) AND  (LANC.ALUNO = B.ALUNO) AND 
						(B.TIPO_BOLSA = TB.TIPO_BOLSA) AND (TB.TIPO_ENCARGO = TE.TIPO_ENCARGO) AND
						(TE.CATEGORIA = 'PerdaBolsa') AND (LANC.PARCELA = @v_perde_bolsa_parc ) AND (LANC.LANC_DEB IN(SELECT * FROM @v_perde_bolsa_lanc_deb))  AND
						(LANC.BOLETO = @p_Boleto) AND LANC.VALOR<>0 
							AND NOT EXISTS (SELECT 1 FROM LY_ITEM_CRED 
								WHERE COBRANCA = LANC.COBRANCA AND TIPO_ENCARGO='Perde_Bolsa'));
					END
				ELSE 
				BEGIN
					SET @v_perde_bolsa_valor = NULL ;
				END

				-- BUSCA DATA DA PERDA BOLSA 
				IF EXISTS (SELECT TOP 1 1 FROM @v_perde_bolsa_lanc_deb) AND @v_perde_bolsa_parc IS NOT NULL
					BEGIN
						SELECT distinct  @v_data_perda_bolsa =C.data_de_vencimento ,@v_aluno= C.ALUNO
						FROM LY_BOLETO BOL INNER JOIN LY_ITEM_LANC I ON BOL.BOLETO = I.BOLETO
						INNER JOIN LY_COBRANCA C ON C.COBRANCA = I.COBRANCA
						WHERE I.BOLETO =  @p_Boleto 
						
						IF @v_utiliza_venc_dia_util = 'S'
							BEGIN
								EXEC DIA_UTIL @v_aluno, @v_data_perda_bolsa OUTPUT
							END
			
					END
				ELSE
					BEGIN
					   SET @v_data_perda_bolsa=NULL
					END

				IF EXISTS (SELECT TOP 1 1 FROM @v_perde_bolsa_lanc_deb) AND @v_perde_bolsa_parc IS NOT NULL AND @v_perde_bolsa_valor IS NOT NULL AND @v_perde_bolsa_valor <> 0	AND @v_data_perda_bolsa IS NOT NULL
					BEGIN 
						SET  @v_calcula_perda_bolsa = 1;
                    END 
				ELSE
					BEGIN 	  
						SET  @v_calcula_perda_bolsa = 0;
					END


			  SET  @v_perde_bolsa_valor =REPLACE(REPLACE(@v_perde_bolsa_valor, CHAR(13), ' '), CHAR(10), ' ');
	
			  
		END -- IF ISNULL(@p_Boleto_candidato, 'N') = 'N'
		ELSE
		BEGIN -- OBTEM DADOS DO BOLETO DE CANDIDATO
			IF @p_operacao = 'Registro' OR @p_operacao = 'Alteracao' 
			BEGIN

				SELECT @v_nosso_numero_boleto = CA.BOLETO_NOSSO_NUMERO,
					   @v_digito_verificador_nosso_numero_boleto = NULL, -- 'SERÁ CALCULADO NO PLUGIN'
					   @v_data_vencimento_boleto = CA.BOL_DT_VENC,
					   @v_valor_titulo_boleto = CA.BOLETO_VALOR,
					   @v_data_emissao_boleto = CA.DT_INSCRICAO,
					   @v_data_validade_boleto = bu.DATA_VALIDADE	
				FROM LY_CANDIDATO ca WITH(NOLOCK) 
				LEFT JOIN LY_BOLETO_UNIFICADO bu on CA.BOLETO = bu.ID_BOLETO
				WHERE BOLETO = @p_Boleto

				SET @v_seu_numero_boleto = @p_Boleto

				-- OBTEM INFORMAÇÕES DO PAGADOR
				SELECT @v_cpf_cnpj_pagador = ISNULL(RESP.CGC_TITULAR, ISNULL(P.CPF, ISNULL(RESP.CPF_TITULAR, C.CPF))),
					   @v_tipo_pagador = CASE isnull(RESP.CGC_TITULAR, '') WHEN '' THEN '1' ELSE '2' END,   
					   @v_nome_pagador = c.NOME_COMPL,
					   @v_logradouro_pagador = c.ENDERECO,
					   @v_bairro_pagador = c.BAIRRO,
					   @v_cidade_pagador = m.NOME,
					   @v_uf_pagador = m.UF,
					   @v_cep_pagador = c.CEP,
					   @v_email_pagador = c.E_MAIL,
					   @v_numero_endereco_pagador = c.END_NUM,
					   @v_complemento_pagador = c.END_COMPL
				FROM LY_CANDIDATO c
				     LEFT JOIN LY_RELACIONAMENTO_PESSOA REL ON REL.PESSOA = C.PESSOA
					 LEFT JOIN lY_PESSOA P ON P.PESSOA = REL.PESSOA_PAPEL AND P.CPF IS NOT NULL
				     LEFT JOIN LY_CANDIDATO_RESP RESP ON RESP.CONCURSO = C.CONCURSO AND RESP.CANDIDATO = C.CANDIDATO 
				     LEFT JOIN HD_MUNICIPIO m ON m.MUNICIPIO = c.MUNICIPIO 
				WHERE c.BOLETO = @p_Boleto

				
				SET @v_numero_inscricao_pagador = @v_cpf_cnpj_pagador
				SET @v_nome_municipio_pagador = @v_cidade_pagador							

				IF ISNULL( @p_operacao, '') = 'Registro'
				BEGIN
					SET @v_tipo_registro_controle = '1'
				END
				ELSE IF ISNULL( @p_operacao, '') = 'Alteracao'
				BEGIN
					SET @v_tipo_registro_controle = '2'
				END

				SET @v_tipo_cobranca_controle = '1' -- SIGNIFICA QUE É PARA BOLETOS

				SELECT @v_concurso =  CONCURSO FROM LY_CANDIDATO WITH(NOLOCK) WHERE BOLETO = @p_Boleto

				SELECT @v_nome_beneficiario = cb.TITULAR,
					   @v_agencia_beneficiario = con.BOLETO_AGENCIA,
					   @v_conta_beneficiario = con.BOLETO_CONTA_BANCO,
					   @v_digito_verificador_conta_beneficiario = SUBSTRING(CONVERT(VARCHAR, con.BOLETO_CONTA_BANCO), LEN(CONVERT(VARCHAR, con.BOLETO_CONTA_BANCO)), LEN(CONVERT(VARCHAR, con.BOLETO_CONTA_BANCO))),
					   @v_cod_banco_beneficiario = con.BOLETO_BANCO,
					   @v_numero_carteira_beneficiario = con.BOLETO_CARTEIRA,
					   @v_cod_convenio_beneficiario = con.BOLETO_CONVENIO
				FROM LY_CONTA_BANCO cb WITH(NOLOCK) 
				INNER JOIN LY_CONCURSO con ON con.BOLETO_BANCO = cb.BANCO AND 
											  con.BOLETO_AGENCIA = cb.AGENCIA AND 
											  con.BOLETO_CONTA_BANCO = cb.CONTA_BANCO
				INNER JOIN LY_CANDIDATO can ON can.CONCURSO = con.CONCURSO
				WHERE can.BOLETO = @p_Boleto AND can.CONCURSO = @v_concurso

				SELECT DISTINCT TOP 1 @v_cpf_cnpj_beneficiario = ue.CGC,
								      @v_nome_beneficiario = ue.NOME_COMP
				FROM LY_UNIDADE_ENSINO ue
					INNER JOIN LY_CONCURSO c ON c.UNIDADE_RESPONSAVEL = ue.UNIDADE_ENS
					INNER JOIN LY_CANDIDATO can ON can.CONCURSO = c.CONCURSO
				WHERE can.BOLETO = @p_Boleto

				SET @v_tipo_carteira_titulo_beneficiario = @v_numero_carteira_beneficiario

				SET @v_titulo_aceite_cobranca = 'S' -- identifica que é um boleto de cobrança

				SET @v_codigo_moeda_cnab_moeda = '09' -- IDENTIFICA QUE COBRANÇA SERÁ EXPRESSÃO EM REAL (R$)

				SET @v_tipo_pagamento_boleto = '3' --Pagamento com data de vencimento determinada

				SET @v_tipo_protesto_boleto = '0' -- NAO PROTESTAR

--				SET @v_tipo_pagador = '01' -- INDICA QUE SERÁ INFORMADO O CPF DO PAGADOR

				SET @v_meio_pagamento_cobranca = '300' -- valor fixo: 300 - Uso do Bradesco

				SET @v_tipo_renderizacao_boleto = '2' -- PDF

				SET @v_valor_iof = '00' -- campo não sera utilizado (BRADESCO)

				SET @v_debito_automatico_debito = 'False' -- campo não sera utilizado (BRADESCO)
				SET @v_rateio_credito = 'False' -- campo não sera utilizado (BRADESCO)
				SET @v_endereco_debito_automatico_debito = '00' -- campo não sera utilizado (BRADESCO)
				SET @v_tipo_ocorrencia_cobranca = '01' -- identifica a ocorrencia como Remessa

				SET @v_sequencia_registro_boleto = '00' -- campo não sera utilizado (BRADESCO)
				SET @v_primeira_instrucao_boleto = '00' -- campo não sera utilizado (BRADESCO)
				SET @v_segunda_instrucao_boleto = '00' -- campo não sera utilizado (BRADESCO)

				SELECT @v_descricao_compra_controle = 'Inscrição no Processo Seletivo: ' + (SELECT CONVERT(VARCHAR(100), ISNULL(DESCRICAO, '')) FROM LY_CONCURSO WHERE CONCURSO = @v_concurso)


				SET @v_numero_variacao_carteira_beneficiario = @v_numero_carteira_beneficiario
				SET @v_codigo_modalidade_titulo_boleto = '1' -- modalidade simples (BANCO DO BRASIL)

				SET @v_codigo_tipo_juro_mora_juros = '0' -- não informado (BANCO DO BRASIL)
				SET @v_codigo_aceite_titulo_boleto = 'A' -- significa 'ACEITE' (BANCO DO BRASIL)

				SET @v_indicador_permissao_recebimento_parcial_boleto = 'S' -- xxx

				SET @v_codigo_tipo_conta_caucao_boleto = '0'

				SET @v_codigo_tipo_canal_solicitacao_controle = '5' -- IB-WEBSERVICE (BANCO DO BRASIL)

			END
			ELSE IF @p_operacao = 'Cancelamento'
			BEGIN

				SELECT @v_nosso_numero_boleto = bc.BOLETO_NOSSO_NUMERO,
					   @v_digito_verificador_nosso_numero_boleto = NULL, -- 'SERÁ CALCULADO NO PLUGIN'
					   @v_data_vencimento_boleto = bc.BOL_DT_VENC,
					   @v_valor_titulo_boleto = bc.BOLETO_VALOR,
					   @v_data_emissao_boleto = bu.DATA_INCLUSAO,
					   @v_data_validade_boleto = bu.DATA_VALIDADE 	
				FROM LY_BOLETOS_CANCELADOS bc WITH(NOLOCK)
				LEFT JOIN LY_BOLETO_UNIFICADO bu on bc.BOLETO = bu.ID_BOLETO
				WHERE bc.BOLETO = @p_Boleto

				SET @v_seu_numero_boleto = @p_Boleto

				-- OBTEM INFORMAÇÕES DO PAGADOR
				SELECT @v_cpf_cnpj_pagador = ISNULL(P.CPF, ISNULL(RESP.CPF_TITULAR, C.CPF)),
					   @v_nome_pagador = c.NOME_COMPL,
					   @v_logradouro_pagador = c.ENDERECO,
					   @v_bairro_pagador = c.BAIRRO,
					   @v_cidade_pagador = m.NOME,
					   @v_uf_pagador = m.UF,
					   @v_cep_pagador = c.CEP,
					   @v_email_pagador = c.E_MAIL,
					   @v_numero_endereco_pagador = c.END_NUM,
					   @v_complemento_pagador = c.END_COMPL
				FROM LY_CANDIDATO c
				     INNER JOIN LY_BOLETOS_CANCELADOS bc ON c.CANDIDATO = bc.CANDIDATO AND c.CONCURSO = bc.CONCURSO
				     LEFT JOIN LY_RELACIONAMENTO_PESSOA REL ON REL.PESSOA = C.PESSOA
					 LEFT JOIN lY_PESSOA P ON P.PESSOA = REL.PESSOA_PAPEL AND P.CPF IS NOT NULL
				     LEFT JOIN LY_CANDIDATO_RESP RESP ON RESP.CONCURSO = C.CONCURSO AND RESP.CANDIDATO = C.CANDIDATO 
				     LEFT JOIN HD_MUNICIPIO m ON m.MUNICIPIO = c.MUNICIPIO
				WHERE c.BOLETO = @p_Boleto

				
				SET @v_numero_inscricao_pagador = @v_cpf_cnpj_pagador
				SET @v_nome_municipio_pagador = @v_cidade_pagador							

				IF ISNULL( @p_operacao, '') = 'Registro'
				BEGIN
					SET @v_tipo_registro_controle = '1'
				END
				ELSE IF ISNULL( @p_operacao, '') = 'Alteracao'
				BEGIN
					SET @v_tipo_registro_controle = '2'
				END

				SET @v_tipo_cobranca_controle = '1' -- SIGNIFICA QUE É PARA BOLETOS

				SELECT @v_concurso = CONCURSO FROM LY_BOLETOS_CANCELADOS WITH(NOLOCK) WHERE BOLETO = @p_Boleto

				SELECT @v_nome_beneficiario = cb.TITULAR,
					   @v_agencia_beneficiario = con.BOLETO_AGENCIA,
					   @v_conta_beneficiario = con.BOLETO_CONTA_BANCO,
					   @v_digito_verificador_conta_beneficiario = SUBSTRING(CONVERT(VARCHAR, con.BOLETO_CONTA_BANCO), LEN(CONVERT(VARCHAR, con.BOLETO_CONTA_BANCO)), LEN(CONVERT(VARCHAR, con.BOLETO_CONTA_BANCO))),
					   @v_cod_banco_beneficiario = con.BOLETO_BANCO,
					   @v_numero_carteira_beneficiario = con.BOLETO_CARTEIRA,
					   @v_cod_convenio_beneficiario = con.BOLETO_CONVENIO
				FROM LY_CONTA_BANCO cb WITH(NOLOCK) 
				INNER JOIN LY_CONCURSO con ON con.BOLETO_BANCO = cb.BANCO AND 
											  con.BOLETO_AGENCIA = cb.AGENCIA AND 
											  con.BOLETO_CONTA_BANCO = cb.CONTA_BANCO
				WHERE con.CONCURSO = @v_concurso

				SELECT DISTINCT TOP 1 @v_cpf_cnpj_beneficiario = ue.CGC,
								      @v_nome_beneficiario = ue.NOME_COMP
				FROM LY_UNIDADE_ENSINO ue
					INNER JOIN LY_CONCURSO c ON c.UNIDADE_RESPONSAVEL = ue.UNIDADE_ENS
					INNER JOIN LY_BOLETOS_CANCELADOS bc ON bc.CONCURSO = c.CONCURSO
				WHERE bc.BOLETO = @p_Boleto

				SET @v_titulo_aceite_cobranca = 'S' -- identifica que é um boleto de cobrança

				SET @v_codigo_moeda_cnab_moeda = '09' -- IDENTIFICA QUE COBRANÇA SERÁ EXPRESSÃO EM REAL (R$)

				SET @v_tipo_pagamento_boleto = '3' --Pagamento com data de vencimento determinada

				SET @v_tipo_carteira_titulo_beneficiario = @v_numero_carteira_beneficiario

				SET @v_tipo_protesto_boleto = '0' -- NAO PROTESTAR

				SET @v_tipo_pagador = '01' -- INDICA QUE SERÁ INFORMADO O CPF DO PAGADOR

				SET @v_meio_pagamento_cobranca = '300' -- valor fixo: 300 - Uso do Bradesco

				SET @v_tipo_renderizacao_boleto = '2' -- PDF

				SET @v_valor_iof = '00' -- campo não sera utilizado (BRADESCO)

				SET @v_debito_automatico_debito = 'False' -- campo não sera utilizado (BRADESCO)
				SET @v_rateio_credito = 'False' -- campo não sera utilizado (BRADESCO)
				SET @v_endereco_debito_automatico_debito = '00' -- campo não sera utilizado (BRADESCO)
				SET @v_tipo_ocorrencia_cobranca = '01' -- identifica a ocorrencia como Remessa

				SET @v_sequencia_registro_boleto = '00' -- campo não sera utilizado (BRADESCO)
				SET @v_primeira_instrucao_boleto = '00' -- campo não sera utilizado (BRADESCO)
				SET @v_segunda_instrucao_boleto = '00' -- campo não sera utilizado (BRADESCO)

				SELECT @v_descricao_compra_controle = 'Inscrição no Processo Seletivo: ' + (SELECT CONVERT(VARCHAR(100), ISNULL(DESCRICAO, '')) FROM LY_CONCURSO WHERE CONCURSO = @v_concurso)


				SET @v_numero_variacao_carteira_beneficiario = @v_numero_carteira_beneficiario
				SET @v_codigo_modalidade_titulo_boleto = '1' -- modalidade simples (BANCO DO BRASIL)

				SET @v_codigo_tipo_juro_mora_juros = '0' -- não informado (BANCO DO BRASIL)
				SET @v_codigo_aceite_titulo_boleto = 'A' -- significa 'ACEITE' (BANCO DO BRASIL)

				SET @v_indicador_permissao_recebimento_parcial_boleto = 'S' -- xxx

				SET @v_codigo_tipo_conta_caucao_boleto = '0'

				SET @v_codigo_tipo_canal_solicitacao_controle = '5' -- IB-WEBSERVICE (BANCO DO BRASIL)

			END
		END -- ELSE IF ISNULL(@p_Boleto_candidato, 'N') = 'N'

														
	END -- 	IF @p_Boleto IS NOT NULL

	-- VALOR DO BOLETO
	IF ISNULL(@v_perde_bolsa_valor,0) <> 0 
			SET @v_valor_titulo_boleto = @v_valor_titulo_boleto - @v_perde_bolsa_valor

	-- OBTEM INSTRUCOES DO BOLETO EM 3 LINHAS
	EXEC DIVIDE_INSTRUCOES_BOLETO @p_Boleto, @p_Boleto_candidato, @v_instrucao_linha_1_boleto OUTPUT, 
		@v_instrucao_linha_2_boleto OUTPUT, @v_instrucao_linha_3_boleto OUTPUT

	SET @v_texto_mensagem_bloqueto_ocorrencia_boleto = @v_instrucao_linha_1_boleto + ' ' +
			@v_instrucao_linha_2_boleto + ' ' + @v_instrucao_linha_3_boleto

	
	-- Pega o prazo de baixa do boleto (dias apos o vencimento)
    SELECT @v_qt_dias_baixa_boleto = PRAZO_BAIXA 
    FROM LY_CONTA_CONVENIO CC   
    INNER JOIN LY_BOLETO BO ON BO.BANCO = CC.BANCO AND BO.AGENCIA = CC.AGENCIA AND BO.CONTA_BANCO = CC.CONTA_BANCO AND BO.CARTEIRA = CC.CARTEIRA AND BO.CONVENIO = CC.CONVENIO  
    WHERE BO.BOLETO = @p_Boleto
	
	
	-- VERIFICA QUANTIDADE DE DIAS PARA BAIXA DO BOLETO    
	EXEC a_GERA_ARQUIVO_BOLETO @p_boleto, @v_cod_banco_beneficiario, @v_agencia_beneficiario, @v_conta_beneficiario, @v_cod_convenio_beneficiario, @v_numero_carteira_beneficiario, @v_qt_dias_baixa_boleto OUTPUT, @v_1_Instrucao OUTPUT,	@v_2_Instrucao OUTPUT



	-- CHAMA EP PARA SETAR VALORES ESPECIFICOS
	EXEC s_OBTER_DADOS_BOLETO_REGISTRO @p_boleto, @p_Boleto_candidato, @v_nome_beneficiario OUTPUT, @v_mensagem_cabecalho_boleto OUTPUT, @v_instrucao_linha_1_boleto OUTPUT, @v_instrucao_linha_2_boleto OUTPUT,
		@v_instrucao_linha_3_boleto OUTPUT, @v_data_validade_boleto OUTPUT, @v_cpf_cnpj_pagador OUTPUT, @v_nome_pagador OUTPUT, @v_logradouro_pagador OUTPUT, @v_bairro_pagador OUTPUT, @v_cidade_pagador OUTPUT, 
		@v_uf_pagador OUTPUT, @v_cep_pagador OUTPUT, @v_nosso_numero_boleto OUTPUT, @v_data_vencimento_boleto OUTPUT, @v_valor_titulo_boleto OUTPUT, @v_seu_numero_boleto OUTPUT, @v_especie_cobranca OUTPUT,  
		@v_data_emissao_boleto OUTPUT, @v_valor_abatimento_cobranca OUTPUT,	@v_valor_juros OUTPUT, @v_percentual_juros OUTPUT, @v_data_multa OUTPUT, @v_percentual_multa OUTPUT, @v_data_desconto OUTPUT,
		@v_tipo_desconto  OUTPUT, @v_valor_desconto OUTPUT, @v_percentual_desconto OUTPUT, @v_cod_convenio_beneficiario OUTPUT, @v_tipo_pagador OUTPUT, @v_numero_carteira_beneficiario OUTPUT, @v_tipo_multa OUTPUT,
		@v_valor_multa OUTPUT, @v_tipo_registro_controle OUTPUT, @v_tipo_cobranca_controle OUTPUT, @v_tipo_produto_controle OUTPUT, @v_subproduto_controle OUTPUT, @v_cpf_cnpj_beneficiario OUTPUT,
		@v_agencia_beneficiario OUTPUT, @v_conta_beneficiario OUTPUT, @v_digito_verificador_conta_beneficiario OUTPUT,  @v_agencia_debito OUTPUT,
		@v_conta_debito OUTPUT, @v_digito_verificador_conta_debito OUTPUT, @v_identificador_titulo_empresa_cobranca OUTPUT, @v_uso_banco_cobranca OUTPUT, @v_titulo_aceite_cobranca OUTPUT,
		@v_email_pagador OUTPUT, @v_cpf_cnpj_sacador_avalista OUTPUT, @v_nome_sacador_avalista OUTPUT, @v_logradouro_sacador_avalista OUTPUT,  @v_bairro_sacador_avalista OUTPUT, @v_cidade_sacador_avalista OUTPUT,
		@v_uf_sacador_avalista OUTPUT, @v_cep_sacador_avalista OUTPUT, @v_codigo_moeda_cnab_moeda OUTPUT, @v_quantidade_moeda OUTPUT, @v_digito_verificador_nosso_numero_boleto OUTPUT, @v_codigo_barras_boleto OUTPUT,
		@v_data_limite_pagamento_boleto OUTPUT, @v_tipo_pagamento_boleto OUTPUT, @v_indicador_pagamento_parcial_cobranca OUTPUT, @v_quantidade_pagamento_parcial_cobranca OUTPUT, @v_quantidade_parcelas_cobranca OUTPUT,
		@v_instrucao_cobranca_1_cobranca OUTPUT, @v_quantidade_dias_1_cobranca OUTPUT, @v_data_instrucao_1_cobranca OUTPUT, @v_instrucao_cobranca_2_cobranca OUTPUT, @v_quantidade_dias_2_cobranca OUTPUT,@v_data_instrucao_2_cobranca OUTPUT,
		@v_instrucao_cobranca_3_cobranca OUTPUT, @v_quantidade_dias_3_cobranca OUTPUT, @v_data_instrucao_3_cobranca OUTPUT, @v_data_juros OUTPUT, @v_tipo_juros OUTPUT, @v_tipo_autorizacao_recebimento_divergente OUTPUT,
		@v_tipo_valor_percentual_recebimento_divergente OUTPUT, @v_valor_minimo_recebimento_divergente OUTPUT, @v_percentual_minimo_recebimento_divergente OUTPUT, @v_valor_maximo_recebimento_divergente OUTPUT,
		@v_percentual_maximo_recebimento_divergente OUTPUT, @v_agencia_grupo_rateio OUTPUT, @v_conta_grupo_rateio OUTPUT, @v_digito_verificador_conta_grupo_rateio OUTPUT, @v_tipo_grupo_rateio OUTPUT, @v_valor_percentual_grupo_rateio OUTPUT,
		@v_tipo_carteira_titulo_beneficiario OUTPUT, @v_expiracao_token_controle OUTPUT, @v_sistema_banco_controle OUTPUT, @v_tipo_protesto_boleto OUTPUT, @v_qt_dias_protesto_boleto OUTPUT, @v_qt_dias_baixa_boleto OUTPUT,
		@v_cod_banco_beneficiario OUTPUT, @v_merchant_id_controle OUTPUT, @v_meio_pagamento_cobranca OUTPUT, @v_url_logotipo_boleto OUTPUT, @v_tipo_renderizacao_boleto OUTPUT, @v_token_request_confirmacao_pagamento_controle OUTPUT,
		@v_ip_maquina_cliente_controle OUTPUT, @v_user_agent_controle OUTPUT, @v_numero_endereco_pagador OUTPUT, @v_complemento_pagador OUTPUT, @v_agencia_pagador OUTPUT, @v_razao_conta_pagador OUTPUT, @v_conta_pagador OUTPUT,
		@v_controle_participante_boleto OUTPUT, @v_aplicar_multa OUTPUT, @v_valor_iof OUTPUT, @v_debito_automatico_debito OUTPUT, @v_rateio_credito OUTPUT, @v_endereco_debito_automatico_debito OUTPUT,
		@v_tipo_ocorrencia_cobranca OUTPUT, @v_sequencia_registro_boleto OUTPUT, @v_primeira_instrucao_boleto OUTPUT, @v_segunda_instrucao_boleto OUTPUT, @v_descricao_compra_controle OUTPUT, @v_numero_variacao_carteira_beneficiario OUTPUT,
		@v_codigo_modalidade_titulo_boleto OUTPUT, @v_quantidade_dia_protesto_boleto OUTPUT, @v_codigo_tipo_juro_mora_juros OUTPUT, @v_codigo_aceite_titulo_boleto OUTPUT, @v_codigo_tipo_titulo_boleto OUTPUT, 
		@v_indicador_permissao_recebimento_parcial_boleto OUTPUT,
		@v_texto_campo_utilizacao_beneficiario_boleto OUTPUT, @v_codigo_tipo_conta_caucao_boleto OUTPUT, @v_texto_mensagem_bloqueto_ocorrencia_boleto OUTPUT, @v_numero_inscricao_pagador OUTPUT, @v_nome_municipio_pagador OUTPUT,
		@v_texto_numero_telefone_pagador OUTPUT, @v_codigo_tipo_inscricao_avalista_pagador OUTPUT, @v_numero_inscricao_avalista_pagador OUTPUT, @v_nome_avalista_titulo_pagador OUTPUT, @v_codigo_chave_usuario_controle OUTPUT,
		@v_codigo_tipo_canal_solicitacao_controle OUTPUT, @v_descricao_tipo_titulo_boleto  OUTPUT, @v_numero_endereco_avalista OUTPUT, @v_complemento_endereco_avalista OUTPUT, @v_tipo_documento_sacador_avalista OUTPUT,
		@v_tipo_bonificacao OUTPUT, @v_perc_desc_bonificacao OUTPUT, @v_valor_desc_bonificacao OUTPUT, @v_data_limite_desc_bonificacao OUTPUT, @v_tipo_emissao_papeleta OUTPUT, @v_qtde_parcelas OUTPUT, @v_tipo_decurso_prazo OUTPUT,
		@v_qtde_dias_decurso OUTPUT, @v_qtde_dias_juros OUTPUT, @v_qtde_dias_multa_atraso OUTPUT, @v_tipo_protesto_negociacao_protesto OUTPUT, @v_qtde_dias_protesto OUTPUT

	-- REMOVE OS NEW LINES
	SET @v_nome_beneficiario = REPLACE(REPLACE(@v_nome_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_mensagem_cabecalho_boleto = REPLACE(REPLACE(@v_mensagem_cabecalho_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_instrucao_linha_1_boleto = REPLACE(REPLACE(@v_instrucao_linha_1_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_instrucao_linha_2_boleto = REPLACE(REPLACE(@v_instrucao_linha_2_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_instrucao_linha_3_boleto = REPLACE(REPLACE(@v_instrucao_linha_3_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_validade_boleto = REPLACE(REPLACE(@v_data_validade_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cpf_cnpj_pagador = REPLACE(REPLACE(@v_cpf_cnpj_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_nome_pagador = REPLACE(REPLACE(@v_nome_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_logradouro_pagador = REPLACE(REPLACE(@v_logradouro_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_bairro_pagador = REPLACE(REPLACE(@v_bairro_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cidade_pagador = REPLACE(REPLACE(@v_cidade_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_uf_pagador = REPLACE(REPLACE(@v_uf_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cep_pagador = REPLACE(REPLACE(@v_cep_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_nosso_numero_boleto = REPLACE(REPLACE(@v_nosso_numero_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_vencimento_boleto = REPLACE(REPLACE(@v_data_vencimento_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_titulo_boleto = REPLACE(REPLACE(@v_valor_titulo_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_seu_numero_boleto = REPLACE(REPLACE(@v_seu_numero_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_especie_cobranca = REPLACE(REPLACE(@v_especie_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_emissao_boleto = REPLACE(REPLACE(@v_data_emissao_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_abatimento_cobranca = REPLACE(REPLACE(@v_valor_abatimento_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_juros = REPLACE(REPLACE(@v_valor_juros, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_percentual_juros = REPLACE(REPLACE(@v_percentual_juros, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_multa = REPLACE(REPLACE(@v_data_multa, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_percentual_multa = REPLACE(REPLACE(@v_percentual_multa, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_desconto = REPLACE(REPLACE(@v_data_desconto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_desconto  = REPLACE(REPLACE(@v_tipo_desconto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_desconto = REPLACE(REPLACE(@v_valor_desconto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_percentual_desconto = REPLACE(REPLACE(@v_percentual_desconto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cod_convenio_beneficiario = REPLACE(REPLACE(@v_cod_convenio_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_pagador = REPLACE(REPLACE(@v_tipo_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_numero_carteira_beneficiario = REPLACE(REPLACE(@v_numero_carteira_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_multa = REPLACE(REPLACE(@v_tipo_multa, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_multa = REPLACE(REPLACE(@v_valor_multa, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_registro_controle = REPLACE(REPLACE(@v_tipo_registro_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_cobranca_controle = REPLACE(REPLACE(@v_tipo_cobranca_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_produto_controle = REPLACE(REPLACE(@v_tipo_produto_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_subproduto_controle = REPLACE(REPLACE(@v_subproduto_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cpf_cnpj_beneficiario = REPLACE(REPLACE(@v_cpf_cnpj_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_agencia_beneficiario = REPLACE(REPLACE(@v_agencia_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_conta_beneficiario = REPLACE(REPLACE(@v_conta_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_digito_verificador_conta_beneficiario = REPLACE(REPLACE(@v_digito_verificador_conta_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_agencia_debito = REPLACE(REPLACE(@v_agencia_debito, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_conta_debito = REPLACE(REPLACE(@v_conta_debito, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_digito_verificador_conta_debito = REPLACE(REPLACE(@v_digito_verificador_conta_debito, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_identificador_titulo_empresa_cobranca = REPLACE(REPLACE(@v_identificador_titulo_empresa_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_uso_banco_cobranca = REPLACE(REPLACE(@v_uso_banco_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_titulo_aceite_cobranca = REPLACE(REPLACE(@v_titulo_aceite_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_email_pagador = REPLACE(REPLACE(@v_email_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cpf_cnpj_sacador_avalista = REPLACE(REPLACE(@v_cpf_cnpj_sacador_avalista, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_nome_sacador_avalista = REPLACE(REPLACE(@v_nome_sacador_avalista, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_logradouro_sacador_avalista = REPLACE(REPLACE(@v_logradouro_sacador_avalista, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_bairro_sacador_avalista = REPLACE(REPLACE(@v_bairro_sacador_avalista, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cidade_sacador_avalista = REPLACE(REPLACE(@v_cidade_sacador_avalista, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_uf_sacador_avalista = REPLACE(REPLACE(@v_uf_sacador_avalista, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cep_sacador_avalista = REPLACE(REPLACE(@v_cep_sacador_avalista, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_moeda_cnab_moeda = REPLACE(REPLACE(@v_codigo_moeda_cnab_moeda, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_quantidade_moeda = REPLACE(REPLACE(@v_quantidade_moeda, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_digito_verificador_nosso_numero_boleto = REPLACE(REPLACE(@v_digito_verificador_nosso_numero_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_barras_boleto = REPLACE(REPLACE(@v_codigo_barras_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_limite_pagamento_boleto = REPLACE(REPLACE(@v_data_limite_pagamento_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_pagamento_boleto = REPLACE(REPLACE(@v_tipo_pagamento_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_indicador_pagamento_parcial_cobranca = REPLACE(REPLACE(@v_indicador_pagamento_parcial_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_quantidade_pagamento_parcial_cobranca = REPLACE(REPLACE(@v_quantidade_pagamento_parcial_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_quantidade_parcelas_cobranca = REPLACE(REPLACE(@v_quantidade_parcelas_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_instrucao_cobranca_1_cobranca = REPLACE(REPLACE(@v_instrucao_cobranca_1_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_quantidade_dias_1_cobranca = REPLACE(REPLACE(@v_quantidade_dias_1_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_instrucao_1_cobranca = REPLACE(REPLACE(@v_data_instrucao_1_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_instrucao_cobranca_2_cobranca = REPLACE(REPLACE(@v_instrucao_cobranca_2_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_quantidade_dias_2_cobranca = REPLACE(REPLACE(@v_quantidade_dias_2_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_instrucao_2_cobranca = REPLACE(REPLACE(@v_data_instrucao_2_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_instrucao_cobranca_3_cobranca = REPLACE(REPLACE(@v_instrucao_cobranca_3_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_quantidade_dias_3_cobranca = REPLACE(REPLACE(@v_quantidade_dias_3_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_instrucao_3_cobranca = REPLACE(REPLACE(@v_data_instrucao_3_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_data_juros = REPLACE(REPLACE(@v_data_juros, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_juros = REPLACE(REPLACE(@v_tipo_juros, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_autorizacao_recebimento_divergente = REPLACE(REPLACE(@v_tipo_autorizacao_recebimento_divergente, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_valor_percentual_recebimento_divergente = REPLACE(REPLACE(@v_tipo_valor_percentual_recebimento_divergente, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_minimo_recebimento_divergente = REPLACE(REPLACE(@v_valor_minimo_recebimento_divergente, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_percentual_minimo_recebimento_divergente = REPLACE(REPLACE(@v_percentual_minimo_recebimento_divergente, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_maximo_recebimento_divergente = REPLACE(REPLACE(@v_valor_maximo_recebimento_divergente, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_percentual_maximo_recebimento_divergente = REPLACE(REPLACE(@v_percentual_maximo_recebimento_divergente, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_agencia_grupo_rateio = REPLACE(REPLACE(@v_agencia_grupo_rateio, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_conta_grupo_rateio = REPLACE(REPLACE(@v_conta_grupo_rateio, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_digito_verificador_conta_grupo_rateio = REPLACE(REPLACE(@v_digito_verificador_conta_grupo_rateio, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_grupo_rateio = REPLACE(REPLACE(@v_tipo_grupo_rateio, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_percentual_grupo_rateio = REPLACE(REPLACE(@v_valor_percentual_grupo_rateio, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_carteira_titulo_beneficiario = REPLACE(REPLACE(@v_tipo_carteira_titulo_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_expiracao_token_controle = REPLACE(REPLACE(@v_expiracao_token_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_sistema_banco_controle = REPLACE(REPLACE(@v_sistema_banco_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_protesto_boleto = REPLACE(REPLACE(@v_tipo_protesto_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_qt_dias_protesto_boleto = REPLACE(REPLACE(@v_qt_dias_protesto_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_qt_dias_baixa_boleto = REPLACE(REPLACE(@v_qt_dias_baixa_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_cod_banco_beneficiario = REPLACE(REPLACE(@v_cod_banco_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_merchant_id_controle = REPLACE(REPLACE(@v_merchant_id_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_meio_pagamento_cobranca = REPLACE(REPLACE(@v_meio_pagamento_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_url_logotipo_boleto = REPLACE(REPLACE(@v_url_logotipo_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_renderizacao_boleto = REPLACE(REPLACE(@v_tipo_renderizacao_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_token_request_confirmacao_pagamento_controle = REPLACE(REPLACE(@v_token_request_confirmacao_pagamento_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_ip_maquina_cliente_controle = REPLACE(REPLACE(@v_ip_maquina_cliente_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_user_agent_controle = REPLACE(REPLACE(@v_user_agent_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_numero_endereco_pagador = REPLACE(REPLACE(@v_numero_endereco_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_complemento_pagador = REPLACE(REPLACE(@v_complemento_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_agencia_pagador = REPLACE(REPLACE(@v_agencia_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_razao_conta_pagador = REPLACE(REPLACE(@v_razao_conta_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_conta_pagador = REPLACE(REPLACE(@v_conta_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_controle_participante_boleto = REPLACE(REPLACE(@v_controle_participante_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_aplicar_multa = REPLACE(REPLACE(@v_aplicar_multa, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_valor_iof = REPLACE(REPLACE(@v_valor_iof, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_debito_automatico_debito = REPLACE(REPLACE(@v_debito_automatico_debito, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_rateio_credito = REPLACE(REPLACE(@v_rateio_credito, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_endereco_debito_automatico_debito = REPLACE(REPLACE(@v_endereco_debito_automatico_debito, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_tipo_ocorrencia_cobranca = REPLACE(REPLACE(@v_tipo_ocorrencia_cobranca, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_sequencia_registro_boleto = REPLACE(REPLACE(@v_sequencia_registro_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_primeira_instrucao_boleto = REPLACE(REPLACE(@v_primeira_instrucao_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_segunda_instrucao_boleto = REPLACE(REPLACE(@v_segunda_instrucao_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_descricao_compra_controle = REPLACE(REPLACE(@v_descricao_compra_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_numero_variacao_carteira_beneficiario = REPLACE(REPLACE(@v_numero_variacao_carteira_beneficiario, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_modalidade_titulo_boleto = REPLACE(REPLACE(@v_codigo_modalidade_titulo_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_quantidade_dia_protesto_boleto = REPLACE(REPLACE(@v_quantidade_dia_protesto_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_tipo_juro_mora_juros = REPLACE(REPLACE(@v_codigo_tipo_juro_mora_juros, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_aceite_titulo_boleto = REPLACE(REPLACE(@v_codigo_aceite_titulo_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_tipo_titulo_boleto = REPLACE(REPLACE(@v_codigo_tipo_titulo_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_indicador_permissao_recebimento_parcial_boleto = REPLACE(REPLACE(@v_indicador_permissao_recebimento_parcial_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_texto_campo_utilizacao_beneficiario_boleto = REPLACE(REPLACE(@v_texto_campo_utilizacao_beneficiario_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_tipo_conta_caucao_boleto = REPLACE(REPLACE(@v_codigo_tipo_conta_caucao_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_texto_mensagem_bloqueto_ocorrencia_boleto = REPLACE(REPLACE(@v_texto_mensagem_bloqueto_ocorrencia_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_numero_inscricao_pagador = REPLACE(REPLACE(@v_numero_inscricao_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_nome_municipio_pagador = REPLACE(REPLACE(@v_nome_municipio_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_texto_numero_telefone_pagador = REPLACE(REPLACE(@v_texto_numero_telefone_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_tipo_inscricao_avalista_pagador = REPLACE(REPLACE(@v_codigo_tipo_inscricao_avalista_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_numero_inscricao_avalista_pagador = REPLACE(REPLACE(@v_numero_inscricao_avalista_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_nome_avalista_titulo_pagador = REPLACE(REPLACE(@v_nome_avalista_titulo_pagador, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_chave_usuario_controle = REPLACE(REPLACE(@v_codigo_chave_usuario_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_codigo_tipo_canal_solicitacao_controle = REPLACE(REPLACE(@v_codigo_tipo_canal_solicitacao_controle, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_descricao_tipo_titulo_boleto = REPLACE(REPLACE(@v_descricao_tipo_titulo_boleto, CHAR(13), ' '), CHAR(10), ' ') 
	SET @v_numero_endereco_avalista = REPLACE(REPLACE( @v_numero_endereco_avalista, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_complemento_endereco_avalista = REPLACE(REPLACE( @v_complemento_endereco_avalista, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_tipo_documento_sacador_avalista = REPLACE(REPLACE( @v_tipo_documento_sacador_avalista, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_tipo_bonificacao = REPLACE(REPLACE( @v_tipo_bonificacao, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_perc_desc_bonificacao = REPLACE(REPLACE( @v_perc_desc_bonificacao, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_valor_desc_bonificacao = REPLACE(REPLACE( @v_valor_desc_bonificacao, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_data_limite_desc_bonificacao = REPLACE(REPLACE( @v_data_limite_desc_bonificacao, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_tipo_emissao_papeleta = REPLACE(REPLACE( @v_tipo_emissao_papeleta, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_qtde_parcelas = REPLACE(REPLACE( @v_qtde_parcelas, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_tipo_decurso_prazo = REPLACE(REPLACE( @v_tipo_decurso_prazo, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_qtde_dias_decurso = REPLACE(REPLACE( @v_qtde_dias_decurso, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_qtde_dias_juros = REPLACE(REPLACE( @v_qtde_dias_juros, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_qtde_dias_multa_atraso = REPLACE(REPLACE( @v_qtde_dias_multa_atraso, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_tipo_protesto_negociacao_protesto = REPLACE(REPLACE( @v_tipo_protesto_negociacao_protesto, CHAR(13), ' '), CHAR(10), ' ')
	SET @v_qtde_dias_protesto = REPLACE(REPLACE( @v_qtde_dias_protesto, CHAR(13), ' '), CHAR(10), ' ')

	-- MONTA JSON
	SET @p_mensagem_servico_rest = '
		{
		  "controle_Parametro": {
			"id_Cliente": "'+ISNULL(CONVERT(VARCHAR(100), @p_Id_cliente), '')+'",
			"chave_Cliente": "'+ISNULL(CONVERT(VARCHAR(100), @p_chaveId), '')+'",
			"id_Pedido": "'+ISNULL(CONVERT(VARCHAR(100), @p_id_pedido_registro_boleto), '')+'",
			"eh_Producao": "'+ISNULL(CONVERT(VARCHAR(100), @p_ehProducao), '')+'",
		    "tipo_registro_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_registro_controle), '')+'",
		    "tipo_cobranca_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_cobranca_controle), '')+'",
		    "tipo_produto_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_produto_controle), '')+'",
		    "subproduto_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_subproduto_controle), '')+'",
		    "expiracao_token_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_expiracao_token_controle), '')+'",
		    "sistema_banco_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_sistema_banco_controle), '')+'",
		    "merchant_id_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_merchant_id_controle), '')+'",
		    "token_request_confirmacao_pagamento_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_token_request_confirmacao_pagamento_controle), '')+'",
		    "ip_maquina_cliente_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_ip_maquina_cliente_controle), '')+'",
		    "user_agent_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_user_agent_controle), '')+'",
		    "descricao_compra_controle": "'+ISNULL(CONVERT(VARCHAR(100), replace(replace(@v_descricao_compra_controle, '"', ''), '''', '')), '')+'",
		    "codigo_chave_usuario_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_chave_usuario_controle), '')+'",
		    "codigo_tipo_canal_solicitacao_controle": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_tipo_canal_solicitacao_controle), '')+'"
		  },
		  "cobranca_Parametro": {
		    "identificador_titulo_empresa_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_identificador_titulo_empresa_cobranca), '')+'",
		    "uso_banco_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_uso_banco_cobranca), '')+'",
		    "titulo_aceite_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_titulo_aceite_cobranca), '')+'",
		    "especie_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_especie_cobranca), '')+'",
		    "indicador_pagamento_parcial_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_indicador_pagamento_parcial_cobranca), '')+'",
		    "quantidade_pagamento_parcial_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_quantidade_pagamento_parcial_cobranca), '')+'",
		    "quantidade_parcelas_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_quantidade_parcelas_cobranca), '')+'",
		    "instrucao_cobranca_1_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_instrucao_cobranca_1_cobranca), '')+'",
		    "quantidade_dias_1_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_quantidade_dias_1_cobranca), '')+'",
		    "data_instrucao_1_cobranca": "'+ISNULL(CONVERT(VARCHAR(11),@v_data_instrucao_1_cobranca,105), '')+'",
		    "instrucao_cobranca_2_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_instrucao_cobranca_2_cobranca), '')+'",
		    "quantidade_dias_2_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_quantidade_dias_2_cobranca), '')+'",
		    "data_instrucao_2_cobranca": "'+ISNULL(CONVERT(VARCHAR(11),@v_data_instrucao_2_cobranca,105), '')+'",
		    "instrucao_cobranca_3_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_instrucao_cobranca_3_cobranca), '')+'",
		    "quantidade_dias_3_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_quantidade_dias_3_cobranca), '')+'",
		    "data_instrucao_3_cobranca": "'+ISNULL(CONVERT(VARCHAR(11),@v_data_instrucao_3_cobranca,105), '')+'",
		    "valor_abatimento_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_abatimento_cobranca), '')+'",
		    "meio_pagamento_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_meio_pagamento_cobranca), '')+'",
		    "tipo_ocorrencia_cobranca": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_ocorrencia_cobranca), '')+'"
		  },
		  "boleto_Parametro": {
		    "nosso_numero_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_nosso_numero_boleto), '')+'",
		    "digito_verificador_nosso_numero_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_digito_verificador_nosso_numero_boleto), '')+'",
		    "codigo_barras_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_barras_boleto), '')+'",
		    "data_vencimento_boleto": "'+ISNULL(CONVERT(VARCHAR(10),@v_data_vencimento_boleto,126), '')+'",
		    "valor_titulo_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_titulo_boleto), '')+'",
		    "seu_numero_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_seu_numero_boleto), '')+'",
		    "data_emissao_boleto": "'+ISNULL(CONVERT(VARCHAR(10),@v_data_emissao_boleto,126), '')+'",
		    "data_limite_pagamento_boleto": "'+ISNULL(CONVERT(VARCHAR(10),@v_data_limite_pagamento_boleto,126), '')+'",
		    "data_validade_boleto": "'+ISNULL(CONVERT(VARCHAR(10),@v_data_validade_boleto,126), '')+'",
		    "mensagem_cabecalho_boleto": "'+ISNULL(CONVERT(VARCHAR(2000), @v_mensagem_cabecalho_boleto), '')+'",
		    "instrucao_linha_1_boleto": "'+ISNULL(CONVERT(VARCHAR(2000), @v_instrucao_linha_1_boleto), '')+'",
		    "instrucao_linha_2_boleto": "'+ISNULL(CONVERT(VARCHAR(2000), @v_instrucao_linha_2_boleto), '')+'",
		    "instrucao_linha_3_boleto": "'+ISNULL(CONVERT(VARCHAR(2000), @v_instrucao_linha_3_boleto), '')+'",
		    "tipo_protesto_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_protesto_boleto), '')+'",
		    "qt_dias_protesto_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_qt_dias_protesto_boleto), '')+'",
		    "qt_dias_baixa_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_qt_dias_baixa_boleto), '')+'",
		    "url_logotipo_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_url_logotipo_boleto), '')+'",
		    "tipo_renderizacao_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_renderizacao_boleto), '')+'",
			"tipo_pagamento_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_pagamento_boleto), '')+'",
		    "controle_participante_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_controle_participante_boleto), '')+'",
		    "sequencia_registro_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_sequencia_registro_boleto), '')+'",
		    "primeira_instrucao_boleto": "'+ISNULL(CONVERT(VARCHAR(2000), @v_primeira_instrucao_boleto), '')+'",
		    "segunda_instrucao_boleto": "'+ISNULL(CONVERT(VARCHAR(2000), @v_segunda_instrucao_boleto), '')+'",
		    "codigo_modalidade_titulo_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_modalidade_titulo_boleto), '')+'",
		    "quantidade_dia_protesto_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_quantidade_dia_protesto_boleto), '')+'",
		    "codigo_aceite_titulo_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_aceite_titulo_boleto), '')+'",
		    "codigo_tipo_titulo_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_tipo_titulo_boleto), '')+'",
			"descricao_tipo_titulo_boleto": "",
		    "indicador_permissao_recebimento_parcial_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_indicador_permissao_recebimento_parcial_boleto), '')+'",
		    "texto_campo_utilizacao_beneficiario_boleto": "'+ISNULL(CONVERT(VARCHAR(2000), @v_texto_campo_utilizacao_beneficiario_boleto), '')+'",
		    "codigo_tipo_conta_caucao_boleto": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_tipo_conta_caucao_boleto), '')+'",
		    "texto_mensagem_bloqueto_ocorrencia_boleto": "'+ISNULL(CONVERT(VARCHAR(2000), @v_texto_mensagem_bloqueto_ocorrencia_boleto), '')+'"	
		
		  },
		  "beneficiario_Parametro": {
		    "nome_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_nome_beneficiario), '')+'",
		    "tipo_carteira_titulo_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_carteira_titulo_beneficiario), '')+'",
		    "cpf_cnpj_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_cpf_cnpj_beneficiario), '')+'",
		    "agencia_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_agencia_beneficiario), '')+'",
		    "conta_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_conta_beneficiario), '')+'",
			"numero_carteira_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_numero_carteira_beneficiario), '')+'",
		    "digito_verificador_conta_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_digito_verificador_conta_beneficiario), '')+'",
			"cod_convenio_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_cod_convenio_beneficiario), '')+'",
		    "cod_banco_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_cod_banco_beneficiario), '')+'",
		    "numero_variacao_carteira_beneficiario": "'+ISNULL(CONVERT(VARCHAR(100), @v_numero_variacao_carteira_beneficiario), '')+'"
		  },
		  "debito_Parametro": {
		    "agencia_debito": "'+ISNULL(CONVERT(VARCHAR(100), @v_agencia_debito), '')+'",
		    "conta_debito": "'+ISNULL(CONVERT(VARCHAR(100), @v_conta_debito), '')+'",
		    "digito_verificador_conta_debito": "'+ISNULL(CONVERT(VARCHAR(100), @v_digito_verificador_conta_debito), '')+'",
		    "debito_automatico_debito": "'+ISNULL(CONVERT(VARCHAR(100), @v_debito_automatico_debito), '')+'",
		    "endereco_debito_automatico_debito": "'+ISNULL(CONVERT(VARCHAR(100), @v_endereco_debito_automatico_debito), '')+'"
		  },
		  "credito_Parametro": {
		    "rateio_credito": "'+ISNULL(CONVERT(VARCHAR(100), @v_rateio_credito), '')+'"
		  },
		  "pagador_Parametro": {
		    "cpf_cnpj_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_cpf_cnpj_pagador), '')+'",
		    "nome_pagador": "'+ISNULL(CONVERT(VARCHAR(100), replace(replace(@v_nome_pagador, '"', ''), '''', '')), '')+'",
		    "logradouro_pagador": "'+ISNULL(CONVERT(VARCHAR(100), replace(replace(@v_logradouro_pagador, '"', ''), '''', '')), '')+'",
		    "bairro_pagador": "'+ISNULL(CONVERT(VARCHAR(100), replace(replace(@v_bairro_pagador, '"', ''), '''', '')), '')+'",
		    "cidade_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_cidade_pagador), '')+'",
		    "nome_municipio_pagador": "'+ISNULL(CONVERT(VARCHAR(100), replace(replace(@v_nome_municipio_pagador, '"', ''), '''', '')), '')+'",
		    "numero_endereco_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_numero_endereco_pagador), '')+'",
		    "complemento_pagador": "'+ISNULL(CONVERT(VARCHAR(100), replace(replace(@v_complemento_pagador, '"', ''), '''', '')), '')+'",
		    "uf_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_uf_pagador), '')+'",
		    "cep_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_cep_pagador), '')+'",
		    "tipo_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_pagador), '')+'",
		    "agencia_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_agencia_pagador), '')+'",
		    "conta_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_conta_pagador), '')+'",
		    "razao_conta_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_razao_conta_pagador), '')+'",
		    "numero_inscricao_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_numero_inscricao_pagador), '')+'",
		    "texto_numero_telefone_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_texto_numero_telefone_pagador), '')+'",
		    "codigo_tipo_inscricao_avalista_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_tipo_inscricao_avalista_pagador), '')+'",
		    "numero_inscricao_avalista_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_numero_inscricao_avalista_pagador), '')+'",
		    "nome_avalista_titulo_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_nome_avalista_titulo_pagador), '')+'",
		    "Grupo_Email_Pagador_Parametro": [
		      {
		        "email_pagador": "'+ISNULL(CONVERT(VARCHAR(100), @v_email_pagador), '')+'"
		      }
		    ]
		  },
		  "sacador_Avalista_Parametro": {
		    "cpf_cnpj_sacador_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_cpf_cnpj_sacador_avalista), '')+'",
		    "nome_sacador_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_nome_sacador_avalista), '')+'",
		    "logradouro_sacador_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_logradouro_sacador_avalista), '')+'",
		    "bairro_sacador_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_bairro_sacador_avalista), '')+'",
		    "cidade_sacador_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_cidade_sacador_avalista), '')+'",
		    "uf_sacador_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_uf_sacador_avalista), '')+'",
		    "cep_sacador_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_cep_sacador_avalista), '')+'",
			"numero_endereco_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_numero_endereco_avalista), '')+'",
			"complemento_endereco_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_complemento_endereco_avalista), '')+'",
			"tipo_documento_sacador_avalista": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_documento_sacador_avalista), '')+'"
		  },
		  "moeda_Parametro": {
		    "codigo_moeda_cnab_moeda": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_moeda_cnab_moeda), '')+'",
		    "quantidade_moeda": "'+ISNULL(CONVERT(VARCHAR(100), @v_quantidade_moeda), '')+'"
		  },
		  "juros_Parametro": [';


		  IF isnull(@v_percentual_juros, 0) > 0 or isnull(@v_valor_juros, 0) > 0
		  BEGIN
			IF isnull(@v_percentual_juros, 0) > 0
			BEGIN
			    SET  @v_percentual_juros = @v_percentual_juros 
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'

				IF @v_cod_banco_beneficiario = '104'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_juros":  "'+ISNULL(CONVERT(VARCHAR(10),DATEADD(DAY, 1, @v_data_vencimento_boleto),126), '')+'",' -- DIA APÓS A DATA DO VENCIMENTO
				ELSE
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_juros": "",' -- NÃO SERÁ INFORMADA UMA DATA

				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_juros": "'+ISNULL(CONVERT(VARCHAR(100), '2'), '')+'",'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_juros), '')+'",'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_juros), '')+'",'

				IF @v_cod_banco_beneficiario = '1'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": "2"'	--BB		
				ELSE
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_tipo_juro_mora_juros), '')+'"'			

				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'
			END
			
			IF isnull(@v_valor_juros, 0) > 0
			BEGIN
				IF @v_percentual_juros IS NOT NULL
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + ','

				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'

				IF @v_cod_banco_beneficiario = '104'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_juros":  "'+ISNULL(CONVERT(VARCHAR(10),DATEADD(DAY, 1, @v_data_vencimento_boleto),126), '')+'",' -- DIA APÓS A DATA DO VENCIMENTO
				ELSE
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_juros": "",' -- NÃO SERÁ INFORMADA UMA DATA

				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_juros": "'+ISNULL(CONVERT(VARCHAR(100), '1'), '')+'",'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_juros), '')+'",'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_juros), '')+'",'

				IF @v_cod_banco_beneficiario = '1'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": "1"'	--BB		
				ELSE
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_tipo_juro_mora_juros), '')+'"'		

				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'
			END
		END
		ELSE
		BEGIN
			IF ISNULL(@p_Boleto_candidato, 'N') = 'N'
			BEGIN
				-- OBTEM LISTA DE JUROS
				DECLARE CURSOR_JUROS CURSOR FAST_FORWARD FOR
					SELECT DISTINCT ecg.TIPO_ENCARGO, CONVERT(VARCHAR, ecg.TIPO_CALCULO), CONVERT(VARCHAR, ecg.VALOR) FROM LY_TIPO_ENCARGOS te
						INNER JOIN LY_ENCARGOS_COB_GERADO ecg ON ecg.TIPO_ENCARGO = te.TIPO_ENCARGO
						INNER JOIN LY_COBRANCA cob ON cob.COBRANCA = ecg.COBRANCA
						INNER JOIN LY_ITEM_LANC il ON il.COBRANCA = cob.COBRANCA
						INNER JOIN LY_BOLETO bol ON bol.BOLETO = il.BOLETO
					WHERE te.CATEGORIA = 'JUROS' AND bol.BOLETO = @p_Boleto

				OPEN CURSOR_JUROS
				FETCH NEXT FROM CURSOR_JUROS INTO @v_cursor_tipo_encargo, @v_cursor_tipo_calculo, @v_cursor_valor
				
				-- se não achou juros (isento) ou for de um banco que os juros sempre devem ser calculados no EP
				IF NOT EXISTS (SELECT TOP 1 1 FROM LY_TIPO_ENCARGOS te
							   		INNER JOIN LY_ENCARGOS_COB_GERADO ecg ON ecg.TIPO_ENCARGO = te.TIPO_ENCARGO
							   		INNER JOIN LY_COBRANCA cob ON cob.COBRANCA = ecg.COBRANCA
							   		INNER JOIN LY_ITEM_LANC il ON il.COBRANCA = cob.COBRANCA
							   		INNER JOIN LY_BOLETO bol ON bol.BOLETO = il.BOLETO
							   WHERE te.CATEGORIA = 'JUROS' AND bol.BOLETO = @p_Boleto)
						OR @v_cod_banco_beneficiario in ('41') -- Bancos que os juros sempre devem ser calculados via EP (41 = Banrisul)
				BEGIN
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_juros": "",' -- NÃO SERÁ INFORMADA UMA DATA

					IF @v_cod_banco_beneficiario = '1'
					    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_juros": "0",' --ISENTO BB
					ELSE
					    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_juros": "5",' --ISENTO

					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_juros": "",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_juros": "",'

					IF @v_cod_banco_beneficiario = '1'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": "0"'	
					ELSE
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": ""'	

					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'

				END
				ELSE
					BEGIN
						
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
	
						IF @v_cod_banco_beneficiario = '104'
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_juros":  "'+ISNULL(CONVERT(VARCHAR(10),DATEADD(DAY, 1, @v_data_vencimento_boleto),126), '')+'",' -- DIA APÓS A DATA DO VENCIMENTO
						ELSE
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_juros": "",' -- NÃO SERÁ INFORMADA UMA DATA

						IF @v_cursor_tipo_calculo = 'Percentual'
						BEGIN
							SET @v_tipo_juros = '2' -- POR PERCENTUAL
							SET @v_percentual_juros = @v_cursor_valor 
						END
						ELSE
						BEGIN
							SET @v_tipo_juros = '1' -- POR VALOR
							SET @v_valor_juros = @v_cursor_valor
						END

						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_juros), '')+'",'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_juros), '')+'",'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_juros), '')+'",'

						IF @v_cod_banco_beneficiario = '1'
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_juros), '')+'"'	--BB		
						ELSE
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_codigo_tipo_juro_mora_juros), '')+'"'			

						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'

						FETCH NEXT FROM CURSOR_JUROS INTO @v_cursor_tipo_encargo, @v_cursor_tipo_calculo, @v_cursor_valor

						if @@FETCH_STATUS = 0 
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + ','

					END
				END
				
				CLOSE CURSOR_JUROS
				DEALLOCATE CURSOR_JUROS
			END
			ELSE -- CANDIDATO NÃO POSSUI JUROS
			BEGIN
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_juros": "",' -- NÃO SERÁ INFORMADA UMA DATA

					IF @v_cod_banco_beneficiario = '1'
					    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_juros": "0",' --ISENTO BB
					ELSE
					    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_juros": "5",' --ISENTO

					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_juros": "",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_juros": "",'

					IF @v_cod_banco_beneficiario = '1'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": "0"'	
					ELSE
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"codigo_tipo_juro_mora_juros": ""'	
		
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'
			END
		END

		SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + 
		    '],
		  "multa_Parametro": [';

		  IF @v_percentual_multa IS NOT NULL or @v_valor_multa IS NOT NULL --foi substituiído no EP
		  BEGIN
			IF @v_percentual_multa IS NOT NULL
			BEGIN
			    SET @v_valor_multa = @v_valor_multa 
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"aplicar_multa": "",'

				IF @v_cod_banco_beneficiario IN ('1', '104')
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_multa": "'+ISNULL(CONVERT(VARCHAR(10),DATEADD(DAY, 1, @v_data_vencimento_boleto),126), '')+'",' -- DIA APÓS A DATA DO VENCIMENTO
				ELSE					
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_multa": "",' -- NÃO SERÁ INFORMADA UMA DATA

				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_multa": "'+ISNULL(CONVERT(VARCHAR(100), '2'), '')+'",'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_multa": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_multa), '')+'",'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_multa": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_multa), '')+'"'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'
			END
			
			IF @v_valor_multa IS NOT NULL
			BEGIN

			IF @v_percentual_multa IS NOT NULL --se já tem um valor no json precisa de virgula
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + ','

				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"aplicar_multa": "",'

				IF @v_cod_banco_beneficiario IN ('1', '104')
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_multa": "'+ISNULL(CONVERT(VARCHAR(10),DATEADD(DAY, 1, @v_data_vencimento_boleto),126), '')+'",' -- DIA APÓS A DATA DO VENCIMENTO
				ELSE					
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_multa": "",' -- NÃO SERÁ INFORMADA UMA DATA

				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_multa": "'+ISNULL(CONVERT(VARCHAR(100), '1'), '')+'",'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_multa": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_multa), '')+'",'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_multa": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_multa), '')+'"'
				SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'
			END
		END
		ELSE
		BEGIN
			IF ISNULL(@p_Boleto_candidato, 'N') = 'N'
			BEGIN
				-- OBTEM LISTA DE MULTA
				DECLARE CURSOR_MULTA CURSOR FAST_FORWARD FOR
					SELECT DISTINCT ecg.TIPO_ENCARGO, CONVERT(VARCHAR, ecg.TIPO_CALCULO), CONVERT(VARCHAR, ecg.VALOR) FROM LY_TIPO_ENCARGOS te
						INNER JOIN LY_ENCARGOS_COB_GERADO ecg ON ecg.TIPO_ENCARGO = te.TIPO_ENCARGO
						INNER JOIN LY_COBRANCA cob ON cob.COBRANCA = ecg.COBRANCA
						INNER JOIN LY_ITEM_LANC il ON il.COBRANCA = cob.COBRANCA
						INNER JOIN LY_BOLETO bol ON bol.BOLETO = il.BOLETO
					WHERE te.CATEGORIA = 'MULTA' AND bol.BOLETO = @p_Boleto

				OPEN CURSOR_MULTA
				FETCH NEXT FROM CURSOR_MULTA INTO @v_cursor_tipo_encargo, @v_cursor_tipo_calculo, @v_cursor_valor

				IF NOT EXISTS(	SELECT TOP 1 1 FROM LY_TIPO_ENCARGOS te
						INNER JOIN LY_ENCARGOS_COB_GERADO ecg ON ecg.TIPO_ENCARGO = te.TIPO_ENCARGO
						INNER JOIN LY_COBRANCA cob ON cob.COBRANCA = ecg.COBRANCA
						INNER JOIN LY_ITEM_LANC il ON il.COBRANCA = cob.COBRANCA
						INNER JOIN LY_BOLETO bol ON bol.BOLETO = il.BOLETO
					WHERE te.CATEGORIA = 'MULTA' AND bol.BOLETO = @p_Boleto)
				BEGIN				
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"aplicar_multa": "",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_multa": "",' -- NÃO SERÁ INFORMADA UMA DATA

					IF @v_cod_banco_beneficiario = '1'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"tipo_multa": "0",'  --ISENTO BB
					else	 
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"tipo_multa": "3",' -- ISENTO

				    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"valor_multa": "",'
				    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"percentual_multa": ""'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'

				END
				ELSE
					BEGIN
						
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"aplicar_multa": "",'

						IF @v_cod_banco_beneficiario IN ('1', '104')
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_multa": "'+ISNULL(CONVERT(VARCHAR(10),DATEADD(DAY, 1, @v_data_vencimento_boleto),126), '')+'",' -- DIA APÓS A DATA DO VENCIMENTO
						ELSE					
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_multa": "",' -- NÃO SERÁ INFORMADA UMA DATA
					
						IF @v_cursor_tipo_calculo = 'Percentual'
						BEGIN
							SET @v_tipo_multa = '2' -- POR PERCENTUAL
							SET @v_percentual_multa = @v_cursor_valor 
						END
						ELSE
						BEGIN
							SET @v_tipo_multa = '1' -- POR VALOR
							SET @v_valor_multa = @v_cursor_valor
						END

						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_multa": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_multa), '')+'",'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_multa": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_multa), '')+'",'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_multa": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_multa), '')+'"'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'

						FETCH NEXT FROM CURSOR_MULTA INTO @v_cursor_tipo_encargo, @v_cursor_tipo_calculo, @v_cursor_valor

						if @@FETCH_STATUS = 0 --se tem próximo coloca virgula
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + ','
					END
				END
				
				CLOSE CURSOR_MULTA
				DEALLOCATE CURSOR_MULTA
			END
			ELSE -- CANDIDATO NÃO POSSUIR MULTA
			BEGIN
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"aplicar_multa": "'+ISNULL(CONVERT(VARCHAR(100), @v_aplicar_multa), '')+'",'
				    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"data_multa": "",'

					IF @v_cod_banco_beneficiario = '1'
						SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"tipo_multa": "0",'  --ISENTO BB
					else	 
					    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"tipo_multa": "3",' -- ISENTO

				    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"valor_multa": "",'
				    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +'"percentual_multa": ""'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'
			END
		END

		SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '],';

			--/*
			--	INICIO TRATAMENTO DE PERDA BOLSA
			--    VERIFICA SE TEM PERDA BOLSA 
			--**/

			---- BUSCA LANC_DEB
			--	INSERT INTO  @v_perde_bolsa_lanc_deb 
			--	SELECT DISTINCT LANC.LANC_DEB
			--	 From LY_ITEM_LANC LANC, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE 
			--	Where (LANC.NUM_BOLSA = B.NUM_BOLSA) AND  
			--			(LANC.ALUNO = B.ALUNO) AND 
			--			(B.TIPO_BOLSA = TB.TIPO_BOLSA) AND  
			--			(TB.TIPO_ENCARGO = TE.TIPO_ENCARGO) AND 
			--			(TE.CATEGORIA = 'PerdaBolsa') AND  (LANC.BOLETO =  @p_Boleto ) AND LANC.LANC_DEB IS NOT NULL 
			--	group by LANC.lanc_deb;


			--	IF EXISTS (SELECT TOP 1 1 FROM @v_perde_bolsa_lanc_deb) 
			--		BEGIN 
			--			-- BUSCA PARCELA
			--			SET @v_perde_bolsa_parc=
			--			(SELECT MAX(LANC.PARCELA) 
			--				From LY_ITEM_LANC LANC, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE  
			--				Where 
			--			(LANC.NUM_BOLSA = B.NUM_BOLSA) AND  (LANC.ALUNO = B.ALUNO) AND 
			--			(B.TIPO_BOLSA = TB.TIPO_BOLSA) AND  (TB.TIPO_ENCARGO = TE.TIPO_ENCARGO) AND 
			--			(TE.CATEGORIA = 'PerdaBolsa') AND (LANC.BOLETO =  @p_Boleto ) AND LANC.LANC_DEB IS NOT NULL  
			--				AND NOT EXISTS (SELECT 1 FROM LY_ITEM_CRED WHERE COBRANCA = LANC.COBRANCA AND TIPO_ENCARGO='Perde_Bolsa'));
			--		END
			--	ELSE 
			--		BEGIN
			--			SET @v_perde_bolsa_parc=NULL 
			--		END

			--	-- BUSCA VALOR DA BOLSA	  
			--	IF EXISTS (SELECT TOP 1 1 FROM @v_perde_bolsa_lanc_deb) AND @v_perde_bolsa_parc IS NOT NULL
			--		BEGIN
			--			SET @v_perde_bolsa_valor=
			--			(SELECT SUM(LANC.VALOR) VALOR_PAGO_TOT 
			--			FROM LY_ITEM_LANC LANC, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE  
			--			Where 
			--			(LANC.NUM_BOLSA = B.NUM_BOLSA) AND  (LANC.ALUNO = B.ALUNO) AND 
			--			(B.TIPO_BOLSA = TB.TIPO_BOLSA) AND (TB.TIPO_ENCARGO = TE.TIPO_ENCARGO) AND
			--			(TE.CATEGORIA = 'PerdaBolsa') AND (LANC.PARCELA = @v_perde_bolsa_parc ) AND (LANC.LANC_DEB IN(SELECT * FROM @v_perde_bolsa_lanc_deb))  AND
			--			(LANC.BOLETO = @p_Boleto) AND LANC.VALOR<>0 
			--				AND NOT EXISTS (SELECT 1 FROM LY_ITEM_CRED 
			--					WHERE COBRANCA = LANC.COBRANCA AND TIPO_ENCARGO='Perde_Bolsa'));
			--		END
			--	ELSE 
			--	BEGIN
			--		SET @v_perde_bolsa_valor = NULL ;
			--	END

			--	-- BUSCA DATA DA PERDA BOLSA 
			--	IF EXISTS (SELECT TOP 1 1 FROM @v_perde_bolsa_lanc_deb) AND @v_perde_bolsa_parc IS NOT NULL
			--		BEGIN
			--			SELECT distinct  @v_data_perda_bolsa =C.data_de_vencimento ,@v_aluno= C.ALUNO
			--			FROM LY_BOLETO BOL INNER JOIN LY_ITEM_LANC I ON BOL.BOLETO = I.BOLETO
			--			INNER JOIN LY_COBRANCA C ON C.COBRANCA = I.COBRANCA
			--			WHERE I.BOLETO =  @p_Boleto 
			--			EXEC DIA_UTIL @v_aluno, @v_data_perda_bolsa OUTPUT
			
			--		END
			--	ELSE
			--		BEGIN
			--		   SET @v_data_perda_bolsa=NULL
			--		END

			--	IF EXISTS (SELECT TOP 1 1 FROM @v_perde_bolsa_lanc_deb) AND @v_perde_bolsa_parc IS NOT NULL AND @v_perde_bolsa_valor IS NOT NULL AND @v_perde_bolsa_valor <> 0	AND @v_data_perda_bolsa IS NOT NULL
			--		BEGIN 
			--			SET  @v_calcula_perda_bolsa = 1;
   --                 END 
			--	ELSE
			--		BEGIN 	  
			--			SET  @v_calcula_perda_bolsa = 0;
			--		END


			--  SET  @v_perde_bolsa_valor =REPLACE(REPLACE(@v_perde_bolsa_valor, CHAR(13), ' '), CHAR(10), ' ');
	

		SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + 
			'
		  "grupo_Desconto_Parametro": [';

		-- SE TEM VALOR PARA APLICAR DESCONTO 
		IF ISNULL(@v_valor_titulo_boleto_desc, 0) > 0
		BEGIN

			IF @v_percentual_desconto IS NOT NULL or @v_valor_desconto IS NOT NULL --foi substituiído no EP
			BEGIN

		  		IF @v_data_desconto IS NULL
					BEGIN
						SET @v_data_desconto = @v_data_vencimento_boleto
					END
			
				IF @v_utiliza_venc_dia_util = 'S'
					BEGIN
						EXEC DIA_UTIL @v_aluno, @v_data_desconto OUTPUT
					END
			
  				   -- calcula valor do desconto considerando perda bolsa 
					IF @v_calcula_perda_bolsa=1	
						BEGIN
							IF @v_percentual_desconto IS NOT NULL	-- SE FOI SETADO DESCONTO PERCENTUAL
								BEGIN 	
									IF @v_data_perda_bolsa <= @v_data_desconto 
										BEGIN  -- SE A DATA DA PERDA BOLSA FOR MENOR QUE A DATA DO DESCONTO
											SET @v_valor_desconto = ((@v_valor_titulo_boleto_desc)* @v_percentual_desconto);
											SET @v_valor_desconto = @v_valor_desconto - @v_perde_bolsa_valor
										END
									ELSE
										BEGIN
											SET @v_valor_desconto = (@v_valor_titulo_boleto_desc * @v_percentual_desconto);
										END
										-- transforma percentual em valor
										SET @v_percentual_desconto =NULL;
										SET @v_tipo_desconto ='1';
								END
							ELSE IF @v_valor_desconto IS NOT NULL
							 BEGIN
								IF @v_data_perda_bolsa <= @v_data_desconto 
									BEGIN  -- SE A DATA DA PERDA BOLSA FOR MENOR QUE A DATA DO DESCONTO
										SET @v_valor_desconto = (@v_perde_bolsa_valor *(-1)) + @v_valor_desconto;
									END
							
								-- transforma percentual em valor
								SET @v_percentual_desconto =NULL;
								SET @v_tipo_desconto ='1';
							END  -- @v_valor_desconto IS NOT NULL
										
							-- Bradesco opera somente com desconto percentual
							IF @v_cod_banco_beneficiario = '237'  
							BEGIN  
								SET @v_tipo_desconto ='2';
								SET @v_percentual_desconto = @v_valor_desconto / @v_valor_titulo_boleto;
								SET @v_valor_desconto = null
							END

							IF @v_cod_banco_beneficiario <> '237'  
							BEGIN
								insert into @v_mensagens_desconto (MENSSAGEM)values('ATÉ A DATA '+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'PAGAR '+ (CONVERT(VARCHAR(50),(@v_valor_titulo_boleto_desc - @v_valor_desconto))));
							END
						END	  --  fim  @v_calcula_perda_bolsa=1	
					ELSE
					BEGIN 
						BEGIN
							IF @v_percentual_desconto IS NOT NULL	-- SE FOI SETADO DESCONTO PERCENTUAL
								BEGIN 	
									SET @v_valor_desconto = (@v_valor_titulo_boleto_desc * @v_percentual_desconto);
								
									-- transforma percentual em valor
									SET @v_percentual_desconto =NULL;
									SET @v_tipo_desconto ='1';
								END
							ELSE IF @v_valor_desconto IS NOT NULL
								BEGIN
														
									-- transforma percentual em valor
									SET @v_percentual_desconto =NULL;
									SET @v_tipo_desconto ='1';
								END  -- @v_valor_desconto IS NOT NULL


							-- Bradesco opera somente com desconto percentual
							IF @v_cod_banco_beneficiario = '237'  
							BEGIN  
								SET @v_tipo_desconto ='2';
								SET @v_percentual_desconto = @v_valor_desconto / @v_valor_titulo_boleto;
								SET @v_valor_desconto = null
								insert into @v_mensagens_desconto (MENSSAGEM)values('ATÉ A DATA '+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'PAGAR '+ (CONVERT(VARCHAR(50),@v_valor_titulo_boleto_desc - @v_valor_desconto)));
							END

							IF @v_cod_banco_beneficiario <> '237'  
							BEGIN	
								insert into @v_mensagens_desconto (MENSSAGEM)values('ATÉ A DATA '+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'PAGAR '+ (CONVERT(VARCHAR(50),(@v_valor_titulo_boleto_desc - @v_valor_desconto))));
							END 
						END	  --  fim  @v_calcula_perda_bolsa=1
					END
					

					
				IF @v_valor_desconto IS NOT NULL
				BEGIN

				IF @v_percentual_desconto IS NOT NULL --se já tem um valor no json precisa de virgula
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + ','

					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_desconto": "'+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_desconto": "'+ISNULL(CONVERT(VARCHAR(100), '1'), '')+'",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_desconto": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_desconto), '')+'",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_desconto": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_desconto), '')+'"'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'
				END
			END
			ELSE
			BEGIN
				IF ISNULL(@p_Boleto_candidato, 'N') = 'N'
				BEGIN
					-- OBTEM LISTA DE DESCONTO agrupado pelo tipo Valor ou Percentual
					DECLARE CURSOR_DESCONTO CURSOR FAST_FORWARD FOR
					SELECT dc.TIPO_DESC, ISNULL(dc.DT_VENC_DESC,@v_data_vencimento_boleto), CONVERT(VARCHAR, SUM(dc.VALOR)) FROM LY_DESCONTO_COBRANCA dc
					WHERE EXISTS (SELECT TOP 1 1 FROM LY_ITEM_LANC IL WHERE il.COBRANCA = DC.COBRANCA AND IL.BOLETO = @p_Boleto)
					GROUP BY dc.TIPO_DESC, dc.DT_VENC_DESC
					ORDER BY dc.DT_VENC_DESC

					OPEN CURSOR_DESCONTO
					FETCH NEXT FROM CURSOR_DESCONTO INTO @v_cursor_tipo_desc, @v_data_desconto, @v_cursor_valor_desconto

					IF NOT EXISTS (SELECT TOP 1 1 FROM LY_DESCONTO_COBRANCA dc
										INNER JOIN LY_COBRANCA cob ON cob.COBRANCA = dc.COBRANCA
										INNER JOIN LY_ITEM_LANC il ON il.COBRANCA = cob.COBRANCA
										INNER JOIN LY_BOLETO bol ON bol.BOLETO = il.BOLETO
								   WHERE bol.BOLETO = @p_Boleto)
					BEGIN
						IF @v_calcula_perda_bolsa=1	
							BEGIN
								SET @v_data_desconto = @v_data_perda_bolsa
								SET @v_valor_desconto = @v_perde_bolsa_valor * -1
								SET @v_percentual_desconto =NULL;
								SET @v_tipo_desconto ='1';

								-- Bradesco opera somente com desconto percentual
								IF @v_cod_banco_beneficiario = '237'  
								BEGIN  
									SET @v_tipo_desconto ='2';
									SET @v_percentual_desconto = @v_valor_desconto / @v_valor_titulo_boleto;
									SET @v_valor_desconto = null
								END
										
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_desconto": "'+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'",'
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_desconto": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_desconto), '2')+'",'
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_desconto": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_desconto), '')+'",'
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_desconto": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_desconto), '')+'"'
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'

								IF @v_cod_banco_beneficiario <> '237' 
								BEGIN
									insert into @v_mensagens_desconto (MENSSAGEM)values('ATÉ A DATA '+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'PAGAR '+ (CONVERT(VARCHAR(50),@v_valor_titulo_boleto_desc - @v_valor_desconto) ));
								END
							END
						ELSE
							BEGIN
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_desconto": "",'
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_desconto": "0",' -- SEM DESCONTO
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_desconto": "",'
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_desconto": ""'	
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'
							END
					END --IF NOT EXISTS (SELECT TOP
					ELSE
						BEGIN
						WHILE @@FETCH_STATUS = 0
						BEGIN

							-- calcula valor do desconto considerando perda bolsa 
							IF @v_calcula_perda_bolsa=1		 
								BEGIN
									IF @v_cursor_tipo_desc = 'Percentual'
										BEGIN 	
											IF @v_data_perda_bolsa <= @v_data_desconto 
												BEGIN  -- SE A DATA DA PERDA BOLSA FOR MENOR QUE A DATA DO DESCONTO
													SET @v_valor_desconto = ((@v_valor_titulo_boleto_desc )* @v_cursor_valor_desconto);
													SET @v_valor_desconto = @v_valor_desconto - @v_perde_bolsa_valor
												END
											ELSE
												BEGIN
													SET @v_valor_desconto = (@v_valor_titulo_boleto_desc * @v_cursor_valor_desconto);
												END
											-- em valor
											SET @v_percentual_desconto =NULL;
											SET @v_tipo_desconto ='1';
										END	 
									ELSE -- ELSE @v_cursor_tipo_desc = 'Percentual'
										BEGIN
											IF @v_data_perda_bolsa <= @v_data_desconto 
												BEGIN  -- SE A DATA DA PERDA BOLSA FOR MENOR QUE A DATA DO DESCONTO
													SET @v_valor_desconto = ( @v_perde_bolsa_valor* (-1) + @v_cursor_valor_desconto);
												END
											ELSE
												BEGIN 
													SET @v_valor_desconto =  @v_cursor_valor_desconto;
												END

											-- em valor
											SET @v_percentual_desconto =NULL;
											SET @v_tipo_desconto ='1';
										END  -- @v_valor_desconto IS NOT NULL

									-- Bradesco opera somente com desconto percentual
									IF @v_cod_banco_beneficiario = '237'  
									BEGIN  
										SET @v_tipo_desconto ='2';
										SET @v_percentual_desconto = @v_valor_desconto / @v_valor_titulo_boleto;
										SET @v_valor_desconto = null
									END

									IF @v_cod_banco_beneficiario <> '237'
									BEGIN
										insert into @v_mensagens_desconto (MENSSAGEM)values('ATÉ A DATA '+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'PAGAR '+ (CONVERT(VARCHAR(50),@v_valor_titulo_boleto_desc - @v_valor_desconto) ));
									END
								END	  
							ELSE   --  ELSE  @v_calcula_perda_bolsa=1	
								BEGIN
									IF @v_cursor_tipo_desc = 'Percentual'
										BEGIN
											SET @v_tipo_desconto = '1' -- POR VALOR
											SET @v_percentual_desconto = null
											SET @v_valor_desconto = ((@v_valor_titulo_boleto_desc )* @v_cursor_valor_desconto);

											IF @v_cod_banco_beneficiario <> '237'
											BEGIN
												insert into @v_mensagens_desconto (MENSSAGEM)values('ATÉ A DATA '+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'PAGAR '+ (CONVERT(VARCHAR(50),@v_valor_titulo_boleto_desc * @v_valor_desconto)));
											END
										END
									ELSE
										BEGIN
											SET @v_tipo_desconto = '1' -- POR VALOR
											SET @v_valor_desconto = @v_cursor_valor_desconto
											
											IF @v_cod_banco_beneficiario <> '237'
											BEGIN
												insert into @v_mensagens_desconto (MENSSAGEM)values('ATÉ A DATA '+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'PAGAR '+ (CONVERT(VARCHAR(50),@v_valor_titulo_boleto_desc - @v_valor_desconto)));
											END
										END 
								
									-- Bradesco opera somente com desconto percentual
									IF @v_cod_banco_beneficiario = '237'  
									BEGIN  
										SET @v_tipo_desconto ='2';
										SET @v_percentual_desconto = @v_valor_desconto / @v_valor_titulo_boleto;
										SET @v_valor_desconto = null
									END
								
								END
						
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_desconto": "'+ISNULL(CONVERT(VARCHAR(10),@v_data_desconto,126), '')+'",'
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_desconto": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_desconto), '')+'",'
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_desconto": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_desconto), '')+'",'
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_desconto": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_desconto), '')+'"'
							SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}'

							FETCH NEXT FROM CURSOR_DESCONTO INTO @v_cursor_tipo_desc, @v_data_desconto, @v_cursor_valor_desconto
							if @@FETCH_STATUS = 0 --se tem próximo coloca virgula
								SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + ','
						END
					END
				
					CLOSE CURSOR_DESCONTO
					DEALLOCATE CURSOR_DESCONTO
				END
				ELSE -- CANDIDATO NÃO POSSUI DESCONTO
				BEGIN
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_desconto": "",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_desconto": "0",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_desconto": "",'
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_desconto": ""' 
					SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}' 
				END
			END
		END 
		ELSE  -- NÃO TEM VALOR PARA APLICAR DESCONTO
		BEGIN
			SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '{'
			SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"data_desconto": "",'
			SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"tipo_desconto": "0",'
			SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"valor_desconto": "",'
			SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '"percentual_desconto": ""' 
			SET @p_mensagem_servico_rest = @p_mensagem_servico_rest + '}' 
		END

	    SET @p_mensagem_servico_rest = @p_mensagem_servico_rest +   
			'],
		  "recebimento_Divergente_Parametro": {
		    "tipo_autorizacao_recebimento_divergente": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_autorizacao_recebimento_divergente), '')+'",
		    "tipo_valor_percentual_recebimento_divergente": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_valor_percentual_recebimento_divergente), '')+'",
			"valor_minimo_recebimento_divergente": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_minimo_recebimento_divergente), '')+'",
		    "percentual_minimo_recebimento_divergente": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_minimo_recebimento_divergente), '')+'",
			"valor_maximo_recebimento_divergente": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_maximo_recebimento_divergente), '')+'",
		    "percentual_maximo_recebimento_divergente": "'+ISNULL(CONVERT(VARCHAR(100), @v_percentual_maximo_recebimento_divergente), '')+'"
		  },
		  "grupo_Rateio_Parametro": [
		    {
		      "agencia_grupo_rateio": "'+ISNULL(CONVERT(VARCHAR(100), @v_agencia_grupo_rateio), '')+'",
		      "conta_grupo_rateio": "'+ISNULL(CONVERT(VARCHAR(100), @v_conta_grupo_rateio), '')+'",
		      "digito_verificador_conta_grupo_rateio": "'+ISNULL(CONVERT(VARCHAR(100), @v_digito_verificador_conta_grupo_rateio), '')+'",
		      "tipo_grupo_rateio": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_grupo_rateio), '')+'",
		      "valor_percentual_grupo_rateio": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_percentual_grupo_rateio), '')+'"
		    }
		  ],
		  "bonificacao_Parametro":{
		      "tipo_bonificacao": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_bonificacao), '')+'",
			  "perc_desc_bonificacao": "'+ISNULL(CONVERT(VARCHAR(100), @v_perc_desc_bonificacao), '')+'",
			  "valor_desc_bonificacao": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_desc_bonificacao), '')+'",
			  "data_limite_desc_bonificacao": "'+ISNULL(CONVERT(VARCHAR(10), @v_data_limite_desc_bonificacao, 126), '')+'"
		   },
		  "protesto_Parametro":{
		     "tipo_protesto_negociacao_protesto": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_protesto_negociacao_protesto), '')+'",
			 "qtde_dias_protesto": "'+ISNULL(CONVERT(VARCHAR(100), @v_qtde_dias_protesto), '')+'"
		  },
		  "informacoes_Adicionais_Parametro":{
		     "tipo_emissao_papeleta": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_emissao_papeleta), '')+'",
			 "qtde_parcelas": "'+ISNULL(CONVERT(VARCHAR(100), @v_qtde_parcelas), '')+'",
			 "valor_iof": "'+ISNULL(CONVERT(VARCHAR(100), @v_valor_iof), '')+'",
			 "tipo_decurso_prazo": "'+ISNULL(CONVERT(VARCHAR(100), @v_tipo_decurso_prazo), '')+'",
			 "qtde_dias_decurso": "'+ISNULL(CONVERT(VARCHAR(100), @v_qtde_dias_decurso), '')+'",
			 "qtde_dias_juros": "'+ISNULL(CONVERT(VARCHAR(100), @v_qtde_dias_juros), '')+'",
			 "qtde_dias_multa_atraso": "'+ISNULL(CONVERT(VARCHAR(100), @v_qtde_dias_multa_atraso), '')+'"
		  }
		}';


-- [FIM]
RETURN

END
GO
