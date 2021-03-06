
SELECT 
	VT.UNIDADE_RESPONSAVEL AS CATEGORIA,
	VT.COD_CURSO AS CURSO,
	HC.ANO_INGRESSO,
	HC.SEM_INGRESSO AS PER_INGRESSO,
	CASE WHEN MP.TURMA IS NULL THEN AL.TURMA_PREF
		ELSE MP.TURMA
	END AS TURMA,
	STATUS_TURMA,
	HC.MOTIVO,
	HC.CAUSA_ENCERR,
	HC.DT_ENCERRAMENTO, 
	COUNT(HC.ALUNO) ALUNOS_DESISTENTES
INTO #TMP_ALUNOS_CANCELADOS
FROM 
	LY_H_CURSOS_CONCL HC
	LEFT JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP
		ON MP.ALUNO = HC.ALUNO
	LEFT JOIN LY_ALUNO AL
		ON AL.ALUNO = HC.ALUNO
	LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT
		ON VT.TURMA_PREF = AL.TURMA_PREF
WHERE
	HC.DT_REABERTURA IS NULL
GROUP BY
	VT.UNIDADE_RESPONSAVEL,
	VT.COD_CURSO,
	HC.ANO_INGRESSO,
	HC.SEM_INGRESSO,
	MP.TURMA,
	AL.TURMA_PREF,
	STATUS_TURMA,
	HC.MOTIVO,
	HC.CAUSA_ENCERR,
	HC.DT_ENCERRAMENTO
ORDER BY HC.ANO_INGRESSO,
	HC.SEM_INGRESSO,
	HC.DT_ENCERRAMENTO,
	VT.UNIDADE_RESPONSAVEL,
	VT.COD_CURSO,
	MP.TURMA,
	AL.TURMA_PREF
	
	-------------------------------------------------------
	-------------------------------------------------------
SELECT
	VT.UNIDADE_RESPONSAVEL AS CATEGORIA,
	VT.COD_CURSO AS CURSO,
	AL.ANO_INGRESSO,
	AL.SEM_INGRESSO AS PER_INGRESSO,
	CASE WHEN MP.TURMA IS NULL THEN AL.TURMA_PREF
		ELSE MP.TURMA
	END AS TURMA,
	STATUS_TURMA,
	MT.DESCRICAO AS MOTIVO_TRANC,
	CT.DESCRICAO AS CAUSA_TRANC,
	TR.OBS,
	TR.DT_INI AS DT_TRANCAMENTO,
	COUNT(TR.ALUNO) ALUNOS_TRANCADOS
INTO #TMP_ALUNOS_TRANCADOS
FROM
	LY_TRANC_INTERV_DATA TR
	LEFT JOIN LY_MOTIVO_TRANCAMENTO MT
		ON MT.MOTIVO_TRANC = TR.MOTIVO_TRANC
	LEFT JOIN LY_CAUSA_TRANCAMENTO CT
		ON CT.CAUSA_TRANC = TR.CAUSA_TRANC
	LEFT JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP
		ON MP.ALUNO = TR.ALUNO
	LEFT JOIN LY_ALUNO AL
		ON AL.ALUNO = TR.ALUNO
	LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT
		ON VT.TURMA_PREF = AL.TURMA_PREF
WHERE 
	TR.DT_REABERTURA IS NULL
GROUP BY
	VT.UNIDADE_RESPONSAVEL,
	VT.COD_CURSO,
	AL.ANO_INGRESSO,
	AL.SEM_INGRESSO,
	MP.TURMA,
	AL.TURMA_PREF,
	STATUS_TURMA,
	TR.DT_INI,
	MT.DESCRICAO,
	CT.DESCRICAO,
	TR.OBS
ORDER BY AL.ANO_INGRESSO,
	AL.SEM_INGRESSO,
	TR.DT_INI,
	VT.UNIDADE_RESPONSAVEL,
	VT.COD_CURSO,
	MP.TURMA,
	AL.TURMA_PREF	


SELECT 
	UNIDADE_RESPONSAVEL AS CATEGORIA,
	COD_CURSO AS CURSO,
	(SELECT sum(ALUNOS_DESISTENTES) FROM #TMP_ALUNOS_CANCELADOS AC WHERE AC.CURSO = VT.COD_CURSO ) AS ALUNOS_DESISTENTES,
	(SELECT sum(ALUNOS_TRANCADOS) FROM #TMP_ALUNOS_TRANCADOS AT WHERE AT.CURSO = VT.COD_CURSO ) AS ALUNOS_TRANCADOS
 FROM 
	VW_FCAV_INI_FIM_CURSO_TURMA VT
GROUP BY 
	UNIDADE_RESPONSAVEL,
	COD_CURSO 
ORDER BY
	UNIDADE_RESPONSAVEL,
	COD_CURSO 


IF EXISTS(SELECT * FROM SYS.tables WHERE name = '#TMP_ALUNOS_TRANCADOS')
	DROP TABLE #TMP_ALUNOS_TRANCADOS
go

IF EXISTS(SELECT * FROM SYS.tables WHERE name = '#TMP_ALUNOS_CANCELADOS')
	DROP TABLE #TMP_ALUNOS_CANCELADOS
go

