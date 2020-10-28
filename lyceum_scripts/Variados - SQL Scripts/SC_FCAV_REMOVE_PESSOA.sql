/*
/*cpf			-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL, '%Jonas%Tavares%Noronha%', NULL, NULL, NULL, NULL

SELECT * FROM LY_PESSOA where cpf ='20097531863'

--EXEC PR_FCAV_RESET_SENHA_CANDIDATO 106159,NULL
*/


DECLARE @pessoa NUMERIC
DECLARE @nome_pessoa VARCHAR(100)


SET @pessoa = 100630 --DIGITE O CÓDIGO DA PESSOA

SELECT @nome_pessoa = NOME_COMPL FROM LY_PESSOA WHERE PESSOA = @pessoa

delete LY_ITEM_CRED WHERE COBRANCA IN (SELECT COBRANCA  FROM LY_COBRANCA WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))))

EXEC PR_FCAV_CONSULTA_PESSOA @pessoa, NULL, NULL, NULL, NULL, NULL


	PRINT '----------------------------------------------'
	/*01*/DELETE LY_ALERTA_RELAC WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_ALERTA_RELAC apagados'
	PRINT '----------------------------------------------'

	PRINT '----------------------------------------------'
	/*01*/DELETE LY_ITEM_BOLETO_REMOVIDO WHERE BOLETO IN (SELECT BOLETO FROM LY_BOLETO WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))))
	PRINT '### Dados da Tabela LY_ITEM_BOLETO_REMOVIDO apagados'
	PRINT '----------------------------------------------'
	
	PRINT '----------------------------------------------'
	/*01*/DELETE LY_LANC_CREDITO WHERE BOLETO IN (SELECT BOLETO FROM LY_BOLETO WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))))
	PRINT '### Dados da Tabela LY_LANC_CREDITO apagados'
	PRINT '----------------------------------------------'
	
	PRINT '----------------------------------------------'
	/*01*/DELETE LY_LANC_CREDITO WHERE RESP in (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_LANC_CREDITO apagados'
	PRINT '----------------------------------------------'

	/*02*/DELETE LY_BOLETO WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_BOLETO apagados'
	PRINT '----------------------------------------------'
	
	/*03*/DELETE LY_PROSPECTO_CAPTACAO WHERE PESSOA in (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_PROSPECTO_OPCOES apagados'
	PRINT '----------------------------------------------'
		
	/*03*/DELETE LY_PROSPECTO_OPCOES WHERE ID_PROSPECTO in (SELECT ID_PROSPECTO FROM LY_PROSPECTO WHERE PESSOA in (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_PROSPECTO_OPCOES apagados'
	PRINT '----------------------------------------------'
	
	/*04*/DELETE LY_PROSPECTO WHERE PESSOA in (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_PROSPECTO apagados'
	PRINT '----------------------------------------------'
	

	/*05*/DELETE LY_PESSOA_PUBLICACAO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_PESSOA_PUBLICACAO apagados'
	PRINT '----------------------------------------------'
	
	/*06*/DELETE LY_ITEM_LANC WHERE COBRANCA IN (SELECT COBRANCA  FROM LY_COBRANCA WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))))
	PRINT '### Dados da Tabela LY_ITEM_LANC apagados'
	PRINT '----------------------------------------------'
	/*06*/DELETE LY_ITEM_CRED WHERE COBRANCA IN (SELECT COBRANCA  FROM LY_COBRANCA WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))))
	PRINT '### Dados da Tabela LY_ITEM_CRED apagados'
	PRINT '----------------------------------------------'
	/*06*/DELETE LY_ENCARGOS_COB_GERADO WHERE COBRANCA IN (SELECT COBRANCA  FROM LY_COBRANCA WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))))
	PRINT '### Dados da Tabela LY_ENCARGOS_COB_GERADO apagados'
	PRINT '----------------------------------------------'
	
	/*06*/DELETE LY_COBRANCA WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_RESP_FINAN apagados'
	PRINT '----------------------------------------------'
	
	/*06*/DELETE LY_PLANO_PGTO_PERIODO WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_RESP_FINAN apagados'
	PRINT '----------------------------------------------'
	
	/*06*/DELETE LY_DESCONTO_DEBITO WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_RESP_FINAN apagados'
	PRINT '----------------------------------------------'
	
	/*06*/DELETE LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_RESP_FINAN apagados'
	PRINT '----------------------------------------------'
	
	/*07*/DELETE LY_ENVIO_EMAIL WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_ENVIO_EMAIL apagados'
	PRINT '----------------------------------------------'
	
	--/*07*/DELETE LY_PROSPECTO_CARRINHO WHERE ID_PROSPECTO_CAPTACAO IN(SELECT ID_PROSPECTO_CAPTACAO FROM LY_PROSPECTO_CAPTACAO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	--PRINT '### Dados da Tabela LY_PROSPECTO_CARRINHO apagados'
	--PRINT '----------------------------------------------'
	
	--/*07*/DELETE LY_HIST_PROSPECTO_CARRINHO WHERE ID_PROSPECTO_CAPTACAO IN(SELECT ID_PROSPECTO_CAPTACAO FROM LY_PROSPECTO_CAPTACAO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	--PRINT '### Dados da Tabela LY_HIST_PROSPECTO_CARRINHO apagados'
	--PRINT '----------------------------------------------'
	
		
	--/*07*/DELETE LY_PROSPECTO_CAPTACAO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	--PRINT '### Dados da Tabela LY_PROSPECTO_CAPTACAO apagados'
	--PRINT '----------------------------------------------'
	
	
	/*08*/DELETE LY_MINI_CURRICULO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_MINI_CURRICULO apagados'
	PRINT '----------------------------------------------'
	
	/*09*/DELETE LY_FL_PESSOA WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_FL_PESSOA apagados'
	PRINT '----------------------------------------------'
	
	/*10*/DELETE LY_TRABALHO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)) 
	PRINT '### Dados da Tabela LY_TRABALHO apagados'
	PRINT '----------------------------------------------'
	
	/*11*/DELETE LY_HISTORICO_DOCENTE WHERE NUM_FUNC IN (SELECT NUM_FUNC FROM LY_DOCENTE WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_DOCENTE apagados'
	
	/*12*/DELETE LY_DOCENTE WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_DOCENTE apagados'
	PRINT '----------------------------------------------'
	
	/*12*/DELETE LY_COMPRA_OFERTA WHERE ID_VOUCHER IN (SELECT ID_VOUCHER FROM LY_VOUCHER WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_DOCENTE apagados'
	PRINT '----------------------------------------------'

	/*13*/DELETE LY_VOUCHER WHERE PESSOA IN (73)
	PRINT '### Dados da Tabela LY_VOUCHER apagados'
	PRINT '----------------------------------------------'
		
	/*13*/DELETE LY_EMAIL_LOTE_DEST WHERE PESSOA IN (@pessoa)
	PRINT '### Dados da Tabela LY_EMAIL_LOTE_DEST apagados'
	PRINT '----------------------------------------------'
	
	/*13*/DELETE LY_RESET_SENHA WHERE PESSOA IN (@pessoa)
	PRINT '### Dados da Tabela LY_RESET_SENHA apagados'
	PRINT '----------------------------------------------'	
	
	/*13*/DELETE LY_PESSOA WHERE PESSOA IN (@pessoa)
	PRINT '### Dados da Tabela LY_PESSOA apagados'
	PRINT '----------------------------------------------'
	
	PRINT 'TODOS OS DADOS DA PESSOA FORAM APAGADOS'
	
