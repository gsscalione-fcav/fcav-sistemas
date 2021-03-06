/*
	REMO�AO DOS DADOS DE RPS

	SELECT * FROM ly_boleto where boleto in (select distinct boleto from ly_item_lanc where aluno = 'A202000797')
	select * from vw_cobranca_boleto where cobranca = 208838
	select distinct cobranca, boleto from ly_item_lanc where aluno = 'A202100080'
*/



/******************
1 - Informe no parametro @boleto o n�mero do boleto

*******************/

DECLARE @boleto T_NUMERO

SET @boleto = 201071

	SELECT BOLETO,
		OBS ,
		NUMERO_RPS ,
		DATA_ENVIO_RPS ,
		VALOR_SERVICO_RPS ,
		VALOR_DEDUCAO_RPS ,
		NUMERO_NFE ,
		DATA_EMISSAO_NFE ,
		VALOR_ISS ,
		DATA_EMISSAO_RPS ,
		LINK_RPS ,
		NOTA_FISCAL_SERIE ,
		VALOR_DESCONTO_RPS ,
		COD_VERIFICACAO ,
		VALOR_PIS ,
		VALOR_COFINS ,
		VALOR_CSLL ,
		VALOR_IR ,
		VALOR_INSS ,
		DT_SOLICITA_CANCEL_RPS ,
		MOTIVO_CANCEL_RPS 
	into #tmp_boleto 
	FROM LY_BOLETO
	WHERE BOLETO in (@boleto)


UPDATE LY_BOLETO
SET
	OBS =					NULL
,	NUMERO_RPS =			NULL
,	DATA_ENVIO_RPS =		NULL
,	VALOR_SERVICO_RPS =		NULL
,	VALOR_DEDUCAO_RPS =		NULL
,	NUMERO_NFE =			NULL
,	DATA_EMISSAO_NFE =		NULL
,	VALOR_ISS =				NULL
,	DATA_EMISSAO_RPS =		NULL
,	LINK_RPS =				NULL
,	NOTA_FISCAL_SERIE =		NULL
,	VALOR_DESCONTO_RPS =	NULL
,	COD_VERIFICACAO =		NULL
,	VALOR_PIS =				NULL
,	VALOR_COFINS =			NULL
,	VALOR_CSLL =			NULL
,	VALOR_IR =				NULL
,	VALOR_INSS =			NULL
,	DT_SOLICITA_CANCEL_RPS = NULL
,	MOTIVO_CANCEL_RPS =		NULL
WHERE
	BOLETO = @boleto

-- Executar o passo 1 at� aqui !!!
--############################################

/**
Este passo s� utilizado se houver a necessidade do financeiro de utilizar a mesma RPS para outro boleto.
**/
	update #tmp_boleto
	set
		BOLETO = 200339

--- VOLTA COM OS DADOS DE RPS DO BOLETO ANTIGO
UPDATE LY_BOLETO
SET
	OBS =					t.OBS
,	NUMERO_RPS =			t.NUMERO_RPS
,	DATA_ENVIO_RPS =		t.DATA_ENVIO_RPS
,	VALOR_SERVICO_RPS =		t.VALOR_SERVICO_RPS
,	VALOR_DEDUCAO_RPS =		t.VALOR_DEDUCAO_RPS
,	NUMERO_NFE =			t.NUMERO_NFE
,	DATA_EMISSAO_NFE =		t.DATA_EMISSAO_NFE
,	VALOR_ISS =				t.VALOR_ISS
,	DATA_EMISSAO_RPS =		t.DATA_EMISSAO_RPS
,	LINK_RPS =				t.LINK_RPS
,	NOTA_FISCAL_SERIE =		t.NOTA_FISCAL_SERIE
,	VALOR_DESCONTO_RPS =	t.VALOR_DESCONTO_RPS
,	COD_VERIFICACAO =		t.COD_VERIFICACAO
,	VALOR_PIS =				t.VALOR_PIS
,	VALOR_COFINS =			t.VALOR_COFINS
,	VALOR_CSLL =			t.VALOR_CSLL
,	VALOR_IR =				t.VALOR_IR
,	VALOR_INSS =			t.VALOR_INSS
,	DT_SOLICITA_CANCEL_RPS = t.DT_SOLICITA_CANCEL_RPS
,	MOTIVO_CANCEL_RPS =		t.MOTIVO_CANCEL_RPS

from LY_BOLETO b
	inner join #tmp_boleto t
		on b.BOLETO = t.BOLETO

WHERE
	b.BOLETO = 200339

	SELECT BOLETO,
		OBS ,
		NUMERO_RPS ,
		DATA_ENVIO_RPS ,
		VALOR_SERVICO_RPS ,
		VALOR_DEDUCAO_RPS ,
		NUMERO_NFE ,
		DATA_EMISSAO_NFE ,
		VALOR_ISS ,
		DATA_EMISSAO_RPS ,
		LINK_RPS ,
		NOTA_FISCAL_SERIE ,
		VALOR_DESCONTO_RPS ,
		COD_VERIFICACAO ,
		VALOR_PIS ,
		VALOR_COFINS ,
		VALOR_CSLL ,
		VALOR_IR ,
		VALOR_INSS ,
		DT_SOLICITA_CANCEL_RPS ,
		MOTIVO_CANCEL_RPS  
	FROM LY_BOLETO
	WHERE BOLETO in (200339)