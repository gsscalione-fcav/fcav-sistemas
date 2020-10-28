-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Gabriel S. Scalione
-- Create date: 29/01/2019
-- Description:	Trigger para ajustar o horário final da oferta
-- =============================================
ALTER TRIGGER TR_FCAV_AJUSTA_DTFIM_OFERTA 
   ON  LY_OFERTA_CURSO
   FOR INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 -- Insert statements for trigger here


	 declare @new_dt_fim	T_DATA,
			 @oferta		T_CODIGO,
			 @concuso		T_CODIGO

	 SELECT 
		@oferta = OFERTA_DE_CURSO,
		@concuso = CONCURSO,
		@new_dt_fim = CONVERT(datetime, CONVERT(varchar(11), DTFIM, 111) + ' 23:59:59', 111)
	 FROM 
		inserted

	 update LY_OFERTA_CURSO
	 set
		DTFIM = @new_dt_fim
	 where 
		OFERTA_DE_CURSO = @oferta
	
	--- atualiza a data também para o concurso
	 UPDATE LY_CONCURSO
	 SET	
		DT_FIM = @new_dt_fim
	 WHERE
		CONCURSO = @concuso


END
GO




