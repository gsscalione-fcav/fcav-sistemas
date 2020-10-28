IF EXISTS (SELECT
        *
    FROM SYS.procedures
    WHERE name = 'PR_FCAV_LISTA_PERFIL_APOIOWEB')
    DROP PROCEDURE PR_FCAV_LISTA_PERFIL_APOIOWEB
GO

CREATE PROCEDURE PR_FCAV_LISTA_PERFIL_APOIOWEB (@apoioweb varchar(20))
 AS
  SET NOCOUNT ON
    BEGIN
	 select 
		DESCR 
	 from 
		HD_TABELAITEM 
	 where TABELA = 'PerfilAcessoApoioWeb'
	 AND @apoioweb = @apoioweb
 END