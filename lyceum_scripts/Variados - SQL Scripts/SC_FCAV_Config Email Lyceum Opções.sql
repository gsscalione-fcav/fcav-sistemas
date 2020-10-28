select 
	EMailServer,
	InstituicaoEmail,
	DominioOrigem,
	EmailLogin,
	dbo.Decrypt(EmailSenha) EmailSenha,
	TEMPO_TIMEOUT,
	UTILIZA_SSL,
	UTILIZA_SERV_EMAIL,
	PORTA,
	NOME_REMETENTE,
	TAMANHO_MAX_ANEXO,
	NUM_TENTATIVAS_MAX
from 
	LY_OPCOES