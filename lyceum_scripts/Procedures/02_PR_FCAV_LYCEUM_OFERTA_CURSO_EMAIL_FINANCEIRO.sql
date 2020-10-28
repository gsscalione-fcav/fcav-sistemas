IF EXISTS (SELECT
        *
    FROM SYS.procedures
    WHERE name = 'PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_FINANCEIRO')
    DROP PROCEDURE dbo.PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_FINANCEIRO
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
--*    		*** PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_FINANCEIRO ***
--*	
--*	USO: 
--*     Chamada via interface do LyceumNG, transação TVEST040D
--*     Botão 'Enviar formulário para o financeiro'
--*
--*	Histórico
--*
--*     13/03/2017 - Código removido de TR_FCAV_ENVIO_FORMULARIO
--*	
--* ***************************************************************

CREATE PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_FINANCEIRO (@oferta_de_curso int, @txtenviarfinan varchar)
AS
    SET NOCOUNT ON
    BEGIN
        DECLARE @turma varchar(20)
        DECLARE @curriculo varchar(20)
        DECLARE @turno varchar(20)
        DECLARE @centro_custo varchar(20)
        DECLARE @inicio_curso varchar(30)
        DECLARE @oferta_curso varchar(200)

        DECLARE @assunto varchar(100)
        DECLARE @destinatario varchar(200)
        DECLARE @encaminha_email varchar(200)
        DECLARE @telefone varchar(200)
        DECLARE @texto varchar(8000)

        DECLARE @valor_total varchar(2000)
        DECLARE @taxa_matricula varchar(2000)
        DECLARE @valor_parcela varchar(2000)
        DECLARE @qtde_parcela varchar(2000)
        DECLARE @desc_avista varchar(200)
        DECLARE @dias_venc_matr varchar(2000)
        DECLARE @data_venc_mens varchar(2000)

        DECLARE @categoria varchar(20)
        DECLARE @nome_curso varchar(200)
        DECLARE @nome_turma varchar(200)
        DECLARE @local varchar(20)
        DECLARE @coordenador varchar(100)
        DECLARE @coord_vice varchar(100)
        DECLARE @duracao varchar(200)
        DECLARE @carga_hor_total varchar(20)
        DECLARE @dat_ini varchar(20)
        DECLARE @vencto_1_mens varchar(20)
        DECLARE @matr varchar(8)
        DECLARE @analise_cur varchar(8)
        DECLARE @entrevista varchar(8)
        DECLARE @prova varchar(8)
        DECLARE @redacao varchar(8)
        DECLARE @data_inicio varchar(20)
        DECLARE @data_fim varchar(20)
        DECLARE @alteracao_cont_prog varchar(8)
        DECLARE @dias_hor varchar(200)
        DECLARE @link_insc varchar(200)
        DECLARE @unidade_fisica varchar(20)
        DECLARE @unidade_ensino varchar(20)


        -------------------------------------------------------------
        SELECT
            @unidade_fisica = UPPER(OC.UNIDADE_FISICA),
            @unidade_ensino = CS.FACULDADE
        FROM LY_OFERTA_CURSO OC
        INNER JOIN LY_CURSO CS
            ON (OC.CURSO = CS.CURSO)
        WHERE OC.OFERTA_DE_CURSO = @oferta_de_curso
        -------------------------------------------------------------

        IF @txtenviarfinan = 'S'
            AND @oferta_de_curso IS NOT NULL
        BEGIN

            SET @txtenviarfinan = 'N'

            EXECUTE
            PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMMON @oferta_de_curso,
                                                     --
                                                     @turma OUTPUT,
                                                     @curriculo OUTPUT,
                                                     @turno OUTPUT,
                                                     @valor_total OUTPUT,
                                                     @taxa_matricula OUTPUT,
                                                     @valor_parcela OUTPUT,
                                                     @qtde_parcela OUTPUT,
                                                     @desc_avista OUTPUT,
                                                     @dias_venc_matr OUTPUT,
                                                     @data_venc_mens OUTPUT,
                                                     @centro_custo OUTPUT,
                                                     @oferta_curso OUTPUT,
                                                     --
                                                     @categoria OUTPUT,
                                                     @nome_curso OUTPUT,
                                                     @nome_turma OUTPUT,
                                                     @local OUTPUT,
                                                     @coordenador OUTPUT,
                                                     @coord_vice OUTPUT,
                                                     @duracao OUTPUT,
                                                     @carga_hor_total OUTPUT,
                                                     @dat_ini OUTPUT,
                                                     @vencto_1_mens OUTPUT,
                                                     @matr OUTPUT,
                                                     @analise_cur OUTPUT,
                                                     @entrevista OUTPUT,
                                                     @prova OUTPUT,
                                                     @redacao OUTPUT,
                                                     @data_inicio OUTPUT,
                                                     @data_fim OUTPUT,
                                                     @alteracao_cont_prog OUTPUT,
                                                     @dias_hor OUTPUT,
                                                     @link_insc OUTPUT

            -------------------------------------------------------------

            SET @assunto = 'Solicitação - Cadastro de Plano de Pagamento para Turma: ' + @turma

            -------------------------------------------------------------

            SET @destinatario =
            -- Desenvolvimento/homologação
            --'suporte_techne@vanzolini.org.br'

            -- Produção
            'suportefinanceiro@vanzolini.com.br; '

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
                @telefone =
                (CASE
                    WHEN (FACULDADE = 'Online' OR
                        FACULDADE = 'Paulista' OR
                        FACULDADE = 'Semipresencial') THEN 'Secretaria Acadêmica Paulista: Via e-mail secretariapta@vanzolini.org.br ou pelo telefone: (11) 3145-3700'
                    WHEN FACULDADE = 'USP' THEN 'Secretaria Acadêmica USP: Via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11) 5525-5830'
                    ELSE '.'
                END)
            FROM LY_TURMA
            WHERE TURMA = @turma

            -------------------------------------------------------------
            SELECT
                @inicio_curso = ISNULL(CONVERT(varchar, DT_INICIO, 103), '.')
            FROM VW_FCAV_INI_FIM_CURSO_TURMA
            WHERE TURMA = @turma

            -------------------------------------------------------------
            SELECT
                @texto =
                'Solicito o cadastro referente ao Plano de Pagamento para a turma ' + @turma + ', conforme dados mencionados abaixo.
					<BR>
					<ul>
					<li> Nome do Curso:  <b>' + @nome_curso + '</b>
					<li> Turma:  <b>' + @nome_turma + '</b>
					<li> Local do curso:  <b>' + @local + '</b>
					<li> Coordenador:  <b>' + @coordenador + '</b>
					<li> Vice Coordenador:  <b>' + @coord_vice + '</b>
					<li> Duração:  <b>' + @duracao + '</b>
					<li> Carga Horária Total:  <b>' + @carga_hor_total + ' Horas</b>
					<li> Centro de Custo:  <b>' + @centro_custo + '</b>
					<li> Curriculo Vigente:  <b>' + @curriculo + '</b>
					<li> Turno da Turma:  <b>' + @turno + '</b>
					<li> Oferta de Curso:  <b>' + @oferta_curso + '</b>
					<li> Valor do Total do Curso sem desconto:  <b>' + @valor_total + '</b>
					<li> Taxa de Matrícula (se houver):  <b>' + @taxa_matricula + '</b>
					<li> Valor de Parcela:  <b>' + @valor_parcela + '</b>
					<li> Quantidade de Parcelas:  <b>' + @qtde_parcela + '</b>
					<li> Desconto para pagto à vista:  <b>' + @desc_avista + '%</b>
					<li> Vencto Matrícula após Aceite (Dias):  <b>' + @dias_venc_matr + '</b>
					<li> Vencto 1ª Mensalidade (Dia/Mês/Ano):  <b>' + @data_venc_mens + '</b>
					</ul>

					<BR>

					Inicio previsto do curso: <b>' + @inicio_curso + '</b>
					<BR><BR>
					Qualquer dúvida estamos à disposição.
					<BR><BR>' + @telefone
            FROM LY_TURMA
            WHERE TURMA = @turma

            -------------------------------------------------------------

            EXEC
            MSDB.dbo.SP_SEND_DBMAIL @profile_name =
                                    -- Desenvolvimento/homologação
                                    --FCAV_HOMOLOGACAO,
                                    -- Produção
                                    VANZOLINI_BD,
                                    @recipients = @destinatario,
                                    @copy_recipients = @encaminha_email,
                                    @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',
                                    @subject = @assunto,
                                    @body = @texto,
                                    @body_format = HTML
        END
        --------------------------------------------------------------------------
        ----condições para retornar o valor na grid do NG, NÃO REMOVER. Gabriel
        IF @txtenviarfinan = 'N'
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