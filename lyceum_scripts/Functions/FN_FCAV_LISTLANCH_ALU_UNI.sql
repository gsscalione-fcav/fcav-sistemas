/*  
FN_FCAV_LISTLANCH_ALU_UNI 
  
Função que retorna a quantidade de alunos únicos de uma sala em uma data, desconsiderando
matrículas para duas disciplinas no mesmo dia.
  
Autor: João Paulo 
Data: 09/10/2018  
*/  
  
ALTER FUNCTION FN_FCAV_LISTLANCH_ALU_UNI  (@DATA DATETIME, @SALA VARCHAR (20)) RETURNS VARCHAR (20)  AS  
BEGIN  

DECLARE @QTD_ALU_UNI VARCHAR(2)

SELECT
	@QTD_ALU_UNI = COUNT(DISTINCT ALUNO)
FROM
	VW_FCAV_AGENDA_ALUNO_DISCIPLINA
WHERE 
	DATA = @DATA
AND SALA	 = @SALA
AND TURMA NOT LIKE 'A-PDT%'

GROUP BY
	DATA,
	SALA
RETURN @QTD_ALU_UNI
END
