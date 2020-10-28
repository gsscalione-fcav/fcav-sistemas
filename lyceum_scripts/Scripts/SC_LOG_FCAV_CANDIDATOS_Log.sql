-- Criando a tabela com a mesma estrutura da original, mas adicionando colunas de controle
IF (OBJECT_ID('Lyceum.dbo.FCAV_CANDIDATOS_Log') IS NOT NULL) DROP TABLE Lyceum.dbo.FCAV_CANDIDATOS_Log
CREATE TABLE Lyceum.dbo.FCAV_CANDIDATOS_Log (
    NUM INT IDENTITY(1, 1),
    Dt_Atualizacao DATETIME DEFAULT GETDATE(),
    [Login] VARCHAR(100),
    Hostname VARCHAR(100),
    Operacao VARCHAR(20),

    -- Dados da tabela original
	CANDIDATO	varchar	(20),
	CONCURSO	varchar	(20),
	CONVOCADO	char	(1),
	DATA_CONV	datetime,
	LINK_CV	varchar	(200),
	PESSOA	varchar	(20),
	OBSERV1	varchar	(2000),
	OBSERV2	varchar	(2000),
	OBSERV3	varchar	(2000),
	ST_SECRET	char	(1),
	DATA_SECRET	datetime,
	OBSERV4	varchar	(2000),
	OBSERV5	varchar	(2000),
	OBSERV6	varchar	(2000),
	OBSERV7	varchar	(2000),
	OBSERV8	varchar	(2000),
	OBSERV9	varchar	(2000),
	OBSERV10	varchar	(2000),
	DATA_INSC	datetime
)
GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgHistorico_FCAV_CANDIDATOS' AND parent_id = OBJECT_ID('Lyceum.dbo.FCAV_CANDIDATOS')) > 0) DROP TRIGGER trgHistorico_FCAV_CANDIDATOS
GO

CREATE TRIGGER trgHistorico_FCAV_CANDIDATOS ON Lyceum.dbo.FCAV_CANDIDATOS -- Tabela que a trigger será associada
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    
    SET NOCOUNT ON

    DECLARE 
        @Login VARCHAR(100) = SYSTEM_USER, 
        @HostName VARCHAR(100) = HOST_NAME(),
        @Data DATETIME = GETDATE()
        

    IF (EXISTS(SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
    BEGIN
        
        INSERT INTO Lyceum.dbo.FCAV_CANDIDATOS_Log
        SELECT @Data, @Login, @HostName, 'UPDATE', *
        FROM Inserted

    END
    ELSE BEGIN

        IF (EXISTS(SELECT * FROM Inserted))
        BEGIN

            INSERT INTO Lyceum.dbo.FCAV_CANDIDATOS_Log
            SELECT @Data, @Login, @HostName, 'INSERT', *
            FROM Inserted

        END
        ELSE BEGIN

            INSERT INTO Lyceum.dbo.FCAV_CANDIDATOS_Log
            SELECT @Data, @Login, @HostName, 'DELETE', *
            FROM Deleted

        END

    END

END
GO