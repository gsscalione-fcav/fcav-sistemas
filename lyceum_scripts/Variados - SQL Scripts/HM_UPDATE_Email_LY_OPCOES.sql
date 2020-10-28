

select
	EMailServer,
	EmailLogin,
	InstituicaoEmail,
	DominioOrigem,
	*
from 
	LY_OPCOES

UPDATE LY_OPCOES
SET
	EmailLogin = 'sgades@vanzolini.org.br',
	InstituicaoEmail = 'sgades@vanzolini.org.br'