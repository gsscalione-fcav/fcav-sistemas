
--* ***************************************************************  
--*  
--*          *** PROCEDURE A_APOI_LY_ITEM_LANC  ***  
--*  
--*    DESCRICAO:  
--*     - Entry-point  
--*     - Executada pela procedure APoI_Ly_Item_Lanc apos a inclusao dos dados na base.  
--*  
--*    USO:  
--*     - Povoa a tabela LY_MOVIMENTO_TEMPORAL se a cobranca JA ESTIVER FATURADA  
--*     - Atualiza centro de custo de LY_ITEM_LANC a partir da turma  
--*     - Tratamento de IGPM  
--*  
--*    ALTERACOES:  
--*  
--*     10/01/2017 - Revisto layout  
--* ***************************************************************  
  

Declare 
@cobranca NUMERIC(10), @itemcobranca NUMERIC(3), @lanc_deb NUMERIC(10), @codigo_lanc VARCHAR(20),  
@aluno VARCHAR(20), @num_bolsa NUMERIC(10), @resp VARCHAR(20), @motivo_desconto VARCHAR(20),  
@devolucao NUMERIC(10), @boleto NUMERIC(10), @parcela NUMERIC(10), @data DATETIME,  
@valor NUMERIC(10, 2), @descricao VARCHAR(100), @acordo NUMERIC(10), @cobranca_orig NUMERIC(10),  
@itemcobranca_orig NUMERIC(3), @centro_de_custo VARCHAR(50), @natureza VARCHAR(50),  
@ano_ref_bolsa NUMERIC(4), @mes_ref_bolsa NUMERIC(2), @num_financiamento NUMERIC(10),  
@encerr_processado VARCHAR(1), @evento VARCHAR(20), @evento_compl VARCHAR(50), @data_contabil DATETIME,  
@dt_envio_contab DATETIME, @curso VARCHAR(20), @turno VARCHAR(20), @curriculo VARCHAR(20),  
@unid_fisica VARCHAR(20), @data_disputa DATETIME, @data_decisao_disputa DATETIME,  
@disputa_aceita VARCHAR(1), @disputa_ajustada VARCHAR(1), @motivo_decisao VARCHAR(255),  
@lote_contabil NUMERIC(10), @data_perda DATETIME, @origem VARCHAR(200)  
  
