          
/****************************************************************                  
--*                  
--*  ***PROCEDURE PR_FCAV_CONSULTA_PESSOA ***                  
--*                   
--* DESCRICAO:                  
--* - PROCEDURE PARA CONSULTAR AS INFORMAÇÕES IMPORTANTES REFERENTE A PESSOA.                  
--*                  
--* PARAMETROS:                  
--* -                 
--*                   
--* USO:                  
--* - O uso exclusivo.                  
--*                  
--* ALTERAÇÕES:                  
--*         EXEC PR_FCAV_CONSULTA_PESSOA NULL,'Gabriel%Scalione',NULL,NULL,NULL,NULL
--*                  
--* Autor: Gabriel S. Scalione                  
--* Data de criação: 26/11/2014                  
        
SELECT * FROM #TMP_CANDIDATO_ALUNO WHERE PESSOA = 95677        
        
*****************************************************************/          
        
          
ALTER PROCEDURE PR_FCAV_CONSULTA_PESSOA @pessoa numeric,          
@nome_pessoa varchar(100),          
@cpf varchar(11),          
@e_mail varchar(100),          
@candidato varchar(20),          
@aluno varchar(20)          
          
-----------------------------------------------------------------------                  
          
AS          
          
        
-----------------------------------------------------------------------                    
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
				OC.CONCURSO AS CONCURSO,
				OC.OFERTA_DE_CURSO,
				OC.CURSO,
				OC.CURRICULO,
				OC.ANO_INGRESSO,
				OC.PER_INGRESSO 
				
			INTO #tmp_candidato_aluno

			FROM LY_CANDIDATO CA
			INNER JOIN LY_OFERTA_CURSO OC
				ON OC.CONCURSO=CA.CONCURSO
				AND OC.ANO_INGRESSO>=2019
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
			FROM VW_FCAV_ALUNOS_VENDA_DIRETA Vd-- WHERE TURMA = 'A-gpmp T 116'
			INNER JOIN LY_ALUNO al
				ON al.ALUNO=vd.ALUNO
			LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA T
				ON T.TURMA=vd.TURMA
				AND t.UNIDADE_RESPONSAVEL!='PALES'


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
		SELECT
			MP.ALUNO,
			MP.TURMA,
			cast(ISNULL(EX.VALOR_PAGAR, 0) as decimal(10,2)) AS VALOR_PAGAR,
			cast(ISNULL(EX.VALOR_PAGO, 0) as decimal(10,2)) AS VALOR_PAGO 
			
			INTO #tmp_extrato_financeiro

		FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA2 MP
		LEFT JOIN VW_FCAV_EXTFIN_LY EX
			ON MP.ALUNO=EX.ALUNO
			AND MP.TURMA=EX.TURMA
			AND EX.CODIGO_LANC!='ACORDO'
			AND EX.COBRANCA=(SELECT
				MIN(COBRANCA)
			FROM LY_ITEM_LANC IL
			WHERE EX.ALUNO=IL.ALUNO
			AND EX.COBRANCA=IL.COBRANCA
			AND IL.PARCELA=1
			AND il.NUM_BOLSA IS NULL)


		-----------------------------------------------------------------------------------------


		SELECT DISTINCT
			PE.PESSOA,
			PE.NOME_COMPL,
			PE.E_MAIL,
			PE.CPF,
			PE.RG_NUM,
			DBO.DECRYPT(PE.SENHA_TAC) AS SENHA,
			TCA.DT_INSCRICAO,
			TCA.CURSO,
			TCA.CURRICULO,
			TCA.OFERTA_DE_CURSO,
			AL.TURMA,
			TCA.CONCURSO AS CONCURSO,
			TCA.COD_INSCR,
			CASE
				WHEN TCA.CONCURSO IS NOT NULL THEN TCA.SITUACAO
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
				WHEN TCA.CONCURSO IS NULL THEN 'Venda Direta'
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
			cast(ISNULL(VALOR_PAGAR, 0) as decimal(10,2)) as VALOR_PAGAR,
			cast(ISNULL(VALOR_PAGO, 0) as decimal(10,2)) as VALOR_PAGO 
			
			

		FROM LY_PESSOA PE
		
		LEFT JOIN #tmp_candidato_aluno TCA
			ON TCA.PESSOA = PE.PESSOA

		LEFT JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA2 AL
			ON ISNULL(AL.CANDIDATO, al.ALUNO)=TCA.COD_INSCR
			AND al.concurso=tca.CONCURSO

		LEFT JOIN #tmp_extrato_financeiro EX
			ON ex.ALUNO=al.ALUNO
			AND ex.TURMA=al.TURMA

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

		WHERE  PE.PESSOA LIKE @pessoa        
			OR PE.NOME_COMPL LIKE @nome_pessoa        
			OR PE.CPF LIKE @cpf 
			OR PE.E_MAIL like @e_mail  
			OR TCA.COD_INSCR LIKE @candidato        
			OR AL.ALUNO LIKE @aluno      

		GROUP BY	PE.PESSOA,
					PE.NOME_COMPL,
					PE.E_MAIL,
					PE.CPF,
					PE.RG_NUM,
					PE.SENHA_TAC,
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
					RF.CPF_TITULAR,
					EX.VALOR_PAGAR,
					EX.VALOR_PAGO
        
        ----------------------------------------------------------------------------  
		-- Clean-up  
		----------------------------------------------------------------------------  
		BEGIN
			DROP TABLE #tmp_candidato_aluno
			DROP TABLE #tmp_extrato_financeiro
		END -- Clean-up        
          
          
    RETURN