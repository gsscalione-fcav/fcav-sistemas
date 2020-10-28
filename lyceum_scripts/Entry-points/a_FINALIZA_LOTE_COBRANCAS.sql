--* ***************************************************************  
--*  
--*  *** PROCEDURE a_FINALIZA_LOTE_COBRANCAS  ***  
--*   
--* DESCRICAO:  
--*  - LANÇAR ENCARGO IGPM QUANDO PARCELA MAIOR OU IGUAL A 13ª    
--*  
--* PARAMETROS:  
--*  
--* USO:  
--*  
--* ALTERAÇÕES: RICARDO.NUNES - TECHNE    
--* DATA: 12/05/2014    
--* OBJETIVO: 1 - Lançar encargo igpm quando parcela maior ou igual a 13ª    
--* 2 - Alterar vencimento das cobranças de matrícula, para 15 dias após a geração, para os responsáveis juridicos    
--* 3 - Alterar vencimento das cobranças de matrícula, para 15 dias após a geração, para os responsáveis juridicos    
--*  
--* ALTERAÇÕES: JOAO PAULO  
--* DATA: 13/07/2016  
--* OBJETIVO: Tratamento de IGPM comentado por esse assunto estar sendo tratado na Entry Point a_APoI_Ly_item_lanc  
--*  
--* Autor: NATÁLIA ORSETTI (TECHNE)   
--* Data de criação: 08/11/2013  
--*   
--* ***************************************************************   
      
ALTER PROCEDURE a_FINALIZA_LOTE_COBRANCAS  
  @p_Resp         T_CODIGO,          
  @p_Ano          T_ANO,          
  @p_Mes          T_MES,          
  @p_Cobranca     T_NUMERO,          
  @p_Data_venc    T_DATA          
AS          
-- [INÍCIO]          
DECLARE @vPARCELA T_NUMERO    
DECLARE @vTipoCurso VARCHAR(20)    
    
-- 1    
SELECT @vPARCELA = IL.PARCELA,    
 @vTipoCurso = CS.TIPO    
FROM LY_COBRANCA C JOIN LY_ALUNO A ON C.ALUNO = A.ALUNO    
 JOIN LY_CURSO CS ON A.CURSO = CS.CURSO    
JOIN LY_ITEM_LANC IL    
 ON IL.COBRANCA = C.COBRANCA    
WHERE C.COBRANCA = @p_Cobranca     
  
-- *** Tratamento de IGPM comentado por esse assunto estar sendo tratado na Entry Point a_APoI_Ly_item_lanc  
--IF @vPARCELA > 12    
-- BEGIN    
--  INSERT INTO LY_ENCARGOS_COB_GERADO VALUES (    
--   @p_Cobranca,'IGPM', 1, NULL, 'Valor', 1.000000)    
      
--  UPDATE LY_ENCARGOS_COB_GERADO    
--  SET ENCARGOCOPIADO = 2    
--  WHERE TIPO_ENCARGO = 'JUROS'    
--  AND COBRANCA = @p_Cobranca    
    
--  UPDATE LY_ENCARGOS_COB_GERADO    
--  SET ENCARGOCOPIADO = 3    
--  WHERE TIPO_ENCARGO = 'MULTA'    
--  AND COBRANCA = @p_Cobranca    
      
--  UPDATE LY_ENCARGOS_COB_GERADO    
--  SET ENCARGOCOPIADO = 4    
--  WHERE TIPO_ENCARGO = 'PERDEBOLSA'    
--  AND COBRANCA = @p_Cobranca      
      
-- END    
     
--Trecho comentado devido ao problema na hora de gerar o boleto A vista para PJ.       
  
---- 2 - ALTERA VENCIMENTO RESPONSÁVEL CADASTRADO COMO PESSOA JURIDICA PARA COBRANÇAS DE MATRICULA     
--IF (EXISTS (SELECT 1 FROM LY_RESP_FINAN WHERE CGC_TITULAR IS NOT NULL AND RESP = @p_Resp)    
-- --  AND EXISTS (SELECT 1 FROM LY_ITEM_LANC WHERE CODIGO_LANC = 'MT' AND COBRANCA = @p_Cobranca))    
-- AND (EXISTS (SELECT 1 FROM LY_ITEM_LANC WHERE CODIGO_LANC = 'MT' AND COBRANCA = @p_Cobranca) OR @vTipoCurso = 'Atualização'))    
--BEGIN    
    
-- UPDATE LY_COBRANCA    
--  SET DATA_DE_VENCIMENTO = DATEADD(DAY, 15, DATA_DE_VENCIMENTO_ORIG)    
-- FROM LY_COBRANCA C    
-- WHERE COBRANCA = @p_Cobranca    
-- AND NOT EXISTS (SELECT 1 FROM LY_PLANO_PGTO_PERIODO PP WHERE PP.ALUNO = C.ALUNO AND PP.ANO = C.ANO    
--      AND (PP.PLANOPAG = 'AVISTA' OR PP.NUM_PARCELAS = 1))     
    
--END     
    
---- 3 - REMOVE DESCONTO PONTUALIDADE PARA COBRANCAS ASSOCIADAS A PLANO DE PAGAMENTO DO PERÍODO A VISTA (1 PARCELA)    
--IF EXISTS (SELECT 1 FROM LY_COBRANCA C JOIN LY_ALUNO A ON C.ALUNO = A.ALUNO    
--   WHERE C.COBRANCA = @p_Cobranca    
--   AND EXISTS (SELECT 1 FROM HADES..HD_TABELAITEM H WHERE H.TABELA = 'LyCustDescAnt' AND H.ITEM = A.CURSO)    
--   AND EXISTS (SELECT 1 FROM LY_PLANO_PGTO_PERIODO PP WHERE PP.ALUNO = A.ALUNO AND PP.ANO = C.ANO    
--      AND (PP.PLANOPAG = 'AVISTA' OR PP.NUM_PARCELAS = 1))    
--   )    
--BEGIN    
-- DELETE LY_DESCONTO_COBRANCA WHERE COBRANCA = @p_Cobranca AND TIPODESCONTO = 'PagtoAntecipado'    
--END    
    
  RETURN         
-- [FIM]