  
  
CREATE PROCEDURE s_Gera_Arq_Rps_Config_Cur     
  
  @p_Situacao                       VARCHAR(1) OUTPUT,      
  @p_NaturezaOperacao               VARCHAR(2) OUTPUT,      
  @p_RegimeEspTrib                  VARCHAR(2) OUTPUT,      
  @p_SimplesNacional                VARCHAR(2) OUTPUT,      
  @p_IncentCultural                 VARCHAR(2) OUTPUT,      
  @p_Status                         VARCHAR(2) OUTPUT,      
  @p_DescontoIncond                 VARCHAR(1) OUTPUT,    
  @p_CodigoCnae                     VARCHAR(20) OUTPUT,    
  @p_CodigoTributacaoMunicipio      VARCHAR(20) OUTPUT,    
  @p_DiscriminacaoServico           VARCHAR(200) OUTPUT,    
  @p_ExigibilidadeISS               VARCHAR(20) OUTPUT,      
  @p_TipoTributacao                 VARCHAR(20) OUTPUT,      
  @p_CodigoItemListaServico         VARCHAR(20) OUTPUT,      
  @p_Cobranca_Boleto      T_NUMERO   
  
AS    
  
  IF @p_Situacao <> 'T'     
  
    SELECT @p_NaturezaOperacao = '3'    
  
  ELSE    
  
    SELECT @p_NaturezaOperacao = '1'    
  
    
  
  SELECT @p_RegimeEspTrib = '1'    
  
  SELECT @p_SimplesNacional = '2'    
  
  SELECT @p_IncentCultural = '2'    
  
  SELECT @p_Status = '1'    
  
  SELECT @p_DescontoIncond = 'N'    
  
  RETURN                     