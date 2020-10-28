  
CREATE PROCEDURE PROC_GERA_RPS              
 @p_Tipo        T_CODIGO,              
 @p_Unidade     T_CODIGO,            
 @p_dtvenc_ini  T_DATA,                    
 @p_dtvenc_fim  T_DATA,            
 @p_Tipo_Data   VARCHAR(20),                  
 @p_sit_boletos T_NUMERO_PEQUENO,                    
 @p_op_emissao  T_NUMERO_PEQUENO,                    
 @p_dtemissao   T_DATA,                  
 @p_boleto      T_NUMERO = null,          
 @p_Serie       VARCHAR(5),           
 @p_TipoValor   VARCHAR(50),        
 @p_cobranca    T_NUMERO = null,  
 @p_conjrespfinan    T_CODIGO                            
AS                    
-- [INÍCIO]                    
BEGIN                    
 DECLARE @v_boleto               T_NUMERO                    
 DECLARE @v_gera                 VARCHAR(1)                    
 DECLARE @v_valor_item_lanc      T_DECIMAL_MEDIO                    
 DECLARE @v_valor_item_cred      T_DECIMAL_MEDIO                    
 DECLARE @v_valor_a_pagar_boleto T_DECIMAL_MEDIO                    
 DECLARE @v_data_de_vencimento   T_DATA                    
 DECLARE @v_dt_credito           T_DATA                    
 DECLARE @v_dt_emissao           T_DATA                    
 DECLARE @v_unidade_fisica       T_CODIGO                    
 DECLARE @v_contador             INTEGER                    
 DECLARE @v_contador_erros       INTEGER                      
 DECLARE @v_erro                 varchar(8000)                    
 DECLARE @v_erroCount            int                    
 DECLARE @v_C_BOLETO_ROWS        T_NUMERO                    
 DECLARE @v_Msg_Refresh          varchar(4000)                    
 DECLARE @v_straux1              varchar(100)                    
 DECLARE @v_straux2              varchar(100)                    
 DECLARE @v_straux3              varchar(100)                    
 DECLARE @v_sessao_id            T_NUMERO                      
 DECLARE @aux_banco              varchar(10)                    
 DECLARE @v_percentual           decimal(16,2)                      
 DECLARE @v_Count                T_NUMERO               
 DECLARE @v_unidade              T_CODIGO            
 DECLARE @v_Qualtipo             varchar(1)            
 DECLARE @v_Serie                VARCHAR(5)            
 DECLARE @v_Cob                  T_SIMNAO        
 DECLARE @v_ALIQUOTA             numeric(5, 2)        
 DECLARE @v_codigo_lanc          T_CODIGO        
 DECLARE @v_codigo_servico       T_NUMERO   
 DECLARE @v_cob_boleto   T_NUMERO  
 DECLARE @v_gera_pgto_parcial    T_SIMNAO   
 DECLARE @v_ErrorsCount   int   
 DECLARE @v_gera_rps    VARCHAR(1)    
 DECLARE @v_substitui   VARCHAR(1)   
   
        
 EXECUTE tipobanco @aux_banco output                    
 EXECUTE spProcInicia 'PROC_GERA_RPS'                    
                    
 -- -----------------------------------------------------------------------------------                    
 --    Validação de parâmetros OBRIGATÓRIOS (Exceto Unidade e Empresa que é um dos dois)                     
 -- -----------------------------------------------------------------------------------                    
 IF @p_Tipo is null            
  BEGIN                    
   SELECT @v_erro = 'Você deve informar o Tipo'            
   EXECUTE seterro @v_erro, 'Tipo'                    
   EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                    
   GOTO FIM_PROC                    
  END            
              
 IF @p_Unidade is null                    
  BEGIN                    
   SELECT @v_erro = 'Você deve informar a Unidade ou a Empresa'            
   EXECUTE seterro @v_erro, 'Unidade'                    
   EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                    
   GOTO FIM_PROC                    
  END            
            
          
 -- Indicando se é Empresa ou Unidade para tipo            
 IF @p_Tipo is not null            
  BEGIN            
   IF @p_Tipo = 'Unidade'            
    BEGIN            
     SELECT @p_Tipo = 'U'            
    END            
      
   IF @p_Tipo = 'Empresa'          
    BEGIN            
     SELECT @p_Tipo = 'E'            
    END       
     
   IF @p_Tipo = 'Mantenedora'          
    BEGIN            
     SELECT @p_Tipo = 'M'            
    END   
  END            
            
 IF @p_dtvenc_ini is null                
  BEGIN          
   SELECT @v_erro = 'Data de vencimento inicial não informada'                    
   EXECUTE seterro @v_erro, 'Data de Vencimento Inicial'                    
   EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                    
   GOTO FIM_PROC                    
  END        
   
 IF @p_dtvenc_fim is null                    
  BEGIN          
   SELECT @v_erro = 'Data de vencimento final não informada'                    
   EXECUTE seterro @v_erro, 'Data de Vencimento Final'                    
   EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                    
   GOTO FIM_PROC                    
  END       
   
 IF @p_dtvenc_fim < @p_dtvenc_ini                      
   BEGIN            
    SELECT @v_erro = 'Data de vencimento final não pode ser menor que a inicial'                      
    EXECUTE seterro @v_erro, 'Data de Vencimento Final'                      
    EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                      
    GOTO FIM_PROC                      
   END   
       
 IF @p_op_emissao = 3 AND @p_dtemissao is null                    
  BEGIN                    
   SELECT @v_erro = 'Data de emissão não informada'                    
   EXECUTE seterro @v_erro, 'Data de Emissão'                    
   EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                    
   GOTO FIM_PROC                    
  END                    
              
 -- ---------------------------------------------------------------------------                    
 --    Validação do campo Unidade            
 -- ---------------------------------------------------------------------------                    
 IF @p_Tipo = 'U'            
  BEGIN                
   IF @p_Unidade is not null                  
    BEGIN                   
     SELECT @v_unidade = FACULDADE             
     FROM VW_FACULDADE            
     WHERE Faculdade = @p_Unidade            
                 
     IF @v_unidade is null or @v_unidade = ''            
      BEGIN                  
       SELECT @v_erro = 'Você deve informar uma Unidade válida.'            
       EXECUTE SetErro @v_erro , 'Unidade'                  
       EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                  
       GOTO FIM_PROC                    
      END                  
    END                       
  END    
   
 IF @p_Tipo = 'E'          
  BEGIN            
   IF @p_Unidade is not null                  
    BEGIN                   
     SELECT @v_unidade = Empresa             
     FROM ly_empresa            
     WHERE empresa = @p_Unidade            
                  
     IF @v_unidade is null or @v_unidade = ''            
      BEGIN                  
       SELECT @v_erro = 'Você deve informar uma Empresa válida.'            
       EXECUTE SetErro @v_erro , 'Unidade'                  
       EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                  
       GOTO FIM_PROC                    
      END                  
    END                  
  END            
      
 IF @p_Tipo = 'M'      
  BEGIN            
   IF @p_Unidade is not null                  
    BEGIN                   
     SELECT @v_unidade = Mantenedora             
     FROM ly_mantenedora            
     WHERE mantenedora = @p_Unidade            
       
     IF @v_unidade is null or @v_unidade = ''            
      BEGIN                  
       SELECT @v_erro = 'Você deve informar uma Mantenedora válida.'            
       EXECUTE SetErro @v_erro , 'Unidade'                  
       EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                  
       GOTO FIM_PROC                    
      END                  
    END                  
  END  
    
 IF @p_Serie is null                    
  BEGIN                    
   SELECT @v_erro = 'Você deve informar a Série'            
   EXECUTE seterro @v_erro, 'Série'                    
   EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                    
   GOTO FIM_PROC                    
  END            
 ELSE          
  BEGIN          
   SELECT @v_count = 0                           
   SELECT @v_count = ISNULL(COUNT(*),0)          
   FROM LY_OPCOES_NOTA_FISCAL WHERE NOTA_FISCAL_SERIE = @p_Serie          
          
   IF @v_count is null or @v_count = 0          
    BEGIN                  
     SELECT @v_erro = 'Série inválida: ' + ltrim(rtrim(@p_Serie))                
     EXECUTE SetErro @v_erro , 'Série'                  
     EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                  
     GOTO FIM_PROC                    
    END            
   ELSE          
    BEGIN          
     SELECT @v_Serie = @p_Serie          
    END          
  END          
          
 -- ---------------------------------------------------------------------------                    
 --    Validação de parâmetros não OBRIGATÓRIOS                    
 -- ---------------------------------------------------------------------------                    
 IF @p_boleto is not null                  
  BEGIN                   
   SELECT @v_count = 0                           
   SELECT @v_count = isnull(COUNT(*),0)                   
   FROM Ly_Boleto WHERE BOLETO = @p_boleto                  
     
   IF @v_count is null or @v_count = 0                  
    BEGIN                  
     SELECT @v_erro = 'Boleto inválido: ' + ltrim(rtrim(str(@p_boleto)))                
     EXECUTE SetErro @v_erro , 'Boleto'                  
     EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                  
     GOTO FIM_PROC                    
    END                  
  END               
        
 IF @p_cobranca is not null                  
  BEGIN              
   SELECT @v_count = 0               
   SELECT @v_count = isnull(COUNT(*),0)                   
   FROM Ly_Cobranca WHERE COBRANCA = @p_cobranca                  
     
   IF @v_count is null or @v_count = 0                  
    BEGIN                  
     SELECT @v_erro = 'Cobrança inválida: ' + ltrim(rtrim(str(@p_cobranca)))                
     EXECUTE SetErro @v_erro , 'Cobrança'                  
     EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                  
     GOTO FIM_PROC                    
    END                  
  END    
  
 IF @p_conjrespfinan is not null                  
  BEGIN              
   SELECT @v_count = 0               
   SELECT @v_count = isnull(COUNT(*),0)                   
   FROM Ly_Conj_Resp_Finan WHERE CONJ_RESP_FINAN = @p_conjrespfinan                  
     
   IF @v_count is null or @v_count = 0                  
    BEGIN                  
     SELECT @v_erro = 'Conjunto de responsáveis financeiros inválido: ' + ltrim(rtrim(str(@p_conjrespfinan)))                
     EXECUTE SetErro @v_erro , 'ConjuntoResponsavelFinan'                  
     EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null                  
     GOTO FIM_PROC                    
    END                  
  END                                             
                   
 -- ------------------------------------------------------------------------------------------                    
 --  Chamada do Entry-Point S_PROC_GERA_RPS para substituir o calculo realizado pela procedure  
 -- ------------------------------------------------------------------------------------------                    
 EXEC S_PROC_GERA_RPS  
  @p_Tipo = @p_Tipo  
  , @p_Unidade = @p_Unidade  
  , @p_dtvenc_ini = @p_dtvenc_ini  
  , @p_dtvenc_fim = @p_dtvenc_fim  
  , @p_Tipo_Data = @p_Tipo_Data  
  , @p_sit_boletos = @p_sit_boletos  
  , @p_op_emissao = @p_op_emissao  
  , @p_dtemissao = @p_dtemissao  
  , @p_boleto = @p_boleto  
  , @p_Serie = @p_Serie  
  , @p_TipoValor = @p_TipoValor  
  , @p_cobranca = @p_cobranca  
  , @p_conjrespfinan = @p_conjrespfinan  
  , @p_substitui = @v_substitui output  
  
 if @v_substitui = 'S'  
 RETURN  
 -- ------------------------------------------------------------------------------------------    
         
                      
 -- ------------------------------------------------------------------------------------------                    
 --  Seleciona os boletos para os quais serão gerados os recibos                    
 -- ------------------------------------------------------------------------------------------                    
 SELECT @v_contador = 0                    
 SELECT @v_contador_erros = 0                          
 SELECT @v_cob = 'N'  
 SELECT @v_gera_pgto_parcial = 'N'            
            
 SELECT @v_cob = ISNULL(COBRANCA, 'N'), @v_gera_pgto_parcial = ISNULL(GERA_PGTO_PARCIAL, 'N')        
 FROM LY_OPCOES_NOTA_FISCAL         
 WHERE FACULDADE = @p_unidade         
 AND NOTA_FISCAL_SERIE = @p_Serie          
 AND TIPO = @p_Tipo        
 --AND COBRANCA = 'S'              
          
 IF @p_Tipo = 'E'            
  BEGIN -- Quando o Tipo = Empresa          
   IF @v_cob <> 'N'         
    BEGIN        
     -- APAGA AS COBRANÇAS COM NUMERO_RPS IGUAL A NULL        
     DELETE FROM LY_COBRANCA_NOTA_FISCAL WHERE NUMERO_RPS IS  NULL        
                                                                                                                        
     -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
     DECLARE C_BOLETO_1 CURSOR STATIC READ_ONLY FOR               
                       
     SELECT distinct C.COBRANCA, ALIQUOTA, C.DATA_DE_VENCIMENTO, @p_unidade EMPRESA, N.CODIGO_SERVICO                 
     FROM ly_item_lanc i, ly_nota_fiscal_cod_lanc n,         
     ly_cobranca c,  LY_LANC_DEBITO LD, LY_AGREGA_ITEM_COBRANCA AIC                  
     WHERE i.cobranca = c.cobranca                     
     AND i.codigo_lanc = n.codigo_lanc         
     AND c.data_de_vencimento >= @p_dtvenc_ini                    
     AND c.data_de_vencimento <= @p_dtvenc_fim                     
     AND c.DATA_DE_FATURAMENTO is not null                     
     AND LD.LANC_DEB = I.LANC_DEB          
     AND LD.GRUPO = AIC.GRUPO                    
     AND AIC.empresa = n.faculdade                         
     AND n.faculdade = @p_unidade                   
     AND ((@p_cobranca is not NULL AND C.COBRANCA = @p_cobranca) or @p_cobranca is null)          
     AND n.nota_fiscal_serie = @v_Serie           
     AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = C.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)        
     AND (@p_TipoValor <> 'Valor Pago' OR @p_TipoValor = 'Valor Pago' AND EXISTS (SELECT 1 FROM LY_LANC_CREDITO LC, LY_ITEM_CRED IC        
                        WHERE LC.LANC_CRED = IC.LANC_CRED         
                        AND IC.COBRANCA = C.COBRANCA         
                        AND I.DATA <= LC.DATA))        
     AND (@p_conjrespfinan Is Null  
        OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = c.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
       )                           
                                                                                                 
       
     IF @aux_banco <> 'SQL'  
       BEGIN   
      SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(*),0)                    
      FROM ly_item_lanc i, ly_nota_fiscal_cod_lanc n,         
      ly_cobranca c, LY_LANC_DEBITO LD, LY_AGREGA_ITEM_COBRANCA AIC                   
      WHERE i.cobranca = c.cobranca                     
      AND i.codigo_lanc = n.codigo_lanc         
      AND LD.LANC_DEB = I.LANC_DEB          
      AND LD.GRUPO = AIC.GRUPO                    
      AND AIC.empresa = n.faculdade                         
      AND c.data_de_vencimento >= @p_dtvenc_ini                    
      AND c.data_de_vencimento <= @p_dtvenc_fim                     
      AND c.DATA_DE_FATURAMENTO is not null                     
      AND n.faculdade = @p_unidade                   
      AND ((@p_cobranca is not NULL AND C.COBRANCA = @p_cobranca) or @p_cobranca is null)          
      AND n.nota_fiscal_serie = @v_Serie           
      AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = C.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)        
      AND (@p_TipoValor <> 'Valor Pago' OR @p_TipoValor = 'Valor Pago' AND EXISTS (SELECT 1 FROM LY_LANC_CREDITO LC, LY_ITEM_CRED IC        
                         WHERE LC.LANC_CRED = IC.LANC_CRED         
                         AND IC.COBRANCA = C.COBRANCA         
                         AND I.DATA <= LC.DATA))        
      AND (@p_conjrespfinan Is Null  
         OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = c.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
        )                           
                      END -- IF @aux_banco <> 'SQL'         
    END   
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento' -- TIPO DE PAGAMENTO          
      BEGIN          
       -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
       DECLARE C_BOLETO_2 CURSOR STATIC READ_ONLY FOR               
            
       SELECT distinct B.BOLETO, 0 as ALIQUOTA, C.DATA_DE_VENCIMENTO, B.EMPRESA, 0 CODIGO_SERVICO                   
       FROM ly_boleto b, ly_item_lanc i, ly_nota_fiscal_cod_lanc n,             
       ly_cobranca c, ly_aluno a, ly_curso u                    
       WHERE b.Boleto = i.Boleto AND i.cobranca = c.cobranca                     
       AND i.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
       AND b.empresa = n.faculdade             
       AND a.curso = u.curso                            
       AND (b.numero_rps is null OR (b.DT_SOLICITA_CANCEL_RPS is not null AND b.DT_ENVIO_CANCEL_RPS is not null)) AND b.removido = 'N'                     
       AND c.data_de_vencimento >= @p_dtvenc_ini                    
       AND c.data_de_vencimento <= @p_dtvenc_fim                     
       AND c.DATA_DE_FATURAMENTO is not null                     
       AND B.EMPRESA = @p_unidade            
       AND ((@p_boleto is not NULL AND B.BOLETO = @p_boleto) or @p_boleto is null)              
       AND n.nota_fiscal_serie = @v_Serie    
       AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = b.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )         
             
             IF @aux_banco <> 'SQL'  
               BEGIN   
           SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(DISTINCT(B.BOLETO)),0)                    
        FROM ly_boleto b, ly_item_lanc i, ly_nota_fiscal_cod_lanc n,                    
        ly_cobranca c, ly_aluno a, ly_curso u                    
        WHERE b.Boleto = i.Boleto AND i.cobranca = c.cobranca                     
        AND i.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
        AND b.empresa = n.faculdade AND a.curso = u.curso                              
        AND (b.numero_rps is null OR (b.DT_SOLICITA_CANCEL_RPS is not null AND b.DT_ENVIO_CANCEL_RPS is not null)) AND b.removido = 'N'                     
        AND c.data_de_vencimento >= @p_dtvenc_ini                    
        AND c.data_de_vencimento <= @p_dtvenc_fim                     
        AND c.DATA_DE_FATURAMENTO is not null                     
        AND b.empresa = @p_unidade            
        AND ((@p_boleto is not NULL AND B.BOLETO = @p_boleto) or @p_boleto is null)             
        AND n.nota_fiscal_serie = @v_Serie   
        AND (@p_conjrespfinan Is Null  
         OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = b.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )             
                              END -- IF @aux_banco <> 'SQL'           
      END            
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento' -- TIPO DE PAGAMENTO          
       BEGIN          
        -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
        DECLARE C_BOLETO_3 CURSOR STATIC READ_ONLY FOR               
            
        SELECT distinct B.BOLETO, 0 as ALIQUOTA, C.DATA_DE_VENCIMENTO, B.EMPRESA, 0 CODIGO_SERVICO                   
        FROM ly_boleto b, ly_item_lanc i, ly_nota_fiscal_cod_lanc n,             
        ly_cobranca c, ly_aluno a, ly_curso u, ly_lanc_debito deb  
        WHERE b.Boleto = i.Boleto AND i.cobranca = c.cobranca                     
        AND i.lanc_deb = deb.lanc_deb  
        AND deb.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
        AND b.empresa = n.faculdade             
        AND a.curso = u.curso                                  
        AND (b.numero_rps is null OR (b.DT_SOLICITA_CANCEL_RPS is not null AND b.DT_ENVIO_CANCEL_RPS is not null)) AND b.removido = 'N'                     
        AND EXISTS(SELECT 1  
             FROM ly_lanc_credito lc    
             WHERE EXISTS (SELECT 1  
               FROM LY_ITEM_CRED IC  
               WHERE LC.LANC_CRED = IC.LANC_CRED  
                  AND C.COBRANCA  = IC.COBRANCA  
               GROUP BY IC.LANC_CRED  
               HAVING SUM(VALOR) <> 0  
              )                                         
                         AND lc.dt_credito >= @p_dtvenc_ini                    
                         AND lc.dt_credito <= @p_dtvenc_fim                     
                         AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
             AND lc.tipo_pagamento <> 'Arrasto'   
             AND lc.tipo_pagamento <> 'Restituicao'  
                    )      
        AND c.DATA_DE_FATURAMENTO is not null                     
        AND B.EMPRESA = @p_unidade            
        AND ((@p_boleto is not NULL AND B.BOLETO = @p_boleto) or @p_boleto is null)              
        AND n.nota_fiscal_serie = @v_Serie   
        AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = b.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )           
            
                                IF @aux_banco <> 'SQL'  
                   BEGIN   
            SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(DISTINCT(B.BOLETO)),0)                    
         FROM ly_boleto b, ly_item_lanc i, ly_nota_fiscal_cod_lanc n,                    
         ly_cobranca c, ly_aluno a, ly_curso u, ly_lanc_debito deb  
         WHERE b.Boleto = i.Boleto AND i.cobranca = c.cobranca                     
         AND i.lanc_deb = deb.lanc_deb  
         AND deb.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
         AND b.empresa = n.faculdade AND a.curso = u.curso                              
         AND (b.numero_rps is null OR (b.DT_SOLICITA_CANCEL_RPS is not null AND b.DT_ENVIO_CANCEL_RPS is not null)) AND b.removido = 'N'                     
         AND EXISTS(SELECT 1  
              FROM ly_lanc_credito lc    
               WHERE EXISTS (SELECT 1  
                          FROM LY_ITEM_CRED IC  
                 WHERE LC.LANC_CRED = IC.LANC_CRED  
                       AND C.COBRANCA  = IC.COBRANCA  
                    GROUP BY IC.LANC_CRED  
                    HAVING SUM(VALOR) <> 0  
                    )                                 
                  AND lc.dt_credito >= @p_dtvenc_ini                    
                  AND lc.dt_credito <= @p_dtvenc_fim  
                  AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
               AND lc.tipo_pagamento <> 'Arrasto'   
               AND lc.tipo_pagamento <> 'Restituicao'  
                 )                     
         AND c.DATA_DE_FATURAMENTO is not null                     
         AND b.empresa = @p_unidade            
         AND ((@p_boleto is not NULL AND B.BOLETO = @p_boleto) or @p_boleto is null)             
         AND n.nota_fiscal_serie = @v_Serie  
         AND (@p_conjrespfinan Is Null  
              OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = b.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
              )                   
                            END -- IF @aux_banco <> 'SQL'      
       END          
    END       --IF @v_cob <> 'N'           
  END       
   
 IF @p_Tipo = 'U'            
  BEGIN -- Quando o Tipo = Unidade            
   IF @v_cob <> 'N'         
    BEGIN        
     IF @p_Tipo_Data = 'Data de Vencimento' -- TIPO DE PAGAMENTO          
      BEGIN         
       -- APAGA AS COBRANÇAS COM NUMERO_RPS IGUAL A NULL        
       DELETE FROM LY_COBRANCA_NOTA_FISCAL WHERE NUMERO_RPS IS  NULL        
                          
       -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
       DECLARE C_BOLETO_4 CURSOR STATIC READ_ONLY FOR               
         
       SELECT distinct C.COBRANCA, ALIQUOTA, C.DATA_DE_VENCIMENTO, A.UNIDADE_FISICA, N.CODIGO_SERVICO                 
       FROM ly_item_lanc i, ly_nota_fiscal_cod_lanc n,             
       ly_cobranca c, ly_aluno a, ly_curso u                    
       WHERE i.cobranca = c.cobranca                     
       AND i.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
       AND a.unidade_fisica = n.faculdade AND a.curso = u.curso                             
       AND c.data_de_vencimento >= @p_dtvenc_ini                    
       AND c.data_de_vencimento <= @p_dtvenc_fim                     
       AND c.DATA_DE_FATURAMENTO is not null                     
       AND n.faculdade = @p_unidade                   
       AND ((@p_cobranca is not NULL AND C.COBRANCA = @p_cobranca) or @p_cobranca is null)          
       AND n.nota_fiscal_serie = @v_Serie           
       AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = C.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)        
       AND (@p_TipoValor <> 'Valor Pago' OR @p_TipoValor = 'Valor Pago' AND EXISTS (SELECT 1 FROM LY_LANC_CREDITO LC, LY_ITEM_CRED IC        
                            WHERE LC.LANC_CRED = IC.LANC_CRED         
                           AND IC.COBRANCA = C.COBRANCA         
                           AND I.DATA <= LC.DATA))        
       AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = c.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )       
  
                   IF @aux_banco <> 'SQL'  
                     BEGIN        
        SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(*),0)                    
        FROM ly_item_lanc i, ly_nota_fiscal_cod_lanc n,             
        ly_cobranca c, ly_aluno a, ly_curso u                    
        WHERE i.cobranca = c.cobranca                     
        AND i.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
        AND a.unidade_fisica = n.faculdade AND a.curso = u.curso                             
        AND c.data_de_vencimento >= @p_dtvenc_ini                    
        AND c.data_de_vencimento <= @p_dtvenc_fim                     
        AND c.DATA_DE_FATURAMENTO is not null                     
        AND n.faculdade = @p_unidade                   
        AND ((@p_cobranca is not NULL AND C.COBRANCA = @p_cobranca) or @p_cobranca is null)          
        AND n.nota_fiscal_serie = @v_Serie           
        AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = C.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)        
        AND (@p_TipoValor <> 'Valor Pago' OR @p_TipoValor = 'Valor Pago' AND EXISTS (SELECT 1 FROM LY_LANC_CREDITO LC, LY_ITEM_CRED IC        
                                                                                  WHERE LC.LANC_CRED = IC.LANC_CRED         
                                     AND IC.COBRANCA = C.COBRANCA         
                                     AND I.DATA <= LC.DATA))        
           AND (@p_conjrespfinan Is Null  
             OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = c.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
             )                             
                              END -- IF @aux_banco <> 'SQL'              
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento' -- TIPO DE PAGAMENTO          
       BEGIN          
        -- APAGA AS COBRANÇAS COM NUMERO_RPS IGUAL A NULL        
        DELETE FROM LY_COBRANCA_NOTA_FISCAL WHERE NUMERO_RPS IS  NULL        
           
        -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
        DECLARE C_BOLETO_5 CURSOR STATIC READ_ONLY FOR               
              
        SELECT distinct C.COBRANCA, ALIQUOTA, C.DATA_DE_VENCIMENTO, A.UNIDADE_FISICA, N.CODIGO_SERVICO                 
        FROM  ly_item_lanc i, ly_nota_fiscal_cod_lanc n,             
        ly_cobranca c, ly_aluno a, ly_curso u, ly_lanc_debito deb  
        WHERE i.cobranca = c.cobranca         
        AND i.lanc_deb = deb.lanc_deb  
        AND deb.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
        AND a.unidade_fisica = n.faculdade AND a.curso = u.curso           
        AND n.faculdade = @p_unidade                   
        AND c.DATA_DE_FATURAMENTO is not null                     
        AND ((@p_cobranca is not NULL AND C.COBRANCA = @p_cobranca) or @p_cobranca is null)          
        AND n.nota_fiscal_serie = @v_Serie           
        AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = C.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)        
        AND EXISTS (select 1 from LY_LANC_CREDITO lc INNER JOIN LY_ITEM_CRED ic on lc.LANC_CRED = ic.LANC_CRED        
           where ic.cobranca = c.cobranca        
           AND lc.dt_credito >= @p_dtvenc_ini                    
           AND lc.dt_credito <= @p_dtvenc_fim          
           AND ic.tipodesconto is null         
           AND ic.tipo_encargo is null  
           AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
           AND lc.tipo_pagamento <> 'Arrasto'   
           AND lc.tipo_pagamento <> 'Restituicao')  
        AND (@p_conjrespfinan Is Null  
           OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = c.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
          )               
  
                                IF @aux_banco <> 'SQL'                  
                                  BEGIN  
         SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(*),0)                    
         FROM  ly_item_lanc i, ly_nota_fiscal_cod_lanc n,             
         ly_cobranca c, ly_aluno a, ly_curso u, ly_lanc_debito deb  
         WHERE i.cobranca = c.cobranca         
         AND i.lanc_deb = deb.lanc_deb  
         AND deb.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
         AND a.unidade_fisica = n.faculdade AND a.curso = u.curso           
         AND n.faculdade = @p_unidade                   
         AND c.DATA_DE_FATURAMENTO is not null                     
         AND ((@p_cobranca is not NULL AND C.COBRANCA = @p_cobranca) or @p_cobranca is null)          
         AND n.nota_fiscal_serie = @v_Serie           
         AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = C.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)        
         AND EXISTS (select 1 from LY_LANC_CREDITO lc INNER JOIN LY_ITEM_CRED ic on lc.LANC_CRED = ic.LANC_CRED        
            where ic.cobranca = c.cobranca        
            AND lc.dt_credito >= @p_dtvenc_ini                    
            AND lc.dt_credito <= @p_dtvenc_fim          
            AND ic.tipodesconto is null         
            AND ic.tipo_encargo is null  
            AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
            AND lc.tipo_pagamento <> 'Arrasto'   
            AND lc.tipo_pagamento <> 'Restituicao')     
         AND (@p_conjrespfinan Is Null  
            OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = c.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
          )                 
                                  END -- IF @aux_banco <> 'SQL'                              
       END          
    END   
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento' -- TIPO DE PAGAMENTO          
      BEGIN          
       -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
       DECLARE C_BOLETO_6 CURSOR STATIC READ_ONLY FOR              
         
       SELECT distinct B.BOLETO, 0 as ALIQUOTA, C.DATA_DE_VENCIMENTO, A.UNIDADE_FISICA, 0 CODIGO_SERVICO                 
       FROM ly_boleto b, ly_item_lanc i, ly_nota_fiscal_cod_lanc n,             
       ly_cobranca c, ly_aluno a, ly_curso u                    
       WHERE b.Boleto = i.Boleto AND i.cobranca = c.cobranca                     
       AND i.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
       AND a.unidade_fisica = n.faculdade AND a.curso = u.curso AND b.Empresa is Null                                
       AND (b.numero_rps is null OR (b.DT_SOLICITA_CANCEL_RPS is not null AND b.DT_ENVIO_CANCEL_RPS is not null)) AND b.removido = 'N'                     
       AND c.data_de_vencimento >= @p_dtvenc_ini                    
       AND c.data_de_vencimento <= @p_dtvenc_fim                     
       AND c.DATA_DE_FATURAMENTO is not null                     
       AND n.faculdade = @p_unidade                   
       AND ((@p_boleto is not NULL AND B.BOLETO = @p_boleto) or @p_boleto is null)                       
       AND n.nota_fiscal_serie = @v_Serie   
       AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = b.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )          
  
                            IF @aux_banco <> 'SQL'                  
                              BEGIN             
        SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(DISTINCT(B.BOLETO)),0)                    
        FROM ly_boleto b, ly_item_lanc i, ly_nota_fiscal_cod_lanc n,           
        ly_cobranca c, ly_aluno a, ly_curso u                    
        WHERE b.Boleto = i.Boleto AND i.cobranca = c.cobranca                     
        AND i.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
        AND a.unidade_fisica = n.faculdade AND a.curso = u.curso                               
        AND (b.numero_rps is null OR (b.DT_SOLICITA_CANCEL_RPS is not null AND b.DT_ENVIO_CANCEL_RPS is not null)) AND b.removido = 'N'                     
        AND c.data_de_vencimento >= @p_dtvenc_ini                    
        AND c.data_de_vencimento <= @p_dtvenc_fim                     
        AND c.DATA_DE_FATURAMENTO is not null                     
        AND n.faculdade = @p_unidade AND b.Empresa is Null                   
        AND ((@p_boleto is not NULL AND B.BOLETO = @p_boleto) or @p_boleto is null)                         
        AND n.nota_fiscal_serie = @v_Serie  
        AND (@p_conjrespfinan Is Null  
           OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = b.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )           
         END -- IF @aux_banco <> 'SQL'                  
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento' -- TIPO DE PAGAMENTO          
       BEGIN          
        -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
        DECLARE C_BOLETO_7 CURSOR STATIC READ_ONLY FOR               
         
        SELECT distinct B.BOLETO, 0 AS ALIQUOTA, C.DATA_DE_VENCIMENTO, A.UNIDADE_FISICA, 0 CODIGO_SERVICO                 
        FROM ly_boleto b, ly_item_lanc i, ly_nota_fiscal_cod_lanc n,             
        ly_cobranca c, ly_aluno a, ly_curso u, ly_lanc_debito deb  
        WHERE b.Boleto = i.Boleto AND i.cobranca = c.cobranca                     
        AND i.lanc_deb = deb.lanc_deb  
        AND deb.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
        AND a.unidade_fisica = n.faculdade AND a.curso = u.curso                  
        AND b.Empresa is Null                                
        AND (b.numero_rps is null OR (b.DT_SOLICITA_CANCEL_RPS is not null AND b.DT_ENVIO_CANCEL_RPS is not null)) AND b.removido = 'N'                     
        AND EXISTS(SELECT 1  
             FROM ly_lanc_credito lc    
             WHERE EXISTS (SELECT 1  
               FROM LY_ITEM_CRED IC  
               WHERE LC.LANC_CRED = IC.LANC_CRED  
                  AND C.COBRANCA  = IC.COBRANCA  
               GROUP BY IC.LANC_CRED  
               HAVING SUM(VALOR) <> 0  
              )                                 
             AND lc.dt_credito >= @p_dtvenc_ini                 
             AND lc.dt_credito <= @p_dtvenc_fim  
             AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
             AND lc.tipo_pagamento <> 'Arrasto'   
             AND lc.tipo_pagamento <> 'Restituicao'   
             )                     
        AND c.DATA_DE_FATURAMENTO is not null                     
        AND n.faculdade = @p_unidade                   
        AND ((@p_boleto is not NULL AND B.BOLETO = @p_boleto) or @p_boleto is null)                       
        AND n.nota_fiscal_serie = @v_Serie   
        AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = b.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )            
            
                                IF @aux_banco <> 'SQL'                  
                                  BEGIN             
         SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(DISTINCT(B.BOLETO)),0)                    
         FROM ly_boleto b, ly_item_lanc i, ly_nota_fiscal_cod_lanc n,           
         ly_cobranca c, ly_aluno a, ly_curso u, ly_lanc_debito deb  
         WHERE b.Boleto = i.Boleto AND i.cobranca = c.cobranca                     
         AND i.lanc_deb = deb.lanc_deb  
         AND deb.codigo_lanc = n.codigo_lanc AND c.aluno = a.aluno                     
         AND a.unidade_fisica = n.faculdade AND a.curso = u.curso                                       
         AND (b.numero_rps is null OR (b.DT_SOLICITA_CANCEL_RPS is not null AND b.DT_ENVIO_CANCEL_RPS is not null)) AND b.removido = 'N'                     
         AND EXISTS(SELECT 1  
              FROM ly_lanc_credito lc    
              WHERE EXISTS (SELECT 1  
                FROM LY_ITEM_CRED IC  
                WHERE LC.LANC_CRED = IC.LANC_CRED  
                 AND C.COBRANCA  = IC.COBRANCA  
                GROUP BY IC.LANC_CRED  
                HAVING SUM(VALOR) <> 0  
               )                                 
              AND lc.dt_credito >= @p_dtvenc_ini                 
              AND lc.dt_credito <= @p_dtvenc_fim  
              AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
              AND lc.tipo_pagamento <> 'Arrasto'   
              AND lc.tipo_pagamento <> 'Restituicao'   
             )                     
         AND c.DATA_DE_FATURAMENTO is not null                     
         AND n.faculdade = @p_unidade AND b.Empresa is Null                   
         AND ((@p_boleto is not NULL AND B.BOLETO = @p_boleto) or @p_boleto is null)                         
         AND n.nota_fiscal_serie = @v_Serie    
         AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = b.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
          )                
          END  -- IF @aux_banco <> 'SQL'                  
       END          
    END   
  END          
     
 IF @p_Tipo = 'M'         
  BEGIN -- Quando o Tipo = Matenedora                       
   IF @v_cob <> 'N'         
    BEGIN        
     IF @p_Tipo_Data = 'Data de Vencimento' -- TIPO DE PAGAMENTO          
      BEGIN         
       -- APAGA AS COBRANÇAS COM NUMERO_RPS IGUAL A NULL        
       DELETE FROM LY_COBRANCA_NOTA_FISCAL WHERE NUMERO_RPS IS  NULL      
          
       -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
       DECLARE C_BOLETO_8 CURSOR STATIC READ_ONLY FOR               
       SELECT DISTINCT co.COBRANCA, ALIQUOTA, co.DATA_DE_VENCIMENTO, i.mantenedora, N.CODIGO_SERVICO  
       from LY_ALUNO a, LY_UNIDADE_ENSINO u, LY_CURSO c, LY_INSTITUICAO i, LY_COBRANCA co, ly_item_lanc il, ly_lanc_debito deb, ly_nota_fiscal_cod_lanc n  
       where a.aluno = co.ALUNO  
       and c.curso = a.curso  
       and u.UNIDADE_ENS = c.faculdade  
       and i.OUTRA_FACULDADE = u.OUTRA_FACULDADE  
       AND il.cobranca = co.cobranca   
       AND il.lanc_deb = deb.lanc_deb  
       AND deb.codigo_lanc = n.codigo_lanc  
       AND i.mantenedora = n.faculdade  
       and not exists (select 1 from LY_OPCOES_NOTA_FISCAL WHERE TIPO = 'U' AND FACULDADE = a.unidade_fisica)  
       AND co.data_de_vencimento >= @p_dtvenc_ini                      
       AND co.data_de_vencimento <= @p_dtvenc_fim  
       AND n.faculdade = @p_unidade                      
       AND ((@p_cobranca is not NULL AND co.COBRANCA = @p_cobranca) or @p_cobranca is null)              
       AND n.nota_fiscal_serie = @v_Serie               
       AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = co.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)            
       AND (@p_TipoValor <> 'Valor Pago' OR @p_TipoValor = 'Valor Pago' AND EXISTS (SELECT 1 FROM LY_LANC_CREDITO LC, LY_ITEM_CRED IC          
                           WHERE LC.LANC_CRED = IC.LANC_CRED           
                           AND IC.COBRANCA = co.COBRANCA            
                           AND il.DATA <= LC.DATA))         
       AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = co.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )                              
      
                            IF @aux_banco <> 'SQL'                  
                              BEGIN             
                       SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(*),0)                    
                       FROM (  
          SELECT DISTINCT co.COBRANCA, ALIQUOTA, co.DATA_DE_VENCIMENTO, i.mantenedora, N.CODIGO_SERVICO  
          from LY_ALUNO a, LY_UNIDADE_ENSINO u, LY_CURSO c, LY_INSTITUICAO i, LY_COBRANCA co, ly_item_lanc il, ly_lanc_debito deb, ly_nota_fiscal_cod_lanc n  
          where a.aluno = co.ALUNO  
          and c.curso = a.curso  
          and u.UNIDADE_ENS = c.faculdade  
          and i.OUTRA_FACULDADE = u.OUTRA_FACULDADE  
          AND il.cobranca = co.cobranca   
          AND il.lanc_deb = deb.lanc_deb  
          AND deb.codigo_lanc = n.codigo_lanc  
          AND i.mantenedora = n.faculdade  
          and not exists (select 1 from LY_OPCOES_NOTA_FISCAL WHERE TIPO = 'U' AND FACULDADE = a.unidade_fisica)  
          AND co.data_de_vencimento >= @p_dtvenc_ini                      
          AND co.data_de_vencimento <= @p_dtvenc_fim  
          AND n.faculdade = @p_unidade                      
          AND ((@p_cobranca is not NULL AND co.COBRANCA = @p_cobranca) or @p_cobranca is null)              
          AND n.nota_fiscal_serie = @v_Serie               
          AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = co.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)            
          AND (@p_TipoValor <> 'Valor Pago' OR @p_TipoValor = 'Valor Pago' AND EXISTS (SELECT 1 FROM LY_LANC_CREDITO LC, LY_ITEM_CRED IC          
                              WHERE LC.LANC_CRED = IC.LANC_CRED           
                              AND IC.COBRANCA = co.COBRANCA            
                              AND il.DATA <= LC.DATA))     
          AND (@p_conjrespfinan Is Null  
             OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = co.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
           )                                  
          ) t  
                              END -- IF @aux_banco <> 'SQL'                               
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento' -- TIPO DE PAGAMENTO          
       BEGIN          
        -- APAGA AS COBRANÇAS COM NUMERO_RPS IGUAL A NULL        
        DELETE FROM LY_COBRANCA_NOTA_FISCAL WHERE NUMERO_RPS IS  NULL    
          
        -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
        DECLARE C_BOLETO_9 CURSOR STATIC READ_ONLY FOR               
        SELECT distinct co.COBRANCA, ALIQUOTA, co.DATA_DE_VENCIMENTO, i.mantenedora, N.CODIGO_SERVICO  
        from LY_ALUNO a, LY_UNIDADE_ENSINO u, LY_CURSO c, LY_INSTITUICAO i, LY_COBRANCA co, ly_item_lanc il, ly_lanc_debito deb, ly_nota_fiscal_cod_lanc n  
        where a.aluno = co.ALUNO  
        and c.curso = a.curso  
        and u.UNIDADE_ENS = c.faculdade  
        and i.OUTRA_FACULDADE = u.OUTRA_FACULDADE  
        AND il.cobranca = co.cobranca   
        AND il.lanc_deb = deb.lanc_deb  
        AND deb.codigo_lanc = n.codigo_lanc  
        AND i.mantenedora = n.faculdade  
        and not exists (select 1 from LY_OPCOES_NOTA_FISCAL WHERE TIPO = 'U' AND FACULDADE = a.unidade_fisica)  
        AND n.faculdade = @p_unidade                      
        AND ((@p_cobranca is not NULL AND co.COBRANCA = @p_cobranca) or @p_cobranca is null)              
        AND n.nota_fiscal_serie = @v_Serie               
        AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = co.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)            
        AND EXISTS (select 1             
           from LY_LANC_CREDITO lc INNER JOIN LY_ITEM_CRED ic on lc.LANC_CRED = ic.LANC_CRED            
           where ic.cobranca = co.cobranca            
           AND lc.dt_credito >= @p_dtvenc_ini                        
           AND lc.dt_credito <= @p_dtvenc_fim  
           AND ic.tipodesconto is null             
           AND ic.tipo_encargo is null  
           AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
           AND lc.tipo_pagamento <> 'Arrasto'   
           AND lc.tipo_pagamento <> 'Restituicao'        
           )  
        AND (@p_conjrespfinan Is Null  
           OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = co.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
          )                     
             
                                IF @aux_banco <> 'SQL'                  
                                  BEGIN             
         SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(*),0)                    
         FROM (  
                SELECT distinct co.COBRANCA, ALIQUOTA, co.DATA_DE_VENCIMENTO, i.mantenedora, N.CODIGO_SERVICO  
             from LY_ALUNO a, LY_UNIDADE_ENSINO u, LY_CURSO c, LY_INSTITUICAO i, LY_COBRANCA co, ly_item_lanc il, ly_lanc_debito deb, ly_nota_fiscal_cod_lanc n  
             where a.aluno = co.ALUNO  
           and c.curso = a.curso  
           and u.UNIDADE_ENS = c.faculdade  
           and i.OUTRA_FACULDADE = u.OUTRA_FACULDADE  
           AND il.cobranca = co.cobranca   
           AND il.lanc_deb = deb.lanc_deb  
           AND deb.codigo_lanc = n.codigo_lanc  
           AND i.mantenedora = n.faculdade  
           and not exists (select 1 from LY_OPCOES_NOTA_FISCAL WHERE TIPO = 'U' AND FACULDADE = a.unidade_fisica)  
           AND n.faculdade = @p_unidade                      
           AND ((@p_cobranca is not NULL AND co.COBRANCA = @p_cobranca) or @p_cobranca is null)              
           AND n.nota_fiscal_serie = @v_Serie               
           AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA_NOTA_FISCAL WHERE numero_rps is not null AND COBRANCA = co.COBRANCA AND aliquota =  n.aliquota AND DT_SOLICITA_CANCEL_RPS is null)            
           AND EXISTS (select 1             
              from LY_LANC_CREDITO lc INNER JOIN LY_ITEM_CRED ic on lc.LANC_CRED = ic.LANC_CRED            
              where ic.cobranca = co.cobranca            
              AND lc.dt_credito >= @p_dtvenc_ini                        
              AND lc.dt_credito <= @p_dtvenc_fim  
              AND ic.tipodesconto is null             
              AND ic.tipo_encargo is null  
              AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
              AND lc.tipo_pagamento <> 'Arrasto'   
              AND lc.tipo_pagamento <> 'Restituicao'        
              )  
           AND (@p_conjrespfinan Is Null  
              OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = co.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
             )                  
               ) t             
                                  END -- IF @aux_banco <> 'SQL'                                    
       END          
    END   
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento' -- TIPO DE PAGAMENTO          
      BEGIN          
       -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
       DECLARE C_BOLETO_10 CURSOR STATIC READ_ONLY FOR              
       SELECT distinct bol.BOLETO, 0 as ALIQUOTA, co.DATA_DE_VENCIMENTO, i.mantenedora, 0 CODIGO_SERVICO   
       from LY_ALUNO a, LY_UNIDADE_ENSINO u, LY_CURSO c, LY_INSTITUICAO i, LY_COBRANCA co,LY_ITEM_LANC il, LY_BOLETO bol, ly_nota_fiscal_cod_lanc n  
       where il.BOLETO = bol.BOLETO  
       and co.COBRANCA = il.COBRANCA  
       and a.aluno = co.ALUNO  
       and c.curso = a.curso  
       and u.UNIDADE_ENS = c.faculdade  
       and i.OUTRA_FACULDADE = u.OUTRA_FACULDADE  
       and il.cobranca = co.cobranca  
       and il.codigo_lanc = n.codigo_lanc   
       AND i.mantenedora = n.faculdade   
       and not exists (select 1 from LY_OPCOES_NOTA_FISCAL WHERE TIPO = 'U' AND FACULDADE = a.unidade_fisica)  
       AND bol.Empresa is Null                                  
       AND (bol.numero_rps is null OR (bol.DT_SOLICITA_CANCEL_RPS is not null AND bol.DT_ENVIO_CANCEL_RPS is not null))   
       AND bol.removido = 'N'                       
       AND co.data_de_vencimento >= @p_dtvenc_ini  
       AND co.data_de_vencimento <= @p_dtvenc_fim  
       AND n.faculdade = @p_unidade                     
       AND ((@p_boleto is not NULL AND bol.BOLETO = @p_boleto) or @p_boleto is null)                         
       AND n.nota_fiscal_serie = @v_Serie  
       AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = bol.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )             
         
                 IF @aux_banco <> 'SQL'                  
                              BEGIN             
        SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(DISTINCT(bol.BOLETO)),0)                    
        from LY_ALUNO a, LY_UNIDADE_ENSINO u, LY_CURSO c, LY_INSTITUICAO i, LY_COBRANCA co,LY_ITEM_LANC il, LY_BOLETO bol, ly_nota_fiscal_cod_lanc n  
        where il.BOLETO = bol.BOLETO  
        and co.COBRANCA = il.COBRANCA  
        and a.aluno = co.ALUNO  
        and c.curso = a.curso  
        and u.UNIDADE_ENS = c.faculdade  
        and i.OUTRA_FACULDADE = u.OUTRA_FACULDADE  
        and il.cobranca = co.cobranca  
        and il.codigo_lanc = n.codigo_lanc   
        AND i.mantenedora = n.faculdade   
        and not exists (select 1 from LY_OPCOES_NOTA_FISCAL WHERE TIPO = 'U' AND FACULDADE = a.unidade_fisica)  
        AND bol.Empresa is Null                                  
        AND (bol.numero_rps is null OR (bol.DT_SOLICITA_CANCEL_RPS is not null AND bol.DT_ENVIO_CANCEL_RPS is not null))   
        AND bol.removido = 'N'                       
        AND co.data_de_vencimento >= @p_dtvenc_ini  
        AND co.data_de_vencimento <= @p_dtvenc_fim  
        AND n.faculdade = @p_unidade                     
        AND ((@p_boleto is not NULL AND bol.BOLETO = @p_boleto) or @p_boleto is null)                         
        AND n.nota_fiscal_serie = @v_Serie   
        AND (@p_conjrespfinan Is Null  
         OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = bol.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )          
         END -- IF @aux_banco <> 'SQL'                    
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento' -- TIPO DE PAGAMENTO          
       BEGIN          
        -- Cria cursor C_COBRANCA DINAMICAMENTE  a partir dos parâmetros                    
        DECLARE C_BOLETO_11 CURSOR STATIC READ_ONLY FOR               
        SELECT distinct bol.BOLETO, 0 as ALIQUOTA, co.DATA_DE_VENCIMENTO, i.mantenedora, 0 CODIGO_SERVICO   
        from LY_ALUNO a, LY_UNIDADE_ENSINO u, LY_CURSO c, LY_INSTITUICAO i, LY_COBRANCA co,LY_ITEM_LANC il, LY_BOLETO bol,  
        ly_nota_fiscal_cod_lanc n, ly_lanc_debito deb   
        where il.BOLETO = bol.BOLETO  
        and co.COBRANCA = il.COBRANCA  
        and a.aluno = co.ALUNO  
        and c.curso = a.curso  
        and u.UNIDADE_ENS = c.faculdade  
        and i.OUTRA_FACULDADE = u.OUTRA_FACULDADE  
        and il.cobranca = co.cobranca  
        and il.codigo_lanc = n.codigo_lanc   
        AND i.mantenedora = n.faculdade   
        and il.lanc_deb = deb.lanc_deb  
        AND deb.codigo_lanc = n.codigo_lanc  
        and not exists (select 1 from LY_OPCOES_NOTA_FISCAL WHERE TIPO = 'U' AND FACULDADE = a.unidade_fisica)  
        AND bol.Empresa is Null                                  
        AND (bol.numero_rps is null OR (bol.DT_SOLICITA_CANCEL_RPS is not null AND bol.DT_ENVIO_CANCEL_RPS is not null))   
        AND bol.removido = 'N'                       
        AND EXISTS(SELECT 1  
             FROM ly_lanc_credito lc    
             WHERE EXISTS (SELECT 1  
               FROM LY_ITEM_CRED IC  
               WHERE LC.LANC_CRED = IC.LANC_CRED  
                  AND co.COBRANCA  = IC.COBRANCA  
               GROUP BY IC.LANC_CRED  
               HAVING SUM(VALOR) <> 0  
              )                                 
             AND lc.dt_credito >= @p_dtvenc_ini                 
             AND lc.dt_credito <= @p_dtvenc_fim  
             AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
             AND lc.tipo_pagamento <> 'Arrasto'   
             AND lc.tipo_pagamento <> 'Restituicao'   
             )                                                
        AND n.faculdade = @p_unidade                     
        AND ((@p_boleto is not NULL AND bol.BOLETO = @p_boleto) or @p_boleto is null)                         
        AND n.nota_fiscal_serie = @v_Serie    
        AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = bol.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
         )           
  
                                IF @aux_banco <> 'SQL'                  
                                  BEGIN                       
         SELECT @v_C_BOLETO_ROWS = ISNULL(COUNT(DISTINCT(bol.BOLETO)),0)                    
         from LY_ALUNO a, LY_UNIDADE_ENSINO u, LY_CURSO c, LY_INSTITUICAO i, LY_COBRANCA co,LY_ITEM_LANC il, LY_BOLETO bol,  
         ly_nota_fiscal_cod_lanc n, ly_lanc_debito deb   
         where il.BOLETO = bol.BOLETO  
         and co.COBRANCA = il.COBRANCA  
         and a.aluno = co.ALUNO  
         and c.curso = a.curso  
         and u.UNIDADE_ENS = c.faculdade  
         and i.OUTRA_FACULDADE = u.OUTRA_FACULDADE  
         and il.cobranca = co.cobranca  
         and il.codigo_lanc = n.codigo_lanc   
         AND i.mantenedora = n.faculdade   
         and il.lanc_deb = deb.lanc_deb  
         AND deb.codigo_lanc = n.codigo_lanc  
         and not exists (select 1 from LY_OPCOES_NOTA_FISCAL WHERE TIPO = 'U' AND FACULDADE = a.unidade_fisica)  
         AND bol.Empresa is Null                                  
         AND (bol.numero_rps is null OR (bol.DT_SOLICITA_CANCEL_RPS is not null AND bol.DT_ENVIO_CANCEL_RPS is not null))   
         AND bol.removido = 'N'                       
         AND EXISTS(SELECT 1  
              FROM ly_lanc_credito lc    
              WHERE EXISTS (SELECT 1  
                FROM LY_ITEM_CRED IC  
                WHERE LC.LANC_CRED = IC.LANC_CRED  
                   AND co.COBRANCA  = IC.COBRANCA  
                GROUP BY IC.LANC_CRED  
                HAVING SUM(VALOR) <> 0  
               )                                 
              AND lc.dt_credito >= @p_dtvenc_ini                 
              AND lc.dt_credito <= @p_dtvenc_fim  
              AND lc.tipo_pagamento <> 'Arrasto-Boleto'   
              AND lc.tipo_pagamento <> 'Arrasto'   
              AND lc.tipo_pagamento <> 'Restituicao'   
            )                                                
         AND n.faculdade = @p_unidade                     
         AND ((@p_boleto is not NULL AND bol.BOLETO = @p_boleto) or @p_boleto is null)                         
         AND n.nota_fiscal_serie = @v_Serie  
         AND (@p_conjrespfinan Is Null  
          OR (@p_conjrespfinan Is Not Null AND EXISTS (SELECT 1 FROM LY_CONJ_RESP_FINAN WHERE LY_CONJ_RESP_FINAN.RESP = bol.RESP AND LY_CONJ_RESP_FINAN.CONJ_RESP_FINAN = @p_conjrespfinan))  
          )           
                                  END -- IF @aux_banco <> 'SQL'                             
       END          
    END   
  END    
   
 -- Quando o Tipo = Empresa  
    IF @p_Tipo = 'E'            
  BEGIN           
   IF @v_cob <> 'N'         
    BEGIN        
     OPEN C_BOLETO_1                    
     FETCH NEXT FROM C_BOLETO_1 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
    END          
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento'         
      BEGIN         
       OPEN C_BOLETO_2                    
       FETCH NEXT FROM C_BOLETO_2 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico          
      END            
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'         
       BEGIN        
        OPEN C_BOLETO_3                    
        FETCH NEXT FROM C_BOLETO_3 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
       END          
    END               
  END            
   
 -- Quando o Tipo = Unidade  
 IF @p_Tipo = 'U'          
  BEGIN         
   IF @v_cob <> 'N'         
    BEGIN        
     IF @p_Tipo_Data = 'Data de Vencimento'         
      BEGIN         
       OPEN C_BOLETO_4                    
       FETCH NEXT FROM C_BOLETO_4 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'         
       BEGIN        
        OPEN C_BOLETO_5               
        FETCH NEXT FROM C_BOLETO_5 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico          
       END          
    END   
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento'           
      BEGIN                    
       OPEN C_BOLETO_6               
       FETCH NEXT FROM C_BOLETO_6 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico           
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'          
       BEGIN        
        OPEN C_BOLETO_7               
        FETCH NEXT FROM C_BOLETO_7 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
       END          
    END         
  END                        
   
 -- Quando o Tipo = Mantenedora  
 IF @p_Tipo = 'M'  
  BEGIN         
   IF @v_cob <> 'N'         
    BEGIN        
     IF @p_Tipo_Data = 'Data de Vencimento'         
      BEGIN         
       OPEN C_BOLETO_8                   
       FETCH NEXT FROM C_BOLETO_8 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'         
       BEGIN        
        OPEN C_BOLETO_9               
        FETCH NEXT FROM C_BOLETO_9 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico          
       END          
    END --IF @v_Cob <> 'N'        
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento'           
      BEGIN                    
       OPEN C_BOLETO_10               
       FETCH NEXT FROM C_BOLETO_10 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico           
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'          
       BEGIN        
        OPEN C_BOLETO_11               
        FETCH NEXT FROM C_BOLETO_11 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
       END          
    END         
  END  
    
    SET @v_contador = 0                    
  
    -- Contador Cursor SQL Server  
    IF @aux_banco = 'SQL'    
      SELECT @v_C_BOLETO_ROWS = @@CURSOR_ROWS      
                    
    WHILE @@FETCH_STATUS = 0                    
  BEGIN                    
   IF @p_sit_boletos = 1 -- Pagos          
    BEGIN          
     SET @v_gera = 'N'          
                                                       
     IF @v_Cob <> 'N'        
      BEGIN        
       SELECT @v_valor_item_lanc = isnull(sum(i.valor),0)           
       FROM ly_item_lanc i           
       WHERE cobranca = @v_boleto        
                         
       SELECT @v_valor_item_cred = isnull(sum(i.valor),0)           
       FROM ly_item_cred i           
       WHERE cobranca = @v_boleto         
      END    
     ELSE        
      BEGIN        
       SELECT @v_valor_item_lanc = isnull(sum(i.valor),0)           
       FROM ly_item_lanc i           
       WHERE exists (SELECT 1 FROM ly_item_lanc b WHERE b.cobranca = i.cobranca AND b.boleto = @v_boleto)          
                   
       SELECT @v_valor_item_cred = isnull(sum(i.valor),0)           
       FROM ly_item_cred i           
       WHERE exists (SELECT 1 FROM ly_item_lanc b WHERE b.cobranca = i.cobranca AND b.boleto = @v_boleto)          
      END   
          
     SET @v_valor_a_pagar_boleto = @v_valor_item_lanc + @v_valor_item_cred          
         
     IF @v_valor_a_pagar_boleto = 0 SET @v_gera = 'S'          
           
     IF @v_valor_item_cred <> 0 AND @v_valor_a_pagar_boleto < 0           
      SET @v_gera = 'S'          
     ELSE          
      BEGIN       
       IF @v_valor_a_pagar_boleto > 0  
       BEGIN  
        IF @v_gera_pgto_parcial = 'S'  
         -- INICIO: tratamento para pgto parcial  
         BEGIN  
          IF @v_Cob <> 'N'        
          BEGIN  
           SET @v_cob_boleto = @v_boleto  
          END  
          ELSE  
          BEGIN  
           SELECT @v_cob_boleto = i.COBRANCA                  
           FROM ly_boleto b inner join ly_item_lanc i ON b.Boleto = i.Boleto  
           WHERE b.Boleto = @v_boleto   
          END  
            
          EXEC PROC_RPS_PGTO_PARCIAL @v_cob_boleto  
            
          EXEC GetErrorsCount @v_ErrorsCount output            
          IF @v_ErrorsCount > 0            
          BEGIN            
            EXEC GetErros @v_Erro OUTPUT    
            SET @v_Erro = 'PROC_RPS_PGTO_PARCIAL: ' + @v_Erro           
            EXEC SetErro @v_Erro            
            EXECUTE spProcLog @v_boleto, null, null, null, null, null, null, null, null, null      
          END        
          ELSE SET @v_gera = 'S'    
         END  
         -- FIM: tratamento para pgto parcial  
           
        ELSE -- @v_gera_pgto_parcial = 'N'          
         BEGIN          
          SELECT @v_erro = 'Não pode gerar RPS para cobrança/boleto com valor em aberto.'          
          EXECUTE SetErro @v_erro , 'Boleto'          
          EXECUTE spProcLog @v_boleto, null, null, null, null, null, null, null, null, null          
         END  
       END          
         
       IF @v_valor_a_pagar_boleto < 0          
        BEGIN          
         SELECT @v_erro = 'Não pode gerar RPS para cobrança/boleto com valor negativo.'          
         EXECUTE SetErro @v_erro , 'Boleto'          
         EXECUTE spProcLog @v_boleto, null, null, null, null, null, null, null, null, null               
        END          
      END          
    END          
          
        IF @p_sit_boletos = 2 -- Vencidos ou Pagos          
   BEGIN          
    SET @v_gera = 'N'          
          
    IF @v_data_de_vencimento > getdate()          
     BEGIN          
      IF @v_Cob <> 'N'        
       BEGIN        
        SELECT @v_valor_item_lanc = isnull(sum(i.valor),0)        
        FROM ly_item_lanc i           
        WHERE cobranca = @v_boleto        
        
        SELECT @v_valor_item_cred = isnull(sum(i.valor),0)           
        FROM ly_item_cred i           
        WHERE cobranca = @v_boleto         
       END        
      ELSE        
       BEGIN        
        SELECT @v_valor_item_lanc = isnull(sum(i.valor),0)           
        FROM ly_item_lanc i           
        WHERE exists (SELECT 1 FROM ly_item_lanc b WHERE b.cobranca = i.cobranca AND b.boleto = @v_boleto)          
          
        SELECT @v_valor_item_cred = isnull(sum(i.valor),0)           
        FROM ly_item_cred i           
        WHERE exists (SELECT 1 FROM ly_item_lanc b WHERE b.cobranca = i.cobranca AND b.boleto = @v_boleto)          
       END         
        
      SET @v_valor_a_pagar_boleto = @v_valor_item_lanc + @v_valor_item_cred            
          
      IF @v_valor_a_pagar_boleto = 0 SET @v_gera = 'S'          
                          
      IF @v_valor_a_pagar_boleto > 0   
      BEGIN  
       IF @v_gera_pgto_parcial = 'S'  
        -- INICIO: tratamento para pgto parcial  
        BEGIN  
         IF @v_Cob <> 'N'        
         BEGIN  
          SET @v_cob_boleto = @v_boleto  
         END  
         ELSE  
         BEGIN  
          SELECT @v_cob_boleto = i.COBRANCA                  
          FROM ly_boleto b inner join ly_item_lanc i ON b.Boleto = i.Boleto  
          WHERE b.Boleto = @v_boleto   
         END  
           
         EXEC PROC_RPS_PGTO_PARCIAL @v_cob_boleto  
           
         EXEC GetErrorsCount @v_ErrorsCount output            
         IF @v_ErrorsCount > 0            
         BEGIN            
           EXEC GetErros @v_Erro OUTPUT    
           SET @v_Erro = 'PROC_RPS_PGTO_PARCIAL: ' + @v_Erro           
           EXEC SetErro @v_Erro            
           EXECUTE spProcLog @v_boleto, null, null, null, null, null, null, null, null, null      
         END        
         ELSE   
          SET @v_gera = 'S'    
        END  
        -- FIM: tratamento para pgto parcial  
          
       ELSE -- @v_gera_pgto_parcial = 'N'  
        BEGIN           
         SELECT @v_erro = 'Não pode gerar RPS para cobrança/boleto com valor em aberto.'          
         EXECUTE SetErro @v_erro , 'Boleto'          
         EXECUTE spProcLog @v_boleto, null, null, null, null, null, null, null, null, null      
        END           
      END  
              
      IF @v_valor_a_pagar_boleto < 0          
       BEGIN          
        SELECT @v_erro = 'Não pode gerar RPS para cobrança/boleto com valor negativo.'          
        EXECUTE SetErro @v_erro , 'Boleto'          
        EXECUTE spProcLog @v_boleto, null, null, null, null, null, null, null, null, null               
       END          
     END          
    ELSE          
     BEGIN          
      SET @v_gera = 'S'          
     END          
   END                            
                  
        IF @p_sit_boletos = 3 SET @v_gera = 'S' -- Todos          
          
        SELECT @v_contador = @v_contador + 1                    
        SELECT @v_percentual = @v_contador                    
        SELECT @v_percentual = @v_percentual / @v_C_BOLETO_ROWS                    
                    
        IF @V_GERA = 'S'                    
   BEGIN                    
    IF @p_op_emissao = 1 SET @v_dt_emissao = @v_data_de_vencimento                    
          
    IF @p_op_emissao = 2           
     BEGIN          
      IF @v_Cob <> 'N'        
       BEGIN        
        SELECT @v_dt_credito = LC.DT_CREDITO          
        FROM  LY_ITEM_CRED IC, LY_LANC_CREDITO LC          
        WHERE IC.LANC_CRED = LC.LANC_CRED          
        AND IC.COBRANCA  = @v_boleto         
        AND IC.TIPODESCONTO is null            
        AND ic.TIPO_ENCARGO is null       
        ORDER BY LC.DT_CREDITO         
       END       
      ELSE        
       BEGIN        
        SELECT @v_dt_credito = LC.DT_CREDITO          
        FROM LY_ITEM_LANC I, LY_ITEM_CRED IC, LY_LANC_CREDITO LC          
        WHERE I.COBRANCA = IC.COBRANCA AND IC.LANC_CRED = LC.LANC_CRED          
        AND I.BOLETO  = @v_boleto          
        ORDER BY LC.DT_CREDITO          
       END         
        
      SET @v_dt_emissao = @v_dt_credito          
     END          
          
    IF @p_op_emissao = 3 SET @v_dt_emissao = @p_dtemissao                   
          
    IF @v_dt_emissao is not null                      
     BEGIN  
      -- Chamada ao entry-point que irá decidir se uma cobrança/boleto deverá ter o RPS gerado ou não  
      EXECUTE a_VALIDA_RPS  @v_boleto, @v_dt_emissao, @v_unidade, @p_Tipo, @v_Serie, @p_TipoValor, @v_Cob, @v_ALIQUOTA, @v_codigo_servico, @v_gera_rps OUTPUT  
      IF @v_gera_rps = 'S'  
        BEGIN              
        EXECUTE GERA_RPS @v_boleto, @v_dt_emissao, @v_unidade, @p_Tipo, @v_Serie, @p_TipoValor, @v_Cob, @v_ALIQUOTA, @v_codigo_servico                             
       END  
     END             
                    
    SET @v_straux1 = convert(varchar(10),@v_contador)                    
    SET @v_straux2 = convert(varchar (10),@v_C_BOLETO_ROWS)                    
    SET @v_straux3 = convert(varchar(10),@v_boleto)                    
    SELECT @v_Msg_Refresh = substring('Processando ' + @v_straux1 + '/' + @v_straux2 + '   Cobrança/Boleto : ' + @v_straux3 ,1,255)                    
    EXECUTE spProcRefresh @v_percentual, @v_Msg_Refresh                
    EXECUTE GET_CONNECT_ID @v_sessao_id output                    
    SELECT @v_count = 0                     
                SELECT @v_count = isnull(COUNT(*),0)  FROM ZZCRO_ERROS WHERE SPID = @v_sessao_id                    
    -- SEM Erros                    
    IF @v_dt_emissao is null            
     BEGIN          
      SELECT @v_erro = 'Data de emissão não informada'              
      EXECUTE SetErro @v_erro , 'Data de emissão'                    
      EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null           
     END          
    ELSE          
     BEGIN          
      IF @v_count = 0 EXECUTE spProcLog @v_boleto, null, null, null, null, null, null, null, null, null, ' [Sucesso]'                        
      ELSE EXECUTE spProcLog @v_boleto, null, null, null, null, null, null, null, null, null            
     END                    
   END                   
                    
        IF @p_Tipo = 'E'            
   BEGIN          
    IF @v_cob <> 'N'         
     BEGIN        
      FETCH NEXT FROM C_BOLETO_1 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
     END          
    ELSE        
     BEGIN           
      IF @p_Tipo_Data = 'Data de Vencimento'         
       BEGIN         
        FETCH NEXT FROM C_BOLETO_2 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico          
       END            
      ELSE          
       IF @p_Tipo_Data = 'Data de Pagamento'         
        BEGIN        
         FETCH NEXT FROM C_BOLETO_3 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
        END          
     END               
   END            
     
  IF @p_Tipo = 'U'            
   BEGIN         
    IF @v_cob <> 'N'         
     BEGIN        
      IF @p_Tipo_Data = 'Data de Vencimento'         
       BEGIN         
        FETCH NEXT FROM C_BOLETO_4 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
       END          
      ELSE          
       IF @p_Tipo_Data = 'Data de Pagamento'         
        BEGIN        
         FETCH NEXT FROM C_BOLETO_5 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico          
        END          
     END        
    ELSE        
     BEGIN           
      IF @p_Tipo_Data = 'Data de Vencimento'         
       BEGIN        
        FETCH NEXT FROM C_BOLETO_6 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico           
       END          
      ELSE          
       IF @p_Tipo_Data = 'Data de Pagamento'          
        BEGIN        
         FETCH NEXT FROM C_BOLETO_7 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
        END          
     END         
   END                
    
  IF @p_Tipo = 'M'            
   BEGIN         
    IF @v_cob <> 'N'         
     BEGIN        
      IF @p_Tipo_Data = 'Data de Vencimento'         
       BEGIN         
        FETCH NEXT FROM C_BOLETO_8 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
       END          
      ELSE          
       IF @p_Tipo_Data = 'Data de Pagamento'         
        BEGIN        
         FETCH NEXT FROM C_BOLETO_9 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico          
        END          
     END        
    ELSE        
     BEGIN           
      IF @p_Tipo_Data = 'Data de Vencimento'         
       BEGIN        
        FETCH NEXT FROM C_BOLETO_10 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico           
       END          
      ELSE          
       IF @p_Tipo_Data = 'Data de Pagamento'          
        BEGIN        
         FETCH NEXT FROM C_BOLETO_11 INTO  @v_boleto, @v_ALIQUOTA, @v_data_de_vencimento, @v_unidade, @v_codigo_servico        
        END          
     END         
   END   
    
    END -- WHILE @@FETCH_STATUS = 0                    
                    
    IF @p_Tipo = 'E'            
  BEGIN         
   IF @v_cob <> 'N'         
    BEGIN        
     CLOSE C_BOLETO_1                
     DEALLOCATE C_BOLETO_1        
    END          
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento'         
      BEGIN         
       CLOSE C_BOLETO_2        
       DEALLOCATE C_BOLETO_2        
      END            
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'         
       BEGIN        
        CLOSE C_BOLETO_3        
        DEALLOCATE C_BOLETO_3        
       END          
    END           
  END            
    
 IF @p_Tipo = 'U'            
  BEGIN         
   IF @v_cob <> 'N'         
    BEGIN        
     IF @p_Tipo_Data = 'Data de Vencimento'         
      BEGIN         
       CLOSE C_BOLETO_4        
       DEALLOCATE C_BOLETO_4        
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'         
       BEGIN        
        CLOSE C_BOLETO_5        
        DEALLOCATE C_BOLETO_5        
       END          
    END         
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento'         
      BEGIN        
       CLOSE C_BOLETO_6        
       DEALLOCATE C_BOLETO_6         
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'         
       BEGIN        
        CLOSE C_BOLETO_7        
        DEALLOCATE C_BOLETO_7        
       END          
    END         
  END            
                    
 IF @p_Tipo = 'M'  
  BEGIN         
   IF @v_cob <> 'N'         
    BEGIN        
     IF @p_Tipo_Data = 'Data de Vencimento'         
      BEGIN         
       CLOSE C_BOLETO_8        
       DEALLOCATE C_BOLETO_8        
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'         
       BEGIN        
        CLOSE C_BOLETO_9        
        DEALLOCATE C_BOLETO_9        
       END          
    END         
   ELSE        
    BEGIN           
     IF @p_Tipo_Data = 'Data de Vencimento'         
      BEGIN        
       CLOSE C_BOLETO_10        
       DEALLOCATE C_BOLETO_10         
      END          
     ELSE          
      IF @p_Tipo_Data = 'Data de Pagamento'         
       BEGIN        
        CLOSE C_BOLETO_11        
        DEALLOCATE C_BOLETO_11        
       END          
    END         
  END  
    
    IF @v_Contador = 0 SET @v_erro = 'Nenhuma recibo foi gerado.' ELSE SET @v_erro = 'Procedure executada com sucesso.'                    
                    
    FIM_PROC:                    
    EXECUTE spProcFinaliza @v_erro                    
    RETURN                    
END                    
-- [FIM]                    