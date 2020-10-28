--* ***************************************************************  
--*  
--*  *** FUN��O FN_FCAV_TOTAL_CONVOCADO  ***  
--*   
--* DESCRICAO:  
--* - Fun��o em formato tabela que exibe os totais de convocados  
--* de um processo seletivo.  
--*  
--* PARAMETROS:  
--* - O par�metro a ser passado � o c�digo do CONCURSO  
--*   
--*  
--* USO:  
--*  Utilizado no script SC_FCAV_CRONOGRAMA_TURMAS  
--*  
--* ALTERA��ES:  
--*  
--* Autor: Gabriel  
--*  07/11/2014  
--*  
--* ***************************************************************  


ALTER FUNCTION FN_FCAV_CONVOCADOS (@CONCURSO varchar(20))

RETURNS varchar(5)

AS
BEGIN
    DECLARE @ret_convocados varchar(5)

    SELECT
        @ret_convocados = COUNT(CA.CANDIDATO)

    FROM LY_CANDIDATO CA
    LEFT JOIN LY_CONVOCADOS_VEST CV
        ON CV.CANDIDATO = CA.CANDIDATO
        AND CV.CONCURSO = CA.CONCURSO
    WHERE CA.CONCURSO = @CONCURSO
    AND CV.MATRICULADO = 'N'


    RETURN @ret_convocados

END