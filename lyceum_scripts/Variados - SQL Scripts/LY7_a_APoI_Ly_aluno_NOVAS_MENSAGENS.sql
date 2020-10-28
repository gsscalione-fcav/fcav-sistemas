


--* ***************************************************************                    
--*                    
--*   *** PROCEDURE a_APoI_Ly_aluno  ***                    
--*                    
--*                    
--* USO:                    
--* - Entry point utilizada para:
--*		1) Preencher o grupo de aluno se houver.
--*		2) Disparar e-mail para novos ingressos.
--*		3) Não aloca inscritos nas Palestras quando atingi o número máximo de vagas.
--*
/*********************************************************************************
ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO 

Para o ambiente de PRODUÇÃO, não esquecer de alterar as variáveis: 
	@destinatario no bloco ingresso de aluno interno,
	Comentar ao final Homologacao @encaminha_email e @assunto 
	@PROFILE_NAME alterar para VANZOLINI_BD

ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO 
**********************************************************************************/

--* Autor:  Techne                 
--* Data de criação: 2010-08-19 17:59:22.030                    

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
    -- [INÍCIO] Customização - Não escreva código antes desta linha                      
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
		SET @endereco = 'Av. Paulista, 967 - 3º andar'
		SET @horario  = '2ªf à 6ªf das 9h00 as 20h00h - sábados das 8h15 às 12hs' 
		SET @contato  = 'Secretaria Acadêmica Paulista: Via e-mail secretariapta@vanzolini.org.br ou pelo telefone:(11) 3145-3700'
	END
    ELSE
    BEGIN
		IF(@unidade_fisica = 'USP')
		BEGIN
			SET @endereco = 'Av. Prof Almeida Prado, 531 - Cidade Universitária'    
			SET @horario  = '2ªf à 5ªf das 9h00 às 21h30h, 6ªf das 9h00 às 20h30 - sábado das 8h15 às 12hs'
			SET @contato  = 'Secretaria Acadêmica USP: Via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11) 5525-5830'
		END
    END
	
	-------------------------------------------------------------
	--BLOCO DE MENSAGENS
    IF (@tipo_ingresso = 'Compra de Curso'
        OR @tipo_ingresso = 'Outros')
    BEGIN

        --MENSAGEM PARA OS ALUNOS DA PALESTRA, CONFIRMAÇÃO OU LISTA DE ESPERA                    
        IF (@unidade_ensino = 'PALES')
        BEGIN
			--BUSCA O NÚMERO MÁXIMO DE ALUNOS DA TURMA PARA AS PALESTRAS    
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

			--CONTA O NÚMERO DE ALUNOS PRE_MATRICULADOS EM PALESTRAS                    
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
				SET @assunto = 'Confirmação de Inscrição'
	          
				SET @mensagem = 
          				'Caro Cliente, 
  						 <br><br>
	  					 
						 Agradecemos sua inscrição para '+@nome_curso+'. 
						 <br><br>
						 Sua inscrição foi efetivada com SUCESSO.
    					 <br><br>                    
						 
						 Seu código de ALUNO é: ' + @aluno + '
						 <br><br>                    
						 
						 Qualquer dúvida entre em contato conosco: 
						 <br> 
						 <ul>                   
							<li> • pelo e-mail: palestrapta@vanzolini.org.br ; ou                   
							<li> • pelo telefone: (11)3145-3700
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
	  					 
							 Agradecemos sua inscrição para '+@nome_curso+'.
							 <br><br>
							 Sua inscrição está em LISTA DE ESPERA.
      						 <br><br>
	      					                
							 Por favor, pedimos que aguarde a Secretaria Acadêmica entrar em contato com você para confirmar a sua vaga.
							 <br><br>                    
							 
							 Seu código de ALUNO é: ' + @aluno + '
							 <br><br>                    
							 
							 Qualquer dúvida entre em contato conosco: 
							 <br> 
							 <ul>                   
								<li> • pelo e-mail: palestrapta@vanzolini.org.br ou                   
								<li> • pelo telefone: (11)3145-3700
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
				SET @assunto = 'Confirmação de Pré-Matrícula'
	          
				SET @mensagem = 
  						'Caro Cliente, 
  						 <br><br>
	  					 
						 Agradecemos sua inscrição no curso '+@nome_curso+'
						 <br><br>
						 
						 Acesse o link https://sga.vanzolini.org.br/AOnline/. 
						 <br><br>
						 
						 Neste ambiente você poderá visualizar seu histórico de cursos, 
						 imprimir boletos, notas fiscais, solicitar serviços como declarações e afins.
						 <br><br>
						 
						 Seu código de ALUNO é: '+@aluno+'
						 <br>
						 Seu login e senha são os mesmos que usou para fazer sua inscrição.
						 <br><br>
						 
						 Em breve enviaremos em seu e-mail as instruções para dar início ao seu curso.
						 <br><br>
						 
						 E-mail de contato: cursos@vanzolini.org.br.
						'   						
			END --FIM IF CURSOS ONLINE
			ELSE
			BEGIN
				---------------------------------------------------------------------------------------                    
				/* MENSAGEM PADRÃO PARA OS CURSOS DE VENDA DIRETA */
				---------------------------------------------------------------------------------------
				SET @assunto = 'Confirmação de Pré-Matrícula'
	          
				SET @mensagem = 
  						'Caro Cliente, 
  						 <br><br>
	  					 
						 Agradecemos sua inscrição no curso '+@nome_curso+'
						 <br><br>
						 
						 Condição obrigatória para confirmação da matrícula:
						 <br>
						 <ul>
					 		<li>Dar o aceite de acordo ao: Termo de aceite das condições de prestação de serviços educacionais; e
					 		<li>Efetuar o pagamento.
						 </ul>		 
						 
						 Acesse o link https://sga.vanzolini.org.br/AOnline/. 
						 <br><br>
						 
						 Neste ambiente você poderá visualizar seu histórico de cursos, 
						 imprimir boletos, notas fiscais, solicitar serviços como declarações e afins.
						 <br><br>
						 
						 Seu código de ALUNO é: '+@aluno+'
						 <br>
						 Seu login e senha são os mesmos que usou para fazer sua inscrição.
						 <br><br>
						 
						 E-mail de contato: cursos@vanzolini.org.br.
						'  
			END
		END
		
    END--FIM DA COMPRA DE CURSO                    

    ELSE
    BEGIN
		---------------------------------------------------------------------------------------                    
		/* MENSAGEM PADRÃO PARA OS ALUNOS INGRESSOS DE PROCESSO SELETIVO */
		---------------------------------------------------------------------------------------
		IF ((@tipo_ingresso = 'Inscricao_Site' 
			OR @tipo_ingresso = 'Processo Seletivo')
			AND @concurso IS NOT NULL )
		BEGIN
			
			SET @assunto = 'Confirmação de Pré-Matrícula'
	      
			SET @mensagem = 
					'Sua Pré-Matrícula foi concluída com sucesso. 
					 <br><br>
					 
					 Seu código de ALUNO é: '+@aluno+'
					 <br><br>
					 Os próximos passos são: 
					 <br><br>
					 A- Efetuar o pagamento conforme o plano escolhido; 
					 <br><br>
					 B - Comparecer em até 3 dias após a data de convocação para entrega da documentação: 
					 <ul>
				 		<li>Diploma da Graduação (cópia autenticada ou original com cópia simples para conferência);
				 		<li>CPF, RG e comprovante de residência (cópia simples); 
				 		<li>01 foto 3x4; e
						<li>Contrato de Prestação de Serviços Educacionais - imprimir 02 vias.
						<br>
						O contrato deve ser assinado e rubricado pelo Responsável Financeiro/Beneficiário e testemunhas).
					 </ul>		 
					 <br>
					 <b>Obs.: Estão impedidos de assinar como testemunhas, menores de 18 anos, o cônjuge, o companheiro, 
					 o ascendente e o descendente em qualquer grau e o colateral, até o terceiro grau.</b>
					 <br><br>
					 
					 Local: '+@endereco+'
					 <br>
					 Horário: '+@horario+'
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
					 Código de ALUNO: '+ @aluno +' 
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
					--Produção
					--'secretariapta@vanzolini.org.br;'
					--Homologação
					'suporte_techne@vanzolini.org.br;'
			END
			ELSE
			BEGIN 
				IF(@unidade_fisica = 'USP')
				BEGIN
					SET @destinatario = 
						--Produção
						--'secretariausp@vanzolini.org.br;'
						--Homologação
						'suporte_techne@vanzolini.org.br;'
				END
			END
		END
				
    END
    
	---------------------------------------------------------------------------------------	
	--ENCAMINHAMENTO DE UMA CÓPIA PARA AS SECRETARIAS
	--Produção
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
		
	--Homologação
		SET @encaminha_email = 'suporte_techne@vanzolini.org.br'
		SET @assunto = 'Homologação - ' + @assunto
                 
    ---------------------------------------------------------------------------------------                    
    EXEC MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME =
								 -- Desenvolvimento/homologação
								 FCAV_HOMOLOGACAO,
								 -- Produção
								 --VANZOLINI_BD,
								 @recipients = @destinatario,
								 @blind_copy_recipients = @encaminha_email,
								 @subject = @assunto,
								 @body = @mensagem,
								 @body_format = 'HTML'

-- [FIM] Customização - Não escreva código após esta linha  