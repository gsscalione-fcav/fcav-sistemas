select 
*
from 
	LY_QUESTAO_APLICADA 
where PAR_CODIGO in ('E201810001','E201810033',
'E201810116' ,'E201810129' ,'E201810164')
AND APLICACAO = 'DOCEAI20193TCCHTA0A' OR 
APLICACAO = 'DISCEAI20193TCCHTA0A'


DELETE LY_QUESTAO_APLICADA 
where PAR_CODIGO in ('E201810001','E201810033',
'E201810116' ,'E201810129' ,'E201810164')
AND APLICACAO = 'DOCEAI20193TCCHTA0A' OR 
APLICACAO = 'DISCEAI20193TCCHTA0A'