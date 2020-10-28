select * from LY_EMAIL_LOTE_DEST order by ID_EMAIL_LOTE_DEST desc

select * from LY_EMAILS_BATCH order by chave desc

select * from LY_ENVIO_EMAIL order by id_envio_email desc

select * from LY_EMAIL_LOTE order by ID_EMAIL_LOTE desc

LY_RESET_SENHA

LY_PARAM_CONFIGURACAO


SELECT EmailLogin, DBO.Decrypt(EMAILSENHA) FROM LY_OPCOES 