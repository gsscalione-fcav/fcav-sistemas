--* ***************************************************************  
--*  
--*  *** FUN��O FN_FCAV_CANCELADO_TURMA  ***  
--*   
--* DESCRICAO:  
--* - Fun��o para trazer o total de alunos cancelados na TURMA  
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
--*	TESTE: SELECT DBO.FN_FCAV_CANCELADO_TURMA('CEQP T 61')
--* 
--* Autor: Gabriel S. Scalione  
--* Data de cria��o: 12/05/2013  
--*  
--* ***************************************************************  


ALTER FUNCTION FN_FCAV_CANCELADO_TURMA (@turma varchar(20))

RETURNS varchar(5)

AS
BEGIN

    DECLARE @ret_cancelados varchar(5)

    SELECT
        @ret_cancelados = COUNT(ALUNO)
    FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA
    WHERE SIT_MATRICULA = 'Cancelado'
    AND TURMA = @turma

    RETURN @ret_cancelados

END