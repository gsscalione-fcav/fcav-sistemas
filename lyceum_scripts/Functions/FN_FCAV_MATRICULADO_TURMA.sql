--* ***************************************************************  
--*  
--*  *** FUN��O FN_FCAV_MATRICULADO_TURMA  ***  
--*   
--* DESCRICAO:  
--* - Fun��o para trazer o total de alunos matriculados na TURMA  
--*  
--* PARAMETROS:  
--* - O par�metro a ser passado � o c�digo da turma  
--*   
--*  
--* USO:  
--* - O uso ser� para gera��o de relat�rios  
--*  
--* ALTERA��ES:  
--*  07/11/2014 - Alterado o parametro da fun��o utilizando s� a turma,   
--*      e alterado a view de consulta, utilizando um resumo de matricula e pre_matricula  
--*  
--*    TESTE: SELECT DBO.FN_FCAV_MATRICULADO_TURMA('MBA-EE T 01')
--*
--* Autor: Gabriel S. Scalione  
--* Data de cria��o: 12/05/2013  
--*  
--* ***************************************************************  


ALTER FUNCTION FN_FCAV_MATRICULADO_TURMA (@turma varchar(20))

RETURNS varchar(5)

AS
BEGIN

    DECLARE @ret_matriculados varchar(5)

    SELECT @ret_matriculados = 
			COUNT(ALUNO)
    FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA2
    WHERE SIT_MATRICULA = 'Matriculado'
	--AND TIPO_INGRESSO != 'Depend�ncia'
	AND SIT_DETALHE like 'Curricular%'
    AND TURMA = @turma
	group by TURMA

    RETURN @ret_matriculados

END