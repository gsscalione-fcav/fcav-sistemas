/*
SELECT 
	CO.*
FROM
	VW_COBRANCA CO
WHERE
	CO.COBRANCA = 47536


*/

--SELECT * FROM LY_ITEM_LANC WHERE DESCRICAO LIKE '%DIFEREN�A%'

DECLARE @cobranca numeric

SET @cobranca	=  47599

SELECT * FROM LY_ITEM_LANC LY_ITEM_LANC   
   WHERE COBRANCA = @COBRANCA AND VALOR NOT LIKE '-%' AND DESCRICAO LIKE 'Mensalidade do curso%'  

--SELECT * FROM LINKED_BASE_TESTE.LYCEUM.dbo.LY_ITEM_LANC WHERE COBRANCA = @cobranca

INSERT INTO LY_ITEM_LANC  
   SELECT  
    @COBRANCA,  
    '50' AS ITEMCOBRANCA,  
    NULL AS LANC_DEB,  
    'MS' AS CODIGO_LANC,  
    ALUNO,  
    NULL AS NUM_BOLSA,  
    RESP,  
    'Acr�scimo' AS MOTIVO_DESCONTO,  
    DEVOLUCAO,BOLETO,PARCELA,DATA,  
    -143.67 AS VALOR,  
    'Acrescimo de IGPM' AS DESCRICAO,  
    ACORDO,COBRANCA_ORIG,ITEMCOBRANCA_ORIG,CENTRO_DE_CUSTO,NATUREZA,ANO_REF_BOLSA,MES_REF_BOLSA,NUM_FINANCIAMENTO,ENCERR_PROCESSADO,EVENTO,  
    EVENTO_COMPL,DATA_CONTABIL,DT_ENVIO_CONTAB,CURSO,TURNO, CURRICULO,UNID_FISICA,DATA_DISPUTA,DATA_DECISAO_DISPUTA,DISPUTA_ACEITA,  
    DISPUTA_AJUSTADA,MOTIVO_DECISAO,LOTE_CONTABIL,DATA_PERDA,ORIGEM,ITEM_ESTORNADO  
   FROM LY_ITEM_LANC   
   WHERE COBRANCA = @COBRANCA AND VALOR NOT LIKE '-%' AND DESCRICAO LIKE 'Mensalidade do curso%'  
   
   
  SELECT * FROM LY_ITEM_LANC LY_ITEM_LANC   
   WHERE COBRANCA = @COBRANCA 