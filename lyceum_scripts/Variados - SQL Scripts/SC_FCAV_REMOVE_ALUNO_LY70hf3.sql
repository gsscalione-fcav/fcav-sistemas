/*

Script para remover somente os dados de aluno, incluindo a parte financeira dele, permanecendo o dados de candidato e pessoa

EXEC PR_FCAV_CONSULTA_PESSOA NULL, NULL, NULL, '%gabriel.scalione@vanzolini.com.br%', NULL, NULL

select * from LY_ALUNO where pessoa = 111219

select * from LY_ALUNO where TURMA_PREF  = 'A-AT T 12'
SELECT 
	* FROM
	VW_FCAV_INI_FIM_CURSO_TURMA 
	WHERE TURMA = 'A-SRSC4 T 01'
delete LY_COMPRA_OFERTA where aluno = 'P201605014'

LY_AGREGA_ITEM_COBRANCA

*/

declare @aluno varchar(20)

set	@aluno = 'A202002383'


select * from LY_ALUNO where ALUNO = @aluno

--------------------------------------------------------------------------

	/*A tabela LY_MOVIMENTO_TEMPORAL é uma tabela que o Argyros utiliza*/
	DELETE LY_MOVIMENTO_TEMPORAL WHERE CAST(ID1 AS NUMERIC) in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)) AND ENTIDADE = 'LY_ITEM_LANC'
    DELETE LY_MOVIMENTO_TEMPORAL WHERE CAST(ID1 AS NUMERIC) in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)) AND ENTIDADE = 'LY_ITEM_CRED'
	PRINT '### Dados da Tabela LY_MOVIMENTO_TEMPORAL apagados'
	PRINT '----------------------------------------------'
		
	/*01*/delete LY_CAR where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_CAR apagados'
	PRINT '----------------------------------------------'
	
	/*02*/delete LY_ENCARGOS_COB_GERADO where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_ENCARGOS_COB_GERADO apagados'
	PRINT '----------------------------------------------'
	
	/*03*/delete LY_ITEM_LANC where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_ITEM_LANC apagados'
	PRINT '----------------------------------------------'
	
	/*04*/delete LY_ITEM_BOLETO_REMOVIDO where BOLETO in (SELECT BOLETO FROM LY_BOLETO where RESP in (SELECT RESP FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)))
	PRINT '### Dados da Tabela LY_ITEM_BOLETO_REMOVIDO apagados'
	PRINT '----------------------------------------------'
	
	/*05*/delete LY_ITEM_CRED where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_ITEM_CRED apagados'
	PRINT '----------------------------------------------'
	
	/*06*/delete LY_DESCONTO_COBRANCA where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_DESCONTO_COBRANCA apagados'
	PRINT '----------------------------------------------'
	
	/*07*/delete LY_DESCONTO_DEBITO where LANC_DEB in (SELECT LANC_DEB FROM LY_LANC_DEBITO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_DESCONTO_DEBITO apagados'
	PRINT '----------------------------------------------'	
	

	/*08*/delete LY_BOLSA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_BOLSA apagados'
	PRINT '----------------------------------------------'
	
	delete LY_PEDIDO_PGTO_COBRANCAS where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	
	/*10*/delete LY_PLANO_ESP_PARC where LANC_DEB in (SELECT LANC_DEB FROM LY_LANC_DEBITO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_PLANO_ESP_PARC apagados'
	PRINT '----------------------------------------------'
	
	/*10*/delete LY_PLANO_PGTO_ESPECIAL where LANC_DEB in (SELECT LANC_DEB FROM LY_LANC_DEBITO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_PLANO_PGTO_ESPECIAL apagados'
	PRINT '----------------------------------------------'
	
	/*09*/delete LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_COBRANCA apagados'
	PRINT '----------------------------------------------'	

	PRINT 'TODOS OS DADOS DE COBRANÇA DO ALUNO FORAM APAGADOS'

	/*123*/delete LY_EMAIL_LOTE_DEST where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_EMAIL_LOTE_DEST apagados'
	PRINT '----------------------------------------------'	


	/*123*/delete LY_ITENS_SOLICIT_SERV where SOLICITACAO in(select SOLICITACAO from LY_SOLICITACAO_SERV where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_SOLICITACAO_SERV apagados'
	PRINT '----------------------------------------------'	


	/*123*/delete LY_H_CURR_ALUNO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_H_CURR_ALUNO apagados'
	PRINT '----------------------------------------------'	


	/*123*/delete LY_SOLICITACAO_SERV where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_SOLICITACAO_SERV apagados'
	PRINT '----------------------------------------------'	

	/*123*/delete LY_COMPRA_OFERTA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_COBRANCA apagados'
	PRINT '----------------------------------------------'	

	/*08*/delete LY_TURMA_TRANSF where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_TURMA_TRANSF apagados'
	PRINT '----------------------------------------------'

	/*11*/delete LY_TRANC_INTERV_DATA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_MATRICULA apagados'
	PRINT '----------------------------------------------'

	/*08*/delete LY_PRE_MATRICULA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_PRE_MATRICULA apagados'
	PRINT '----------------------------------------------'

	/*11*/delete LY_MATRICULA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_MATRICULA apagados'
	PRINT '----------------------------------------------'
	
	/*12*/delete LY_LANC_DEBITO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_LANC_DEBITO apagados'
	PRINT '----------------------------------------------'

	/*02*/delete LY_DADOS_HIST where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_HIST_INSCRONLINE apagados'	
	PRINT '----------------------------------------------'

	/*02*/delete LY_FL_ALUNO where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_HIST_INSCRONLINE apagados'	
	PRINT '----------------------------------------------'
	
	/*01*/delete LY_HIST_INSCRONLINE_DISC where ID_HIST_INSCRONLINE in (SELECT ID_HIST_INSCRONLINE FROM LY_HIST_INSCRONLINE where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_HIST_INSCRONLINE_DISC apagados'
	PRINT '----------------------------------------------'
	
	/*02*/delete LY_HIST_INSCRONLINE where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_HIST_INSCRONLINE apagados'	
	PRINT '----------------------------------------------'
	
	/*03*/delete LY_CONTRATO_REMOVIDO where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_CONTRATO_REMOVIDO apagados'
	PRINT '----------------------------------------------'
	
	/*04*/delete LY_CONTR_ALU_IMG_REMOV where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_CONTR_ALU_IMG_REMOV apagados'
	PRINT '----------------------------------------------'
	
	/*05*/delete LY_CONTRATO_ALUNO_IMG where ID_CONTRATO_ALUNO in (SELECT ID_CONTRATO_ALUNO FROM LY_CONTRATO_ALUNO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno))
	PRINT '### Dados da Tabela LY_CONTRATO_ALUNO_IMG apagados'
	PRINT '----------------------------------------------'
	
	/*06*/delete LY_CONTRATO_ALUNO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_CONTRATO_ALUNO apagados'	
	PRINT '----------------------------------------------'
	
	/*07*/delete LY_DADOS_VESTIBULAR where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_DADOS_VESTIBULAR apagados'
	PRINT '----------------------------------------------'
	
	/*08*/delete LY_H_CURSOS_CONCL where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_H_CURSOS_CONCL apagados'
	PRINT '----------------------------------------------'
	
	/*09*/delete LY_MATRICULA_DOCALU where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_MATRICULA_DOCALU apagados'
	PRINT '----------------------------------------------'
	
	/*10*/delete LY_PLANO_PGTO_PERIODO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_PLANO_PGTO_PERIODO apagados'
	PRINT '----------------------------------------------'
	
	/*11*/delete LY_ALUNO_MATRICULA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_ALUNO_MATRICULA apagados'
	PRINT '----------------------------------------------'
	
	/*12*/delete LY_COMP_IMAGEM where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_COMP_IMAGEM apagados'
	PRINT '----------------------------------------------'
	
	/*13*/delete LY_LOG_CONEXOES where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_LOG_CONEXOES apagados'
	PRINT '----------------------------------------------'
	
	/*14*/delete LY_ALUNO_DOC_INGRESSO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where ALUNO = @aluno)
	PRINT '### Dados da Tabela LY_ALUNO_DOC_INGRESSO apagados'
	PRINT '----------------------------------------------'
	
	/*15*/delete LY_ALUNO where ALUNO = @aluno
	PRINT '### Dados da Tabela LY_ALUNO apagados'
	PRINT '----------------------------------------------'
	
	
	PRINT 'TODOS OS DADOS ACADEMICOS DO ALUNO FORAM APAGADOS'	
	
select * from LY_ALUNO where ALUNO = @aluno