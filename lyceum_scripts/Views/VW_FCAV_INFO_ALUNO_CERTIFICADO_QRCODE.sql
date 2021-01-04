/*
		VIEW VW_FCAV_INFO_ALUNO_CERTIFICADO_QRCODE
	
	Finalidade: Trazer informa��es para emiss�o de certificados dos alunos com qr code
		utilizado no banco LYCEUM_MEDIA
		
		Para trazer as informa��es da frequencia do aluno, a turma precisa estar com o per�odo letivo fechado "Fechamento do per�odo letivo", para q as disciplinas fiquem no hist�rico.


	Autor: Gabriel Serrano Scalione
	Criado em: 19/06/2020

*/


USE LYCEUM
GO

ALTER VIEW VW_FCAV_INFO_ALUNO_CERTIFICADO_QRCODE
AS


with docente_turma AS 
(
	SELECT    
	 TUR.CURSO AS CURSO,    
	 TUR.TURMA,    
	 TUR.DISCIPLINA AS DISCIPLINA,    
	 DOC.NUM_FUNC AS ID_DOCENTE,
	 DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(LTRIM(RTRIM(DOC.NOME_COMPL))) AS NOME_DOCENTE
	FROM    
	 LY_TURMA TUR    
	 INNER JOIN LY_DISCIPLINA DIS ON (TUR.DISCIPLINA = DIS.DISCIPLINA)    
	 INNER JOIN LY_AGENDA AGE ON (TUR.TURMA = AGE.TURMA AND TUR.DISCIPLINA = AGE.DISCIPLINA AND TUR.SEMESTRE = AGE.SEMESTRE)    
	 INNER JOIN LY_DOCENTE DOC ON (DOC.NUM_FUNC = AGE.NUM_FUNC)    
  
	WHERE TUR.CLASSIFICACAO != 'Cancelada'
		AND DOC.NUM_FUNC !=83484
  
	GROUP BY     
	 TUR.CURSO, TUR.TURMA,TUR.DISCIPLINA,DOC.NUM_FUNC, DOC.NOME_COMPL
)


SELECT
	AL.ALUNO,
	PE.NOME_COMPL,
	PE.RG_NUM,
	AL.SIT_ALUNO,
	HI.SITUACAO_HIST AS SIT_MATRICULA,
	CASE WHEN CS.CURSO = 'ATUALIZACAO' OR CS.CURSO = 'PALESTRA' THEN DI.NOME_COMPL
	ELSE CS.NOME END AS NOME_CURSO,
	AL.CURSO,
	CO.NUM_FUNC,
	CO.NOME_COMPL AS NOME_COORD,
	CT.TURMA,
	CT.DT_INICIO,
	CT.DT_FIM,
	CT.CARGA_HORARIA,
	HI.DISCIPLINA,
	DI.NOME AS NOME_DISCIPLINA,
	CAST(CAST(DI.HORAS_AULA AS int) AS varchar) + ' horas' AS CARGA_HOR_DISCIPLINA,
	DT.ID_DOCENTE,
	isnull(DT.NOME_DOCENTE, 'Docente n�o informado') NOME_DOCENTE,
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
	LEFT JOIN docente_turma DT
		ON DT.TURMA = CT.TURMA
		AND DT.DISCIPLINA = DI.DISCIPLINA
WHERE CO.TIPO_COORD = 'Coord'
and ct.unidade_responsavel != 'PALES'
AND al.SIT_ALUNO NOT IN ('Cancelado')
AND DI.DISCIPLINA != 'CEAI-RESERV'
and YEAR(CT.DT_FIM) >=2019
GROUP BY	CT.DT_INICIO,
			CT.TURMA,
			AL.ALUNO,
			PE.NOME_COMPL,
			PE.RG_NUM,
			DI.NOME_COMPL,
			CS.CURSO ,
			CS.NOME,
			AL.CURSO,
			CO.NUM_FUNC,
			CO.NOME_COMPL,
			CT.DT_FIM,
			CT.CARGA_HORARIA,
			AL.SIT_ALUNO,
			HI.SITUACAO_HIST,
			HI.DISCIPLINA,
			DI.DISCIPLINA,
			DI.NOME,
			DI.HORAS_AULA,
			DT.ID_DOCENTE,
			DT.NOME_DOCENTE,
			hi.NOTA_FINAL,
			hi.PERC_PRESENCA

UNION ALL

SELECT
	AL.ALUNO,
	PE.NOME_COMPL,
	PE.RG_NUM,
	AL.SIT_ALUNO,
	MA.SIT_MATRICULA,
	CASE WHEN CS.CURSO = 'ATUALIZACAO' OR CS.CURSO = 'PALESTRA' THEN DI.NOME_COMPL
	ELSE CS.NOME END AS NOME_CURSO,
	AL.CURSO,
	CO.NUM_FUNC,
	CO.NOME_COMPL AS NOME_COORD,
	CT.TURMA,
	CT.DT_INICIO,
	CT.DT_FIM,
	CT.CARGA_HORARIA,
	DI.DISCIPLINA,
	DI.NOME AS NOME_DISCIPLINA,
	CAST(CAST(DI.HORAS_AULA AS int) AS varchar) + ' horas' AS CARGA_HOR_DISCIPLINA,
	DT.ID_DOCENTE,
	isnull(DT.NOME_DOCENTE, 'Docente n�o informado') NOME_DOCENTE,
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
	LEFT JOIN docente_turma DT
		ON DT.TURMA = CT.TURMA
		AND DT.DISCIPLINA = DI.DISCIPLINA
WHERE CO.TIPO_COORD = 'Coord'
and ct.unidade_responsavel != 'PALES'
AND al.SIT_ALUNO NOT IN ('Cancelado')
AND DI.DISCIPLINA != 'CEAI-RESERV'
and YEAR(CT.DT_FIM) >= 2019
GROUP BY	CT.DT_INICIO,
			CT.TURMA,
			AL.ALUNO,
			PE.NOME_COMPL,
			PE.RG_NUM,
			DI.NOME_COMPL,
			CS.CURSO ,
			CS.NOME,
			AL.CURSO,
			CO.NUM_FUNC,
			CO.NOME_COMPL,
			CT.DT_FIM,
			CT.CARGA_HORARIA,
			AL.SIT_ALUNO,
			MA.SIT_MATRICULA,
			DI.DISCIPLINA,
			DI.NOME,
			DI.HORAS_AULA,
			DT.ID_DOCENTE,
			DT.NOME_DOCENTE,
			MA.CONCEITO_FIM
