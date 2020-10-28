


--* ***************************************************************                    
--*                    
--*   *** PROCEDURE a_APoI_Ly_aluno  ***                    
--*                    
--*                    
--* USO:                    
--* - Entry point utilizada para:
--*		1) Preencher o grupo de aluno se houver.
--*		2) Disparar e-mail para novos ingressos.
--*		3) N�o aloca inscritos nas Palestras quando atingi o n�mero m�ximo de vagas.
--*
/*********************************************************************************
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO 

Para o ambiente de PRODU��O, n�o esquecer de alterar as vari�veis: 
	@destinatario no bloco ingresso de aluno interno,
	Comentar ao final Homologacao @encaminha_email e @assunto 
	@PROFILE_NAME alterar para VANZOLINI_BD

ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO 
**********************************************************************************/

--* Autor:  Techne                 
--* Data de cria��o: 2010-08-19 17:59:22.030                    

--* ***************************************************************                    
ALTER PROCEDURE a_APoI_Ly_aluno @erro varchar(1024) OUTPUT,
@aluno varchar(20), @concurso varchar(20), @candidato varchar(20), @curso varchar(20),
@turno varchar(20), @curriculo varchar(20), @serie numeric(3), @nome_compl varchar(100),
@nome_abrev varchar(50), @anoconcl_2g numeric(4), @tipo_ingresso varchar(20), @ano_ingresso numeric(4),
@sem_ingresso numeric(2), @sit_aluno varchar(15), @cred_educativo varchar(1), @turma_pref varchar(20),
@grupo varchar(20), @areacnpq varchar(20), @discipoutraserie varchar(1), @ref_aluno_ant varchar(20),
@sit_aprov varchar(1), @cod_cartao varchar(20), @dt_ingresso datetime, @e_mail_interno varchar(100),
@num_chamada numeric(10), @curso_ant varchar(100), @unidade_fisica varchar(20), @pessoa numeric(10),
@outra_faculdade varchar(100), @cidade_2g varchar(50), @pais_2g varchar(50), @creditos numeric(3),
@obs_aluno_finan varchar(3000), @representante_turma varchar(1), @tipo_aluno varchar(50),
@faculdade_conveniada varchar(20), @stamp_atualizacao datetime, @unidade_ensino varchar(20),
@instituicao varchar(20), @classif_aluno varchar(40), @dist_aluno_unidade numeric(15), @nome_social varchar(100)
AS
    -- [IN�CIO] Customiza��o - N�o escreva c�digo antes desta linha                      
    -------------------------------------                
    --VARIAVEIS
    DECLARE @max_alunos numeric
    DECLARE @alu_inscritos numeric
    
    DECLARE	@nome_curso varchar (300)
	
	DECLARE	@grupoDoAluno varchar(20)
	
	DECLARE @endereco varchar(100)    
    DECLARE @horario varchar(80)    
    DECLARE @contato varchar(200)
    
	DECLARE @destinatario varchar(100)    
    DECLARE @encaminha_email varchar(100)      
    DECLARE @assunto varchar(100) 
    DECLARE @mensagem VARCHAR(8000)    
    

	------------------------------------                    
    --DEFINE A DATA DE INGRESSO DO ALUNO                                       
    UPDATE LY_ALUNO
    SET DT_INGRESSO = CASE WHEN DT_INGRESSO IS NULL THEN GETDATE()
					  ELSE DT_INGRESSO
					  END
    WHERE ALUNO = @aluno

    --------------------------------------------                
    --DEFINE O GRUPO DE ALUNO CASO EXISTA                
    SET @grupoDoAluno = (SELECT TOP 1
        GSP.GRUPO
    FROM LY_ALUNO A
    INNER JOIN LY_CURRICULO C
        ON A.CURRICULO = C.CURRICULO
        AND A.TURNO = C.TURNO
        AND A.CURSO = C.CURSO
    INNER JOIN LY_OFERTA_CURSO OC
        ON OC.CURRICULO = A.CURRICULO
        AND OC.ANO_INGRESSO = A.ANO_INGRESSO
        AND OC.PER_INGRESSO = A.SEM_INGRESSO
    INNER JOIN LY_GRUPO_SERV_PERIODO GSP
        ON C.SERVICO = GSP.SERVICO
        AND OC.ANO_INGRESSO = GSP.ANO
        AND OC.PER_INGRESSO = GSP.PERIODO
    WHERE A.ALUNO = @aluno
    ORDER BY GSP.GRUPO DESC)

    UPDATE LY_ALUNO
    SET GRUPO =
               CASE
                   WHEN @grupoDoAluno IS NULL THEN NULL
                   ELSE @grupoDoAluno
               END
    WHERE ALUNO = @aluno

	--------------------------------------------
	-- TRAZ O NOME DO CURSO
	SELECT
		@nome_curso = NOME
	FROM
		LY_CURSO
	WHERE
		CURSO = @curso
		
	-------------------------------------------------------------
    -- INSERE A UNIDADE DE ENSINO SE VIER VAZIA                    
    IF @unidade_ensino IS NULL
    BEGIN
        SET @unidade_ensino = (SELECT
            FACULDADE
        FROM LY_CURSO
        WHERE CURSO = @curso)
        
        UPDATE LY_ALUNO 
        SET
			UNIDADE_ENSINO = @unidade_ensino
		WHERE
			ALUNO = @aluno
    END

	-------------------------------------------------------------
	--TRAZ O E-MAIL DO ALUNO    
	SELECT 
		@destinatario = E_MAIL 
	FROM 
		LY_PESSOA 
	WHERE 
		PESSOA = @pessoa
	
	-------------------------------------------------------------    
	IF(@unidade_fisica = 'Paulista')
	BEGIN	
		SET @endereco = 'Av. Paulista, 967 - 3� andar'
		SET @horario  = '2�f � 6�f das 9h00 as 20h00h - s�bados das 8h15 �s 12hs' 
		SET @contato  = 'Secretaria Acad�mica Paulista: Via e-mail secretariapta@vanzolini.org.br ou pelo telefone:(11) 3145-3700'
	END
    ELSE
    BEGIN
		IF(@unidade_fisica = 'USP')
		BEGIN
			SET @endereco = 'Av. Prof Almeida Prado, 531 - Cidade Universit�ria'    
			SET @horario  = '2�f � 5�f das 9h00 �s 21h30h, 6�f das 9h00 �s 20h30 - s�bado das 8h15 �s 12hs'
			SET @contato  = 'Secretaria Acad�mica USP: Via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11) 5525-5830'
		END
    END
	
	-------------------------------------------------------------
	--BLOCO DE MENSAGENS
    IF (@tipo_ingresso = 'Compra de Curso'
        OR @tipo_ingresso = 'Outros')
    BEGIN

        --MENSAGEM PARA OS ALUNOS DA PALESTRA, CONFIRMA��O OU LISTA DE ESPERA                    
        IF (@unidade_ensino = 'PALES')
        BEGIN
			--BUSCA O N�MERO M�XIMO DE ALUNOS DA TURMA PARA AS PALESTRAS    
			SELECT top 1
				@max_alunos = ISNULL(MAX(C.VAGAS),T.NUM_ALUNOS)
			FROM LY_TURMA T
			INNER JOIN LY_CURSO C
				ON C.CURSO = T.CURSO
			INNER JOIN LY_PRE_MATRICULA P
				ON T.TURMA = P.TURMA
			WHERE T.UNIDADE_RESPONSAVEL = 'PALES'
			AND T.CLASSIFICACAO = 'EmInscricao'
			AND T.CURRICULO = @curriculo
			AND P.TURMA = T.TURMA
			group by c.VAGAS, t.NUM_ALUNOS

			--CONTA O N�MERO DE ALUNOS PRE_MATRICULADOS EM PALESTRAS                    
			SELECT
				@alu_inscritos = ISNULL(COUNT(P.ALUNO), 0)
			FROM LY_PRE_MATRICULA P
			INNER JOIN LY_TURMA T
				ON P.TURMA = T.TURMA
			WHERE T.UNIDADE_RESPONSAVEL = 'PALES'
			AND T.CLASSIFICACAO = 'EmInscricao'
			AND T.CURRICULO = @curriculo
			AND P.TURMA = T.TURMA
			---------------------------------------------------------------------------------------                    
			/* MENSAGEM PARA ALUNOS CONFIRMADOS */
			---------------------------------------------------------------------------------------  
			IF (@alu_inscritos <= @max_alunos)
			BEGIN
				SET @assunto = 'Confirma��o de Inscri��o'
	          
				SET @mensagem = 
          				'Caro Cliente, 
  						 <br><br>
	  					 
						 Agradecemos sua inscri��o para '+@nome_curso+'. 
						 <br><br>
						 Sua inscri��o foi efetivada com SUCESSO.
    					 <br><br>                    
						 
						 Seu c�digo de ALUNO �: ' + @aluno + '
						 <br><br>                    
						 
						 Qualquer d�vida entre em contato conosco: 
						 <br> 
						 <ul>                   
							<li> � pelo e-mail: palestrapta@vanzolini.org.br ; ou                   
							<li> � pelo telefone: (11)3145-3700
						 </ul>
						'
			END
			ELSE
			BEGIN
				---------------------------------------------------------------------------------------                    
				/* MENSAGEM PARA ALUNOS EM LISTA DE ESPERA */
				---------------------------------------------------------------------------------------  
				IF (@alu_inscritos > @max_alunos)
				BEGIN              
					SET @assunto = 'LISTA DE ESPERA'
		          
					SET @mensagem = 
      						'Caro Cliente, 
  							 <br><br>
	  					 
							 Agradecemos sua inscri��o para '+@nome_curso+'.
							 <br><br>
							 Sua inscri��o est� em LISTA DE ESPERA.
      						 <br><br>
	      					                
							 Por favor, pedimos que aguarde a Secretaria Acad�mica entrar em contato com voc� para confirmar a sua vaga.
							 <br><br>                    
							 
							 Seu c�digo de ALUNO �: ' + @aluno + '
							 <br><br>                    
							 
							 Qualquer d�vida entre em contato conosco: 
							 <br> 
							 <ul>                   
								<li> � pelo e-mail: palestrapta@vanzolini.org.br ou                   
								<li> � pelo telefone: (11)3145-3700
							 </ul>
							'                
				END
			END
        END --FIM DO IF 'PALES'
        ELSE
        BEGIN
			---------------------------------------------------------------------------------------                    
			/* MENSAGEM PARA ALUNOS DE CURSOS ONLINE */
			--------------------------------------------------------------------------------------- 
			IF(@unidade_fisica = 'Online')
			BEGIN
				SET @assunto = 'Confirma��o de Pr�-Matr�cula'
	          
				SET @mensagem = 
  						'Caro Cliente, 
  						 <br><br>
	  					 
						 Agradecemos sua inscri��o no curso '+@nome_curso+'
						 <br><br>
						 
						 Acesse o link https://sga.vanzolini.org.br/AOnline/. 
						 <br><br>
						 
						 Neste ambiente voc� poder� visualizar seu hist�rico de cursos, 
						 imprimir boletos, notas fiscais, solicitar servi�os como declara��es e afins.
						 <br><br>
						 
						 Seu c�digo de ALUNO �: '+@aluno+'
						 <br>
						 Seu login e senha s�o os mesmos que usou para fazer sua inscri��o.
						 <br><br>
						 
						 Em breve enviaremos em seu e-mail as instru��es para dar in�cio ao seu curso.
						 <br><br>
						 
						 E-mail de contato: cursos@vanzolini.org.br.
						'   						
			END --FIM IF CURSOS ONLINE
			ELSE
			BEGIN
				---------------------------------------------------------------------------------------                    
				/* MENSAGEM PADR�O PARA OS CURSOS DE VENDA DIRETA */
				---------------------------------------------------------------------------------------
				SET @assunto = 'Confirma��o de Pr�-Matr�cula'
	          
				SET @mensagem = 
  						'Caro Cliente, 
  						 <br><br>
	  					 
						 Agradecemos sua inscri��o no curso '+@nome_curso+'
						 <br><br>
						 
						 Condi��o obrigat�ria para confirma��o da matr�cula:
						 <br>
						 <ul>
					 		<li>Dar o aceite de acordo ao: Termo de aceite das condi��es de presta��o de servi�os educacionais; e
					 		<li>Efetuar o pagamento.
						 </ul>		 
						 
						 Acesse o link https://sga.vanzolini.org.br/AOnline/. 
						 <br><br>
						 
						 Neste ambiente voc� poder� visualizar seu hist�rico de cursos, 
						 imprimir boletos, notas fiscais, solicitar servi�os como declara��es e afins.
						 <br><br>
						 
						 Seu c�digo de ALUNO �: '+@aluno+'
						 <br>
						 Seu login e senha s�o os mesmos que usou para fazer sua inscri��o.
						 <br><br>
						 
						 E-mail de contato: cursos@vanzolini.org.br.
						'  
			END
		END
		
    END--FIM DA COMPRA DE CURSO                    

    ELSE
    BEGIN
		---------------------------------------------------------------------------------------                    
		/* MENSAGEM PADR�O PARA OS ALUNOS INGRESSOS DE PROCESSO SELETIVO */
		---------------------------------------------------------------------------------------
		IF ((@tipo_ingresso = 'Inscricao_Site' 
			OR @tipo_ingresso = 'Processo Seletivo')
			AND @concurso IS NOT NULL )
		BEGIN
			
			SET @assunto = 'Confirma��o de Pr�-Matr�cula'
	      
			SET @mensagem = 
					'Sua Pr�-Matr�cula foi conclu�da com sucesso. 
					 <br><br>
					 
					 Seu c�digo de ALUNO �: '+@aluno+'
					 <br><br>
					 Os pr�ximos passos s�o: 
					 <br><br>
					 A- Efetuar o pagamento conforme o plano escolhido; 
					 <br><br>
					 B - Comparecer em at� 3 dias ap�s a data de convoca��o para entrega da documenta��o: 
					 <ul>
				 		<li>Diploma da Gradua��o (c�pia autenticada ou original com c�pia simples para confer�ncia);
				 		<li>CPF, RG e comprovante de resid�ncia (c�pia simples); 
				 		<li>01 foto 3x4; e
						<li>Contrato de Presta��o de Servi�os Educacionais - imprimir 02 vias.
						<br>
						O contrato deve ser assinado e rubricado pelo Respons�vel Financeiro/Benefici�rio e testemunhas).
					 </ul>		 
					 <br>
					 <b>Obs.: Est�o impedidos de assinar como testemunhas, menores de 18 anos, o c�njuge, o companheiro, 
					 o ascendente e o descendente em qualquer grau e o colateral, at� o terceiro grau.</b>
					 <br><br>
					 
					 Local: '+@endereco+'
					 <br>
					 Hor�rio: '+@horario+'
					'  
		END
		ELSE
		BEGIN
			-------------------------------------------------------------
			/*MENSAGEM PARA ALUNOS CADASTRADOS PELA SECRETARIA*/
			-------------------------------------------------------------
			SET @assunto = 'Ingresso Interno de Aluno'
	      
			SET @mensagem = 
					'Ingresso Interno de Aluno
					 <br><br>
					 
					 Nome: '+ @nome_compl +' 
					 <br>
					 C�digo de ALUNO: '+ @aluno +' 
					 <br>
					 Curso:'+ @nome_curso +' 
					 <br>
					 Periodo Ingresso: '+ CAST(@ano_ingresso as varchar)+ '/'
										+ CAST(@sem_ingresso as varchar)+'
					 <br>
					 Tipo de Ingresso: '+ @tipo_ingresso+' 
					'
			IF(@unidade_fisica = 'Paulista')
			BEGIN
				SET @destinatario = 
					--Produ��o
					--'secretariapta@vanzolini.org.br;'
					--Homologa��o
					'suporte_techne@vanzolini.org.br;'
			END
			ELSE
			BEGIN 
				IF(@unidade_fisica = 'USP')
				BEGIN
					SET @destinatario = 
						--Produ��o
						--'secretariausp@vanzolini.org.br;'
						--Homologa��o
						'suporte_techne@vanzolini.org.br;'
				END
			END
		END
				
    END
    
	---------------------------------------------------------------------------------------	
	--ENCAMINHAMENTO DE UMA C�PIA PARA AS SECRETARIAS
	--Produ��o
		--IF (@unidade_fisica = 'USP')
		--BEGIN
		--	SET @encaminha_email = 
		--		'secretariausp@vanzolini.org.br;'
		--END
		--ELSE
		--BEGIN
		--	IF (@unidade_ensino	= 'ATUAL'	 OR @unidade_ensino = 'PALES'
		--	AND(@unidade_fisica = 'Paulista' OR @unidade_fisica	= 'Online'))
		--	BEGIN
		--		SET @encaminha_email = 
		--			'mayla.alencar@vanzolini.org.br; 
		--			 elivana.moura@vanzolini.org.br;'
		--	END
		--	ELSE
		--	BEGIN
		--		IF ((@unidade_ensino = 'CAPAC' OR @unidade_ensino = 'ESPEC')
		--		AND @unidade_fisica  = 'Paulista')
		--		BEGIN
		--			SET @encaminha_email =
		--				'adriana.pereira@vanzolini.org.br;
		--				 elivana.moura@vanzol\ini.org.br;'
		--		END

		--	END
		--END
		
		--SET @encaminha_email = @encaminha_email + 'suporte_techne@vanzolini.org.br'
		
	--Homologa��o
		SET @encaminha_email = 'suporte_techne@vanzolini.org.br'
		SET @assunto = 'Homologa��o - ' + @assunto
                 
    ---------------------------------------------------------------------------------------                    
    EXEC MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME =
								 -- Desenvolvimento/homologa��o
								 FCAV_HOMOLOGACAO,
								 -- Produ��o
								 --VANZOLINI_BD,
								 @recipients = @destinatario,
								 @blind_copy_recipients = @encaminha_email,
								 @subject = @assunto,
								 @body = @mensagem,
								 @body_format = 'HTML'

-- [FIM] Customiza��o - N�o escreva c�digo ap�s esta linha  