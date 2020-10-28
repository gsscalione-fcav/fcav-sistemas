  
ALTER PROCEDURE PRORROGA_DT_VENC_COBRANCA            
  @p_cobranca T_NUMERO,            
  @p_nova_data T_DATA            
AS            
-- [INÍCIO]            
  DECLARE @v_data_aux T_DATA            
  DECLARE @v_data_de_vencimento T_DATA            
  DECLARE @v_Errors varchar(8000)            
  DECLARE @v_ErrorsCount int            
  DECLARE @v_straux1 varchar(100)            
  DECLARE @aux_banco varchar (10)            
  DECLARE @v_desconto_cobranca T_VALOR_INTEIRO          
  DECLARE @v_dt_venc_desc T_DATA          
  DECLARE @v_dif_data T_NUMERO          
  DECLARE @v_count    T_NUMERO        
  DECLARE @v_substitui T_SIMNAO        
        
  DECLARE @v_prorroga_cancel_boleto VARCHAR(1)        
  DECLARE @v_banco T_NUMERO_PEQUENO        
  DECLARE @v_agencia T_ALFASMALL        
  DECLARE @v_conta_banco T_ALFASMALL        
  DECLARE @v_boleto T_NUMERO        
  DECLARE @v_carteira T_ALFASMALL        
  DECLARE @v_convenio T_CODIGO        
  DECLARE @v_lote T_NUMERO        
  DECLARE @v_resp T_CODIGO        
  DECLARE @v_sessao_id VARCHAR(40)        
          
  DECLARE @v_banco_ativo T_SIMNAO        
  DECLARE @v_local_origem VARCHAR(40)           
  DECLARE @v_total_conta INT        
  DECLARE @v_ValorTotal  T_DECIMAL_MEDIO        
          
  DECLARE @Faculdade    T_CODIGO        
  DECLARE @Curso     T_CODIGO        
  DECLARE @DebCob     T_NUMERO        
  DECLARE @Opcao     T_NUMERO        
  DECLARE @Ano      T_ANO         
  DECLARE @Periodo     T_SEMESTRE2        
  DECLARE @v_CriarCobProrrogacao as varchar(1)        
  DECLARE @V_BOLETO_AUX    T_NUMERO        
  DECLARE @v_aluno     T_CODIGO        
  DECLARE @v_Lanc_Cred    T_NUMERO  
          
  DECLARE @v_sessao_id_Aux  T_NUMERO          
  DECLARE @v_sessao_id_str_Aux VARCHAR(40)         
    
  DECLARE @v_lanc_deb T_NUMERO  
  DECLARE @v_concurso T_CODIGO  
  DECLARE @v_candidato T_CODIGO  
    
  EXEC s_PRORROGA_DT_VENC_COBRANCA @p_cobranca,            
       @p_nova_data,        
       @v_substitui output        
                      
  IF @v_substitui = 'S'         
      RETURN    
    
  SELECT @v_banco = T3.BANCO, @v_agencia = T3.AGENCIA, @v_conta_banco = T3.CONTA_BANCO,        
         @v_boleto = T3.BOLETO, @v_carteira = T3.CARTEIRA, @v_convenio = T3.CONVENIO,        
         @v_lote = T3.LOTE, @v_resp = T3.RESP        
  FROM LY_ITEM_LANC T1, LY_COBRANCA T2, LY_BOLETO T3        
  WHERE T1.COBRANCA = T2.COBRANCA        
  AND T1.BOLETO = T3.BOLETO        
  AND T2.COBRANCA = @p_cobranca 


            
  -------------------------------------------------------------------              
  -- Verifica se cancela boleto e cria um novo        
  -------------------------------------------------------------------                 
  SELECT @v_prorroga_cancel_boleto = PRORROGA_CANCEL_BOLETO         
  FROM LY_OPCOES_BOLETO        
  WHERE BANCO = @v_banco        
  AND AGENCIA = @v_agencia        
  AND CONTA_BANCO = @v_conta_banco      

  IF ISNULL(@v_prorroga_cancel_boleto,'N') = 'N'
    BEGIN	      
	  ----       
	  ----------------------------------------------------------------            
	  -- INICIO - VALIDAÇÃO REGISTRO DE BOLETO  
	  -- Não deixar alterar a data se a carteira for registrada e   
	  -- não for registro via plugin (job/tela)   
	  -- e o banco não tiver na tabela geral do hades  
	  -- e o boleto já tiver sido enviado para registro  
	  ----------------------------------------------------------------  
	  --verifica se a carteira é registrada  
	  IF EXISTS (select top 1 1 from LY_OPCOES_BOLETO o where o.banco = @v_banco and o.AGENCIA = @v_agencia and o.CONTA_BANCO = @v_conta_banco  
				and o.CARTEIRA = @v_carteira and o.ARQUIVO_COBRANCA = 'Registrada')   
	     AND EXISTS (select top 1 1 from ly_boleto where enviado = 'S' and boleto = @v_boleto) --e o boleto já foi enviado para registro  
	    BEGIN    
	      --verifica se o tipo da cobrança é registrado por plugin ou arquido de remessa  
  
		 DECLARE @v_contexto_boleto VARCHAR(100)  
		 -- VERIFICA SE CONTEXTO DO BOLETO É MATRICULA  
		 SET @v_contexto_boleto = (SELECT TOP 1 'Matricula' FROM LY_BOLETO B  
		  WITH(NOLOCK)  
		  INNER JOIN LY_ITEM_LANC IL ON B.BOLETO = IL.BOLETO  
		  INNER JOIN LY_COBRANCA C ON IL.COBRANCA = C.COBRANCA  
		 WHERE C.NUM_COBRANCA = 1 AND IL.PARCELA = 1  
		  -- E NÃO TEM NENHUMA PARCELA MAIOR QUE 1  
		  AND NOT EXISTS (SELECT TOP 1 1 FROM LY_ITEM_LANC IL2 WHERE IL2.BOLETO = B.BOLETO AND IL2.PARCELA > 1)  
		  AND B.BOLETO = @v_boleto)  
  
		 -- SE NÃO FOR MATRICULA, VERIFICA O CONTEXTO PELA NUM_COBRANCA ASSOCIADA AO BOLETO  
		 IF (@v_contexto_boleto IS NULL)  
		 BEGIN    SET @v_contexto_boleto = (SELECT TOP 1 CASE c.NUM_COBRANCA WHEN 1 THEN 'Mensalidade'   
					   WHEN 2 THEN 'Servico'   
					   WHEN 3 THEN 'Acordo'   
					   WHEN 4 THEN 'Outros'   
					   WHEN 5 THEN 'Cheque'  
					   END AS Contexto  
				FROM LY_BOLETO b  
				WITH(NOLOCK)  
				INNER JOIN LY_ITEM_LANC il ON il.BOLETO = b.BOLETO  
				INNER JOIN LY_COBRANCA c ON c.COBRANCA = il.COBRANCA  
				WHERE b.BOLETO = @v_boleto)  
		 END  
    
		  --verifica se este tipo de cobrança está configurado para usar plugin ou não  
		 DECLARE @v_chave_config_boleto T_NUMERO   
		 DECLARE @v_usaPlugin T_SIMNAO   
		 SET @v_usaPlugin = 'N'  
  
		 SELECT @v_chave_config_boleto = CHAVE FROM LY_CONFIGURACAO WHERE CONFIGURACAO = 'configGatewayBoleto'  
  
		 IF ( @v_contexto_boleto = 'Matricula' ) -- SE FOR BOLETO DE MATRICULA  
		 BEGIN  
		  -- OBTEM CONFIGURAÇÕES  
		  SELECT @v_usaPlugin = CAST(ISNULL(VALOR_TEXTO, 'N') AS CHAR(1)) FROM LY_PARAM_CONFIGURACAO WHERE CHAVE = @v_chave_config_boleto AND NOME = 'matriculaUsaPlugin';  
		 END  
		 ELSE IF ( @v_contexto_boleto = 'Mensalidade' ) -- SE FOR BOLETO DE MENSALIDADE  
		 BEGIN  
		  -- OBTEM CONFIGURAÇÕES  
		  SELECT @v_usaPlugin = CAST(ISNULL(VALOR_TEXTO, 'N') AS CHAR(1)) FROM LY_PARAM_CONFIGURACAO WHERE CHAVE = @v_chave_config_boleto AND NOME = 'mensalidadeUsaPlugin';   
		 END  
		 ELSE IF ( @v_contexto_boleto = 'Servico' ) -- SE FOR BOLETO DE SERVIÇO  
		 BEGIN  
		  -- OBTEM CONFIGURAÇÕES  
		  SELECT @v_usaPlugin = CAST(ISNULL(VALOR_TEXTO, 'N') AS CHAR(1)) FROM LY_PARAM_CONFIGURACAO WHERE CHAVE = @v_chave_config_boleto AND NOME = 'servicoUsaPlugin';  
		 END  
		 ELSE IF ( @v_contexto_boleto = 'Acordo' ) -- SE FOR BOLETO DE ACORDO  
		 BEGIN  
		  -- OBTEM CONFIGURAÇÕES  
		  SELECT @v_usaPlugin = CAST(ISNULL(VALOR_TEXTO, 'N') AS CHAR(1)) FROM LY_PARAM_CONFIGURACAO WHERE CHAVE = @v_chave_config_boleto AND NOME = 'acordoUsaPlugin';    
		 END  
		 ELSE IF ( @v_contexto_boleto = 'Cheque' ) -- SE FOR BOELTO DE CHEQUE  
		 BEGIN  
		  -- OBTEM CONFIGURAÇÕES  
		  SELECT @v_usaPlugin = CAST(ISNULL(VALOR_TEXTO, 'N') AS CHAR(1)) FROM LY_PARAM_CONFIGURACAO WHERE CHAVE = @v_chave_config_boleto AND NOME = 'chequeUsaPlugin';  
		 END  
		 ELSE IF ( @v_contexto_boleto = 'Outros' ) -- SE FOR BOLETO DE OUTROS  
		 BEGIN  
		  -- OBTEM CONFIGURAÇÕES  
		  SELECT @v_usaPlugin = CAST(ISNULL(VALOR_TEXTO, 'N') AS CHAR(1)) FROM LY_PARAM_CONFIGURACAO WHERE CHAVE = @v_chave_config_boleto AND NOME = 'outrosUsaPlugin';  
		 END    
   
		 IF ISNULL(@v_usaPlugin,'N') = 'N'     
		 BEGIN  
		  --VERIFICA SE O BANCO ESTÁ IMPLEMENTADO PARA FAZER ALTERAÇÃO VIA ARQUIVO DE REMESSA QUE DEVE SER CUSTOMIZAÇÃO  
		  IF NOT EXISTS (SELECT 1 FROM ITEMTABELA WHERE TAB = 'EnviaBancoCobAltVenc' AND ITEM = CONVERT(VARCHAR(20),@v_banco))  
		  BEGIN  
			SELECT @v_Errors = ' Não é possível alterar a data da cobrança pois existe boleto já registrado e a alteração não está disponível para o banco ' + CONVERT(VARCHAR(20),@v_banco) + '.'  
			EXEC SetErro @v_Errors                     
		   RETURN      
		  END  -- IF NOT EXISTS (SELECT 1 FROM ITEMTABELA WHERE TAB = 'EnviaBancoCobAltVenc' AND ITEM = CONVERT(VARCHAR(20),@v_banco))  
		 END -- IF ISNULL(@v_usaPlugin,'N') = 'N'         
	    END  -- IF EXISTS (select top 1 1 from LY_OPCOES_BOLETO o where o.banco = @v_banco and o.AGENCIA = @v_agencia and o.CONTA_BANCO = @v_conta_banco       
	  ----------------------------------------------------------------            
	  -- FIM - VALIDAÇÃO REGISTRO DE BOLETO  
	  ----------------------------------------------------------------  
    END -- IF ISNULL(@v_prorroga_cancel_boleto,'N') = 'N'
	        
  EXEC GET_CONNECT_ID @v_sessao_id_Aux output          
  SELECT @v_sessao_id_str_Aux = CONVERT(VARCHAR(40), @v_sessao_id_Aux)  
              
  EXEC tipobanco @aux_banco OUTPUT            
        
  ----------------------------------------------------------------            
  -- Essa procedure prorroga a data de vencimento de uma cobrança            
  ----------------------------------------------------------------            
  EXEC GetDataDiaSemHora @v_data_aux output            
            
  BEGIN TRAN Acerta_Cobranca            
  SAVE TRAN Acerta_Cobranca            
            
            
  SELECT @v_data_de_vencimento = DATA_DE_VENCIMENTO            
  FROM LY_COBRANCA            
  WHERE COBRANCA = @p_cobranca            
          
  -------------------------------------------------------------              
  --Verifica se a cobrança pertence a uma boletão        
  -------------------------------------------------------------         
  SELECT @v_count = ISNULL(COUNT(*),0)        
  FROM LY_COBRANCA_BOLETO, LY_BOLETO        
  WHERE LY_COBRANCA_BOLETO.BOLETO = LY_BOLETO.BOLETO        
   AND LY_COBRANCA_BOLETO.COBRANCA = @p_cobranca        
   AND REMOVIDO <> 'S'        
        
  IF @v_count > 0        
    BEGIN        
      SET @v_straux1 = CONVERT(VARCHAR(50),@p_cobranca)              
      SELECT @v_Errors = 'A cobrança ' + @v_straux1  + ' não pode ser prorrogada porque pertence a um boleto cumulativo.'            
      EXEC SetErro @v_Errors, 'COBRANCA'              
      EXEC GetErros @v_Errors output              
      ROLLBACK TRANSACTION Acerta_Cobranca              
      if @aux_banco = 'SQL'              
       COMMIT TRAN Acerta_Cobranca              
      EXEC SetErro @v_Errors              
      RETURN            
    END        
            
  -------------------------------------------------------------              
  --Verifica se a cobrança foi PRÉ-ACORDADA        
  -------------------------------------------------------------         
  SELECT @v_count = ISNULL(COUNT(*),0)        
    FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO        
   WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO        
     AND COBRANCA = @p_cobranca        
     AND CANCELADO = 'N'        
        
  IF @v_count > 0        
    BEGIN        
      SET @v_straux1 = CONVERT(VARCHAR(50),@p_cobranca)              
      SELECT @v_Errors = 'A cobrança ' + @v_straux1  + ' não pode ser prorrogada porque foi pré-acordada!'            
      EXEC SetErro @v_Errors, 'COBRANCA'              
      EXEC GetErros @v_Errors output              
      ROLLBACK TRANSACTION Acerta_Cobranca              
      if @aux_banco = 'SQL'              
       COMMIT TRAN Acerta_Cobranca              
      EXEC SetErro @v_Errors              
      RETURN            
    END        
          
  -------------------------------------------------------------              
  --Verifica se a cobrança está marcada como PROTESTO              
  -------------------------------------------------------------            
  SELECT @v_count = COUNT(1) FROM LY_COBRANCA         
  WHERE PROTESTO = 'S'         
  AND DATA_DE_PROTESTO IS NOT NULL         
  AND DATA_CANC_PROTESTO IS NULL        
  AND COBRANCA = @p_cobranca        
          
  IF @v_count > 0         
    BEGIN              
      SET @v_straux1 = CONVERT(VARCHAR(50),@p_cobranca)              
      SELECT @v_Errors = 'A cobrança ' + @v_straux1  + ' não pode ser prorrogada porque foi protestada.'            
      EXEC SetErro @v_Errors, 'COBRANCA'              
      EXEC GetErros @v_Errors output              
      ROLLBACK TRANSACTION Acerta_Cobranca              
      if @aux_banco = 'SQL'              
       COMMIT TRAN Acerta_Cobranca              
      EXEC SetErro @v_Errors              
      RETURN              
    END          
          
  -------------------------------------------------------------            
  --Verifica se a nova data da cobrança é inferior à data atual            
  -------------------------------------------------------------            
  IF @p_nova_data < @v_data_aux            
    BEGIN            
      SET @v_straux1 = CONVERT(VARCHAR(50),@p_cobranca)            
      SELECT @v_Errors = 'A cobrança ' + @v_straux1  + ' não pode ser prorrogada para uma data inferior à data atual.'            
      EXEC SetErro @v_Errors, 'COBRANCA'            
      SELECT @v_Errors = 'Ela dever ser prorrogada para uma data maior que a data atual ou igual.'            
      EXEC SetErro @v_Errors, 'COBRANCA'            
      EXEC GetErros @v_Errors output            
      ROLLBACK TRANSACTION Acerta_Cobranca            
      if @aux_banco = 'SQL'            
       COMMIT TRAN Acerta_Cobranca            
      EXEC SetErro @v_Errors            
      RETURN            
    END            
            
  -----------------------------------------------------------------            
  --Verifica se a nova data da cobrança é maior que a data anterior            
  -----------------------------------------------------------------            
  IF @p_nova_data <= @v_data_de_vencimento            
    BEGIN            
      SET @v_straux1 = CONVERT(VARCHAR(50),@p_cobranca)            
      SELECT @v_Errors = 'A cobrança ' + @v_straux1  + ' não pode ser prorrogada para uma data inferior ou igual à data da cobrança .'            
      EXEC SetErro @v_Errors, 'COBRANCA'            
      SELECT @v_Errors = 'Ela dever ser prorrogada para uma data maior que a data da cobrança'            
      EXEC SetErro @v_Errors, 'COBRANCA'            
      EXEC GetErros @v_Errors output            
      ROLLBACK TRANSACTION Acerta_Cobranca            
      if @aux_banco = 'SQL'            
       COMMIT TRAN Acerta_Cobranca            
      EXEC SetErro @v_Errors            
      RETURN            
    END            
        
  -------------------------------------------------------------------        
  -- Verifica se a cobrança a ser prorrogada já está paga          
  -------------------------------------------------------------------                  
  SELECT @v_ValorTotal=SUM(VALOR)         
  FROM VW_COBRANCA         
  WHERE COBRANCA=@p_cobranca         
    
  SELECT @V_BOLETO_AUX = 0  
  SELECT @V_BOLETO_AUX = ISNULL(BOLETO,0)  
  FROM LY_ITEM_LANC  
  WHERE COBRANCA=@p_cobranca  
  AND BOLETO IS NOT NULL  
    
  IF @V_BOLETO_AUX <> 0  
 BEGIN  
  SELECT @v_Lanc_Cred = 0  
  SELECT @v_Lanc_Cred = ISNULL(LANC_CRED,0)  
  FROM LY_LANC_CREDITO  
  WHERE BOLETO = @V_BOLETO_AUX  
 END   
         
  IF (@v_ValorTotal = 0) or   
     (@v_ValorTotal > 0 AND @V_BOLETO_AUX = 0 AND EXISTS(SELECT 1 FROM LY_ITEM_CRED WHERE COBRANCA = @p_cobranca and not exists (SELECT 1 FROM VW_LANC_CREDITO_REMOVIDO WHERE VW_LANC_CREDITO_REMOVIDO.LANC_CRED = LY_ITEM_CRED.LANC_CRED))) or  
     (@v_ValorTotal > 0 AND @v_Lanc_Cred <> 0 AND EXISTS(SELECT 1 FROM LY_ITEM_CRED WHERE LANC_CRED = @v_Lanc_Cred and not exists (SELECT 1 FROM VW_LANC_CREDITO_REMOVIDO WHERE VW_LANC_CREDITO_REMOVIDO.LANC_CRED = LY_ITEM_CRED.LANC_CRED)))  
    BEGIN          
      SET @v_straux1 = CONVERT(VARCHAR(50),@p_cobranca)              
      SELECT @v_Errors = 'A cobrança ' + @v_straux1  + ' não pode ser prorrogada porque já está paga.'              
      EXEC SetErro @v_Errors, 'COBRANCA'              
      EXEC GetErros @v_Errors output              
      ROLLBACK TRANSACTION Acerta_Cobranca              
      if @aux_banco = 'SQL'              
       COMMIT TRAN Acerta_Cobranca              
      EXEC SetErro @v_Errors              
      RETURN              
    END        
            
            
  ---------------------------------------------------------------------------------------        
  -- Verifica se o boleto da cobrança, quando existir, tem mais de uma cobrança associada          
  ---------------------------------------------------------------------------------------                  
  SELECT @v_count = ISNULL(COUNT(DISTINCT COBRANCA),0)          
  FROM LY_ITEM_LANC IL        
  WHERE IL.BOLETO IS NOT NULL        
  AND IL.COBRANCA = @p_cobranca        
  AND EXISTS (SELECT 1 FROM LY_ITEM_LANC IL2 WHERE IL2.COBRANCA <> IL.COBRANCA AND IL2.BOLETO = IL.BOLETO)        
        
          
  IF @v_count > 0        
    BEGIN        
      SET @v_straux1 = CONVERT(VARCHAR(50),@p_cobranca)              
      SELECT @v_Errors = 'A cobrança ' + @v_straux1  + ' não pode ser prorrogada porque pertence a um boleto com várias cobranças!'            
      EXEC SetErro @v_Errors, 'COBRANCA'              
      EXEC GetErros @v_Errors output              
      ROLLBACK TRANSACTION Acerta_Cobranca              
      if @aux_banco = 'SQL'              
       COMMIT TRAN Acerta_Cobranca              
      EXEC SetErro @v_Errors              
      RETURN            
    END        
    
  SELECT @v_aluno = aluno         
  FROM ly_cobranca   
  WHERE cobranca = @p_cobranca   
              
  -- INICIO        
  -- Buscando a chave da tabela de opções financeiras que deverá ser utilizada         
  SELECT @Faculdade = faculdade, @Curso = ly_aluno.curso         
    FROM ly_aluno, ly_curso         
   WHERE ly_aluno.curso = ly_curso.curso         
     AND aluno = (Select aluno from ly_cobranca where cobranca = @p_cobranca)         
             
  SELECT @DebCob = Max(lanc_deb)         
    FROM ly_item_lanc, ly_cobranca         
   WHERE ly_item_lanc.cobranca = ly_cobranca.cobranca         
     AND ly_item_lanc.cobranca = @p_cobranca         
           
  SELECT @Ano = ano_ref, @Periodo = periodo_ref         
    FROM ly_lanc_debito         
   WHERE lanc_deb = @DebCob         
           
  SELECT @Opcao = NULL         
           
  SELECT @Opcao = Max(f.opcao)         
    FROM ly_opcoes_finan f, ly_opcoes_finan_curso fc         
   WHERE f.opcao = fc.opcao         
     AND ano = @Ano         
     AND periodo = @Periodo         
     AND faculdade = @Faculdade         
     AND curso = @Curso         
           
  IF @Opcao IS NULL         
    SELECT @Opcao = Max(f.opcao)         
      FROM ly_opcoes_finan f, ly_opcoes_finan_unid fc         
     WHERE f.opcao = fc.opcao         
       AND ano = @Ano         
       AND periodo = @Periodo         
       AND faculdade = @Faculdade         
       AND NOT EXISTS (SELECT 1         
                         FROM ly_opcoes_finan_curso         
                        WHERE opcao = fc.opcao         
                          AND faculdade = fc.faculdade)         
           
  IF @Opcao IS NULL         
    SELECT @Opcao = Max(opcao)         
      FROM ly_opcoes_finan o         
     WHERE ano = @Ano         
       AND periodo = @Periodo         
       AND NOT EXISTS (SELECT 1         
                         FROM ly_opcoes_finan_unid         
                        WHERE opcao = o.opcao)         
           
  IF @Opcao IS NULL         
    BEGIN        
  SELECT @v_Errors = 'Não foi encontrado nenhuma opção financeira.'            
  EXEC SetErro @v_Errors, 'COBRANCA'              
  EXEC GetErros @v_Errors output              
  ROLLBACK TRANSACTION Acerta_Cobranca              
  if @aux_banco = 'SQL'              
  COMMIT TRAN Acerta_Cobranca              
  EXEC SetErro @v_Errors              
  RETURN           
    END         
        
  -- FIM        
  -- Buscando a chave da tabela de opções financeiras que deverá ser utilizada         
  Select @v_CriarCobProrrogacao = IsNull(CRIAR_COB_PRORROGACAO,'N')        
  From LY_OPCOES_FINAN        
  Where opcao = @Opcao        
          
  if @v_CriarCobProrrogacao = 'S'        
    BEGIN       
          
             
          
      -- Realizará o processamento alternativo executando a procedure "PRORROGA_DT_VENC_NOVA_COB"        
      EXEC PRORROGA_DT_VENC_NOVA_COB @v_sessao_id_str_Aux,        
                                     @p_cobranca,            
                                     @p_nova_data,        
                                     @v_aluno       
          
      EXEC GetErrorsCount @v_ErrorsCount OUTPUT            
            
      IF @v_ErrorsCount  > 0            
        BEGIN            
          SET @v_straux1 = convert(varchar(50),@p_cobranca)            
          select @v_Errors = 'Erro ao prorrogara a data  de vencimento da cobrança ' + @v_straux1            
          EXEC SetErro @v_Errors, 'PRORROGA_DT_VENC_NOVA_COB'            
          EXEC GetErros @v_Errors output            
          ROLLBACK TRANSACTION Acerta_Cobranca            
          if @aux_banco = 'SQL'            
            COMMIT TRAN Acerta_Cobranca            
          EXEC SetErro @v_Errors            
          RETURN            
        END      
      ELSE    
        BEGIN    
          COMMIT TRAN Acerta_Cobranca    
          RETURN    
        END    
    END          
            
  
          
  -------------------------------------------------------------------              
  -- Remove o boleto da cobrança antes da prorrogação        
  -------------------------------------------------------------------        
  IF @v_prorroga_cancel_boleto = 'S'        
    BEGIN         
      -- VERIFICA SE A CONTA ESTÁ DESATIVADA        
      SELECT @v_banco_ativo = T2.ATIVO, @v_local_origem = T1.LOCAL_ORIGEM        
      FROM LY_CONTA_BANCO T1, LY_CONTA_CONVENIO T2        
      WHERE T1.BANCO = T2.BANCO AND T1.AGENCIA = T2.AGENCIA AND T1.CONTA_BANCO = T2.CONTA_BANCO        
      AND T1.BANCO = @v_banco        
      AND T1.AGENCIA = @v_agencia        
      AND T1.CONTA_BANCO = @v_conta_banco        
      AND T2.CARTEIRA = @v_carteira        
      AND T2.CONVENIO = @v_convenio        
        
      -- SE A CONTA ESTIVER DESATIVADO, PESQUISA CONTA/BANCO/AGENCIA ATIVO PARA O MESMO LOCAL DE ORIGEM DO BOLETO        
      IF @v_banco_ativo = 'N'        
        BEGIN        
          SET @v_total_conta = 0         
          SELECT @v_total_conta = ISNULL(COUNT(T1.BANCO),0)        
          FROM LY_CONTA_BANCO T1, LY_CONTA_CONVENIO T2        
          WHERE T1.BANCO = T2.BANCO AND T1.AGENCIA = T2.AGENCIA AND T1.CONTA_BANCO = T2.CONTA_BANCO        
          AND T1.LOCAL_ORIGEM = @v_local_origem        
          AND T2.ATIVO = 'S'        
                    
          IF @v_total_conta = 1          
            BEGIN         
              SELECT @v_banco = T1.BANCO, @v_agencia = T1.AGENCIA, @v_conta_banco = T1.CONTA_BANCO,        
                     @v_carteira = T2.CARTEIRA, @v_convenio = T2.CONVENIO        
              FROM LY_CONTA_BANCO T1, LY_CONTA_CONVENIO T2        
              WHERE T1.BANCO = T2.BANCO AND T1.AGENCIA = T2.AGENCIA AND T1.CONTA_BANCO = T2.CONTA_BANCO        
              AND T1.LOCAL_ORIGEM = @v_local_origem        
              AND T2.ATIVO = 'S'           
            END          
          ELSE        
            BEGIN        
              IF @v_total_conta = 0 OR @v_total_conta > 1          
                BEGIN         
                 SELECT @v_Errors = 'Prorrogação não permitida! Favor remover/faturar/gerar boleto!'            
                  EXEC SetErro @v_Errors, 'CONTA_BANCO'            
                  EXEC GetErros @v_Errors output            
                  ROLLBACK TRANSACTION Acerta_Cobranca            
                  IF @aux_banco = 'SQL'            
                    COMMIT TRAN Acerta_Cobranca            
                    EXEC SetErro @v_Errors            
                    RETURN        
                END        
            END        
        END        
         
      -- REMOVE O BOLETO        
      EXEC REMOVE_BOLETO @v_boleto        
    END        
        
            
  -------------------------------------------------------------------            
  -- Executa a alteração da data de vencimento da cobrança            
  -------------------------------------------------------------------            
  EXEC LY_COBRANCA_Update @pkCobranca = @p_cobranca, @Data_de_vencimento = @p_nova_data            
            
  EXEC GetErrorsCount @v_ErrorsCount OUTPUT            
            
  IF @v_ErrorsCount  > 0            
    BEGIN            
      SET @v_straux1 = convert(varchar(50),@p_cobranca)            
      select @v_Errors = 'Erro ao alterar a data de vencimento da cobranca ' + @v_straux1            
      EXEC SetErro @v_Errors, 'DATA_DE_VENCIMENTO'            
      EXEC GetErros @v_Errors output            
      ROLLBACK TRANSACTION Acerta_Cobranca            
      if @aux_banco = 'SQL'            
       COMMIT TRAN Acerta_Cobranca            
      EXEC SetErro @v_Errors            
 RETURN            
    END            
            
  -------------------------------------------------------------------            
  -- Executa a alteração das datas das faixas de desconto           
  -------------------------------------------------------------------            
  DECLARE C_DESCONTOS CURSOR FOR          
    SELECT DESCONTO_COBRANCA, DT_VENC_DESC          
    FROM LY_DESCONTO_COBRANCA          
    WHERE COBRANCA = @p_cobranca          
          
          
  OPEN C_DESCONTOS          
  FETCH NEXT FROM C_DESCONTOS INTO @v_desconto_cobranca, @v_dt_venc_desc          
  WHILE (@@fetch_status = 0 )          
    BEGIN          
        
      SELECT @v_dif_data = datediff(day, @v_data_de_vencimento, @v_dt_venc_desc)          
         
      IF @v_dif_data > 0        
        select @v_dif_data = 0         
                
      SELECT @v_dt_venc_desc = dateadd(day, @v_dif_data, @p_nova_data)        
          
      EXEC LY_DESCONTO_COBRANCA_Update @pkCobranca = @p_cobranca          
                                       , @pkDesconto_cobranca = @v_desconto_cobranca          
                                       , @dt_venc_desc = @v_dt_venc_desc          
          
        
      EXEC GetErrorsCount @v_ErrorsCount output        
      IF @v_ErrorsCount > 0          
        BEGIN          
          SET @v_straux1 = CONVERT(VARCHAR(50),@p_cobranca)          
          EXEC SetErro 'Erro atualizando faixas de desconto',''          
          EXEC GetErros @v_Errors output          
          ROLLBACK TRANSACTION Acerta_Cobranca          
          if @aux_banco = 'SQL'          
           COMMIT TRAN Acerta_Cobranca          
          EXEC SetErro @v_Errors          
          CLOSE C_DESCONTOS          
          DEALLOCATE C_DESCONTOS          
          RETURN          
        END          
          
      FETCH NEXT FROM C_DESCONTOS INTO @v_desconto_cobranca, @v_dt_venc_desc          
          
    END          
          
    CLOSE C_DESCONTOS          
    DEALLOCATE C_DESCONTOS          
            
    -------------------------------------------------------------------              
    -- Cria um novo boleto        
    -------------------------------------------------------------------        
    IF @v_prorroga_cancel_boleto = 'S'        
  BEGIN  
   DELETE FROM LY_ITENS_AUX WHERE SESSAO_ID = @v_sessao_id_str_Aux  
   INSERT INTO LY_ITENS_AUX (SESSAO_ID, CHAVE, VALOR, DESCRICAO, DT_VENC, COBRANCA, ITEMCOBRANCA, PARCELA, ACORDO, VALOR_DESCONTO)     
       VALUES (@v_sessao_id_str_Aux, 1, 0, 'Prorroga data de vencimento-Processo seletivo', @p_nova_data, @p_cobranca, null, null, null, null)  
     
   EXEC GERA_BOLETO_RESP @v_sessao_id_str_Aux, @v_banco, @v_agencia, @v_conta_banco, @v_convenio,        
        @v_carteira, @v_resp, 'N', @p_nova_data, 'S', null, 'N', 'N', 'S', null, null, 'S'        
  END        
       
 IF @v_Aluno = 'ALUNO_CANDIDATO'       
    BEGIN    
   SELECT @v_lanc_deb = 0  
   SELECT @v_lanc_deb = LANC_DEB    
   FROM LY_ITEM_LANC    
   WHERE COBRANCA = @p_COBRANCA     
          
   SELECT @v_concurso = ''    
   SELECT @v_candidato = ''    
   SELECT @v_concurso = concurso,    
    @v_candidato = candidato    
   FROM LY_LANC_DEBITO     
   WHERE LANC_DEB = @v_lanc_deb     
        
      IF @v_concurso <> '' AND @v_candidato <> ''    
     UPDATE LY_CANDIDATO    
     SET BOL_DT_VENC = @p_nova_data     
     WHERE CONCURSO = @v_concurso    
     AND CANDIDATO = @v_candidato    
    END --IF @v_Aluno = 'ALUNO_CANDIDATO'   
                
    EXEC a_PRORROGA_DT_VENC_COBRANCA @p_cobranca,            
                     @p_nova_data         
            
    COMMIT TRAN Acerta_Cobranca            
        
-- [FIM]     