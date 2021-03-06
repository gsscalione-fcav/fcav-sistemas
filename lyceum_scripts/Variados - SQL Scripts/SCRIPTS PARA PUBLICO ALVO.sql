--Rela�ao de Docente 
SELECT
  A.NUM_FUNC
FROM LY_AGENDA A,
     LY_MATRICULA M
WHERE A.ANO = M.ANO
AND A.SEMESTRE = M.SEMESTRE
AND A.DISCIPLINA = M.DISCIPLINA
AND A.TURMA = M.TURMA
AND M.SIT_MATRICULA = 'Matriculado'
GROUP BY A.NUM_FUNC


--Rela��o de disciplinas da turma
SELECT distinct 
  ALUNO, M.DISCIPLINA
FROM LY_MATRICULA M
WHERE M.SIT_MATRICULA = 'Matriculado'
AND M.TURMA = 'CEGP T 65'
group by ALUNO, TURMA, DISCIPLINA

/*aluno			-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL,NULL,NULL,NULL,NULL,'E201630045'