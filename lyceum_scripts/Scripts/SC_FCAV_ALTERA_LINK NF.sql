select OBS, LINK_RPS,
	*
from 
	LY_BOLETO
where 
	BOLETO = 199137

ALTERAR O LINK PARA LIMITAR O TAMANHO DO CAMPO OBS PARA 100 CARACTERES.


UPDATE LY_BOLETO	
SET
	OBS = 'https://nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?ccm=10947310&nf=00268310&cod=Y3QNTERZ',
	LINK_RPS = 'nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?ccm=10947310&nf=00268310&cod=Y3QNTERZ'
WHERE 
	BOLETO = 199137

