
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
--*			10/01/2017 - Revisto layout.
--*			18/09/2020 - Revisto validado as regras para aplicação do IGPM junto ao Financeiro. 
--* ***************************************************************  
 

ALTER PROCEDURE dbo.a_APoI_Ly_item_lanc  
@erro VARCHAR(1024) OUTPUT,  
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
AS  
-- [INICIO] Customizacao - Nao escreva codigo antes desta linha  
BEGIN -- BEGIN 1  
	
	DECLARE @IGPM_PERC     T_DECIMAL_MEDIO_PRECISO6  
	DECLARE @IGPM_PERC_ANT T_DECIMAL_MEDIO_PRECISO6  
	DECLARE @IGPM_VALOR    T_DECIMAL_MEDIO  
	DECLARE @TURMA_PREF T_CODIGO  
	DECLARE @ULTIMO_ITEM NUMERIC
	DECLARE @VALOR_BOLSA  T_DECIMAL_MEDIO  
	DECLARE @IGPM_BOLSA   T_DECIMAL_MEDIO 
	DECLARE @VERIFICA_IGPM_NAO_CALCULADO BIT 
	DECLARE @VERIFICA_NAO_EH_ESTORNO BIT 
	DECLARE @VERIFICA_BOLSA_NAO_EH_TOTAL BIT  
	DECLARE @VERIFICA_BOLSA_PARC BIT  

	BEGIN 
		------------------------------------------------------------------------  
		-- Atualiza centro de custo de LY_ITEM_LANC a partir da turma  
		------------------------------------------------------------------------  

			
  
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
  
		UPDATE IL  
		SET  
			CENTRO_DE_CUSTO = cc.CENTRO_DE_CUSTO  
		FROM  
			dbo.LY_ITEM_LANC IL,  
			dbo.LY_CENTRO_DE_CUSTO cc  
		WHERE  
			il.COBRANCA     = @cobranca  
		AND il.ITEMCOBRANCA = @itemcobranca  
		--  
		AND cc.TURMA = @TURMA_PREF  
	
	END -- Atualiza centro de custo de LY_ITEM_LANC a partir da turma ----------  
	


	------------------------------------------------------------------------  
	-- Tratamento de IGPM  
	------------------------------------------------------------------------  
		
	IF (@parcela > 12)
	BEGIN  
		----------------------------------------------------------
		-- Criterio IGPM: 1 - Verifica se é a 13ª parcela ou maior
		----------------------------------------------------------
  
		BEGIN  
			----------------------------------------------------------  
			-- Criterio IGPM: Verifica se ainda nao foi calculado  
			----------------------------------------------------------  
  
			
				SET @VERIFICA_IGPM_NAO_CALCULADO =  
				CASE WHEN NOT EXISTS(  
							SELECT *  
							FROM dbo.LY_ITEM_LANC  
							WHERE  
								COBRANCA  = @cobranca
							AND PARCELA   = @parcela
							AND DESCRICAO = 'Acrescimo de IGPM'
                            
						) THEN 1  
							ELSE 0  
				END  
		END -- Criterio IGPM: 2 - Verifica se na cobrança, já houve correção por IGP-M; ---------------  
  
		BEGIN  
			----------------------------------------------------------  
			-- Criterio IGPM: nao eh estorno  
			----------------------------------------------------------  
  
			SELECT @VERIFICA_NAO_EH_ESTORNO =  
				CASE WHEN ESTORNO <> 'S' THEN 1  
											ELSE 0  
				END  
			FROM dbo.LY_COBRANCA  
			WHERE COBRANCA = @COBRANCA  
		END -- Criterio IGPM: 3 - Verifica se não tem estorno; ------------------------  
  
		BEGIN  
			----------------------------------------------------------  
			-- Criterio IGPM: nao tem bolsa 100%  
			----------------------------------------------------------  
  
			SELECT @VERIFICA_BOLSA_NAO_EH_TOTAL =  
				CASE WHEN NOT EXISTS  
					( SELECT *   
					FROM LY_BOLSA BOL INNER JOIN LY_ITEM_LANC IL ON (IL.ALUNO = BOL.ALUNO)  
					WHERE IL.COBRANCA = @COBRANCA AND BOL.PERC_VALOR = 'Percentual' AND BOL.VALOR = '1.000000' )  
					THEN 1  
					ELSE 0  
				END  
		END -- Criterio IGPM: 4 - Verifica se não é bolsista 100%; --------------------  
  
		BEGIN  
			----------------------------------------------------------  
			-- Criterio IGPM: tem bolsa para ajustar  
			----------------------------------------------------------  
  
			SET @VERIFICA_BOLSA_PARC =  
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
							 and not exists(SELECT *  
								FROM dbo.LY_ITEM_LANC  
								WHERE  
									COBRANCA  = @cobranca  
								AND NUM_BOLSA IS NOT NULL  
							    AND DESCRICAO LIKE '%Desconto%'  
							    AND ITEM_ESTORNADO IS NULL)
							 and not exists(SELECT *  
								FROM dbo.LY_ITEM_LANC  
								WHERE  
									COBRANCA  = @cobranca  
								AND NUM_BOLSA IS NOT NULL  
							    AND DESCRICAO LIKE '%Valor%'  
							    AND ITEM_ESTORNADO IS NULL)
							
							THEN 1  
							  ELSE 0  
				END  
		END -- Criterio IGPM: 5 - Verifica se o bolsista é menor 100% para o calculo do valor da bolsa para aplicação do IGP-M. ----------------  
  

		-- Verifica indice e faz o calculo com base no mes da 12a parcela, pois na 13a pode nao haver indice ainda.
		BEGIN
			WITH tu AS(  
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
						COR_ANT.ANO = CASE WHEN MONTH(TU.DT_INICIO) = 1 THEN YEAR(TU.DT_INICIO)
										ELSE YEAR(TU.DT_INICIO) + 1 END
						AND COR_ANT.MES = CASE WHEN MONTH(TU.DT_INICIO) = 1 THEN 12 
										ELSE MONTH(DATEADD(mm, -1, TU.DT_INICIO)) END
					)  
			WHERE  
				ld.LANC_DEB = @LANC_DEB  
			--  
			AND tu.CURSO = @CURSO  
			AND tu.TURNO = @TURNO  
			AND tu.ANO_SEMESTRE_INICIO = CONVERT(VARCHAR, ld.ANO_REF) + '/' + CONVERT(VARCHAR, ld.PERIODO_REF)  --Fim do verifica indice

			------------------------------------------------------------------------
			-- Calcula o valor de IGPM aplicado na Mensalidade -----------------  
			------------------------------------------------------------------------
			BEGIN

				SET @IGPM_VALOR =  @VALOR * isnull(@IGPM_PERC_ANT,0)

			END -- Fim do Calculo para Mensalidade

			------------------------------------------------------------------------
			-- Calcula o valor de IGPM aplicado para Bolsa -----------------  
			------------------------------------------------------------------------
			BEGIN
				SELECT @VALOR_BOLSA =   
					SUM(VALOR)  
				FROM dbo.LY_ITEM_LANC  
				WHERE  
					COBRANCA  = @cobranca  
				AND NUM_BOLSA IS NOT NULL  
				AND DESCRICAO LIKE 'Bolsa%'  
				AND DESCRICAO NOT LIKE '%Valor%'
				AND ITEM_ESTORNADO IS NULL
				AND PARCELA = @parcela
         
				SET @IGPM_BOLSA = @VALOR_BOLSA *  isnull(@IGPM_PERC_ANT,0)

			END -- Fim do Calculo para a Bolsa

		END --- Fim do Verifica indice e faz o calculo

			
		------------------------------------------------------------------------	
		-- BLOCO PARA INSERIR A LINHA DE IGPM  
		------------------------------------------------------------------------	
		BEGIN
			IF @VERIFICA_IGPM_NAO_CALCULADO  = 1  AND  
			   @VERIFICA_NAO_EH_ESTORNO = 1		  AND  
			   @VERIFICA_BOLSA_NAO_EH_TOTAL	= 1   AND
			   @IGPM_VALOR > 0.00
			BEGIN
				
				-- Verifica o campo ultimo_item da Cobranca e soma mais para a inserir na Item Lanc. -----------------
				BEGIN
					SELECT 
						@ULTIMO_ITEM = ULTIMO_ITEM + 1
					FROM 
						LY_COBRANCA 
					WHERE COBRANCA = @cobranca

					-- Atualiza o campo ultimo_item na tabela LY_COBRANCA ---  
					UPDATE LY_COBRANCA  
					SET ULTIMO_ITEM = @ULTIMO_ITEM
					WHERE COBRANCA  = @COBRANCA 
				END -- Fim do ultimo item


			-- Insercao da linha de IGPM -------------------  
				INSERT INTO dbo.LY_ITEM_LANC(  
					COBRANCA, ITEMCOBRANCA, LANC_DEB, CODIGO_LANC,  
					ALUNO, RESP, NUM_BOLSA,  
					MOTIVO_DESCONTO,  
					--  
					DEVOLUCAO, BOLETO, PARCELA, DATA,  
					--  
					VALOR, DESCRICAO,  
					--  
					ACORDO, COBRANCA_ORIG, ITEMCOBRANCA_ORIG,  
					--  
					CENTRO_DE_CUSTO, NATUREZA, ANO_REF_BOLSA, MES_REF_BOLSA, NUM_FINANCIAMENTO, ENCERR_PROCESSADO, EVENTO, EVENTO_COMPL, DATA_CONTABIL, DT_ENVIO_CONTAB,  
					CURSO, TURNO, CURRICULO, UNID_FISICA, DATA_DISPUTA, DATA_DECISAO_DISPUTA, DISPUTA_ACEITA, DISPUTA_AJUSTADA, MOTIVO_DECISAO, LOTE_CONTABIL,  
					DATA_PERDA, ORIGEM  
				)  
				VALUES (
					@cobranca, @ultimo_item , NULL , 'MS',  
					@ALUNO, @RESP, NULL, NULL,  
					--  
					NULL, @boleto, @parcela, @data,  
					--  
					@IGPM_VALOR, 'Acrescimo de IGPM',  
					--  
					NULL, NULL, NULL,  
					--  
					@centro_de_custo, @natureza, @ano_ref_bolsa, @mes_ref_bolsa, @num_financiamento, @encerr_processado, @evento, @evento_compl, @data_contabil, @dt_envio_contab,  
					@curso, @turno, @curriculo, @unid_fisica, @data_disputa, @data_decisao_disputa, @disputa_aceita, @disputa_ajustada, @motivo_decisao, @lote_contabil,  
					@data_perda, @origem  
				
				)
			END -- FIM DO IF PARA INSERIR LINHA DE IGP-M
		
		END --  BLOCO PARA INSERIR A LINHA DE IGP-M  

          
		------------------------------------------------------------------------
		--BLOCO PARA INSERIR A LINHA DE IGP-M PARA BOLSA
		------------------------------------------------------------------------
		BEGIN	
			IF @VERIFICA_BOLSA_PARC = 1	 
			BEGIN
      
				-- Verifica o campo ultimo_item da Cobranca e soma mais 1 para a inserir na Item Lanc. -----------------
				BEGIN
					SELECT 
						@ULTIMO_ITEM = ULTIMO_ITEM + 1
					FROM 
						LY_COBRANCA 
					WHERE COBRANCA = @cobranca

					-- Atualiza o campo ultimo_item na tabela LY_COBRANCA ---  
					UPDATE LY_COBRANCA  
					SET ULTIMO_ITEM = @ULTIMO_ITEM
					WHERE COBRANCA  = @COBRANCA 
				END -- Fim do ultimo item

				
				-- Insercao da linha de IGPM PARA A BOLSA -------------------  
				INSERT INTO dbo.LY_ITEM_LANC(  
					COBRANCA, ITEMCOBRANCA, LANC_DEB, CODIGO_LANC,  
					ALUNO, RESP, NUM_BOLSA,  
					MOTIVO_DESCONTO,  
					--  
					DEVOLUCAO, BOLETO, PARCELA, DATA,  
					--  
					VALOR, DESCRICAO,  
					--  
					ACORDO, COBRANCA_ORIG, ITEMCOBRANCA_ORIG,  
					--  
					CENTRO_DE_CUSTO, NATUREZA, ANO_REF_BOLSA, MES_REF_BOLSA, NUM_FINANCIAMENTO, ENCERR_PROCESSADO, EVENTO, EVENTO_COMPL, DATA_CONTABIL, DT_ENVIO_CONTAB,  
					CURSO, TURNO, CURRICULO, UNID_FISICA, DATA_DISPUTA, DATA_DECISAO_DISPUTA, DISPUTA_ACEITA, DISPUTA_AJUSTADA, MOTIVO_DECISAO, LOTE_CONTABIL,  
					DATA_PERDA, ORIGEM  
				)  
				VALUES(
					@COBRANCA, @ultimo_item,   
					NULL,   
					'MS',  
					@ALUNO, @RESP, NULL ,  
					NULL,  
					--  
					NULL , @boleto, @parcela, @data,  
					--  
					@IGPM_BOLSA , 'Ajuste de IGPM Bolsa' ,  
					--  
					NULL , NULL , NULL ,  
					--  
					@centro_de_custo, @natureza, @ano_ref_bolsa, @mes_ref_bolsa, @num_financiamento, @encerr_processado, @evento, @evento_compl, @data_contabil, @dt_envio_contab,  
					@curso, @turno, @curriculo, @unid_fisica, @data_disputa, @data_decisao_disputa, @disputa_aceita, @disputa_ajustada, @motivo_decisao, @lote_contabil,  
					@data_perda, @origem  
				)
			END   -- FIM IF PARA INSERA A LINHA BOLSA  

		END -- FIM DO BLOCO PARA INSERIR LINHA IGPM BOLSA

		
	END -- Criterio IGPM: 1 - Verifica se é a 13ª parcela ou maior ---------------
			
	------------------------------------------------------------------------  
	-- Fim do Bloco para Tratamento IGPM  
	------------------------------------------------------------------------   


END	-- BEGIN 1
  
-- [FIM] Customizacao - Nao escreva codigo apos esta linha  
  