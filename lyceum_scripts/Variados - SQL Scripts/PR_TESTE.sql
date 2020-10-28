drop procedure PR_TESTE
ALTER PROCEDURE PR_TESTE(
    @OFERTA_DE_CURSO INT, @Enviar varchar)
 AS
 
    DECLARE @assunto VARCHAR(100)
	DECLARE @texto VARCHAR (8000)
	
 
	if @Enviar = 'S' AND @OFERTA_DE_CURSO IS NOT NULL
	begin
	
		SET @Enviar = 'N'
		
		SET @assunto = 'TESTE DE ENVIO DE E-MAIL FINANCEIRO'
		
		SELECT 	@texto = 
		'Teste de envio de e-mail, utilizando o botão <b>Enviar Formulário para o Financeiro</b>
			<BR>
		<ul>
		<li> Nome do Curso:  <b>'+ISNULL(CURSO,' - ')+'</b>
		<li> Turma:  <b>'+ISNULL(TURMA_PREF,' - ')+'</b>
		<li> Local do curso:  <b>'+ISNULL(UNIDADE_FISICA,' - ')+'</b>
		<li> Curriculo Vigente:  <b>'+ISNULL(CURRICULO,' - ')+'</b>
		<li> Turno da Turma:  <b>'+ISNULL(TURNO,' - ')+'</b>
		<li> Oferta de Curso:  <b>'+ISNULL(DESCRICAO_COMPL,' - ')+'</b>
		</ul>

		<BR>'
		FROM LY_OFERTA_CURSO
		WHERE oferta_de_curso = @OFERTA_DE_CURSO
		
		SELECT 1 AS VALOR
		
	    EXEC
		MSDB.dbo.SP_SEND_DBMAIL
        @PROFILE_NAME =
            -- Desenvolvimento/homologação
            FCAV_HOMOLOGACAO,
            -- Produção
            --VANZOLINI_BD,
        @RECIPIENTS = 'joao.neves@vanzolini.org.br; gabriel.scalione@vanzolini.org.br; mvaraujo@vanzolini-ead.org.br; ecampos@vanzolini-ead.org.br',
       -- @copy_recipients = @encaminha_email,
        @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',
        @SUBJECT = @assunto,
        @BODY = @texto,
        @BODY_FORMAT = HTML
        
	
	end
	if @Enviar = 'N'
	begin
		select 5 as valor
	end
	ELSE
	begin
		select 3 as valor
	end
	
	

