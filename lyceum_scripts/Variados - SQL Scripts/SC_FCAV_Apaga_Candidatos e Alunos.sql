/*

SELECT * FROM ly_candidato WHERE CONCURSO = 'CEGP T 72'

/*PESSOA -*/ EXEC PR_FCAV_CONSULTA_PESSOA null,'Anderson Martin Bernardes%',NULL,NULL,NULL,NULL
/*CANDIDATO	 -*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL,NULL,NULL,NULL,'201700404',null


select * from vw_fcav_ini_fim_curso_turma where turma in ('CEGP T 67')

select * from ly_candidato where NOME_COMPL like 'Gabriel Serrano Scalione%'
select * from VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA where NOME_COMPL like 'Renata Ferrari Pinto%'aluno = 'C201700045'
exec PR_FCAV_RESET_SENHA_CANDIDATO 105041,null

select * from fcav_candidatos where candidato = '201910026'

*/


declare @pessoa varchar(20)declare @candidato varchar(20)declare @concurso varchar(20)
declare @validapessoa varchar(1)declare @validacandidato varchar(1) declare @validaaluno varchar(1)		
declare @validafinanceiro varchar(1)

set @candidato = '202100646'-- '201720339'	-- Digite o candidato e abaixo valide se o script irá apagar o candidato e aluno ou somente o aluno.
set @concurso  =  'CCUPON T 33'--'CEGP T 67'	-- Digite o concurso do candidato.


-- Para apagar a pessoa altere o valor para 'S'
set @validapessoa	 = 'N'
-- Para apagar o candidato altere o valor para 'S'
set @validacandidato = 'N'
-- Para apagar o aluno altere o valor para 'S'
set @validaaluno = 'S'
-- Para apagar as cobranças do aluno altere o valor para 'S'. Não removi as Dívidas geradas, somentes as cobranças e plano de pagamento.
set @validafinanceiro = 'S'


----------------------------------------------------------------------------------
/*candidato		-*/
SELECT
	ca.DT_INSCRICAO,
	PE.PESSOA,
	PE.NOME_COMPL,
	PE.E_MAIL,
	DBO.DECRYPT(PE.SENHA_TAC) SENHA,
	CA.CANDIDATO,
	CA.CONCURSO,
	CA.SIT_CANDIDATO_VEST,
	AL.ALUNO,
	AL.CURSO,
	AL.TURNO,
	AL.CURRICULO,
	AL.ANO_INGRESSO,
	AL.SEM_INGRESSO,
	TURMA_PREF
	
FROM
	LY_CANDIDATO CA 
	INNER JOIN LY_PESSOA PE ON PE.PESSOA = CA.PESSOA
	LEFT JOIN LY_ALUNO AL ON AL.CANDIDATO = CA.CANDIDATO AND AL.CONCURSO = CA.CONCURSO
WHERE CA.CANDIDATO = @candidato
----------------------------------------------------------------------------------

--A VARIÁVEL @pessoa recebe o código PESSOA da LY_CANDIDATO
SELECT @pessoa = PESSOA FROM LY_CANDIDATO where CANDIDATO = @candidato and CONCURSO = @concurso

