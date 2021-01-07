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

select top 100
	items.* 
    ,l.description 
from dbo.sysmail_mailitems as items  
left join dbo.sysmail_event_log as l  
    on items.mailitem_id = l.mailitem_id  
where	
		subject like '%Confirmação%'
		--and items.recipients like '%@ej.com.br%'
		--items.copy_recipients like '%danw%' or 
		--items.blind_copy_recipients like '%atendimentousp%'  
		--and send_request_date between '2019-02-05 00:00:00.000' and '2019-02-05 23:59:59.999'

order by mailitem_id desc
GO  

--sysmail_help_status_sp  

--sysmail_start_sp 

--sysmail_stop_sp  

