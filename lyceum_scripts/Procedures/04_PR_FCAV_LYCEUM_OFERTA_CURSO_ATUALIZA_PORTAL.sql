IF EXISTS (SELECT
        *
    FROM SYS.procedures
    WHERE name = 'PR_FCAV_LYCEUM_OFERTA_CURSO_ATUALIZA_PORTAL')
    DROP PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_ATUALIZA_PORTAL
GO

-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO
--
-- Em produção, alterar o código de inicialização de @DESTINATARIO e
-- @encaminha_email e a chamada a SP_SEND_DBMAIL
--
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO

--* ***************************************************************
--*
--*    		*** PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_ATUALIZA_PORTAL ***
--*	
--*	USO: 
--*     Chamada via interface do LyceumNG, transação TVEST040D
--*     Botão 'Atuallizar os dados do Portal'
--*
--*	Histórico
--*
--*     13/03/2017 - Código removido de TR_FCAV_ENVIO_FORMULARIO
--*	
--* ***************************************************************

CREATE PROCEDURE dbo.PR_FCAV_LYCEUM_OFERTA_CURSO_ATUALIZA_PORTAL (@oferta_de_curso int, @txtatualizaportal varchar)
AS
BEGIN
    DECLARE @turma T_CODIGO

    DECLARE @assunto varchar(100)
    DECLARE @destinatario varchar(200)
    DECLARE @encaminha_email varchar(200)
    DECLARE @texto varchar(8000)

    DECLARE @objetivos varchar(max)
    DECLARE @programa varchar(max)
    DECLARE @publico varchar(max)
    DECLARE @corpo_doc varchar(max)
    DECLARE @invest varchar(max)
    DECLARE @apresentacao varchar(max)
    DECLARE @diferencial varchar(max)
    DECLARE @perfil varchar(max)
    DECLARE @certific varchar(max)
    DECLARE @metodologia varchar(max)
    DECLARE @sistema_aval varchar(max)
    DECLARE @proc_selet varchar(max)
    DECLARE @valor varchar(20)
    DECLARE @data_ini_turma varchar(10)
    DECLARE @data_fim_turma varchar(10)
    DECLARE @data_ini_oferta varchar(10)
    DECLARE @data_fim_oferta varchar(10)
    DECLARE @sit_turma varchar(15)
    DECLARE @unidade_fisica varchar(20)
    DECLARE @unidade_ensino varchar(20)
	declare @dia_horario varchar (100)

    SET @objetivos = NULL
    SET @programa = NULL
    SET @publico = NULL
    SET @corpo_doc = NULL
    SET @invest = NULL
    SET @apresentacao = NULL
    SET @diferencial = NULL
    SET @perfil = NULL
    SET @certific = NULL
    SET @metodologia = NULL
    SET @sistema_aval = NULL
    SET @proc_selet = NULL
    SET @valor = NULL
    SET @data_ini_turma = NULL
    SET @data_fim_turma = NULL
    SET @data_ini_oferta = NULL
    SET @data_fim_oferta = NULL
    SET @sit_turma = NULL
	set @dia_horario = NULL
	-------------------------------------------------------------
	
    SELECT
        @turma = vw_cur_tur.TURMA
    FROM VW_FCAV_INI_FIM_CURSO_TURMA vw_cur_tur /* TURMA em LY_OFERTA_CURSO não é preenchida */
    WHERE vw_cur_tur.OFERTA_DE_CURSO = @oferta_de_curso
    
    -------------------------------------------------------------
    SELECT
        @unidade_fisica = UPPER(OC.UNIDADE_FISICA),
        @unidade_ensino = CS.FACULDADE
    FROM LY_OFERTA_CURSO OC
    INNER JOIN LY_CURSO CS
        ON (OC.CURSO = CS.CURSO)
    WHERE OC.OFERTA_DE_CURSO =  @oferta_de_curso


    IF @txtatualizaportal = 'S'
        AND @oferta_de_curso IS NOT NULL
    BEGIN

        SET @txtatualizaportal = 'N'

        SET @assunto = 'Dados do portal atualizados. TURMA: ' + @turma

        -------------------------------------------------------------
        SELECT
            @destinatario =
            -- Desenvolvimento/homologação
            --'suporte_techne@vanzolini.org.br'

            -- Produção
            'suportemkt@vanzolini.com.br'

        ---------------------------------------------------------------------------------------   
        --ENCAMINHAMENTO DE CÓPIA PARA AS SECRETARIAS  
        --Produção  
        IF (@unidade_fisica = 'USP'or @unidade_fisica = 'Online USP')
        BEGIN
            SET @encaminha_email =
            'atendimentousp@vanzolini.com.br;'
        END
        ELSE
        BEGIN
            IF (@unidade_fisica = 'ONLINE')
			BEGIN
				SET @encaminha_email =
				'atendimentousp@vanzolini.com.br; secretariapta@vanzolini.com.br;secretariausp@vanzolini.com.br;'
			END
			ELSE
			BEGIN
				SET @encaminha_email =
				'secretariapta@vanzolini.com.br; '
			END
        END

        --Homologação  
        --SET @encaminha_email = 'suporte_techne@vanzolini.org.br'  
        --SET @assunto = 'Homologação - ' + @assunto  

        ---------------------------------------------------------------------------------------      

        SELECT
            @objetivos =
                        CASE
                            WHEN V.OBJETIVOS = ISNULL(T.OBJETIVOS, '...') THEN 'OK'
                            ELSE 'ALTERADO'
                        END,
            @programa =
                       CASE
                           WHEN V.PROGRAMA = ISNULL(T.PROGRAMA, '...') THEN 'OK'
                           ELSE 'ALTERADO'
                       END,
            @publico =
                      CASE
                          WHEN V.PUBLICO_ALVO = ISNULL(T.PUBLICO_ALVO, '...') THEN 'OK'
                          ELSE 'ALTERADO'
                      END,
            @corpo_doc =
                        CASE
                            WHEN V.CORPO_DOCENTE = ISNULL(T.CORPO_DOCENTE, '...') THEN 'OK'
                            ELSE 'ALTERADO'
                        END,
            @invest =
                     CASE
                         WHEN V.INVESTIMENTO = ISNULL(T.INVESTIMENTO, '...') THEN 'OK'
                         ELSE 'ALTERADO'
                     END,
            @apresentacao =
                           CASE
                               WHEN V.APRESENTACAO_CURSO = ISNULL(T.APRESENTACAO_CURSO, '...') THEN 'OK'
                               ELSE 'ALTERADO'
                           END,
            @diferencial =
                          CASE
                              WHEN V.DIFERENCIAL = ISNULL(T.DIFERENCIAL, '...') THEN 'OK'
                              ELSE 'ALTERADO'
                          END,
            @perfil =
                     CASE
                         WHEN V.PERFIL_ALUNO = ISNULL(T.PERFIL_ALUNO, '...') THEN 'OK'
                         ELSE 'ALTERADO'
                     END,
            @certific =
                       CASE
                           WHEN V.CERTIFICACAO = ISNULL(T.CERTIFICACAO, '...') THEN 'OK'
                           ELSE 'ALTERADO'
                       END,
            @metodologia =
                          CASE
                              WHEN V.METODOLOGIA = ISNULL(T.METODOLOGIA, '...') THEN 'OK'
                              ELSE 'ALTERADO'
                          END,
            @sistema_aval =
                           CASE
                               WHEN V.SISTEMA_AVALIACAO = ISNULL(T.SISTEMA_AVALIACAO, '...') THEN 'OK'
                               ELSE 'ALTERADO'
                           END,
            @proc_selet =
                         CASE
                             WHEN V.PROCESSO_SELETIVO = ISNULL(T.PROCESSO_SELETIVO, '...') THEN 'OK'
                             ELSE 'ALTERADO'
                         END,
            @valor =
                    CASE
                        WHEN V.VALOR_CURSO = ISNULL(T.VALOR_CURSO, '...') THEN 'OK'
                        ELSE 'ALTERADO'
                    END,
            @data_ini_turma =
                             CASE
                                 WHEN V.DT_INICIO = T.DT_INICIO THEN 'OK'
                                 ELSE 'ALTERADO'
                             END,
			@dia_horario =
                             CASE
                                 WHEN V.DIA_HORARIO_AULAS = T.DIA_HORARIO_AULAS THEN 'OK'
                                 ELSE 'ALTERADO'
                             END,
            @data_fim_turma =
                             CASE
                                 WHEN V.DT_FIM = T.DT_FIM THEN 'OK'
                                 ELSE 'ALTERADO'
                             END,
            @data_ini_oferta =
                              CASE
                                  WHEN V.DTINI_OFERTA = T.DTINI_OFERTA THEN 'OK'
                                  ELSE 'ALTERADO'
                              END,
            @data_fim_oferta =
                              CASE
                                  WHEN V.DTFIM_OFERTA = T.DTFIM_OFERTA THEN 'OK'
                                  ELSE 'ALTERADO'
                              END,
            @sit_turma =
                        CASE
                            WHEN V.SIT_TURMA = ISNULL(T.SIT_TURMA, '...') THEN 'OK'
                            ELSE 'ALTERADO'
                        END
        FROM VW_FCAV_INFO_CURSO_PORTAL2 V
        INNER JOIN FCAV_INFO_CURSO_PORTAL2 T
            ON (V.TURMA = T.TURMA
            AND V.CURSO = T.CURSO
            AND V.CURRICULO = T.CURRICULO
            AND V.DISCIPLINA = T.DISCIPLINA
            AND ISNULL(V.DOCENTE, '0000') = ISNULL(T.DOCENTE, '0000')
            AND V.PERIODO = T.PERIODO)
        WHERE T.TURMA_PREF = @turma
        -------------------------------------------------------------

        SELECT
            @texto =
                    CASE
                        WHEN ISNULL((SELECT DISTINCT
                                1
                            FROM FCAV_INFO_CURSO_PORTAL2
                            WHERE TURMA_PREF = @turma)
                            , '0') = 1 THEN (SELECT
                                'Foi feita atualização dos dados de uma turma para portal da Fundação.
						<BR>
						<BR>
						<ul>
						<li> Turma:  <b>' + @turma + '</b>
						<li> Objetivos: ' + @objetivos + '
						<li> Programa: ' + @programa + '
						<li> Público Alvo: ' + @publico + '
						<li> Corpo Docente: ' + @corpo_doc + '
						<li> Investimento: ' + @invest + '
						<li> Apresentação: ' + @apresentacao + '
						<li> Diferencial: ' + @diferencial + '
						<li> Perfil: ' + @perfil + '
						<li> Certificação: ' + @certific + '
						<li> Metodologia: ' + @metodologia + '
						<li> Sistema Avaliação: ' + @sistema_aval + '
						<li> Processo Seletivo: ' + @proc_selet + '
						<li> Valor do Curso: ' + @valor + '
						<li> Data início Turma: ' + @data_ini_turma + '
						<li> Data fim Turma: ' + @data_fim_turma + '
						<li> Horário: ' + @dia_horario + '
						<li> Data início Oferta: ' + @data_ini_oferta + '
						<li> Data fim Oferta: ' + @data_fim_oferta + '
						<li> Situação da Turma: ' + @sit_turma + '
						</ul>
						<BR> ')
                        ELSE (SELECT
                                'Nova turma cadastrada.<BR>Código: ' + @turma + '<BR>')
                    END
        -------------------------------------------------------------

        EXEC
        MSDB.dbo.SP_SEND_DBMAIL @profile_name =
                                -- Desenvolvimento/homologação
                                --FCAV_HOMOLOGACAO,
                                -- Produção
                                VANZOLINI_BD,
                                @recipients = @destinatario,
                                @copy_recipients = @encaminha_email,
                                @blind_copy_recipients = 'suporte_techne@vanzolini.com.br',
                                @subject = @assunto,
                                @body = @texto,
                                @body_format = HTML

        -- *** UPDATE PARA ATUALIZAR A TABELA QUE MANDA AS INFORMAÇÕES DAS TURMAS PARA O PORTAL
        -- *** INICIO
        DELETE FCAV_INFO_CURSO_PORTAL2
        WHERE TURMA = @turma

        ALTER TABLE FCAV_INFO_CURSO_PORTAL2
        DROP COLUMN [SEQUENCIAL]

        INSERT FCAV_INFO_CURSO_PORTAL2
            SELECT
                *,
                NULL AS DT_IMPORT
            FROM VW_FCAV_INFO_CURSO_PORTAL2
            WHERE TURMA = @turma

        ALTER TABLE FCAV_INFO_CURSO_PORTAL2
        ADD [SEQUENCIAL] [int] IDENTITY (1, 1) NOT NULL
    END
    --------------------------------------------------------------------------
    --condições para retornar o valor na grid oculta da tela da oferta do NG, NÃO REMOVER. Gabriel
    IF @txtatualizaportal = 'N'
    BEGIN
        SELECT
            5 AS VALOR
    END
    ELSE
    BEGIN
        SELECT
            3 AS VALOR
    END
--------------------------------------------------------------------------	
END
GO