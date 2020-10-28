


--* ***************************************************************                    
--*                    
--*   *** PROCEDURE a_APoI_Ly_aluno  ***                    
--*                    
--* DESCRICAO:                    
--*  - Está procedure foi criada pela Techne e por isso o nome dela                    
--*  não possui o padrão fcav como está no nome.                    
--*                    
--* PARAMETROS:                    
--*                    
--* USO:                    
--* - Entry point disparada no momento da criação de um aluno                    
--*                    
--* ALTERAÇÕES:                    
--* ALTERADO POR: NATÁLIA ORSETTI (TECHNE)                    
--* DATA: 31/10/2013                    
--* OBJETIVO: Inserir automaticamente dados para envio de e-mail para alunos do Inscricao Online                    
--* DATA: 06/12/2013                    
--* OBJETIVO: Atualizar a senha do aluno igual o CPF                    
--*                    
--* ALTERAÇÃO                    
--* AUTOR: Gabriel Scalione                    
--* DATA: 13/06/2014                    
--* CRIADO UPDATE PARA INSERIR A TURMA NO TURMA_PREF DO ALUNO.                    
--*                    
--* Autor:                    
--* Data de criação:                    
--*                    
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
    ------------------------------------                    
    --COLOCA A HORA NA DT_INGRESSO DO ALUNO                    
    ------------------------------------                    
    UPDATE LY_ALUNO
    SET DT_INGRESSO = GETDATE()
    WHERE ALUNO = @aluno

    -------------------------------------                
    --VARIAVEIS PARA NUMERO DE ALUNO PALESTRA.                    
    DECLARE @max_alunos numeric,
            @alu_inscritos numeric

    --VARIÁVEIS CURSOR ENVIA E-MAIL                    
    DECLARE @pPessoa varchar(50),
            @pEmail varchar(50),
            @pTitulo varchar(500),
            @pMensagem varchar(8000)

    --------------------------------------------                
    --DEFINE O GRUPO DE ALUNO CASO EXISTA                
    DECLARE @grupoDoAluno varchar(20)

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



    ---- INSERE A UNIDADE DE ENSINO SE VIER VAZIA                    
    IF @unidade_ensino IS NULL
    BEGIN
        SET @unidade_ensino = (SELECT
            FACULDADE
        FROM LY_CURSO
        WHERE CURSO = @curso)
    END


    IF (@tipo_ingresso = 'Compra de Curso'
        OR @tipo_ingresso = 'Outros')
    BEGIN

        --ATUALIZA A TURMA_PREF DO ALUNO                    
        UPDATE LY_ALUNO
        SET TURMA_PREF = TURMA
        FROM LY_ALUNO A
        LEFT JOIN LY_HIST_INSCRONLINE O
            ON O.ALUNO = A.ALUNO
        LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA T
            ON O.oferta_de_curso = T.OFERTA_DE_CURSO
        WHERE a.ALUNO = @aluno
        AND A.TURMA_PREF IS NULL

        --BUSCA O NÚMERO MÁXIMO DE ALUNOS DA TURMA PARA AS PALESTRAS    
        SELECT
            @max_alunos = MAX(C.VAGAS)
        FROM LY_TURMA T
        INNER JOIN LY_CURSO C
            ON C.CURSO = T.CURSO
        INNER JOIN LY_PRE_MATRICULA P
            ON T.TURMA = P.TURMA
        WHERE T.UNIDADE_RESPONSAVEL = 'PALES'
        AND T.CLASSIFICACAO = 'EmInscricao'
        AND T.CURRICULO = @curriculo
        AND P.TURMA = T.TURMA

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


        --CONDIÇÕES PARA ENVIAR A MENSAGEM PARA OS ALUNOS DA PALESTRA, CONFIRMAÇÃO OU LISTA DE ESPERA                    
        IF (@alu_inscritos <= @max_alunos
            AND @unidade_ensino = 'PALES')
        BEGIN
            INSERT INTO LY_EMAILS_BATCH
                SELECT
                    P.PESSOA,
                    ISNULL(P.E_MAIL, MAILBOX) EMAIL_PARA,
                    'Confirmação de Inscrição' TITULO_SUBJECT,
                    'Parabéns!<BR>                    
    				Sua Inscrição foi efetivada com SUCESSO.<BR><BR>                    
					Seu código de ALUNO é: ' + @aluno + '<BR><BR>                    
					Qualquer dúvida entre em contato conosco: <br>                    
					&nbsp;&nbsp;&nbsp;&nbsp; • pelo e-mail: palestrapta@vanzolini.org.br ou <BR>                    
					&nbsp;&nbsp;&nbsp;&nbsp; • pelo telefone: (11)3145-3700<BR>' MENSAGEM,
                    NULL ANEXO,
                    'smtp.vanzolini.org.br' EMAIL_SERVER,
                    'sgades@vanzolini.org.br' INSTITUICAO_EMAIL,
                    'vanzolini.org.br' DOMINIO_ORIGEM,
                    'sgades' EMAIL_LOGIN,
                    dbo.crypt('fcav@1256') EMAIL_SENHA,
                    'N' ENVIADA,
                    GETDATE() DATA,
                    '10.200.43.174' IP_LOCAL,   --Na base de producao colocar o IP 10.200.43.69                    
                    'N' E_DOCENTE,
                    160 TEMPO_TIMEOUT,
                    587 PORTA,
                    5 NUMERO_TENTATIVAS,
                    NULL DATA_ULTIMA_TENTATIVA,
                    @@ERROR MENSAGEM_ERRO,
                    'N' UTILIZA_SSL,
                    'Fundação Carlos Alberto Vanzolini' NOME_REMETENTE,
                    'N' UTILIZA_SERV_EMAIL,
                    NULL ANEXO_ID,
                    NULL ORIGEM_PESSOA,
                    NULL FORMA_ENVIO
                FROM LY_PESSOA P
                INNER JOIN LY_ALUNO A
                    ON A.PESSOA = P.PESSOA
                INNER JOIN LY_CURSO C
                    ON C.CURSO = A.CURSO
                WHERE P.PESSOA = @pessoa
                AND A.ALUNO = @aluno
                AND C.FACULDADE = 'PALES'

            DECLARE EnviaEmail CURSOR FOR

            SELECT
                PESSOA,
                EMAIL_PARA,
                TITULO_SUBJECT,
                MENSAGEM
            FROM LY_EMAILS_BATCH
            WHERE ENVIADA = 'N'

            OPEN EnviaEmail

            FETCH NEXT FROM EnviaEMail INTO @pPessoa, @pEmail, @pTitulo, @pMensagem

            WHILE @@FETCH_STATUS = 0
            BEGIN

                EXEC
                MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME =
                                        -- Desenvolvimento/homologação
                                        FCAV_HOMOLOGACAO,
                                        -- Produção
                                        --VANZOLINI_BD,
                                        @recipients = @pEmail,
                                        @copy_recipients = NULL,
                                        @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',
                                        @subject = @pTitulo,
                                        @body = @pMensagem,
                                        @body_format = 'HTML'

                UPDATE LY_EMAILS_BATCH
                SET ENVIADA = 'S'
                WHERE PESSOA = @pPessoa
                AND TITULO_SUBJECT = @pTitulo

                FETCH NEXT FROM EnviaEmail INTO @pPessoa, @pEmail, @pTitulo, @pMensagem

            END
            CLOSE EnviaEmail
            DEALLOCATE EnviaEmail
        END --FIM DA MENSAGEM DA CONFIRMAÇÃO DE INSCRIÇÃO PARA A PALESTRA                    
        ELSE
        BEGIN

            IF (@alu_inscritos > @max_alunos
                AND @unidade_ensino = 'PALES')
            BEGIN
                ---------------------------------------------------------------------------------------                    
                /* MENSAGEM PARA ALUNOS EM LISTA DE ESPERA */
                ---------------------------------------------------------------------------------------                    
                INSERT INTO LY_EMAILS_BATCH
                    SELECT DISTINCT
                        P.PESSOA,
                        ISNULL(P.E_MAIL, MAILBOX) EMAIL_PARA,
                        'LISTA DE ESPERA' TITULO_SUBJECT,
                        '<BR>                    
						Sua inscriçao está confirmada em LISTA DE ESPERA.                    
						<BR><BR>                    
						Por favor, pedimos que aguarde a Secretaria Acadêmica entrar em contato com você para confirmar a sua vaga.<BR><BR>                    
						Seu código de ALUNO é: ' + @aluno + '<BR><BR>                    
						Qualquer dúvida entre em contato conosco: <br>                    
						&nbsp;&nbsp;&nbsp;&nbsp; • pelo e-mail: palestrapta@vanzolini.org.br ou <BR>                    
						&nbsp;&nbsp;&nbsp;&nbsp; • pelo telefone: (11)3145-3700<BR>' MENSAGEM,
                        NULL ANEXO,
                        'smtp.vanzolini.org.br' EMAIL_SERVER,
                        'sgades@vanzolini.org.br' INSTITUICAO_EMAIL,
                        'vanzolini.org.br' DOMINIO_ORIGEM,
                        'sgades' EMAIL_LOGIN,
                        dbo.crypt('fcav@1256') EMAIL_SENHA,
                        'N' ENVIADA,
                        GETDATE() DATA,
                        '10.200.43.174' IP_LOCAL,    --Na base de producao colocar o IP 10.200.43.69                    
                        'N' E_DOCENTE,
                        160 TEMPO_TIMEOUT,
                        587 PORTA,
                        5 NUMERO_TENTATIVAS,
                        NULL DATA_ULTIMA_TENTATIVA,
                        @@ERROR MENSAGEM_ERRO,
                        'N' UTILIZA_SSL,
                        'Fundação Carlos Alberto Vanzolini' NOME_REMETENTE,
                        'N' UTILIZA_SERV_EMAIL,
                        NULL ANEXO_ID,
                        NULL ORIGEM_PESSOA,
                        NULL FORMA_ENVIO
                    FROM LY_PESSOA P
                    INNER JOIN LY_ALUNO A
                        ON A.PESSOA = P.PESSOA
                    INNER JOIN LY_CURSO C
                        ON C.CURSO = A.CURSO
                    WHERE P.PESSOA = @pessoa
                    AND A.ALUNO = @aluno
                    AND c.FACULDADE = 'PALES'

                ----CURSOR ENVIA E-MAIL                    
                --DECLARE @pPessoa VARCHAR(50), @pEmail VARCHAR(50), @pTitulo VARCHAR(500), @pMensagem VARCHAR(8000)                    

                DECLARE EnviaEmail CURSOR FOR

                SELECT
                    PESSOA,
                    EMAIL_PARA,
                    TITULO_SUBJECT,
                    MENSAGEM
                FROM LY_EMAILS_BATCH
                WHERE ENVIADA = 'N'

                OPEN EnviaEmail

                FETCH NEXT FROM EnviaEMail INTO @pPessoa, @pEmail, @pTitulo, @pMensagem

                WHILE @@FETCH_STATUS = 0
                BEGIN

                    EXEC
                    MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME =
                                            -- Desenvolvimento/homologação
                                            FCAV_HOMOLOGACAO,
                                            -- Produção
                                            --VANZOLINI_BD,
                                            @recipients = @pEmail,
                                            @copy_recipients = NULL,
                                            @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',
                                            @subject = @pTitulo,
                                            @body = @pMensagem,
                                            @body_format = 'HTML'

                    UPDATE LY_EMAILS_BATCH
                    SET ENVIADA = 'S'
                    WHERE PESSOA = @pPessoa
                    AND TITULO_SUBJECT = @pTitulo

                    FETCH NEXT FROM EnviaEmail INTO @pPessoa, @pEmail, @pTitulo, @pMensagem

                END
                CLOSE EnviaEmail
                DEALLOCATE EnviaEmail
            END --FIM DA MENSAGEM PARA ALUNOS EM LISTA DE ESPERA                    

        END --FIM ELSE                    

    END--FIM DA COMPRA DE CURSO                    

    ELSE
    BEGIN
        UPDATE LY_ALUNO
        SET TURMA_PREF = TURMA
        FROM LY_ALUNO A
        JOIN VW_FCAV_INI_FIM_CURSO_TURMA V
            ON A.CONCURSO = V.CONCURSO
            AND A.CURSO = V.CURSO
            AND A.TURNO = V.TURNO
            AND A.CURRICULO = V.CURRICULO

        WHERE ALUNO = @aluno
    END

    ---------------------------------------------------------------------------------------                    
    --INSERIR AUTOMATICAMENTE DADOS DE ENVIO DE E-MAIL PARA ALUNOS DO INSCRIÇÃO ONLINE                    
    ---------------------------------------------------------------------------------------                    
    INSERT INTO LY_EMAILS_BATCH
        SELECT DISTINCT
            P.PESSOA,
            ISNULL(P.E_MAIL, MAILBOX) EMAIL_PARA,
            'Confirmação de Pré-Matrícula' TITULO_SUBJECT,
            'Parabéns!<BR>                    
		     Sua Pré-Matrícula foi efetuada com sucesso.<BR><BR>                    
		     Seu código de ALUNO é: ' + @aluno + '<BR><BR>                    
		     Condição obrigatória para efetivação da matrícula: <BR>                    
		     &nbsp;&nbsp;&nbsp;&nbsp;• A matrícula está condicionada ao aceite e emissão do contrato de prestação de serviços,     
		     entrega da documentação e pagamento do boleto.' MENSAGEM,
            NULL ANEXO,
            'smtp.vanzolini.org.br' EMAIL_SERVER,
            'sgades@vanzolini.org.br' INSTITUICAO_EMAIL,
            'vanzolini.org.br' DOMINIO_ORIGEM,
            'sgades' EMAIL_LOGIN,					--'gestao.cursos'
            dbo.crypt('fcav@1256') EMAIL_SENHA,		--'$]Oz65mB_Pl'
            'N' ENVIADA,
            GETDATE() DATA,
            '10.200.43.174' IP_LOCAL,    --Na base de produção colocar o IP 10.200.43.69
            'N' E_DOCENTE,
            160 TEMPO_TIMEOUT,
            587 PORTA,
            5 NUMERO_TENTATIVAS,
            NULL DATA_ULTIMA_TENTATIVA,
            @@ERROR MENSAGEM_ERRO,
            'N' UTILIZA_SSL,
            'Fundação Carlos Alberto Vanzolini' NOME_REMETENTE,
            'N' UTILIZA_SERV_EMAIL,
            NULL ANEXO_ID,
            NULL ORIGEM_PESSOA,
            NULL FORMA_ENVIO
        FROM LY_PESSOA P
        INNER JOIN LY_ALUNO A
            ON A.PESSOA = P.PESSOA
        INNER JOIN LY_CURSO C
            ON C.CURSO = A.CURSO
        WHERE P.PESSOA = @pessoa
        AND A.ALUNO = @aluno
        AND c.FACULDADE NOT LIKE 'PALES'


    DECLARE EnviaEmail CURSOR FOR

    SELECT
        PESSOA,
        EMAIL_PARA,
        TITULO_SUBJECT,
        MENSAGEM
    FROM LY_EMAILS_BATCH
    WHERE ENVIADA = 'N'

    OPEN EnviaEmail

    FETCH NEXT FROM EnviaEMail INTO @pPessoa, @pEmail, @pTitulo, @pMensagem

    WHILE @@FETCH_STATUS = 0
    BEGIN

        EXEC
        MSDB.dbo.SP_SEND_DBMAIL @PROFILE_NAME =
                                -- Desenvolvimento/homologação
                                FCAV_HOMOLOGACAO,
                                -- Produção
                                --VANZOLINI_BD,
                                @recipients = @pEmail,
                                @copy_recipients = NULL,
                                @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',
                                @subject = @pTitulo,
                                @body = @pMensagem,
                                @body_format = 'HTML'

        UPDATE LY_EMAILS_BATCH
        SET ENVIADA = 'S'
        WHERE PESSOA = @pPessoa
        AND TITULO_SUBJECT = @pTitulo

        FETCH NEXT FROM EnviaEmail INTO @pPessoa, @pEmail, @pTitulo, @pMensagem

    END


    CLOSE EnviaEmail
    DEALLOCATE EnviaEmail

-- [FIM] Customização - Não escreva código após esta linha  