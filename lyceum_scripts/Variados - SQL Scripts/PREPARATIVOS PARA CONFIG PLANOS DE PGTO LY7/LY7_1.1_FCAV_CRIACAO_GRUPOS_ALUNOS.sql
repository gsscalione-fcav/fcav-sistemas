
-----------------------------------------------------------------
--BLOCO CRIA��O DOS GRUPOS DE ALUNOS

INSERT INTO LY_GRUPO_ALUNO(GRUPO,DESCRICAO)
SELECT
	GRUPO_TURMA,
	'Valor fixo para turma - '+ TURMA
FROM	
	VW_FCAV_CONFIG_PLANO_PGTO
WHERE
	DT_INI_TURMA<=GETDATE()		--Trazer as turmas em andamento
GROUP BY
	GRUPO_TURMA,
	TURMA

SELECT 
	*
FROM
	LY_GRUPO_ALUNO GA

GO

-----------------------------------------------------------------
--BLOCO ASSOCIANDO OS GRUPOS AOS SERVICOS DOS CURSOS

INSERT INTO LY_ALUNO_SERVICO(SERVICO,GRUPO,CUSTO_UNITARIO)
SELECT
	SERVICO_MENSALIDADE,
	GRUPO_TURMA,
	1
FROM	
	VW_FCAV_CONFIG_PLANO_PGTO
WHERE
	DT_INI_TURMA<=GETDATE()
GROUP BY
	GRUPO_TURMA,
	SERVICO_MENSALIDADE

SELECT
*
FROM 
	LY_ALUNO_SERVICO
GO