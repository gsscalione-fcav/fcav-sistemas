select * from  certificados 
where ALUNO = 'C201800300'


update certificados 
set
	URL_APROVACAO = 'http://10.0.10.14/tstvalidade/teste_pdf.asp?B0657EFBDFC8329D96A77D8CBE192CF4'

where ALUNO = 'C201800300'

	--'http://10.0.10.14/tstvalidade/teste_pdf.asp?B0657EFBDFC8329D96A77D8CBE192CF4'

select 
	aluno, sit_aluno, Lyceum.dbo.Decrypt(p.SENHA_TAC) senha
from 
	LYCEUM.dbo.LY_PESSOA p
	inner join lyceum.dbo.ly_aluno a
		on a.pessoa = p.pessoa
where aluno = 'C201800300'

delete LYCEUM.DBO.LY_AVISO where aluno = 'C201800300'