--* ***************************************************************  
--*  
--*  *** PROCEDURE a_Numero_RPS  ***  
--*   
--* DESCRICAO:  
--*  - Ajuste para não gerar RPS para títulos em que o aluno ou responsável  
--* possui TESTE no nome.  
--*  
--* PARAMETROS:  
--*  
--* USO:  
--*  
--* ALTERAÇÕES:   
--*  17/09/2018: Adicionado a validação para trazer o valor da RPS quando o desconto for na dívida.
--* Autor:  
--*   
--* ***************************************************************  
ALTER PROCEDURE a_Numero_RPS      
  @p_faculdade         T_CODIGO,      
  @p_boleto            T_NUMERO,        
  @p_resp              T_CODIGO,        
  @p_numero_RPS        NUMERIC(12,0) OUTPUT,    
  @p_valorServicoRPS   T_DECIMAL_MEDIO OUTPUT,    
  @p_valorDeducaoRPS   T_DECIMAL_MEDIO OUTPUT,  
  @p_contexto          T_ALFASMALL,  
  @p_nota_fiscal_serie VARCHAR(5) OUTPUT,  
  @p_Aliquota		   NUMERIC(5, 2),  
  @p_Codigo_Servico    T_NUMERO  
AS    
BEGIN  
  -- O parâmetro @p_contexto será 'GER_BOLETO' se chamado da procedure gera_boleto_resp  
  -- ou 'PAGAMENTO' se chamado da procedure PAGAMENTO_BOLETO  
  -- ou 'PROCESSO' se chamado da procedure GERA_RPS.  
  
  -- [INÍCIO] Customização - Não escreva código antes desta linha  
    
-- Verifica se a cobrança possui desconto na dívida (Voucher ou Plano Pgto) para trazer o valor bruto
IF EXISTS(
  SELECT 1
  FROM LY_ITEM_LANC
  WHERE BOLETO = @p_boleto  
	AND MOTIVO_DESCONTO in ('Voucher', 'PlanoPagamento'))
BEGIN
	 SELECT @p_valorServicoRPS = VALOR
	 FROM LY_ITEM_LANC 
	 WHERE BOLETO = @p_boleto
	 AND ITEMCOBRANCA = 1
END

------------------------------------------------
-- Verificação para não gerar o RPS quando for teste
  IF EXISTS  
  (  
  SELECT 1  
  FROM VW_COBRANCA_BOLETO B JOIN LY_COBRANCA C ON B.COBRANCA = C.COBRANCA  
 JOIN LY_ALUNO A ON C.ALUNO = A.ALUNO  
 JOIN LY_RESP_FINAN R ON C.RESP = R.RESP  
  WHERE B.BOLETO = @p_boleto  
  AND (A.NOME_COMPL LIKE '%TESTE%' OR R.TITULAR LIKE '%TESTE%')  
  )  
  BEGIN  
    SET @p_numero_RPS = NULL  
	SET @p_valorServicoRPS = NULL  
	SET @p_valorDeducaoRPS = NULL  
	SET @p_nota_fiscal_serie = NULL  
   
 UPDATE LY_OPCOES_NOTA_FISCAL SET NOTA_FISCAL = NOTA_FISCAL - 1 WHERE FACULDADE = @p_faculdade  
  END  
  -- [FIM] Customização - Não escreva código após esta linha  
  
  RETURN   
END

