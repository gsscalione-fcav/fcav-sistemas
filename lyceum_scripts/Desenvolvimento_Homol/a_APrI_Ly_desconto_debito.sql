/*
	EP a_APrI_Ly_desconto_debito

	Alteração: 
		28/02/2019: Não aplicar o desconto do plano de pagamento A Vista quando houver Voucher.
		Autor: Gabriel S Scalione

Autor: Techne
Data: 2018-11-14
*/
-----------------------------

ALTER PROCEDURE a_APrI_Ly_desconto_debito  
    @erro VARCHAR(1024) OUTPUT,  
    @lanc_deb NUMERIC(20, 10) OUTPUT, @resp VARCHAR(200) OUTPUT, @motivo_desconto VARCHAR(200) OUTPUT,   
    @valor NUMERIC(20, 10) OUTPUT, @data DATETIME OUTPUT, @tipo_parcelamento NUMERIC(20, 10) OUTPUT,   
    @descricao VARCHAR(200) OUTPUT, @lote NUMERIC(20, 10) OUTPUT  
  AS  
  BEGIN  
   -- [INÍCIO] Customização - Não escreva código antes desta linha  

   -- Variáveis para Localizar o Aluno
   DECLARE  @p_aluno T_CODIGO,
			@p_ano T_ANO,
			@p_periodo T_SEMESTRE2

	--Variáveis para o plano de pagmento
	DECLARE @v_total_percentual  decimal(14,6)  
	DECLARE @v_cont_outras_dividas T_NUMERO_PEQUENO  
	DECLARE @v_Erros   VARCHAR(1024)  
	DECLARE @v_resp   T_CODIGO  
	DECLARE @v_fiador   T_CODIGO  
	DECLARE @v_fiador2   T_CODIGO  
	DECLARE @v_planopag  T_CODIGO  
	DECLARE @v_ano_inicial  T_ANO  
	DECLARE @v_mes_inicial  T_NUMERO_PEQUENO  
	DECLARE @v_dia_vencimento T_NUMERO_PEQUENO  
	DECLARE @v_desc_perc_valor T_TIPO_TAXA  
	DECLARE @v_desconto  T_DECIMAL_MEDIO_PRECISO  
	DECLARE @v_percententrada T_DECIMAL_PRECISO  
	DECLARE @v_num_parcelas T_NUMERO_PEQUENO  
	DECLARE @v_percent_divida_aluno T_DECIMAL_PRECISO  
	DECLARE @v_dt_ult_alt  T_DATA  
	DECLARE @v_aplicabolsa  varchar(1)  
	DECLARE @v_aparece_extrato_aluno varchar(1)   
	DECLARE @v_outras_dividas varchar(1)  
	DECLARE @v_impr_bol_matr_web varchar(1)  
	DECLARE @v_rateia_restante_divida varchar(1)    
	DECLARE @v_serie   T_NUMERO_PEQUENO  
	DECLARE @v_num_parcelas_insc T_NUMERO_PEQUENO  
	DECLARE @v_ErrorsCount  int  
	DECLARE @v_ano   T_ANO   
	DECLARE @v_periodo  T_SEMESTRE2  
	DECLARE @v_aluno   T_CODIGO  
	DECLARE @v_Count   int  
	DECLARE @v_straux varchar(100)  
	DECLARE @aux_banco varchar (10)  
	DECLARE @v_Banco T_NUMERO_PEQUENO  
	DECLARE @v_Agencia T_ALFASMALL  
	DECLARE @v_Conta_Banco T_ALFASMALL  
	DECLARE @v_Dv_Agencia T_ALFASMALL  
	DECLARE @v_Dv_Conta T_ALFASMALL  
	DECLARE @v_Dv_Agencia_Conta T_ALFASMALL  
	DECLARE @v_Operacao T_ALFASMALL  
	DECLARE @v_parcela T_NUMERO_PEQUENO  
	DECLARE @v_straux1 varchar(100)  
	DECLARE @v_count_parcelas int  
	DECLARE @v_count_cob int  
	DECLARE @v_aplica_rever_resp int  
	DECLARE @v_aplica_rever_resp_ext int  
	DECLARE @v_aplicabolsaReveRFP  varchar(1)
      
	--Localiza o Aluno, Ano e Periodo pela Dívida dele
	SELECT 
		@p_aluno = ALUNO,
		@p_ano = ANO_REF,
		@p_periodo = PERIODO_REF
	FROM LY_LANC_DEBITO
	WHERE LANC_DEB = @lanc_deb

	--Alimenta as variáveis do plano de pagamento do Aluno, para serem utilizada na EP abaixo.
	SELECT 
		@v_resp = RESP, 
		@p_ano = ANO, 
		@p_periodo = PERIODO,
		@p_aluno = ALUNO, 
		@v_planopag = PLANOPAG,
		@v_ano_inicial = ANO_INICIAL,
		@v_mes_inicial = MES_INICIAL,   
		@v_dia_vencimento = DIA_VENCIMENTO, 
		@v_percententrada = PERCENTENTRADA,  
		@v_num_parcelas = NUM_PARCELAS, 
		@v_percent_divida_aluno = PERCENT_DIVIDA_ALUNO,  
		@v_dt_ult_alt = DT_ULT_ALT, 
		@v_aplicabolsa = APLICABOLSA,  
		@v_aparece_extrato_aluno = APARECE_EXTRATO_ALUNO,   
		@v_outras_dividas = OUTRAS_DIVIDAS, 
		@v_impr_bol_matr_web = IMPR_BOL_MATR_WEB,  
		@v_rateia_restante_divida = RATEIA_RESTANTE_DIVIDA,  
		@v_serie = SERIE,  
		@v_num_parcelas_insc = NUM_PARCELAS_INSC, 
		@v_fiador = FIADOR, 
		@v_fiador2 = FIADOR2,  
		@v_Banco = BANCO, 
		@v_Agencia = AGENCIA, 
		@v_Conta_Banco = CONTA_BANCO,  
		@v_Dv_Agencia = DV_AGENCIA, 
		@v_Dv_Conta	= DV_CONTA,   
		@v_Dv_Agencia_Conta = DV_AGENCIA_CONTA, 
		@v_Operacao = OPERACAO, 
		@v_aplicabolsaReveRFP = APLICABOLSA_RFPRINC
	FROM 
		LY_PLANO_PGTO_PERIODO
	WHERE 
		ALUNO = @p_aluno
		AND ANO = @p_ano
		AND PERIODO = @p_periodo	

	------------------------
	--Caso o motivo do desconto seja Voucher, será verificado se o plano de pagamento é a Vista e se há desconto.
   IF @motivo_desconto = 'Voucher' 
   BEGIN 
		IF EXISTS(SELECT 1 FROM LY_PLANO_PGTO_PERIODO
					WHERE ALUNO = @p_aluno
							AND ANO = @p_ano
							AND PERIODO = @p_periodo
							AND PLANOPAG = 'AVISTA'
							AND DESCONTO IS NOT NULL)
		BEGIN
			/* Caso seja verdadeiro as validações dos Ifs acima, chama a EP LY_PLANO_PGTO_PERIODO_Update para para retirar o desconto para pagamento a vista, 
			   preenchendo NULL nas variáveis @Desc_perc_valor e @Desconto.*/
			EXEC LY_PLANO_PGTO_PERIODO_Update 
				@pkResp = @v_resp, 
				@pkAno = @p_ano, 
				@pkPeriodo = @p_periodo,
				@pkAluno = @p_aluno, 
				@Planopag = @v_planopag,
				@Ano_inicial = @v_ano_inicial,
				@Mes_inicial = @v_mes_inicial,   
                @Dia_vencimento = @v_dia_vencimento, 
				@Desc_perc_valor = NULL,					
                @Desconto = NULL,							
				@Percententrada = @v_percententrada,  
                @Num_parcelas = @v_num_parcelas, 
				@Percent_divida_aluno = @v_percent_divida_aluno,  
                @Dt_ult_alt = @v_dt_ult_alt, 
				@Aplicabolsa = @v_aplicabolsa,  
                @Aparece_extrato_aluno = @v_aparece_extrato_aluno,   
                @Outras_dividas = @v_outras_dividas, 
				@Impr_bol_matr_web = @v_impr_bol_matr_web,  
                @Rateia_restante_divida = @v_rateia_restante_divida,  
				@Serie = @v_serie,  
                @Num_parcelas_insc = @v_num_parcelas_insc, 
				@Fiador = @v_fiador, 
				@Fiador2 = @v_fiador2,  
                @Banco = @v_Banco, 
				@Agencia = @v_Agencia, 
				@Conta_Banco = @v_Conta_Banco,  
                @Dv_Agencia = @v_Dv_Agencia, 
				@Dv_Conta = @v_Dv_Conta,   
                @Dv_Agencia_Conta = @v_Dv_Agencia_Conta, 
				@Operacao = @v_Operacao, 
				@Aplicabolsa_rfprinc= @v_aplicabolsaReveRFP

		END
   END


   RETURN  
   -- [FIM] Customização - Não escreva código após esta linha  
  END  
  