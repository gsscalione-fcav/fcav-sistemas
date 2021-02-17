/*

    Store Procedure SP_FCAV_APOIOWEB_INGRESSANTES

	Finalidade: Utilizada para realizar a consulta dos isncritos que é utilizada para alimentar
	ApoioWeb.

Autor: Gabriel S. Scalione
Data: 13/09/2019

EXEC SP_FCAV_APOIOWEB_INGRESSANTES


select * from #dim_inscritos where concurso = 'a-aspon t 01'

*/


ALTER PROCEDURE SP_FCAV_APOIOWEB_INGRESSANTES
AS
	SET NOCOUNT ON
	BEGIN
		----------------------------------------------------------------------------  
		-- Determina a massa de dados
		----------------------------------------------------------------------------  
		BEGIN
			SELECT
				CA.PESSOA,
				CA.CANDIDATO AS COD_INSCR,
				CA.SIT_CANDIDATO_VEST AS SITUACAO,
				ISNULL(CA.DT_INSCRICAO, FC.DATA_INSC) AS DT_INSCRICAO,
				CASE
					WHEN CONVOCADO='1' THEN 'Selecionado'
					WHEN CONVOCADO='2' THEN 'Recusado'
					ELSE 'Nao_Avaliado'
				END SELEC_COORD,
				MAX(OC.CONCURSO) AS CONCURSO,
				OC.OFERTA_DE_CURSO,
				OC.CURSO,
				OC.CURRICULO,
				OC.ANO_INGRESSO,
				OC.PER_INGRESSO 
				
			INTO #dim_inscritos 

			FROM LY_CANDIDATO CA
			INNER JOIN LY_OFERTA_CURSO OC
				ON OC.CONCURSO=CA.CONCURSO
				AND OC.ANO_INGRESSO >= 2018
			INNER JOIN FCAV_CANDIDATOS FC
				ON FC.CANDIDATO=CA.CANDIDATO
				AND FC.CONCURSO=CA.CONCURSO
			
			GROUP BY	CA.PESSOA,
						CA.CANDIDATO,
						CA.SIT_CANDIDATO_VEST,
						CA.DT_INSCRICAO,
						FC.DATA_INSC,
						FC.CONVOCADO,
						OC.CONCURSO,
						OC.OFERTA_DE_CURSO,
						OC.CURSO,
						OC.TURNO,
						OC.CURRICULO,
						OC.ANO_INGRESSO,
						OC.PER_INGRESSO

			UNION ALL

			SELECT
				al.PESSOA,
				AL.ALUNO AS COD_INSCR,
				vd.SIT_MATRICULA AS SITUACAO,
				vd.DT_INGRESSO AS DT_INSCRICAO,
				'Compra_Direta' AS SELEC_COORD,
				T.TURMA AS CONCURSO,
				t.OFERTA_DE_CURSO,
				t.CURSO,
				t.CURRICULO,
				al.ANO_INGRESSO,
				al.SEM_INGRESSO AS PER_INGRESSO
			FROM VW_FCAV_ALUNOS_VENDA_DIRETA Vd
			INNER JOIN LY_ALUNO al
				ON al.ALUNO=vd.ALUNO
				and al.CONCURSO IS NULL
				and al.ANO_INGRESSO >= 2018
				
			LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA T
				ON T.TURMA=vd.TURMA
				AND t.UNIDADE_RESPONSAVEL!='PALES'
				and t.CURSO = al.CURSO
			--		WHERE T.TURMA = 'A-gpmp T 116'

			GROUP BY	al.PESSOA,
						AL.ALUNO,
						vd.SIT_MATRICULA,
						vd.DT_INGRESSO,
						T.TURMA,
						t.OFERTA_DE_CURSO,
						t.CURSO,
						t.CURRICULO,
						al.ANO_INGRESSO,
						al.SEM_INGRESSO
		END

		--------------------------------------------
		--Extrato financeiro
		--------------------------------------------
		BEGIN
			SELECT
				EX.ALUNO,
				EX.TURMA,
				cast(ISNULL(SUM(EX.VALOR_PAGAR), 0) as decimal(10,2)) - ISNULL(DE.DEVOLUCAO,0) AS VALOR_PAGAR,
				cast(ISNULL(SUM(EX.VALOR_PAGO), 0) as decimal(10,2))  - ISNULL(DE.DEVOLUCAO,0) AS VALOR_PAGO 
			--
			INTO #dim_extrato_financeiro 
			--
			FROM VW_FCAV_EXTFIN_LY EX 
				left join VW_FCAV_DEVOLUCAO_ALUNO DE
					ON DE.ALUNO = EX.ALUNO
					and de.TURMA_PREF = ex.TURMA
					and de.CURSO = ex.CURSO
			WHERE EX.COBRANCA=( SELECT
									MIN(COBRANCA)
								FROM LY_ITEM_LANC IL
								WHERE EX.ALUNO=IL.ALUNO
								AND EX.COBRANCA=IL.COBRANCA
								AND IL.PARCELA=1
								AND il.NUM_BOLSA IS NULL)
					and ex.SIT_ALUNO != 'Cancelado'
			group by ex.aluno, ex.turma,DE.DEVOLUCAO
		END

		--------------------------------------------
		--Descontos do Aluno
		--------------------------------------------
		BEGIN
			SELECT 
				LD.ALUNO,
				LD.LANC_DEB,
				LD.DESCRICAO,
				LD.MATRICULA,
				LD.ANO_REF,
				LD.PERIODO_REF,
				SUM(ISNULL(DD.VALOR,0)) DESCONTO,
				CAST(SUM((ISNULL(LD.VALOR,0) * ISNULL(BO.VALOR,0))) AS decimal(10,2)) AS BOLSA,
				(SUM(ISNULL(DD.VALOR,0)) + SUM((ISNULL(LD.VALOR,0) * ISNULL(BO.VALOR,0)))) AS TOTAL_DESCONTOS
						
				INTO #dim_descontos_do_aluno 

			FROM LY_LANC_DEBITO LD
				
			--AND MP.SIT_DETALHE = 'Curricular'

			LEFT JOIN LY_DESCONTO_DEBITO DD
				ON DD.LANC_DEB = LD.LANC_DEB
				AND DD.MOTIVO_DESCONTO != 'Estorno'
		
			left join LY_BOLSA BO
				ON BO.ALUNO = LD.ALUNO
				AND BO.ANOFIM >= YEAR(GETDATE())
				and bo.perc_valor = 'Percentual'
			

			WHERE LD.DESCRICAO != 'Acordo'
			  AND DD.MOTIVO_DESCONTO != 'Estorno'
			GROUP BY LD.ALUNO,
				
				LD.LANC_DEB,
				LD.DESCRICAO,
				LD.MATRICULA,
				LD.ANO_REF,
				LD.PERIODO_REF
		END

		--------------------------------------------
		--Divida do Aluno
		--------------------------------------------
		BEGIN
			SELECT 
				MP.ALUNO,
				MP.TURMA,
				LD.LANC_DEB,
				LD.DESCRICAO,
				LD.MATRICULA,
				LD.ANO_REF,
				LD.PERIODO_REF,
				SUM(ISNULL(LD.VALOR,0)) VALOR,
				SUM(ISNULL(DA.TOTAL_DESCONTOS,0)) DESCONTO,
				SUM(ISNULL(DE.DEVOLUCAO,0)) as DEVOLUCAO,
				CAST(SUM(ISNULL(LD.VALOR,0)) - SUM(ISNULL(DA.TOTAL_DESCONTOS,0)) - SUM(ISNULL(DE.DEVOLUCAO,0)) AS DECIMAL(10,2)) AS VALOR_CONTRATADO
						
			INTO #dim_divida_do_aluno

			FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP
		
			left join ly_item_lanc  IL
				ON IL.ALUNO = MP.ALUNO
				AND IL.CURSO   = MP.CURSO
				AND IL.TURNO   = MP.TURNO
				AND IL.CURRICULO = MP.CURRICULO
			
			LEFT JOIN LY_LANC_DEBITO LD 
				ON LD.ALUNO = IL.ALUNO
				AND LD.LANC_DEB = IL.LANC_DEB
				AND LD.DESCRICAO != 'Acordo'

			LEFT JOIN #dim_descontos_do_aluno DA
				ON DA.ALUNO = LD.ALUNO
				AND DA.LANC_DEB = LD.LANC_DEB
			
			left join VW_FCAV_DEVOLUCAO_ALUNO DE
					ON DE.ALUNO = LD.ALUNO
							
			WHERE MP.SIT_ALUNO != 'Cancelado'
			AND MP.SIT_DETALHE = 'Curricular'
			AND mp.oferta_de_curso is not null
		
			GROUP BY MP.ALUNO,
				MP.TURMA,
				LD.LANC_DEB,
				LD.DESCRICAO,
				LD.MATRICULA,
				LD.ANO_REF,
				LD.PERIODO_REF
		END

		-----------------------------------------------------------------------------------------
		--ALIMENTA A TABELA A TEMPORARIA PARA SER CARREGADA NA TABELA FCAV_APOIOWEB_INGRESSANTES
		BEGIN
			SELECT 
				TCA.DT_INSCRICAO,
				TCA.CURSO,
				AL.CURRICULO,
				TCA.OFERTA_DE_CURSO,
				AL.TURMA,
				CASE WHEN TCA.CONCURSO != AL.TURMA THEN AL.TURMA_PREF
				ELSE TCA.CONCURSO
				END AS CONCURSO,
				TCA.COD_INSCR,
				CASE
					WHEN al.CONCURSO IS NOT NULL THEN TCA.SITUACAO
					ELSE ''
				END AS SIT_CANDIDATO,
				TCA.SELEC_COORD,
				CASE
					WHEN EXISTS (SELECT
							1
						FROM LY_CONVOCADOS_VEST
						WHERE CANDIDATO=TCA.COD_INSCR
						AND CONCURSO=TCA.CONCURSO) THEN 'CONVOCADO'
					WHEN TCA.COD_INSCR=AL.ALUNO THEN 'CONVOCADO'
					ELSE 'NÃO CONVOCADO'
				END SIT_CONVOCADO,
				AL.DT_MATRICULA AS DT_INGRESSO,
				AL.ALUNO,
				AL.SIT_ALUNO,
				AL.TURMA_PREF,
				CASE
					WHEN TCA.SELEC_COORD = 'Compra_Direta' THEN 'Venda Direta'
					ELSE 'Processo Seletivo'
				END AS TIPO_INGRESSO,
				(SELECT TOP 1
					SIT_MATRICULA
				FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA
				WHERE MA.ALUNO=AL.ALUNO
				AND MA.CURRICULO=AL.CURRICULO
				GROUP BY SIT_MATRICULA)
				AS SIT_MATRICULA,
				CASE
					WHEN EXISTS (SELECT TOP 1
							1
						FROM LY_H_CURR_ALUNO
						WHERE ALUNO=TCA.COD_INSCR) THEN 'Transferido'
					ELSE 'Normal'
				END ORIGEM,
				PP.PLANOPAG AS PLANO_PGTO_PERIODO,
				CM.FORMA_PAGAMENTO,
				CASE
					WHEN RF.CGC_TITULAR IS NULL THEN RF.CPF_TITULAR
					WHEN RF.CPF_TITULAR IS NULL THEN RF.CGC_TITULAR
					ELSE NULL
				END AS DOC_TITULAR,
				RF.TITULAR,
				PP.PERCENT_DIVIDA_ALUNO,
				BL.TIPO_BOLSA,
				BL.NUM_BOLSA,
				BL.PERC_VALOR,
				BL.VALOR,
				BL.MOTIVO,
				VO.VOUCHER,
				VO.DESCONTO,
				VO.DESC_PERC_VALOR,
				cast(ISNULL(SUM(ex.VALOR_PAGAR), 0) as decimal(10,2)) as VALOR_PAGAR,
				cast(ISNULL(SUM(ex.VALOR_PAGO), 0) as decimal(10,2)) as VALOR_PAGO
			
				INTO #dim_apoioweb_ingressantes

			FROM #dim_inscritos TCA

			LEFT JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA AL 
				ON ISNULL(AL.CANDIDATO, al.ALUNO)=TCA.COD_INSCR
			--	AND al.concurso=tca.CONCURSO
				AND al.UNIDADE_RESPONSAVEL!='PALES'
				and al.CURSO = tca.CURSO
				and al.concurso = tca.concurso
		
			LEFT JOIN #dim_extrato_financeiro EX 
				ON ex.ALUNO=al.ALUNO
				AND ex.TURMA=al.TURMA
			
			left join #dim_divida_do_aluno DA
				on DA.ALUNO = al.ALUNO
				and DA.TURMA = al.TURMA

			LEFT JOIN LY_PLANO_PGTO_PERIODO PP
				ON PP.ALUNO=AL.ALUNO
				AND pp.OUTRAS_DIVIDAS='S'

			LEFT JOIN LY_RESP_FINAN RF
				ON RF.RESP=PP.RESP

			LEFT JOIN LY_BOLSA BL
				ON BL.ALUNO=AL.ALUNO

			LEFT JOIN LY_COMPRA_OFERTA CM
				ON CM.ALUNO=AL.ALUNO

			LEFT JOIN VW_FCAV_ALUNOS_COM_VOUCHERS VO
				ON VO.ALUNO=AL.ALUNO

		--	WHERE al.ALUNO = 'A202000129'

			GROUP BY	al.CONCURSO,
						TCA.CONCURSO,
						TCA.CURRICULO,
						TCA.SITUACAO,
						TCA.DT_INSCRICAO,
						TCA.COD_INSCR,
						TCA.CURSO,
						TCA.OFERTA_DE_CURSO,
						TCA.SELEC_COORD,
						AL.TURMA,
						AL.DT_MATRICULA,
						AL.CURRICULO,
						AL.CANDIDATO,
						AL.ALUNO,
						AL.SIT_ALUNO,
						AL.CURSO,
						AL.TURMA_PREF,
						PP.PLANOPAG,
						PP.PERCENT_DIVIDA_ALUNO,
						BL.TIPO_BOLSA,
						BL.NUM_BOLSA,
						BL.PERC_VALOR,
						BL.VALOR,
						BL.MOTIVO,
						CM.FORMA_PAGAMENTO,
						VO.VOUCHER,
						VO.DESCONTO,
						VO.DESC_PERC_VALOR,
						RF.RESP,
						RF.TITULAR,
						RF.CGC_TITULAR,
						RF.CPF_TITULAR
					
		END

		------------------------------------------------------------------------
		--Preencha a tabela FCAV_APOIOWEB_INGRESSANTES
		BEGIN
			BEGIN TRANSACTION

				TRUNCATE TABLE FCAV_APOIOWEB_INGRESSANTES

				INSERT FCAV_APOIOWEB_INGRESSANTES
					SELECT
						*
					FROM #dim_apoioweb_ingressantes 
					--WHERE CONCURSO = 'MBA-GP T 03' order by COD_INSCR

			COMMIT
		END

		----------------------------------------------------------------------------  
		-- Clean-up  
		----------------------------------------------------------------------------  
		BEGIN
			DROP TABLE #dim_inscritos
			DROP TABLE #dim_extrato_financeiro
			DROP TABLE #dim_divida_do_aluno
			DROP TABLE #dim_descontos_do_aluno
			DROP TABLE #dim_apoioweb_ingressantes
		END -- Clean-up  



	END --fim da sp