SELECT
    MP.UNIDADE_RESPONSAVEL,
    MP.CURSO,
    MP.TURMA,
    MP.TURMA_PREF,
	MP.STATUS_TURMA,
    MP.ALUNO,
    MP.NOME_COMPL,
    MP.SIT_ALUNO,

    CASE WHEN MP.CURSO = 'CEAI' THEN 11
		 WHEN MP.CURSO IN ('CCBB','CCGB','CCUPGRADE') THEN 
				(SELECT COUNT(DISCIPLINA) FROM LY_GRADE GR
				WHERE GR.CURRICULO = MP.CURRICULO)
		ELSE(SELECT
			COUNT(DISCIPLINA)
		FROM LY_TURMA TU
		WHERE TU.TURMA = MP.TURMA) 
    END AS DISC_GRADE,
    
    (SELECT COUNT(MF.DISCIPLINA)FROM VW_FCAV_MEDIA_FINAL_ALUNOS MF
		WHERE MF.ALUNO = MP.ALUNO
		) AS DISC_CURSADAS,
    CAST((SELECT SUM(MF.NOTA_FINAL) FROM VW_FCAV_MEDIA_FINAL_ALUNOS MF
		WHERE MF.ALUNO = MP.ALUNO
			)/(SELECT COUNT(MF.DISCIPLINA)FROM VW_FCAV_MEDIA_FINAL_ALUNOS MF
		WHERE MF.ALUNO = MP.ALUNO
		) AS decimal(10, 2)) AS MEDIA_NOTA_FINAL,
    
     CAST((SELECT SUM(MF.FREQUENCIA) FROM VW_FCAV_MEDIA_FINAL_ALUNOS MF
		WHERE MF.ALUNO = MP.ALUNO)/(SELECT COUNT(MF.DISCIPLINA)FROM VW_FCAV_MEDIA_FINAL_ALUNOS MF
		WHERE MF.ALUNO = MP.ALUNO) AS decimal(10, 2)) AS MEDIA_FREQ_FINAL
FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP
WHERE
	MP.SIT_ALUNO = 'Ativo'
AND MP.UNIDADE_RESPONSAVEL IN ('CAPAC', 'ESPEC')
GROUP BY MP.UNIDADE_RESPONSAVEL,
         MP.CURSO,
		 MP.TURMA,
		 MP.TURMA_PREF,
		 MP.CURRICULO,
         MP.STATUS_TURMA,
         MP.ALUNO,
         MP.NOME_COMPL,
         MP.SIT_ALUNO
ORDER BY MP.UNIDADE_RESPONSAVEL, MP.CURSO, MP.TURMA, MP.ALUNO