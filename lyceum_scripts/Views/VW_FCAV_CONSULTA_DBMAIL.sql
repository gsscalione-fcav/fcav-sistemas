
-- CRIACAO DA VIEW PARA FORMATAÇÃO DAS INFORMAÇÕES DE ENVIO DE EMAIL
ALTER VIEW VW_FCAV_CONSULTA_DBMAIL AS 

select 
	SUBSTRING(body,(CHARINDEX('RPS:</B>',body,1)) + 9,				 (CHARINDEX(' <B>VALOR:</B>',body,1))						- (CHARINDEX('RPS:</B>',body,1)) - 10)				 AS TITULO_RPS,
	SUBSTRING(body,126,(CHARINDEX('</b>,<BR>',body,1)) - 126) AS NOME,
	recipients			AS DESTINATARIO,
	subject				AS ASSUNTO,
	body				AS MENSAGEM,
	CAST(send_request_date	AS DATE) AS DT_SOLICIT,
	CAST(sent_date			AS DATE) AS DT_ENVIO,
	sent_status			AS STATUS
from msdb.dbo.sysmail_allitems
where subject = 'Aviso de NF vencida - Fundacao Vanzolini'

