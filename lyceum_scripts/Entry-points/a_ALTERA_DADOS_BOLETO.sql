--* ***************************************************************  
--*  
--*   *** PROCEDURE a_ALTERA_DADOS_BOLETO  ***  
--*   
--* DESCRICAO:   
--* - Ajuste Techne na gera��o de boletos  
--*      
--* PARAMETROS:  
--*  
--* USO:   
--*  
--* Autor:   
--* Data de cria��o:  
--*   
--* ***************************************************************  
CREATE PROCEDURE a_ALTERA_DADOS_BOLETO        
  @Banco          as T_ALFASMALL,        
  @Agencia        as T_ALFASMALL,        
  @Conta_Banco    as T_ALFASMALL,        
  @Carteira       as T_ALFASMALL,        
  @Convenio       as T_CODIGO,        
  @Aluno          as T_CODIGO,        
  @Boleto         as T_NUMERO,        
  @Nosso_Numero   as NUMERIC(38),        
  @NumDoc         as T_ALFALARGE OUTPUT,      
  @TipoDesconto   as T_ALFALARGE OUTPUT,      
  @idFatura       as T_ALFASMALL OUTPUT,    
  @usaConvenio    as T_SIMNAO  OUTPUT    
AS        
--[INICIO]        
        
  -- OBSERVA��O IMPORTANTE --      
  -- O par�metrto @TipoDesconto ser� utilizado na impress�o do modelo 2 para que alguns tipos de desconto sejam incluidos       
  -- O par�metro @idFatura ser� utilizado na impress�o do modelo 11 para o projeto do Siga2.      
  -- na coluna de cobran�as e n�o no detalhamento dos descontos.      
  -- Deve estar no formato 'TIPO_DESCONTO1','TIPO_DESCONTO2'.      
  SET @idFatura = 'LY-'    
  SET @usaConvenio = 'S'    
  SET @NumDoc = ISNULL(@NumDoc, '')    
  RETURN        
--[FIM] 