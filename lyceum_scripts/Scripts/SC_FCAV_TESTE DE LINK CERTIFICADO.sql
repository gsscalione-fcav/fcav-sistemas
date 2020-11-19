select * from  certificados 
where ALUNO = 'C201800300'


update certificados 
set
	URL_APROVACAO = 'http://200.196.228.204/tstvalidade/certificado.asp?0B448E91A86AC2E77E04877292F02055'

where ALUNO = 'C201800300'



select 
	aluno, sit_aluno, Lyceum.dbo.Decrypt(p.SENHA_TAC) senha
from 
	LYCEUM.dbo.LY_PESSOA p
	inner join lyceum.dbo.ly_aluno a
		on a.pessoa = p.pessoa
where aluno = 'C201800300'

delete LYCEUM.DBO.LY_AVISO where aluno = 'C201800300'