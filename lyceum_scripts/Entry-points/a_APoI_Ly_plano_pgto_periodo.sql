--* ***************************************************************    
--*    
--*  *** PROCEDURE a_APoI_Ly_plano_pgto_periodo  ***    
--*     
--* DESCRICAO:    
--*  - EP chamada após a inserção do plano de pagmento período do aluno       
--*        
--*  - Adequações referentes ao plano de pagamento do aluno    
--*   
--*  
--* ALTERAÇÕES:  
--*  29/09/2017 - Após virada de versão do Lyceum, foi incluido mais um campo na tabela de Bolsa  
--*      BOLSA_PROMOCIONAL, por conta disso as bolsas não estavam sendo incluídas.  
--*      Ajuste já realizado. Gabriel S. Scalione  
--*    
  
--* ***************************************************************      
ALTER PROCEDURE a_APoI_Ly_plano_pgto_periodo @resp varchar(20), @ano numeric(4),   
@periodo numeric(2), @aluno varchar(20), @planopag varchar(20),@ano_inicial numeric(4),   
@mes_inicial numeric(3), @dia_vencimento numeric(3), @desc_perc_valor varchar(15),  
@desconto numeric(14, 6), @percententrada numeric(7, 4), @num_parcelas numeric(3),  
@percent_divida_aluno numeric(7, 4), @dt_ult_alt datetime, @aplicabolsa varchar(1),  
@aparece_extrato_aluno varchar(1), @outras_dividas varchar(1), @impr_bol_matr_web varchar(1),  
@serie numeric(3), @num_parcelas_insc numeric(3), @fiador varchar(20), @banco numeric(3),  
@agencia varchar(15), @conta_banco varchar(15), @dv_agencia varchar(15), @dv_conta varchar(15),  
@dv_agencia_conta varchar(15), @operacao numeric(3), @rateia_restante_divida varchar(1)  
AS  
 -- [INÍCIO] Customização - Não escreva código antes desta linha        
  
	 UPDATE LY_PLANO_PGTO_PERIODO  
	 SET DESC_PERC_VALOR = DP.DESC_PERC_VALOR,  
	  DESCONTO = DP.DESCONTO  
	 FROM LY_PLANO_PGTO_PERIODO P  
	 JOIN LY_ALUNO A  
	  ON P.ALUNO = A.ALUNO  
	 JOIN LY_DESCONTO_PLANO_PGTO DP  
	  ON A.CURSO = DP.CURSO  
	  AND A.TURNO = DP.TURNO  
	  AND A.CURRICULO = DP.CURRICULO  
	  AND A.CONCURSO = DP.CONCURSO  
	  AND P.NUM_PARCELAS = DP.NUM_PARCELAS  
	 WHERE P.OUTRAS_DIVIDAS = 'S'  
	 AND P.ANO = @ano  
	 AND P.PERIODO = @periodo  
	 AND P.ALUNO = @aluno  
	 AND P.RESP = @resp  
	 AND P.NUM_PARCELAS = @num_parcelas  
  
  
	 --------------------------------------------------------------------------------------  
	 -- VALIDAÇÃO DE INSERÇÃO DE BOLSA DE ESTUDOS DE ACORDO COM O CURSO E CONCURSO DO ALUNO        
	 DECLARE @v_tipo_bolsa T_CODIGO,  
	   @v_concurso T_CODIGO,  
	   @v_valor_maximo T_DECIMAL_MEDIO_PRECISO6,  
	   @v_dt_ingresso T_DATA,  
	   @num_bolsa numeric  
  
	 SELECT  
	  @v_concurso = FL_FIELD_22,  
	  @v_tipo_bolsa = FL_FIELD_24,  
	  @v_dt_ingresso = A.DT_INGRESSO  
	 FROM LY_FL_PESSOA P  
	 JOIN LY_ALUNO A  
	  ON A.PESSOA = P.PESSOA  
	 WHERE A.ALUNO = @aluno  
	 AND FL_FIELD_22 = A.CONCURSO  
	 AND FL_FIELD_24 IS NOT NULL  
   
	 -----------------------------------------------------------  
	 /*VERIFICA O NÚMERO DE BOLSA E SOMA MAIS UM.    */  
	 SELECT @num_bolsa = ISNULL(COUNT(NUM_BOLSA),0)+1 FROM LY_BOLSA WHERE ALUNO = @aluno  
   
	 -----------------------------------------------------------  
	 /*Ano e Mês de inicio da Bolsa.        */  
		SELECT   
		  @ano_inicial = ISNULL(AL.ANO_INGRESSO, oc.ANO_INGRESSO),  
		  @mes_inicial = PO.MES_INICIAL
		 FROM  
		  LY_ALUNO AL  
		  INNER JOIN LY_OFERTA_CURSO OC  
		   ON OC.CONCURSO = AL.CONCURSO  
		  INNER JOIN LY_PLANOS_OFERTADOS PO  
		   ON PO.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO  
		 WHERE ALUNO = @aluno  
   
   
	 -----------------------------------------------------------  
	 /*INSERE A BOLSA PARA ALUNO CONFORME CADASTRO NA PESSOA  */  
	 IF (@v_tipo_bolsa IS NOT NULL  
	  AND @v_concurso IS NOT NULL)  
	 BEGIN  
  
		  -- MARCA O APLICA A BOLSA NO PLANO DE PAGAMENTO DO ALUNO  
		  UPDATE LY_PLANO_PGTO_PERIODO  
		  SET   
		   APLICABOLSA = 'S'  
		  FROM LY_PLANO_PGTO_PERIODO P  
		  JOIN LY_ALUNO A  
		   ON A.ALUNO = P.ALUNO  
		  WHERE  
		   P.ALUNO = @aluno  
		   AND P.APLICABOLSA = 'N'  
     
  
		  SELECT  
		   @v_valor_maximo = CASE WHEN CONVERT(decimal(10, 2), VALOR_MAXIMO) > 100 THEN 1
						 ELSE CONVERT(decimal(10, 2), VALOR_MAXIMO) / 100
						 END
		  FROM LY_TIPO_BOLSA  
		  WHERE TIPO_BOLSA = @v_tipo_bolsa  
  
		  INSERT INTO LY_BOLSA (ALUNO, NUM_BOLSA, TIPO_BOLSA, PERC_VALOR, VALOR, MOTIVO, DTINI, DTFIM, ENTIDADE,  
		   MESINI, MESFIM, ANOINI, ANOFIM, DATA_BOLSA, DATA_ALT, DATA_CANCEL, MOTIVO_CANCEL, OBS, FL_FIELD_01,  
		   FL_FIELD_02, FL_FIELD_03, FL_FIELD_04, FL_FIELD_05, SERVICO, BOLSA_PROMOCAO)  
		   VALUES  
			( @aluno,							 --ALUNO  
			 @num_bolsa,						 --NUM_BOLSA  
			 @v_tipo_bolsa,						 --TIPO_BOLSA  
			 'Percentual',						 --PERC_VALOR  
			 isnull(@v_valor_maximo,0),			 --VALOR  
			 'Bolsa Concedida na Pré-matrícula', --MOTIVO  
			 NULL,								 --DTINI  
			 NULL,								 --DTFIM  
			 NULL,								 --ENTIDADE  
			 @mes_inicial,						 --MESINI  
			 NULL,								 --MESFIM  
			 @ano_inicial,						 --ANOINI  
			 NULL,								 --ANOFIM  
			 dbo.FN_DATADIASEMHORA(GETDATE()),   --DATA_BOLSA  
			 dbo.FN_DATADIASEMHORA(GETDATE()),   --DATA_ALT  
			 NULL,								 --DATA_CANCEL  
			 NULL,								 --MOTIVO_CANCEL  
			 NULL,								 --OBS  
			 NULL,								 --FL_FIELD_01  
			 NULL,								 --FL_FIELD_02  
			 NULL,								 --FL_FIELD_03  
			 NULL,								 --FL_FIELD_04  
			 NULL,								 --FL_FIELD_05  
			 NULL,								 --SERVICO  
			 NULL								 --BOLSA_PROMOCAO  
			 )  
  
	 END  
  
  
 RETURN