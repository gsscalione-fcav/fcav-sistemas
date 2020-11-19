/*  
    SP utilizada na JOB que alimenta a tabela FCAV_EXTRATO_FINANCEIRO2  
   
 SELECT ALUNO, VALOR_PAGAR, VALOR_PAGO FROM VW_fcav_EXTFIN_LY  
  
  SELECT * FROM #ic_data WHERE cobranca = '49997'  
  SELECT * FROM #tp_ingresso WHERE ALUNO = 'A201900807'  
  SELECT * FROM #il_ic WHERE cobranca = '49997'  
  SELECT * FROM #il  WHERE cobranca = '198422'  
  SELECT * FROM #turma WHERE ALUNO = 'A201900807'  
  SELECT * FROM #hist_mat where ALUNO = 'A201900807'  
  
  
 EXEC SP_FCAV_EXTRATO_FINANCEIRO2  
   
Criação: 18/01/2017  
  
*/

ALTER PROCEDURE SP_FCAV_EXTRATO_FINANCEIRO2
AS
    SET NOCOUNT ON
    BEGIN
        ----------------------------------------------------------------------------    
        -- Determina a massa de dados    
        ----------------------------------------------------------------------------    

        BEGIN
            ----------------------------------------------------    
            -- Histórico de matrícula, para determinação da turma    
            ----------------------------------------------------    

            SELECT 
                al.ALUNO,
                trm.TURMA,
                al.CURRICULO,
                trm.CENTRO_DE_CUSTO,
                ISNULL(PM.DT_MATRICULA, AL.DT_INGRESSO) AS DT_ULTALT
				INTO #hist_mat
            FROM LY_ALUNO AL
            LEFT JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA PM
                ON PM.ALUNO = AL.ALUNO
                AND PM.CURSO = AL.CURSO
                AND PM.TURNO = AL.TURNO
                AND PM.CURRICULO = AL.CURRICULO
            INNER JOIN LY_TURMA trm
                ON trm.TURMA = ISNULL(PM.TURMA, AL.TURMA_PREF)
			group by al.ALUNO,
                trm.TURMA,
                al.CURRICULO,
                trm.CENTRO_DE_CUSTO,
                PM.DT_MATRICULA, 
				AL.DT_INGRESSO


				
            ----------------------------------------------------    
            -- Turma    
            ----------------------------------------------------    

            SELECT
                hist.ALUNO,
                hist.CURRICULO,
                --    
                MAX(hist.TURMA) AS TURMA,          -- Paranóia - pode ter mudado de turma duas vezes no mesmo dia - chuta uma    
                MAX(hist.CENTRO_DE_CUSTO) AS CENTRO_DE_CUSTO -- Paranóia - ler acima    
            INTO #turma
            FROM #hist_mat hist
            WHERE hist.DT_ULTALT = (SELECT
                MAX(hist_max.DT_ULTALT)
            FROM #hist_mat hist_max
            WHERE hist_max.ALUNO = hist.ALUNO
            AND hist_max.CURRICULO = hist.CURRICULO)
			AND hist.CENTRO_DE_CUSTO IS NOT NULL
            GROUP BY hist.ALUNO,
                     hist.CURRICULO

			
            ----------------------------------------------------    
            -- Itens de lançamento    
            ----------------------------------------------------    

            SELECT
                ld.ALUNO,
                il.COBRANCA,
                il.BOLETO,
                il.LANC_DEB_MAX AS LANC_DEB,
                ld.ANO_REF,
                ld.PERIODO_REF,
                CASE
                    WHEN ld_cnt.CODIGO_LANC_COUNT > 1 THEN '--'
                    ELSE ld.CODIGO_LANC
                END AS CODIGO_LANC,
                CASE
                    WHEN ld_cnt.CODIGO_LANC_COUNT > 1 THEN 'COBRANÇA AGRUPADA'
                    ELSE ld.DESCRICAO
                END AS DESCRICAO,
                il.CURRICULO_MAX AS CURRICULO,
                il.DT_ENVIO_CONTAB_MAX AS DT_ENVIO_CONTAB 
				--
				INTO #il
				--
            FROM (SELECT -- Há mais de um item para a mesma COBRANCA    
						-- 0:1 para BOLETO    
						COBRANCA,
						BOLETO,
						--    
						MAX(CURRICULO) AS CURRICULO_MAX,
						MAX(LANC_DEB) AS LANC_DEB_MAX,
						MAX(DT_ENVIO_CONTAB) AS DT_ENVIO_CONTAB_MAX
					FROM VW_FCAV_IL_NAO_ESTORNO il
					WHERE LANC_DEB IS NOT NULL
					GROUP BY COBRANCA,
							 BOLETO) il
            INNER JOIN (SELECT il.COBRANCA,
							MAX(ld.LANC_DEB) AS LANC_DEB,
							COUNT(DISTINCT il.CODIGO_LANC) AS CODIGO_LANC_COUNT
						FROM dbo.LY_LANC_DEBITO ld
						INNER JOIN dbo.LY_ITEM_LANC il
							ON il.LANC_DEB = ld.LANC_DEB
								GROUP BY il.COBRANCA) ld_cnt
                ON ld_cnt.COBRANCA = il.COBRANCA
            --    
            INNER JOIN dbo.LY_LANC_DEBITO ld
                ON ld.LANC_DEB = il.LANC_DEB_MAX
			
			group by ld.ALUNO,
                il.COBRANCA,
                il.BOLETO,
                il.LANC_DEB_MAX,
                ld.ANO_REF,
                ld.PERIODO_REF,
				ld_cnt.CODIGO_LANC_COUNT,
				ld.CODIGO_LANC,
				ld.DESCRICAO,
				il.CURRICULO_MAX,
				il.DT_ENVIO_CONTAB_MAX



				
            ----------------------------------------------------    
            -- Itens de lançamento/crédito agrupados    
            ----------------------------------------------------    

            BEGIN
                SELECT
                    'IL_VALOR_LANC_NAO_ACORDADO' AS TIPO,
                    COBRANCA,
                    SUM(VALOR) AS VALOR 
				INTO #IL_IC
                FROM VW_FCAV_IL_NAO_ESTORNO il
                WHERE ACORDO IS NULL
			    --AND VALOR > 0
				AND NUM_BOLSA IS NULL
                AND MOTIVO_DESCONTO IS NULL
                AND DESCRICAO <> 'Acrescimo de IGPM'
                AND VALOR IS NOT NULL
                GROUP BY COBRANCA

                INSERT INTO #IL_IC
                    SELECT
                        'IL_VALOR_LANC_ACORDADO',
                        COBRANCA,
                        SUM(VALOR)
                    FROM VW_FCAV_IL_NAO_ESTORNO il
                    WHERE ACORDO IS NOT NULL
                    AND VALOR IS NOT NULL
                    GROUP BY COBRANCA

                INSERT INTO #IL_IC
                    SELECT
                        'IL_BOLSA',
                        COBRANCA,
						SUM(CASE WHEN VALOR > 0 THEN VALOR * -1
						ELSE VALOR END)
                    FROM VW_FCAV_IL_NAO_ESTORNO il
                    WHERE NUM_BOLSA IS NOT NULL
                    AND DESCRICAO LIKE '%Bolsa%'
                    AND VALOR IS NOT NULL
                    GROUP BY COBRANCA


                INSERT INTO #IL_IC
                    SELECT
                        'IL_DESCONTO',
                        COBRANCA,
                        SUM(VALOR)
                    FROM VW_FCAV_IL_NAO_ESTORNO il
                    WHERE MOTIVO_DESCONTO IN (
                    'PlanoPagamento', 'Estorno',
                    'Cancelamento', 'Ajuste',
                    'Voucher'     -- Inclusão do motivo "Voucher" em 11/01/18 - João Paulo  
                    )
                    AND VALOR IS NOT NULL
                    GROUP BY COBRANCA

                INSERT INTO #IL_IC
                    SELECT
                        'IL_IGPM',
                        COBRANCA,
                        SUM(VALOR)
                    FROM VW_FCAV_IL_NAO_ESTORNO il
                    WHERE DESCRICAO = 'Acrescimo de IGPM'
                    AND VALOR IS NOT NULL
                    GROUP BY COBRANCA

                INSERT INTO #IL_IC
                    SELECT
                        'IC_VALOR_PAGO',
                        IC.COBRANCA,
                        SUM(IC.VALOR)
                    FROM LY_LANC_CREDITO LC
                    INNER JOIN VW_FCAV_IC_NAO_ESTORNO IC
                        ON IC.LANC_CRED = LC.LANC_CRED
                    WHERE LC.TIPO_PAGAMENTO IN ('Banco', 'Dinheiro', 'Especial', 'Cartao') /* Há dois registros com outros tipos - Foi necessário adicionar tipo Especial */
                    --    
                    AND IC.TIPO_ENCARGO IS NULL
                    AND IC.TIPODESCONTO IS NULL
                    AND VALOR IS NOT NULL
                    GROUP BY IC.COBRANCA

                INSERT INTO #IL_IC
                    SELECT
                        'IC_DESCONTO',
                        COBRANCA,
                        SUM(VALOR)
                    FROM VW_FCAV_IC_NAO_ESTORNO
                    WHERE TIPODESCONTO IN (
                    'DescBanco', 'DispEncargo', 'Concedido',
                    'Acréscimo', 'PagtoAntecipado'
                    )
                    AND VALOR IS NOT NULL
                    GROUP BY COBRANCA

                INSERT INTO #IL_IC
                    SELECT
                        'IC_JUROS_MULTA',
                        COBRANCA,
                        SUM(VALOR)
                    FROM VW_FCAV_IC_NAO_ESTORNO
                    WHERE TIPO_ENCARGO IN ('JUROS', 'MULTA')
                    AND VALOR IS NOT NULL
                    GROUP BY COBRANCA

                INSERT INTO #IL_IC
                    SELECT
                        'IC_AJUSTE',
                        COBRANCA,
                        SUM(VALOR)
                    FROM VW_FCAV_IC_NAO_ESTORNO
                    WHERE TIPO_ENCARGO = 'AJUSTE'
                    AND VALOR IS NOT NULL
                    GROUP BY COBRANCA

                INSERT INTO #IL_IC
                    SELECT
                        'IC_OUTROS_ENCARGOS',
                        COBRANCA,
                        SUM(VALOR)
                    FROM VW_FCAV_IC_NAO_ESTORNO
                    WHERE TIPO_ENCARGO NOT IN ('JUROS', 'MULTA', 'AJUSTE')
                    AND VALOR IS NOT NULL
                    GROUP BY COBRANCA
            END -- Itens de lançamento/crédito agrupados    

            ----------------------------------------------------    
            -- Estorno    
            ----------------------------------------------------    

            SELECT
                COBRANCA,
                SUM(VALOR) AS VALOR 
			--
			INTO #il_estorno
			--
            FROM dbo.LY_ITEM_LANC
            WHERE ITEMCOBRANCA <> ITEM_ESTORNADO
				AND VALOR IS NOT NULL
            GROUP BY COBRANCA

            ----------------------------------------------------    
            -- Data de pagamento    
            ----------------------------------------------------    

            SELECT
                IC.COBRANCA,
                MAX(IC.DATA) AS DATA 
			--	
			INTO #ic_data
			--
            FROM VW_FCAV_IC_NAO_ESTORNO IC
            INNER JOIN LY_LANC_CREDITO LC
                ON LC.LANC_CRED = IC.LANC_CRED
            WHERE LC.TIPO_PAGAMENTO IN ('Banco', 'Dinheiro', 'Cartao')
            --    
            AND IC.TIPO_ENCARGO IS NULL
            AND IC.TIPODESCONTO IS NULL
            GROUP BY IC.COBRANCA

            ----------------------------------------------------    
            -- Tipo de ingresso    
            ----------------------------------------------------    

            SELECT
                ALUNO,
                CURRICULO,
                --    
                CASE
                    WHEN CONCURSO IS NOT NULL THEN 'PS'
                    ELSE 'VD'
                END AS TP_INGRESSO INTO #tp_ingresso
            FROM LY_ALUNO

            GROUP BY ALUNO,
                     CURRICULO,
                     CONCURSO

        END -- Determina a massa de dados    

        ----------------------------------------------------------------------------    
        -- O resultado    
        ----------------------------------------------------------------------------    

        BEGIN
            TRUNCATE TABLE FCAV_EXTRATO_FINANCEIRO2_ESTAGE

            INSERT INTO FCAV_EXTRATO_FINANCEIRO2_ESTAGE
                SELECT DISTINCT
                    A.CURRICULO,
                    A.PESSOA,
                    A.ALUNO,
                    A.NOME_COMPL,
                    A.SIT_ALUNO,
                    A.CURSO,
                    A.TURNO,
                    --    
                    turma.TURMA,
                    turma.CENTRO_DE_CUSTO,
                    --    
                    -- ATENÇÂO: Verificar se há alguém usando    
                    -- Ao certificar-se que não há uso, excluir essa coluna    
                    -- Origem: VW_FCAV_INI_FIM_CURSO_TURMA.TP_INGRESSO    
                    tp_ingresso.TP_INGRESSO AS TP_INGRESSO,
                    --    
                    il.LANC_DEB,
                    il.CODIGO_LANC,
                    il.ANO_REF,
                    il.PERIODO_REF,
                    il.DESCRICAO,
                    --    
                    C.RESP,
                    --    
                    RF.TITULAR,
                    RF.CPF_TITULAR,
                    RF.CGC_TITULAR,
                    --    
                    C.COBRANCA,
                    C.ANO,
                    C.MES,
                    C.DATA_DE_FATURAMENTO AS DATA_DE_EMISSAO,
                    C.DATA_DE_VENCIMENTO,
                    --    
                    IC_DATA.DATA AS DATA_DE_PAGAMENTO,
                    --  
                    ISNULL(IL_VALOR_LANC_NAO_ACORDADO.VALOR, 0.00) +
                    ISNULL(IL_BOLSA.VALOR, 0.00) +
                    ISNULL(IL_DESCONTO.VALOR, 0.00) +      -- Feito inclusão dessa linha para considerar descontos feitos na LY_ITEM_LANC - 11/01/2018 - João Paulo  
                    ISNULL(IC_DESCONTO.VALOR, 0.00) +
                    ISNULL(IL_IGPM.VALOR, 0.00) AS VALOR_PAGAR,
                    --    
                    ISNULL(IL_VALOR_LANC_ACORDADO.VALOR, 0.00) AS VALOR_ACORDADO,
                    --    
                    -- ATENÇÂO: Verificar se há alguém usando    
                    -- Ao certificar-se que não há uso, excluir essa coluna    
                    -- Origens: LY_PLANO_PGTO_ESPECIAL e LY_PLANO_PGTO_PERIODO    
                    CONVERT(numeric(5, 4) /* T_ANO */, NULL) AS ANO_INICIAL,
                    CONVERT(numeric(5, 3) /* T_NUMERO_PEQUENO */, NULL) AS MES_INICIAL,
                    CONVERT(numeric(5, 3) /* T_NUMERO_PEQUENO */, NULL) AS NUM_PARCELAS,
                    --    
                    B.BOLETO,
                    B.CONTA_BANCO,
                    B.NUMERO_RPS,
                    B.DATA_EMISSAO_RPS,
                    B.NUMERO_NFE,
                    B.DATA_EMISSAO_NFE,
                    --    
                    CASE
                        WHEN IL_VALOR_LANC_ACORDADO.VALOR IS NOT NULL THEN 'Baixa por Acordo'
                        WHEN IC_VALOR_PAGO.VALOR IS NOT NULL THEN CASE
                                WHEN
                                    ABS(IC_VALOR_PAGO.VALOR) =
                                    ISNULL(IL_VALOR_LANC_NAO_ACORDADO.VALOR, 0.00) +
                                    ISNULL(IL_BOLSA.VALOR, 0.00) +
                                    ISNULL(IL_DESCONTO.VALOR, 0.00) +
                                    ISNULL(IL_IGPM.VALOR, 0.00) +
                                    --    
                                    ISNULL(IC_DESCONTO.VALOR, 0.00) +
                                    ISNULL(IC_JUROS_MULTA.VALOR, 0.00) +
                                    ISNULL(IC_AJUSTE.VALOR, 0.00) +
                                    ISNULL(IC_OUTROS_ENCARGOS.VALOR, 0.00) THEN 'Boleto pago'
                                ELSE 'Boleto parcialmente pago'
                            END
                        WHEN C.DATA_DE_VENCIMENTO >= GETDATE() THEN 'A Vencer'
                        WHEN ISNULL(IL_BOLSA.VALOR, 0.00) < 0.00 AND
                            (ISNULL(IL_VALOR_LANC_NAO_ACORDADO.VALOR, 0.00) +
                            ISNULL(IL_BOLSA.VALOR, 0.00) +
                            ISNULL(IL_DESCONTO.VALOR, 0.00) +
                            ISNULL(IC_DESCONTO.VALOR, 0.00) +
                            ISNULL(IL_IGPM.VALOR, 0.00)) = 0.00 THEN 'Boleto pago'
                        WHEN C.DATA_DE_VENCIMENTO < GETDATE() AND
                            (ISNULL(IL_VALOR_LANC_NAO_ACORDADO.VALOR, 0.00) +
                            ISNULL(IL_BOLSA.VALOR, 0.00) +
                            ISNULL(IL_DESCONTO.VALOR, 0.00) + ISNULL(IC_DESCONTO.VALOR, 0.00) +
                            ISNULL(IL_IGPM.VALOR, 0.00)) > 0.00 THEN 'Vencido'
                        ELSE 'Boleto pago'
                    END AS SITUACAO_BOLETO,
                    --    
                    ISNULL(ABS(IC_VALOR_PAGO.VALOR), 0.00) AS VALOR_PAGO,
                    ISNULL(IL_DESCONTO.VALOR, 0.00) +      -- Feito inclusão dessa linha para considerar descontos feitos na LY_ITEM_LANC - 11/01/2018 - João Paulo  
                    ISNULL(IC_DESCONTO.VALOR, 0.00) AS DESCONT,
                    ISNULL(IC_JUROS_MULTA.VALOR, 0.00) AS JUROS_MULTA,
                    ISNULL(IC_AJUSTE.VALOR, 0.00) AS AJUSTE,
                    ISNULL(IC_OUTROS_ENCARGOS.VALOR, 0.00) AS OUTROS_ENC,
                    --    
                    --ISNULL(IC_DESCONTO.VALOR, 0.00) +    --    Comentada a adição com o Desconto e alterado o nome de DESCONT_COM_BOLSA para apenas BOLSA  
                    ISNULL(IL_BOLSA.VALOR, 0.00) AS BOLSA,
                    --    
                    -- ATENÇÂO: Verificar se há alguém usando    
                    -- Ao certificar-se que não há uso, excluir essa coluna    
                    CONVERT(decimal(17, 2), NULL) AS ESTORNO,
                    --    
                    il.DT_ENVIO_CONTAB,
                    B.VALOR_SERVICO_RPS AS VALOR_FATURADO,


                    --Calcula a diferença entre valor pago e valor a pagar  
                    ISNULL(IL_VALOR_LANC_NAO_ACORDADO.VALOR, 0.00) +
                    ISNULL(IL_BOLSA.VALOR, 0.00) +
                    ISNULL(IL_DESCONTO.VALOR, 0.00) +
                    ISNULL(IC_DESCONTO.VALOR, 0.00) +
                    ISNULL(IL_IGPM.VALOR, 0.00) - ISNULL(ABS(IC_VALOR_PAGO.VALOR), 0.00) AS DIFERENCA



                FROM #il il
                INNER JOIN (
                LY_COBRANCA C
                INNER JOIN LY_RESP_FINAN RF
                    ON RF.RESP = C.RESP
                )
                    ON C.COBRANCA = il.COBRANCA
                --    
                LEFT OUTER JOIN #il_ic AS IL_VALOR_LANC_NAO_ACORDADO
                    ON IL_VALOR_LANC_NAO_ACORDADO.COBRANCA = il.COBRANCA
                    AND IL_VALOR_LANC_NAO_ACORDADO.TIPO = 'IL_VALOR_LANC_NAO_ACORDADO'
				--
                LEFT OUTER JOIN #il_ic AS IL_VALOR_LANC_ACORDADO
                    ON IL_VALOR_LANC_ACORDADO.COBRANCA = il.COBRANCA
                    AND IL_VALOR_LANC_ACORDADO.TIPO = 'IL_VALOR_LANC_ACORDADO'
				--
                LEFT OUTER JOIN #il_ic AS IL_BOLSA
                    ON IL_BOLSA.COBRANCA = il.COBRANCA
                    AND IL_BOLSA.TIPO = 'IL_BOLSA'
				--
                LEFT OUTER JOIN #il_ic AS IL_DESCONTO
                    ON IL_DESCONTO.COBRANCA = il.COBRANCA
                    AND IL_DESCONTO.TIPO = 'IL_DESCONTO'
				--
                LEFT OUTER JOIN #il_ic AS IL_IGPM
                    ON IL_IGPM.COBRANCA = il.COBRANCA
                    AND IL_IGPM.TIPO = 'IL_IGPM'
                --    
                LEFT OUTER JOIN #il_ic AS IC_VALOR_PAGO
                    ON IC_VALOR_PAGO.COBRANCA = il.COBRANCA
                    AND IC_VALOR_PAGO.TIPO = 'IC_VALOR_PAGO'
				--
                LEFT OUTER JOIN #il_ic AS IC_DESCONTO
                    ON IC_DESCONTO.COBRANCA = il.COBRANCA
                    AND IC_DESCONTO.TIPO = 'IC_DESCONTO'
				--
                LEFT OUTER JOIN #il_ic AS IC_JUROS_MULTA
                    ON IC_JUROS_MULTA.COBRANCA = il.COBRANCA
                    AND IC_JUROS_MULTA.TIPO = 'IC_JUROS_MULTA'
				--
                LEFT OUTER JOIN #il_ic AS IC_AJUSTE
                    ON IC_AJUSTE.COBRANCA = il.COBRANCA
                    AND IC_AJUSTE.TIPO = 'IC_AJUSTE'
				--
                LEFT OUTER JOIN #il_ic AS IC_OUTROS_ENCARGOS
                    ON IC_OUTROS_ENCARGOS.COBRANCA = il.COBRANCA
                    AND IC_OUTROS_ENCARGOS.TIPO = 'IC_OUTROS_ENCARGOS'
                --    
                LEFT OUTER JOIN #il_estorno IL_ESTORNO
                    ON IL_ESTORNO.COBRANCA = il.COBRANCA
                --    
                LEFT OUTER JOIN #ic_data IC_DATA
                    ON IC_DATA.COBRANCA = il.COBRANCA
                --    
                LEFT OUTER JOIN LY_BOLETO B
                    ON B.BOLETO = il.BOLETO
                --  
                LEFT OUTER JOIN #turma turma
                    ON turma.ALUNO = il.ALUNO
                    --AND turma.CURRICULO = il.CURRICULO  
                --    
                LEFT OUTER JOIN #tp_ingresso tp_ingresso
                    ON tp_ingresso.ALUNO = il.ALUNO
                    --AND tp_ingresso.CURRICULO = il.CURRICULO  
                --    
                INNER JOIN LY_ALUNO A
                    ON A.ALUNO = tp_ingresso.ALUNO
				--
				INNER JOIN DADOSADVP12.dbo.CTT010 CTT 
					ON CTT.CTT_CUSTO collate Latin1_General_CI_AI = turma.CENTRO_DE_CUSTO
