    
CREATE PROCEDURE ESTORNA_COBRANCA    
  @p_cobranca T_NUMERO    
AS    
-- [INÍCIO]    
    
  DECLARE @v_Erros VARCHAR(1024)    
  DECLARE @v_ErrorsCount int    
  DECLARE @v_straux varchar(100)    
  DECLARE @v_straux2 varchar(100)    
  DECLARE @v_Count int    
  DECLARE @v_Cobranca      T_NUMERO    
  DECLARE @v_s_cobranca    VARCHAR(28)    
  DECLARE @v_ItemCobranca  T_NUMERO_PEQUENO    
  DECLARE @v_LancDebito    T_NUMERO    
  DECLARE @v_Codigo_Lanc   T_CODIGO    
  DECLARE @v_Aluno         T_CODIGO    
  DECLARE @v_Num_Bolsa     T_NUMERO    
  DECLARE @v_Resp          T_CODIGO    
  DECLARE @v_Mot_Desconto  T_CODIGO    
  DECLARE @v_Devolucao     T_NUMERO    
  DECLARE @v_Boleto        T_NUMERO    
  DECLARE @v_Parcela       T_NUMERO    
  DECLARE @v_Data          T_DATA    
  DECLARE @v_Valor         T_DECIMAL_MEDIO    
  DECLARE @v_Descricao     T_ALFALARGE    
  DECLARE @v_Acordo        T_NUMERO    
  DECLARE @v_Cobranca_Orig T_NUMERO    
  DECLARE @v_ItemCob_Orig  T_NUMERO_PEQUENO    
  DECLARE @v_Centro_Custo  T_ALFAMEDIUM    
  DECLARE @v_Natureza      T_ALFAMEDIUM    
    
    
  DECLARE @v_Ano_Ref_Bolsa T_ANO    
  DECLARE @v_Mes_Ref_Bolsa T_MES    
  DECLARE @v_ValorTotal    T_DECIMAL_MEDIO    
  DECLARE @aux_banco varchar (10)    
  DECLARE @v_curso T_CODIGO      
  DECLARE @v_curriculo T_CODIGO      
  DECLARE @v_turno T_CODIGO      
  DECLARE @v_unidfisica T_CODIGO    
  DECLARE @v_origem VARCHAR(40)    
  DECLARE @v_estorno T_SIMNAO    
  DECLARE @v_substitui VARCHAR(1)    
  DECLARE @v_msg_erro VARCHAR(4000)    
  DECLARE @v_item_cobranca T_NUMERO_PEQUENO   
  DECLARE @v_encerr_processado  T_SIMNAO  
        
  EXEC tipobanco @aux_banco OUTPUT    
      
  BEGIN TRANSACTION TR_ESTORNA_COBRANCA    
  SAVE TRANSACTION TR_ESTORNA_COBRANCA    
      
  -- Chamada do entry-point s_ESTORNA_COBRANCA    
  EXEC s_ESTORNA_COBRANCA @p_cobranca, @v_substitui OUTPUT, @v_msg_erro OUTPUT    
      
  IF @v_substitui = 'S'    
  BEGIN     
     ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
     if @aux_banco = 'SQL'    
       Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
     EXEC SetErro @v_msg_erro, ''    
     RETURN    
  END     
        
  -- Validação se cobrança está paga totalmente ou parcialmente, pois não pode ser estornada    
  SELECT @v_ValorTotal=SUM(VALOR) FROM VW_COBRANCA WHERE COBRANCA=@p_cobranca                
  IF (@v_ValorTotal <= 0 AND EXISTS(SELECT 1 FROM LY_ITEM_CRED WHERE COBRANCA=@p_cobranca and not exists (SELECT 1     
                                                                                                          FROM LY_ITEM_CRED        
                                                                                                          WHERE COBRANCA = @p_cobranca    
                                                                                                          GROUP BY COBRANCA HAVING SUM(VALOR)=0    
                                                                                                          )    
                                    )    
      )     
      or     
     (@v_ValorTotal > 0 AND EXISTS(SELECT 1 FROM LY_ITEM_CRED WHERE COBRANCA=@p_cobranca and not exists (SELECT 1     
                                                                                                         FROM LY_ITEM_CRED        
                                                                                                         WHERE COBRANCA = @p_cobranca    
                               AND TIPO_ENCARGO is null and TIPODESCONTO IS NULL  
                                                                                                         GROUP BY COBRANCA HAVING SUM(VALOR)=0    
                                                                                                         )    
                                  )    
      )            
  BEGIN     
     ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
     if @aux_banco = 'SQL'    
       Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
     EXEC SetErro 'Estorno de Cobranca. Cobrança paga totalmente ou parcialmente não pode ser estornada!', ''    
     RETURN    
  END     
      
  -- Validação se cobrança pertence a uma dívida de acordo, pois não pode ser estornada    
  SELECT @v_Cobranca = NUM_COBRANCA, @v_aluno = ALUNO, @v_estorno = estorno    
  FROM  LY_COBRANCA     
  WHERE COBRANCA = @p_cobranca    
      
  IF @v_estorno = 'S'    
 BEGIN    
      ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
      if @aux_banco = 'SQL'    
        Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
      EXEC SetErro 'Estorno de Cobranca. Cobrança já encontra-se estornada!', ''    
      RETURN    
 END     
      
  IF @v_Cobranca = 3    
    BEGIN     
      ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
      if @aux_banco = 'SQL'    
        Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
      EXEC SetErro 'Estorno de Cobranca. Cobrança originada de Acordo não pode ser estornada!', ''    
      RETURN    
    END     
    
  -- Validação se cobrança pertence a uma dívida de acordo, pois não pode ser estornada    
  SELECT  @v_Count = isnull(COUNT(*),0)    
  FROM  LY_ITEM_LANC    
  WHERE COBRANCA = @p_cobranca    
        AND ACORDO IS NOT NULL    
        AND EXISTS (SELECT ACORDO     
                    FROM LY_ACORDO     
                    WHERE LY_ITEM_LANC.ACORDO = LY_ACORDO.ACORDO AND CANCELADO = 'N')    
      
  IF @v_Count > 0    
    BEGIN     
      ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
      if @aux_banco = 'SQL'    
        Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
      EXEC SetErro 'Estorno de Cobranca. Cobrança Acordada não pode ser estornada!', ''    
      RETURN    
    END     
      
  --Validação se a cobrança possui restituição, pois não pode ser estornada    
  SELECT @v_Count = isnull(COUNT(*),0)    
  FROM LY_ITEM_LANC    
  WHERE COBRANCA=@p_cobranca     
        AND CODIGO_LANC='Acerto' AND COBRANCA_ORIG IS NOT NULL    
        AND ITEMCOBRANCA_ORIG IS NOT NULL        
      
  IF @v_Count > 0    
    BEGIN     
      ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
      if @aux_banco = 'SQL'    
        Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
      EXEC SetErro 'Estorno de Cobranca. Cobrança com restituição não pode ser estornada!', ''    
      RETURN    
    END    
    
  --Validação se a cobrança forneceu restituição, pois não pode ser estornada    
  SELECT @v_Count = isnull(COUNT(*),0)    
  FROM LY_ITEM_LANC    
  WHERE CODIGO_LANC='Acerto' AND COBRANCA_ORIG = @p_cobranca     
      
  IF @v_Count > 0    
    BEGIN     
      ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
      if @aux_banco = 'SQL'    
        Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
      EXEC SetErro 'Estorno de Cobranca. Cobrança forneceu restituição não pode ser estornada!', ''    
      RETURN    
    END    
      
  --Validação se a cobrança tem devolução, pois não pode ser estornada    
  SELECT @v_Count = isnull(COUNT(*),0)    
  FROM LY_ITEM_LANC    
  WHERE CODIGO_LANC='Acerto' AND COBRANCA = @p_cobranca     
        AND DEVOLUCAO IS NOT NULL    
        AND EXISTS (SELECT 1     
                    FROM LY_ITEM_LANC IL     
                    WHERE LY_ITEM_LANC.COBRANCA = IL.COBRANCA     
                          AND LY_ITEM_LANC.DEVOLUCAO = IL.DEVOLUCAO     
                    GROUP BY IL.COBRANCA    
                    HAVING SUM(IL.VALOR) <> 0)    
      
      
  IF @v_Count > 0    
    BEGIN     
      ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
      if @aux_banco = 'SQL'    
        Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
      EXEC SetErro 'Estorno de Cobranca. Cobrança com devolução não pode ser estornada!', ''    
      RETURN    
    END    
         
  SELECT @v_curso = CURSO, @v_turno = TURNO, @v_curriculo = CURRICULO, @v_unidfisica = UNID_FISICA    
  FROM LY_COBRANCA    
  WHERE COBRANCA = @p_cobranca    
      
  EXEC GetDataDiaSemHora @v_Data output        
    
  --CURSOR READ_ONLY    
  DECLARE C_ITEM_LANC_A_ESTORNAR CURSOR STATIC READ_ONLY FOR     
  SELECT COBRANCA,LANC_DEB,CODIGO_LANC,ALUNO,NUM_BOLSA,RESP,MOTIVO_DESCONTO,DEVOLUCAO,BOLETO,PARCELA,    
         VALOR,DESCRICAO,ACORDO,COBRANCA_ORIG,ITEMCOBRANCA_ORIG,CENTRO_DE_CUSTO,NATUREZA,ANO_REF_BOLSA,    
         MES_REF_BOLSA, CURSO, TURNO, CURRICULO, UNID_FISICA, ORIGEM, ITEMCOBRANCA, ENCERR_PROCESSADO    
  FROM LY_ITEM_LANC   
  WHERE COBRANCA = @p_cobranca   
  AND (ORIGEM IS NULL OR ORIGEM <> 'APROPRIACAO-RECEITA')  
       
  OPEN C_ITEM_LANC_A_ESTORNAR    
  FETCH NEXT FROM C_ITEM_LANC_A_ESTORNAR INTO @v_Cobranca,@v_LancDebito,@v_Codigo_Lanc,@v_Aluno,@v_Num_Bolsa,@v_Resp,    
  @v_Mot_Desconto,@v_Devolucao,@v_Boleto,@v_Parcela,@v_Valor,@v_Descricao,@v_Acordo,@v_Cobranca_Orig,@v_ItemCob_Orig,@v_Centro_Custo,    
  @v_Natureza,@v_Ano_Ref_Bolsa,@v_Mes_Ref_Bolsa, @v_curso, @v_turno, @v_curriculo, @v_unidfisica, @v_origem, @v_item_cobranca ,@v_encerr_processado                 
      
      
  WHILE @@fetch_status = 0    
  BEGIN    
      --Verifica se o item possui boleto, se possuir faz a remoção      
      IF @v_Boleto IS NOT NULL     
      BEGIN    
          EXEC REMOVE_BOLETO @v_Boleto    
          EXEC GetErrorsCount @v_ErrorsCount output    
          IF @v_ErrorsCount > 0    
             BEGIN    
               EXEC GetErros @v_Erros Output    
               ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
               if @aux_banco = 'SQL'    
                   Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
               EXEC SetErro @v_Erros    
               EXEC SetErro 'Estorno de Cobranca. Erro ao remover o boleto do item lançamento.', ''    
               CLOSE C_ITEM_LANC_A_ESTORNAR    
               DEALLOCATE C_ITEM_LANC_A_ESTORNAR    
               RETURN    
             END    
      END    
          
      --Muda o sinal do valor para gerar um novo item de lançamento com sinal inverso     
      SELECT @v_Valor =@v_Valor * (-1)     
      --Busca o maior valor do item de cobranca para a cobrança     
      SELECT @v_ItemCobranca=0    
   SELECT @v_s_cobranca = convert(varchar(28),@v_Cobranca)    
      EXEC GET_NUMERO 'itemlanc', @v_s_cobranca, @v_ItemCobranca OUTPUT          
      EXEC GetErrorsCount @v_ErrorsCount output          
                        
      IF @v_ErrorsCount > 0          
        BEGIN          
           EXEC GetErros @v_Erros Output    
           ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
           if @aux_banco = 'SQL'    
                 Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
           EXEC SetErro @v_Erros    
           EXEC SetErro 'Estorno de Cobranca. Erro ao gerar o número do item lançamento.', ''    
           CLOSE C_ITEM_LANC_A_ESTORNAR    
           DEALLOCATE C_ITEM_LANC_A_ESTORNAR    
           RETURN    
        END          
    
        SELECT @v_Descricao=substring('Estorno de Cobrança: Estorno de ' + @v_Descricao,1,100)              
            
        EXEC LY_ITEM_LANC_Insert  @Cobranca = @v_cobranca,    
                                  @Itemcobranca = @v_itemCobranca,    
                                  @Lanc_deb =@v_LancDebito,    
                                  @Codigo_lanc = @v_Codigo_lanc,    
                                  @Aluno =@v_Aluno,    
                                  @Num_bolsa =@v_Num_Bolsa,    
                                  @Resp =@v_Resp,    
                                  @Motivo_desconto = @v_Mot_Desconto,    
                                  @Devolucao = @v_Devolucao,    
                                  @Boleto = null,    
                                  @Parcela =@v_Parcela,    
                                  @Data = @v_Data,    
                                  @Valor = @v_Valor,    
                                  @Descricao = @v_Descricao,    
                                  @Acordo = @v_Acordo,    
                                  @Cobranca_orig = @v_Cobranca_Orig,    
                                  @Itemcobranca_orig = @v_ItemCob_Orig,    
                                  @centro_de_custo=@v_Centro_Custo,    
                                  @natureza=@v_Natureza,    
                                  @ano_ref_bolsa=@v_Ano_Ref_Bolsa,    
                                  @mes_ref_bolsa=@v_Mes_Ref_Bolsa,    
                              @Curso = @v_curso,     
                                  @Turno = @v_turno,     
          @Curriculo = @v_curriculo,     
                       @Unid_fisica = @v_unidfisica,    
                                  @Data_disputa = null,    
                                  @Data_decisao_disputa = null,    
                                  @Disputa_aceita = 'N',    
                                  @Disputa_ajustada = 'N',    
                                  @MOTIVO_DECISAO = NULL,    
                                  @lote_contabil = NULL,     
             @data_perda = NULL,     
             @origem  = @v_origem,    
                                  @item_estornado = @v_item_cobranca,  
                                  @encerr_processado = @v_encerr_processado   
    
       EXEC GetErrorsCount @v_ErrorsCount output    
       IF @v_ErrorsCount > 0    
          BEGIN    
             EXEC GetErros @v_Erros Output    
             ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
             if @aux_banco = 'SQL'    
                    Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount    
             EXEC SetErro @v_Erros    
             EXEC SetErro 'Estorno de Cobranca. Erro no estorno do item de cobrança.', ''    
             CLOSE C_ITEM_LANC_A_ESTORNAR    
             DEALLOCATE C_ITEM_LANC_A_ESTORNAR    
             RETURN    
          END    
                    
       
    FETCH NEXT FROM C_ITEM_LANC_A_ESTORNAR INTO @v_Cobranca,@v_LancDebito,@v_Codigo_Lanc,@v_Aluno,@v_Num_Bolsa,@v_Resp,    
    @v_Mot_Desconto,@v_Devolucao,@v_Boleto,@v_Parcela,@v_Valor,@v_Descricao,@v_Acordo,@v_Cobranca_Orig,@v_ItemCob_Orig,@v_Centro_Custo,    
    @v_Natureza,@v_Ano_Ref_Bolsa,@v_Mes_Ref_Bolsa, @v_curso, @v_turno, @v_curriculo, @v_unidfisica, @v_origem, @v_item_cobranca,@v_encerr_processado                   
 END    
    
  CLOSE C_ITEM_LANC_A_ESTORNAR    
  DEALLOCATE C_ITEM_LANC_A_ESTORNAR    
    
 EXEC LY_COBRANCA_UPDATE @pkCobranca = @p_Cobranca, @estorno = 'S', @dt_estorno = @v_Data    
    
 EXEC GetErrorsCount @v_ErrorsCount output    
 IF @v_ErrorsCount > 0    
   BEGIN    
   EXEC GetErros @v_Erros Output    
   ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
   if @aux_banco = 'SQL'    
    Commit transaction -- pois o rollback até umf save point não decrementa a variavel @@trancount    
   EXEC SetErro @v_Erros    
   EXEC SetErro 'Estorno de Cobranca. Erro na atualização de cobrança.', ''    
   RETURN    
   END    
     
 EXEC a_ESTORNA_COBRANCA @p_Cobranca    
     
 EXEC GetErrorsCount @v_ErrorsCount output    
 IF @v_ErrorsCount > 0    
   BEGIN    
   EXEC GetErros @v_Erros Output    
   ROLLBACK TRANSACTION TR_ESTORNA_COBRANCA    
   if @aux_banco = 'SQL'    
    Commit transaction -- pois o rollback até umf save point não decrementa a variavel @@trancount    
   EXEC SetErro @v_Erros    
   EXEC SetErro 'Estorno de Cobranca. Erro na execução do entry-point a_ESTORNA_COBRANCA.', ''    
   RETURN    
   END    
                       
  if @aux_banco = 'SQL'    
      COMMIT TRANSACTION TR_ESTORNA_COBRANCA    
-- [FIM]    