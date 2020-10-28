--* ***************************************************************  
--*  
--*  *** FUNÇÃO FN_FCAV_MATRICULADO_TURMA  ***  
--*   
--* DESCRICAO:  
--* - Função para trazer o total de alunos matriculados na TURMA  
--*  
--* PARAMETROS:  
--* - O parâmetro a ser passado é o código da turma  
--*   
--*  
--* USO:  
--* - O uso será para geração de relatórios  
--*  
--* ALTERAÇÕES:  
--*  07/11/2014 - Alterado o parametro da função utilizando só a turma,   
--*      e alterado a view de consulta, utilizando um resumo de matricula e pre_matricula  
--*  
--*    TESTE: SELECT DBO.FN_FCAV_MATRICULADO_TURMA('MBA-EE T 01')
--*
--* Autor: Gabriel S. Scalione  
--* Data de criação: 12/05/2013  
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
	--AND TIPO_INGRESSO != 'Dependência'
	AND SIT_DETALHE like 'Curricular%'
    AND TURMA = @turma
	group by TURMA

    RETURN @ret_matriculados

END