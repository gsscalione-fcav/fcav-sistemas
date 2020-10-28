-- ************************************************
-- JOB_MONIT_REPROCES
--
-- Script para monitorar o reprocessamento feito
-- automaticamente pelo Protheus.
--
-- Ele estará dentro de uma Job que estará rodando 
-- de 1 em 1 minuto das 20h até as 22h, assim 
-- pegará com certeza o início e termino da rotina
--
-- ************************************************

DECLARE @STATUS		CHAR (1)
DECLARE @ITEM		VARCHAR (6)
DECLARE @MENSAGEM	VARCHAR (2000)
DECLARE @ASSUNTO	VARCHAR (200)

SET @STATUS		= ''
SET @ITEM		= ''
SET @MENSAGEM	= ''
SET @ASSUNTO	= ''

	SELECT @STATUS  = TSK_STATUS,
		   @ITEM	= TSK_ITEM
	FROM   SCHDTSK
	WHERE  D_E_L_E_T_ = ''
	   AND TSK_ROTINA = 'CTBA190'
	   AND (SUBSTRING(TSK_DIA,1,4)+'-'+SUBSTRING(TSK_DIA,5,2)+'-'+SUBSTRING(TSK_DIA,7,2)) = CAST(GETDATE() AS DATE)


IF @STATUS IN ('1','2','3') AND NOT EXISTS (SELECT 1 FROM FCAV_TAB_CONFERE_REPROCES WHERE STATUS = @STATUS AND ITEM = @ITEM)
	BEGIN

	SELECT
		@ASSUNTO  = CASE @STATUS 
						WHEN '1' THEN 'Status Reprocessamento - INICIADO'
						WHEN '2' THEN 'Status Reprocessamento - FINALIZADO'
						WHEN '3' THEN 'Status Reprocessamento - COM FALHA!'
						END,
		@MENSAGEM = CASE @STATUS
						WHEN '1' THEN 'O reprocessamento contábil está em excecução e foi inciado às '+ CONVERT(VARCHAR,GETDATE(),113 )
						WHEN '2' THEN 'O reprocessamento contábil foi finalizado com êxito às '+ CONVERT(VARCHAR,GETDATE(),113 )
						WHEN '3' THEN 'O reprocessamento contábil <b>FALHOU</b> e não finalizou'
						END

		EXEC MSDB.dbo.SP_SEND_DBMAIL      
	   @PROFILE_NAME = VANZOLINI_BD, -- PROFILE DA BASE TESTE: VANZOLINI_BD_TESTE      
	   @RECIPIENTS = 'gabriel.scalione@vanzolini.com.br',    
	   @SUBJECT		= @ASSUNTO,      
	   @BODY		= @MENSAGEM,
	   @BODY_FORMAT = HTML;      
       
	INSERT INTO FCAV_TAB_CONFERE_REPROCES
	VALUES (@STATUS, @ITEM,'CTBA190')

	SELECT  @STATUS		= '',
			@MENSAGEM	= '',
			@ASSUNTO	= ''
	
	END