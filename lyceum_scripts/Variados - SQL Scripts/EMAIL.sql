use LYCEUM
go

SELECT UTILIZA_SSL FROM LY_OPCOES

update LY_OPCOES
set
 UTILIZA_SSL = 'S'
 
 --LY_ORIENTADORES 


select ENVIADA,* from ly_emails_batch order by chave desc
select * from ly_envio_email order by id_envio_email desc
select * from LY_EMAIL_LOTE_DEST order by ID_EMAIL_LOTE_DEST desc
select * from LY_EMAIL_LOTE order by ID_EMAIL_LOTE desc
SELECT TOP 100
	ID_EMAIL_LOTE_DEST,
	SIT_EMAIL_LOTE,
	NUMERO_TENTATIVAS,
	DATA_ULTIMA_TENTATIVA,
	MENSAGEM_ERRO,
	EL.*,
	PESSOA,
	ALUNO,
	EMAIL_DESTINATARIO,
	NOME_DESTINATARIO
FROM LY_EMAIL_LOTE EL 
INNER JOIN LY_EMAIL_LOTE_DEST ED
	ON ED.ID_EMAIL_LOTE = EL.ID_EMAIL_LOTE
--where SIT_EMAIL_LOTE like 'N�o Enviado%'
ORDER BY EL.ID_EMAIL_LOTE DESC

//


update LY_EMAIL_LOTE_DEST
set
	SIT_EMAIL_LOTE = 'N�o Enviado - Aguardando Reenvio',
	numero_tentativas = 0,
	MENSAGEM_ERRO = NULL
where
	ID_EMAIL_LOTE_DEST IN (19090)