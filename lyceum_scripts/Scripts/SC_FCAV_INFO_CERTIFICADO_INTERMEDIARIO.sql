/*
	VIEW VW_FCAV_INFO_CERTIFICADO_INTERMEDIARIO

Finalidade: Consulta para trazer a rela��o de alunos aprovados nas 5 primeiras disciplinas dos cursos CEGP E CEAI.

Autor: Gabriel S Scalione
Data:  19/08/2019
*/


USE LYCEUM
GO

CREATE VIEW VW_FCAV_INFO_CERTIFICADO_INTERMEDIARIO
AS
--Rankeia as disciplinas
WITH DISCIPLINA_INTERMEDIARIAS as (
	
	SELECT
		TURMA, DISCIPLINA, MIN(DT_INICIO) AS DT_INICIO, MAX(DT_FIM) DT_FIM,
		RANK() OVER (PARTITION BY TURMA ORDER BY DT_INICIO, DT_FIM,TURMA, DISCIPLINA) AS RankResult  
	FROM LY_TURMA
	WHERE 
		CURSO IN ('CEAI','CEGP')
		AND DISCIPLINA NOT IN ('CEGP-EAP')
	GROUP BY DT_INICIO, DT_FIM,TURMA, DISCIPLINA 
	
)

--Realiza a consulta trazendo as 5 primeiras disciplinas realizadas.
SELECT 
	AL.ALUNO,
	AL.NOME_COMPL AS NOME_ALUNO,
	CS.FACULDADE AS UNIDADE_RESPONSAVEL,
	CS.CURSO,
	CS.NOME AS NOME_CURSO,
	CO.NOME_COMPL AS NOME_COORD,
	PE.SEXO,
	HI.TURMA,
	HI.DISCIPLINA,
	DI.NOME_COMPL AS NOME_DISCIP,
	TU.ANO,
	TU.SEMESTRE,
	TU.DT_INICIO,
	TU.DT_FIM,
	HI.HORAS_AULA,
	HI.NOTA_FINAL,
	HI.PERC_PRESENCA,
	HI.SITUACAO_HIST

FROM LY_ALUNO AL
	INNER JOIN LY_HISTMATRICULA HI
		ON HI.ALUNO = AL.ALUNO
	INNER JOIN LY_TURMA TU
		ON TU.TURMA = HI.TURMA
		AND TU.DISCIPLINA = HI.DISCIPLINA
	INNER JOIN LY_DISCIPLINA DI
		ON DI.DISCIPLINA = HI.DISCIPLINA
	INNER JOIN LY_CURSO CS
		ON CS.CURSO = AL.CURSO
	INNER JOIN VW_FCAV_COORDENADOR_TURMA CO
		ON CO.TURMA = HI.TURMA
	INNER JOIN LY_PESSOA PE 
		ON PE.NUM_FUNC = CO.NUM_FUNC
	INNER JOIN	DISCIPLINA_INTERMEDIARIAS DN
		ON DN.DISCIPLINA = TU.DISCIPLINA
		AND DN.TURMA = TU.TURMA
WHERE
	SITUACAO_HIST = 'Aprovado'
	AND CS.CURSO IN ('CEAI','CEGP')
	AND CO.TIPO_COORD = 'COORD'
	AND DN.RankResult <= 5
GROUP BY
	TU.DT_INICIO,
	TU.DT_FIM,
	HI.TURMA,
	HI.DISCIPLINA,
	DI.NOME_COMPL,
	TU.ANO,
	TU.SEMESTRE,
	CS.FACULDADE,
	CS.CURSO,
	CS.NOME,
	CO.NOME_COMPL,
	AL.ALUNO,
	AL.NOME_COMPL,
	PE.SEXO,
	HI.HORAS_AULA,
	HI.NOTA_FINAL,
	HI.PERC_PRESENCA,
	HI.SITUACAO_HIST
