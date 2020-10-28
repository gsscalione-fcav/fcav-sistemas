/*
	SCRIPT PARA RETIRAR O ESTORNO DA COBRANÇA E RETORNAR O BOLETO REMOVIDO.

Autor: Gabriel S. Scalione
Data: 13/01/2015
*/
--SELECT * FROM LY_BOLETO WHERE NUMERO_RPS = 10001416

--No LYCEUM, verifique o número do boleto removido da cobrança estornada antes de executar os passos abaixo.
DECLARE @cobrança T_NUMERO
DECLARE @boleto	  T_NUMERO

SET @cobrança = 53995
SET @boleto	  = 52755

SELECT * FROM LY_COBRANCA WHERE COBRANCA = @cobrança
SELECT * FROM LY_BOLETO WHERE BOLETO = @boleto
SELECT * FROM VW_COBRANCA_BOLETO WHERE COBRANCA = @cobrança

--Remove o estorno da cobrança da LY_ITEM_LANC
delete LY_ITEM_LANC where COBRANCA = @cobrança and DESCRICAO LIKE 'Estorno%'

--Altera o valor do campo ITEM_ESTORNADO para NULL
UPDATE LY_ITEM_LANC SET ITEM_ESTORNADO = NULL WHERE COBRANCA = @cobrança

--Altera o estorno da cobrança para N e a data do estorno para NULL
update LY_COBRANCA
set
	ESTORNO = 'N',
	DT_ESTORNO = NULL
WHERE
	COBRANCA = @cobrança

--Altera para N o Boleto removido
UPDATE LY_BOLETO
SET
	REMOVIDO = 'N',
	DATA_REMOCAO = NULL
WHERE 
	BOLETO = @boleto

--Vincula o boleto a cobrança
UPDATE LY_ITEM_LANC 
SET
	BOLETO = @boleto
WHERE COBRANCA = @cobrança

--Remove o boleto da tabela boleto removido
DELETE LY_ITEM_BOLETO_REMOVIDO WHERE BOLETO = @boleto

SELECT * FROM VW_COBRANCA_BOLETO WHERE COBRANCA = @cobrança