--------------------------------------------------------------------------
--BLOCO PARA APAGAR AS DIVIDAS DO ALUNO
IF (@validafinanceiro = 'S')
BEGIN

	delete LY_PEDIDO_PGTO_COBRANCAS where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))

	/*A tabela LY_MOVIMENTO_TEMPORAL é uma tabela que o Argyros utiliza*/
	DELETE LY_MOVIMENTO_TEMPORAL WHERE CAST(ID1 AS NUMERIC) in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)) AND ENTIDADE = 'LY_ITEM_LANC'
    DELETE LY_MOVIMENTO_TEMPORAL WHERE CAST(ID1 AS NUMERIC) in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)) AND ENTIDADE = 'LY_ITEM_CRED'
	PRINT '### Dados da Tabela LY_MOVIMENTO_TEMPORAL apagados'
	PRINT '----------------------------------------------'
		
	/*01*/delete LY_CAR where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_CAR apagados'
	PRINT '----------------------------------------------'
	
	/*02*/delete LY_ENCARGOS_COB_GERADO where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_ENCARGOS_COB_GERADO apagados'
	PRINT '----------------------------------------------'
	
	/*03*/delete LY_ITEM_LANC where BOLETO in (SELECT BOLETO FROM VW_COBRANCA_BOLETO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_ITEM_LANC apagados'
	PRINT '----------------------------------------------'


	/*03*/delete LY_ITEM_LANC where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_ITEM_LANC apagados'
	PRINT '----------------------------------------------'
	
	/*04*/delete LY_ITEM_BOLETO_REMOVIDO where BOLETO in (SELECT BOLETO FROM LY_BOLETO where RESP in (SELECT RESP FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)))
	PRINT '### Dados da Tabela LY_ITEM_BOLETO_REMOVIDO apagados'
	PRINT '----------------------------------------------'
	
	DELETE LY_BOLETO where BOLETO in (SELECT BOLETO FROM VW_COBRANCA_BOLETO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO =  @concurso))
	PRINT '### Dados da Tabela LY_BOLETO apagados'
	PRINT '----------------------------------------------'
	
	/*05*/delete LY_ITEM_CRED where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_ITEM_CRED apagados'
	PRINT '----------------------------------------------'
	
	/*06*/delete LY_DESCONTO_COBRANCA where COBRANCA in (SELECT COBRANCA FROM LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_DESCONTO_COBRANCA apagados'
	PRINT '----------------------------------------------'
	
	/*07*/delete LY_ACORDO where LANC_DEB in (SELECT LANC_DEB FROM LY_LANC_DEBITO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_ACORDO apagados'
	PRINT '----------------------------------------------'	
	
	/*07*/delete LY_DESCONTO_DEBITO where LANC_DEB in (SELECT LANC_DEB FROM LY_LANC_DEBITO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_DESCONTO_DEBITO apagados'
	PRINT '----------------------------------------------'	
	
	/*08*/delete LY_BOLSA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_BOLSA apagados'
	PRINT '----------------------------------------------'
	
	/*10*/delete LY_PLANO_PGTO_ESPECIAL where LANC_DEB in (SELECT LANC_DEB FROM LY_LANC_DEBITO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_PLANO_PGTO_ESPECIAL apagados'
	PRINT '----------------------------------------------'
	
	/*09*/delete LY_COBRANCA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_COBRANCA apagados'
	PRINT '----------------------------------------------'	

	PRINT 'TODOS OS DADOS DE COBRANÇA DO ALUNO FORAM APAGADOS'
END

---------------------------------------------------------------------------
--BLOCO PARA APAGAR O ALUNO
IF (@validaaluno = 'S')
BEGIN
	/*08*/delete LY_AVISO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_EMAIL_LOTE_DEST apagados'
	PRINT '----------------------------------------------'
	

	/*08*/delete LY_EMAIL_LOTE_DEST where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_EMAIL_LOTE_DEST apagados'
	PRINT '----------------------------------------------'

	/*08*/delete LY_TURMA_TRANSF where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_TURMA_TRANSF apagados'
	PRINT '----------------------------------------------'

	/*08*/delete LY_PRE_MATRICULA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_PRE_MATRICULA apagados'
	PRINT '----------------------------------------------'

	/*11*/delete LY_MATRICULA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_MATRICULA apagados'
	PRINT '----------------------------------------------'
	
	/*12*/delete LY_LANC_DEBITO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_LANC_DEBITO apagados'
	PRINT '----------------------------------------------'
	
	/*12*/delete LY_COMPRA_OFERTA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_LANC_DEBITO apagados'
	PRINT '----------------------------------------------'
	
	/*08*/delete LY_ANDAMENTO WHERE SOLICITACAO IN (SELECT SOLICITACAO FROM LY_SOLICITACAO_SERV where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_ANDAMENTO apagados'
	PRINT '----------------------------------------------'
	
	/*08*/delete LY_ITENS_SOLICIT_SERV WHERE SOLICITACAO IN (SELECT SOLICITACAO FROM LY_SOLICITACAO_SERV where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_ITENS_SOLICIT_SERV apagados'
	PRINT '----------------------------------------------'
	
	/*08*/delete LY_SOLICITACAO_SERV where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_SOLICITACAO_SERV apagados'
	PRINT '----------------------------------------------'
	
	/*08*/delete LY_NOTA_HISTMATR where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_NOTA_HISTMATR apagados'
	PRINT '----------------------------------------------'
	
	/*08*/delete LY_HISTORICO_DOCENTE where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_HISTORICO_DOCENTE apagados'
	PRINT '----------------------------------------------'

	/*08*/delete LY_HISTMATRICULA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_HISTMATRICULA apagados'
	PRINT '----------------------------------------------'

	/*08*/delete LY_HIST_FACULDADE where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_HIST_FACULDADE apagados'
	PRINT '----------------------------------------------'

	/*01*/delete LY_HIST_INSCRONLINE_DISC where ID_HIST_INSCRONLINE in (SELECT ID_HIST_INSCRONLINE FROM LY_HIST_INSCRONLINE where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_HIST_INSCRONLINE_DISC apagados'
	PRINT '----------------------------------------------'
	
	/*02*/delete LY_HIST_INSCRONLINE where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_HIST_INSCRONLINE apagados'	
	PRINT '----------------------------------------------'
	
	/*03*/delete LY_CONTRATO_REMOVIDO where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_CONTRATO_REMOVIDO apagados'
	PRINT '----------------------------------------------'
	
	/*04*/delete LY_CONTR_ALU_IMG_REMOV where ALUNO in  (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_CONTR_ALU_IMG_REMOV apagados'
	PRINT '----------------------------------------------'
	
	/*05*/delete LY_CONTRATO_ALUNO_IMG where ID_CONTRATO_ALUNO in (SELECT ID_CONTRATO_ALUNO FROM LY_CONTRATO_ALUNO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso))
	PRINT '### Dados da Tabela LY_CONTRATO_ALUNO_IMG apagados'
	PRINT '----------------------------------------------'
	
	/*06*/delete LY_CONTRATO_ALUNO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_CONTRATO_ALUNO apagados'	
	PRINT '----------------------------------------------'
	
	/*07*/delete LY_DADOS_VESTIBULAR where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_DADOS_VESTIBULAR apagados'
	PRINT '----------------------------------------------'
	
	/*08*/delete LY_H_CURSOS_CONCL where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_H_CURSOS_CONCL apagados'
	PRINT '----------------------------------------------'
	
	/*09*/delete LY_MATRICULA_DOCALU where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_MATRICULA_DOCALU apagados'
	PRINT '----------------------------------------------'
	
	/*10*/delete LY_PLANO_PGTO_PERIODO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_PLANO_PGTO_PERIODO apagados'
	PRINT '----------------------------------------------'
	
	/*11*/delete LY_ALUNO_MATRICULA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_ALUNO_MATRICULA apagados'
	PRINT '----------------------------------------------'
	
	/*12*/delete LY_COMP_IMAGEM where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_COMP_IMAGEM apagados'
	PRINT '----------------------------------------------'
	
	/*13*/delete LY_LOG_CONEXOES where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_LOG_CONEXOES apagados'
	PRINT '----------------------------------------------'
	
	/*14*/delete LY_COMP_LISTA where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_COMP_LISTA apagados'
	PRINT '----------------------------------------------'

	/*14*/delete LY_ALUNO_DOC_INGRESSO where ALUNO in (SELECT ALUNO FROM LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_ALUNO_DOC_INGRESSO apagados'
	PRINT '----------------------------------------------'
	
	/*15*/delete LY_ALUNO where CANDIDATO in (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_ALUNO apagados'
	PRINT '----------------------------------------------'
	
	/*16*/DELETE LY_ACEITE_PREMAT_IMG WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_ACEITE_PREMAT_IMG apagados'	
	PRINT '----------------------------------------------'
	
	/*17*/DELETE LY_ACEITE_PREMAT_INSTR WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_ACEITE_PREMAT_INSTR apagados'	
	PRINT '----------------------------------------------'
	
	--altera a coluna matriculado para N, assim é possível realizar a pré-matricula
	
	UPDATE LY_CONVOCADOS_VEST 
	SET
		MATRICULADO = 'N'
	WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_CONVOCADOS_VEST Alterado'	
	PRINT '----------------------------------------------'
	
	PRINT 'TODOS OS DADOS ACADEMICOS DO ALUNO FORAM APAGADOS'	
END

---------------------------------------------------------------------------
--BLOCO PARA APAGAR O CANDIDATO
IF(@validacandidato = 'S')
BEGIN

	PRINT '----------------------------------------------'
	/*01*/DELETE LY_CONVOCADOS_VEST WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_CONVOCADOS_VEST apagados'
	PRINT '----------------------------------------------'
	
	/*02*/DELETE LY_NOTAS_VEST WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_NOTAS_VEST apagados'
	PRINT '----------------------------------------------'
	
	/*03*/DELETE LY_PARTICIPACAO_QUEST WHERE CODIGO IN (SELECT CODIGO FROM LY_AVALIADOR WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_PARTICIPACAO_QUEST apagados'
	PRINT '----------------------------------------------'
	
	/*04*/DELETE LY_RESPOSTA WHERE AVA_CODIGO IN (SELECT CODIGO FROM LY_AVALIADOR WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso)
	PRINT '### Dados da Tabela LY_RESPOSTA apagados'
	PRINT '----------------------------------------------'
	
	/*05*/DELETE LY_AVALIADOR WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_AVALIADOR apagados'
	PRINT '----------------------------------------------'
	
	/*06*/DELETE LY_OPCOES_PROC_SELETIVO WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_OPCOES_PROC_SELETIVO apagados'
	PRINT '----------------------------------------------'
	
	/*07*/DELETE FCAV_CANDIDATOS WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_OPCOES_PROC_SELETIVO apagados'
	PRINT '----------------------------------------------'
		
	/*08*/DELETE LY_CANDIDATO WHERE CANDIDATO IN (@candidato)and CONCURSO = @concurso
	PRINT '### Dados da Tabela LY_CANDIDATO apagados'
	PRINT '----------------------------------------------'
	
	PRINT 'TODOS OS DADOS DO CANDIDATO FORAM APAGADOS'	
END

---------------------------------------------------------------------------
--BLOCO PARA APAGAR A PESSOA
IF(@validapessoa = 'S')
BEGIN

	/*07*/DELETE LY_MINI_CURRICULO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_MINI_CURRICULO apagados'
	PRINT '----------------------------------------------'

	PRINT '----------------------------------------------'
	/*01*/DELETE LY_PROSPECTO_CAPTACAO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_CONVOCADOS_VEST apagados'
	PRINT '----------------------------------------------'
	
	PRINT '----------------------------------------------'
	/*01*/DELETE LY_ITEM_BOLETO_REMOVIDO WHERE BOLETO IN (SELECT BOLETO FROM LY_BOLETO WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))))
	PRINT '### Dados da Tabela LY_ITEM_BOLETO_REMOVIDO apagados'
	PRINT '----------------------------------------------'
	
	/*02*/DELETE LY_BOLETO WHERE RESP IN (SELECT RESP FROM LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_BOLETO apagados'
	PRINT '----------------------------------------------'
	
	/*03*/DELETE LY_PROSPECTO_OPCOES WHERE ID_PROSPECTO in (SELECT ID_PROSPECTO FROM LY_PROSPECTO WHERE PESSOA in (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)))
	PRINT '### Dados da Tabela LY_PROSPECTO_OPCOES apagados'
	PRINT '----------------------------------------------'
	
	/*04*/DELETE LY_PROSPECTO WHERE PESSOA in (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_PROSPECTO apagados'
	PRINT '----------------------------------------------'
	
	
	/*05*/DELETE LY_PESSOA_PUBLICACAO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_RESP_FINAN apagados'
	PRINT '----------------------------------------------'
	
	
	/*05*/DELETE LY_RESP_FINAN WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_RESP_FINAN apagados'
	PRINT '----------------------------------------------'
	
	/*06*/DELETE LY_ENVIO_EMAIL WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_ENVIO_EMAIL apagados'
	PRINT '----------------------------------------------'
	
	/*07*/DELETE LY_MINI_CURRICULO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_MINI_CURRICULO apagados'
	PRINT '----------------------------------------------'
	
	/*08*/DELETE LY_FL_PESSOA WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_FL_PESSOA apagados'
	PRINT '----------------------------------------------'
	
	/*09*/DELETE LY_TRABALHO WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa)) 
	PRINT '### Dados da Tabela LY_TRABALHO apagados'
	PRINT '----------------------------------------------'
	
	/*10*/DELETE LY_DOCENTE WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_DOCENTE apagados'
	PRINT '----------------------------------------------'

	/*10*/DELETE LY_VOUCHER WHERE PESSOA IN (SELECT PESSOA FROM LY_PESSOA WHERE PESSOA IN (@pessoa))
	PRINT '### Dados da Tabela LY_DOCENTE apagados'
	PRINT '----------------------------------------------'
	
	/*11*/DELETE LY_PESSOA WHERE PESSOA IN (@pessoa)
	PRINT '### Dados da Tabela LY_PESSOA apagados'
	PRINT '----------------------------------------------'
	
	PRINT 'TODOS OS DADOS DA PESSOA FORAM APAGADOS'
END

----------------------------------------------------------------------------------
/*candidato		-*/
SELECT
	ca.DT_INSCRICAO,
	PE.PESSOA,
	PE.NOME_COMPL,
	PE.E_MAIL,
	DBO.DECRYPT(PE.SENHA_TAC) SENHA,
	CA.CANDIDATO,
	CA.CONCURSO,
	CA.SIT_CANDIDATO_VEST,
	AL.ALUNO,
	AL.CURSO,
	AL.TURNO,
	AL.CURRICULO,
	AL.ANO_INGRESSO,
	AL.SEM_INGRESSO
	
FROM
	LY_CANDIDATO CA 
	INNER JOIN LY_PESSOA PE ON PE.PESSOA = CA.PESSOA
	LEFT JOIN LY_ALUNO AL ON AL.CANDIDATO = CA.CANDIDATO AND AL.CONCURSO = CA.CONCURSO
WHERE CA.CANDIDATO = @candidato
----------------------------------------------------------------------------------