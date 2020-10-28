
ALTER TRIGGER [dbo].[TR_FCAV_SELEC_COORD]
ON [dbo].[FCAV_CANDIDATOS]
AFTER INSERT, UPDATE

AS

    DECLARE @candidato varchar(20)
    DECLARE @pessoa varchar(20)
    DECLARE @nome varchar(100)
    DECLARE @concurso varchar(20)
	DECLARE @curso varchar(20)
    DECLARE @texto varchar(8000)
    DECLARE @destinatario varchar(100)
    DECLARE @assunto varchar(100)
    DECLARE @obs1 varchar(2000)
    DECLARE @obs2 varchar(2000)
    DECLARE @obs3 varchar(2000)
    DECLARE @obs4 varchar(2000)
    DECLARE @obs5 varchar(2000)
    DECLARE @obs6 varchar(2000)
    DECLARE @obs7 varchar(2000)
    DECLARE @obs8 varchar(2000)
    DECLARE @obs9 varchar(2000)
    DECLARE @obs10 varchar(2000)
    DECLARE @situacao varchar(30)
    DECLARE @unidade_fisica varchar(20)
    DECLARE @unidade_responsavel varchar(20)

    SET @candidato = NULL
    SET @pessoa = NULL
    SET @nome = NULL
    SET @concurso = NULL
	SET @curso = NULL
    SET @texto = NULL
    SET @destinatario = NULL
    SET @assunto = NULL
    SET @obs1 = NULL
    SET @obs2 = NULL
    SET @obs3 = NULL
    SET @obs4 = NULL
    SET @obs5 = NULL
    SET @obs6 = NULL
    SET @obs7 = NULL
    SET @obs8 = NULL
    SET @obs9 = NULL
    SET @obs10 = NULL
    SET @situacao = NULL
    SET @unidade_fisica = NULL
    SET @unidade_responsavel = NULL


    BEGIN
        /*---------------------------------------------------------------------------
            Caso entre outro tipo de curso com a letra diferente, acrescentar a letra referente ao curso na variavel @verificador.  
            Identifica se � candidato ou aluno de venda direta.  
         Ex. P - Palestra, a variavel @verificador ficar�: "ACEP". A ordem das letras n�o � importante.  
        -----------------------------------------------------------------------------*/
        DECLARE @verificador varchar(20)
        DECLARE @char varchar(1)

        SET @verificador = 'ACE'  -- Acrescentar a letra referente ao curso, caso necess�rio.  

        SELECT
            @candidato = CANDIDATO,
            @concurso = CONCURSO,
            @pessoa = PESSOA,
            @char = SUBSTRING(CANDIDATO, 1, 1)
        FROM INSERTED

       --------------------------------------------------------
        SELECT
            @unidade_fisica = oc.UNIDADE_FISICA,
            @unidade_responsavel = CS.FACULDADE,
			@curso = cs.CURSO
        FROM LY_OFERTA_CURSO OC
        INNER JOIN LY_CURSO CS
            ON CS.CURSO = OC.CURSO
        WHERE oc.CONCURSO = @concurso
        --------------------------------------------------------

        IF (CHARINDEX(@char, @verificador) <= 0)-- Retorna a posi��o do caracter, se for menor ou igual a 0 significa que o primeiro caracter do c�digo do candidato n�o � das letras definidas na @verificador  
        BEGIN

            SELECT
                @candidato = CANDIDATO,
                @concurso = CONCURSO,
                @pessoa = PESSOA
            FROM INSERTED

            SET @nome = (SELECT
                NOME_COMPL
            FROM LYCEUM.dbo.LY_CANDIDATO C
            WHERE C.CANDIDATO = @candidato
            AND C.CONCURSO = @concurso)

            SELECT DISTINCT
                @obs1 = ISNULL(OBSERV1, ' '),
                @obs2 = ISNULL(OBSERV2, ' '),
                @obs3 = ISNULL(OBSERV3, ' '),
                @obs4 = ISNULL(OBSERV4, ' '),
                @obs5 = ISNULL(OBSERV5, ' '),
                @obs6 = ISNULL(OBSERV6, ' '),
                @obs7 = ISNULL(OBSERV7, ' '),
                @obs8 = ISNULL(OBSERV8, ' '),
                @obs9 = ISNULL(OBSERV9, ' '),
                @obs10 = ISNULL(OBSERV10, ' ')
            FROM FCAV_CANDIDATOS
            WHERE CANDIDATO = @candidato
            AND CONCURSO = @concurso

            SELECT
                @situacao = (CASE
                    WHEN (SELECT
                            CONVOCADO
                        FROM FCAV_CANDIDATOS
                        WHERE CANDIDATO = @candidato
                        AND CONCURSO = @concurso)
                        = '0' THEN 'N�O AVALIADO'
                    WHEN (SELECT
                            CONVOCADO
                        FROM FCAV_CANDIDATOS
                        WHERE CANDIDATO = @candidato
                        AND CONCURSO = @concurso)
                        = '1' THEN 'SELECIONADO'
                    WHEN (SELECT
                            CONVOCADO
                        FROM FCAV_CANDIDATOS
                        WHERE CANDIDATO = @candidato
                        AND CONCURSO = @concurso)
                        = '2' THEN 'RECUSADO'
                    ELSE 'N�O AVALIADO'
                END)

            SET @texto =
            'Existe uma nova intera��o com o candidato.<br>  
			  <br>  
			  C�digo: '   + @candidato + '<br>  
			  Nome: '	  + @nome + '<br>  
			  Situa��o: ' + @situacao + '<br>  
			  Concurso: ' + @concurso + '<br>  
			  <br>  
			  <B>Observa��o1:</B><br>'
            + @obs1 + '<br>  
			  <BR>  
			  <B>Observa��o2:</B><br>'
            + @obs2 + '<br>  
			  <BR>  
			  <B>Observa��o3:</B><br>'
            + @obs3 + '<br>  
			  <BR>  
			  <B>Observa��o4:</B><br>'
            + @obs4 + '<br>  
			  <BR>  
			  <B>Observa��o5:</B><br>'
            + @obs5 + '<br>  
			  <BR>  
			  <B>Observa��o6:</B><br>'
            + @obs6 + '<br>  
			  <BR>  
			  <B>Observa��o7:</B><br>'
            + @obs7 + '<br>  
			  <BR>  
			  <B>Observa��o8:</B><br>'
            + @obs8 + '<br>  
			  <BR>  
			  <B>Observa��o9:</B><br>'
            + @obs9 + '<br>  
			  <BR>  
			  <B>Observa��o10:</B><br>'
            + @obs10 + '<br>  
			  <br>  
			  <i>Mensagem enviada automaticamente pelo sistema.</i>'



            SET @assunto =
            'NOVA INTERA��O COM: ' + @nome + ' - ' + @concurso

            ---------------------------------------------------------------------------------------   
            --BLOCO DE DIRECIONAMENTOS PARA AS SECRETARIAS
            --Produ��o  
            IF (@unidade_fisica = 'USP' or @curso = 'CEAI')
            BEGIN
                SET @destinatario =
                'atendimentousp@vanzolini.com.br; '
            END
            ELSE
            BEGIN
                SET @destinatario =
                'secretariapta@vanzolini.com.br; '
            END

            --Homologa��o  
            --SET @destinatario = 'suporte_techne@vanzolini.com.br'  
            --SET @assunto = 'Homologa��o - ' + @assunto  


            -------------------------------------------------------------------------------------

            EXEC
            MSDB.dbo.SP_SEND_DBMAIL @profile_name =
                                    -- Desenvolvimento/homologa��o  
                                    --FCAV_HOMOLOGACAO,  
                                    -- Produ��o  
                                    VANZOLINI_BD,
                                    @recipients = @destinatario,
                                    @blind_copy_recipients = 'suporte_techne@vanzolini.com.br',
                                    @subject = @assunto,
                                    @body = @texto,
                                    @body_format = HTML
        END

    END --fim da trigger