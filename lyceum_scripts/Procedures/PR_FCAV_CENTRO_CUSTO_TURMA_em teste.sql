
CREATE PROCEDURE PR_FCAV_CENTRO_CUSTO_TURMA (@turma varchar, @txtbuscacentrocusto varchar)
AS 
	SELECT 
	*
	FROM HD_TABELAITEM
	WHERE
		TABELA = 'CentroCusto'
		and DESCR = @turma

   --condi��es para retornar o valor na grid oculta da tela da oferta do NG, N�O REMOVER. Gabriel
    IF @txtbuscacentrocusto = 'N'
    BEGIN
        SELECT
            5 AS VALOR
    END
    ELSE
    BEGIN
        SELECT
            3 AS VALOR
    END