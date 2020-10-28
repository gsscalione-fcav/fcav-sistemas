SELECT 
	*
FROM 
	msdb.dbo.sysmail_mailitems 
WHERE 
	recipients = 'clarogodoy@gmail.com'
	AND sent_status = 1 
	AND subject LIKE 'CCGP-AC - Divulgação de Nota'




IF NOT EXISTS(SELECT 1 FROM MSDB.dbo.sysmail_mailitems WHERE recipients = 'clarogodoy@gmail.com' collate Latin1_General_CI_AI AND sent_status = 2 AND subject LIKE 'CCGP-AC - Divulgação de Nota')
BEGIN

	declare @v_profile varchar(100)

	set @v_profile = -- Desenvolvimento/homologação       
					 --'FCAV_HOMOLOGACAO'
					 -- Produção        
					 'VANZOLINI_BD'

	EXEC MSDB.dbo.SP_SEND_DBMAIL 
			@profile_name =  @v_profile,  
			@recipients = 'gabriel.scalione@vanzolini.com.br',    
			--@copy_recipients = @encaminha_email,    
			--@blind_copy_recipients = 'suporte_techne@vanzolini.com.br',    
			@subject = 'CCGP-AC - Divulgação de Nota',    
			@body = 'teste',    
			@body_format = HTML;
END