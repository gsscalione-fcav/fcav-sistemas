SELECT
*
FROM LY_ITEM_LANC
WHERE COBRANCA = 68990
AND PARCELA = 14

DELETE LY_ITEM_LANC
WHERE COBRANCA = 68990
AND PARCELA = 14



-- Atualização do último item em LY_COBRANCA ---  
            UPDATE LY_COBRANCA  
            SET ULTIMO_ITEM =(  
                  SELECT COUNT(*)  
                    FROM dbo.LY_ITEM_LANC  
                    WHERE COBRANCA = 68990  
                )
             WHERE COBRANCA = 68990 

SELECT
*
FROM LY_ITEM_LANC
WHERE COBRANCA = 68990