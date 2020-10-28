/*
	Atualização: Foi realizado a tentativa de gerar RPS para boletos zerados por essa ep,
				 porém as variaveis @p_boleto e @p_cobranca, são nulas e impossibilita geração de RPs em lote. 
				 Essa configuração foi comentada.
*/


ALTER PROCEDURE S_PROC_GERA_RPS (@p_Tipo T_CODIGO,
@p_Unidade T_CODIGO,
@p_dtvenc_ini T_DATA,
@p_dtvenc_fim T_DATA,
@p_Tipo_Data varchar(20),
@p_sit_boletos T_NUMERO_PEQUENO,
@p_op_emissao T_NUMERO_PEQUENO,
@p_dtemissao T_DATA,
@p_boleto T_NUMERO = NULL,
@p_Serie varchar(5),
@p_TipoValor varchar(50),
@p_cobranca T_NUMERO = NULL,
@p_conjrespfinan T_CODIGO,
@p_substitui varchar(1) OUTPUT)
AS
-- [INÍCIO] Customização - Não escreva código antes desta linha      
BEGIN

   --DECLARE @data_emissao datetime
   --SET @data_emissao = CONVERT(date, GETDATE(), 102)

   --IF (SELECT
   --      ISNULL(SUM(VALOR), 0)
   --   FROM LY_ITEM_LANC
   --   WHERE BOLETO @p_boleto
	  --group by BOLETO)
   --   = 0
   --BEGIN

   --   EXEC GERA_RPS @p_boleto,
   --                 @data_emissao,
   --                 'FCAV',
   --                 'E',
   --                 'C',
   --                 'Tipo Valor',
   --                 'N',
   --                 0.00,
   --                 5762

   --   SET @p_substitui = 'S'
   --END
   --ELSE
   --BEGIN
      SET @p_substitui = 'N'
   --END
   RETURN
END
-- [FIM] Customização - Não escreva código após esta linha