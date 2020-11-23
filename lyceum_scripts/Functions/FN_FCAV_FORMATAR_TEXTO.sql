CREATE FUNCTION [dbo].[FN_FCAV_FORMATAR_TEXTO]
(
	@TEXTO VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @TEXTO_FORMATADO VARCHAR(MAX)

	-- O trecho abaixo possibilita que caracteres como "º" ou "ª"
	-- sejam convertidos para "o" ou "a", respectivamente
	SET @TEXTO_FORMATADO = @TEXTO
	    COLLATE sql_latin1_general_cp1250_ci_as

	-- O trecho abaixo remove acentos e outros caracteres especiais,
	-- substituindo os mesmos por letras normais
	SET @TEXTO_FORMATADO = @TEXTO_FORMATADO
	    COLLATE sql_latin1_general_cp1251_ci_as

	RETURN @TEXTO_FORMATADO

END
GO