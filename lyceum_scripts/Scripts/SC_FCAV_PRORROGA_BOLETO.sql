
/*

*/

USE LYCEUM
GO
/*
	select  cobranca, 
			BOLETO
	from	VW_COBRANCA_BOLETO 
	where	cobranca in (215525,215526)
		aluno in ('A202001542')
*/

DECLARE @boleto numeric

--Informe o código do boleto
SET @boleto = 201458    

select COBRANCA, BOLETO, ALUNO,ANO,MES,NUM_COBRANCA,convert(varchar, DATA_DE_VENCIMENTO,103) as DATA_DE_VENCIMENTO  from VW_COBRANCA_BOLETO where BOLETO = @boleto

update LY_COBRANCA 
set
	--Atualize a data de vencimento para a data que o financeiro informar.
	DATA_DE_VENCIMENTO = '2021-02-01 23:59:59.000'
where 
	cobranca in (select COBRANCA from VW_COBRANCA_BOLETO where BOLETO = @boleto)

select COBRANCA, BOLETO, ALUNO,ANO,MES,NUM_COBRANCA,convert(varchar, DATA_DE_VENCIMENTO,103) as DATA_DE_VENCIMENTO  from VW_COBRANCA_BOLETO where BOLETO = @boleto