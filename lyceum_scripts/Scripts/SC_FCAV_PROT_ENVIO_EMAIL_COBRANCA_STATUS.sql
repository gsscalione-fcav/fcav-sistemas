select   
 SUBSTRING(body,(CHARINDEX('RPS:</B>',body,1)) + 9,     (CHARINDEX(' <B>VALOR:</B>',body,1))      - (CHARINDEX('RPS:</B>',body,1)) - 10)     AS TITULO_RPS,  
 SUBSTRING(body,126,(CHARINDEX('</b>,<BR>',body,1)) - 126) AS NOME,  
 recipients   AS DESTINATARIO,  
 subject    AS ASSUNTO,  
 body    AS MENSAGEM,  
 CAST(send_request_date AS DATE) AS DT_SOLICIT,  
 CAST(sent_date   AS DATE) AS DT_ENVIO,  
 sent_status   AS STATUS  
from msdb.dbo.sysmail_allitems  
where subject = 'Aviso de NF vencida - Fundacao Vanzolini'  

and SUBSTRING(body,(CHARINDEX('RPS:</B>',body,1)) + 9,     (CHARINDEX(' <B>VALOR:</B>',body,1))      - (CHARINDEX('RPS:</B>',body,1)) - 10)  IN (
'5038'
)




SELECT 
	TITULO_RPS ,
	NOME ,
	DESTINATARIO ,
	ASSUNTO ,
	MENSAGEM ,
	DT_SOLICIT ,
	DT_ENVIO ,
	STATUS 
FROM 
	FCAV_CONSULTA_DBMAIL
WHERE
	TITULO_RPS IN (
'283878',
'283099',
'284625',
'284612',
'284613',
'284616',
'284626',
'284663',
'284633',
'284814',
'4975',
'4988',
'4999',
'284755',
'284732',
'284750',
'284779',
'284780',
'284777',
'284795',
'5005',
'4991',
'284894',
'284884',
'284858',
'4985',
'4984',
'4986',
'5040',
'5041',
'284920',
'5030',
'5017',
'5038',
'284391',
'5042',
'284938',
'284969',
'285034',
'285006',
'285010',
'285168',
'284934',
'284948',
'284992',
'284978',
'284966',
'284936',
'284935',
'284985',
'285033',
'284998',
'284967',
'285035',
'284958',
'284959',
'284965',
'284955',
'284968',
'284962',
'285014',
'285019',
'285048'
)




select * from 
FCAV_EMAIL_CERTIF
WHERE
	TITULO_RPS IN (
'283878',
'283099',
'284625',
'284612',
'284613',
'284616',
'284626',
'284663',
'284633',
'284814',
'4975',
'4988',
'4999',
'284755',
'284732',
'284750',
'284779',
'284780',
'284777',
'284795',
'5005',
'4991',
'284894',
'284884',
'284858',
'4985',
'4984',
'4986',
'5040',
'5041',
'284920',
'5030',
'5017',
'5038',
'284391',
'5042',
'284938',
'284969',
'285034',
'285006',
'285010',
'285168',
'284934',
'284948',
'284992',
'284978',
'284966',
'284936',
'284935',
'284985',
'285033',
'284998',
'284967',
'285035',
'284958',
'284959',
'284965',
'284955',
'284968',
'284962',
'285014',
'285019',
'285048'
)