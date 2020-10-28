/*

SELECT * FROM ly_item_lanc WHERE  boleto = 192969 
aluno = 'A201902036'cobranca = 201306

*/

--tem que executar como usuário com privilegios administrativos

declare @data_emissao datetime,
		@num_boleto numeric

set @num_boleto = 193680

set @data_emissao = CONVERT(DATE, getdate(),102)


SELECT * FROM LY_BOLETO
WHERE BOLETO = @num_boleto

EXEC GERA_RPS @num_boleto,   
			  @data_emissao,   
			  'FCAV' ,   
			  'E', -- Só pode ser E (Empresa) ou U (Unidade)   
			  'C'    ,   
			  'Tipo Valor' ,   
			  'N' ,   
			  0.00,   
			  5762


SELECT BOLETO,
		NUMERO_RPS ,
		DATA_EMISSAO_RPS ,
		DATA_ENVIO_RPS ,
		VALOR_SERVICO_RPS ,
		VALOR_DEDUCAO_RPS ,
		NUMERO_NFE ,
		DATA_EMISSAO_NFE ,
		VALOR_ISS ,
		OBS ,
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
	WHERE 
		BOLETO = @num_boleto