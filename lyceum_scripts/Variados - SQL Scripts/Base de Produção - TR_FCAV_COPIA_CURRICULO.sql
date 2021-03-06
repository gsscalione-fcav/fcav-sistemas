USE [LYCEUM]
GO
/****** Object:  Trigger [dbo].[TR_FCAV_COPIA_CURRICULO]    Script Date: 01/24/2017 14:24:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TR_FCAV_COPIA_CURRICULO]
ON [dbo].[LY_MINI_CURRICULO]
AFTER INSERT, UPDATE

AS

DECLARE @PESSOA VARCHAR(20)
DECLARE @NOME VARCHAR(100)
DECLARE @EXTENSAO VARCHAR(10)


SET @EXTENSAO = (SELECT EXTENSAO FROM INSERTED)
SET @PESSOA = (SELECT PESSOA FROM INSERTED)

BEGIN


DECLARE ExtraiCurriculo CURSOR
FOR

		SELECT DISTINCT PESSOA, NOME
		FROM LY_MINI_CURRICULO
		WHERE EXTENSAO = @EXTENSAO AND PESSOA = @PESSOA

OPEN ExtraiCurriculo 

FETCH NEXT FROM ExtraiCurriculo
			INTO @PESSOA, @NOME

DECLARE @pctStr INT
DECLARE @image VARBINARY(MAX)
DECLARE @P_NOME T_ALFALARGE
DECLARE @P_PESSOA T_CODIGO	
 

WHILE @@FETCH_STATUS = 0

BEGIN	

SELECT @P_NOME = PES.CPF+'_'+CONVERT(VARCHAR,CV.PESSOA,20)
FROM LY_MINI_CURRICULO as CV inner join LY_PESSOA AS PES on (CV.PESSOA = PES.PESSOA)
WHERE CV.PESSOA = @PESSOA
AND EXTENSAO = @EXTENSAO

	--- aqui você substitui pela tabela e faz a query. Você também pode criar uma proc que exporte tudo
	SET @image = (SELECT DOCUMENTO_CURRICULO FROM LY_MINI_CURRICULO WHERE EXTENSAO = @EXTENSAO AND PESSOA = @PESSOA)
	DECLARE @filePath VARCHAR(8000)
	SET @filePath = 'C:\\Curriculo\'+@P_NOME+@EXTENSAO
	EXEC sp_OACreate 'ADODB.Stream', @pctStr OUTPUT
	EXEC sp_OASetProperty @pctStr, 'Type', 1
	EXEC sp_OAMethod @pctStr, 'Open'
	EXEC sp_OAMethod @pctStr,  'Write', NULL, @image
	EXEC sp_OAMethod @pctStr, 'SaveToFile', NULL,@filePath, 2
	EXEC sp_OAMethod @pctStr, 'Close'
	EXEC sp_OADestroy @pctStr


FETCH NEXT FROM ExtraiCurriculo INTO @PESSOA, @NOME
END
CLOSE ExtraiCurriculo
DEALLOCATE ExtraiCurriculo


exec master.dbo.xp_cmdshell 'net use X: \\10.200.50.14\Curriculos /USER:bd.lyceum Gtw_853_!'

EXEC master.dbo.XP_CMDSHELL 'copy c:\Curriculo\* X: /Y'

exec xp_cmdshell 'net use X: /DELETE'
	



END