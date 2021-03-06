SELECT
	AV.TURMA,
	AD.CODIGO,
	AD.DESCRICAO
 FROM
	LY_AVALIADO AD
	INNER JOIN VW_FCAV_RESPOSTAS_AVAL_DOCENTE_DISCIPLINA AV
		ON AD.CODIGO = AV.AVALIADO
WHERE
	AD.CODIGO like '%Infra%'

GROUP BY
	AV.TURMA,
	AD.CODIGO,
	AD.DESCRICAO
	
	
SELECT
	AV.TURMA,
	DISCIPLINA,
	DESCRICAO
 FROM
	LY_AVALIADO AD
	INNER JOIN VW_FCAV_RESPOSTAS_AVAL_DOCENTE_DISCIPLINA AV
		ON AD.CODIGO = AV.AVALIADO
WHERE
	AD.DISCIPLINA IS NOT NULL
	--AND QTDE_APLICADA = 1
GROUP BY
	AV.TURMA,
	DISCIPLINA,
	DESCRICAO


SELECT 
	QUESTIONARIO,
	QUESTAO,
	PERGUNTAS
FROM
	VW_FCAV_RESPOSTAS_AVAL_DOCENTE_DISCIPLINA
WHERE
	TIPO_QUESTIONARIO IN ('FORM_AVAL_DOC_2018', 'FORM_AVAL_DIS_2018','FORM_AVAL_INFRA_2018')
GROUP  BY
	QUESTIONARIO,
	QUESTAO,
	PERGUNTAS
ORDER BY
	QUESTIONARIO DESC,
	QUESTAO