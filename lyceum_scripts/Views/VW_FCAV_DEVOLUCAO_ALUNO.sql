/*
	VIEW VW_FCAV_DEVOLUCAO_ALUNO

Finalidade: Consulta para trazer a relação de alunos que tiveram devoluções

*/


CREATE VIEW VW_FCAV_DEVOLUCAO_ALUNO
as

select 
	ALUNO,NOME_COMPL, CURSO, TURNO, CURRICULO,
	TURMA_PREF,
	case when EXISTS (SELECT 
						1 
					  FROM 
						LY_ALUNO A2 
					  WHERE A2.ALUNO = A1.ALUNO 
						    AND A2.TURMA_PREF = A1.TURMA_PREF
					        AND replace(LOWER(OBS_ALUNO_FINAN),' ','') LIKE '%devoluçãoder$%') then
	cast(replace(replace(
			replace(replace(SUBSTRING(replace(LOWER(OBS_ALUNO_FINAN),' ',''),CHARINDEX('$',replace(LOWER(OBS_ALUNO_FINAN),' ',''))+1,6),'.',''),',','.'),
		char(13),''),char(10),'') as decimal(10,2))
	ELSE 0
	end DEVOLUCAO
from 
	ly_aluno A1
where 
	replace(LOWER(OBS_ALUNO_FINAN),' ','') LIKE '%devoluçãoder$%'
--and TURMA_PREF = 'A-ASPON T 01' 