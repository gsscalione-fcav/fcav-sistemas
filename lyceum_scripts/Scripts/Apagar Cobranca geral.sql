DECLARE @COBRANCA T_NUMERO

SET @COBRANCA = 119051 -- COBRANCA A SER EXCLU�DA


SELECT COBRANCA,* FROM VW_FCAV_EXTRATO_FINANCEIRO2 WHERE COBRANCA = @COBRANCA


DELETE LY_APROP_CRED WHERE  ID_CAR IN (SELECT CAR.ID_CAR FROM LY_CAR AS CAR WHERE CAR.COBRANCA = @COBRANCA)
DELETE LY_CAR WHERE COBRANCA = @COBRANCA
DELETE LY_ENCARGOS_COB_GERADO WHERE COBRANCA = @COBRANCA
DELETE LY_ITEM_LANC WHERE COBRANCA = @COBRANCA
DELETE LY_EAR WHERE COBRANCA = @COBRANCA
DELETE LY_ITEM_BOLETO_REMOVIDO WHERE BOLETO IN (SELECT BOL.BOLETO FROM LY_BOLETO AS BOL INNER JOIN VW_COBRANCA_BOLETO AS VW ON (BOL.BOLETO = VW.BOLETO) WHERE VW.COBRANCA = @COBRANCA)
DELETE LY_BOLETO WHERE BOLETO IN (SELECT BOL.BOLETO FROM LY_BOLETO AS BOL INNER JOIN VW_COBRANCA_BOLETO AS VW ON (BOL.BOLETO = VW.BOLETO) WHERE VW.COBRANCA = @COBRANCA)
DELETE LY_ITEM_CRED WHERE COBRANCA = @COBRANCA
DELETE LY_DESCONTO_COBRANCA WHERE COBRANCA = @COBRANCA
DELETE LY_MOVIMENTO_TEMPORAL WHERE ID1 = CAST(@COBRANCA AS VARCHAR(20))
DELETE LY_COBRANCA WHERE COBRANCA = @COBRANCA


SELECT * FROM VW_FCAV_EXTRATO_FINANCEIRO2 WHERE COBRANCA = @COBRANCA