/* ***************************************************************      
--*      
--*     *** TRIGGER TR_FCAV_ATUALIZA_TURMA  ***      
--*      
--*	FINALIDADE: Trigger para verificar se a tabela FCAV_EXTRATO_FINANCEIRO2 
--*				possui a turma e centro de custo do aluno vazio e preenche
--*				esses campos.      
--* ALTERAÇÕES:      
--*      
--* Autor: Gabriel Serrano Scalione
--* Data de criação: 05/01/2018     

--* *****************************************************************************/

CREATE TRIGGER TR_FCAV_ATUALIZA_TURMA
ON FCAV_EXTRATO_FINANCEIRO2
AFTER INSERT

AS
	
	UPDATE FCAV_EXTRATO_FINANCEIRO2
	SET
		TURMA = MP.TURMA ,
		CENTRO_DE_CUSTO = CC.C_CUSTO_DISCIPLINA
	FROM
		FCAV_EXTRATO_FINANCEIRO2 EX
		INNER JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP
			ON MP.ALUNO = EX.ALUNO
		INNER JOIN VW_FCAV_VERIFICA_CENTRO_CUSTO CC
			on CC.TURMA = MP.TURMA
	WHERE
		(EX.TURMA IS NULL 
		OR EX.CENTRO_DE_CUSTO IS NULL)
		AND CC.C_CUSTO_DISCIPLINA IS NOT NULL
		AND EX.ALUNO = MP.ALUNO