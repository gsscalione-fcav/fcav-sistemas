  
-- O parametro @p_Usa_Cobr_Pre_Selecionadas indica quais cobranças devem ser usadas para a geração do boleto:  
--  
--   -> Se for 'N' então serão selecionadas todas as cobranças do responsável financeiro com data de vencimento igual a informada.  
--  
--   -> Se for 'S' então serão usadas as cobranças previamente colocadas na tabela LY_ITENS_AUX. A função chamadora deve se  
--      responsabilizar em apagar e copiar as cobranças para LY_ITENS_AUX  
--  
-- Quando @p_Usa_Cobr_Pre_Selecionadas for S (sim) o parametro data de vencimento não fara sentido, pois a data de vencimento da  
-- cobrança será a data presente na tabela LY_ITENS_AUX  
ALTER PROCEDURE GERA_BOLETO_RESP          
  @p_sessao_id VARCHAR(40),          
  @p_Banco T_NUMERO_PEQUENO,          
  @p_Agencia T_ALFASMALL,          
  @p_Conta T_ALFASMALL,          
  @p_Convenio T_CODIGO,          
  @p_Carteira VARCHAR(10),          
  @p_Resp T_CODIGO,          
  @p_ApenasFaturar varchar(1),          
  @p_DtVenc T_DATA,          
  @p_Usa_Cobr_Pre_Selecionadas varchar(1) = 'N',          
  @p_Lote T_NUMERO = null,          
  @p_boleto_zerado varchar(1) = 'N',          
  @p_boleto_negativo varchar(1) = 'N',          
  @p_cobranca_com_nota varchar(1) = 'N',    
  @p_Apartir_Valor DECIMAL(14,6)=NULL,    
  @p_tipo_cobranca T_NUMERO_PEQUENO = NULL,    
  @p_online varchar(1) = 'S'    
