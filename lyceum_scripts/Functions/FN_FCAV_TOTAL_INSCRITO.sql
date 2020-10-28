--* ***************************************************************  
--*  
--*  *** FUN��O TABELA FN_FCAV_TOTAL_INSCRITO  ***  
--*   
--* DESCRICAO:  
--* - Fun��o em formato tabela que exibe os totais de inscritos,  
--* de um processo seletivo.  
--*  
--* PARAMETROS:  
--* - O par�metro a ser passado � o c�digo do CONCURSO  
--*   
--*  
--* USO:  
--* - O uso ser� excluvivo em uma p�gina ASP utilizada pelos  
--* coordenadores avaliarem o processo seletivo  
--*  
--* ALTERA��ES:  
--*  07/11/2014 - Filtro para n�o trazer os candidatos testes. Gabriel S. Scalione  
--*  09/06/2015 - Filtro contar somente os candidatos inscritos pela internet
--*  02/06/2017 - Fun��o alterada para contar os candidatos
--*  select * from VW_FCAV_MATRICULA_E_PRE_MATRICULA where concurso  = 'CEAI T 20'
--*	TESTE: SELECT DBO.FN_FCAV_TOTAL_INSCRITO('CEQP T 61')
--*
--* Autor: Jo�o Paulo  
--* Data de cria��o: 10/10/2013  
--* Data de Altera��o: 09/06/2015  
--*  
--* ***************************************************************  


ALTER FUNCTION FN_FCAV_TOTAL_INSCRITO (@CONCURSO varchar(20))

RETURNS varchar(5)

AS
BEGIN

    DECLARE @RET_TOTAL_INSCRITO varchar(5)

    SELECT
        @RET_TOTAL_INSCRITO = COUNT(CANDIDATO)
    FROM VW_FCAV_INSCRITOS CA
    WHERE CA.CONCURSO = @CONCURSO
		--and  ca.NOME_COMPL not like '%teste%'
	GROUP BY CA.CONCURSO
	
    RETURN @RET_TOTAL_INSCRITO

END