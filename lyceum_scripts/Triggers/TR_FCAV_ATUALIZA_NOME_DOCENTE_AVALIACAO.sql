-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Gabriel S. Scalione
-- Create date: 26/11/2020
-- Description:	Trigger para manter atualizado o nome do docente na tabela LY_AVALIADO para Avaliação Docente
-- =============================================


CREATE TRIGGER TR_FCAV_ATUALIZA_NOME_DOCENTE_AVALIACAO
   ON  LY_DOCENTE
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Insert statements for trigger here



	declare @nome_atual varchar(100),
			@num_func numeric

	SELECT @nome_atual = NOME_COMPL,
	       @num_func   = NUM_FUNC
	FROM inserted
	
	BEGIN TRANSACTION
		UPDATE LY_AVALIADO
		SET
			DESCRICAO = @nome_atual
		WHERE
			DOCENTE = @num_func
	COMMIT

END
GO
