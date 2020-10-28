--* ***************************************************************  
--*  
--*  *** FUNÇÃO FN_FCAV_TOTAL_CANCELADO  ***  
--*   
--* DESCRICAO:  
--* - Função em formato tabela que exibe os totais de cancelados  
--* de um processo seletivo.  
--*  
--* PARAMETROS:  
--* - O parâmetro a ser passado é o código do CONCURSO  
--*   
--*  
--* USO:  
--* - O uso será excluvivo em uma página ASP utilizada pelos  
--* coordenadores avaliarem o processo seletivo  
--*  
--*	TESTE: SELECT DBO.FN_FCAV_TOTAL_CANCELADO('CEQP T 61')
--*
--*  
--* Autor: João Paulo  
--* Data de criação: 10/10/2013  
--* Data de Alteração: 10/10/2013  
--*  
--* ***************************************************************  


ALTER FUNCTION FN_FCAV_TOTAL_CANCELADO (@CONCURSO varchar(20))

RETURNS varchar(5)

AS
BEGIN

    DECLARE @RET_TOTAL_CANCELADO varchar(5)

    SELECT 
		@RET_TOTAL_CANCELADO = COUNT(CA.CANDIDATO)
    FROM LY_CANDIDATO CA
    LEFT JOIN LY_CONVOCADOS_VEST CV
        ON CV.CANDIDATO = CA.CANDIDATO
        AND CV.CONCURSO = CA.CONCURSO
    WHERE CA.CONCURSO = @CONCURSO
    AND SIT_CANDIDATO_VEST = 'Cancelado'
    AND (CV.MATRICULADO IS NULL
    OR CV.MATRICULADO = 'N')

    RETURN @RET_TOTAL_CANCELADO

END