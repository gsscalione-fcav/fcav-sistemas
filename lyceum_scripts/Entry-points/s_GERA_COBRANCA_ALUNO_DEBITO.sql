
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
    
		----------------------------------------------------------------------------------
		/* Não gerar novas cobranças para aluno de rematricula que está inadimplente.	*/
		/* Identifica a última parcela gerada e soma + 1 para saber qual será a próxima */
		/* parcela a ser gerada. Caso seja uma das parcelas abaixo, que representa o	*/ 
		/* inicio de cada quadrimestre, irá verificar se existe cobranças anteriores	*/	
		/* vencidas e não será gerado novas cobranças até a quitação das mesmas.		*/	
		----------------------------------------------------------------------------------
		IF(@prox_parcela = 5 or @prox_parcela = 9 or @prox_parcela = 13 
		   or @prox_parcela = 17 or @prox_parcela = 21)
		BEGIN
			IF EXISTS (SELECT DISTINCT
					1
				FROM VW_FCAV_EXTFIN_LY EX
					INNER JOIN LY_CURSO CS
						ON CS.CURSO = EX.CURSO
					INNER JOIN LY_BOLSA BO
						ON BO.ALUNO = EX.ALUNO
				WHERE CS.FACULDADE = 'ESPEC'
				AND CONVERT(VARCHAR, DATA_DE_VENCIMENTO,112) < CONVERT(VARCHAR, GETDATE(),112)
				AND DATA_DE_PAGAMENTO IS NULL
				AND SITUACAO_BOLETO != 'Baixa por Acordo'
				AND EX.ALUNO = @p_aluno
				AND SIT_ALUNO !='Cancelado'
				AND BO.PERC_VALOR != 'Percentual'
				AND BO.VALOR != 1.000000
				AND EX.VALOR_PAGAR > 0.00
				)
			BEGIN
				SELECT
					@p_retorno = 'N'
				SELECT
					@p_msg = 'Aluno inadimplente, há cobrança(s) e/ou acordo(s) vencido(os)!'

			END
			ELSE
			BEGIN
				SELECT
					@p_retorno = 'S'
				SELECT
					@p_msg = ''
			END
		END
	    ELSE
		BEGIN
    
			SELECT
				@p_retorno = 'S'
			SELECT
				@p_msg = ''
		END
  END
  
  RETURN
END