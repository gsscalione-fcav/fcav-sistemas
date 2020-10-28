IF EXISTS (SELECT
        *
    FROM SYS.procedures
    WHERE name = 'PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO')
    DROP PROCEDURE dbo.PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO
GO

-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O
--
-- Em produ��o, alterar o c�digo de inicializa��o de @DESTINATARIO e
-- a chamada a SP_SEND_DBMAIL
--
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O


--* ***************************************************************
--*
--*    		*** PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO ***
--*	
--*	USO: 
--*     Chamada via interface do LyceumNG, transa��o TVEST040D
--*     Bot�o 'Enviar formul�rio para a secretaria'
--*
--*	Hist�rico
--*
--*     13/03/2017 - C�digo removido de TR_FCAV_ENVIO_FORMULARIO
--*	
--* ***************************************************************

CREATE PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO (@oferta_de_curso int, @txtenviarsec varchar)
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
            @unidade_fisica = OC.UNIDADE_FISICA,
            @unidade_ensino = CS.FACULDADE
        FROM LY_OFERTA_CURSO OC
        INNER JOIN LY_CURSO CS
            ON (OC.CURSO = CS.CURSO)
        WHERE OC.OFERTA_DE_CURSO = @oferta_de_curso
        -------------------------------------------------------------


        IF @txtenviarsec = 'S'
            AND @oferta_de_curso IS NOT NULL
        BEGIN

            SET @txtenviarsec = 'N'

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

            SET @assunto = 'Dados para abertura de turma no site: ' + @turma

            ---------------------------------------------------------------------------------------   
            --ENCAMINHAMENTO DE C�PIA PARA AS SECRETARIAS  
            --Produ��o  
            --IF (@unidade_fisica = 'USP')
            --BEGIN
            --    SET @destinatario =
            --    'atendimentousp@vanzolini.com.br; suportemkt@vanzolini.com.br'
            --END
            --ELSE
            --BEGIN
               
            --    SET @destinatario =
            --    'secretariapta@vanzolini.org.br; cursos@vanzolini.com.br; suportemkt@vanzolini.com.br'
               
            --END

            --Homologa��o  
            SET @destinatario = 'suporte_techne@vanzolini.org.br'  
            SET @assunto = 'Homologa��o - ' + @assunto  

			---------------------------------------------------------------------------------------      
			--Datas da aulas
			IF(@unidade_ensino = 'ATUAL')
			begin
			declare @datas_curso varchar(200)
			
			set @datas_curso = '<li>' + ISNULL(replace(replace(stuff((
									SELECT distinct
										', ' + quotename(CONVERT(VARCHAR,DATA,103))
									FROM LY_AGENDA 
									WHERE TURMA = @turma
									for xml path('') 
								), 1, 1,''),'[',''),']',''), 'Agenda n�o cadastrada!')
								+ ''
			end
			else
			begin
				set @datas_curso  = ''
			end

			---------------------------------------------------------------------------------------      
			--Telefone de contato da unidade
            SELECT
                @telefone =
                (CASE
                    WHEN (FACULDADE = 'Online' OR
                        FACULDADE = 'Paulista' OR
                        FACULDADE = 'Semipresencial') THEN 'Secretaria Acad�mica Paulista: Via e-mail secretariapta@vanzolini.org.br ou pelo telefone: (11) 3145-3700'
                    WHEN FACULDADE = 'USP' THEN ' Secretaria Acad�mica USP: Via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11)5525-5830'
                    ELSE '.'
                END)
            FROM LY_TURMA
            WHERE TURMA = @turma

            -------------------------------------------------------------
            SELECT
                @inicio_curso =
                ISNULL(CONVERT(varchar, DT_INICIO, 103), '.')
            FROM VW_FCAV_INI_FIM_CURSO_TURMA
            WHERE TURMA = @turma

            -------------------------------------------------------------

            SELECT
                @texto =
                'Solicito a abertura da turma ' + @turma + ' no site para divulga��o.
				<BR>
				<BR>
				<BR>
				<ul><b>Informa��es sobre o Curso </b>
				<li> Categoria do Curso:  <b>' + @categoria + '</b>
				<li> Nome do Curso:  <b>' + @nome_curso + '</b>
				<li> Turma:  <b>' + @nome_turma + '</b>
				<li> Sigla:  <b>' + @turma + '</b>
				<li> Local do curso:  <b>' + @local + '</b>
				<li> Coordenador:  <b>' + @coordenador + '</b>
				<li> Vice Coordenador:  <b>' + @coord_vice + '</b>
				<li> Dura��o:  <b>' + @duracao + '</b>
				<li> Carga Hor�ria Total:  <b>' + @carga_hor_total + ' Horas</b>
				<li> Data In�cio do Curso:  <b>' + @dat_ini + '</b>
				<li> Vencto Matr�cula ap�s Aceite (Dias):  <b>' + @dias_venc_matr + '</b>
				<li> Vencto 1� Mensalidade (Dia/M�s/Ano):  <b>' + @data_venc_mens + '</b>
				<BR>
				<BR> <b>Dias e Hor�rios das aulas</b>
				' + @datas_curso + '
				<li> ' + @dias_hor + '
				<BR>
				<BR> <b>Valores</b>
				<li> Possui Taxa de Matr�cula?:  <b>' + @matr + '</b>
				<li> Taxa de Matr�cula (se houver):  <b>' + @taxa_matricula + '</b>
				<li> Valor de Parcela:  <b>' + @valor_parcela + '</b>
				<li> Quantidade de Parcelas:  <b>' + @qtde_parcela + '</b>
				<li> Desconto para pagto � vista:  <b>' + @desc_avista + '%</b>
				<li> Curriculo:  <b>' + @curriculo + '</b>
				<BR>
				<BR><B>Centro de Custo</B>
				<li> Centro de Custo:  <b>' + @centro_custo + '</b>
				<br>
				<br><b>Crit�rios para Sele��o:</b>
				<li> An�lise Curricular: <b>' + @analise_cur + '</b>
				<li> Entrevista: <b>' + @entrevista + '</b>
				<li> Prova: <b>' + @prova + '</b>
				<li> Reda��o: <b>' + @redacao + '</b>
				<br>
				<br> <B>Processo Seletivo:</B>
				<li> In�cio: <b>' + @data_inicio + '</b>
				<li> T�rmino: <b>' + @data_fim + '</b>
				<BR>
				<BR> <B>Documentos para Matr�cula:</B>
				<li>
				<BR>
				<BR> <B>Altera��o no Conte�do Program�tico?:</B>
				<li>
				</ul>

				<BR>

				Inicio previsto do curso: <b>' + @inicio_curso + '</b><BR>
				Link para a inscri��o LYCEUM: <b>' + @link_insc + '</b>
				<BR><BR>
				Qualquer d�vida estamos � disposi��o.
				<BR><BR>' + @telefone
            FROM LY_TURMA
            WHERE TURMA = @turma

            -------------------------------------------------------------

            EXEC
            MSDB.dbo.SP_SEND_DBMAIL @profile_name =
                                    -- Desenvolvimento/homologa��o
                                    FCAV_HOMOLOGACAO,
                                    -- Produ��o
                                    --VANZOLINI_BD,
                                    @recipients = @destinatario,
                                    @blind_copy_recipients = 'suporte_techne@vanzolini.com.br',
                                    @subject = @assunto,
                                    @body = @texto,
                                    @body_format = HTML
        END

        --------------------------------------------------------------------------
        --condi��es para retornar o valor na grid oculta da tela da oferta do NG, N�O REMOVER. Gabriel
        IF @txtenviarsec = 'N'
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