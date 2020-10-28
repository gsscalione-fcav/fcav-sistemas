/*	VIEW utilizada na SP_EXTRATO_FINANCEIRO
	
	Ela separa os itens (LY_ITEM_LANC) que não são estorno

*/
  
ALTER VIEW VW_FCAV_IL_NAO_ESTORNO AS  
SELECT il.*  
FROM  
    dbo.LY_COBRANCA cob  
        INNER JOIN dbo.LY_ITEM_LANC il  
        ON il.COBRANCA = cob.COBRANCA  
WHERE  
    cob.ESTORNO = 'N'  
AND cob.COBRANCA NOT IN(  
  SELECT COBRANCA  
  FROM VW_FCAV_COBRANCA_DIF_ESTORNO  
 )  
--  
AND NOT EXISTS(  
        SELECT *  
        FROM dbo.LY_ITEM_LANC il_est  
        WHERE  
            il_est.COBRANCA       = il.COBRANCA  
        AND il_est.ITEM_ESTORNADO = il.ITEMCOBRANCA  
        --  
        AND il_est.ITEMCOBRANCA <> il_est.ITEM_ESTORNADO  
                -- O próprio item estornado TEM ITEM_ESTORNADO apontando para si mesmo  
                -- E foram encontrados casos em que ITEM_ESTORNADO aponta para si mesmo  
                -- sem que tenha qualquer outro registro apontando para ele  
                -- (o registro original de estorno foi excluído do banco de dados?)  
    )  
--  
AND ISNULL(il.ITEM_ESTORNADO, il.ITEMCOBRANCA)  
        = il.ITEMCOBRANCA -- Todos itens, menos os de estorno  
                          -- Item estornado tem valor ITEM_ESTORNADO apontando para si mesmo  
                          -- Ver observação do item acims  