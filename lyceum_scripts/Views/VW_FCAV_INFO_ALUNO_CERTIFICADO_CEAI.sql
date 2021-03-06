

USE LYCEUM
GO

ALTER VIEW VW_FCAV_INFO_ALUNO_CERTIFICADO_CEAI
AS

SELECT
	AL.ALUNO,
	PE.NOME_COMPL,
	AL.SIT_ALUNO,
	HI.SITUACAO_HIST AS SIT_MATRICULA,
	CASE WHEN CS.CURSO = 'ATUALIZACAO' OR CS.CURSO = 'PALESTRA' THEN DI.NOME_COMPL
	ELSE CS.NOME END AS NOME_CURSO,
	AL.CURSO,
	CO.NOME_COMPL AS NOME_COORD,
	CT.TURMA,
	CT.DT_INICIO,
	CT.DT_FIM,
	CT.CARGA_HORARIA,
	HI.DISCIPLINA,
	DI.NOME AS NOME_DISCIPLINA,
	hi.NOTA_FINAL,
	hi.PERC_PRESENCA
FROM LY_ALUNO AL
	INNER JOIN LY_HISTMATRICULA HI
		ON AL.ALUNO = HI.ALUNO
	INNER JOIN LY_PESSOA PE
		ON PE.PESSOA = AL.PESSOA
	INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA CT
		ON CT.TURMA = HI.TURMA
	INNER JOIN VW_FCAV_COORDENADOR_TURMA CO
		ON CO.TURMA = CT.TURMA
	INNER JOIN LY_DISCIPLINA DI
		ON DI.DISCIPLINA = HI.DISCIPLINA
	INNER JOIN LY_CURSO CS
		ON CS.CURSO = AL.CURSO
WHERE CO.TIPO_COORD = 'Coord'
and ct.unidade_responsavel != 'PALES'
AND al.SIT_ALUNO NOT IN ('Cancelado')
AND AL.CURSO = 'CEAI'
AND DI.DISCIPLINA != 'CEAI-RESERV'
GROUP BY	AL.ALUNO,
			PE.NOME_COMPL,
			DI.NOME_COMPL,
			CS.CURSO ,
			CS.NOME,
			AL.CURSO,
			CO.NOME_COMPL,
			CT.TURMA,
			CT.DT_INICIO,
			CT.DT_FIM,
			CT.CARGA_HORARIA,
			AL.SIT_ALUNO,
			HI.SITUACAO_HIST,
			HI.DISCIPLINA,
			DI.DISCIPLINA,
			DI.NOME,
			hi.NOTA_FINAL,
			hi.PERC_PRESENCA

UNION ALL

SELECT
	AL.ALUNO,
	PE.NOME_COMPL,
	AL.SIT_ALUNO,
	MA.SIT_MATRICULA,
	CASE WHEN CS.CURSO = 'ATUALIZACAO' OR CS.CURSO = 'PALESTRA' THEN DI.NOME_COMPL
	ELSE CS.NOME END AS NOME_CURSO,
	AL.CURSO,
	CO.NOME_COMPL AS NOME_COORD,
	CT.TURMA,
	CT.DT_INICIO,
	CT.DT_FIM,
	CT.CARGA_HORARIA,
	DI.DISCIPLINA,
	DI.NOME AS NOME_DISCIPLINA,
	MA.CONCEITO_FIM AS NOTA_FINAL,
	0 AS PERC_PRESENCA
FROM LY_ALUNO AL
	INNER JOIN LY_MATRICULA MA
		ON AL.ALUNO = MA.ALUNO
	INNER JOIN LY_PESSOA PE
		ON PE.PESSOA = AL.PESSOA
	INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA CT
		ON CT.TURMA = MA.TURMA
	INNER JOIN VW_FCAV_COORDENADOR_TURMA CO
		ON CO.TURMA = CT.TURMA
	INNER JOIN LY_DISCIPLINA DI
		ON DI.DISCIPLINA = MA.DISCIPLINA
	INNER JOIN LY_CURSO CS
		ON CS.CURSO = AL.CURSO

WHERE CO.TIPO_COORD = 'Coord'
and ct.unidade_responsavel != 'PALES'
AND al.SIT_ALUNO NOT IN ('Cancelado')
AND AL.CURSO = 'CEAI'
AND DI.DISCIPLINA != 'CEAI-RESERV'
GROUP BY	AL.ALUNO,
			PE.NOME_COMPL,
			DI.NOME_COMPL,
			CS.CURSO ,
			CS.NOME,
			AL.CURSO,
			CO.NOME_COMPL,
			CT.TURMA,
			CT.DT_INICIO,
			CT.DT_FIM,
			CT.CARGA_HORARIA,
			AL.SIT_ALUNO,
			MA.SIT_MATRICULA,
			DI.DISCIPLINA,
			DI.NOME,
			MA.CONCEITO_FIM
