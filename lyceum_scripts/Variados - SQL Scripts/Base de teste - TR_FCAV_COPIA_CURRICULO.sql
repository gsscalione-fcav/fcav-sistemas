USE [LYCEUM]
GO
/****** Object:  Trigger [dbo].[TR_FCAV_COPIA_CURRICULO]    Script Date: 01/24/2017 14:28:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TR_FCAV_COPIA_CURRICULO]
ON [dbo].[LY_MINI_CURRICULO]
AFTER INSERT, UPDATE AS
BEGIN
    INSERT INTO FCAV_TRG_MINI_CURRICULO(PESSOA)
    SELECT PESSOA
    FROM INSERTED
    WHERE PESSOA NOT IN(
            SELECT PESSOA
            FROM FCAV_TRG_MINI_CURRICULO
        )
END
