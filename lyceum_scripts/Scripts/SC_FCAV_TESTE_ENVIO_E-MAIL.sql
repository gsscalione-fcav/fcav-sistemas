  EXEC MSDB.dbo.SP_SEND_DBMAIL  
   -- AJUSTAR AO PROFILE CONFIGURADO NO BANCO         
   @profile_name =
	 -- Desenvolvimento/homologa��o    
	 FCAV_HOMOLOGACAO,    
	 -- Produ��o    
     --VANZOLINI_BD,
   
   --EMAIL DO DESTINAT�RIO
   @RECIPIENTS = 'gabriel.scalione@vanzolini.com.br',
   
   --@blind_copy_recipients = 'suporte_techne@vanzolini.org.br', 
   
   -- ASSUNTO DA MENSAGEM
   @SUBJECT = 'Teste de envio pelo Lyceum homologa��o',
   
   -- TEXTO DA MENSAGEM
   @BODY = 'Desculpe, esse email est� sendo enviado pelo sistema. <br> <br> Por favor confirme o recebimento para respondendo o e-mail para gabriel.scalione@vanzolini.com.br <br><br><br>Desde j� agrade�o.',
   @BODY_FORMAT = HTML;      



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
		send_request_date between '2018-10-19 17:00:00.000' and '2018-10-22 23:59:59.999'
	order by mailitem_id desc
