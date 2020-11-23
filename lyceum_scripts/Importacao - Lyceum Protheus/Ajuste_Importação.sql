-- *** PESQUISA POR FATURAMENTO DE ESTORNO NO PROTHEUS ***
-- *** COLOCAR O NUMERO DA COBRANCA NO CAMPO CT2_HIST PARA PESQUISA ***
USE DADOSADVP12
GO
 SELECT 
D_E_L_E_T_, CT2_DATA, CT2_LOTE, CT2_DOC,CT2_LINHA, CT2_DC,
CT2_DEBITO,CT2_CREDIT, CT2_HIST,CT2_VALOR, CT2_CCD,CT2_CCC, R_E_C_N_O_
 FROM		DADOSADVP12.dbo.CT2010
 WHERE	--D_E_L_E_T_ = '' and
  CT2_DATA >= '20190101'
AND (  CT2_HIST LIKE '%200173%')
AND			CT2_LOTE in ('008871','008870')
ORDER BY	CT2_LOTE,CT2_DOC DESC,CT2_LINHA


--IDENTIFICA O ÚLTIMO DOC NA CT2
SELECT 
	CT2_DATA,
	CT2_LOTE,
	CT2_DOC 
FROM		DADOSADVP12.dbo.CT2010
WHERE	D_E_L_E_T_ = '' and
  CT2_DATA >= '20200101'
AND			CT2_LOTE in ('008870')
GROUP BY
		CT2_DATA,
	CT2_LOTE,CT2_DOC
ORDER BY	CT2_LOTE,CT2_DOC DESC


--****************************************************************************
--					LIBERACAO DO CENTRO DE CUSTO							--
--****************************************************************************

	
			declare @centro_custo varchar(9)

			set @centro_custo = '502013118' -- INFORME O CENTRO DE CUSTO

			SELECT CTT_TX_GER, CTT_CLVL, *
			FROM DADOSADVP12.dbo.CTT010
			WHERE  D_E_L_E_T_ = ''
			and CTT_CUSTO = @centro_custo


			--CENTRO DE CUSTO VENCIDO
				UPDATE CTT010
				SET
				 CTT_DTEXSF = CONVERT(varchar,getdate()+1,112) ---Data de Vencimento
				WHERE CTT_CUSTO IN (@centro_custo)


			--CENTRO DE CUSTO BLOQUEADO
				UPDATE CTT010
				SET
					CTT_BLOQ = '2'			--- 2 desbloqueio - 1 bloqueia
				WHERE  --CTT_DTEXIS >= '20190118'AND 
				CTT_CUSTO IN (@centro_custo)
				AND CTT_BLOQ = '1'

			--CENTRO DE CUSTO INATIVO
				UPDATE CTT010
				SET
					CTT_STATUS = 'A'			--- A Ativo - I Inativo
				WHERE  --CTT_DTEXIS >= '20190118'AND 
				CTT_CUSTO IN (@centro_custo)
				AND CTT_STATUS = 'I'

			SELECT CTT_TX_GER, CTT_CLVL, *
			FROM CTT010
			WHERE  D_E_L_E_T_ = ''
			and CTT_CUSTO = @centro_custo

		END
--****************************************************************************
	GO


--****************************************************************************
--			BLOCO PARA CONSULTAR AS COBRANCAS NO LYCEUM						--
--****************************************************************************
USE LYCEUM
go	
	--****************************************************************************
	--		IDENTIFICAR O CENTRO DE CUSTO / CUSTO ATIVIDADE / CLASSE VALOR		--
	--****************************************************************************
	BEGIN
		DECLARE @cobranca T_NUMERO

		SET @cobranca = 207774

	
		SELECT DISTINCT TURMA, 
						CENTRO_DE_CUSTO,
						CTT_CATIV,
						CTT_CLVL
		FROM   LY_TURMA tu
			inner join DADOSADVP12.dbo.CTT010 ct 
				on CENTRO_DE_CUSTO = ct.CTT_CUSTO collate Latin1_General_CI_AI 
		WHERE  TURMA = (SELECT DISTINCT TURMA 
						FROM   VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA 
						WHERE  ALUNO IN(SELECT ALUNO 
										FROM   LY_COBRANCA 
										WHERE  COBRANCA =  @cobranca))  
	END

	GO

	

	--************************************************************************
	--	VERIFICAR OS LANÇAMENTOS DOS ITENS DA COBRANCA DÉBITO E CREDITO		--
	--************************************************************************
	
	use LYCEUM	
	go
	BEGIN
		DECLARE @cobranca T_NUMERO

		SET @cobranca = 200173   ---DIGITTE O NÚMERO DA COBRANÇA

		--lancamentos dos débitos da cobrança

		SELECT DT_ENVIO_CONTAB, *
		FROM lyceum.dbo.LY_ITEM_LANC
		WHERE COBRANCA IN (@cobranca)


		--lancamentos dos créditos da cobrança

		SELECT DT_ENVIO_CONTAB, *
		FROM LY_ITEM_CRED
		WHERE COBRANCA in (@cobranca)
	

		-- CONSULTA AUXILIAR 
		SELECT 
			* 
		FROM 
			VW_FCAV_BOLETOS_EMITIDOS_CONTAB 
		WHERE COBRANCA = @cobranca
	END
GO


	--************************************************************************
	-- PREENCHE A DATA CONTABIL PARA O DÉBITO NÃO IR NA IMPORTAÇÃO
	--************************************************************************
	BEGIN 
		UPDATE Lyceum.dbo.LY_ITEM_LANC
		SET
				DT_ENVIO_CONTAB = '2020-01-09 00:00:00.000'
		WHERE
			 COBRANCA in(205445)
		AND DT_ENVIO_CONTAB IS  NULL
		--AND ITEMCOBRANCA IN (1,2,3,4)
	END
GO


	--************************************************************************
	-- PREENCHE A DATA CONTABIL PARA O CRÉDITO NÃO IR NA IMPORTAÇÃO
	--************************************************************************
	BEGIN
		UPDATE LY_ITEM_CRED
		SET
			DT_ENVIO_CONTAB = '2020-01-09 00:00:00.000'
		WHERE
			COBRANCA in(205445)
		AND DT_ENVIO_CONTAB IS  NULL
	END
GO
	
	--************************************************************************
	-- UPDATE PARA PREENCHER A DESCRIÇÃO, VERIFICAR O TIPO LANÇAMENTO
	--************************************************************************
	
	--CASO O TIPO_ENCARGO SEJA ACRESCIMO
	UPDATE LY_ITEM_CRED
	SET	DESCRICAO = 'Acréscimo'
	WHERE
		DT_ENVIO_CONTAB IS NULL 
		AND COBRANCA in (187111)
		AND ITEMCRED = 3
		AND TIPO_ENCARGO = 'Acréscimo'
		AND DESCRICAO IS NULL

	--CASO O TIPODESCONTO SEJA CONCEDIDO
	UPDATE LY_ITEM_CRED
	SET DESCRICAO = 'Desconto Concedido'
	WHERE 
		DESCRICAO IS NULL
		AND TIPODESCONTO = 'Concedido'
		AND COBRANCA in (187111)
		AND ITEMCRED = 3

	--CASO O TIPODESCONTO SEJA ACRESCIMO
	UPDATE LY_ITEM_CRED
	SET DESCRICAO = 'Acréscimo'
	WHERE 
		DESCRICAO IS NULL
		AND TIPODESCONTO = 'Acréscimo'
		AND COBRANCA in (187111)
		AND ITEMCRED = 3

GO
