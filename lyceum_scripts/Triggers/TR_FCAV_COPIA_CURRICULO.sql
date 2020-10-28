--* ***************************************************************
--*
--*		*** TRIGGER TR_FCAV_COPIA_CURRICULO  ***
--*	
--*	DESCRICAO:
--*	- Trigger indicar quais currículso anexados pelo candidato têm
--*   de ser copiados para o ApoioWeb
--*
--*	ALTERAÇÕES:
--*		
--*  - Código movido para o SQL Server Agent 
--*	 - 06/09/2017: Colocado filtro para não puxar arquivos menores que um 1KB, 
--*	   para evitar a ida de arquivos corrompidos. Gabriel SS
--*	 - 05/10/2018: Implementado um recurso que atualiza o curriculo na hora. Gabriel SS.
--*
--*    Autor: Marcus Vinicius Pompeu
--*	   Data de criação: 28/11/2016
--*	
--* ***************************************************************

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'TR_FCAV_COPIA_CURRICULO')
DROP TRIGGER [TR_FCAV_COPIA_CURRICULO]
go

CREATE TRIGGER [dbo].[TR_FCAV_COPIA_CURRICULO]
ON [dbo].[LY_MINI_CURRICULO]
AFTER INSERT, UPDATE, DELETE AS
BEGIN

	SET NOCOUNT ON

	DECLARE @pessoa T_numero
	DECLARE @TAM_FILE NUMERIC


	if exists(select 1 from deleted)
	begin

		SELECT 
			@pessoa = PESSOA
		FROM deleted
	end
	else 
	begin
		SELECT 
			@pessoa = PESSOA
		FROM inserted
	end
		
	----------------------------------------------------------------------

	SELECT 
		@TAM_FILE  = CAST(DATALENGTH(DOCUMENTO_CURRICULO) AS NUMERIC)
	FROM LY_MINI_CURRICULO CV
	WHERE CV.PESSOA = PESSOA
	
	IF (@TAM_FILE > 1000)
	BEGIN
		INSERT INTO FCAV_TRG_MINI_CURRICULO(PESSOA)
		SELECT PESSOA
		FROM INSERTED
		WHERE 
			@TAM_FILE > 1000
			AND PESSOA NOT IN(
				SELECT PESSOA
				FROM FCAV_TRG_MINI_CURRICULO
			)
	END

	-- 
	IF exists(select 1 from LY_CANDIDATO where PESSOA = @pessoa)
	begin
		UPDATE LY_CANDIDATO 
		SET
			OBS = OBS +'<br>'+ convert(varchar,getdate(),103) +' - Currículo novo anexado. <br> ' 
		where
			PESSOA = @pessoa
		 
		EXEC msdb.dbo.sp_start_job N'JOB_FCAV_COPIA_CURRICULO'
	end

END
GO