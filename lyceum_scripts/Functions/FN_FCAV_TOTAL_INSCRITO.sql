--* ***************************************************************  
--*  
--*  *** FUNÇÃO TABELA FN_FCAV_TOTAL_INSCRITO  ***  
--*   
--* DESCRICAO:  
--* - Função em formato tabela que exibe os totais de inscritos,  
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
--* ALTERAÇÕES:  
--*  07/11/2014 - Filtro para não trazer os candidatos testes. Gabriel S. Scalione  
--*  09/06/2015 - Filtro contar somente os candidatos inscritos pela internet
--*  02/06/2017 - Função alterada para contar os candidatos
--*  select * from VW_FCAV_MATRICULA_E_PRE_MATRICULA where concurso  = 'CEAI T 20'
--*	TESTE: SELECT DBO.FN_FCAV_TOTAL_INSCRITO('CEQP T 61')
--*
--* Autor: João Paulo  
--* Data de criação: 10/10/2013  
--* Data de Alteração: 09/06/2015  
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