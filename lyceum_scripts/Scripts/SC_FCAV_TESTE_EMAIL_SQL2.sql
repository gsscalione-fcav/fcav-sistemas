--Teste em Produ��o
EXEC MSDB.dbo.SP_SEND_DBMAIL
		@PROFILE_NAME =
			VANZOLINI_BD,
   
   --EMAIL DO DESTINAT�RIO
   @RECIPIENTS = 'gabriel.scalione@vanzolini.com.br',
   
   --@blind_copy_recipients = 'suporte_techne@vanzolini.org.br', 
   
   -- ASSUNTO DA MENSAGEM
   @SUBJECT = 'Teste de envio pelo Lyceum Produ��o',
   
   -- TEXTO DA MENSAGEM
   @BODY = 'Desculpe, esse email est� sendo enviado pelo sistema. <br> <br> Por favor confirme o recebimento para respondendo o e-mail para gabriel.scalione@vanzolini.com.br <br><br><br>Desde j� agrade�o.',
   @BODY_FORMAT = HTML;

		
	

--CONSULTA ENVIO DOS E-MAILS
select items.sent_status,
	items.* 
    ,l.description 
from dbo.sysmail_allitems as items  
left join dbo.sysmail_event_log as l  
    on items.mailitem_id = l.mailitem_id  
--where	
--	send_request_date between '2019-12-09 00:00:00.000' and '2019-12-23 23:59:59.999'
--	and items.sent_status not like 'sent'
order by mailitem_id desc



			
		
		SELECT is_broker_enabled FROM sys.databases WHERE name = 'msdb'
		
		--verifica o servi�o do sysmail
		EXECUTE dbo.sysmail_help_status_sp
		
		--para o servi�o
		EXECUTE dbo.sysmail_stop_sp ; 

		--inicia o servi�o
		EXECUTE dbo.sysmail_start_sp ; 

		SELECT * FROM sysmail_event_log order by log_id desc



		select * from sysmail_mailitems order by mailitem_id desc

		EXECUTE msdb.dbo.sysmail_help_queue_sp @queue_type = 'Mail'


			
		
		SELECT is_broker_enabled FROM sys.databases WHERE name = 'msdb'
		
		--verifica o servi�o do sysmail
		EXECUTE dbo.sysmail_help_status_sp
		
		--para o servi�o
		EXECUTE dbo.sysmail_stop_sp ; 

		--inicia o servi�o
		EXECUTE dbo.sysmail_start_sp ; 

		SELECT * FROM sysmail_event_log order by log_id desc



		select * from sysmail_mailitems order by mailitem_id desc

		EXECUTE msdb.dbo.sysmail_help_queue_sp @queue_type = 'Mail'