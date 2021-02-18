USE LYCEUM_MEDIA
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Gabriel Scalione
-- Create date: 2020-11-18
-- Description:	Trigger para disponibilizar o link do certificado na página de aviso na Central do Aluno.
-- =============================================
ALTER TRIGGER dbo.TR_FCAV_LINK_CERTIFICADO
   ON  dbo.certificados
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here

	DECLARE @aluno varchar(20),
			@curso varchar(20),
			@turma varchar(20),
			@url_aprovado varchar(255),
			@aprovacao varchar(1)

	-- variaveis para o e-mail
	DECLARE @nomealuno varchar(100),
			@nomecurso varchar(100),
			@emailaluno varchar(200),
			@encaminha_email varchar(200),
			@unidade_fisica varchar(20),
			@unidade_ensino VARCHAR(20),
			@assunto varchar(100),      
			@texto varchar(8000)   

	/**Bloco para disponibilizar o certificado na tela de aviso da Central do Aluno.**/

	/* Carrega as variáveis */
	SELECT 
		@aluno = ALUNO,
		@curso = CURSO,
		@turma = TURMA,
		@url_aprovado = URL_APROVACAO,
		@aprovacao = APROVACAO

	FROM 
		INSERTED

	/*Verifica se o certificado foi liberado. 
	  Se for verdadeiro e se o link existe, insere na tabela de Aviso do Lyceum o link do certificado.
	  Se for falso, verifica se a aprovação é N, sendo verdadeira, apaga a linha referente ao certificado.*/

	IF @url_aprovado IS NOT NULL AND @aprovacao = 'S'
	BEGIN
		INSERT INTO LYCEUM.DBO.LY_AVISO
		(ALUNO,DTINI,DTFIM,MENSAGEM,CURSO,SERIE,TIPO_AVISO,UNID_RESPONSAVEL,UNID_FISICA,
			TURNO,CURRICULO,CONCURSO,DATA_INCLUSAO,USUARIO,DESTINO,ORDEM,LOTE,ANEXO_ID)
		VALUES
		(@aluno,CONVERT(DATE,GETDATE(),102),CONVERT(DATE,GETDATE()+500,102),'Link para o Certificado '+ @turma +': <p><a href="'+ @url_aprovado +'" target="_blank" >Clique Aqui</a></p>',
			@curso,NULL,'I',NULL,NULL,NULL,NULL,NULL,CONVERT(DATE,GETDATE(),102),'zeus',NULL,NULL,NULL,NULL)	
	END
	ELSE 
	BEGIN
		IF @aprovacao = 'N'
		BEGIN
			DELETE LYCEUM.DBO.LY_AVISO WHERE ALUNO = @aluno AND CURSO = @curso AND  MENSAGEM LIKE '%Link para o Certificado%' 
		END
	END


	/**Bloco para Envio do e-mail para o aluno**/
		-------------------------------------------------------------   
		-- DADOS DO ALUNO
		SELECT      
			@nomealuno = P.NOME_COMPL,
			@emailaluno = LOWER(LTRIM(RTRIM(P.E_MAIL)))      
		FROM LYCEUM.dbo.LY_ALUNO A
			 INNER JOIN LYCEUM.dbo.LY_PESSOA P
				ON P.PESSOA = A.PESSOA
		WHERE A.ALUNO = @aluno

		-------------------------------------------------------------   
		-- DADOS DO CURSO
        SELECT      
            @nomecurso = CS.NOME,      
            @unidade_fisica = OC.UNIDADE_FISICA,
			@unidade_ensino = CS.FACULDADE
		FROM lyceum.dbo.LY_OFERTA_CURSO OC      
			INNER JOIN lyceum.dbo.LY_CURSO CS      
				ON (OC.CURSO = CS.CURSO)      
        WHERE CS.CURSO = @curso  

		-------------------------------------------------------------      
		 --ENCAMINHAMENTO DE CÓPIA PARA AS SECRETARIAS      
			--Produção 
			IF (@unidade_fisica = 'USP' OR (@unidade_fisica = 'Online' AND @unidade_ensino != 'ATUAL') OR @unidade_fisica = 'Online USP')
			BEGIN      
			  SET @encaminha_email = 'secretariausp@vanzolini.com.br; '
			END
			ELSE
			BEGIN
				IF(@unidade_fisica = 'Online' AND @unidade_ensino = 'ATUAL')
				BEGIN
					SET @encaminha_email = 'secretariausp@vanzolini.com.br; secretariapta@vanzolini.com.br; '
				END
				ELSE
				BEGIN
					SET @encaminha_email = 'secretariapta@vanzolini.com.br; '
				END	
			END

		---------------------------------------------------------------------------------------                              
		/* MENSAGEM PADRÃO PARA OS ALUNOS INGRESSOS DE PROCESSO SELETIVO*/        
		---------------------------------------------------------------------------------------          
		SET @assunto = 'Certificado: ' + @nomecurso + ' - ' + @turma + ''
		-------------------------------------------------------------   
		SET @texto = 
				'Olá, ' + @nomealuno + '!
				<br><br>
				Tudo bem?
				<br><br>
				Informamos que o seu certificado digital, referente ao curso '+ @nomecurso +', turma '+ right(@turma,CHARINDEX(' ', REVERSE(LTRIM(RTRIM(@turma))))-1) +', 
				está disponível na Central do Aluno > AVISOS > Avisos e Ocorrências, em Mensagens Recebidas. 
				<br><br> 
				Acesse o link: <a href="https://sga.vanzolini.org.br/AOnline/" target="_blank">https://sga.vanzolini.org.br/AOnline/</a>
				<br><br>
				Clique em Avisos > link para o certificado. 
				<br><br> 	
				Caso tenha alguma dúvida, entre em contato conosco através dos canais abaixo:
				<br><br>
				<b>Secretaria Acadêmica PTA</b>: Via e-mail secretariapta@vanzolini.com.br ou pelo telefone: (11) 3145-3700.  
				<br>        
				<b>Secretaria Acadêmica USP</b>: Via e-mail secretariausp@vanzolini.com.br ou pelo telefone: (11) 5525-5837.
				<br><br>
				Conte com a gente para o que precisar!' 
		-------------------------------------------------------------            
		EXEC MSDB.dbo.SP_SEND_DBMAIL @profile_name =      
										-- Desenvolvimento/homologação         
										--FCAV_HOMOLOGACAO,          
										-- Produção          
										VANZOLINI_BD,      
										@recipients = @emailaluno,
										@reply_to = @encaminha_email,
										@copy_recipients = @encaminha_email,      
										@blind_copy_recipients = 'suporte_techne@vanzolini.com.br',      
										@subject = @assunto,      
										@body = @texto,      
										@body_format = HTML;   
END
GO
