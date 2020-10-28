/*********************************************************************************      
		TRIGGER TR_FCAV_ENVIA_EMAIL_LANC_NOTA



      
**********************************************************************************/    

ALTER TRIGGER TR_FCAV_ENVIA_EMAIL_LANC_NOTA    
ON  LY_NOTA	
AFTER INSERT,UPDATE    
    
AS    
    --vari�veis para montar o e-mail
    DECLARE @curso T_CODIGO
	DECLARE @turma T_CODIGO
	DECLARE @periodo VARCHAR(20)
	DECLARE @disciplina T_CODIGO
	DECLARE @nome_disciplina varchar(200)    
	DECLARE @nome_docente varchar(200)  
    DECLARE @unidade_ensino varchar(20)    

	DECLARE @aluno T_CODIGO
	DECLARE @nome_aluno varchar(200) 

    DECLARE @link_apolo varchar(200)
	DECLARE @link_aonline varchar(200)

	--vari�veis para o e-mail
	DECLARE @assunto varchar(100)    
    DECLARE @texto varchar(8000)    
    DECLARE @destinatario varchar(100)    
    DECLARE @encaminha_email varchar(200)    
	DECLARE @unidade_fisica  varchar(200)    


    SET @curso = NULL
	SET @turma = NULL
	SET @periodo = NULL
	SET @disciplina = NULL
	SET @nome_disciplina = NULL
	SET @nome_docente = NULL
	SET @unidade_ensino = NULL
	SET @unidade_fisica = NULL

    SET @link_apolo = 'https://uspdigital.usp.br/apolo'
	SET @link_aonline = 'https://sga.vanzolini.org.br/AOnline'
    
	SET @assunto = NULL   
    SET @texto = NULL   
    SET @destinatario = NULL    


----------------------------------------------------
	SELECT 
		@aluno = ALUNO,
		@turma = TURMA,
		@disciplina = upper(DISCIPLINA),
		@periodo = (CONVERT(VARCHAR, ANO) + '/' + CONVERT(VARCHAR,SEMESTRE))
	FROM inserted

----------------------------------------------------
	SELECT 
		@nome_disciplina = CASE WHEN NOME_COMPL LIKE '%-CEAI' THEN
					SUBSTRING(SUBSTRING(NOME_COMPL,1,CHARINDEX('-',NOME_COMPL)-1),CHARINDEX('em ',NOME_COMPL)+3,LEN(NOME_COMPL))
			ELSE NOME_COMPL END
	FROM 
		LY_DISCIPLINA
	WHERE
		DISCIPLINA = @disciplina

----------------------------------------------------
	SELECT 
		@curso = CURSO,
		@unidade_ensino = UNIDADE_RESPONSAVEL,
		@unidade_fisica = FACULDADE
	FROM LY_TURMA TU
	WHERE TURMA = @turma
		AND DISCIPLINA = @disciplina
	GROUP BY CURSO, UNIDADE_RESPONSAVEL,FACULDADE

----------------------------------------------------
	SELECT 
		@nome_docente = DO.NOME_COMPL
	FROM LY_TURMA TU
		INNER JOIN LY_DOCENTE DO
			ON TU.NUM_FUNC = DO.NUM_FUNC
	WHERE TURMA = @turma
		AND DISCIPLINA = @disciplina
	GROUP BY DO.NOME_COMPL, CURSO, 
			 DISCIPLINA, UNIDADE_RESPONSAVEL


----------------------------------------------------
-- Define o nome e e-mail
----------------------------------------------------
	SELECT 
		@destinatario = E_MAIL,
		@nome_aluno = pe.NOME_COMPL
	FROM LY_ALUNO AL
	INNER JOIN LY_PESSOA PE
		ON AL.PESSOA = PE.PESSOA
	WHERE
		AL.ALUNO = @aluno

----------------------------------------------------

	IF(@unidade_fisica = 'USP' or @curso like 'CEAI'or @curso like 'A-PDT')
	BEGIN 
		SET @encaminha_email = 	'secretariausp@vanzolini.com.br'
	END
	ELSE BEGIN 
		SET @encaminha_email = 'secretariapta@vanzolini.com.br' 
	END

---------------------------------------------

IF (@unidade_ensino = 'CAPAC') 
BEGIN
	
	SET @assunto = @turma + ' - ' + @disciplina + ' - Divulga��o de Nota'

	SET @texto = 'Prezado (a) '+ @nome_aluno +',
			<br><br>
				Informamos que est� dispon�vel na Central do Aluno a m�dia final da disciplina <b>'+ @nome_disciplina +'</b> - Prof. '+ @nome_docente +'.
			<br><br>
				<b>Instru��es para acesso:</b>
			<br><ul>
					<li> Central do aluno <a href="'+ @link_aonline +'">(Clique aqui)</a>
					<li> Digite usu�rio e senha (cadastrados no ato da matr�cula)
					<li> Clique em disciplina > hist�rico acad�mico
				</ul>
			<br>
				Os alunos reprovados por nota e/ou frequ�ncia dever�o preencher o requerimento na Central do Aluno solicitando a regulariza��o.
			<br><br>
				<b>Instru��es para preenchimento do requerimento:</b>
				<br><ul>
					<li> Clique em Secretaria Virtual > Solicita��o de Servi�os
					<li> Escolha a op��o desejada (caso n�o tenha, opte por outras solicita��es)
					<li> Preencha o campo de observa��es 
					<li> Enviar para a cesta > ok para gravar a solicita��o 
					<li> Clique em �concluir solicita��o�.  
				</ul>
			<br><br>
			Atenciosamente,  
			<br><br>
			Secretaria Acad�mica.'

