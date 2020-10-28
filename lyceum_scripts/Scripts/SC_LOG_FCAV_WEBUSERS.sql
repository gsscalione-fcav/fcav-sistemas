-- Criando a tabela com a mesma estrutura da original, mas adicionando colunas de controle
IF (OBJECT_ID('Lyceum.dbo.FCAV_WEBUSERS_Log') IS NOT NULL) DROP TABLE Lyceum.dbo.FCAV_WEBUSERS_Log
CREATE TABLE Lyceum.dbo.FCAV_WEBUSERS_Log (
    NUM INT IDENTITY(1, 1),
    Dt_Atualizacao DATETIME DEFAULT GETDATE(),
    [Login] VARCHAR(100),
    Hostname VARCHAR(100),
    Operacao VARCHAR(20),

    -- Dados da tabela original
	ID numeric,
    "USER" varchar(12),
    PASS varchar(6),
    NOME varchar (50),
    CARGO varchar (50),
    EMAIL varchar (50) ,
    STATUS varchar (4),
    CODIGO_TOT varchar (6),
    STATUS_TOT varchar (4),
    GRUPO varchar (10)
)
GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgHistorico_Fcav_Webusers' AND parent_id = OBJECT_ID('Lyceum.dbo.FCAV_WEBUSERS')) > 0) DROP TRIGGER trgHistorico_Fcav_Webusers
GO

CREATE TRIGGER trgHistorico_Fcav_Webusers ON Lyceum.dbo.FCAV_WEBUSERS -- Tabela que a trigger será associada
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    
    SET NOCOUNT ON

    DECLARE 
        @Login VARCHAR(100) = SYSTEM_USER, 
        @HostName VARCHAR(100) = HOST_NAME(),
        @Data DATETIME = GETDATE()
        

    IF (EXISTS(SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
    BEGIN
        
        INSERT INTO Lyceum.dbo.FCAV_WEBUSERS_Log
        SELECT @Data, @Login, @HostName, 'UPDATE', *
        FROM Inserted

    END
    ELSE BEGIN

        IF (EXISTS(SELECT * FROM Inserted))
        BEGIN

            INSERT INTO Lyceum.dbo.FCAV_WEBUSERS_Log
            SELECT @Data, @Login, @HostName, 'INSERT', *
            FROM Inserted

        END
        ELSE BEGIN

            INSERT INTO Lyceum.dbo.FCAV_WEBUSERS_Log
            SELECT @Data, @Login, @HostName, 'DELETE', *
            FROM Deleted

        END

    END

END
GO