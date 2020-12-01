--/*****************************************/
----APAGA ARRASTO DE BOLETO
--DELETE LY_LANC_CREDITO WHERE BOLETO = 42742 -- = '97837181003175'
--DELETE LY_ITEM_CRED WHERE LANC_CRED = 37547
--/*****************************************/


--Verificar se tem desconto válido na Dívida

--SELECT * FROM LY_LANC_DEBITO WHERE ALUNO = 'C202000129 '


/********************************************************************************
	VERIFICAR DESCONTO VÁLIDO NO PLANO DE PAGAMENTO
********************************************************************************/

DECLARE @ALUNO VARCHAR(20) = 'C202000032'

declare @lanc_debito numeric

--Verifica o código da dívida do aluno
select @lanc_debito = LANC_DEB from LY_LANC_DEBITO where ALUNO = @ALUNO

--Verifica quais são os descontos aplicados na dívida
select * 
from  LY_DESCONTO_DEBITO 
WHERE LANC_DEB  = @lanc_debito

--Verifica quais são as cobranças lançadas do aluno.
SELECT * 
FROM LY_ITEM_LANC 
WHERE COBRANCA IN (SELECT COBRANCA 
				   FROM LY_COBRANCA 
				   WHERE ALUNO = @ALUNO)

select * from LY_MATRICULA where ALUNO = @ALUNO

/********************************************************************************
Executar os 2 deletes abaixo, colocando o Lanc_deb da dívida estornada.
********************************************************************************/

DELETE LY_DESCONTO_DEBITO WHERE LANC_DEB in (SELECT LANC_DEB FROM LY_LANC_DEBITO WHERE ALUNO = @ALUNO) AND (MOTIVO_DESCONTO like '%Estorno%')


/********************************************************************************
Vincula a dívida novamente na matricula ou pre-matricula do aluno
********************************************************************************/

IF EXISTS (SELECT 1 FROM LY_MATRICULA where ALUNO = @ALUNO)
BEGIN
	UPDATE LY_MATRICULA 
	SET
		LANC_DEB = @lanc_debito
	WHERE
		ALUNO = @ALUNO
		and LANC_DEB is null

	select * from LY_MATRICULA where ALUNO = @ALUNO

END
ELSE
BEGIN
	UPDATE LY_PRE_MATRICULA
	SET
		LANC_DEB =  @lanc_debito
	WHERE
		ALUNO = @ALUNO
		and LANC_DEB is null

	select * from LY_PRE_MATRICULA where ALUNO = @ALUNO
END
--------------------------------------------------------------------------------------