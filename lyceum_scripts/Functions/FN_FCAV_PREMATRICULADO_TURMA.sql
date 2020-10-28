--* ***************************************************************  
--*  
--*  *** FUNÇÃO FN_FCAV_PREMATRICULADO_TURMA  ***  
--*   
--* DESCRICAO:  
--* - Função para trazer o total de alunos pré-matriculados na TURMA  
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
--*	TESTE: SELECT DBO.FN_FCAV_PREMATRICULADO_TURMA('CEAI T 29')
--*  
--* Autor: Gabriel S. Scalione  
--* Data de criação: 12/05/2013  
--*  
--* ***************************************************************  


ALTER FUNCTION FN_FCAV_PREMATRICULADO_TURMA (@turma varchar(20))

RETURNS varchar(5)

AS
BEGIN

    DECLARE @ret_prematriculados varchar(5)

    SELECT
        @ret_prematriculados = COUNT(ALUNO)
    FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA
    WHERE SIT_MATRICULA = 'Pre-Matriculado'
    AND TURMA = @turma

    RETURN @ret_prematriculados

END