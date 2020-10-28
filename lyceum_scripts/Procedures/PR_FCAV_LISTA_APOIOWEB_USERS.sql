IF EXISTS (SELECT
        *
    FROM SYS.procedures
    WHERE name = 'PR_FCAV_LISTA_APOIOWEB_USERS')
    DROP PROCEDURE PR_FCAV_LISTA_APOIOWEB_USERS
GO

CREATE PROCEDURE PR_FCAV_LISTA_APOIOWEB_USERS (@apoioweb varchar(20))
AS
    SET NOCOUNT ON
    BEGIN
      
        SELECT
            ID,
            "USER",
            PASS,
            NOME,
            CARGO,
            EMAIL,
            TI.DESCR AS STATUS,
            CODIGO_TOT,
            STATUS_TOT,
            GRUPO
        FROM FCAV_WEBUSERS FW
        INNER JOIN HD_TABELAITEM TI
            ON TI.ITEM = FW.STATUS
            AND TI.TABELA = 'PerfilAcessoApoioWeb'
        WHERE @apoioweb = @apoioweb
        ORDER BY ID

    END