--					AND turma.TURMA like (CTT.CTT_DESC01+'%' collate Latin1_General_CI_AI)
                --    
             WHERE A.NOME_COMPL NOT LIKE '%TESTE%'
				and -- VALOR_PAGAR --
					(ISNULL(IL_VALOR_LANC_NAO_ACORDADO.VALOR, 0.00) +
                    ISNULL(IL_BOLSA.VALOR, 0.00) +
                    ISNULL(IL_DESCONTO.VALOR, 0.00) + 
                    ISNULL(IC_DESCONTO.VALOR, 0.00) +
                    ISNULL(IL_IGPM.VALOR, 0.00)) >= 0.00
			
			----------------------------------------------------------------------------    
			-- Limpa a tabela para alimentar os dados atualizados.
			---------------------------------------------------------------------------- 
            BEGIN
                BEGIN TRANSACTION

                    TRUNCATE TABLE FCAV_EXTRATO_FINANCEIRO2

                    INSERT INTO FCAV_EXTRATO_FINANCEIRO2
                        SELECT
                            *
                        FROM FCAV_EXTRATO_FINANCEIRO2_ESTAGE

                COMMIT
            END
        END

        ----------------------------------------------------------------------------    
        -- Clean-up    
        ----------------------------------------------------------------------------    
        BEGIN
            DROP TABLE #ic_data
            DROP TABLE #tp_ingresso
            DROP TABLE #il_ic
            DROP TABLE #il
            DROP TABLE #turma
            DROP TABLE #hist_mat
        END -- Clean-up    
    END