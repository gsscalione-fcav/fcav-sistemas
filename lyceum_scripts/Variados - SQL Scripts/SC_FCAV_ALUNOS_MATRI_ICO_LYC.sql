SELECT 
	* 
FROM 
	VW_FCAV_RELACAO_GERAL_DE_CURSOS_LYCEUM
WHERE TURMA like 'A-LA9001.15 T 08'


SELECT 
 SISTEMA,
 CURSO,
 TURMA,
 NOME_COMPL,
 E_MAIL, 
 DATA_MATRICULA,
 SIT_ALUNO,
 SIT_MATRICULA,
 STATUS
FROM 
	VW_FCAV_INFO_ALUNOS_LYCEUM_ICORUJA
WHERE
	SIT_MATRICULA NOT LIKE 'Cancelado'
GROUP BY
	SISTEMA,
	DATA_MATRICULA,
	CURSO,
	TURMA,
	NOME_COMPL,
	E_MAIL,
	SIT_ALUNO,
	SIT_MATRICULA,
	STATUS