END
ELSE
BEGIN
	IF(@disciplina like 'A-CEAI%') --VERIFICA SE A DISCIPLINA � EGRESSO
	BEGIN
						
		SET @assunto ='Egressos '+ @periodo + ' - ' + @disciplina + ' - Divulga��o de Nota'
		
		SET @texto = '
			
			Prezado(a) '+ @nome_aluno +',
			<br><br>
			Informamos que a m�dia final da disciplina '+ @nome_disciplina +' � Prof. '+@nome_docente+' est� dispon�vel para consulta na <a href="'+ @link_aonline +'">Central do Aluno</a>.
			<br><br>
			Ap�s acessar, clique em Disciplina-> Hist�rico Acad�mico (� necess�rio usar a barra de rolagem).
			<br><br>
			Iremos aguardar a divulga��o das m�dias de todas as disciplinas oferecidas aos egressos no 2� quadrimestre de 2018 e depois providenciaremos as declara��es daqueles que foram aprovados. Quando o documento estiver pronto, n�s comunicaremos por email.
			<br><br>
			Caso esteja reprovado por nota (quando a m�dia obtida � igual ou menor que 6,9) e/ou reprovado por frequ�ncia (quando o numero de faltas � maior do que 75%) a declara��o n�o ser� emitida.
			<br><br>
			Atenciosamente,
			<br><br>
			Secretaria Acad�mica.
		'
	END
	ELSE 
	BEGIN
		IF(@disciplina like '%TCC' AND @curso NOT IN ('CEAI', 'CEQP', 'CELOG', 'CEGP'))
		BEGIN
			SET @assunto = @disciplina + ' - Divulga��o de Nota'

			SET @texto = 'Prezado(a) '+ @nome_aluno +',
				<br><br>
				Informo que est� dispon�vel no <a href="'+ @link_apolo +'">Apolo (sistema USP)</a> e na <a href="'+ @link_aonline +'">Central do Aluno</a> a nota referente � 
				disciplina '+ @nome_disciplina +' � Prof. '+@nome_docente+'. <br>
				O certificado ser� solicitado automaticamente pela secretaria de cursos � Universidade de S�o Paulo, somente para o aluno com na seguinte situa��o:
				<br><br>
				- Aprovado com m�dia igual ou superior a 7,0 em todas as disciplinas, inclusive o TCC; <br>
				- Frequ�ncia m�nima de 85%; <br>
				- Documenta��o acad�mica completa (entrega de todos os documentos solicitados na matr�cula); e<br>
				- Concluiu a valida��o de dados pessoais no Apolo - sistema USP. <br>
				<br><br>
				O prazo para disponibiliza��o do certificado � de, aproximadamente, 08 meses e comunicaremos, via email, a disponibilidade deste para retirada.<br>
				<br><br>
				A impress�o do hist�rico escolar pode ser realizada no Apolo.
				<br><br>
				Caso haja alguma disformidade em rela��o a uma das situa��es acima o seu certificado n�o ser� emitido e seu curso ser� jubilado, 
				significando o encerramento de seu vinculo com a Universidade de S�o Paulo. 
				<br><br>
				Atenciosamente,  
				<br><br>
				Secretaria Acad�mica.
			'
		END
		ELSE
		BEGIN
			IF (@curso IN ('A-PDT') )
			BEGIN
				
				Declare @Docentes Varchar(700)

				--// Inicia vari�vel vazia por que varchar n�o concatena com null
				Set @Docentes = ''


				SELECT 
					 @Docentes = @Docentes + NOME_COMPL + ' / '
				FROM 
					LY_DOCENTE do 
					inner join LY_AGENDA ag 
						on do.NUM_FUNC = ag.NUM_FUNC 
				where do.NUM_FUNC != 83484 
					and DISCIPLINA = @disciplina
					and TURMA = @turma
				group by do.NUM_FUNC,NOME_COMPL

				--// Se houve resultado, retira o �ltimo caractere (;)
				If @Docentes <> ''
				Begin
				   --// Retira o �ltimo caractere "/"
				   Set @Docentes = SUBSTRING(@Docentes, 1, len(@Docentes)-1)
				End

				SET @assunto = @disciplina + ' - Divulga��o de Nota'


				SET @texto ='Prezado(a) '+ @nome_aluno +',
							<br><br>
							Informamos  que est� dispon�vel no <a href="'+ @link_apolo +'">Apolo (sistema USP)</a> e na <a href="'+ @link_aonline +'">Central do Aluno</a> a nota referente 
							� disciplina '+ @nome_disciplina +' - Professor(es): '+ @Docentes +' .
							<br><br>
							O certificado ser� solicitado automaticamente pela secretaria de cursos � Universidade de S�o Paulo, somente para o aluno com na seguinte situa��o:
							<br><br>
								- Aprovado com m�dia igual ou superior a 7,0.
								<br>
								- Frequ�ncia m�nima de 75%;
								<br>
								- Documenta��o acad�mica completa (entrega de todos os documentos solicitados na matr�cula).
								<br>
								- Concluiu a valida��o de dados pessoais no Apolo - sistema USP. 
								<br><br>
								O prazo para disponibiliza��o do certificado � de, aproximadamente, 04 meses e comunicaremos via e-mail.
								<br><br>
								Caso haja alguma disformidade em rela��o a uma das situa��es acima o seu certificado n�o ser� emitido e seu curso ser� jubilado, 
								significando o encerramento de seu v�nculo com a Universidade de S�o Paulo. 
								<br><br>
								Atenciosamente'

			END
			ELSE
			BEGIN
				
				IF(@curso IN ('A-LA9001.15'))
				BEGIN
					SET @assunto = @disciplina + ' - ' + @periodo + ' - ' + 'Divulga��o de Nota'
		
						SET @texto = '
							Prezado(a) '+ @nome_aluno +',
							<br><br>
								Informamos que a nota do curso '+ @nome_disciplina +' � Prof. '+@nome_docente+' est� dispon�vel para consulta na <a href="'+ @link_aonline +'">Central do Aluno</a>.
							<br><br>
								Para ser aprovado, o aluno deve ter frequentado todo o curso e receber uma nota m�nima equivalente a 70%, 
								tanto na avalia��o cont�nua quanto na avalia��o escrita.
							<br><br>
								O aluno que for reprovado, poder� realizar uma segunda prova dentro do per�odo de 12 meses contados � partir da data de realiza��o da primeira prova,
								mediante pagamento de taxa administrativa (consulte o valor com a Secretaria Acad�mica). 
							<br><br>
								O exame ser� diferente do aplicado no treinamento, mas seguir� as mesmas regras. 
								Caso reprovado nessa segunda avalia��o, o aluno dever� realizar um novo curso.

							<br><br>
							Atenciosamente,
							<br><br>
							Secretaria Acad�mica.'
				END
				ELSE
				BEGIN
				
					SET @assunto = @disciplina + ' - ' + @periodo + ' - ' + 'Divulga��o de Nota'
		
					SET @texto = '
						Prezado (a) '+ @nome_aluno +',
						<br><br>
							Informamos que est� dispon�vel na Central do Aluno a m�dia final da disciplina <b>'+ @nome_disciplina +'</b> - Prof. '+ @nome_docente +'.
						<br><br>
							<b>Instru��es para acesso:</b>
						<br><ul>
								<li> Central do aluno <a href="'+ @link_aonline +'">(Clique aqui)</a>
								<li> Digite usu�rio e senha (cadastrados no ato da matr�cula)
								<li> Clique em disciplina > hist�rico acad�mico
							</ul>
						<br>
							Os alunos reprovados por nota e/ou frequ�ncia dever�o preencher o requerimento na Central do Aluno solicitando a regulariza��o.
						<br><br>
							<b>Instru��es para preenchimento do requerimento:</b>
							<br><ul>
								<li> Clique em Secretaria Virtual > Solicita��o de Servi�os
								<li> Escolha a op��o desejada (caso n�o tenha, opte por outras solicita��es)
								<li> Preencha o campo de observa��es 
								<li> Enviar para a cesta > ok para gravar a solicita��o 
								<li> Clique em �concluir solicita��o�.  
							</ul>
						<br><br>
						Atenciosamente,  
						<br><br>
						Secretaria Acad�mica.'
				END
			END
		END
	END
END

------------------------------------------
--DISPARA O E-MAIL

IF NOT EXISTS(SELECT 1 FROM MSDB.dbo.sysmail_mailitems WHERE recipients = @destinatario collate Latin1_General_CI_AI AND sent_status = 1 AND subject LIKE @assunto)
BEGIN

	declare @v_profile varchar(100)

	set @v_profile = -- Desenvolvimento/homologa��o       
					 --'FCAV_HOMOLOGACAO'
					 -- Produ��o        
					 'VANZOLINI_BD'

	EXEC MSDB.dbo.SP_SEND_DBMAIL 
			@profile_name =  @v_profile,  
			@recipients = @destinatario,    
			@copy_recipients = @encaminha_email,
			@reply_to = @encaminha_email,
			@blind_copy_recipients = 'suporte_techne@vanzolini.com.br',    
			@subject = @assunto,    
			@body = @texto,    
			@body_format = HTML;
END