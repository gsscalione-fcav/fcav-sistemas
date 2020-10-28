-- =============================================

-- Author:		Gabriel Scalione
-- Create date: 2019-08-08
-- Description:	Trigger que irá disparar um e-mail para o candidato, informando sobre local, data e horario da entrevista.

-- =============================================
ALTER TRIGGER TR_FCAV_ENVIA_EMAIL_ENTREVISTA 
   ON  LY_ENTREVISTA_CANDIDATO
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Insert statements for trigger here


	DECLARE @candidato varchar(20)      
    DECLARE @pessoa varchar(20)      
    DECLARE @nome varchar(100)      
    DECLARE @concurso varchar(20)      
    DECLARE @nome_curso varchar(100)      
    DECLARE @assunto varchar(100)      
    DECLARE @texto varchar(8000)      
    DECLARE @endereco varchar(100)      
    DECLARE @destinatario varchar(100)      
    DECLARE @inicio_curso varchar(30)      
    DECLARE @encaminha_email varchar(200)      
    DECLARE @responder_para varchar(100)      
    DECLARE @horario varchar(80)      
    DECLARE @contato varchar(200)      
    DECLARE @link varchar(200)      
    DECLARE @unidade_fisica varchar(20)      
    DECLARE @unidade_ensino varchar(20)      
    DECLARE @email_unidfisica varchar(200)
	DECLARE @data_agendada varchar (20)    
	DECLARE @sala varchar(20)
      
	SET @sala = NULL
    SET @candidato = NULL      
    SET @pessoa = NULL      
    SET @nome = NULL      
    SET @concurso = NULL      
    SET @nome_curso = NULL      
    SET @assunto = NULL      
    SET @texto = NULL      
    SET @endereco = NULL      
    SET @destinatario = NULL      
    SET @responder_para = NULL      
    SET @inicio_curso = NULL      
    SET @encaminha_email = NULL      
    SET @horario = NULL      
    SET @contato = NULL      
    SET @link = NULL      
    SET @unidade_ensino = NULL  
	SET @email_unidfisica = NULL 
	SET @data_agendada = NULL   
      
    BEGIN      
      
        SELECT      
            @candidato = CANDIDATO, --'201400274',            
            @concurso = CONCURSO, --'CCBB T 28',
			@horario = CONVERT(VARCHAR,HORA_INICIO,108),
			@data_agendada = CONVERT(VARCHAR,DATA,103),
			@sala = DEPENDENCIA
      
        FROM INSERTED      
      
        -------------------------------------------------------------            
      -- PRODUÇÃO
	    SELECT      
            @pessoa = PESSOA,      
            @nome = NOME_COMPL,
            @destinatario = LOWER(LTRIM(RTRIM(c.E_MAIL)))      
        FROM LY_CANDIDATO C      
        WHERE C.CANDIDATO = @candidato      
        AND C.CONCURSO = @concurso      
      
	  -- HOMOLOGAÇÃO
	  	--SET @destinatario =	'suporte_techne@vanzolini.com.br'


        -------------------------------------------------------------            
        SELECT      
            @nome_curso = CS.NOME,      
            @unidade_fisica = OC.UNIDADE_FISICA,      
            @unidade_ensino = CS.FACULDADE              
		FROM LY_OFERTA_CURSO OC      
			INNER JOIN LY_CURSO CS      
				ON (OC.CURSO = CS.CURSO)      
        WHERE OC.CONCURSO = @concurso      
      
	  END
  -------------------------------------------------------------      
  --ENDEREÇO DA UNIDADE FÍSICA      
  SELECT       
   @endereco =        
    DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(ENDERECO)      
    + ', ' + ISNULL(END_NUM ,'-')      
    + ', ' + ISNULL(END_COMPL,'-')       
    + ', ' + DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(ISNULL(BAIRRO,''))      
    + ', ' + DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(HM.NOME)      
    + ' - '+ HM.UF      
  FROM LY_UNIDADE_FISICA UN      
   INNER JOIN HD_MUNICIPIO HM      
    ON HM.MUNICIPIO = UN.MUNICIPIO      
  WHERE UN.UNIDADE_FIS = @unidade_fisica      
       
  -------------------------------------------------------------        
  --CONTATO              
  SELECT      
   @contato = DESCR      
  FROM HD_TABELAITEM      
  WHERE TABELA = 'ContatosFCAV'      
  AND ITEM = @unidade_fisica      
  
  -------------------------------------------------------------        
  --EMAIL PARA CONTATO  
  IF (@unidade_fisica = 'USP') BEGIN  
    SET @email_unidfisica = 'atendimentousp@vanzolini.com.br'  
  END  
  ELSE BEGIN  
 SET @email_unidfisica = 'secretariapta@vanzolini.com.br'  
  END  
  
      
    
  ---------------------------------------------------------------------------------------                              
  /* MENSAGEM PADRÃO PARA ENTREVISTA*/        
  ---------------------------------------------------------------------------------------          
  
   -------------------------------------------------------------            
   SET @assunto = 'Convocação para entrevista do curso de ' + @nome_curso      
   -------------------------------------------------------------   
			BEGIN
				  SET @texto = 'Prezado '+ @nome +', boa tarde!        
					  <br><br>        
					  Para darmos continuidade ao processo de seleção do curso de ' + @nome_curso + ', estamos agendando a sua entrevista com a coordenação deste curso:
					  <br>            
					  <br>        
					Data: ' + @data_agendada + '
						<br>        
					Horário: ' + @horario + '
						<br>        
					Local: ' + @endereco + ' 
					<br>
					Sala: '+ @sala +' 1º Andar
					<br><br>                  
					<b> Aguardamos sua confirmação através do e-mail ' + @email_unidfisica + ' </b>		    
					  <br><br>        
					Mais informações: ' + @contato + '            
					  <br><br>        
					  Permanecemos à disposição.        
					  <br><br>        
					  Fundação Vanzolini' 

			END


        -------------------------------------------------------------            
      
        EXEC MSDB.dbo.SP_SEND_DBMAIL @profile_name =      
                                     -- Desenvolvimento/homologação         
                                     --FCAV_HOMOLOGACAO,          
                                     -- Produção          
                                     VANZOLINI_BD,      
                                     @recipients = @destinatario,      
									 @copy_recipients = @email_unidfisica, 
									 @reply_to = @email_unidfisica,     
                                     @blind_copy_recipients = 'gabriel.scalione@vanzolini.com.br',      
                                     @subject = @assunto,      
                                     @body = @texto,      
                                     @body_format = HTML; 

END