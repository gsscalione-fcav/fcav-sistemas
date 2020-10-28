SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Gabriel
-- Create date: 31/07/2018
-- Description:	Utilizada para inserir os mais opções de planos por cartão de crédito com parcelas decrescentes
--			SELECT * FROM LY_PLANOS_OFERTADOS WHERE FORMA_PAGAMENTO = 'CARTAO'
-- =============================================
CREATE TRIGGER TR_FCAV_INSERE_PARCELAS_CARTAO
   ON  LY_PLANOS_OFERTADOS
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here

	DECLARE @oferta_de_curso		numeric
	DECLARE @mes_inicial			numeric
	DECLARE @num_parcelas			numeric
	DECLARE @num_parcelas_inscr		numeric
	DECLARE @n_dias_venc_bol		numeric
	DECLARE @num_parcelas_cartao	numeric
	DECLARE @plano					VARCHAR(20)
	DECLARE @descricao				VARCHAR(2000)
	DECLARE @forma_pagamento		VARCHAR(100)

	--Alimenta as variáveis

	SELECT 
		@oferta_de_curso	= OFERTA_DE_CURSO,
		@mes_inicial		= MES_INICIAL,
		@num_parcelas		= NUM_PARCELAS,
		@num_parcelas_inscr	= NUM_PARCELAS_INSCR,
		@n_dias_venc_bol	= N_DIAS_VENC_BOL,
		@num_parcelas_cartao= NUM_PARCELAS_CARTAO,
		@plano				= PLANO,
		@descricao			= DESCRICAO,
		@forma_pagamento	= FORMA_PAGAMENTO
	FROM 
		inserted


	IF @forma_pagamento = 'Cartao'
	BEGIN

		WHILE @num_parcelas_cartao > 1 
		   BEGIN
			SET @plano = @plano - 1
			SET @num_parcelas_cartao = @num_parcelas_cartao - 1
			SET @descricao = RIGHT('0'+CAST(@num_parcelas_cartao AS VARCHAR),2) + SUBSTRING(@descricao,CHARINDEX(' ',@descricao,1),len(@descricao))

			INSERT LY_PLANOS_OFERTADOS (OFERTA_DE_CURSO,
										PLANO,
										PLANOPAG,
										DESCRICAO,
										MES_INICIAL,
										NUM_PARCELAS,
										TIPO_DESC,
										DESCONTO,
										DATA_DE_VENCIMENTO,
										FORMA_PAGAMENTO,
										NUM_PARCELAS_INSCR,
										N_DIAS_VENC_BOL,
										VALOR_ESTIMADO,
										DT_INI_VIGENCIA,
										DT_FIM_VIGENCIA,
										NUM_PARCELAS_CARTAO )
									VALUES(
										@oferta_de_curso,
										@plano,
										'AVISTA',
										@descricao,
										@mes_inicial,
										@num_parcelas,
										NULL,
										NULL,
										NULL,
										@forma_pagamento,
										@num_parcelas_inscr,
										@n_dias_venc_bol,
										NULL,
										NULL,
										NULL,
										@num_parcelas_cartao )		
		END


		UPDATE LY_PLANOS_OFERTADOS
		SET
			DESCRICAO = REPLACE (DESCRICAO, 'PARCELAS','PARCELA')
		WHERE
			FORMA_PAGAMENTO = 'Cartao'
			AND NUM_PARCELAS_CARTAO = 1

	END




END
GO
