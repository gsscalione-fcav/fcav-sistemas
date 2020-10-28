--* ***************************************************************  
--*  
--*  *** FUNÇÃO FN_FCAV_CANCELADO_TURMA  ***  
--*   
--* DESCRICAO:  
--* - Função para trazer o total de alunos cancelados na TURMA  
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
--*	TESTE: SELECT DBO.FN_FCAV_CANCELADO_TURMA('CEQP T 61')
--* 
--* Autor: Gabriel S. Scalione  
--* Data de criação: 12/05/2013  
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