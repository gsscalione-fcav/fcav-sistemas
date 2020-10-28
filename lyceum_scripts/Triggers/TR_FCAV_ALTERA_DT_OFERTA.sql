-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Gabriel
-- Create date: 31/07/2018
-- Description:	Utilizada para alterar de período de inscrição na tabela LY_OFERTA_CURSO
-- =============================================
ALTER TRIGGER TR_FCAV_ALTERA_DT_OFERTA
   ON  LY_CONCURSO
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE	@concurso varchar(20)

	SELECT 
		@concurso = CONCURSO
	FROM 
		inserted

	IF(@concurso IS NOT NULL)
	BEGIN
		UPDATE LY_OFERTA_CURSO
		SET
			DTINI = CO.DT_INICIO,
			DTFIM = CONVERT(datetime, CONVERT(varchar(11), CO.DT_FIM, 111) + ' 23:59:59', 111)
		FROM 
			LY_OFERTA_CURSO OC
			INNER JOIN inserted CO
				ON CO.CONCURSO = OC.CONCURSO
		WHERE
			OC.CONCURSO = @concurso
			AND (OC.DTINI != CO.DT_INICIO OR OC.DTFIM != CO.DT_FIM)
	END

END
GO
