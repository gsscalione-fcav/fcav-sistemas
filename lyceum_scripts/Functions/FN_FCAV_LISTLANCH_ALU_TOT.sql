/*  
FN_FCAV_LISTLANCH_ALU_TOT  
  
Função que retorna a quantidade de aluno de uma sala em uma data, mesmo 
que repita o aluno por ele estar matriculado em duas disciplinas 
do mesmo dia.
  
Autor: João Paulo 
Data: 09/10/2018  
*/  
  
ALTER FUNCTION FN_FCAV_LISTLANCH_ALU_TOT  (@DATA DATETIME, @SALA VARCHAR (20)) RETURNS VARCHAR (20)  AS  
BEGIN  

DECLARE @QTD_ALU_TOT VARCHAR(2)

SELECT
	@QTD_ALU_TOT = COUNT(ALUNO)
FROM
	VW_FCAV_AGENDA_ALUNO_DISCIPLINA
WHERE 
	DATA = @DATA
AND SALA	 = @SALA
AND TURMA NOT LIKE 'A-PDT%'

GROUP BY
	DATA,
	SALA
RETURN @QTD_ALU_TOT
END
