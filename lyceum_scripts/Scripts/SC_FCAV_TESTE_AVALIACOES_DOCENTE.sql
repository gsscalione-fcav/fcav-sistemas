select distinct
a.ALUNO,
dbo.decrypt(p.SENHA_TAC) as senha,
f.DT_PREENCHIMENTO
from
LY_MATRICULA m
inner join LY_ALUNO a
on a.ALUNO = m.ALUNO
inner join LY_PESSOA p
on p.PESSOA = a.PESSOA
left join FCAV_AVALIACAO_DOCENTE f
on f.ALUNO = a.ALUNO
where m.TURMA = 'CEQP T 67'
and a.SIT_ALUNO = 'Ativo'



SELECT * FROM FCAV_AVALIACAO_DOCENTE 
where TURMA = 'CEQP T 67'



EXEC SP_FCAV_AVALIACAO_DOCENTE