AS          
-- [INÍCIO]          
  DECLARE @v_ValorCreditos T_DECIMAL_MEDIO              
  DECLARE @v_ValorCobranca T_DECIMAL_MEDIO              
  DECLARE @v_ValorBoleto T_DECIMAL_MEDIO              
  DECLARE @v_sBoleto VARCHAR(100)          
  DECLARE @v_NossoNumero T_NUMERO_GRANDE              
  DECLARE @v_sNNumero varchar(16)          
  DECLARE @v_ItemValor T_DECIMAL_MEDIO          
  DECLARE @v_ItemDescricao T_ALFALARGE          
  DECLARE @v_Instrucoes varchar(500)          
  DECLARE @v_Erro VARCHAR(1000)          
  DECLARE @v_ErrosCount INT          
  DECLARE @v_DVNN T_NUMERO          
  DECLARE @v_DebitoAutomaticoResp varchar(1)          
  DECLARE @v_DebitoAutomaticoAluno varchar(1)          
  DECLARE @v_DtFimDebAuto T_DATA          
  DECLARE @v_DtIniDebAuto T_DATA          
  DECLARE @v_Contador T_NUMERO          
  DECLARE @v_Cobranca T_NUMERO          
  DECLARE @v_BoletoUnico varchar(1)          
  DECLARE @v_Boleto T_NUMERO                     
  DECLARE @v_Erros_ID T_NUMERO          
  DECLARE @v_dt_venc T_DATA          
  DECLARE @v_dt_venc2 T_DATA          
          
  DECLARE @v_aux_str T_ALFALARGE          
  DECLARE @aux_dt T_DATA          
  DECLARE @v_cobranca_update T_NUMERO          
  DECLARE @v_itemcobranca_update T_NUMERO          
  DECLARE @v_lanc_cred_update T_NUMERO          
  DECLARE @v_itemcred_update T_NUMERO          
  DECLARE @v_data_faturamento T_DATA          
  DECLARE @v_id_instituicao T_CODIGO          
  DECLARE @v_id_inst_aux NUMERIC          
  DECLARE @v_count     T_NUMERO          
  DECLARE @v_straux1 varchar(100)          
  DECLARE @v_straux2 varchar(100)          
  DECLARE @v_straux3 varchar(100)          
  DECLARE @v_ItensBoleto T_NUMERO          
  DECLARE @v_apenas_cobranca T_SIMNAO          
  DECLARE @v_sAgencia varchar(100)          
  DECLARE @v_sAgenciaNN varchar(100)          
  DECLARE @v_Debaut_Banco T_NUMERO_PEQUENO          
  DECLARE @v_Debaut_Agencia T_ALFASMALL          
  DECLARE @v_Debaut_Conta_Banco T_ALFASMALL          
  DECLARE @v_Dv_Agencia T_ALFASMALL              
  DECLARE @v_Dv_Conta T_ALFASMALL            
  DECLARE @v_Dv_Agencia_Conta T_ALFASMALL               
  DECLARE @v_Operacao T_NUMERO_PEQUENO            
  DECLARE @v_resp T_CODIGO          
  DECLARE @v_ano T_ANO          
  DECLARE @v_periodo T_SEMESTRE2          
  DECLARE @v_aluno T_CODIGO          
  DECLARE @v_pgto_pre_exec varchar(1)           
  DECLARE @v_bol_acordo T_NUMERO           
  DECLARE @v_bco_gera_nn varchar(1)           
  DECLARE @v_tipocarteira T_ALFAMEDIUM          
  DECLARE @v_ValorFinalCobranca T_DECIMAL_MEDIO          
  DECLARE @v_num_cobranca T_NUMERO     
      
  DECLARE @v_numeroRPS numeric(12,0)    
  DECLARE @v_faculdade T_CODIGO    
  DECLARE @v_ValorServicoRPS T_DECIMAL_MEDIO    
  DECLARE @v_ValorDeducaoRPS T_DECIMAL_MEDIO     
  DECLARE @v_NotaFiscalSerie VARCHAR(5)    
  DECLARE @v_data_emissao_rps T_DATA      
  DECLARE @v_BolUnicoPessoa varchar(1)          
  DECLARE @v_PessoaResp T_NUMERO    
  DECLARE @v_PessoaAluno T_NUMERO    
  DECLARE @v_Tipo21 varchar(1)          
  DECLARE @v_empresa varchar(200)    
  DECLARE @v_aux_convenio_num NUMERIC          
  DECLARE @v_aux_convenio VARCHAR(28)          
  DECLARE @v_RetornoSP T_SIMNAO    
  DECLARE @v_MsgSP varchar(100)    
  DECLARE @v_Cont INT     
  DECLARE @v_Cobranca_PreAcordo T_NUMERO          
  DECLARE @v_Gera_Bol_Cobr_Zero T_SIMNAO    
  DECLARE @v_valor_update T_DECIMAL_MEDIO  
  DECLARE @v_Lanc_deb T_NUMERO    
  DECLARE @v_DebitoAutomatico varchar(1)  
  DECLARE @v_boletoParaRegistro T_NUMERO   
  DECLARE @V_DATA_VALIDADE T_DATA  
  DECLARE @V_PRAZO_BAIXA NUMERIC(2)  
  DECLARE @p_substitui_prazo T_SIMNAO  
  DECLARE @p_novo_prazo numeric(2)  
    
  if isnull(@p_online,'') <> 'N' set @p_online = 'S'    
    
         
  SELECT @v_BoletoUnico = BOLETO_UNICO,    
         @v_BolUnicoPessoa = BOL_UNICO_PESSOA,    
         @v_PessoaResp = PESSOA        
  , @v_DtFimDebAuto = DTFIM_DEB_AUTO      
  , @v_DtIniDebAuto = DTINI_DEB_AUTO       
  FROM LY_RESP_FINAN       
  WHERE RESP = @p_Resp          
          
  SELECT @v_bco_gera_nn = NOSSO_NUMERO_BANCO          
  FROM LY_CONTA_CONVENIO          
  WHERE BANCO = @p_Banco          
  AND AGENCIA = @p_Agencia          
  AND CONTA_BANCO = @p_Conta          
  AND CONVENIO = @p_Convenio   
  AND CARTEIRA = @p_Carteira            
      
  IF Charindex('-',@p_Convenio) = 0  and  Charindex('A',@p_Convenio) = 0 and Charindex('B',@p_Convenio) = 0    
    BEGIN    
      select @v_aux_convenio_num = convert(numeric(20),@p_Convenio)    
      select @v_aux_convenio = convert(varchar(28),@v_aux_convenio_num)    
    END    
  ELSE    
    SELECT @v_aux_convenio = @p_Convenio    
    
            
  SET @v_DebitoAutomaticoResp = 'N'      
      
  IF @v_DtIniDebAuto IS NOT NULL           
  BEGIN          
    IF @v_DtFimDebAuto IS NULL          
    BEGIN          
      IF @p_DtVenc >= @v_DtIniDebAuto SELECT @v_DebitoAutomaticoResp = 'S'          
      ELSE SELECT @v_DebitoAutomaticoResp = 'N'          
    END          
      
    ELSE          
    BEGIN          
      IF @p_DtVenc >= @v_DtIniDebAuto AND @p_DtVenc <= @v_DtFimDebAuto          
        SELECT @v_DebitoAutomaticoResp = 'S'         
      ELSE          
        SELECT @v_DebitoAutomaticoResp = 'N'          
    END          
  END                  
            
  EXEC GET_ERROR_ID @v_Erros_ID          
  IF @v_Erros_ID <> 0          
  BEGIN          
    SELECT @v_Erro = 'Erro ao obter os dados bancários do responsável financeiro: ' + @p_Resp              
    EXEC SetErro @v_Erro, 'RESP'          
    RETURN          
  END          
      
  -------------------------------------------------    
  -- CHAMADA DO ENTRY-POINT a_Gera_Boleto_Cob_Zero    
  -- ----------------------------------------------    
  EXEC a_Gera_Boleto_Cob_Zero @p_Resp,     
                              @v_Gera_Bol_Cobr_Zero OUTPUT    
    
  ---------------------------------------------    
  -- REMOVE OS REGISTROS COM O MESMO SESSAO_ID    
  -- ------------------------------------------    
  DELETE FROM LY_ALU_BLOQUEIA_BOLETO WHERE SESSAO_ID = @p_sessao_id    
    
  ---------------------------------------------    
  -- CHAMADA DO ENTRY-POINT S_GERA_BOLETO_RESP    
  -- ------------------------------------------    
  EXEC s_GERA_BOLETO_RESP @p_sessao_id,    
       @p_Banco,    
       @p_Agencia,    
       @p_Conta,    
       @p_Convenio,    
       @p_Carteira,    
       @p_Resp,    
       @p_DtVenc,    
       @p_ApenasFaturar,    
       @v_RetornoSP OUTPUT,      
       @v_MsgSP OUTPUT       
           
  IF @v_RetornoSP = 'N'    
 BEGIN          
  EXEC SetErro @v_MsgSP, 'BOLETO'          
  RETURN          
 END             
      
  IF @p_ApenasFaturar = 'S'           
  BEGIN          
    -- -----------------------------------------------------------------------------          
    --  Apenas faturar, não gerar boleto, então apenas atualiza DATA_DE_VENCIMENTO          
    -- -----------------------------------------------------------------------------          
    IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
    BEGIN          
      declare c_LY_COBRANCA_1 cursor for          
  SELECT cobranca   
  FROM   ly_cobranca   
  WHERE  resp = @p_Resp   
      AND data_de_vencimento = @p_DtVenc   
      AND data_de_faturamento IS NULL   
      AND ( ( @p_tipo_cobranca IS NOT NULL   
        AND num_cobranca = @p_tipo_cobranca )   
       OR @p_tipo_cobranca IS NULL )   
      AND ( @p_cobranca_com_nota = 'S'   
       OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  dt_canc IS NULL  
            AND ly_cobranca.cobranca = ly_nota_promissoria.cobranca ) )    
    
      open c_LY_COBRANCA_1          
      fetch next from c_LY_COBRANCA_1 into @v_cobranca_update          
          
      while (@@fetch_status = 0)          
      BEGIN          
    
        -- VERIFICA SE A COBRANÇA FOI PRÉ-ACORDADA    
        SELECT @v_Cont = ISNULL(COUNT(*),0)    
          FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO    
         WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO    
           AND COBRANCA = @v_cobranca_update    
           AND CANCELADO = 'N'    
    
        IF @v_Cont > 0    
          BEGIN    
            SET @v_straux1 = CONVERT(VARCHAR(20),@v_cobranca_update)    
            SET @v_Erro = 'A cobrança ' + @v_straux1 + ' não pode ser faturada porque foi pré-acordada!'    
            EXEC SetErro @v_Erro, 'COBRANCA'    
            CLOSE c_LY_COBRANCA_1          
            DEALLOCATE c_LY_COBRANCA_1    
            RETURN      
          END    
    
        EXEC GetDataDiaSemHora @aux_dt output          
        EXEC LY_COBRANCA_Update @pkCobranca = @v_cobranca_update,@Data_de_faturamento = @aux_dt          
        EXEC GetErrorsCount @v_ErrosCount OUTPUT          
              
        IF @v_ErrosCount  > 0          
        BEGIN          
          SET @v_straux1 = convert(varchar(50),@v_cobranca_update)          
          SELECT @v_Erro = 'Erro ao atualizar a data de faturamento da cobranca ' + @v_straux1          
          EXEC SetErro @v_Erro, 'DATA_DE_FATURAMENTO'          
          CLOSE c_LY_COBRANCA_1          
          DEALLOCATE c_LY_COBRANCA_1          
          RETURN          
        END          
  
        -- Inserção no contador para que o processo possa controlar o log para responsáveis que somente falturam as cobranças  
        SET @v_count = 0          
        SELECT @v_count = isnull(count(*),0) FROM  LY_AUX_CONTADOR WHERE SESSAO_ID = @p_sessao_id          
                         
        IF @v_count > 0          
          BEGIN          
            SELECT @v_count = CONTADOR FROM LY_AUX_CONTADOR WHERE SESSAO_ID = @p_sessao_id          
            SET @v_count = @v_count + 1          
            EXEC LY_AUX_CONTADOR_Update @pkSESSAO_ID = @p_sessao_id, @Contador = @v_count           
          END  
  
                    
        fetch next from c_LY_COBRANCA_1 into @v_cobranca_update          
      END       
          
      CLOSE c_LY_COBRANCA_1          
      DEALLOCATE c_LY_COBRANCA_1          
    END          
          
    ELSE          
    BEGIN          
      declare c_LY_COBRANCA_2 cursor for                    
      SELECT LY_COBRANCA.COBRANCA          
      FROM LY_COBRANCA, LY_ITENS_AUX          
      WHERE RESP = @p_Resp AND DATA_DE_VENCIMENTO = @p_DtVenc       
      AND DATA_DE_FATURAMENTO IS NULL       
      AND LY_COBRANCA.COBRANCA = LY_ITENS_AUX.COBRANCA       
      AND LY_ITENS_AUX.SESSAO_ID = @p_sessao_id    
      AND ((@p_tipo_cobranca is NOT null AND LY_COBRANCA.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)        
      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = ly_cobranca.cobranca   
            AND dt_canc IS NULL ) )    
              
      OPEN C_LY_COBRANCA_2                  
      FETCH NEXT FROM C_LY_COBRANCA_2 INTO @v_cobranca_update            
  
          
      WHILE (@@FETCH_STATUS = 0)          
      BEGIN          
            
        -- VERIFICA SE A COBRANÇA FOI PRÉ-ACORDADA    
        SELECT @v_Cont = ISNULL(COUNT(*),0)    
          FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO    
         WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO    
           AND COBRANCA = @v_cobranca_update    
           AND CANCELADO = 'N'    
    
        IF @v_Cont > 0    
          BEGIN    
            SET @v_straux1 = CONVERT(VARCHAR(20),@v_cobranca_update)    
            SET @v_Erro = 'A cobrança ' + @v_straux1 + ' não pode ser faturada porque foi pré-acordada!'    
            EXEC SetErro @v_Erro, 'COBRANCA'    
            CLOSE c_LY_COBRANCA_2          
            DEALLOCATE c_LY_COBRANCA_2    
            RETURN      
          END    
    
        EXEC GetDataDiaSemHora @aux_dt output          
        EXEC LY_COBRANCA_UPDATE @pkCobranca = @v_cobranca_update,@DATA_DE_FATURAMENTO = @aux_dt          
        EXEC GetErrorsCount @v_ErrosCount OUTPUT          
                    
        IF @v_ErrosCount  > 0          
        BEGIN          
          SET @v_straux1 = convert(varchar(50),@v_cobranca_update)          
          SELECT @v_Erro = 'Erro ao atualizar a data de faturamento da cobranca ' + @v_straux1          
          EXEC SetErro @v_Erro, 'DATA_DE_FATURAMENTO'          
          CLOSE c_LY_COBRANCA_2          
          DEALLOCATE c_LY_COBRANCA_2          
          RETURN          
        END          
  
        -- Inserção no contador para que o processo possa controlar o log para responsáveis que somente falturam as cobranças  
        SET @v_count = 0          
        SELECT @v_count = isnull(count(*),0) FROM  LY_AUX_CONTADOR WHERE SESSAO_ID = @p_sessao_id          
                         
        IF @v_count > 0          
          BEGIN          
            SELECT @v_count = CONTADOR FROM LY_AUX_CONTADOR WHERE SESSAO_ID = @p_sessao_id          
            SET @v_count = @v_count + 1          
            EXEC LY_AUX_CONTADOR_Update @pkSESSAO_ID = @p_sessao_id, @Contador = @v_count           
          END  
            
        FETCH NEXT FROM C_LY_COBRANCA_2 INTO @v_cobranca_update          
      END          
                    
      CLOSE C_LY_COBRANCA_2          
      DEALLOCATE C_LY_COBRANCA_2                    
    END                
  END -- IF @p_ApenasFaturar = 'S'                
  ELSE           
  BEGIN          
    -- -----------------------------------------------------------------------------          
    --  Gerar boleto (além de faturar). O resp finan que um único boleto ?        
    -- -----------------------------------------------------------------------------          
    SELECT @v_tipocarteira = ARQUIVO_COBRANCA, @v_Tipo21 = TIPO_21 FROM LY_OPCOES_BOLETO       
    WHERE BANCO = @p_Banco AND AGENCIA = @p_Agencia AND CONTA_BANCO = @p_Conta   
          AND CARTEIRA = @p_Carteira           
          
    IF @v_BoletoUnico = 'S' OR @v_BolUnicoPessoa = 'S'         
    BEGIN          
      -- ***** GERAR BOLETO ÚNICO *****          
      -- Selecione as cobranças          
      DECLARE c_cobranca_origem2 CURSOR READ_ONLY FOR          
      SELECT DISTINCT C.DATA_DE_VENCIMENTO, NULL AS PESSOA FROM LY_COBRANCA C    
      WHERE C.RESP = @p_Resp      
      AND C.DATA_DE_VENCIMENTO = @p_dtVenc       
      AND @p_Usa_Cobr_Pre_Selecionadas = 'N'       
      AND @v_BoletoUnico = 'S'    
      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
      AND ((@p_tipo_cobranca is NOT null AND C.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)        
      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )    
      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
      AND EXISTS (SELECT IL.COBRANCA  
                  FROM LY_ITEM_LANC IL  
                  WHERE C.COBRANCA = IL.COBRANCA  
                  GROUP BY IL.COBRANCA  
                  HAVING SUM(IL.VALOR) >=0)  
      UNION          
      SELECT DISTINCT C.DATA_DE_VENCIMENTO, NULL AS PESSOA FROM LY_ITENS_AUX I, LY_COBRANCA C    
      WHERE C.RESP = @p_Resp     
      AND C.COBRANCA = I.COBRANCA       
      AND I.SESSAO_ID = @p_sessao_id       
      AND @p_Usa_Cobr_Pre_Selecionadas = 'S'       
      AND @v_BoletoUnico = 'S'    
      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
      AND ((@p_tipo_cobranca is NOT null AND C.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)        
      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )    
      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
      AND EXISTS (SELECT IL.COBRANCA  
                  FROM LY_ITEM_LANC IL  
                  WHERE C.COBRANCA = IL.COBRANCA  
                  GROUP BY IL.COBRANCA  
                  HAVING SUM(IL.VALOR) >=0)        
      UNION    
      SELECT DISTINCT C.DATA_DE_VENCIMENTO, A.PESSOA FROM LY_COBRANCA C, LY_ALUNO A    
      WHERE C.RESP = @p_Resp   AND C.ALUNO  = A.ALUNO     
      AND C.DATA_DE_VENCIMENTO = @p_dtVenc       
      AND @v_BolUnicoPessoa = 'S'         
      AND @p_Usa_Cobr_Pre_Selecionadas = 'N'       
      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
      AND ((@p_tipo_cobranca is NOT null AND C.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)        
      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )    
      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
      AND EXISTS (SELECT IL.COBRANCA  
                  FROM LY_ITEM_LANC IL  
                  WHERE C.COBRANCA = IL.COBRANCA  
                  GROUP BY IL.COBRANCA  
                  HAVING SUM(IL.VALOR) >=0)        
      UNION          
      SELECT DISTINCT C.DATA_DE_VENCIMENTO, A.PESSOA FROM LY_ITENS_AUX I, LY_COBRANCA C, LY_ALUNO A    
      WHERE C.RESP = @p_Resp   AND C.ALUNO  = A.ALUNO     
      AND C.COBRANCA = I.COBRANCA       
      AND @v_BolUnicoPessoa = 'S'         
      AND I.SESSAO_ID = @p_sessao_id       
      AND @p_Usa_Cobr_Pre_Selecionadas = 'S'       
      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
      AND ((@p_tipo_cobranca is NOT null AND C.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)        
      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )    
      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
      AND EXISTS (SELECT IL.COBRANCA  
                  FROM LY_ITEM_LANC IL  
                  WHERE C.COBRANCA = IL.COBRANCA  
                  GROUP BY IL.COBRANCA  
                  HAVING SUM(IL.VALOR) >=0)  
      ORDER BY C.DATA_DE_VENCIMENTO                    
  
    
      OPEN c_cobranca_origem2           
      FETCH NEXT FROM c_cobranca_origem2 INTO  @v_dt_venc2, @v_PessoaAluno    
          
      WHILE @@FETCH_STATUS = 0          
      BEGIN                /* ============================================================================================= */    
        /* INÍCIO DA VERIFICAÇÃO SE TEM PELO MENOS UMA COBRANÇA PRÉ-ACORDADA                             */    
        /* ============================================================================================= */    
        IF @v_BoletoUnico = 'S'     
          BEGIN    
            IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              BEGIN          
                DECLARE C_COBRANCA_PRE_ACORDO_1 CURSOR FOR          
                SELECT DISTINCT I.COBRANCA    
                FROM LY_ITEM_LANC I, LY_COBRANCA C          
                WHERE C.RESP = @p_Resp       
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                      AND I.COBRANCA = C.COBRANCA       
                      AND I.BOLETO IS NULL       
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)  
                ORDER BY I.COBRANCA                                     
                       
    
                OPEN C_COBRANCA_PRE_ACORDO_1          
                FETCH NEXT FROM C_COBRANCA_PRE_ACORDO_1 INTO @v_Cobranca_PreAcordo    
                        
                WHILE (@@FETCH_STATUS = 0)          
                  BEGIN          
                    -- VERIFICA SE A COBRANÇA FOI PRÉ-ACORDADA    
                    SELECT @v_Cont = ISNULL(COUNT(*),0)    
                      FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO    
                     WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO    
                       AND COBRANCA = @v_Cobranca_PreAcordo    
                       AND CANCELADO = 'N'    
    
                    IF @v_Cont > 0    
                      BEGIN    
                        SET @v_straux1 = CONVERT(VARCHAR(20),@v_Cobranca_PreAcordo)    
                        SET @v_Erro = 'O boleto da cobrança ' + @v_straux1 + ' não pode ser gerado porque a mesma foi pré-acordada!'    
                        EXEC SetErro @v_Erro, 'COBRANCA'    
                        CLOSE c_cobranca_origem2          
                        DEALLOCATE c_cobranca_origem2    
                        CLOSE C_COBRANCA_PRE_ACORDO_1          
                        DEALLOCATE C_COBRANCA_PRE_ACORDO_1    
                        RETURN      
                      END     
    
                    FETCH NEXT FROM C_COBRANCA_PRE_ACORDO_1 INTO @v_Cobranca_PreAcordo    
                  END          
                          
                CLOSE C_COBRANCA_PRE_ACORDO_1          
                DEALLOCATE C_COBRANCA_PRE_ACORDO_1          
              END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'                  
            ELSE          
              BEGIN          
                DECLARE C_COBRANCA_PRE_ACORDO_2 CURSOR FOR          
                  SELECT DISTINCT I.COBRANCA    
                  FROM LY_ITEM_LANC I, LY_COBRANCA C, LY_ITENS_AUX AUX          
                  WHERE C.RESP = @p_Resp       
                     AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                     AND I.COBRANCA = C.COBRANCA       
                     AND C.COBRANCA = AUX.COBRANCA       
                     AND AUX.SESSAO_ID = @p_sessao_id       
                     AND I.BOLETO IS NULL       
                     AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                     AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )    
                     AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                     AND EXISTS (SELECT IL.COBRANCA  
                                 FROM LY_ITEM_LANC IL  
                                 WHERE C.COBRANCA = IL.COBRANCA  
                                 GROUP BY IL.COBRANCA  
                                 HAVING SUM(IL.VALOR) >=0)  
                  ORDER BY I.COBRANCA     
     
                OPEN C_COBRANCA_PRE_ACORDO_2          
                FETCH NEXT FROM C_COBRANCA_PRE_ACORDO_2 INTO @v_Cobranca_PreAcordo    
                        
                WHILE (@@FETCH_STATUS = 0)          
                  BEGIN          
                    -- VERIFICA SE A COBRANÇA FOI PRÉ-ACORDADA    
                     SELECT @v_Cont = ISNULL(COUNT(*),0)    
                      FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO    
                     WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO    
                       AND COBRANCA = @v_Cobranca_PreAcordo          
                       AND CANCELADO = 'N'    
    
                    IF @v_Cont > 0    
                      BEGIN    
                        SET @v_straux1 = CONVERT(VARCHAR(20),@v_Cobranca_PreAcordo)    
                        SET @v_Erro = 'O boleto da cobrança ' + @v_straux1 + ' não pode ser gerado porque a mesma foi pré-acordada!'    
                        EXEC SetErro @v_Erro, 'COBRANCA'    
                        CLOSE c_cobranca_origem2          
                        DEALLOCATE c_cobranca_origem2    
                        CLOSE C_COBRANCA_PRE_ACORDO_2          
                        DEALLOCATE C_COBRANCA_PRE_ACORDO_2    
                        RETURN      
                      END     
    
                    FETCH NEXT FROM C_COBRANCA_PRE_ACORDO_2 INTO @v_Cobranca_PreAcordo    
                  END          
                           
                CLOSE C_COBRANCA_PRE_ACORDO_2          
                DEALLOCATE C_COBRANCA_PRE_ACORDO_2          
              END -- ELSE -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
            END -- IF @v_BoletoUnico = 'S'     
          ELSE    
            BEGIN    
              IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                BEGIN          
                  DECLARE C_COBRANCA_PRE_ACORDO_3 CURSOR FOR          
                  SELECT DISTINCT I.COBRANCA    
                  FROM LY_ITEM_LANC I, LY_COBRANCA C, LY_ALUNO A         
                  WHERE C.RESP = @p_Resp   AND C.ALUNO  = A.ALUNO    
                       AND A.PESSOA = @v_PessoaAluno    
                       AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                       AND I.COBRANCA = C.COBRANCA       
                       AND I.BOLETO IS NULL       
                       AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                       AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )    
                       AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                       AND EXISTS (SELECT IL.COBRANCA  
                                   FROM LY_ITEM_LANC IL  
                                   WHERE C.COBRANCA = IL.COBRANCA  
                                   GROUP BY IL.COBRANCA  
                                   HAVING SUM(IL.VALOR) >=0)               
                  ORDER BY I.COBRANCA       
                            
                  OPEN C_COBRANCA_PRE_ACORDO_3          
                  FETCH NEXT FROM C_COBRANCA_PRE_ACORDO_3 INTO @v_Cobranca_PreAcordo    
                            
                  WHILE (@@FETCH_STATUS = 0)          
                    BEGIN          
                      -- VERIFICA SE A COBRANÇA FOI PRÉ-ACORDADA    
                      SELECT @v_Cont = ISNULL(COUNT(*),0)    
                        FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO    
                    WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO    
                         AND COBRANCA = @v_Cobranca_PreAcordo    
                         AND CANCELADO = 'N'     
    
                      IF @v_Cont > 0    
                        BEGIN    
                          SET @v_straux1 = CONVERT(VARCHAR(20),@v_Cobranca_PreAcordo)    
                          SET @v_Erro = 'O boleto da cobrança ' + @v_straux1 + ' não pode ser gerado porque a mesma foi pré-acordada!'    
                          EXEC SetErro @v_Erro, 'COBRANCA'    
                          CLOSE c_cobranca_origem2          
                          DEALLOCATE c_cobranca_origem2    
                          CLOSE C_COBRANCA_PRE_ACORDO_3          
                          DEALLOCATE C_COBRANCA_PRE_ACORDO_3    
                          RETURN      
                        END        
                               
                      FETCH NEXT FROM C_COBRANCA_PRE_ACORDO_3 INTO @v_Cobranca_PreAcordo    
                    END          
                              
                  CLOSE C_COBRANCA_PRE_ACORDO_3          
                  DEALLOCATE C_COBRANCA_PRE_ACORDO_3          
                END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'                 
              ELSE          
                BEGIN          
                  DECLARE C_COBRANCA_PRE_ACORDO_4 CURSOR FOR          
                  SELECT DISTINCT I.COBRANCA    
                  FROM LY_ITEM_LANC I, LY_COBRANCA C, LY_ITENS_AUX AUX, LY_ALUNO A          
                  WHERE C.RESP = @p_Resp     
                       AND C.ALUNO = A.ALUNO    
                       AND A.PESSOA = @v_PessoaAluno    
                       AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                       AND I.COBRANCA = C.COBRANCA       
                       AND C.COBRANCA = AUX.COBRANCA       
                       AND AUX.SESSAO_ID = @p_sessao_id       
                       AND I.BOLETO IS NULL       
                       AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                       AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )    
                       AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)                              
                       AND EXISTS (SELECT IL.COBRANCA  
                                   FROM LY_ITEM_LANC IL  
                                   WHERE C.COBRANCA = IL.COBRANCA  
                                   GROUP BY IL.COBRANCA  
                                   HAVING SUM(IL.VALOR) >=0)               
                  ORDER BY I.COBRANCA  
                         
                  OPEN C_COBRANCA_PRE_ACORDO_4          
                  FETCH NEXT FROM C_COBRANCA_PRE_ACORDO_4 INTO @v_Cobranca_PreAcordo    
                            
                  WHILE (@@FETCH_STATUS = 0)          
                    BEGIN          
                      -- VERIFICA SE A COBRANÇA FOI PRÉ-ACORDADA    
                      SELECT @v_Cont = ISNULL(COUNT(*),0)    
                        FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO    
                       WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO    
                         AND COBRANCA = @v_Cobranca_PreAcordo    
                         AND CANCELADO = 'N'     
    
                      IF @v_Cont > 0    
                        BEGIN    
                          SET @v_straux1 = CONVERT(VARCHAR(20),@v_Cobranca_PreAcordo)    
                          SET @v_Erro = 'O boleto da cobrança ' + @v_straux1 + ' não pode ser gerado porque a mesma foi pré-acordada!'    
                          EXEC SetErro @v_Erro, 'COBRANCA'    
                          CLOSE c_cobranca_origem2          
                          DEALLOCATE c_cobranca_origem2    
                          CLOSE C_COBRANCA_PRE_ACORDO_4          
                          DEALLOCATE C_COBRANCA_PRE_ACORDO_4    
                          RETURN      
                        END        
    
                      FETCH NEXT FROM C_COBRANCA_PRE_ACORDO_4 INTO @v_Cobranca_PreAcordo    
                    END          
                               
                  CLOSE C_COBRANCA_PRE_ACORDO_4          
                  DEALLOCATE C_COBRANCA_PRE_ACORDO_4          
                END -- ELSE -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'              
            END -- ELSE -- IF @v_BoletoUnico = 'S'      
        /* ============================================================================================= */    
        /* FIM DA VERIFICAÇÃO SE TEM PELO MENOS UMA COBRANÇA PRÉ-ACORDADA                                */    
        /* ============================================================================================= */    
    
        -- -----------------------------------------------------------------------------          
        --  Soma o valor dos ITENS DE LANÇAMENTO de todas as cobranças          
        -- -----------------------------------------------------------------------------          
    
        IF @v_BoletoUnico = 'S'     
          BEGIN    
            IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              BEGIN          
  
                SELECT @v_ValorCobranca = isnull(SUM(VALOR),0)   
                FROM LY_ITEM_LANC           
                WHERE BOLETO IS NULL       
                      AND EXISTS ( SELECT C.COBRANCA   
                                   FROM LY_COBRANCA C    
                                   WHERE LY_ITEM_LANC.COBRANCA = C.COBRANCA   
                                         AND C.RESP = @p_Resp AND C.DATA_DE_VENCIMENTO = @v_dt_venc2        
                                         AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                                         AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)      
                                         AND EXISTS (SELECT IL.COBRANCA  
                                                     FROM LY_ITEM_LANC IL  
                                                     WHERE C.COBRANCA = IL.COBRANCA  
                                                     GROUP BY IL.COBRANCA  
                                                     HAVING SUM(IL.VALOR) >=0)  
                                  )       
                      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
                                       FROM ly_nota_promissoria   
                                       WHERE  ly_nota_promissoria.cobranca = LY_ITEM_LANC.cobranca   
                                 AND dt_canc IS NULL   
                                                                     )   
                          )                    
  
  
                EXEC GET_ERROR_ID @v_Erros_ID          
              END          
                          
            ELSE          
              BEGIN          
  
                SELECT @v_ValorCobranca = isnull(SUM(VALOR),0)   
                FROM LY_ITEM_LANC           
                WHERE BOLETO IS NULL       
                      AND EXISTS ( SELECT  C.COBRANCA   
                                   FROM LY_COBRANCA C, LY_ITENS_AUX I    
                                   WHERE LY_ITEM_LANC.COBRANCA  =  C.COBRANCA  
                                         AND C.RESP = @p_Resp       
                                         AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                                         AND C.COBRANCA = I.COBRANCA       
                                         AND I.SESSAO_ID = @p_sessao_id       
                                         AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                                         AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                                         AND EXISTS (SELECT IL.COBRANCA  
                                                     FROM LY_ITEM_LANC IL  
                                                     WHERE C.COBRANCA = IL.COBRANCA  
                                                     GROUP BY IL.COBRANCA  
                                                     HAVING SUM(IL.VALOR) >=0)  
                                 )       
                      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
                                       FROM   ly_nota_promissoria   
                                       WHERE  ly_nota_promissoria.cobranca = LY_ITEM_LANC.cobranca   
                                        AND dt_canc IS NULL )   
                           )    
  
  
                     
                EXEC GET_ERROR_ID @v_Erros_ID          
              END     
          END --  IF @v_BoletoUnico = 'S' AND @v_BolUnicoPessoa <> 'S'            
        ELSE    
          BEGIN    
            IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              BEGIN          
                IF @v_PessoaAluno IS NOT NULL     
                  BEGIN                     
  
                    SELECT @v_ValorCobranca = isnull(SUM(VALOR),0)   
                    FROM LY_ITEM_LANC           
                    WHERE BOLETO IS NULL       
                          AND EXISTS (     
                                       SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ALUNO A    
                                       WHERE C.cobranca = LY_ITEM_LANC.cobranca   
                        AND C.RESP = @p_Resp AND C.ALUNO = A.ALUNO     
                                             AND C.DATA_DE_VENCIMENTO = @v_dt_venc2        
                                             AND A.PESSOA = @v_PessoaAluno    
                                             AND isnull(C.APENAS_COBRANCA, 'N') = 'N'     
                                             AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                                             AND EXISTS (SELECT IL.COBRANCA  
                                                         FROM LY_ITEM_LANC IL  
                                                         WHERE C.COBRANCA = IL.COBRANCA  
                                                         GROUP BY IL.COBRANCA  
                                                         HAVING SUM(IL.VALOR) >=0)                          
                                     )       
                          AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
                                           FROM   ly_nota_promissoria   
                                           WHERE  ly_nota_promissoria.cobranca = LY_ITEM_LANC.cobranca   
                                            AND dt_canc IS NULL ) )    
  
  
                  END    
                ELSE -- IF @v_PessoaAluno IS NOT NULL     
                  BEGIN    
                    SELECT @v_ValorCobranca = isnull(SUM(VALOR),0) FROM LY_ITEM_LANC           
                    WHERE BOLETO IS NULL       
                    AND EXISTS      
                    (     
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ALUNO A    
                      WHERE C.cobranca = LY_ITEM_LANC.cobranca   
       AND C.RESP = @p_Resp AND C.ALUNO = A.ALUNO     
                            AND C.DATA_DE_VENCIMENTO = @v_dt_venc2        
                            AND A.PESSOA <> @v_PessoaResp    
                            AND isnull(C.APENAS_COBRANCA, 'N') = 'N'     
                            AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                            AND EXISTS (SELECT IL.COBRANCA  
                                        FROM LY_ITEM_LANC IL  
                                        WHERE C.COBRANCA = IL.COBRANCA  
                                        GROUP BY IL.COBRANCA  
                                        HAVING SUM(IL.VALOR) >=0)      
                    )           
    
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_LANC.cobranca   
            AND dt_canc IS NULL ) )    
                  END     
                    
                EXEC GET_ERROR_ID @v_Erros_ID          
              END  -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'                      
            ELSE          
              BEGIN          
                IF @v_PessoaAluno IS NOT NULL     
                  BEGIN    
                    SELECT @v_ValorCobranca = isnull(SUM(VALOR),0) FROM LY_ITEM_LANC           
                    WHERE BOLETO IS NULL       
                    AND EXISTS      
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ITENS_AUX I, LY_ALUNO A    
                      WHERE  C.cobranca = LY_ITEM_LANC.cobranca   
       AND C.RESP = @p_Resp  AND C.ALUNO  = A.ALUNO     
                      AND A.PESSOA = @v_PessoaAluno    
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                      AND C.COBRANCA = I.COBRANCA       
                      AND I.SESSAO_ID = @p_sessao_id       
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)  
                    )       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_LANC.cobranca   
            AND dt_canc IS NULL ) )         
                  END -- IF @v_PessoaAluno IS NOT NULL     
                ELSE    
                  BEGIN    
  
                    SELECT @v_ValorCobranca = isnull(SUM(VALOR),0)   
                    FROM LY_ITEM_LANC           
                    WHERE BOLETO IS NULL       
                          AND EXISTS (      
                                      SELECT C.COBRANCA   
                                      FROM LY_COBRANCA C, LY_ITENS_AUX I, LY_ALUNO A    
                                      WHERE  C.cobranca = LY_ITEM_LANC.cobranca   
                              AND C.RESP = @p_Resp AND C.ALUNO  = A.ALUNO       
                                             AND A.PESSOA <> @v_PessoaResp    
                                             AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                                             AND C.COBRANCA = I.COBRANCA       
                                             AND I.SESSAO_ID = @p_sessao_id       
                                             AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                                             AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                                             AND EXISTS (SELECT IL.COBRANCA  
                                                         FROM LY_ITEM_LANC IL  
                                                         WHERE C.COBRANCA = IL.COBRANCA  
                                                         GROUP BY IL.COBRANCA  
                                                         HAVING SUM(IL.VALOR) >=0)                          
                                     )       
                          AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
                                              FROM   ly_nota_promissoria   
                                           WHERE  ly_nota_promissoria.cobranca = LY_ITEM_LANC.cobranca   
             AND dt_canc IS NULL )   
                              )              
  
                      
                  END  -- ELSE  -- -- IF @v_PessoaAluno IS NOT NULL                          
                EXEC GET_ERROR_ID @v_Erros_ID          
              END -- ELSE -- -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'                      
          END -- ELSE -- --  IF @v_BoletoUnico = 'S' AND @v_BolUnicoPessoa <> 'S'            
                                            
        IF @v_Erros_ID <> 0          
          BEGIN          
            SELECT @v_Erro = 'Erro ao obter a soma dos itens de lançamento'          
            EXEC SetErro @v_Erro, 'ITEMCOBRANCA'          
            CLOSE c_cobranca_origem2          
            DEALLOCATE c_cobranca_origem2          
            RETURN          
          END          
                               
        -- -----------------------------------------------------------------------------          
        --  Soma o valor dos ITENS DE CRÉDITO de todas as cobranças          
        -- -----------------------------------------------------------------------------                    
        IF @v_BoletoUnico = 'S'     
          BEGIN    
            IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              BEGIN          
                SELECT @v_ValorCreditos = ISNULL(SUM(VALOR),0)       
                FROM LY_ITEM_CRED          
                WHERE BOLETO IS NULL       
                AND EXISTS      
                (      
                  SELECT C.COBRANCA FROM LY_COBRANCA C    
                  WHERE  C.cobranca = LY_ITEM_CRED.cobranca   
      AND C.RESP = @p_Resp       
                  AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                  AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                  AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                  AND EXISTS (SELECT IL.COBRANCA  
                              FROM LY_ITEM_LANC IL  
                              WHERE C.COBRANCA = IL.COBRANCA  
                              GROUP BY IL.COBRANCA  
                              HAVING SUM(IL.VALOR) >=0)  
                    
                )       
                AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_CRED.cobranca   
            AND dt_canc IS NULL ) )          
                     
                EXEC GET_ERROR_ID @v_Erros_ID          
              END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'               
            ELSE          
              BEGIN          
                SELECT @v_ValorCreditos = ISNULL(SUM(VALOR),0)       
                FROM LY_ITEM_CRED          
                WHERE BOLETO IS NULL       
                      AND EXISTS (      
                                   SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ITENS_AUX I    
                                   WHERE C.cobranca = LY_ITEM_CRED.cobranca   
                             AND C.RESP = @p_Resp       
                                         AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                                         AND C.COBRANCA = I.COBRANCA       
                                         AND I.SESSAO_ID = @p_sessao_id       
                                         AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                                         AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                                         AND EXISTS (SELECT IL.COBRANCA  
                                                     FROM LY_ITEM_LANC IL  
                                                     WHERE C.COBRANCA = IL.COBRANCA  
                                                     GROUP BY IL.COBRANCA  
                                                     HAVING SUM(IL.VALOR) >=0)                                           
          )       
                      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
                                       FROM   ly_nota_promissoria   
                                       WHERE  ly_nota_promissoria.cobranca = LY_ITEM_CRED.cobranca   
                                        AND dt_canc IS NULL ) )              
                    
                EXEC GET_ERROR_ID @v_Erros_ID          
              END -- ELSE -- -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'               
          END -- IF @v_BoletoUnico = 'S'     
        ELSE    
          BEGIN    
            IF @v_PessoaAluno IS NOT NULL     
              BEGIN        
                IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                  BEGIN          
                    SELECT @v_ValorCreditos = ISNULL(SUM(VALOR),0)       
                    FROM LY_ITEM_CRED          
                    WHERE BOLETO IS NULL       
                    AND EXISTS       
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ALUNO A    
                      WHERE C.cobranca = LY_ITEM_CRED.cobranca   
       AND C.RESP = @p_Resp AND C.ALUNO = A.ALUNO      
                      AND A.PESSOA = @v_PessoaAluno    
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)     
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)  
                    )       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_CRED.cobranca   
            AND dt_canc IS NULL ) )          
                         
                    EXEC GET_ERROR_ID @v_Erros_ID          
                  END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'               
                ELSE          
                  BEGIN          
                    SELECT @v_ValorCreditos = ISNULL(SUM(VALOR),0)       
                    FROM LY_ITEM_CRED          
                    WHERE BOLETO IS NULL       
                    AND EXISTS       
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ITENS_AUX I, LY_ALUNO A    
                      WHERE C.cobranca = LY_ITEM_CRED.cobranca   
       AND C.RESP = @p_Resp       
                      AND C.ALUNO = A.ALUNO      
                      AND A.PESSOA = @v_PessoaAluno    
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                      AND C.COBRANCA = I.COBRANCA       
                      AND I.SESSAO_ID = @p_sessao_id       
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)  
                     )       
                     AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_CRED.cobranca   
            AND dt_canc IS NULL ) )              
                        
                    EXEC GET_ERROR_ID @v_Erros_ID          
                  END -- ELSE -- -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'               
              END --  IF @v_PessoaAluno IS NOT NULL     
      ELSE    
              BEGIN    
                IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                  BEGIN          
                    SELECT @v_ValorCreditos = ISNULL(SUM(VALOR),0)       
                    FROM LY_ITEM_CRED          
                    WHERE BOLETO IS NULL       
                    AND EXISTS    
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ALUNO A    
                      WHERE C.cobranca = LY_ITEM_CRED.cobranca   
       AND C.RESP = @p_Resp       
                      AND C.ALUNO = A.ALUNO      
                      AND A.PESSOA <> @v_PessoaResp    
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)  
                    )       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_CRED.cobranca   
            AND dt_canc IS NULL ) )          
                         
                    EXEC GET_ERROR_ID @v_Erros_ID          
                  END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'               
                ELSE          
                  BEGIN          
                    SELECT @v_ValorCreditos = ISNULL(SUM(VALOR),0)       
                    FROM LY_ITEM_CRED          
                    WHERE BOLETO IS NULL       
                    AND EXISTS       
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ITENS_AUX I, LY_ALUNO A    
                      WHERE C.cobranca = LY_ITEM_CRED.cobranca   
       AND C.RESP = @p_Resp       
                      AND C.ALUNO = A.ALUNO      
                      AND A.PESSOA <> @v_PessoaResp    
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                      AND C.COBRANCA = I.COBRANCA       
                      AND I.SESSAO_ID = @p_sessao_id       
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)     
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)  
                        
                     )       
                     AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_CRED.cobranca   
            AND dt_canc IS NULL ) )              
                        
                    EXEC GET_ERROR_ID @v_Erros_ID          
                  END -- ELSE -- -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'               
              END -- ELSE -- --  IF @v_PessoaAluno <> NULL     
          END -- ELSE -- -- IF @v_BoletoUnico = 'S'      
                                              
        IF @v_Erros_ID <> 0          
          BEGIN          
            SELECT @v_Erro = 'Erro ao obter a soma dos itens de crédito'          
            EXEC SetErro @v_Erro, 'ITEMCRED'          
            CLOSE c_cobranca_origem2          
            DEALLOCATE c_cobranca_origem2          
            RETURN          
          END          
                                        
        -- -----------------------------------------------------------------------------          
        --  Verifique se existem itens que não foram emboletados          
        -- -----------------------------------------------------------------------------                    
        SELECT @v_ItensBoleto = 0          
            
        IF @v_BoletoUnico = 'S'     
          BEGIN              
            IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              BEGIN          
                SELECT @v_ItensBoleto = ISNULL(COUNT(*),0)           
                FROM VW_LANCAMENTOS_PAGAMENTOS           
                WHERE BOLETO IS NULL       
                AND EXISTS            
                (      
                  SELECT C.COBRANCA FROM LY_COBRANCA C    
                  WHERE C.COBRANCA  = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
      AND C.RESP = @p_Resp           
                  AND C.DATA_DE_VENCIMENTO = @v_dt_venc2           
                  AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                  AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                  AND EXISTS (SELECT IL.COBRANCA  
                              FROM LY_ITEM_LANC IL  
                              WHERE C.COBRANCA = IL.COBRANCA  
                              GROUP BY IL.COBRANCA  
                              HAVING SUM(IL.VALOR) >=0)  
                )       
                AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
            AND dt_canc IS NULL ) )         
                  
              END          
            ELSE          
              BEGIN          
                SELECT @v_ItensBoleto = ISNULL(COUNT(*),0) FROM VW_LANCAMENTOS_PAGAMENTOS           
                WHERE BOLETO IS NULL       
                AND EXISTS       
                (      
                  SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ITENS_AUX I    
                  WHERE C.COBRANCA  = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
      AND C.RESP = @p_Resp       
                  AND C.DATA_DE_VENCIMENTO = @v_dt_venc2        
      AND C.COBRANCA = I.COBRANCA       
                  AND I.SESSAO_ID = @p_sessao_id       
                  AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                  AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                  AND EXISTS (SELECT IL.COBRANCA  
                              FROM LY_ITEM_LANC IL  
                              WHERE C.COBRANCA = IL.COBRANCA  
                              GROUP BY IL.COBRANCA  
                              HAVING SUM(IL.VALOR) >=0)                                           
                )       
                AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
            AND dt_canc IS NULL ) )           
                    
              END          
          END -- IF @v_BoletoUnico = 'S'     
        ELSE    
          BEGIN    
            IF @v_PessoaAluno IS NOT NULL      
              BEGIN    
                IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                  BEGIN          
                    SELECT @v_ItensBoleto = ISNULL(COUNT(*),0)           
                    FROM VW_LANCAMENTOS_PAGAMENTOS           
                    WHERE BOLETO IS NULL       
                    AND EXISTS   
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ALUNO A    
                      WHERE C.COBRANCA  = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
       AND C.RESP = @p_Resp AND C.ALUNO = A.ALUNO     
                      AND A.PESSOA  = @v_PessoaAluno           
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2           
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)    
                    )       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
            AND dt_canc IS NULL ) )         
                      
                  END          
                ELSE          
                  BEGIN          
                    SELECT @v_ItensBoleto = ISNULL(COUNT(*),0) FROM VW_LANCAMENTOS_PAGAMENTOS           
                    WHERE BOLETO IS NULL       
                    AND EXISTS       
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ITENS_AUX I, LY_ALUNO A    
                      WHERE C.COBRANCA  = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
       AND C.RESP = @p_Resp   AND C.ALUNO = A.ALUNO     
                      AND A.PESSOA  = @v_PessoaAluno           
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2        
                      AND C.COBRANCA = I.COBRANCA       
                      AND I.SESSAO_ID = @p_sessao_id       
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)     
                    )       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
            AND dt_canc IS NULL ) )                               
                  END          
              END -- IF @v_PessoaAluno IS NOT NULL      
            ELSE    
              BEGIN    
                IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                  BEGIN          
                    SELECT @v_ItensBoleto = ISNULL(COUNT(*),0)           
                    FROM VW_LANCAMENTOS_PAGAMENTOS           
                    WHERE BOLETO IS NULL       
                    AND EXISTS          
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ALUNO A    
                      WHERE C.COBRANCA  = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
       AND C.RESP = @p_Resp AND C.ALUNO = A.ALUNO     
                      AND A.PESSOA  <> @v_PessoaResp           
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2           
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)    
                    )       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
            AND dt_canc IS NULL ) )         
                      
                  END          
                ELSE          
                  BEGIN          
      SELECT @v_ItensBoleto = ISNULL(COUNT(*),0) FROM VW_LANCAMENTOS_PAGAMENTOS           
                    WHERE BOLETO IS NULL       
                    AND EXISTS      
                    (      
                      SELECT C.COBRANCA FROM LY_COBRANCA C, LY_ITENS_AUX I, LY_ALUNO A    
                      WHERE C.COBRANCA  = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
       AND C.RESP = @p_Resp   AND C.ALUNO = A.ALUNO     
                      AND A.PESSOA <> @v_PessoaResp           
                      AND C.DATA_DE_VENCIMENTO = @v_dt_venc2        
                      AND C.COBRANCA = I.COBRANCA       
                      AND I.SESSAO_ID = @p_sessao_id       
                      AND isnull(C.APENAS_COBRANCA, 'N') = 'N'    
                      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                      AND EXISTS (SELECT IL.COBRANCA  
                                  FROM LY_ITEM_LANC IL  
                                  WHERE C.COBRANCA = IL.COBRANCA  
                                  GROUP BY IL.COBRANCA  
                                  HAVING SUM(IL.VALOR) >=0)    
                    )       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
            AND dt_canc IS NULL ) )                               
                  END          
              END -- ELSE -- -- IF @v_PessoaAluno IS NOT NULL      
          END -- ELSE -- -- IF @v_BoletoUnico = 'S'               
        -- -----------------------------------------------------------------------------          
        --  Monta o valor do boleto          
        -- -----------------------------------------------------------------------------
		                 
        SELECT @v_ValorBoleto = (@v_ValorCobranca + 1) + @v_ValorCreditos          
                    
        -- -------------------------------------------------------------------------------          
        --  Não gerar boleto para cobranças já quitadas ou com devolução a ser feita,          
        --  porém nestes casos a cobrança deve ser faturada (ie, a cobrança sempre é faturada          
        -- -------------------------------------------------------------------------------          
        SELECT @v_Boleto = NULL          
        IF (@v_ValorBoleto > 0 and @p_Apartir_Valor is null) or (@v_ItensBoleto > 0 and @v_ValorBoleto = 0 AND @p_boleto_zerado = 'S')      
                    or (@v_ItensBoleto > 0 and @v_ValorBoleto < 0 AND @p_boleto_negativo = 'S')    
                    or (@v_ValorBoleto >= @p_Apartir_Valor and @p_Apartir_Valor is not null and @p_Apartir_Valor > 0)    
                         
          BEGIN          
            -- ------------------------------------------------          
            --  Inserção do boleto VAZIO           
            -- ------------------------------------------------          
            EXEC GetDataDiaSemHora @aux_dt output          
                                
            IF @p_lote is null          
              BEGIN              
                EXEC GET_NUMERO 'Lote', '0' , @p_lote OUTPUT          
                EXEC GetErrorsCount @v_ErrosCount output          
                            
                IF @v_ErrosCount > 0           
                BEGIN          
                  EXEC SetErro 'Erro na obtenção do lote do boleto', 'LOTE'          
                  CLOSE c_cobranca_origem2          
                  DEALLOCATE c_cobranca_origem2          
                  RETURN        
                END          
              END          
              
   -- INSERINDO REGISTRO NA LY_BOLETO_UNIFICADO PARA OBTER UM NOVO NUMERO DE BOLETO  
   declare @data_atual_2 T_DATA  
   set @data_atual_2 = GETDATE()   
  
   EXEC LY_BOLETO_UNIFICADO_Insert           
                  @id_boleto = @v_Boleto OUTPUT,           
     @data_inclusao = @data_atual_2,  
      @origem = 'LY_BOLETO'   
   EXEC GetErrorsCount @v_ErrosCount OUTPUT                   
            IF @v_ErrosCount  > 0          
            BEGIN          
              SELECT @v_Erro = 'Erro ao gerar numeração do boleto '          
              EXEC SetErro @v_Erro, 'BOLETO'          
              CLOSE c_cobranca_origem2          
              DEALLOCATE c_cobranca_origem2          
              RETURN          
            END     
                         
            EXEC LY_BOLETO_Insert           
                  @Boleto = @v_Boleto,           
                  @Banco = @p_Banco,           
                  @Agencia = @p_Agencia,           
                  @Conta_banco = @p_Conta,           
                  @Resp = @p_Resp,           
                  @Data_proc = @aux_dt,           
                  @Nosso_numero = 0,           
                  @Instrucoes = NULL,           
                  @Lote = @p_Lote,           
                  @Arquivo_retorno = NULL,           
                  @Debito_automatico = 'N',           
                  @Debito_auto_cancelado = 'N',           
                  @Removido = 'N',           
                  @Aceito = 'N',           
                  @Impresso = 'N',          
                  @Enviado = 'N',           
                  @Env_Cancel = 'N',           
         @Cancel_Banco = 'N',           
                  @Carteira = @p_Carteira,           
                  @Convenio = @p_Convenio,          
                  @Obs = NULL,    
                  @on_line = @p_online,  
              @Boleto_cumulativo = 'N'    
                           
            EXEC GetErrorsCount @v_ErrosCount OUTPUT          
                        
            IF @v_ErrosCount  > 0          
              BEGIN          
                SELECT @v_Erro = 'Erro ao inserir boleto para o responsável financeiro ' + @p_Resp          
                EXEC SetErro @v_Erro, 'RESP'          
                CLOSE c_cobranca_origem2          
                DEALLOCATE c_cobranca_origem2          
                RETURN          
              END              
            ELSE           
              BEGIN          
                SET @v_count = 0          
                SELECT @v_count = isnull(count(*),0) FROM  LY_AUX_CONTADOR WHERE SESSAO_ID = @p_sessao_id          
                         
                IF @v_count > 0          
                BEGIN          
                  SELECT @v_count = CONTADOR FROM LY_AUX_CONTADOR WHERE SESSAO_ID = @p_sessao_id          
                  SET @v_count = @v_count + 1          
                  EXEC LY_AUX_CONTADOR_Update @pkSESSAO_ID = @p_sessao_id, @Contador = @v_count           
                END          
              END          
                
   SET @v_boletoParaRegistro = @v_Boleto;   
                  
            -- *** Geração do Nosso Número *** --             
   EXEC GERA_NOSSO_NUMERO_BOLETO @v_Boleto, @p_Banco, @p_Agencia, @p_Conta, @p_Carteira, @p_Convenio, @v_NossoNumero output  
            EXEC GetErrorsCount @v_ErrosCount OUTPUT            
   IF @v_ErrosCount  > 0          
   BEGIN          
    SET @v_straux1 = convert(varchar(50),@v_Boleto)          
    SELECT @v_Erro = 'Erro ao gerar nosso número do boleto : ' + @v_straux1          
    EXEC SetErro @v_Erro, 'NOSSO_NUMERO'          
    CLOSE c_cobranca_origem2          
    DEALLOCATE c_cobranca_origem2          
    RETURN          
   END          
                                    
            -- -------------------------------------------------------------          
            --   Vincula boleto aos itens (de lançamento e de crédito)          
            -- -------------------------------------------------------------          
                
            -- -------------------------------------------------------------          
            -- *** Itens de lançamento  ***           
            -- -------------------------------------------------------------         
            IF @v_BoletoUnico = 'S'     
              BEGIN    
                IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                  BEGIN          
                    DECLARE C_UPDATE_LY_ITEM_LANC_1 CURSOR FOR          
                    SELECT DISTINCT I.COBRANCA, I.ITEMCOBRANCA          
                    FROM LY_ITEM_LANC I, LY_COBRANCA C          
                    WHERE C.RESP = @p_Resp       
                    AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                    AND I.COBRANCA = C.COBRANCA       
                    AND I.BOLETO IS NULL       
                    AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )   
                    AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                    AND EXISTS (SELECT IL.COBRANCA  
                                FROM LY_ITEM_LANC IL  
                                WHERE C.COBRANCA = IL.COBRANCA  
                                GROUP BY IL.COBRANCA  
                                HAVING SUM(IL.VALOR) >=0)  
                    ORDER BY I.COBRANCA, I.ITEMCOBRANCA                                          
                      
    
                    OPEN C_UPDATE_LY_ITEM_LANC_1          
                    FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_1 INTO @v_cobranca_update, @v_itemcobranca_update       
                        
                    WHILE (@@FETCH_STATUS = 0)          
                    BEGIN          
                      -- SE VALOR DA COBRANCA IGUAL A ZERO     
                      SELECT @v_valor_update = ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC WHERE COBRANCA = @v_cobranca_update    
    
                      IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)    
                        UPDATE LY_ITEM_LANC WITH (ROWLOCK)          
                        SET Boleto = @v_Boleto          
                        WHERE cobranca = @v_cobranca_update          
                        AND itemcobranca = @v_itemcobranca_update     
                            
                      FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_1 INTO @v_cobranca_update, @v_itemcobranca_update         
                    END          
                          
                    CLOSE C_UPDATE_LY_ITEM_LANC_1          
                    DEALLOCATE C_UPDATE_LY_ITEM_LANC_1          
                  END            
                ELSE          
                  BEGIN          
                    DECLARE C_UPDATE_LY_ITEM_LANC_2 CURSOR FOR          
                    SELECT DISTINCT I.COBRANCA, I.ITEMCOBRANCA     
                    FROM LY_ITEM_LANC I, LY_COBRANCA C, LY_ITENS_AUX AUX          
                    WHERE C.RESP = @p_Resp       
                    AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                    AND I.COBRANCA = C.COBRANCA       
                    AND C.COBRANCA = AUX.COBRANCA       
                    AND AUX.SESSAO_ID = @p_sessao_id       
                    AND I.BOLETO IS NULL       
                    AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                    AND (@p_cobranca_com_nota = 'S'   
       OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )        
                    AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                    AND EXISTS (SELECT IL.COBRANCA  
                                FROM LY_ITEM_LANC IL  
                                WHERE C.COBRANCA = IL.COBRANCA  
                                GROUP BY IL.COBRANCA  
                                HAVING SUM(IL.VALOR) >=0)  
                    ORDER BY I.COBRANCA, I.ITEMCOBRANCA                                     
                      
                          
                    OPEN C_UPDATE_LY_ITEM_LANC_2          
                    FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_2 INTO @v_cobranca_update, @v_itemcobranca_update      
                        
                    WHILE (@@FETCH_STATUS = 0)          
                      BEGIN          
                        -- SE VALOR DA COBRANCA IGUAL A ZERO     
                        SELECT @v_valor_update = ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC WHERE COBRANCA = @v_cobranca_update    
    
                        IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)    
                          UPDATE LY_ITEM_LANC     
                          SET Boleto = @v_Boleto     
                          WHERE Cobranca = @v_cobranca_update     
                                AND Itemcobranca = @v_itemcobranca_update          
    
                        FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_2 INTO @v_cobranca_update, @v_itemcobranca_update          
                      END          
                           
                    CLOSE C_UPDATE_LY_ITEM_LANC_2          
                    DEALLOCATE C_UPDATE_LY_ITEM_LANC_2          
                  END -- ELSE -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              END -- IF @v_BoletoUnico = 'S'     
            ELSE    
              BEGIN    
                IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                  BEGIN          
                    DECLARE C_UPDATE_LY_ITEM_LANC_3 CURSOR FOR          
                    SELECT DISTINCT I.COBRANCA, I.ITEMCOBRANCA           
                    FROM LY_ITEM_LANC I, LY_COBRANCA C, LY_ALUNO A         
                    WHERE C.RESP = @p_Resp   AND C.ALUNO  = A.ALUNO    
                        AND A.PESSOA = @v_PessoaAluno    
                        AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                        AND I.COBRANCA = C.COBRANCA       
                        AND I.BOLETO IS NULL       
                        AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                        AND (@p_cobranca_com_nota = 'S'   
          OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )   
                        AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                        AND EXISTS (SELECT IL.COBRANCA  
                                    FROM LY_ITEM_LANC IL  
                                    WHERE C.COBRANCA = IL.COBRANCA  
                                    GROUP BY IL.COBRANCA  
                                    HAVING SUM(IL.VALOR) >=0)  
                    ORDER BY I.COBRANCA, I.ITEMCOBRANCA                                               
                          
    
                    OPEN C_UPDATE_LY_ITEM_LANC_3          
                    FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_3 INTO @v_cobranca_update, @v_itemcobranca_update    
                            
                    WHILE (@@FETCH_STATUS = 0)          
                      BEGIN          
                        -- SE VALOR DA COBRANCA IGUAL A ZERO     
                        SELECT @v_valor_update = ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC WHERE COBRANCA = @v_cobranca_update                            
    
                        IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)    
                          UPDATE LY_ITEM_LANC WITH (ROWLOCK)          
                          SET Boleto = @v_Boleto          
                          WHERE cobranca = @v_cobranca_update          
                          AND itemcobranca = @v_itemcobranca_update          
                               
                          FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_3 INTO @v_cobranca_update, @v_itemcobranca_update   
                      END          
                              
                      CLOSE C_UPDATE_LY_ITEM_LANC_3          
                      DEALLOCATE C_UPDATE_LY_ITEM_LANC_3          
                  END            
                ELSE          
                  BEGIN          
                    DECLARE C_UPDATE_LY_ITEM_LANC_4 CURSOR FOR          
                    SELECT DISTINCT I.COBRANCA, I.ITEMCOBRANCA     
                    FROM LY_ITEM_LANC I, LY_COBRANCA C, LY_ITENS_AUX AUX, LY_ALUNO A          
                    WHERE C.RESP = @p_Resp   AND C.ALUNO  = A.ALUNO    
                        AND A.PESSOA = @v_PessoaAluno    
                        AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                        AND I.COBRANCA = C.COBRANCA       
                        AND C.COBRANCA = AUX.COBRANCA       
                        AND AUX.SESSAO_ID = @p_sessao_id       
                        AND I.BOLETO IS NULL       
                        AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                        AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )   
                        AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                        AND EXISTS (SELECT IL.COBRANCA  
                                    FROM LY_ITEM_LANC IL  
                                    WHERE C.COBRANCA = IL.COBRANCA  
                                    GROUP BY IL.COBRANCA  
                                    HAVING SUM(IL.VALOR) >=0)  
                    ORDER BY I.COBRANCA, I.ITEMCOBRANCA   
                          
                              
                    OPEN C_UPDATE_LY_ITEM_LANC_4          
                    FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_4 INTO @v_cobranca_update, @v_itemcobranca_update         
                            
                    WHILE (@@FETCH_STATUS = 0)          
                      BEGIN      
                        -- SE VALOR DA COBRANCA IGUAL A ZERO     
                        SELECT @v_valor_update = ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC WHERE COBRANCA = @v_cobranca_update    
    
                        IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)        
                          UPDATE LY_ITEM_LANC     
                          SET Boleto = @v_Boleto     
                          WHERE Cobranca = @v_cobranca_update     
                          AND Itemcobranca = @v_itemcobranca_update          
    
                          FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_4 INTO @v_cobranca_update, @v_itemcobranca_update         
                      END          
                               
                    CLOSE C_UPDATE_LY_ITEM_LANC_4          
                    DEALLOCATE C_UPDATE_LY_ITEM_LANC_4          
                  END -- ELSE -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                      
              END -- ELSE -- IF @v_BoletoUnico = 'S'      
    
  
       
    -- Retorna a empresa da LY_AGREGA_ITEM_COBRANCA pelo grupo de umas das dívidas dos     
    -- itens de cobrança do boleto    
    Select @v_empresa = isnull(empresa,'')     
    From LY_AGREGA_ITEM_COBRANCA    
 Where exists (     
        Select  grupo from ly_lanc_debito    
        Where exists (     
             select  lanc_deb from ly_item_lanc    
             where boleto = @v_Boleto  and ly_item_lanc.lanc_deb = ly_lanc_debito.lanc_deb  
             )     
  and LY_AGREGA_ITEM_COBRANCA.grupo =  ly_lanc_debito.grupo  
        and grupo is not null    
        )  and     
      empresa is not null and    
      banco = @p_Banco and    
      agencia = @p_Agencia and    
      conta_banco = @p_Conta and    
      (@p_Carteira is null or carteira = @p_Carteira)    
    order by empresa desc    
        
    If @v_empresa <> ''    
     Begin    
       Begin Tran TR_empresa    
       IF @v_boleto IS NOT NULL    
        BEGIN        
         EXEC LY_BOLETO_UPDATE @pkBoleto = @v_Boleto,               
               @empresa = @v_empresa    
         EXEC GetErrorsCount @v_ErrosCount OUTPUT            
                            
         IF @v_ErrosCount  > 0                
          ROLLBACK TRAN TR_empresa    
         ELSE    
          COMMIT TRAN TR_empresa    
        END     
       ELSE    
        COMMIT TRAN TR_empresa    
     End    
            -- -------------------------------------------------------------          
            -- *** Itens de crédito ***           
            -- -------------------------------------------------------------          
            IF @v_BoletoUnico = 'S'     
              BEGIN    
                IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                  BEGIN             
                    DECLARE C_UPDATE_LY_ITEM_CRED_5 CURSOR FOR          
                    SELECT DISTINCT CRED.LANC_CRED, CRED.ITEMCRED     
                    FROM LY_ITEM_CRED CRED, LY_COBRANCA COBR    
                    WHERE COBR.RESP = @p_Resp       
                    AND COBR.DATA_DE_VENCIMENTO = @v_dt_venc2       
                    AND CRED.COBRANCA = COBR.COBRANCA       
                    AND CRED.BOLETO IS NULL       
                    AND isnull(COBR.APENAS_COBRANCA, 'N') = 'N'       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = COBR.cobranca   
            AND dt_canc IS NULL ) )   
                    AND EXISTS (SELECT IL.COBRANCA  
                                FROM LY_ITEM_LANC IL  
                                WHERE COBR.COBRANCA = IL.COBRANCA  
                                GROUP BY IL.COBRANCA  
                                HAVING SUM(IL.VALOR) >=0)  
     ORDER BY CRED.LANC_CRED, CRED.ITEMCRED            
       
                    OPEN C_UPDATE_LY_ITEM_CRED_5          
                    FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_5 INTO @v_lanc_cred_update, @v_itemcred_update         
                                                 
                  WHILE (@@FETCH_STATUS = 0)          
                      BEGIN      
                        -- SE VALOR DA COBRANCA IGUAL A ZERO     
                        SELECT @v_valor_update = ISNULL(SUM(LY_ITEM_LANC.VALOR),0)     
                          FROM LY_ITEM_LANC, LY_ITEM_CRED, LY_COBRANCA     
                         WHERE LY_COBRANCA.COBRANCA = LY_ITEM_CRED.COBRANCA    
                           AND LY_COBRANCA.COBRANCA = LY_ITEM_LANC.COBRANCA    
                           AND LY_ITEM_CRED.LANC_CRED = @v_lanc_cred_update    
     
                        IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)        
                          BEGIN    
                            EXEC LY_ITEM_CRED_UPDATE @pkLanc_cred = @v_lanc_cred_update, @pkItemcred = @v_itemcred_update, @boleto = @v_Boleto          
                            EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                          
                            IF @v_ErrosCount  > 0          
                              BEGIN          
                                SELECT @v_Erro = 'Erro ao atualizar os itens de crédito que fazem parte do boleto (não usando cobranças pré-selecionadas)'          
                                EXEC SetErro @v_Erro, 'ITEMCREDITO'          
                                CLOSE C_UPDATE_LY_ITEM_CRED_5          
                                DEALLOCATE C_UPDATE_LY_ITEM_CRED_5          
                                CLOSE c_cobranca_origem2          
                                DEALLOCATE c_cobranca_origem2          
                                RETURN          
                              END -- IF @v_ErrosCount  > 0                   
                          END    
                        FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_5 INTO @v_lanc_cred_update, @v_itemcred_update    
                      END -- WHILE (@@FETCH_STATUS = 0)          
                                
                    CLOSE C_UPDATE_LY_ITEM_CRED_5          
                    DEALLOCATE C_UPDATE_LY_ITEM_CRED_5          
                  END            
                ELSE          
                  BEGIN          
                    DECLARE C_UPDATE_LY_ITEM_CRED_6 CURSOR FOR          
                    SELECT CRED.LANC_CRED, CRED.ITEMCRED    
                    FROM LY_ITEM_CRED CRED, LY_COBRANCA COBR, LY_ITENS_AUX AUX    
                    WHERE COBR.RESP = @p_Resp       
                    AND COBR.DATA_DE_VENCIMENTO = @v_dt_venc2       
                    AND CRED.COBRANCA = COBR.COBRANCA       
                    AND COBR.COBRANCA = AUX.COBRANCA       
                    AND AUX.SESSAO_ID = @p_sessao_id       
                    AND CRED.BOLETO IS NULL       
                    AND isnull(COBR.APENAS_COBRANCA, 'N') = 'N'       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = cobr.cobranca   
            AND dt_canc IS NULL ) )   
                    AND EXISTS (SELECT IL.COBRANCA  
                                FROM LY_ITEM_LANC IL  
                                WHERE COBR.COBRANCA = IL.COBRANCA  
                                GROUP BY IL.COBRANCA  
                                HAVING SUM(IL.VALOR) >=0)  
     ORDER BY CRED.LANC_CRED, CRED.ITEMCRED         
                          
                    OPEN C_UPDATE_LY_ITEM_CRED_6          
                    FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_6 INTO @v_lanc_cred_update, @v_itemcred_update         
                                     
                    WHILE (@@FETCH_STATUS = 0)          
                      BEGIN         
                        -- SE VALOR DA COBRANCA IGUAL A ZERO     
                        SELECT @v_valor_update = ISNULL(SUM(LY_ITEM_LANC.VALOR),0)     
                          FROM LY_ITEM_LANC, LY_ITEM_CRED, LY_COBRANCA     
                         WHERE LY_COBRANCA.COBRANCA = LY_ITEM_CRED.COBRANCA    
                           AND LY_COBRANCA.COBRANCA = LY_ITEM_LANC.COBRANCA    
                           AND LY_ITEM_CRED.LANC_CRED = @v_lanc_cred_update    
     
                        IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)    
                          BEGIN     
                            EXEC LY_ITEM_CRED_UPDATE @pkLanc_cred = @v_lanc_cred_update, @pkItemcred = @v_itemcred_update, @boleto = @v_Boleto          
                            EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                            
                            IF @v_ErrosCount  > 0          
                              BEGIN          
                                SELECT @v_Erro = 'Erro ao atualizar os itens de crédito que fazem parte do boleto (usando cobranças pré-selecionadas)'          
                                EXEC SetErro @v_Erro, 'ITEMCREDITO'          
                                CLOSE C_UPDATE_LY_ITEM_CRED_6          
                                DEALLOCATE C_UPDATE_LY_ITEM_CRED_6          
                                CLOSE c_cobranca_origem2          
                                DEALLOCATE c_cobranca_origem2          
                                RETURN          
                              END              
                          END                                       
                        FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_6 INTO @v_lanc_cred_update, @v_itemcred_update         
                      END          
                                  
                    CLOSE C_UPDATE_LY_ITEM_CRED_6          
                    DEALLOCATE C_UPDATE_LY_ITEM_CRED_6          
                  END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              END -- IF @v_BoletoUnico = 'S'                    ELSE    
              BEGIN    
                IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
                  BEGIN             
                        DECLARE C_UPDATE_LY_ITEM_CRED_7 CURSOR FOR          
                        SELECT DISTINCT CRED.LANC_CRED, CRED.ITEMCRED     
                        FROM LY_ITEM_CRED CRED, LY_COBRANCA COBR, LY_ALUNO A    
                        WHERE COBR.RESP = @p_Resp   AND COBR.ALUNO  = A.ALUNO     
                        AND A.PESSOA = @v_PessoaAluno    
                        AND COBR.DATA_DE_VENCIMENTO = @v_dt_venc2       
                        AND CRED.COBRANCA = COBR.COBRANCA       
                        AND CRED.BOLETO IS NULL       
                        AND isnull(COBR.APENAS_COBRANCA, 'N') = 'N'       
                        AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = cobr.cobranca   
            AND dt_canc IS NULL ) )   
                        AND EXISTS (SELECT IL.COBRANCA  
                                    FROM LY_ITEM_LANC IL  
                                    WHERE COBR.COBRANCA = IL.COBRANCA  
                                    GROUP BY IL.COBRANCA  
                                    HAVING SUM(IL.VALOR) >=0)  
      ORDER BY CRED.LANC_CRED, CRED.ITEMCRED           
    
                        OPEN C_UPDATE_LY_ITEM_CRED_7          
                        FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_7 INTO @v_lanc_cred_update, @v_itemcred_update        
                                                     
                        WHILE (@@FETCH_STATUS = 0)          
                          BEGIN          
                            -- SE VALOR DA COBRANCA IGUAL A ZERO     
                            SELECT @v_valor_update = ISNULL(SUM(LY_ITEM_LANC.VALOR),0)     
                              FROM LY_ITEM_LANC, LY_ITEM_CRED, LY_COBRANCA     
                             WHERE LY_COBRANCA.COBRANCA = LY_ITEM_CRED.COBRANCA    
                               AND LY_COBRANCA.COBRANCA = LY_ITEM_LANC.COBRANCA    
                               AND LY_ITEM_CRED.LANC_CRED = @v_lanc_cred_update    
    
                             IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)    
                              BEGIN         
                                EXEC LY_ITEM_CRED_UPDATE @pkLanc_cred = @v_lanc_cred_update, @pkItemcred = @v_itemcred_update, @boleto = @v_Boleto          
                                EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                              
                                IF @v_ErrosCount  > 0          
                                  BEGIN          
                                    SELECT @v_Erro = 'Erro ao atualizar os itens de crédito que fazem parte do boleto (não usando cobranças pré-selecionadas)'          
                                    EXEC SetErro @v_Erro, 'ITEMCREDITO'          
                                    CLOSE C_UPDATE_LY_ITEM_CRED_7          
                                    DEALLOCATE C_UPDATE_LY_ITEM_CRED_7          
                                    CLOSE c_cobranca_origem2          
                                    DEALLOCATE c_cobranca_origem2          
                                    RETURN          
                                  END -- IF @v_ErrosCount  > 0                   
                              END    
                            FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_7 INTO @v_lanc_cred_update, @v_itemcred_update          
                          END -- WHILE (@@FETCH_STATUS = 0)          
                                    
                        CLOSE C_UPDATE_LY_ITEM_CRED_7          
                        DEALLOCATE C_UPDATE_LY_ITEM_CRED_7          
                      END            
                ELSE          
                  BEGIN          
                    DECLARE C_UPDATE_LY_ITEM_CRED_8 CURSOR FOR          
                    SELECT CRED.LANC_CRED, CRED.ITEMCRED     
                    FROM LY_ITEM_CRED CRED, LY_COBRANCA COBR, LY_ITENS_AUX AUX, LY_ALUNO A    
                    WHERE COBR.RESP = @p_Resp   AND COBR.ALUNO  = A.ALUNO     
                          AND A.PESSOA = @v_PessoaAluno    
                          AND COBR.DATA_DE_VENCIMENTO = @v_dt_venc2       
                          AND CRED.COBRANCA = COBR.COBRANCA       
                          AND COBR.COBRANCA = AUX.COBRANCA       
                          AND AUX.SESSAO_ID = @p_sessao_id       
                          AND CRED.BOLETO IS NULL       
                          AND isnull(COBR.APENAS_COBRANCA, 'N') = 'N'       
                          AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = cobr.cobranca   
            AND dt_canc IS NULL ) )   
                          AND EXISTS (SELECT IL.COBRANCA  
                                      FROM LY_ITEM_LANC IL  
                                      WHERE COBR.COBRANCA = IL.COBRANCA  
                                      GROUP BY IL.COBRANCA  
                                      HAVING SUM(IL.VALOR) >=0)  
     ORDER BY CRED.LANC_CRED, CRED.ITEMCRED            
                              
                    OPEN C_UPDATE_LY_ITEM_CRED_8          
                    FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_8 INTO @v_lanc_cred_update, @v_itemcred_update        
                                         
                    WHILE (@@FETCH_STATUS = 0)          
                      BEGIN          
                        -- SE VALOR DA COBRANCA IGUAL A ZERO     
                        SELECT @v_valor_update = ISNULL(SUM(LY_ITEM_LANC.VALOR),0)     
                          FROM LY_ITEM_LANC, LY_ITEM_CRED, LY_COBRANCA     
                         WHERE LY_COBRANCA.COBRANCA = LY_ITEM_CRED.COBRANCA    
                           AND LY_COBRANCA.COBRANCA = LY_ITEM_LANC.COBRANCA    
                           AND LY_ITEM_CRED.LANC_CRED = @v_lanc_cred_update    
    
                        IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)    
                          BEGIN    
                            EXEC LY_ITEM_CRED_UPDATE @pkLanc_cred = @v_lanc_cred_update, @pkItemcred = @v_itemcred_update, @boleto = @v_Boleto          
                            EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                                
                            IF @v_ErrosCount  > 0          
                              BEGIN          
                                SELECT @v_Erro = 'Erro ao atualizar os itens de crédito que fazem parte do boleto (usando cobranças pré-selecionadas)'          
                                EXEC SetErro @v_Erro, 'ITEMCREDITO'          
                                CLOSE C_UPDATE_LY_ITEM_CRED_8          
                                DEALLOCATE C_UPDATE_LY_ITEM_CRED_8          
                                CLOSE c_cobranca_origem2          
                                DEALLOCATE c_cobranca_origem2          
                                RETURN          
                              END              
                          END                                          
                        FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_8 INTO @v_lanc_cred_update, @v_itemcred_update         
                      END          
                                      
                    CLOSE C_UPDATE_LY_ITEM_CRED_8          
                    DEALLOCATE C_UPDATE_LY_ITEM_CRED_8          
                  END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'             
              END -- ELSE -- -- IF @v_BoletoUnico = 'S'       
    
            -- -------------------------------------------------------    
            -- CHAMA a_Numero_RPS    
            -- -------------------------------------------------------        
            IF @v_boleto is not null    
           BEGIN         
                SELECT @v_faculdade = t3.faculdade     
                FROM ly_aluno t1, ly_cobranca t2, ly_curso t3, ly_item_lanc t4       
                WHERE t1.aluno = t2.aluno     
                      AND t1.curso = t3.curso     
                      AND t2.cobranca = @v_cobranca    
                      AND t2.cobranca = t4.cobranca    
                    
              BEGIN TRAN TR_NumeroRps    
                  
                     
                EXEC a_numero_RPS @v_faculdade, @v_Boleto, @p_resp, @v_numeroRPS output, @v_ValorServicoRPS output, @v_ValorDeducaoRPS output, 'GER_BOLETO', @v_NotaFiscalSerie output, null, null            
                    
                EXEC GetDataDiaSemHora @v_data_emissao_rps output          
                    
                IF @v_numeroRPS IS NOT NULL    
                  BEGIN        
                    EXEC LY_BOLETO_UPDATE @pkBoleto = @v_Boleto,               
                                          @numero_rps = @v_NumeroRPS,              
                                          @data_emissao_rps = @v_data_emissao_rps,  
                                          @nota_fiscal_serie = @v_NotaFiscalSerie  
                                                 
                 EXEC GetErrorsCount @v_ErrosCount OUTPUT            
                            
                    IF @v_ErrosCount  > 0                
                    ROLLBACK TRAN TR_NumeroRps    
                   ELSE    
                      COMMIT TRAN TR_NumeroRps    
                  END     
                ELSE    
                  COMMIT TRAN TR_NumeroRps     
              END -- IF @v_boleto is not null    
                
            --**Verificar se é servico pré-pago(pega as instrucoes_servico ao inves de instrucoes)**----          
            SELECT  @v_pgto_pre_exec = SERV.PAGAMENTO_PRE_EXECUCAO       
            FROM LY_ITEM_LANC ITEM, LY_ITENS_SOLICIT_SERV  ITEM_SERV, LY_TABELA_SERVICOS SERV          
            WHERE ITEM.BOLETO = @v_Boleto            
            AND ITEM.LANC_DEB = ITEM_SERV.LANC_DEB           
            AND ITEM_SERV.SERVICO =  SERV.SERVICO          
                     
            IF @v_pgto_pre_exec = 'S'            
            BEGIN  -- Pagamento pré execução              
              -- *** Obtenção das instruções do boleto de servicos  *** --            
              SELECT @v_Instrucoes = INSTRUCOES_SERVICO             
              FROM LY_OPCOES_BOLETO            
              WHERE BANCO = @p_Banco       
              AND AGENCIA = @p_Agencia       
              AND CONTA_BANCO = @p_Conta       
              AND CARTEIRA = @p_Carteira            
            END                      
            ELSE              
            BEGIN            
              --Verificar se é acordo                        
              SELECT  @v_bol_acordo = C.NUM_COBRANCA   
              FROM LY_COBRANCA C inner join LY_ITEM_LANC I ON C.COBRANCA  = I.COBRANCA  
              WHERE I.BOLETO = @v_Boleto   
                        
              IF @v_bol_acordo = 3          
                BEGIN          
                  -- *** Obtenção das instruções do boleto de acordo *** --            
                  SELECT @v_Instrucoes = INSTRUCOES_ACORDO FROM LY_OPCOES_BOLETO            
                  WHERE BANCO = @p_Banco       
                        AND AGENCIA = @p_Agencia       
                        AND CONTA_BANCO = @p_Conta       
                        AND CARTEIRA = @p_Carteira            
                END                             
              ELSE  
                BEGIN          
                  -- Verificar se é serviço  
                  IF  @v_bol_acordo = 2  
                    BEGIN  
                      -- *** Obtenção das instruções do boleto de servicos  *** --            
                      SELECT @v_Instrucoes = INSTRUCOES_SERVICO             
                      FROM LY_OPCOES_BOLETO            
                      WHERE BANCO = @p_Banco       
                            AND AGENCIA = @p_Agencia       
                            AND CONTA_BANCO = @p_Conta       
                            AND CARTEIRA = @p_Carteira            
                    END   
                  ELSE  
                    BEGIN          
                      -- *** Obtenção das instruções do boleto *** --            
                      SELECT @v_Instrucoes = INSTRUCOES FROM LY_OPCOES_BOLETO            
                      WHERE BANCO = @p_Banco AND AGENCIA = @p_Agencia AND CONTA_BANCO = @p_Conta AND CARTEIRA = @p_Carteira            
                    END -- IF  @v_bol_acordo = 2  
                END -- IF @v_bol_acordo = 3               
            END -- IF @v_pgto_pre_exec = 'S'                 
                        
            EXEC GET_ERROR_ID @v_Erros_ID          
                                  
            IF @v_Erros_ID <> 0          
            BEGIN          
              SET @v_straux1 = convert(varchar(50),@p_banco)          
              SET @v_straux2 = convert(varchar(50),@p_Agencia)          
              SET @v_straux3 = convert(varchar(50),@p_Conta)          
              SELECT @v_Erro = 'Erro ao obter as instruções do boleto para o banco/agencia/conta: ' + @v_straux1 + '/' + @v_straux2 + '/' + @v_straux3          
              EXEC SetErro @v_Erro, 'BANCO'          
              CLOSE c_cobranca_origem2          
              DEALLOCATE c_cobranca_origem2          
              RETURN          
            END              
                   
            EXEC ADICIONA_INSTRUCAO @p_sessao_id, @v_Boleto, @v_instrucoes OUTPUT          
            EXEC a_Identif_Cliente @v_Boleto, @p_Resp       
            EXEC a_Nosso_Numero @v_Boleto, @p_Banco, @p_Agencia, @p_Conta, @p_Convenio, @p_Carteira, @p_Resp, @v_NossoNumero output                 
    
            -- ---------------------------------------------------------------------------------------      
            -- DEBITO AUTOMATICO - inicio      
            -- ---------------------------------------------------------------------------------------      
            select @v_num_cobranca = NUM_COBRANCA FROM LY_COBRANCA WHERE COBRANCA = @v_cobranca            
                                       
            IF @v_num_cobranca = 3     
            BEGIN    
              SET @v_DebitoAutomaticoAluno = 'N'    
              SET @v_Debaut_Banco = null      
              SET @v_Debaut_Agencia = null      
              SET @v_Debaut_Conta_Banco = null      
              SET @v_Dv_Agencia = null       
              SET @v_Dv_Conta = null       
              SET @v_Dv_Agencia_Conta = null       
              SET @v_Operacao = null       
            END    
                                        
            ELSE    
            BEGIN  
       
         INSERT INTO LY_PLANOPGTOESPEC_AUX ( RESP, LANC_DEB, SESSAO_ID )          
                  SELECT b.RESP, pe.LANC_DEB, @p_sessao_id          
                  FROM LY_PLANO_PGTO_ESPECIAL pe, LY_LANC_DEBITO d, LY_ITEM_LANC ic, LY_BOLETO b          
                  WHERE ic.BOLETO = b.BOLETO       
                  AND ic.LANC_DEB = d.LANC_DEB                                  
                  AND b.RESP = pe.RESP   
         AND d.LANC_DEB = pe.LANC_DEB                     
                  AND pe.BANCO is not null       
                  AND pe.AGENCIA is not null       
                  AND pe.CONTA_BANCO is not null       
                  AND b.BOLETO = @v_boleto          
                  GROUP BY b.RESP, pe.LANC_DEB  
           
         SET @v_Debaut_Banco = null    
                  SET @v_Debaut_Agencia = null    
                  SET @v_Debaut_Conta_Banco = null    
                  SET @v_Dv_Agencia = null     
                  SET @v_Dv_Conta = null     
                  SET @v_Dv_Agencia_Conta = null     
                  SET @v_Operacao = null  
           
         SELECT @v_Debaut_Banco = pe.BANCO, @v_Debaut_Agencia = pe.AGENCIA,         
                  @v_Debaut_Conta_Banco = pe.CONTA_BANCO, @v_Dv_Agencia = pe.DV_AGENCIA,        
                  @v_Dv_Conta = pe.DV_CONTA, @v_Dv_Agencia_Conta = pe.DV_AGENCIA_CONTA,        
                  @v_Operacao = pe.OPERACAO        
                  FROM LY_PLANO_PGTO_ESPECIAL pe, LY_PLANOPGTOESPEC_AUX pa        
                  WHERE pe.LANC_DEB = pa.LANC_DEB                 
                  AND pe.RESP = pa.RESP                   
                  AND SESSAO_ID = @p_sessao_id  
           
         SET @v_DebitoAutomaticoAluno = 'N'  
           
         IF @v_Debaut_Banco is not null SET @v_DebitoAutomaticoAluno = 'S'  
           
         DECLARE C_PLANOPGTOESPEC_AUX CURSOR READ_ONLY FOR        
                  SELECT RESP, LANC_DEB FROM LY_PLANOPGTOESPEC_AUX WHERE Sessao_id = @p_sessao_id        
                        
                  OPEN C_PLANOPGTOESPEC_AUX        
                  FETCH NEXT FROM C_PLANOPGTOESPEC_AUX INTO @v_resp, @v_Lanc_deb        
                            
                  WHILE @@fetch_status = 0        
                  BEGIN        
                    EXEC LY_PLANOPGTOESPEC_AUX_Delete @pkSessao_id = @p_sessao_id,        
                    @pkresp= @v_resp,        
                    @pkLanc_deb = @v_Lanc_deb  
                        
                    FETCH NEXT FROM C_PLANOPGTOESPEC_AUX INTO @v_resp, @v_Lanc_deb      
                  END        
                            
                  CLOSE C_PLANOPGTOESPEC_AUX        
                  DEALLOCATE C_PLANOPGTOESPEC_AUX  
           
         IF @v_DebitoAutomaticoAluno = 'N'  
            BEGIN                          
                
              INSERT INTO LY_PLANOPGTOPERIODO_AUX ( RESP, ANO, PERIODO, ALUNO, SESSAO_ID )          
              SELECT b.RESP, pp.ANO, pp.PERIODO, pp.ALUNO,  @p_sessao_id          
              FROM LY_PLANO_PGTO_PERIODO pp, LY_LANC_DEBITO d, LY_ITEM_LANC ic, LY_BOLETO b          
              WHERE ic.BOLETO = b.BOLETO       
              AND ic.LANC_DEB = d.LANC_DEB       
              AND d.ANO_REF = pp.ANO       
              AND d.PERIODO_REF = pp.PERIODO       
              AND b.RESP = pp.RESP       
              AND d.ALUNO = pp.ALUNO       
              AND pp.BANCO is not null       
              AND pp.AGENCIA is not null       
              AND pp.CONTA_BANCO is not null       
              AND b.BOLETO = @v_boleto          
              GROUP BY b.RESP, pp.ANO, pp.PERIODO, pp.ALUNO          
                                  
                    
              SELECT @v_Debaut_Banco = pp.BANCO, @v_Debaut_Agencia = pp.AGENCIA,           
              @v_Debaut_Conta_Banco = pp.CONTA_BANCO, @v_Dv_Agencia = pp.DV_AGENCIA,          
              @v_Dv_Conta = pp.DV_CONTA, @v_Dv_Agencia_Conta = pp.DV_AGENCIA_CONTA,          
              @v_Operacao = pp.OPERACAO          
              FROM LY_PLANO_PGTO_PERIODO pp, LY_PLANOPGTOPERIODO_AUX pa          
              WHERE pp.ANO = pa.ANO       
              AND pp.PERIODO = pa.PERIODO       
              AND pp.RESP = pa.RESP       
              AND pp.ALUNO = pa.ALUNO       
              AND SESSAO_ID = @p_sessao_id          
                                                          
              IF @v_Debaut_Banco is not null SET @v_DebitoAutomaticoAluno = 'S'     
                      
              DECLARE C_PLANOPGTO_PERIODO_AUX CURSOR READ_ONLY FOR          
              SELECT RESP, ANO, PERIODO, ALUNO FROM LY_PLANOPGTOPERIODO_AUX WHERE Sessao_id = @p_sessao_id          
                      
              OPEN C_PLANOPGTO_PERIODO_AUX          
              FETCH NEXT FROM C_PLANOPGTO_PERIODO_AUX INTO @v_resp, @v_ano, @v_periodo, @v_aluno          
                          
              WHILE @@fetch_status = 0          
              BEGIN          
                DELETE FROM LY_PLANOPGTOPERIODO_AUX   
                WHERE Sessao_id = @p_sessao_id AND resp= @v_resp  
                      AND ano = @v_ano AND periodo = @v_periodo AND aluno = @v_aluno  
                       
                  
                FETCH NEXT FROM C_PLANOPGTO_PERIODO_AUX INTO @v_resp, @v_ano, @v_periodo, @v_aluno          
              END          
                          
              CLOSE C_PLANOPGTO_PERIODO_AUX          
              DEALLOCATE C_PLANOPGTO_PERIODO_AUX            
            END   
              
            IF @v_DebitoAutomaticoAluno = 'N' AND @v_DebitoAutomaticoResp = 'S'    
              BEGIN    
                SELECT @v_Debaut_Banco = BANCO, @v_Debaut_Agencia = AGENCIA,         
                @v_Debaut_Conta_Banco = CONTA_BANCO, @v_Dv_Agencia = DV_AGENCIA,        
                @v_Dv_Conta = DV_CONTA, @v_Dv_Agencia_Conta = DV_AGENCIA_CONTA,        
                @v_Operacao = OPERACAO        
                FROM LY_RESP_FINAN        
                WHERE RESP = @p_resp        
                  
                IF @v_Debaut_Banco is not null SET @v_DebitoAutomaticoAluno = 'S'     
              END   
        
            END --IF @num_cobranca = 3    
              
            EXEC s_DEBITO_AUTOMATICO @p_Resp,   
                                     @v_cobranca,   
                                     @v_DebitoAutomaticoResp OUTPUT,   
                                     @v_DebitoAutomaticoAluno OUTPUT,   
                                     @v_Debaut_Banco OUTPUT,   
                                     @v_Debaut_Agencia OUTPUT,   
                                     @v_Debaut_Conta_Banco OUTPUT,   
                                     @v_Dv_Agencia OUTPUT,   
                                     @v_Dv_Conta OUTPUT,   
                                     @v_Dv_Agencia_Conta OUTPUT,   
                                     @v_Operacao OUTPUT   
              
            SET @v_DebitoAutomatico = 'N'  
              
            IF @v_Debaut_Banco is not null SET @v_DebitoAutomatico = 'S'  
                                         
            -- ---------------------------------------------------------------------------------------      
            -- DEBITO AUTOMATICO - fim      
            -- ---------------------------------------------------------------------------------------      
                    
            -- ------------------------------------------------          
            --  Complementação das informações do boleto          
            -- ------------------------------------------------          
            EXEC GetDataDiaSemHora @aux_dt output          
                  
            EXEC LY_BOLETO_UPDATE          
            @pkBoleto = @v_Boleto,           
            @Banco = @p_Banco,           
            @Agencia = @p_Agencia,           
            @Conta_banco = @p_Conta,           
            @Resp = @p_Resp,           
            @Data_proc = @aux_dt,           
            @Nosso_numero = @v_NossoNumero,           
            @Instrucoes = @v_Instrucoes,           
            @Lote = @p_Lote,           
            @Arquivo_retorno = NULL,           
            @Debito_automatico = @v_DebitoAutomatico,           
            @Debito_auto_cancelado = 'N',           
            @Removido = 'N',           
            @Aceito = 'N',           
            @Impresso = 'N',          
            @Enviado = 'N',           
            @Env_Cancel = 'N',           
            @Cancel_Banco = 'N',           
            @Carteira = @p_Carteira,           
            @Obs = NULL,        
            @DebAut_Banco = @v_Debaut_Banco,           
            @Debaut_Agencia = @v_Debaut_Agencia,           
            @Debaut_Conta_banco = @v_Debaut_Conta_Banco,           
            @Dv_Agencia = @v_Dv_Agencia,           
            @Dv_Conta = @v_Dv_Conta,           
            @Dv_Agencia_Conta = @v_Dv_Agencia_Conta,           
            @Operacao = @v_Operacao         
    
                   
            EXEC GetErrorsCount @v_ErrosCount OUTPUT          
                          
            IF @v_ErrosCount  > 0          
            BEGIN          
              SELECT @v_Erro = 'Erro ao atualizar boleto para o responsável financeiro ' + @p_Resp          
              EXEC SetErro @v_Erro, 'RESP'          
              CLOSE c_cobranca_origem2          
              DEALLOCATE c_cobranca_origem2          
              RETURN          
            END -- IF @v_ErrosCount  > 0                
    
          END -- IF (@v_ValorBoleto > 0 and @p_Apartir_Valor is null) or (@v_ItensBoleto > 0 and @v_ValorBoleto = 0 AND @p_boleto_zerado = 'S')            
                           
        -- -----------------------------------------------------------------------------          
        --  Atulizar as cobranças (as cobranças sempre serão faturadas)             
        -- -----------------------------------------------------------------------------          
        IF @v_BoletoUnico = 'S'     
          BEGIN    
            IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              BEGIN          
                DECLARE C_UPDATE_LY_COBRANCA_9 CURSOR FOR          
                SELECT DISTINCT  C.COBRANCA FROM LY_COBRANCA C    
                WHERE C.RESP = @p_Resp       
                AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                AND C.DATA_DE_FATURAMENTO IS NULL       
                AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )   
                AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
                AND EXISTS (SELECT IL.COBRANCA  
                            FROM LY_ITEM_LANC IL  
                            WHERE C.COBRANCA = IL.COBRANCA  
                            GROUP BY IL.COBRANCA  
                            HAVING SUM(IL.VALOR) >=0)  
                ORDER BY C.COBRANCA  
             
                OPEN C_UPDATE_LY_COBRANCA_9          
                FETCH NEXT FROM C_UPDATE_LY_COBRANCA_9 INTO @v_cobranca_update          
                           
                WHILE (@@FETCH_STATUS = 0)          
                BEGIN          
                  EXEC GetDataDiaSemHora @aux_dt output          
                  EXEC LY_COBRANCA_UPDATE @pkCobranca = @v_cobranca_update, @data_de_faturamento = @aux_dt          
                  EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                        
                  IF @v_ErrosCount  > 0          
                  BEGIN          
                    SET @v_straux1 = convert(varchar(50),@v_cobranca_update)          
                    SELECT @v_Erro = 'Erro ao atualizar a data de faturamento da cobranca ' + @v_straux1          
                    EXEC SetErro @v_Erro, 'DATA_DE_FATURAMENTO'          
                    CLOSE C_UPDATE_LY_COBRANCA_9          
                    DEALLOCATE C_UPDATE_LY_COBRANCA_9          
                    CLOSE c_cobranca_origem2          
                    DEALLOCATE c_cobranca_origem2          
                    RETURN          
                  END              
                       
                  FETCH NEXT FROM C_UPDATE_LY_COBRANCA_9 INTO @v_cobranca_update          
                END          
                      
                CLOSE C_UPDATE_LY_COBRANCA_9          
                DEALLOCATE C_UPDATE_LY_COBRANCA_9          
                       
                FETCH NEXT FROM c_cobranca_origem2 INTO  @v_dt_venc2, @v_PessoaAluno    
              END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'                
            ELSE          
              BEGIN          
                DECLARE C_UPDATE_LY_COBRANCA_10 CURSOR FOR          
                SELECT DISTINCT COBR.COBRANCA FROM LY_COBRANCA COBR, LY_ITENS_AUX AUX    
                WHERE COBR.RESP = @p_Resp       
                AND COBR.DATA_DE_VENCIMENTO = @v_dt_venc2       
                AND COBR.DATA_DE_FATURAMENTO IS NULL       
                AND COBR.COBRANCA = AUX.COBRANCA       
                AND isnull(COBR.APENAS_COBRANCA, 'N') = 'N'       
                AND AUX.SESSAO_ID = @p_sessao_id       
                AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = cobr.cobranca   
            AND dt_canc IS NULL ) )   
                AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = COBR.ALUNO AND SESSAO_ID = @p_sessao_id)    
                AND EXISTS (SELECT IL.COBRANCA  
                            FROM LY_ITEM_LANC IL  
                            WHERE COBR.COBRANCA = IL.COBRANCA  
                            GROUP BY IL.COBRANCA  
                            HAVING SUM(IL.VALOR) >=0)  
                ORDER BY COBR.COBRANCA                              
  
                     
                OPEN C_UPDATE_LY_COBRANCA_10          
                FETCH NEXT FROM C_UPDATE_LY_COBRANCA_10 INTO @v_cobranca_update          
                   
                WHILE (@@FETCH_STATUS = 0)          
                BEGIN          
                  EXEC GetDataDiaSemHora @aux_dt output          
                  EXEC LY_COBRANCA_UPDATE @pkCobranca = @v_cobranca_update, @data_de_faturamento = @aux_dt          
                  EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                        
                  IF @v_ErrosCount  > 0          
                  BEGIN          
                    SET @v_straux1 = convert(varchar(50),@v_cobranca_update)          
                    SELECT @v_Erro = 'Erro ao atualizar a data de faturamento da cobranca ' + @v_straux1          
                    EXEC SetErro @v_Erro, 'DATA_DE_FATURAMENTO'          
                    CLOSE C_UPDATE_LY_COBRANCA_10          
                    DEALLOCATE C_UPDATE_LY_COBRANCA_10          
                    RETURN          
                  END              
                             
                  FETCH NEXT FROM C_UPDATE_LY_COBRANCA_10 INTO @v_cobranca_update          
                END          
                CLOSE C_UPDATE_LY_COBRANCA_10          
                DEALLOCATE C_UPDATE_LY_COBRANCA_10          
                              
                FETCH NEXT FROM c_cobranca_origem2 INTO  @v_dt_venc2, @v_PessoaAluno    
              END -- ELSE -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'      
          END -- IF @v_BoletoUnico = 'S'     
        ELSE    
          BEGIN    
            IF @p_Usa_Cobr_Pre_Selecionadas = 'N'          
              BEGIN          
                DECLARE C_UPDATE_LY_COBRANCA_11 CURSOR FOR          
                SELECT DISTINCT  C.COBRANCA FROM LY_COBRANCA C, LY_ALUNO A    
                WHERE C.RESP = @p_Resp    AND C.ALUNO  = A.ALUNO    
                    AND A.PESSOA = @v_PessoaAluno    
                    AND C.DATA_DE_VENCIMENTO = @v_dt_venc2       
                    AND C.DATA_DE_FATURAMENTO IS NULL       
                    AND isnull(C.APENAS_COBRANCA, 'N') = 'N'       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )   
                    AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)        
                    AND EXISTS (SELECT IL.COBRANCA  
                                FROM LY_ITEM_LANC IL  
                                WHERE C.COBRANCA = IL.COBRANCA  
                                GROUP BY IL.COBRANCA  
                                HAVING SUM(IL.VALOR) >=0)  
                ORDER BY C.COBRANCA      
                                 
                OPEN C_UPDATE_LY_COBRANCA_11          
                FETCH NEXT FROM C_UPDATE_LY_COBRANCA_11 INTO @v_cobranca_update          
                               
                WHILE (@@FETCH_STATUS = 0)          
                  BEGIN          
                      EXEC GetDataDiaSemHora @aux_dt output          
                      EXEC LY_COBRANCA_UPDATE @pkCobranca = @v_cobranca_update, @data_de_faturamento = @aux_dt          
                      EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                            
                      IF @v_ErrosCount  > 0          
                      BEGIN          
                        SET @v_straux1 = convert(varchar(50),@v_cobranca_update)          
                        SELECT @v_Erro = 'Erro ao atualizar a data de faturamento da cobranca ' + @v_straux1          
                        EXEC SetErro @v_Erro, 'DATA_DE_FATURAMENTO'          
                        CLOSE C_UPDATE_LY_COBRANCA_11          
                        DEALLOCATE C_UPDATE_LY_COBRANCA_11          
                        CLOSE c_cobranca_origem2          
                        DEALLOCATE c_cobranca_origem2          
                        RETURN          
                      END              
                           
                      FETCH NEXT FROM C_UPDATE_LY_COBRANCA_11 INTO @v_cobranca_update          
                  END          
                          
                CLOSE C_UPDATE_LY_COBRANCA_11          
                DEALLOCATE C_UPDATE_LY_COBRANCA_11          
                           
                FETCH NEXT FROM c_cobranca_origem2 INTO  @v_dt_venc2, @v_PessoaAluno    
              END -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'                
            ELSE          
              BEGIN          
                DECLARE C_UPDATE_LY_COBRANCA_12 CURSOR FOR          
                SELECT DISTINCT COBR.COBRANCA FROM LY_COBRANCA COBR, LY_ITENS_AUX AUX, LY_ALUNO A    
                WHERE COBR.RESP = @p_Resp   AND COBR.ALUNO  = A.ALUNO     
                    AND A.PESSOA = @v_PessoaAluno    
                    AND COBR.DATA_DE_VENCIMENTO = @v_dt_venc2       
                    AND COBR.DATA_DE_FATURAMENTO IS NULL       
                    AND COBR.COBRANCA = AUX.COBRANCA       
                    AND isnull(COBR.APENAS_COBRANCA, 'N') = 'N'       
     AND AUX.SESSAO_ID = @p_sessao_id       
                    AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = cobr.cobranca   
            AND dt_canc IS NULL ) )   
                    AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = COBR.ALUNO AND SESSAO_ID = @p_sessao_id)          
                    AND EXISTS (SELECT IL.COBRANCA  
                                FROM LY_ITEM_LANC IL  
                                WHERE COBR.COBRANCA = IL.COBRANCA  
                                GROUP BY IL.COBRANCA  
                                HAVING SUM(IL.VALOR) >=0)  
                ORDER BY COBR.COBRANCA      
                                         
                OPEN C_UPDATE_LY_COBRANCA_12          
                FETCH NEXT FROM C_UPDATE_LY_COBRANCA_12 INTO @v_cobranca_update          
                       
                WHILE (@@FETCH_STATUS = 0)          
                  BEGIN          
                      EXEC GetDataDiaSemHora @aux_dt output          
                      EXEC LY_COBRANCA_UPDATE @pkCobranca = @v_cobranca_update, @data_de_faturamento = @aux_dt          
                      EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                            
                      IF @v_ErrosCount  > 0          
                      BEGIN          
                        SET @v_straux1 = convert(varchar(50),@v_cobranca_update)          
                        SELECT @v_Erro = 'Erro ao atualizar a data de faturamento da cobranca ' + @v_straux1          
                        EXEC SetErro @v_Erro, 'DATA_DE_FATURAMENTO'          
                        CLOSE C_UPDATE_LY_COBRANCA_12          
                        DEALLOCATE C_UPDATE_LY_COBRANCA_12          
                        RETURN          
                      END              
        
                      FETCH NEXT FROM C_UPDATE_LY_COBRANCA_12 INTO @v_cobranca_update          
                  END          
                CLOSE C_UPDATE_LY_COBRANCA_12          
                DEALLOCATE C_UPDATE_LY_COBRANCA_12          
                                  
                FETCH NEXT FROM c_cobranca_origem2 INTO  @v_dt_venc2, @v_PessoaAluno                  
              END -- ELSE -- IF @p_Usa_Cobr_Pre_Selecionadas = 'N'      
          END -- ELSE -- -- IF @v_BoletoUnico = 'S'    
      
    ---------------------------------------------    
    -- CALCULA E GRAVA DATA DE VALIDADE DO BOLETO  
    -- ------------------------------------------   
      
    SELECT @V_PRAZO_BAIXA = PRAZO_BAIXA FROM LY_CONTA_CONVENIO CC   
    INNER JOIN LY_BOLETO BO ON BO.BANCO = CC.BANCO AND BO.AGENCIA = CC.AGENCIA AND BO.CONTA_BANCO = CC.CONTA_BANCO   
    AND BO.CARTEIRA = CC.CARTEIRA AND BO.CONVENIO = CC.CONVENIO  
    WHERE BO.BOLETO = @v_boletoParaRegistro  
      
    --chama EP para substituir prazo de baixa  
      
    exec s_prazo_baixa_boleto @v_boletoParaRegistro, @p_substitui_prazo output, @p_novo_prazo output  
    if @p_substitui_prazo = 'S'  
    begin  
    set @V_PRAZO_BAIXA = isnull(@p_novo_prazo,@p_novo_prazo)  
    end  
      
    IF @V_PRAZO_BAIXA is not null  
    BEGIN  
      SET @V_DATA_VALIDADE = (select dateadd(day,@V_PRAZO_BAIXA,@p_DtVenc))  
    UPDATE LY_BOLETO_UNIFICADO SET DATA_VALIDADE = @V_DATA_VALIDADE  WHERE ID_BOLETO = @v_boletoParaRegistro  
    END  
      
     ---------------------------------------------    
    -- INSERE BOLETO NA FILA PARA SER REGISTRADO   
    -- ------------------------------------------   
    IF @v_boletoParaRegistro IS NOT NULL -- se existe código do boleto tenta colocalo na fila para registro segundo configurações de plugin de boleto  
    BEGIN  
     EXEC INSERE_PEDIDO_REGISTRO_BOLETO @v_boletoParaRegistro, 'Registro'     
    END  
    --------------------------------------------------------    
    -- ## FIM ## INSERE BOLETO NA FILA PARA SER REGISTRADO   ## FIM ##   
    -- -----------------------------------------------------         
                                    
      END -- while em c_cobranca_origem2          
            
      CLOSE c_cobranca_origem2          
      DEALLOCATE c_cobranca_origem2          
    END  -- IF @v_BoletoUnico = 'S'                 
          
    ELSE          
    BEGIN          
      -- ***** UM BOLETO PARA CADA COBRANÇA *****          
      -- Selecione as cobranças          
      DECLARE c_cobranca_origem CURSOR READ_ONLY FOR          
      SELECT C.COBRANCA, C.DATA_DE_VENCIMENTO, C.APENAS_COBRANCA FROM LY_COBRANCA C          
      WHERE C.RESP = @p_Resp       
      AND C.DATA_DE_VENCIMENTO = @p_dtVenc       
      AND @p_Usa_Cobr_Pre_Selecionadas = 'N'    
      AND ((@p_tipo_cobranca is NOT null AND C.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)       
      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = C.cobranca   
            AND dt_canc IS NULL ) )         
      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)         
      UNION          
      SELECT I.COBRANCA, C.DATA_DE_VENCIMENTO, C.APENAS_COBRANCA FROM LY_ITENS_AUX I, LY_COBRANCA C          
      WHERE C.RESP = @p_Resp       
      AND C.COBRANCA = I.COBRANCA       
      AND I.SESSAO_ID = @p_sessao_id       
      AND @p_Usa_Cobr_Pre_Selecionadas = 'S'      
      AND ((@p_tipo_cobranca is NOT null AND C.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)      
      AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )   
      AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)    
      ORDER BY C.COBRANCA, C.DATA_DE_VENCIMENTO  
    
      OPEN c_cobranca_origem           
      FETCH NEXT FROM c_cobranca_origem INTO @v_Cobranca, @v_dt_venc, @v_apenas_cobranca          
            
      WHILE @@FETCH_STATUS = 0          
      BEGIN    
            
        -- VERIFICA SE A COBRANÇA FOI PRÉ-ACORDADA    
        SELECT @v_Cont = ISNULL(COUNT(*),0)    
          FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO    
         WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO    
           AND COBRANCA = @v_Cobranca    
           AND CANCELADO = 'N'    
    
        IF @v_Cont > 0    
          BEGIN    
            SET @v_straux1 = CONVERT(VARCHAR(20),@v_Cobranca)    
            SET @v_Erro = 'O boleto da cobrança ' + @v_straux1 + ' não pode ser gerado porque a mesma foi pré-acordada!'    
            EXEC SetErro @v_Erro, 'COBRANCA'    
            CLOSE c_cobranca_origem          
            DEALLOCATE c_cobranca_origem    
            RETURN      
          END        
           
        IF @v_apenas_cobranca = 'N' or @v_apenas_cobranca is null          
        BEGIN          
                            
          -- -----------------------------------------------------------------------------          
          --  Soma o valor dos itens da cobrança          
          -- -----------------------------------------------------------------------------          
          SELECT @v_ValorCobranca = ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC           
          WHERE COBRANCA = @v_Cobranca       
          AND BOLETO is null       
          AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_LANC.cobranca   
            AND dt_canc IS NULL ) )              
                 
          EXEC GET_ERROR_ID @v_Erros_ID          
                  
          IF @v_Erros_ID <> 0          
          BEGIN          
            SET @v_straux1 = convert(varchar(50),@v_Cobranca)          
            SELECT @v_Erro = 'Erro ao obter a soma dos itens de lançamento para a cobrança ' + @v_straux1          
            EXEC SetErro @v_Erro, 'ITEMCOBRANCA'       
            CLOSE c_cobranca_origem          
            DEALLOCATE c_cobranca_origem          
            RETURN          
          END                        
               
          SELECT @v_ValorCreditos = ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED           
          WHERE COBRANCA = @v_Cobranca AND BOLETO is null       
          AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_ITEM_CRED.cobranca   
            AND dt_canc IS NULL ) )              
                
          EXEC GET_ERROR_ID @v_Erros_ID          
          IF @v_Erros_ID <> 0          
          BEGIN          
            SET @v_straux1 = convert(varchar(50),@v_Cobranca)          
            SELECT @v_Erro = 'Erro ao obter a soma dos itens de crédito para a cobrança ' + @v_straux1          
            EXEC SetErro @v_Erro, 'ITEMCRED'          
            CLOSE c_cobranca_origem          
            DEALLOCATE c_cobranca_origem          
            RETURN          
          END          
               
          SELECT @v_ValorBoleto = @v_ValorCobranca + @v_ValorCreditos          
                
          -- -----------------------------------------------------------------------------          
          --  Verifique se existem itens que não foram emboletados          
          -- -----------------------------------------------------------------------------                    
          SELECT @v_ItensBoleto = 0          
          SELECT @v_ItensBoleto = ISNULL(COUNT(*),0) FROM VW_LANCAMENTOS_PAGAMENTOS           
          WHERE BOLETO IS NULL AND COBRANCA = @v_Cobranca       
                AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = VW_LANCAMENTOS_PAGAMENTOS.cobranca   
            AND dt_canc IS NULL ) )              
                
          -- -----------------------------------------------------------------------------          
          --  Verifique o valor original da cobrança          
          -- -----------------------------------------------------------------------------                    
          SELECT @v_ValorFinalCobranca = SUM(VALOR) FROM LY_ITEM_LANC WHERE COBRANCA = @v_Cobranca AND CODIGO_LANC <> 'Acerto'          
                
          EXEC GET_ERROR_ID @v_Erros_ID          
          IF @v_Erros_ID <> 0          
          BEGIN          
            SET @v_straux1 = convert(varchar(50),@v_ValorFinalCobranca)          
            SELECT @v_Erro = 'Erro ao obter o valor original da cobrança ' + @v_straux1          
            EXEC SetErro @v_Erro, 'ITEMCOBRANCA'          
            CLOSE c_cobranca_origem          
            DEALLOCATE c_cobranca_origem          
            RETURN          
          END          
              
          -- -----------------------------------------------------------------------------          
          --  Não gerar boleto se a cobrança já estiver quitada ou com devolução a ser feita          
          -- -----------------------------------------------------------------------------          
          SELECT @v_Boleto = NULL          
          IF (@v_ValorBoleto > 0 and @p_Apartir_Valor is null) or (@v_ItensBoleto > 0 AND @v_ValorBoleto = 0 AND @p_boleto_zerado = 'S')           
          or ((@v_ValorFinalCobranca > (-1 * @v_ValorCreditos) or @v_ValorCreditos = 0) AND @v_ItensBoleto > 0 AND @v_ValorBoleto < 0 AND @p_boleto_negativo = 'S')           
          or (@v_ValorBoleto >= @p_Apartir_Valor and @p_Apartir_Valor is not null and @p_Apartir_Valor > 0)    
              
          BEGIN          
            -- ------------------------------------------------          
            --  Inserção do boleto VAZIO          
            -- ------------------------------------------------          
            EXEC GetDataDiaSemHora @aux_dt output          
                  
            IF @p_lote is null          
            BEGIN              
              EXEC GET_NUMERO 'Lote', '0' , @p_lote OUTPUT          
              EXEC GetErrorsCount @v_ErrosCount output          
                    
              IF @v_ErrosCount > 0           
              BEGIN          
                EXEC SetErro 'Erro na obtenção do lote do boleto', 'LOTE'          
                CLOSE c_cobranca_origem          
                DEALLOCATE c_cobranca_origem          
                RETURN          
              END          
            END          
              
   -- INSERINDO REGISTRO NA LY_BOLETO_UNIFICADO PARA OBTER UM NOVO NUMERO DE BOLETO  
   declare @data_atual_1 T_DATA  
   set @data_atual_1 = GETDATE()   
  
   EXEC LY_BOLETO_UNIFICADO_Insert           
                  @id_boleto = @v_Boleto OUTPUT,           
                  @data_inclusao = @data_atual_1,  
      @origem = 'LY_BOLETO'   
   EXEC GetErrorsCount @v_ErrosCount OUTPUT                   
            IF @v_ErrosCount  > 0          
            BEGIN          
              SELECT @v_Erro = 'Erro ao gerar numeração do boleto '          
              EXEC SetErro @v_Erro, 'BOLETO'          
              CLOSE c_cobranca_origem          
              DEALLOCATE c_cobranca_origem          
              RETURN          
            END    
       
            EXEC LY_BOLETO_Insert           
            @Boleto = @v_Boleto,           
            @Banco = @p_Banco,           
            @Agencia = @p_Agencia,           
            @Conta_banco = @p_Conta,           
            @Resp = @p_Resp,           
            @Data_proc = @aux_dt,           
            @Nosso_numero = 0,           
            @Instrucoes = NULL,           
            @Lote = @p_Lote,           
            @Arquivo_retorno = NULL,           
            @Debito_automatico = 'N',           
            @Debito_auto_cancelado = 'N',           
            @Removido = 'N',           
            @Aceito = 'N',           
            @Impresso = 'N',          
            @Enviado = 'N',           
            @Env_Cancel = 'N',           
            @Cancel_Banco = 'N',           
            @Carteira = @p_Carteira,           
            @Convenio = @p_Convenio,          
            @Obs = NULL,    
            @on_line = @p_online,  
          @Boleto_cumulativo = 'N'  
                              
            EXEC GetErrorsCount @v_ErrosCount OUTPUT          
                           
            IF @v_ErrosCount  > 0          
            BEGIN          
              SELECT @v_Erro = 'Erro ao inserir boleto para o responsável financeiro ' + @p_Resp          
              EXEC SetErro @v_Erro, 'RESP'          
              CLOSE c_cobranca_origem          
              DEALLOCATE c_cobranca_origem          
              RETURN          
            END                        
            ELSE           
            BEGIN          
              SET @v_count = 0          
              SELECT @v_count = isnull(count(*),0) FROM  LY_AUX_CONTADOR WHERE SESSAO_ID = @p_sessao_id          
                      
              IF @v_count > 0          
              BEGIN          
                SELECT @v_count = CONTADOR FROM  LY_AUX_CONTADOR WHERE SESSAO_ID = @p_sessao_id          
                SET @v_count = @v_count + 1          
                EXEC LY_AUX_CONTADOR_Update @pkSESSAO_ID = @p_sessao_id, @Contador = @v_count           
              END          
            END      
        
   SET @v_boletoParaRegistro = @v_Boleto;   
  
       -- *** Geração do Nosso Número *** --             
   EXEC GERA_NOSSO_NUMERO_BOLETO @v_Boleto, @p_Banco, @p_Agencia, @p_Conta, @p_Carteira, @p_Convenio, @v_NossoNumero output  
            EXEC GetErrorsCount @v_ErrosCount OUTPUT            
   IF @v_ErrosCount  > 0          
   BEGIN          
    SET @v_straux1 = convert(varchar(50),@v_Boleto)          
    SELECT @v_Erro = 'Erro ao gerar nosso número do boleto : ' + @v_straux1          
    EXEC SetErro @v_Erro, 'NOSSO_NUMERO'          
    CLOSE c_cobranca_origem          
    DEALLOCATE c_cobranca_origem          
    RETURN          
   END     
                                      
            -- ---------------------------------          
            --   Vincula boleto aos itens          
            -- ---------------------------------          
            -- *** Itens de lançamento  *** --           
            DECLARE C_UPDATE_LY_ITEM_LANC_7 CURSOR FOR          
            SELECT I.COBRANCA, I.ITEMCOBRANCA     
            FROM LY_ITEM_LANC I, LY_COBRANCA C          
            WHERE C.RESP = @p_Resp       
            AND C.DATA_DE_VENCIMENTO = @v_dt_venc       
            AND I.COBRANCA = C.COBRANCA       
            AND C.COBRANCA = @v_Cobranca       
            AND I.BOLETO is null       
            AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = c.cobranca   
            AND dt_canc IS NULL ) )   
            AND NOT EXISTS (SELECT 1 FROM LY_ALU_BLOQUEIA_BOLETO WHERE ALUNO = C.ALUNO AND SESSAO_ID = @p_sessao_id)       
            ORDER BY I.COBRANCA, I.ITEMCOBRANCA     
                            
            OPEN C_UPDATE_LY_ITEM_LANC_7          
            FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_7 INTO @v_cobranca_update, @v_itemcobranca_update    
                                              
            WHILE (@@FETCH_STATUS = 0)          
            BEGIN      
              -- SE VALOR DA COBRANCA IGUAL A ZERO     
              SELECT @v_valor_update = ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC WHERE COBRANCA = @v_cobranca_update       
    
              IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)        
                UPDATE LY_ITEM_LANC WITH (ROWLOCK)     
                SET Boleto = @v_Boleto          
         WHERE Cobranca = @v_cobranca_update          
                AND Itemcobranca = @v_itemcobranca_update          
                                    
              FETCH NEXT FROM C_UPDATE_LY_ITEM_LANC_7 INTO @v_cobranca_update, @v_itemcobranca_update          
            END      
                          
            CLOSE C_UPDATE_LY_ITEM_LANC_7          
            DEALLOCATE C_UPDATE_LY_ITEM_LANC_7          
            -- *** Itens de crédito *** --          
            DECLARE C_UPDATE_LY_ITEM_CRED_8 CURSOR FOR          
            SELECT CRED.LANC_CRED, CRED.ITEMCRED     
            FROM LY_ITEM_CRED CRED, LY_COBRANCA COBR          
            WHERE COBR.RESP = @p_Resp AND COBR.DATA_DE_VENCIMENTO = @v_dt_venc       
            AND CRED.COBRANCA = COBR.COBRANCA       
            AND COBR.COBRANCA = @v_Cobranca       
            AND CRED.BOLETO is null       
            AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = cobr.cobranca   
            AND dt_canc IS NULL ) )   
            ORDER BY CRED.LANC_CRED, CRED.ITEMCRED                 
                           
            OPEN C_UPDATE_LY_ITEM_CRED_8          
            FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_8 INTO @v_lanc_cred_update, @v_itemcred_update          
                                
            WHILE (@@FETCH_STATUS = 0)          
              BEGIN          
                -- SE VALOR DA COBRANCA IGUAL A ZERO     
                SELECT @v_valor_update = ISNULL(SUM(LY_ITEM_LANC.VALOR),0)     
                FROM LY_ITEM_LANC, LY_ITEM_CRED, LY_COBRANCA     
                WHERE LY_COBRANCA.COBRANCA = LY_ITEM_CRED.COBRANCA    
                   AND LY_COBRANCA.COBRANCA = LY_ITEM_LANC.COBRANCA    
                   AND LY_ITEM_CRED.LANC_CRED = @v_lanc_cred_update    
    
                IF (@v_Gera_Bol_Cobr_Zero = 'S') OR (@v_Gera_Bol_Cobr_Zero = 'N' AND @v_valor_update > 0)    
                  BEGIN    
                    EXEC LY_ITEM_CRED_UPDATE @pkLanc_cred = @v_lanc_cred_update, @pkItemcred = @v_itemcred_update, @boleto = @v_Boleto          
                    EXEC GetErrorsCount @v_ErrosCount OUTPUT                
                          
                    IF @v_ErrosCount  > 0          
                      BEGIN          
                        SET @v_straux1 = convert(varchar(50),@v_cobranca)          
                        SELECT @v_Erro = 'Erro ao atualizar os itens de crédito da cobrança ' + @v_straux1          
                        EXEC SetErro @v_Erro, 'ITEMCRED'          
                        CLOSE C_UPDATE_LY_ITEM_CRED_8          
                        DEALLOCATE C_UPDATE_LY_ITEM_CRED_8          
                        CLOSE c_cobranca_origem          
                        DEALLOCATE c_cobranca_origem          
                        RETURN          
                      END              
                  END        
                FETCH NEXT FROM C_UPDATE_LY_ITEM_CRED_8 INTO @v_lanc_cred_update, @v_itemcred_update         
              END          
            CLOSE C_UPDATE_LY_ITEM_CRED_8          
            DEALLOCATE C_UPDATE_LY_ITEM_CRED_8             
      
    -- Retorna a empresa da LY_AGREGA_ITEM_COBRANCA pelo grupo de umas das dívidas dos     
    -- itens de cobrança do boleto    
    Select @v_empresa = isnull(empresa,'')     
    From LY_AGREGA_ITEM_COBRANCA    
    Where exists (     
        Select  grupo from ly_lanc_debito    
        Where exists (     
             select  lanc_deb from ly_item_lanc    
             where boleto = @v_Boleto  and ly_item_lanc.lanc_deb = ly_lanc_debito.lanc_deb  
             )     
  and LY_AGREGA_ITEM_COBRANCA.grupo =  ly_lanc_debito.grupo  
        and grupo is not null    
        )  and     
      empresa is not null and    
      banco = @p_Banco and    
      agencia = @p_Agencia and    
      conta_banco = @p_Conta and    
      (@p_Carteira is null or carteira = @p_Carteira)    
 order by empresa desc    
        
    If @v_empresa <> ''    
     Begin    
       Begin Tran TR_empresa2    
       IF @v_boleto IS NOT NULL    
        BEGIN        
         EXEC LY_BOLETO_UPDATE @pkBoleto = @v_Boleto,               
               @empresa = @v_empresa    
         EXEC GetErrorsCount @v_ErrosCount OUTPUT            
                            
         IF @v_ErrosCount  > 0                
          ROLLBACK TRAN TR_empresa2    
         ELSE    
          COMMIT TRAN TR_empresa2    
        END     
       ELSE    
        COMMIT TRAN TR_empresa2    
     End     
              -- -------------------------------------------------------    
              -- CHAMA a_Numero_RPS    
              -- -------------------------------------------------------        
              IF @v_boleto is not null    
                BEGIN         
                  SELECT @v_faculdade = t3.faculdade     
                  FROM ly_aluno t1, ly_cobranca t2, ly_curso t3, ly_item_lanc t4       
                  WHERE t1.aluno = t2.aluno     
                  AND t1.curso = t3.curso     
                  AND t4.boleto = @v_Boleto        
                  AND t2.cobranca = t4.cobranca    
                     
                  BEGIN TRAN TR_NumeroRps    
    
                  EXEC a_numero_RPS @v_faculdade, @v_Boleto, @p_resp, @v_numeroRPS output, @v_ValorServicoRPS output, @v_ValorDeducaoRPS output, 'GER_BOLETO', @v_NotaFiscalSerie output, null, null           
        
                  EXEC GetDataDiaSemHora @v_data_emissao_rps output    
    
                  IF @v_numeroRPS IS NOT NULL    
                     BEGIN    
                        EXEC LY_BOLETO_UPDATE @pkBoleto = @v_Boleto,               
                                        @numero_rps = @v_NumeroRPS,              
                                        @data_emissao_rps = @v_data_emissao_rps,      
                                        @nota_fiscal_serie = @v_NotaFiscalSerie   
                                          
              EXEC GetErrorsCount @v_ErrosCount OUTPUT            
                            
                      IF @v_ErrosCount  > 0                
              ROLLBACK TRAN TR_NumeroRps    
                 ELSE    
                            COMMIT TRAN TR_NumeroRps    
                      END     
                  ELSE    
                     COMMIT TRAN TR_NumeroRps     
              END    
    
            --**Verificar se é servico pré-pago(pega as instrucoes_servico ao inves de instrucoes)**----          
            SELECT  @v_pgto_pre_exec = SERV.PAGAMENTO_PRE_EXECUCAO            
            FROM LY_ITEM_LANC ITEM, LY_ITENS_SOLICIT_SERV  ITEM_SERV, LY_TABELA_SERVICOS SERV          
            WHERE ITEM.COBRANCA = @v_cobranca            
            AND  ITEM.LANC_DEB = ITEM_SERV.LANC_DEB           
            AND ITEM_SERV.SERVICO =  SERV.SERVICO          
                          
            IF @v_pgto_pre_exec = 'S'            
            BEGIN  -- Pagamento pré execução              
              -- *** Obtenção das instruções do boleto de servicos  *** --            
              SELECT @v_Instrucoes = INSTRUCOES_SERVICO FROM LY_OPCOES_BOLETO            
              WHERE BANCO = @p_Banco       
              AND AGENCIA = @p_Agencia       
              AND CONTA_BANCO = @p_Conta       
              AND CARTEIRA = @p_Carteira            
            END            
                          
            ELSE              
            BEGIN            
              --Verificar se é acordo          
              SELECT  @v_bol_acordo = NUM_COBRANCA  FROM LY_COBRANCA WHERE COBRANCA = @v_cobranca            
                 
              IF @v_bol_acordo = 3          
                BEGIN          
                  -- *** Obtenção das instruções do boleto *** --            
                  SELECT @v_Instrucoes = INSTRUCOES_ACORDO             
                  FROM LY_OPCOES_BOLETO            
                  WHERE BANCO = @p_Banco AND             
                AGENCIA = @p_Agencia AND             
                        CONTA_BANCO = @p_Conta AND               
                        CARTEIRA = @p_Carteira            
                END                                   
              ELSE            
                BEGIN  
                 -- Verifica se é serviço          
                 IF @v_bol_acordo = 2  
                   BEGIN  
                     -- *** Obtenção das instruções do boleto de servicos  *** --            
                     SELECT @v_Instrucoes = INSTRUCOES_SERVICO FROM LY_OPCOES_BOLETO            
                     WHERE BANCO = @p_Banco       
                           AND AGENCIA = @p_Agencia       
                           AND CONTA_BANCO = @p_Conta       
                           AND CARTEIRA = @p_Carteira            
                   END   
                 ELSE  
                   BEGIN   
                     -- *** Obtenção das instruções do boleto *** --            
                     SELECT @v_Instrucoes = INSTRUCOES FROM LY_OPCOES_BOLETO            
                     WHERE BANCO = @p_Banco       
                            AND AGENCIA = @p_Agencia       
                            AND CONTA_BANCO = @p_Conta       
                            AND CARTEIRA = @p_Carteira            
                   END -- IF @v_bol_acordo = 2  
                END -- IF @v_bol_acordo = 3                  
            END  -- IF @v_pgto_pre_exec = 'S'         
                
            EXEC GET_ERROR_ID @v_Erros_ID         
      
        IF @v_Erros_ID <> 0          
            BEGIN          
              SET @v_straux1 = convert(varchar(50),@p_banco)          
              SET @v_straux2 = convert(varchar(50),@p_Agencia)          
              SET @v_straux3 = convert(varchar(50),@p_Conta)          
              SELECT @v_Erro = 'Erro ao obter as instruções do boleto para o banco/agencia/conta: ' + @v_straux1 + '/' + @v_straux2 + '/' + @v_straux3          
              EXEC SetErro @v_Erro, 'BANCO'          
              CLOSE c_cobranca_origem      
              DEALLOCATE c_cobranca_origem          
              RETURN          
            END            
                
            EXEC ADICIONA_INSTRUCAO @p_sessao_id, @v_Boleto, @v_instrucoes OUTPUT          
            EXEC a_Identif_Cliente @v_Boleto, @p_Resp          
            EXEC a_Nosso_Numero @v_Boleto, @p_Banco, @p_Agencia, @p_Conta, @p_Convenio, @p_Carteira, @p_Resp, @v_NossoNumero output          
                                                        
            -- ---------------------------------------------------------------------------------------      
            -- DEBITO AUTOMATICO - inicio      
            -- ---------------------------------------------------------------------------------------      
            select @v_num_cobranca = NUM_COBRANCA FROM LY_COBRANCA WHERE COBRANCA = @v_cobranca            
                          
            IF @v_num_cobranca = 3     
            BEGIN    
              SET @v_DebitoAutomaticoAluno = 'N'    
              SET @v_Debaut_Banco = null      
              SET @v_Debaut_Agencia = null      
              SET @v_Debaut_Conta_Banco = null      
              SET @v_Dv_Agencia = null       
              SET @v_Dv_Conta = null       
              SET @v_Dv_Agencia_Conta = null       
              SET @v_Operacao = null       
            END    
                                        
            ELSE    
            BEGIN   
  
            INSERT INTO LY_PLANOPGTOESPEC_AUX ( RESP, LANC_DEB, SESSAO_ID )          
              SELECT b.RESP, pe.LANC_DEB, @p_sessao_id          
              FROM LY_PLANO_PGTO_ESPECIAL pe, LY_LANC_DEBITO d, LY_ITEM_LANC ic, LY_BOLETO b          
              WHERE ic.BOLETO = b.BOLETO       
              AND ic.LANC_DEB = d.LANC_DEB                                  
              AND b.RESP = pe.RESP   
     AND d.LANC_DEB = pe.LANC_DEB                     
              AND pe.BANCO is not null       
    AND pe.AGENCIA is not null       
              AND pe.CONTA_BANCO is not null       
              AND b.BOLETO = @v_boleto          
              GROUP BY b.RESP, pe.LANC_DEB  
       
     SET @v_Debaut_Banco = null    
              SET @v_Debaut_Agencia = null    
              SET @v_Debaut_Conta_Banco = null    
              SET @v_Dv_Agencia = null     
              SET @v_Dv_Conta = null     
              SET @v_Dv_Agencia_Conta = null     
              SET @v_Operacao = null  
       
     SELECT @v_Debaut_Banco = pe.BANCO, @v_Debaut_Agencia = pe.AGENCIA,         
              @v_Debaut_Conta_Banco = pe.CONTA_BANCO, @v_Dv_Agencia = pe.DV_AGENCIA,        
              @v_Dv_Conta = pe.DV_CONTA, @v_Dv_Agencia_Conta = pe.DV_AGENCIA_CONTA,        
              @v_Operacao = pe.OPERACAO        
              FROM LY_PLANO_PGTO_ESPECIAL pe, LY_PLANOPGTOESPEC_AUX pa        
              WHERE pe.LANC_DEB = pa.LANC_DEB                 
              AND pe.RESP = pa.RESP                   
              AND SESSAO_ID = @p_sessao_id  
       
     SET @v_DebitoAutomaticoAluno = 'N'  
       
     IF @v_Debaut_Banco is not null SET @v_DebitoAutomaticoAluno = 'S'  
       
     DECLARE C_PLANOPGTOESPEC_AUX CURSOR READ_ONLY FOR        
              SELECT RESP, LANC_DEB FROM LY_PLANOPGTOESPEC_AUX WHERE Sessao_id = @p_sessao_id        
                    
              OPEN C_PLANOPGTOESPEC_AUX        
              FETCH NEXT FROM C_PLANOPGTOESPEC_AUX INTO @v_resp, @v_Lanc_deb        
                        
              WHILE @@fetch_status = 0        
              BEGIN        
                DELETE FROM LY_PLANOPGTOESPEC_AUX WHERE Sessao_id = @p_sessao_id AND resp= @v_resp AND Lanc_deb = @v_Lanc_deb  
                    
                FETCH NEXT FROM C_PLANOPGTOESPEC_AUX INTO @v_resp, @v_Lanc_deb      
              END        
                        
              CLOSE C_PLANOPGTOESPEC_AUX        
              DEALLOCATE C_PLANOPGTOESPEC_AUX  
       
     IF @v_DebitoAutomaticoAluno = 'N'  
     BEGIN                         
                 
              INSERT INTO LY_PLANOPGTOPERIODO_AUX ( RESP, ANO, PERIODO, ALUNO, SESSAO_ID )          
              SELECT b.RESP, pp.ANO, pp.PERIODO, pp.ALUNO,  @p_sessao_id          
              FROM LY_PLANO_PGTO_PERIODO pp, LY_LANC_DEBITO d, LY_ITEM_LANC ic, LY_BOLETO b          
              WHERE ic.BOLETO = b.BOLETO       
              AND ic.LANC_DEB = d.LANC_DEB       
              AND d.ANO_REF = pp.ANO       
              AND d.PERIODO_REF = pp.PERIODO       
              AND b.RESP = pp.RESP       
              AND d.ALUNO = pp.ALUNO       
              AND pp.BANCO is not null       
              AND pp.AGENCIA is not null       
              AND pp.CONTA_BANCO is not null       
              AND b.BOLETO = @v_boleto          
              GROUP BY b.RESP, pp.ANO, pp.PERIODO, pp.ALUNO          
                                  
                    
              SELECT @v_Debaut_Banco = pp.BANCO, @v_Debaut_Agencia = pp.AGENCIA,           
              @v_Debaut_Conta_Banco = pp.CONTA_BANCO, @v_Dv_Agencia = pp.DV_AGENCIA,          
              @v_Dv_Conta = pp.DV_CONTA, @v_Dv_Agencia_Conta = pp.DV_AGENCIA_CONTA,          
              @v_Operacao = pp.OPERACAO          
              FROM LY_PLANO_PGTO_PERIODO pp, LY_PLANOPGTOPERIODO_AUX pa          
              WHERE pp.ANO = pa.ANO       
              AND pp.PERIODO = pa.PERIODO       
              AND pp.RESP = pa.RESP       
              AND pp.ALUNO = pa.ALUNO       
              AND SESSAO_ID = @p_sessao_id          
                                                          
              IF @v_Debaut_Banco is not null SET @v_DebitoAutomaticoAluno = 'S'  
          --  
  
                      
              DECLARE C_PLANOPGTO_PERIODO_AUX CURSOR READ_ONLY FOR          
              SELECT RESP, ANO, PERIODO, ALUNO FROM LY_PLANOPGTOPERIODO_AUX WHERE Sessao_id = @p_sessao_id          
                      
              OPEN C_PLANOPGTO_PERIODO_AUX          
              FETCH NEXT FROM C_PLANOPGTO_PERIODO_AUX INTO @v_resp, @v_ano, @v_periodo, @v_aluno          
                          
              WHILE @@fetch_status = 0          
              BEGIN          
                EXEC LY_PLANOPGTOPERIODO_AUX_Delete @pkSessao_id = @p_sessao_id,          
                @pkresp= @v_resp,          
                @pkano = @v_ano,          
                @pkperiodo = @v_periodo,          
                @pkaluno = @v_aluno          
                      
                FETCH NEXT FROM C_PLANOPGTO_PERIODO_AUX INTO @v_resp, @v_ano, @v_periodo, @v_aluno          
              END          
                          
              CLOSE C_PLANOPGTO_PERIODO_AUX          
              DEALLOCATE C_PLANOPGTO_PERIODO_AUX    
          END      
                  
              IF @v_DebitoAutomaticoAluno = 'N' AND @v_DebitoAutomaticoResp = 'S'  
              BEGIN    
                SELECT @v_Debaut_Banco = BANCO, @v_Debaut_Agencia = AGENCIA,         
                @v_Debaut_Conta_Banco = CONTA_BANCO, @v_Dv_Agencia = DV_AGENCIA,        
                @v_Dv_Conta = DV_CONTA, @v_Dv_Agencia_Conta = DV_AGENCIA_CONTA,        
                @v_Operacao = OPERACAO        
                FROM LY_RESP_FINAN        
                WHERE RESP = @p_resp        
                  
                IF @v_Debaut_Banco is not null SET @v_DebitoAutomaticoAluno = 'S'     
              END           
            END --IF @num_cobranca = 3    
              
            EXEC s_DEBITO_AUTOMATICO @p_Resp,   
                                     @v_cobranca,   
                                     @v_DebitoAutomaticoResp OUTPUT,   
                                     @v_DebitoAutomaticoAluno OUTPUT,   
                                     @v_Debaut_Banco OUTPUT,   
                                     @v_Debaut_Agencia OUTPUT,   
                                     @v_Debaut_Conta_Banco OUTPUT,   
                                     @v_Dv_Agencia OUTPUT,   
                                     @v_Dv_Conta OUTPUT,   
                                     @v_Dv_Agencia_Conta OUTPUT,   
                                     @v_Operacao OUTPUT  
              
            SET @v_DebitoAutomatico = 'N'  
            IF @v_Debaut_Banco is not null SET @v_DebitoAutomatico = 'S'     
                                                   
            -- ---------------------------------------------------------------------------------------      
            -- DEBITO AUTOMATICO - fim      
            -- ---------------------------------------------------------------------------------------      
                          
                          
            -- ------------------------------------------------          
            --  Complementação das informações do boleto          
            -- ------------------------------------------------        
            EXEC GetDataDiaSemHora @aux_dt output          
                  
            EXEC LY_BOLETO_UPDATE           
            @pkBoleto = @v_Boleto,           
            @Banco = @p_Banco,           
            @Agencia = @p_Agencia,           
            @Conta_banco = @p_Conta,           
            @Resp = @p_Resp,           
            @Data_proc = @aux_dt,           
            @Nosso_numero = @v_NossoNumero,           
            @Instrucoes = @v_Instrucoes,           
            @Lote = @p_Lote,           
            @Arquivo_retorno = NULL,           
            @Debito_automatico = @v_DebitoAutomatico,           
            @Debito_auto_cancelado = 'N',           
            @Removido = 'N',           
            @Aceito = 'N',           
            @Impresso = 'N',          
            @Enviado = 'N',          
            @Env_Cancel = 'N',           
            @Cancel_Banco = 'N',            
            @Carteira = @p_Carteira,           
            @Obs = NULL,        
            @DebAut_Banco = @v_Debaut_Banco,           
            @Debaut_Agencia = @v_Debaut_Agencia,           
            @Debaut_Conta_banco = @v_Debaut_Conta_Banco,           
            @Dv_Agencia = @v_Dv_Agencia,           
            @Dv_Conta = @v_Dv_Conta,           
            @Dv_Agencia_Conta = @v_Dv_Agencia_Conta,           
            @Operacao = @v_Operacao         
                
            EXEC GetErrorsCount @v_ErrosCount OUTPUT          
                  
            IF @v_ErrosCount  > 0          
            BEGIN           
              SELECT @v_Erro = 'Erro ao alterar boleto para o responsável financeiro ' + @p_Resp          
              EXEC SetErro @v_Erro, 'RESP'          
              CLOSE c_cobranca_origem          
              DEALLOCATE c_cobranca_origem          
              RETURN          
            END          
    
          END  -- IF (@v_ValorBoleto > 0 and @p_Apartir_Valor is null) or (@v_ItensBoleto > 0 AND @v_ValorBoleto = 0 AND @p_boleto_zerado = 'S')           
                
          -- -----------------------------------------------------------------------------          
          --  Atualizar a cobrança          
          -- -----------------------------------------------------------------------------          
          SELECT @v_count = isnull(COUNT(*),0) FROM LY_COBRANCA           
          WHERE RESP = @p_Resp           
          AND DATA_DE_VENCIMENTO = @v_dt_venc          
          AND DATA_DE_FATURAMENTO IS NULL AND COBRANCA = @v_Cobranca       
          AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = LY_COBRANCA.cobranca   
            AND dt_canc IS NULL ) )              
                            
          IF @v_count = 1           
          BEGIN          
            EXEC GetDataDiaSemHora @aux_dt output          
            EXEC LY_COBRANCA_UPDATE @pkCobranca = @v_Cobranca, @data_de_faturamento = @aux_dt          
            EXEC GetErrorsCount @v_ErrosCount OUTPUT          
                  
            IF @v_ErrosCount  > 0          
            BEGIN          
              SELECT @v_Erro = 'Erro ao atualizar as cobranças do responsável financeiro : ' + @p_Resp          
              EXEC SetErro @v_Erro, 'RESP'          
              CLOSE c_cobranca_origem          
              DEALLOCATE c_cobranca_origem          
              RETURN          
            END          
          END          
                
              
          FETCH NEXT FROM c_cobranca_origem INTO @v_Cobranca, @v_dt_venc, @v_apenas_cobranca       
        END -- IF @v_apenas_cobranca = 'N' or @v_apenas_cobranca is null            
        ELSE          
        BEGIN          
          -- -----------------------------------------------------------------------------          
          --  Atualizar a cobrança          
          -- -----------------------------------------------------------------------------          
          SELECT @v_count = isnull(COUNT(*),0) FROM LY_COBRANCA           
          WHERE RESP = @p_Resp           
          AND DATA_DE_VENCIMENTO = @v_dt_venc          
          AND DATA_DE_FATURAMENTO IS NULL AND COBRANCA = @v_Cobranca       
          AND (@p_cobranca_com_nota = 'S' OR NOT EXISTS (SELECT cobranca   
            FROM   ly_nota_promissoria   
            WHERE  ly_nota_promissoria.cobranca = ly_cobranca.cobranca   
            AND dt_canc IS NULL ) )    
               
          IF @v_count = 1           
          BEGIN          
            EXEC GetDataDiaSemHora @aux_dt output          
            EXEC LY_COBRANCA_UPDATE @pkCobranca = @v_Cobranca, @data_de_faturamento = @aux_dt          
            EXEC GetErrorsCount @v_ErrosCount OUTPUT          
                            
            IF @v_ErrosCount  > 0          
            BEGIN          
              SELECT @v_Erro = 'Erro ao atualizar as cobranças do responsável financeiro : ' + @p_Resp          
              EXEC SetErro @v_Erro, 'RESP'          
              CLOSE c_cobranca_origem          
     DEALLOCATE c_cobranca_origem          
              RETURN          
            END          
          END          
          FETCH NEXT FROM c_cobranca_origem INTO @v_Cobranca, @v_dt_venc, @v_apenas_cobranca          
        END -- ELSE -- IF @v_apenas_cobranca = 'N' or @v_apenas_cobranca is null       
    
       ---------------------------------------------    
       -- CALCULA E GRAVA DATA DE VALIDADE DO BOLETO  
       -- ------------------------------------------   
       
       SELECT @V_PRAZO_BAIXA = PRAZO_BAIXA FROM LY_CONTA_CONVENIO CC   
       INNER JOIN LY_BOLETO BO ON BO.BANCO = CC.BANCO AND BO.AGENCIA = CC.AGENCIA AND BO.CONTA_BANCO = CC.CONTA_BANCO   
       AND BO.CARTEIRA = CC.CARTEIRA AND BO.CONVENIO = CC.CONVENIO  
       WHERE BO.BOLETO = @v_boletoParaRegistro  
       
       --chama EP para substituir prazo de baixa  
      
       exec s_prazo_baixa_boleto @v_boletoParaRegistro, @p_substitui_prazo output, @p_novo_prazo output  
       if @p_substitui_prazo = 'S'  
       begin  
      set @V_PRAZO_BAIXA = isnull(@p_novo_prazo,@p_novo_prazo)  
       end  
       
       IF @V_PRAZO_BAIXA is not null  
       BEGIN  
         SET @V_DATA_VALIDADE = (select dateadd(day,@V_PRAZO_BAIXA,@p_DtVenc))  
      UPDATE LY_BOLETO_UNIFICADO SET DATA_VALIDADE = @V_DATA_VALIDADE  WHERE ID_BOLETO = @v_boletoParaRegistro  
       END  
       
        ---------------------------------------------    
       -- INSERE BOLETO NA FILA PARA SER REGISTRADO   
       -- ------------------------------------------   
       IF @v_boletoParaRegistro IS NOT NULL -- se existe código do boleto tenta colocalo na fila para registro segundo configurações de plugin de boleto  
      BEGIN  
       EXEC INSERE_PEDIDO_REGISTRO_BOLETO @v_boletoParaRegistro, 'Registro'     
      END  
  
       --------------------------------------------------------    
       -- ## FIM ## INSERE BOLETO NA FILA PARA SER REGISTRADO   ## FIM ##   
       -- -----------------------------------------------------      
                  
      END -- while em c_cobranca_origem          
                          
      CLOSE c_cobranca_origem          
      DEALLOCATE c_cobranca_origem          
    END -- ELSE -- IF @v_BoletoUnico = 'S'                
  END  -- ELSE -- IF @p_ApenasFaturar = 'S'       
   
  ---------------------------------------------    
  -- REMOVE OS REGISTROS COM O MESMO SESSAO_ID    
  -- ------------------------------------------    
  DELETE FROM LY_ALU_BLOQUEIA_BOLETO WHERE SESSAO_ID = @p_sessao_id           
-- [FIM]   