**********************

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



-- INSERT NA TABELA PARA SER USADA NO RELATORIO
INSERT INTO FCAV_CONSULTA_DBMAIL
SELECT 
	TITULO_RPS ,
NOME ,
DESTINATARIO ,
ASSUNTO ,
MENSAGEM ,
DT_SOLICIT ,
DT_ENVIO ,
STATUS 

FROM VW_FCAV_CONSULTA_DBMAIL


--****************************************
-- CRAIACAO DA TABELA PARA O RELATÓRIO
--
--
--CREATE TABLE FCAV_CONSULTA_DBMAIL 
--(
--TITULO_RPS varchar (20) COLLATE Latin1_General_BIN,
--NOME varchar (200) COLLATE Latin1_General_BIN,
--DESTINATARIO varchar (300) COLLATE Latin1_General_BIN,
--ASSUNTO varchar (100) COLLATE Latin1_General_BIN,
--MENSAGEM varchar (max) COLLATE Latin1_General_BIN,
--DT_SOLICIT date ,
--DT_ENVIO date ,
--STATUS varchar (10) COLLATE Latin1_General_BIN
--)