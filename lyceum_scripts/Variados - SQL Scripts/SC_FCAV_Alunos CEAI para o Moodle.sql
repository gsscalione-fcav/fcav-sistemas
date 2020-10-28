use lyceum
go
	
select 
	ma.DISCIPLINA,
	ma.ANO,
	ma.SEMESTRE,
	ma.TURMA,
	ma.ALUNO,
	pe.NOME_COMPL,
	pe.E_MAIL,
	pe.CPF
from
	ly_matricula ma
	inner join LY_ALUNO al
		on al.ALUNO = ma.ALUNO
	inner join LY_PESSOA pe
		on pe.pessoa = al.pessoa
where al.curso = 'ceai'
and ANO >= 2017
and DISCIPLINA not like 'CEAI-RESERV'
order by DISCIPLINA,ANO, SEMESTRE,TURMA, NOME_COMPL