SELECT 
	* 
FROM 
	VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA
WHERE
	ANO_INGRESSO = 2018						-- Ano que os alunos ingressaram
	AND UNIDADE_RESPONSAVEL != 'PALES'		-- Diferente de Palestra
	AND STATUS_TURMA != 'Cancelada'			-- Diferente de turmas Canceladas
	AND SIT_MATRICULA = 'Matriculado'		-- Somente alunos matriculados
	and SIT_DETALHE = 'Curricular'			-- Que não sejam alunos 
