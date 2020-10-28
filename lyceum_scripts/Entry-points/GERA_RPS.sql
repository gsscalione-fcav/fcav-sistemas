    
ALTER PROCEDURE GERA_RPS              
 @p_boleto          T_NUMERO,              
 @p_dt_emissao      T_DATA,            
 @p_faculdade       T_CODIGO,             
 @p_Qualtipo        VARCHAR(1), -- Só pode ser E (Empresa) ou U (Unidade)      
 @p_Serie           VARCHAR(5),      
 @p_TipoValor       VARCHAR(50),    
 @p_Cob    T_SIMNAO,    
 @p_Aliquota   NUMERIC(5, 2),    
 @p_Codigo_Servico T_NUMERO        
AS              
 DECLARE @v_resp                 T_CODIGO                
 DECLARE @v_NumeroRPS            NUMERIC(12,0)                
 DECLARE @v_ValorServicoRPS      T_DECIMAL_MEDIO                    
 DECLARE @v_ValorDeducaoRPS      T_DECIMAL_MEDIO              
 DECLARE @v_dt_venc              T_DATA              
 DECLARE @v_Erros_ID             T_NUMERO                
 DECLARE @v_Erro                 VARCHAR(1000)                
 DECLARE @v_straux1              VARCHAR(100)          
 DECLARE @V_CONT                 INT         
 DECLARE @v_Aliquota_DeducaoRPS T_DECIMAL_MEDIO              
 DECLARE @v_ValorDeducaoLanc     T_DECIMAL_MEDIO     
 DECLARE @v_ValorTotalCob        T_DECIMAL_MEDIO                       
 DECLARE @v_ValorCob             T_DECIMAL_MEDIO    
 DECLARE @v_ValorCobBase         T_DECIMAL_MEDIO      
 DECLARE @v_NotaFiscalSerie      VARCHAR(5)    
 DECLARE @v_Situacao             VARCHAR(1)    
 DECLARE @v_NaturezaOperacao     VARCHAR(2)    
 DECLARE @v_RegimeEspTrib        VARCHAR(2)    
 DECLARE @v_SimplesNacional      VARCHAR(2)    
 DECLARE @v_IncentCultural       VARCHAR(2)    
 DECLARE @v_Status               VARCHAR(2)    
 DECLARE @v_DescontoIncond       VARCHAR(1)    
 DECLARE @v_ValorDescontoRPS     T_DECIMAL_MEDIO    
 DECLARE @v_Mantenedora   T_CODIGO    
 DECLARE @v_Valor_Pis   T_DECIMAL_MEDIO    
 DECLARE @v_Valor_Cofins      T_DECIMAL_MEDIO    
 DECLARE @v_Valor_Ir       T_DECIMAL_MEDIO    
 DECLARE @v_Valor_Csll   T_DECIMAL_MEDIO    
 DECLARE @v_Valor_Inss   T_DECIMAL_MEDIO     
 DECLARE @v_Dt_Solicita_Cancel_Rps T_DATA    
 DECLARE @v_Dt_Envio_Cancel_Rps  T_DATA     
 DECLARE @v_Motivo_Cancel_Rps  T_ALFALARGE     
 DECLARE @v_substitui    varchar(1)     
 
 DECLARE @v_CodigoCnae                     VARCHAR(20)    
 DECLARE @v_CodigoTributacaoMunicipio      VARCHAR(20)
 DECLARE @v_DiscriminacaoServico		   VARCHAR(200)
 DECLARE @v_ExigibilidadeISS               VARCHAR(20)
 DECLARE @v_TipoTributacao                 VARCHAR(20)
 DECLARE @v_CodigoItemListaServico         VARCHAR(20) 
    
 -- ---------------------------------------------------------------------------            
 --    Validação de parâmetros OBRIGATÓRIOS            
 -- ---------------------------------------------------------------------------            
 IF @p_boleto is null            
  BEGIN     
   IF @p_Cob <> 'N'    
    BEGIN    
     SELECT @v_erro = 'Cobrança não informada'            
     EXECUTE seterro @v_erro, 'Cobranca'            
    END    
   ELSE            
    BEGIN    
     SELECT @v_erro = 'Boleto não informado'            
     EXECUTE seterro @v_erro, 'Boleto'            
    END    
   EXECUTE spProcLog null, null, null, null, null, null, null, null, null, null            
   RETURN            
  END            
      
 IF @p_faculdade is null       
  BEGIN            
   SELECT @v_erro = 'Código da Unidade/Empresa não informado'            
   EXECUTE seterro @v_erro, 'Faculdade'            
   EXECUTE spProcLog @p_boleto, null, null, null, null, null, null, null, null, null            
   RETURN            
  END      
      
 IF @p_Qualtipo is null       
  BEGIN            
   SELECT @v_erro = 'Tipo não informado'            
   EXECUTE seterro @v_erro, 'Tipo'            
   EXECUTE spProcLog @p_boleto, null, null, null, null, null, null, null, null, null            
   RETURN            
  END      
    
 IF @p_Serie is null       
  BEGIN            
   SELECT @v_erro = 'Série não informada'            
   EXECUTE seterro @v_erro, 'Série'            
   EXECUTE spProcLog @p_boleto, null, null, null, null, null, null, null, null, null            
   RETURN            
  END      
    
 IF @p_TipoValor is null       
  BEGIN            
   SELECT @v_erro = 'Tipo Valor não informado'            
   EXECUTE seterro @v_erro, 'Tipo Valor'            
   EXECUTE spProcLog @p_boleto, null, null, null, null, null, null, null, null, null            
   RETURN            
  END      
        
 IF @p_dt_emissao is null            
  BEGIN            
   SELECT @v_erro = 'Data de Emissão não informada'            
   EXECUTE seterro @v_erro, 'Data de Emissão'            
   EXECUTE spProcLog @p_boleto, null, null, null, null, null, null, null, null, null            
   RETURN            
  END            
        
 --Verifica se a cobrança do boleto foi pré-acordada      
 SELECT @V_CONT = 0    
 IF @p_Cob <> 'N'    
  SELECT @V_CONT = ISNULL(COUNT(*),0)      
  FROM LY_COBRANCA C    
  WHERE C.COBRANCA = @p_boleto      
  AND EXISTS (SELECT 1 FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO       
     WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO       
     AND COBRANCA = C.COBRANCA       
     AND LY_PRE_ACORDO.CANCELADO = 'N')      
 ELSE      
  SELECT @V_CONT = ISNULL(COUNT(*),0)      
  FROM LY_COBRANCA C, LY_ITEM_LANC I      
  WHERE C.COBRANCA = I.COBRANCA      
  AND I.BOLETO = @p_boleto      
  AND EXISTS (SELECT 1 FROM LY_PRE_ACORDO_ITEM, LY_PRE_ACORDO       
     WHERE LY_PRE_ACORDO_ITEM.PRE_ACORDO = LY_PRE_ACORDO.PRE_ACORDO       
     AND COBRANCA = C.COBRANCA       
     AND LY_PRE_ACORDO.CANCELADO = 'N')      
       
 IF @V_CONT > 0      
  BEGIN      
   SET @v_straux1 = convert(varchar(50),@p_boleto)                
   SELECT @v_Erro = 'O boleto ' + @v_straux1 + ' possui cobrança pré-acordada!'                
   EXECUTE SetErro @v_Erro, 'BOLETO'              
   RETURN              
  END      
      
 ---------------------------------------------------------------------------            
 ---------------------------------------------------------------------------            
 IF @p_Cob <> 'N'    
  SELECT @v_resp = RESP FROM LY_COBRANCA WHERE COBRANCA = @p_boleto              
 ELSE     
  SELECT @v_resp = RESP FROM LY_BOLETO WHERE BOLETO = @p_boleto       
     
 EXECUTE GET_ERROR_ID @v_Erros_ID                
     
 IF @v_Erros_ID <> 0                
  BEGIN                
   SET @v_straux1 = convert(varchar(50),@v_resp)                
   SELECT @v_Erro = 'Erro ao obter o responsável para gerar o RPS.' + @v_straux1                 
   EXECUTE SetErro @v_Erro, 'RESP'              
   RETURN              
  END      
      
 IF @v_resp is null              
  BEGIN              
   SET @v_straux1 = convert(varchar(50),@p_boleto)                
   SELECT @v_Erro = 'Não foi localizado a cobrança/boleto com este número.' + @v_straux1                 
   EXECUTE SetErro @v_Erro, 'BOLETO'              
   RETURN              
  END              
        
 SELECT @v_NumeroRPS = nota_fiscal, @v_Situacao = SITUACAO    
 FROM LY_OPCOES_NOTA_FISCAL       
 WHERE FACULDADE = @p_faculdade and TIPO = @p_Qualtipo      
 and nota_fiscal_serie = @p_Serie      
              
 EXECUTE GET_ERROR_ID @v_Erros_ID                
     
 IF @v_Erros_ID <> 0                
  BEGIN                
   SET @v_straux1 = convert(varchar(50),@v_resp)                
   SELECT @v_Erro = 'Erro ao obter os dados de RPS para o responsável ' + @v_straux1                 
   EXECUTE SetErro @v_Erro, 'RESP'                
   RETURN                
  END                    
      
 IF @v_NumeroRPS is null                
  BEGIN              
   SET @v_straux1 = convert(varchar(50),@p_faculdade)                
   SELECT @v_Erro = 'Não existem opções.' + @v_straux1                 
   EXECUTE SetErro @v_Erro, 'FACULDADE'              
   RETURN                  
  END     
      
 -- ------------------------------------------------------------------------------------------                      
 --  Chamada do Entry-Point S_GERA_RPS para substituir o calculo realizado pela procedure    
 -- ------------------------------------------------------------------------------------------       
 EXEC S_GERA_RPS @p_boleto = @p_boleto    
 , @p_dt_emissao = @p_dt_emissao    
 , @p_faculdade = @p_faculdade    
 , @p_Qualtipo = @p_Qualtipo    
 , @p_Serie = @p_Serie    
 , @p_TipoValor = @p_TipoValor    
 , @p_Cob = @p_Cob    
 , @p_Aliquota = @p_Aliquota    
 , @p_Codigo_Servico = @p_Codigo_Servico    
 , @p_substitui = @v_substitui output    
    
 IF @v_substitui = 'S'    
 RETURN    
 -- ------------------------------------------------------------------------------------------             
      
 Select @v_ValorTotalCob = 0    
 Select @v_ValorCob = 0    
     
 SET @v_Dt_Solicita_Cancel_Rps = NULL    
 SET @v_Dt_Envio_Cancel_Rps = NULL     
 SET @v_Motivo_Cancel_Rps = NULL     
      
 IF @p_Cob <> 'N'    
  BEGIN      
    SELECT @v_ValorTotalCob = SUM(il.VALOR)     
    FROM  LY_COBRANCA co, ly_item_lanc il, ly_lanc_debito deb, ly_nota_fiscal_cod_lanc n    
    WHERE il.cobranca = co.cobranca     
       AND il.lanc_deb = deb.lanc_deb    
       AND deb.codigo_lanc = n.codigo_lanc    
       AND n.faculdade = @p_faculdade                        
       AND co.COBRANCA = @p_Boleto    
    
          SELECT @v_ValorCobBase =  SUM(il.VALOR)     
    FROM  LY_COBRANCA co, ly_item_lanc il, ly_lanc_debito deb, ly_nota_fiscal_cod_lanc n    
    WHERE il.cobranca = co.cobranca     
       AND il.lanc_deb = deb.lanc_deb    
       AND deb.codigo_lanc = n.codigo_lanc    
       AND n.faculdade = @p_faculdade                        
       AND co.COBRANCA = @p_Boleto    
       AND n.CODIGO_SERVICO = @p_Codigo_Servico    
        
              
    SELECT @v_ValorCob =  SUM(il.VALOR)    
    FROM  LY_COBRANCA co, ly_item_lanc il, ly_lanc_debito deb, ly_nota_fiscal_cod_lanc n    
    WHERE il.cobranca = co.cobranca     
       AND il.lanc_deb = deb.lanc_deb    
       AND deb.codigo_lanc = n.codigo_lanc    
       AND n.faculdade = @p_faculdade                        
       AND co.COBRANCA = @p_Boleto    
       AND n.aliquota = @p_Aliquota      
       and n.CODIGO_SERVICO = @p_Codigo_Servico           
    
  END    
    
 if @p_TipoValor = 'Valor Lançado Líquido'      
  BEGIN      
   IF @p_Cob <> 'N'    
    Select @v_ValorDeducaoRPS = sum(n.aliquota_deducao * valor / 100)           
    From ly_item_lanc i, ly_nota_fiscal_cod_lanc n          
    Where i.codigo_lanc = n.codigo_lanc          
    and n.faculdade = rTrim(ltrim(@p_faculdade))       
    and n.tipo = rTrim(ltrim(@p_Qualtipo))          
    and n.nota_fiscal_serie = rtrim(ltrim(@p_Serie))      
    and i.cobranca = @p_Boleto    
    and n.aliquota = @p_Aliquota     
    and CODIGO_SERVICO = @p_Codigo_Servico    
   ELSE     
    Select @v_ValorDeducaoRPS = sum(n.aliquota_deducao * valor / 100)           
    From ly_item_lanc i, ly_nota_fiscal_cod_lanc n          
    Where i.codigo_lanc = n.codigo_lanc          
    and n.faculdade = rTrim(ltrim(@p_faculdade))       
    and n.tipo = rTrim(ltrim(@p_Qualtipo))          
    and n.nota_fiscal_serie = rtrim(ltrim(@p_Serie))      
    and exists (select 1 from ly_item_lanc b where b.cobranca = i.cobranca and b.boleto = @p_Boleto)          
  END      
        
 if @p_TipoValor = 'Valor Lançado Bruto'      
  BEGIN      
   IF @p_Cob <> 'N'    
    SELECT @v_ValorDeducaoRPS = sum(n.aliquota_deducao * valor / 100)           
    FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N                
    WHERE I.CODIGO_LANC = N.CODIGO_LANC              
    AND I.COBRANCA = @p_boleto              
    AND N.FACULDADE = rTrim(lTrim(@p_faculdade))       
    AND N.TIPO = rTrim(lTrim(@p_Qualtipo))          
    AND N.NOTA_FISCAL_SERIE = rtrim(ltrim(@p_Serie))         
    AND I.NUM_BOLSA IS NULL       
    AND I.DEVOLUCAO IS NULL       
    AND I.ACORDO IS NULL       
    AND I.NUM_FINANCIAMENTO IS NULL       
    AND I.CODIGO_LANC <> 'Acerto'      
    AND I.COBRANCA_ORIG IS NULL      
    AND I.ITEMCOBRANCA_ORIG IS NULL    
    AND N.ALIQUOTA = @p_Aliquota      
    and CODIGO_SERVICO = @p_Codigo_Servico     
   ELSE    
    SELECT @v_ValorDeducaoRPS = sum(n.aliquota_deducao * valor / 100)           
    FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N                
    WHERE I.CODIGO_LANC = N.CODIGO_LANC              
    AND I.BOLETO = @p_boleto              
    AND N.FACULDADE = rTrim(lTrim(@p_faculdade))       
    AND N.TIPO = rTrim(lTrim(@p_Qualtipo))          
    AND N.NOTA_FISCAL_SERIE = rtrim(ltrim(@p_Serie))         
    AND I.NUM_BOLSA IS NULL       
    AND I.DEVOLUCAO IS NULL       
    AND I.ACORDO IS NULL       
    AND I.NUM_FINANCIAMENTO IS NULL       
    AND I.CODIGO_LANC <> 'Acerto'      
    AND I.COBRANCA_ORIG IS NULL      
    AND I.ITEMCOBRANCA_ORIG IS NULL      
  END      
         
 if @p_TipoValor = 'Valor Pago'      
  BEGIN      
   IF @p_Cob <> 'N'    
    BEGIN    
     SELECT @v_Aliquota_DeducaoRPS = n.aliquota_deducao       
     From ly_item_lanc i, ly_nota_fiscal_cod_lanc n            
     Where i.codigo_lanc = n.codigo_lanc            
     and n.faculdade = rTrim(ltrim(@p_faculdade))         
     and n.tipo = rTrim(ltrim(@p_Qualtipo))            
     and n.nota_fiscal_serie = rtrim(ltrim(@p_Serie))        
     and i.cobranca = @p_Boleto    
     and n.aliquota = @p_Aliquota            
     and CODIGO_SERVICO = @p_Codigo_Servico     
        
     Select @v_ValorDeducaoRPS = sum(ic.valor)       
     From ly_item_cred ic            
     Where ic.tipodesconto is null and        
     ic.tipo_encargo is null and        
     ic.cobranca = @p_Boleto    
    
     IF @v_ValorTotalCob <> 0 AND @v_ValorCob > 0    
      Select @v_ValorDeducaoRPS = (@v_ValorDeducaoRPS * @v_ValorCob) / @v_ValorTotalCob    
     ELSE    
      Select @v_ValorDeducaoRPS = 0     
     END    
   ELSE    
    BEGIN    
     SELECT @v_Aliquota_DeducaoRPS = n.aliquota_deducao       
     From ly_item_lanc i, ly_nota_fiscal_cod_lanc n            
     Where i.codigo_lanc = n.codigo_lanc            
     and n.faculdade = rTrim(ltrim(@p_faculdade))         
     and n.tipo = rTrim(ltrim(@p_Qualtipo))            
     and n.nota_fiscal_serie = rtrim(ltrim(@p_Serie))        
     and exists (select 1 from ly_item_lanc b where b.cobranca = i.cobranca and b.boleto = @p_Boleto)            
     
     Select @v_ValorDeducaoRPS = sum(ic.valor)       
     From ly_item_cred ic            
     Where ic.tipodesconto is null and        
     ic.tipo_encargo is null and        
     exists (select 1 from ly_item_lanc b where b.cobranca = ic.cobranca and b.boleto = @p_Boleto)        
    END    
    
   SELECT @v_ValorDeducaoRPS =  (-1)*((@v_Aliquota_DeducaoRPS * @v_ValorDeducaoRPS)/100)      
  END         
                
 EXECUTE GET_ERROR_ID @v_Erros_ID                
     
 IF @v_Erros_ID <> 0                
  BEGIN                
   SET @v_straux1 = convert(varchar(50),@v_resp)                
   SELECT @v_Erro = 'Erro ao obter os dados de RPS para o responsável ' + @v_straux1                 
   EXECUTE SetErro @v_Erro, 'RESP'                
   RETURN                
  END                    
      
 IF @v_NumeroRPS is null                
  BEGIN              
   SET @v_straux1 = convert(varchar(50),@p_faculdade)                
   SELECT @v_Erro = 'Não existem opções.' + @v_straux1                 
   EXECUTE SetErro @v_Erro, 'FACULDADE'              
   RETURN                  
  END              
              
 if @p_TipoValor = 'Valor Lançado Líquido'      
  BEGIN       
   IF @p_Cob <> 'N'    
    SELECT @v_ValorServicoRPS = isnull(SUM(VALOR),0)                 
    FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N                
    WHERE I.CODIGO_LANC = N.CODIGO_LANC              
    AND I.COBRANCA = @p_boleto              
    AND N.FACULDADE = rTrim(lTrim(@p_faculdade))       
    AND N.TIPO = rTrim(lTrim(@p_Qualtipo))          
    AND N.NOTA_FISCAL_SERIE = rtrim(ltrim(@p_Serie))    
    AND N.ALIQUOTA = @p_Aliquota     
    and CODIGO_SERVICO = @p_Codigo_Servico        
   ELSE     
    SELECT @v_ValorServicoRPS = isnull(SUM(VALOR),0)                 
    FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N                
    WHERE I.CODIGO_LANC = N.CODIGO_LANC              
    AND I.BOLETO = @p_boleto              
    AND N.FACULDADE = rTrim(lTrim(@p_faculdade))       
    AND N.TIPO = rTrim(lTrim(@p_Qualtipo))          
    AND N.NOTA_FISCAL_SERIE = rtrim(ltrim(@p_Serie))      
  END      
       
 if @p_TipoValor = 'Valor Lançado Bruto'      
  BEGIN       
   IF @p_Cob <> 'N'    
    SELECT @v_ValorServicoRPS = isnull(SUM(VALOR),0)                 
    FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N                
    WHERE I.CODIGO_LANC = N.CODIGO_LANC              
    AND I.COBRANCA = @p_boleto              
    AND N.FACULDADE = rTrim(lTrim(@p_faculdade))       
    AND N.TIPO = rTrim(lTrim(@p_Qualtipo))          
    AND N.NOTA_FISCAL_SERIE = rtrim(ltrim(@p_Serie))         
    AND I.NUM_BOLSA IS NULL       
    AND I.DEVOLUCAO IS NULL       
    AND I.ACORDO IS NULL       
    AND I.NUM_FINANCIAMENTO IS NULL       
    AND I.CODIGO_LANC <> 'Acerto'      
    AND I.COBRANCA_ORIG IS NULL      
    AND I.ITEMCOBRANCA_ORIG IS NULL     
    AND N.ALIQUOTA = @p_Aliquota     
    and CODIGO_SERVICO = @p_Codigo_Servico     
   ELSE    
    SELECT @v_ValorServicoRPS = isnull(SUM(VALOR),0)                 
    FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N                
    WHERE I.CODIGO_LANC = N.CODIGO_LANC              
    AND I.BOLETO = @p_boleto              
    AND N.FACULDADE = rTrim(lTrim(@p_faculdade))       
    AND N.TIPO = rTrim(lTrim(@p_Qualtipo))          
    AND N.NOTA_FISCAL_SERIE = rtrim(ltrim(@p_Serie))         
    AND I.NUM_BOLSA IS NULL       
    AND I.DEVOLUCAO IS NULL       
    AND I.ACORDO IS NULL       
    AND I.NUM_FINANCIAMENTO IS NULL       
    AND I.CODIGO_LANC <> 'Acerto'      
    AND I.COBRANCA_ORIG IS NULL      
    AND I.ITEMCOBRANCA_ORIG IS NULL      
  END      
           
 if @p_TipoValor = 'Valor Pago'      
  BEGIN      
   IF @p_Cob <> 'N'    
    BEGIN      
     SELECT @v_ValorServicoRPS = isnull(SUM(IC.VALOR),0) * (-1)                   
     FROM  ly_item_cred ic                    
     WHERE exists (SELECT  I.COBRANCA      
        FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N      
        WHERE I.CODIGO_LANC = N.CODIGO_LANC AND                
        I.COBRANCA = IC.COBRANCA AND        
        I.COBRANCA = @p_boleto AND        
        N.FACULDADE = rTrim(lTrim(@p_faculdade)) AND         
        N.TIPO = rTrim(lTrim(@p_Qualtipo)) AND         
        N.NOTA_FISCAL_SERIE = rtrim(ltrim(@p_Serie)))      
     AND ic.tipodesconto is null       
     AND ic.tipo_encargo is null     
    
     IF @v_ValorTotalCob <> 0    
      Select @v_ValorServicoRPS = (@v_ValorServicoRPS * @v_ValorCob) / @v_ValorTotalCob    
     ELSE    
      Select @v_ValorServicoRPS = 0     
    END    
            
   ELSE     
    SELECT @v_ValorServicoRPS = isnull(SUM(IC.VALOR),0) * (-1)                   
    FROM  ly_item_cred ic                    
    WHERE exists (SELECT  I.COBRANCA      
       FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N      
       WHERE I.CODIGO_LANC = N.CODIGO_LANC AND                
       I.COBRANCA = IC.COBRANCA AND        
       I.BOLETO = @p_boleto AND        
       N.FACULDADE = rTrim(lTrim(@p_faculdade)) AND         
       N.TIPO = rTrim(lTrim(@p_Qualtipo)) AND         
       N.NOTA_FISCAL_SERIE = rtrim(ltrim(@p_Serie)))      
    AND ic.tipodesconto is null       
    AND ic.tipo_encargo is null         
  END        
         
               
 IF @v_Erros_ID <> 0                
  BEGIN                
   SET @v_straux1 = convert(varchar(50),@p_boleto)                
   SELECT @v_Erro = 'Erro ao obter o valor de RPS para o boleto ' + @v_straux1              
   EXECUTE SetErro @v_Erro, 'BOLETO'                
   RETURN                
  END                    
      
 IF @v_ValorServicoRPS <= 0 RETURN              
                                    
        
 UPDATE ly_opcoes_nota_fiscal set nota_fiscal = nota_fiscal + 1       
 WHERE FACULDADE = @p_faculdade and TIPO = @p_Qualtipo      
 and NOTA_FISCAL_SERIE = @p_Serie                
        
    SELECT @v_NotaFiscalSerie = @p_Serie    
         
 -- Gera os valores e cód. servicos.      
 EXECUTE a_numero_RPS @p_faculdade, @p_boleto, @v_resp, @v_numeroRPS output, @v_ValorServicoRPS output, @v_ValorDeducaoRPS output, 'PROCESSO', @v_NotaFiscalSerie output, @p_Aliquota, @p_Codigo_Servico              

 EXECUTE s_GERA_ARQ_RPS_CONFIG_CUR 
			@v_Situacao, 
			@v_NaturezaOperacao OUTPUT, 
			@v_RegimeEspTrib OUTPUT, 
			@v_SimplesNacional OUTPUT, 
			@v_IncentCultural OUTPUT, 
			@v_Status OUTPUT, 
			@v_DescontoIncond OUTPUT,
			@v_CodigoCnae OUTPUT,
			@v_CodigoTributacaoMunicipio OUTPUT, 
			@v_DiscriminacaoServico OUTPUT,
			@v_ExigibilidadeISS OUTPUT,
			@v_TipoTributacao OUTPUT,
			@v_CodigoItemListaServico OUTPUT,
			@p_boleto    
      
 SET @v_ValorDescontoRPS = 0    
      
 IF @v_DescontoIncond = 'S'    
  BEGIN    
   IF @p_Cob = 'N'    
    BEGIN    
     IF @p_Qualtipo = 'U'    
      BEGIN    
       SELECT @v_ValorDescontoRPS = SUM(ISNULL(VALOR,0))     
       FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N, LY_ALUNO A, LY_BOLETO B     
       WHERE I.CODIGO_LANC = N.CODIGO_LANC     
       AND I.BOLETO = @p_boleto      
       AND I.BOLETO = B.BOLETO     
       AND I.ALUNO = A.ALUNO     
       AND ((I.NUM_BOLSA IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LY_ITEM_LANC IL, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE     
                   WHERE IL.NUM_BOLSA = B.NUM_BOLSA     
                   AND IL.ALUNO = B.ALUNO     
                   AND B.TIPO_BOLSA = TB.TIPO_BOLSA     
                   AND TB.TIPO_ENCARGO = TE.TIPO_ENCARGO     
                   AND TE.CATEGORIA = 'PerdaBolsa'     
                   AND IL.NUM_BOLSA IS NOT NULL     
                   AND IL.LANC_DEB IS NOT NULL     
                   AND IL.BOLETO = I.BOLETO))     
                   OR I.MOTIVO_DESCONTO IS NOT NULL)    
       AND N.TIPO = @p_Qualtipo    
       AND A.UNIDADE_FISICA = N.FACULDADE     
       AND B.EMPRESA IS NULL    
      END -- IF @p_Qualtipo = 'U'    
         
     IF @p_Qualtipo = 'E'    
      BEGIN    
       SELECT @v_ValorDescontoRPS = SUM(ISNULL(VALOR,0))      
       FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N, LY_ALUNO A, LY_BOLETO B     
       WHERE I.CODIGO_LANC = N.CODIGO_LANC     
       AND I.BOLETO = @p_boleto      
       AND I.BOLETO = B.BOLETO     
       AND I.ALUNO = A.ALUNO     
       AND ((I.NUM_BOLSA IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LY_ITEM_LANC IL, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE     
                   WHERE IL.NUM_BOLSA = B.NUM_BOLSA     
                   AND IL.ALUNO = B.ALUNO     
                   AND B.TIPO_BOLSA = TB.TIPO_BOLSA     
                   AND TB.TIPO_ENCARGO = TE.TIPO_ENCARGO     
                   AND TE.CATEGORIA = 'PerdaBolsa'     
                   AND IL.NUM_BOLSA IS NOT NULL     
                   AND IL.LANC_DEB IS NOT NULL     
                   AND IL.BOLETO = I.BOLETO))     
                   OR I.MOTIVO_DESCONTO IS NOT NULL)    
       AND N.TIPO = @p_Qualtipo    
       AND B.EMPRESA = N.FACULDADE    
       AND B.EMPRESA IS NULL    
      END -- IF @p_Qualtipo = 'E'    
         
     IF @p_Qualtipo = 'M'    
      BEGIN    
       SELECT @v_ValorDescontoRPS = SUM(ISNULL(VALOR,0))     
       FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N, LY_ALUNO A, LY_BOLETO B, LY_CURSO CUR, LY_UNIDADE_ENSINO U, LY_INSTITUICAO IT    
       WHERE I.CODIGO_LANC = N.CODIGO_LANC     
       AND I.BOLETO =  @p_boleto      
       AND I.BOLETO = B.BOLETO     
       AND I.ALUNO = A.ALUNO     
       AND A.CURSO = CUR.CURSO    
       AND U.UNIDADE_ENS = CUR.FACULDADE    
       AND IT.OUTRA_FACULDADE = U.OUTRA_FACULDADE    
       AND ((I.NUM_BOLSA IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LY_ITEM_LANC IL, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE     
                   WHERE IL.NUM_BOLSA = B.NUM_BOLSA     
                   AND IL.ALUNO = B.ALUNO     
                   AND B.TIPO_BOLSA = TB.TIPO_BOLSA     
                   AND TB.TIPO_ENCARGO = TE.TIPO_ENCARGO     
                   AND TE.CATEGORIA = 'PerdaBolsa'     
                   AND IL.NUM_BOLSA IS NOT NULL     
                   AND IL.LANC_DEB IS NOT NULL     
                   AND IL.BOLETO = I.BOLETO))     
                   OR I.MOTIVO_DESCONTO IS NOT NULL)    
       AND N.TIPO = @p_Qualtipo    
      END    
          
    END -- IF @p_Cob = 'N'    
   ELSE    
    BEGIN    
     IF @p_Cob = 'S'    
      BEGIN    
       IF @p_Qualtipo = 'U'    
        BEGIN    
         SELECT @v_ValorDescontoRPS = SUM(ISNULL(VALOR,0))     
         FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N, LY_ALUNO A, LY_BOLETO B     
         WHERE I.CODIGO_LANC = N.CODIGO_LANC              AND I.COBRANCA =  @p_boleto       
         AND I.BOLETO = B.BOLETO     
         AND I.ALUNO = A.ALUNO     
         AND ((I.NUM_BOLSA IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LY_ITEM_LANC IL, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE     
                     WHERE IL.NUM_BOLSA = B.NUM_BOLSA     
                     AND IL.ALUNO = B.ALUNO     
                     AND B.TIPO_BOLSA = TB.TIPO_BOLSA     
                     AND TB.TIPO_ENCARGO = TE.TIPO_ENCARGO     
                     AND TE.CATEGORIA = 'PerdaBolsa'     
                     AND IL.NUM_BOLSA IS NOT NULL     
                     AND IL.LANC_DEB IS NOT NULL     
                     AND IL.BOLETO = I.BOLETO))     
                     OR I.MOTIVO_DESCONTO IS NOT NULL)    
         AND N.TIPO = @p_Qualtipo    
         AND A.UNIDADE_FISICA = N.FACULDADE     
         AND B.EMPRESA IS NULL    
        END  -- IF @p_Qualtipo = 'U'    
           
       IF @p_Qualtipo = 'E'    
        BEGIN    
         SELECT @v_ValorDescontoRPS = SUM(ISNULL(VALOR,0))     
         FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N, LY_ALUNO A, LY_BOLETO B     
         WHERE I.CODIGO_LANC = N.CODIGO_LANC     
         AND I.COBRANCA =  @p_boleto      
         AND I.BOLETO = B.BOLETO     
         AND I.ALUNO = A.ALUNO     
         AND ((I.NUM_BOLSA IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LY_ITEM_LANC IL, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE     
                     WHERE IL.NUM_BOLSA = B.NUM_BOLSA     
                     AND IL.ALUNO = B.ALUNO     
                     AND B.TIPO_BOLSA = TB.TIPO_BOLSA     
                     AND TB.TIPO_ENCARGO = TE.TIPO_ENCARGO     
                     AND TE.CATEGORIA = 'PerdaBolsa'     
                     AND IL.NUM_BOLSA IS NOT NULL     
                     AND IL.LANC_DEB IS NOT NULL     
                     AND IL.BOLETO = I.BOLETO))     
                     OR I.MOTIVO_DESCONTO IS NOT NULL)    
         AND N.TIPO = @p_Qualtipo    
         AND B.EMPRESA = N.FACULDADE    
         AND B.EMPRESA IS NULL    
        END -- IF @p_Qualtipo = 'E'    
                  
       IF @p_Qualtipo = 'M'    
        BEGIN    
         SELECT @v_ValorDescontoRPS = SUM(ISNULL(VALOR,0))     
         FROM LY_ITEM_LANC I, LY_NOTA_FISCAL_COD_LANC N, LY_ALUNO A, LY_BOLETO B, LY_CURSO CUR, LY_UNIDADE_ENSINO U, LY_INSTITUICAO IT    
         WHERE I.CODIGO_LANC = N.CODIGO_LANC     
         AND I.COBRANCA =  @p_boleto      
         AND I.BOLETO = B.BOLETO     
         AND I.ALUNO = A.ALUNO     
         AND A.CURSO = CUR.CURSO    
         AND U.UNIDADE_ENS = CUR.FACULDADE    
         AND IT.OUTRA_FACULDADE = U.OUTRA_FACULDADE    
         AND ((I.NUM_BOLSA IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LY_ITEM_LANC IL, LY_BOLSA B, LY_TIPO_BOLSA TB, LY_TIPO_ENCARGOS  TE     
                     WHERE IL.NUM_BOLSA = B.NUM_BOLSA     
                     AND IL.ALUNO = B.ALUNO     
                     AND B.TIPO_BOLSA = TB.TIPO_BOLSA     
                     AND TB.TIPO_ENCARGO = TE.TIPO_ENCARGO     
                     AND TE.CATEGORIA = 'PerdaBolsa'     
                     AND IL.NUM_BOLSA IS NOT NULL     
                     AND IL.LANC_DEB IS NOT NULL     
                     AND IL.BOLETO = I.BOLETO))     
                     OR I.MOTIVO_DESCONTO IS NOT NULL)    
         AND N.TIPO = @p_Qualtipo    
        END    
            
      END -- IF @p_Cob = 'S'    
    END       
  END -- IF @v_DescontoIncond = 'S'    
     
 SET @v_Mantenedora = NULL    
     
 IF @p_Qualtipo = 'M'    
  BEGIN    
   IF @p_Cob = 'S'    
    BEGIN    
     SELECT @v_Mantenedora = I.MANTENEDORA    
     FROM LY_ALUNO A, LY_UNIDADE_ENSINO U, LY_CURSO C, LY_INSTITUICAO I, LY_COBRANCA CO    
     WHERE A.ALUNO = CO.ALUNO    
     AND C.CURSO = A.CURSO    
     AND U.UNIDADE_ENS = C.FACULDADE    
     AND I.OUTRA_FACULDADE = U.OUTRA_FACULDADE    
     AND CO.COBRANCA = @p_boleto    
    END    
   ELSE    
    BEGIN    
     SELECT @v_Mantenedora = I.MANTENEDORA    
     FROM LY_ALUNO A, LY_UNIDADE_ENSINO U, LY_CURSO C, LY_INSTITUICAO I, LY_COBRANCA CO,LY_ITEM_LANC IL, LY_BOLETO BOL    
     WHERE IL.BOLETO = BOL.BOLETO    
     AND CO.COBRANCA = IL.COBRANCA    
     AND A.ALUNO = CO.ALUNO    
     AND C.CURSO = A.CURSO    
     AND U.UNIDADE_ENS = C.FACULDADE    
     AND I.OUTRA_FACULDADE = U.OUTRA_FACULDADE    
     AND BOL.BOLETO = @p_boleto    
    END    
  END    
      
 EXECUTE s_CALCULA_DEMAIS_TRIBUTOS_NFE  @p_Cob, @p_boleto, @v_NumeroRPS, @v_ValorServicoRPS, @v_ValorDeducaoRPS, @v_ValorDescontoRPS,     
            @p_Aliquota, @p_Codigo_Servico, @p_dt_emissao, @v_Mantenedora, @p_Serie,     
            @v_Valor_Pis OUTPUT, @v_Valor_Cofins OUTPUT, @v_Valor_Ir OUTPUT,     
            @v_Valor_Csll OUTPUT, @v_Valor_Inss OUTPUT    
      
 SET @v_Valor_Pis = ISNULL(@v_Valor_Pis,0)     
 SET @v_Valor_Cofins = ISNULL(@v_Valor_Cofins,0)     
 SET @v_Valor_Ir = ISNULL(@v_Valor_Ir,0)     
 SET @v_Valor_Csll = ISNULL(@v_Valor_Csll,0)     
 SET @v_Valor_Inss = ISNULL(@v_Valor_Inss,0)     
       
 -- Atualiza os dados acima no boleto ou cobranca    
 IF @p_Cob <> 'N'    
  BEGIN    
    IF @v_NumeroRPS IS NOT null    
   BEGIN    
     IF @p_Qualtipo <> 'M'    
    INSERT INTO LY_COBRANCA_NOTA_FISCAL(COBRANCA,ALIQUOTA,VALOR_BASE_COB,NUMERO_RPS,DATA_EMISSAO_RPS,DATA_ENVIO_RPS,VALOR_SERVICO_RPS,VALOR_DEDUCAO_RPS,NUMERO_NFE,DATA_EMISSAO_NFE,VALOR_ISS,LINK_RPS,NOTA_FISCAL_SERIE,VALOR_DESCONTO_RPS,CODIGO_SERVICO,EMPRESA,MANTENEDORA,VALOR_PIS,VALOR_COFINS,VALOR_CSLL,VALOR_IR,VALOR_INSS)    
    VALUES (@p_boleto,@p_Aliquota,@v_ValorCobBase,@v_NumeroRPS,@p_dt_emissao,NULL,@v_ValorServicoRPS,@v_ValorDeducaoRPS,NULL,NULL,NULL,NULL,@p_Serie,@v_ValorDescontoRPS,@p_Codigo_Servico,@p_faculdade,@v_Mantenedora,@v_Valor_Pis,@v_Valor_Cofins,@v_Valor_Csll,@v_Valor_Ir,@v_Valor_Inss)         
     ELSE    
    INSERT INTO LY_COBRANCA_NOTA_FISCAL(COBRANCA,ALIQUOTA,VALOR_BASE_COB,NUMERO_RPS,DATA_EMISSAO_RPS,DATA_ENVIO_RPS,VALOR_SERVICO_RPS,VALOR_DEDUCAO_RPS,NUMERO_NFE,DATA_EMISSAO_NFE,VALOR_ISS,LINK_RPS,NOTA_FISCAL_SERIE,VALOR_DESCONTO_RPS,CODIGO_SERVICO,EMPRESA,MANTENEDORA,VALOR_PIS,VALOR_COFINS,VALOR_CSLL,VALOR_IR,VALOR_INSS)    
    VALUES (@p_boleto,@p_Aliquota,@v_ValorCobBase,@v_NumeroRPS,@p_dt_emissao,NULL,@v_ValorServicoRPS,@v_ValorDeducaoRPS,NULL,NULL,NULL,NULL,@p_Serie,@v_ValorDescontoRPS,@p_Codigo_Servico,NULL,@v_Mantenedora,@v_Valor_Pis,@v_Valor_Cofins,@v_Valor_Csll,@v_Valor_Ir,@v_Valor_Inss)       
   END  -- IF @v_NumeroRPS IS NOT null            
  END    
 ELSE       
  BEGIN          
   EXEC LY_BOLETO_UPDATE                
   @pkBoleto = @p_boleto,                 
   @numero_rps = @v_NumeroRPS,                
   @valor_servico_rps = @v_ValorServicoRPS,                
   @valor_deducao_rps = @v_ValorDeducaoRPS,              
   @data_emissao_rps = @p_dt_emissao,    
   @nota_fiscal_serie =  @p_Serie,         
   @valor_desconto_rps = @v_ValorDescontoRPS,    
   @mantenedora = @v_Mantenedora,    
   @valor_pis = @v_Valor_Pis,     
   @valor_cofins = @v_Valor_Cofins,     
   @valor_ir = @v_Valor_Ir,     
   @valor_csll = @v_Valor_Csll,     
   @valor_inss = @v_Valor_Inss,    
   @dt_solicita_cancel_rps = @v_Dt_Solicita_Cancel_Rps,    
   @dt_envio_cancel_rps = @v_Dt_Envio_Cancel_Rps,     
   @motivo_cancel_rps = @v_Motivo_Cancel_Rps    
  END      
-- [FIM] 