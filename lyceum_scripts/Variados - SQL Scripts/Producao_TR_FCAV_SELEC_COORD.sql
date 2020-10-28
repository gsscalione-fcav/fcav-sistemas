  
ALTER TRIGGER [dbo].[TR_FCAV_SELEC_COORD]  
ON [dbo].[FCAV_CANDIDATOS]  
AFTER INSERT, UPDATE  
  
AS  
  
    DECLARE @CANDIDATO varchar(20)  
    DECLARE @PESSOA varchar(20)  
    DECLARE @NOME varchar(100)  
    DECLARE @CONCURSO varchar(20)  
    DECLARE @TEXTO varchar(8000)  
    DECLARE @DESTINATARIO varchar(100)  
    DECLARE @ASSUNTO varchar(100)  
    DECLARE @OBS1 varchar(2000)  
    DECLARE @OBS2 varchar(2000)  
    DECLARE @OBS3 varchar(2000)  
    DECLARE @OBS4 varchar(2000)  
    DECLARE @OBS5 varchar(2000)  
    DECLARE @OBS6 varchar(2000)  
    DECLARE @OBS7 varchar(2000)  
    DECLARE @OBS8 varchar(2000)  
    DECLARE @OBS9 varchar(2000)  
    DECLARE @OBS10 varchar(2000)  
    DECLARE @SITUACAO varchar(30)  
  
    SET @CANDIDATO = NULL  
    SET @PESSOA = NULL  
    SET @NOME = NULL  
    SET @CONCURSO = NULL  
    SET @TEXTO = NULL  
    SET @DESTINATARIO = NULL  
    SET @ASSUNTO = NULL  
    SET @OBS1 = NULL  
    SET @OBS2 = NULL  
    SET @OBS3 = NULL  
    SET @OBS4 = NULL  
    SET @OBS5 = NULL  
    SET @OBS6 = NULL  
    SET @OBS7 = NULL  
    SET @OBS8 = NULL  
    SET @OBS9 = NULL  
    SET @OBS10 = NULL  
    SET @SITUACAO = NULL  
  
    BEGIN  
        /*------------------------------------------------------------  
            Caso entre outro tipo de curso com a letra diferente, acrescentar a letra referente ao curso na variavel @verificador.  
            Identifica se é candidato ou aluno de venda direta.  
         Ex. P - Palestra, a variavel @verificador ficará: "ACEP". A ordem das letras não é importante.  
        */  
        DECLARE @verificador varchar(20)  
        DECLARE @char varchar(1)  
  
        SET @verificador = 'ACE'  -- Acrescentar a letra referente ao curso, caso necessário.  
  
        SELECT  
            @CANDIDATO = CANDIDATO,  
            @CONCURSO = CONCURSO,  
            @PESSOA = PESSOA,  
            @char = SUBSTRING(CANDIDATO, 1, 1)  
        FROM INSERTED  
  
  
        IF (CHARINDEX(@char, @verificador) <= 0)-- Retorna a posição do caracter, se for menor ou igual a 0 significa que o primeiro caracter do código do candidato não é das letras definidas na @verificador  
        BEGIN  
  
            SELECT  
                @CANDIDATO = CANDIDATO,  
                @CONCURSO = CONCURSO,  
                @PESSOA = PESSOA  
            FROM INSERTED  
  
            SET @NOME = (SELECT  
                NOME_COMPL  
            FROM LYCEUM.dbo.LY_CANDIDATO C  
            WHERE C.CANDIDATO = @CANDIDATO  
            AND C.CONCURSO = @CONCURSO)  
  
            SELECT DISTINCT  
                @OBS1 = ISNULL(OBSERV1, ' '),  
                @OBS2 = ISNULL(OBSERV2, ' '),  
                @OBS3 = ISNULL(OBSERV3, ' '),  
                @OBS4 = ISNULL(OBSERV4, ' '),  
                @OBS5 = ISNULL(OBSERV5, ' '),  
                @OBS6 = ISNULL(OBSERV6, ' '),  
                @OBS7 = ISNULL(OBSERV7, ' '),  
                @OBS8 = ISNULL(OBSERV8, ' '),  
                @OBS9 = ISNULL(OBSERV9, ' '),  
                @OBS10 = ISNULL(OBSERV10, ' ')  
            FROM FCAV_CANDIDATOS  
            WHERE CANDIDATO = @CANDIDATO  
            AND CONCURSO = @CONCURSO  
  
            SELECT  
                @SITUACAO = (CASE  
                    WHEN (SELECT  
                            CONVOCADO  
                        FROM FCAV_CANDIDATOS  
                        WHERE CANDIDATO = @CANDIDATO  
                        AND CONCURSO = @CONCURSO)  
                        = '0' THEN 'NÃO AVALIADO'  
                    WHEN (SELECT  
                            CONVOCADO  
                        FROM FCAV_CANDIDATOS  
                        WHERE CANDIDATO = @CANDIDATO  
                        AND CONCURSO = @CONCURSO)  
                        = '1' THEN 'SELECIONADO'  
                    WHEN (SELECT  
                            CONVOCADO  
                        FROM FCAV_CANDIDATOS  
                        WHERE CANDIDATO = @CANDIDATO  
                        AND CONCURSO = @CONCURSO)  
                        = '2' THEN 'RECUSADO'  
 ELSE 'NÃO AVALIADO'  
                END)  
  
            SET @TEXTO =  
            'Existe uma nova interação com o candidato.<br>  
  <br>  
  Código: ' + @CANDIDATO + '<br>  
  Nome: ' + @NOME + '<br>  
  Situação: ' + @SITUACAO + '<br>  
  Concurso: ' + @CONCURSO + '<br>  
  <br>  
  <B>Observação1:</B><br>'  
            + @OBS1 + '<br>  
  <BR>  
  <B>Observação2:</B><br>'  
            + @OBS2 + '<br>  
  <BR>  
  <B>Observação3:</B><br>'  
            + @OBS3 + '<br>  
  <BR>  
  <B>Observação4:</B><br>'  
            + @OBS4 + '<br>  
  <BR>  
  <B>Observação5:</B><br>'  
            + @OBS5 + '<br>  
  <BR>  
  <B>Observação6:</B><br>'  
            + @OBS6 + '<br>  
  <BR>  
  <B>Observação7:</B><br>'  
            + @OBS7 + '<br>  
  <BR>  
  <B>Observação8:</B><br>'  
            + @OBS8 + '<br>  
  <BR>  
  <B>Observação9:</B><br>'  
            + @OBS9 + '<br>  
  <BR>  
  <B>Observação10:</B><br>'  
            + @OBS10 + '<br>  
  <br>  
  <i>Mensagem enviada automaticamente pelo sistema.</i>'  
  
    SET @ASSUNTO =  
    'NOVA INTERAÇÃO COM: ' + @NOME + ' - ' + @CONCURSO  
  
  
     SELECT @DESTINATARIO =       
   (CASE WHEN UNIDADE_FISICA = 'Paulista' THEN 'secretariapta@vanzolini.org.br'      
    WHEN UNIDADE_FISICA = 'USP' THEN 'secretariausp@vanzolini.org.br'      
    END)      
  FROM LY_OFERTA_CURSO      
  WHERE CONCURSO = @CONCURSO     
  
            EXEC  
   MSDB.dbo.SP_SEND_DBMAIL  
    @PROFILE_NAME =  
     -- Desenvolvimento/homologação  
     --FCAV_HOMOLOGACAO,  
     -- Produção  
     VANZOLINI_BD,  
    @RECIPIENTS = @destinatario,  
    @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',  
    @SUBJECT = @assunto,  
    @BODY = @texto,  
    @BODY_FORMAT = HTML  
  
  
  
        END  
  
    END --fim da trigger