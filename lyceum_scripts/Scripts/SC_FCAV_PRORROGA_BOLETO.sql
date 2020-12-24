
/*

*/

USE LYCEUM
GO
/*
	select  cobranca, 
			BOLETO
	from	VW_COBRANCA_BOLETO 
	where	cobranca in (214909  )
		aluno in ('A202001542')
*/

DECLARE @boleto numeric

SET @boleto = 200919    

select COBRANCA, BOLETO, ALUNO,ANO,MES,NUM_COBRANCA,convert(varchar, DATA_DE_VENCIMENTO,103) as DATA_DE_VENCIMENTO  from VW_COBRANCA_BOLETO where BOLETO = @boleto

update LY_COBRANCA 
set
	DATA_DE_VENCIMENTO = '2021-01-11 23:59:59.000'
where cobranca in (select COBRANCA from VW_COBRANCA_BOLETO where BOLETO = @boleto)

select COBRANCA, BOLETO, ALUNO,ANO,MES,NUM_COBRANCA,convert(varchar, DATA_DE_VENCIMENTO,103) as DATA_DE_VENCIMENTO  from VW_COBRANCA_BOLETO where BOLETO = @boleto