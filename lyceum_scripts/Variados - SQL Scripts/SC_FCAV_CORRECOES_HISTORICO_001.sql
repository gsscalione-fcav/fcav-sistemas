SELECT * FROM VW_FCAV_MEDIA_FINAL_ALUNOS where NOME_COMPL = 'Cybele Figueiredo da Costa'

SELECT * FROM VW_FCAV_MEDIA_FINAL_ALUNOS where NOME_COMPL = 'Dominique de Avila Cossa'

SELECT * FROM VW_FCAV_MEDIA_FINAL_ALUNOS where turma  = 'CCAN T 15'

SELECT * FROM VW_FCAV_HISTORICO_ACADEMICO where turma = 'CCAN T 15'

SELECT * FROM VW_FCAV_MEDIA_FINAL_ALUNOS where turma  = 'CCAN T 09'

SELECT * FROM VW_FCAV_HISTORICO_ACADEMICO WHERE NOME_COMPL = 'Cybele Figueiredo da Costa'

select * from LY_DISCIPLINA where NOME_COMPL in ('Perspectivas',
'Aula Inaugural')

SELECT * FROM LY_TURMA WHERE TURMA = 'CCAN T 15'


SELECT DISTINCT SIT_DETALHE FROM VW_FCAV_MEDIA_FINAL_ALUNOS 

	SELECT ha.turma,   
		  CONVERT(DECIMAL(10,2), AVG(HA.NOTA_FINAL))
		  FROM VW_FCAV_HISTORICO_ACADEMICO HA
		  WHERE HA.ALUNO = 'C201700059'
		  GROUP BY HA.ALUNO, HA.TURMA
		  

SELECT 
	ALUNO,
	CURSO,
	TURMA,
	DT_INICIO,
	DT_FIM,
	ANO,
	SEMESTRE,
	DISCIPLINA,
	NOTA_FINAL,
	FREQUENCIA
FROM
	VW_FCAV_HISTORICO_ACADEMICO	
WHERE
	ALUNO = 'C201700059'
GROUP BY 
	ALUNO,
	CURSO,
	TURMA,
	DT_INICIO,
	DT_FIM,
	ANO,
	SEMESTRE,
	DISCIPLINA,
	NOTA_FINAL,
	FREQUENCIA
