
USE LYCEUM
GO



ALTER PROCEDURE s_GERA_COBRANCA_ALUNO_DEBITO 
@p_aluno T_CODIGO,
@p_resp T_CODIGO,
@p_num_cobranca T_NUMERO_PEQUENO,
@p_ano T_ANO,
@p_mes T_MES,
@p_curso T_CODIGO,
@p_turno T_CODIGO,
@p_curriculo T_CODIGO,
@p_unidfisica T_CODIGO,
@p_retorno T_SIMNAO OUTPUT,
@p_msg varchar(100) OUTPUT
AS
BEGIN

	DECLARE @prox_parcela numeric
    
    SET @prox_parcela = isnull((SELECT TOP 1 PARCELA
								FROM LY_ITEM_LANC
								WHERE ALUNO = @p_aluno
								and ACORDO is null
								ORDER BY COBRANCA DESC),0) + 1


    -- Não vai gerar cobrança para aluno Cancelado, Trancado e Evadido

    IF (SELECT
            CASE
                WHEN (SELECT
                        1
                    FROM LY_TRANC_INTERV_DATA TRANC
                    WHERE TRANC.ALUNO = @p_aluno
                    AND DT_INI < GETDATE()
                    AND DT_REABERTURA IS NULL)
                    = 1 THEN 'Trancado'
                ELSE (SELECT DISTINCT
                        SIT_ALUNO
                    FROM LY_ALUNO
                    WHERE ALUNO = @p_aluno)
            END)
        IN ('Trancado', 'Cancelado', 'Evadido', 'Jubilado')
    BEGIN
        SELECT
            @p_retorno = 'N'
        SELECT
            @p_msg = 'Aluno Cancelado, ou Trancado, ou Evadido, ou Jubilado'
    END
    ELSE
    BEGIN
  
		SELECT
			@p_retorno = 'S'
		SELECT
			@p_msg = ''
	
	END
  
  RETURN
END