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
where	
		--subject like 'confirma��o%'
		--items.recipients like '%danw%' or 
		--items.copy_recipients like '%danw%' or 
		--items.blind_copy_recipients like '%atendimentousp%' 
		send_request_date between '2018-10-22 17:00:00.000' and '2018-10-22 23:59:59.999'
		and items.sent_status not like 'sent'
	order by mailitem_id desc


--Teste em Homologa��o 

EXEC MSDB.dbo.SP_SEND_DBMAIL 
		@PROFILE_NAME =    
		-- Desenvolvimento/homologa��o      
		FCAV_HOMOLOGACAO,      
		@RECIPIENTS = 'gabriel.scalione@vanzolini.com.br',
		--@blind_copy_recipients = 'gestao.cursos@vanzolini.com.br',
		@SUBJECT = 'TESTE',
		@BODY = 'TESTE ',   
		@body_format = HTML    

			
		
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