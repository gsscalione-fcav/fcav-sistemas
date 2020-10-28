SELECT
	MA.CURSO,
	CS.NOME,
	MA.TURMA,
	MA.ALUNO,
	MA.NOME_COMPL,
	MA.ANO_INGRESSO,
	MA.SEM_INGRESSO,
	CC.ANO_ENCERRAMENTO,
	CC.SEM_ENCERRAMENTO,
	CC.DT_ENVIO_INST_EXT AS DT_SOLICITACAO,
	CC.DT_DIPLOMA AS DT_DISPONIBILIZACAO,
	CC.DT_RETIRA_DIP AS DT_RETIRADA
FROM
	VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA
	LEFT JOIN LY_H_CURSOS_CONCL CC
		ON CC.ALUNO = MA.ALUNO
		AND CC.CURSO = MA.CURSO
		AND CC.TURNO = MA.TURNO
		AND CC.CURRICULO = MA.CURRICULO
	INNER JOIN LY_CURSO CS
		ON CS.CURSO = MA.CURSO
WHERE
	SIT_ALUNO != 'Cancelado'
	and SIT_ALUNO != 'Ativo'
group by
	MA.CURSO,
	CS.NOME,
	MA.TURMA,
	MA.ALUNO,
	MA.NOME_COMPL,
	MA.ANO_INGRESSO,
	MA.SEM_INGRESSO,
	CC.ANO_ENCERRAMENTO,
	CC.SEM_ENCERRAMENTO,
	CC.DT_ENVIO_INST_EXT,
	CC.DT_DIPLOMA,
	CC.DT_RETIRA_DIP
ORDER BY
	MA.CURSO,
	MA.TURMA,
	MA.ALUNO