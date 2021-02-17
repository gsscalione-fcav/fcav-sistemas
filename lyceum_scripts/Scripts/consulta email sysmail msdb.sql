USE msdb ;  
GO  

-- Show the subject, the time that the mail item row was last  
-- modified, and the log information.  
-- Join sysmail_faileditems to sysmail_event_log   
-- on the mailitem_id column.  
-- In the WHERE clause list items where danw was in the recipients,  
-- copy_recipients, or blind_copy_recipients.  
-- These are the items that would have been sent  
-- to danw.  


--CONSULTA ENVIO DOS E-MAILS
select top 10 items.sent_status,
	items.* 
    ,l.description 
from dbo.sysmail_allitems as items  
left join dbo.sysmail_event_log as l  
    on items.mailitem_id = l.mailitem_id  
--where	
		--subject like 'Teste de envio pelo Lyceum Produção%'
		--items.recipients like '%danw%' or 
		--items.copy_recipients like '%danw%' or 
		--items.blind_copy_recipients like '%atendimentousp%' 
		--send_request_date between '2018-10-22 17:00:00.000' and '2018-10-22 23:59:59.999'
		--and items.sent_status not like 'sent'
	order by mailitem_id desc

--sysmail_help_status_sp  

--sysmail_start_sp 

--sysmail_stop_sp  