-- [INICIO] Customizacao - Nao escreva codigo antes desta linha  
BEGIN -- BEGIN 1  

	BEGIN  
			------------------------------------------------------------------------  
			-- Atualiza centro de custo de LY_ITEM_LANC a partir da turma  
			------------------------------------------------------------------------  

			SET @cobranca = 211447
			set @parcela = 15
			set @CURSO = 'CEGP'
			set @TURNO = 'NOTURNO'

			select @LANC_DEB = lanc_deb , @parcela = PARCELA
			from LY_ITEM_LANC where COBRANCA = @cobranca and LANC_DEB is not null 
		

			DECLARE @TURMA_PREF T_CODIGO  
  
			SELECT  
				-- Se nao estiver definido a.TURMA_PREF,  
				-- recupera a partir da mais recente matricula ou pre-matricula (VW_FCAV_MATRICULA_E_PRE_MATRICULA)  
				@TURMA_PREF = ISNULL(a.TURMA_PREF, mat_pre_mat.TURMA)  
			FROM  
				dbo.LY_COBRANCA C  
					INNER JOIN(  
						dbo.LY_ALUNO A  
							LEFT OUTER JOIN dbo.VW_FCAV_MATRICULA_E_PRE_MATRICULA mat_pre_mat  
							ON(  
									mat_pre_mat.ALUNO = A.ALUNO  
								AND mat_pre_mat.TURMA IS NOT NULL  
								--  
								AND mat_pre_mat.DT_ULTALT =(  
										SELECT MAX(DT_ULTALT)  
										FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA mat_pre_mat_max  
										WHERE mat_pre_mat_max.ALUNO = mat_pre_mat.ALUNO  
									)  
							)  
					)  
					ON A.ALUNO = C.ALUNO  
			WHERE c.COBRANCA = @cobranca  
  

		END -- Atualiza centro de custo de LY_ITEM_LANC a partir da turma ----------  
	
	IF NOT EXISTS(select 1 from LY_DESCONTO_DEBITO where LANC_DEB = @lanc_deb  AND MOTIVO_DESCONTO = 'Estorno') --So aplica o IGPM se a divida nao estiver estornada
	BEGIN
	
		BEGIN  
			------------------------------------------------------------------------  
			-- Tratamento de IGPM  
			------------------------------------------------------------------------  
  
			BEGIN  
				----------------------------------------------------------  
				-- Criterio IGPM: ainda nao foi calculado  
				----------------------------------------------------------  
  
				DECLARE @IGPM_NAO_CALCULADO BIT  
				  SET @IGPM_NAO_CALCULADO =  
					CASE WHEN NOT EXISTS(  
								SELECT *  
								FROM dbo.LY_ITEM_LANC  
								WHERE  
									COBRANCA  = @cobranca
								AND PARCELA   = @parcela
								AND DESCRICAO = 'Acrescimo de IGPM'
								AND ITEM_ESTORNADO IS NULL
							) THEN 1  
							  ELSE 0  
					END  
			END -- Criterio IGPM: ainda nao foi calculado ----------------  
  
			BEGIN  
				----------------------------------------------------------  
				-- Criterio IGPM: nao eh estorno  
				----------------------------------------------------------  
  
				DECLARE @IGPM_NAO_EH_ESTORNO BIT  
  
				SELECT @IGPM_NAO_EH_ESTORNO =  
					CASE WHEN ESTORNO <> 'S' THEN 1  
											 ELSE 0  
					END  
				FROM dbo.LY_COBRANCA  
				WHERE COBRANCA = @COBRANCA  
			END -- Criterio IGPM: nao eh estorno --------------------------  
  
			BEGIN  
				----------------------------------------------------------  
				-- Criterio IGPM: nao tem bolsa 100%  
				----------------------------------------------------------  
  
				DECLARE @IGPM_BOLSA_TOTAL BIT  
  
				SELECT @IGPM_BOLSA_TOTAL =  
					CASE WHEN NOT EXISTS  
					 ( SELECT *   
					  FROM LY_BOLSA BOL INNER JOIN LY_ITEM_LANC IL ON (IL.ALUNO = BOL.ALUNO)  
					  WHERE IL.COBRANCA = @COBRANCA AND BOL.PERC_VALOR = 'Percentual' AND BOL.VALOR = '1.000000' )  
					 THEN 1  
					 ELSE 0  
					END  
			END -- Criterio IGPM: nao tem bolsa 100% ---------------------  
  
			BEGIN  
				----------------------------------------------------------  
				-- Criterio IGPM: tem bolsa para ajustar  
				----------------------------------------------------------  
  
				DECLARE @IGPM_BOLSA_PARC BIT  
  
				SET @IGPM_BOLSA_PARC =  
					CASE WHEN EXISTS(  
								SELECT *  
								FROM dbo.LY_ITEM_LANC  
								WHERE  
									COBRANCA  = @cobranca  
								AND NUM_BOLSA IS NOT NULL  
							   	   AND DESCRICAO LIKE 'Bolsa%'  
							   AND ITEM_ESTORNADO IS NULL  
							) and not exists(SELECT *  
								FROM dbo.LY_ITEM_LANC  
								WHERE  
									COBRANCA  = @cobranca  
								AND NUM_BOLSA IS NOT NULL  
							    AND DESCRICAO LIKE '%Acerto%'  
							    AND ITEM_ESTORNADO IS NULL)
							
							THEN 1   
							  ELSE 0  
					END  
			END -- Criterio IGPM: tem bolsa para ajustar ----------------  
  
			BEGIN  
				----------------------------------------------------------  
				-- Criterio IGPM: excecao de calculo - usar parcela 11  
				----------------------------------------------------------  
  
				DECLARE @IGPM_CALCULO_EXCECAO_PAR_11 BIT  
  
				SELECT @IGPM_CALCULO_EXCECAO_PAR_11 =  
					CASE WHEN EXISTS(  
								SELECT *  
								FROM dbo.LY_MATRICULA  
								WHERE  
									ALUNO = @aluno  
								AND LANC_DEB IS NOT NULL  
								AND TURMA IN(  
										   'CELOG T 22','CEAI T 25','CEGP T 62','CEAI T 22', 'CEGP T 60', 'CEGP-TI T 22', 'CELOG T 20', 'MBA-GO T 26'  
										)  
							) THEN 1  
							  ELSE 0  
					END  
			END -- Criterio IGPM: excecao de calculo - usar parcela 11 ---  

			BEGIN  
				----------------------------------------------------------  
				-- Criterio IGPM: Turma cadastrada como excecao de calculo 
				----------------------------------------------------------  
  
				DECLARE @IGPM_TURMA_EXCECAO BIT  
  
				SELECT @IGPM_TURMA_EXCECAO =  
					CASE WHEN EXISTS(  
								SELECT *  
								FROM dbo.VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA
								WHERE  
									ALUNO = @aluno  
								AND TURMA IN (SELECT DESCR 
											  FROM HD_TABELAITEM 
											  WHERE 
												TABELA	= 'IsencaoIGPM' 
											  )										  
							) THEN 1  --TURMA ISENTA DO CALCULO IGPM
							  ELSE 0  
					END  
			END -- Criterio IGPM: Turma cadastrada como excecao de calculo  
  
  
  
			DECLARE @IGPM_PERC     T_DECIMAL_MEDIO_PRECISO6  
			DECLARE @IGPM_PERC_ANT T_DECIMAL_MEDIO_PRECISO6  
			DECLARE @IGPM_VALOR    T_DECIMAL_MEDIO  
  
			--COBRANCA, ITEMCOBRANCA  
			IF  
				@parcela > 12 AND  
				--  
				@IGPM_NAO_CALCULADO  = 1 AND  
				@IGPM_NAO_EH_ESTORNO = 1 AND  
				@IGPM_BOLSA_TOTAL	= 1	 AND
				@IGPM_TURMA_EXCECAO = 0
			BEGIN -- BEGIN IF  
    
			BEGIN -- BEGIN 2  
				WITH  
					tu AS(  
						SELECT  
							tu.CURSO, tu.TURNO, tu.TURMA,  
							--  
							MIN(  
								CONVERT(VARCHAR, tu.ANO) + '/' + CONVERT(VARCHAR, tu.SEMESTRE)  
							) AS ANO_SEMESTRE_INICIO,  
							--  
							MIN(tu.DT_INICIO) AS DT_INICIO  
						FROM dbo.LY_TURMA tu  
						GROUP BY tu.CURSO, tu.TURNO, tu.TURMA  
					)  
				SELECT  
					@IGPM_PERC     = COR.VALOR,  
					@IGPM_PERC_ANT = COR_ANT.VALOR  
				FROM  
					dbo.LY_LANC_DEBITO ld,  
					tu  
						LEFT OUTER JOIN LY_CORRECAO COR  
						ON(  
								COR.ANO = YEAR(TU.DT_INICIO) + 1  
							AND COR.MES = MONTH(TU.DT_INICIO)  
						)  
						--  
						LEFT OUTER JOIN LY_CORRECAO COR_ANT  
						ON(  
								COR_ANT.ANO = YEAR(TU.DT_INICIO) + 1  
							AND COR_ANT.MES = MONTH(DATEADD(mm, -1, TU.DT_INICIO))  
						)  
				WHERE  
					ld.LANC_DEB = @LANC_DEB  
				--  
				AND tu.CURSO = @CURSO  
				AND tu.TURNO = @TURNO  
				AND tu.ANO_SEMESTRE_INICIO = CONVERT(VARCHAR, ld.ANO_REF) + '/' + CONVERT(VARCHAR, ld.PERIODO_REF)  
  
				-- Determinacao de @IGPM_VALOR -----------------  
				SET @IGPM_VALOR =  
					@VALOR *  
					CASE @IGPM_CALCULO_EXCECAO_PAR_11  
						WHEN 0 THEN @IGPM_PERC  
								ELSE @IGPM_PERC_ANT  
						END -- FINAL CASE  
					END -- FINAL BEGIN 2  

				--Prevencao de IGPM negativo
				IF @IGPM_VALOR < 0.01  
				BEGIN -- BEGIN 3
					SET @IGPM_VALOR = 0.00
				END  --FINAL BEGIN 3

				
				
				declare @ultimo_item numeric

				select @ultimo_item = ultimo_item
				from LY_COBRANCA where cobranca = @cobranca
  
			--- LINHA DO IGPM
				SELECT distinct 
					@COBRANCA AS COBRANCA, @ultimo_item + 10 AS ITEMCOBRANCA, NULL AS LANC_DEB, 'MS' /* Melhor: @codigo_lanc! */ AS CODIGO_LANC,  
					@ALUNO, @RESP, NULL AS NUM_BOLSA,  
					NULL /* Original: 'Acrescimo' */ AS motivo_desconto,  
					--  
					NULL AS DEVOLUCAO, @boleto, @parcela, @data,  
					--  
					@IGPM_VALOR AS VALOR, 'Acrescimo de IGPM' AS DESCRICAO,  
					--  
					NULL AS ACORDO, NULL AS COBRANCA_ORIG, NULL AS ITEMCOBRANCA_ORIG,  
					--  
					@centro_de_custo, @natureza, @ano_ref_bolsa, @mes_ref_bolsa, @num_financiamento, @encerr_processado, @evento, @evento_compl, @data_contabil, @dt_envio_contab,  
					@curso, @turno, @curriculo, @unid_fisica, @data_disputa, @data_decisao_disputa, @disputa_aceita, @disputa_ajustada, @motivo_decisao, @lote_contabil,  
					@data_perda, @origem  
				FROM dbo.LY_ITEM_LANC  
				WHERE COBRANCA = @COBRANCA  
					AND ISNULL(@IGPM_VALOR,'0.00') > '0.00'
					AND DESCRICAO NOT LIKE 'Bolsa%' 
			      
		  


		IF @IGPM_BOLSA_PARC  = 1 and  
		   @IGPM_NAO_CALCULADO  = 0  
		BEGIN -- BEGIN INSERE LINHA BOLSA  
  
			DECLARE @VALOR_BOLSA  T_DECIMAL_MEDIO  
			DECLARE @IGPM_BOLSA   T_DECIMAL_MEDIO  
  
  
			  BEGIN  
						WITH  
							tu AS(  
								SELECT  
									tu.CURSO, tu.TURNO, tu.TURMA,  
									--  
									MIN(  
										CONVERT(VARCHAR, tu.ANO) + '/' + CONVERT(VARCHAR, tu.SEMESTRE)  
									) AS ANO_SEMESTRE_INICIO,  
									--  
									MIN(tu.DT_INICIO) AS DT_INICIO  
								FROM dbo.LY_TURMA tu  
								GROUP BY tu.CURSO, tu.TURNO, tu.TURMA  
							)  

						
						SELECT  
							@IGPM_PERC     = COR.VALOR,  
							@IGPM_PERC_ANT = COR_ANT.VALOR  
						FROM  
							dbo.LY_LANC_DEBITO ld,  
							tu  
								LEFT OUTER JOIN LY_CORRECAO COR  
								ON(  
										COR.ANO = YEAR(TU.DT_INICIO) + 1  
									AND COR.MES = MONTH(TU.DT_INICIO)  
								)  
								--  
								LEFT OUTER JOIN LY_CORRECAO COR_ANT  
								ON(  
										COR_ANT.ANO = YEAR(DATEADD(mm, -1, TU.DT_INICIO)) + 1  
									AND COR_ANT.MES = MONTH(DATEADD(mm, -1, TU.DT_INICIO))  
								)  
						WHERE  
							ld.LANC_DEB = @LANC_DEB  
						--  
						AND tu.CURSO = @CURSO  
						AND tu.TURNO = @TURNO  
						AND tu.ANO_SEMESTRE_INICIO = CONVERT(VARCHAR, ld.ANO_REF) + '/' + CONVERT(VARCHAR, ld.PERIODO_REF)  
				
				
      
				SELECT @VALOR_BOLSA =   
				   SUM(VALOR)  
				FROM dbo.LY_ITEM_LANC  
				WHERE  
					COBRANCA  = @cobranca  
				AND NUM_BOLSA IS NOT NULL  
				AND DESCRICAO LIKE 'Bolsa%'  
				AND ITEM_ESTORNADO IS NULL  
         
				SET @IGPM_BOLSA =  
				   @VALOR_BOLSA *  
				   CASE @IGPM_CALCULO_EXCECAO_PAR_11  
					WHEN 0 THEN @IGPM_PERC  
					  ELSE @IGPM_PERC_ANT  
					END -- FINAL CASE     
			   END  
				
				
				select @ultimo_item = ultimo_item
			  from LY_COBRANCA where cobranca = @cobranca


			   -- linha de IGPM PARA A BOLSA -------------------  
			 SELECT  DISTINCT
			   @COBRANCA AS COBRANCA, 20 AS ITEMCOBRANCA,   
			   NULL AS LANC_DEB,   
			   'MS' /* Melhor: @codigo_lanc! */ AS CODIGO_LANC,  
			   @ALUNO ALUNO, @RESP RESP, NULL AS NUM_BOLSA,  
			   NULL /* Original: 'Acrescimo' */ AS motivo_desconto,  
			   --  
			   NULL AS DEVOLUCAO, @boleto BOLETO , @parcela PARCELA, @data DATA,  
			   --  
			   @IGPM_BOLSA AS VALOR, 'Ajuste de IGPM Bolsa' AS DESCRICAO,  
			   --  
			   NULL AS ACORDO, NULL AS COBRANCA_ORIG, NULL AS ITEMCOBRANCA_ORIG
			   --  
			    
			  FROM dbo.LY_ITEM_LANC  
			  WHERE COBRANCA = @COBRANCA
			  AND DESCRICAO LIKE '%IGPM%'
				AND DESCRICAO NOT LIKE '%Tipo%Acerto%'

      
      
				END   -- END INSERE LINHA BOLSA  
			END -- FINAL BEGIN IF     
		
		END -- Tratamento de IGPM  
	
	END -- fim da verificacao do estorno da divida
  
END -- FINAL BEGIN 1  


select  @cobranca as cobranca,
						@CURSO as curso,
						@TURNO as turno,
						@LANC_DEB LANC_DEB, 
						@IGPM_TURMA_EXCECAO as IGPM_TURMA_EXCECAO,
						@IGPM_NAO_CALCULADO as IGPM_NAO_CALCULADO,
						@IGPM_NAO_EH_ESTORNO as IGPM_NAO_EH_ESTORNO,
						@IGPM_BOLSA_PARC IGPM_BOLSA_PARC, 
						@IGPM_PERC as IGPM_PERC, 
						@IGPM_BOLSA as IGPM_bolsa

  