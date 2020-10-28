

ALTER PROCEDURE a_ALTERA_BOLETO_PRE_MATR @p_sessao_id varchar(40),
@p_aluno T_CODIGO,
@p_resp T_CODIGO,
@p_ano_letivo T_ANO,
@p_periodo_letivo T_SEMESTRE2,
@p_regerar_ano T_ANO,
@p_regerar_mes T_MES,
@p_data_venc T_DATA = NULL OUTPUT
AS
BEGIN
    -- [INÍCIO] Customização - Não escreva código antes desta linha  

    DECLARE @diasvenc_pj int

    SELECT
        @diasvenc_pj = ISNULL(CAST(DESCR AS int), 0)
    FROM HD_TABELAITEM
    WHERE TABELA = 'DiasVencPessJuridica'
    AND ITEM = 'DIAS'

    IF EXISTS (SELECT
            1
        FROM LY_RESP_FINAN
        WHERE CGC_TITULAR IS NOT NULL
        AND RESP = @p_resp)
    BEGIN
        SELECT
            @p_data_venc = CONVERT(datetime, CONVERT(varchar(11), dbo.FN_FCAV_GetDiaUtil(GETDATE(), @diasvenc_pj), 111) + ' 23:59:59', 121)
    END

    -- [FIM] Customização - Não escreva código após esta linha  
    RETURN
END