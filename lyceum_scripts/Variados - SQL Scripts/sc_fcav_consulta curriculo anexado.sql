select 
	pe.NOME_COMPL,
	CPF,
	CAST(CPF as varchar) +
	'_' +
	CAST(pe.PESSOA as varchar) + '.' +
	EXTENSAO AS CURRICULO
from 
 LY_MINI_CURRICULO mc
 inner join LY_PESSOA pe
	on pe.PESSOA = mc.PESSOA
 where 
	pe.PESSOA = 114755


update FCAV_CANDIDATOS
SET
	LINK_CV = '/Curriculos/33623819875_114755.pdf'
WHERE
	CANDIDATO = '201810168'

SELECT * FROM FCAV_CANDIDATOS WHERE CANDIDATO = '201720225'

SELECT * FROM LY_PESSOA where PESSOA