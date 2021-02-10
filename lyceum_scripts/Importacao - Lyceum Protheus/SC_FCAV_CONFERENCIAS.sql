
--****************************************************************************
-- 1 -- VERIFICAR ESTORNOS
--****************************************************************************
SELECT distinct 
	SUBSTRING(HISTORICO,CHARINDEX(' ',HISTORICO,1)+1,6) AS COBRANCA, *
FROM LYCEUM.DBO.FCAV_IMPORTCONTABIL 
WHERE SUBSTRING(HISTORICO,CHARINDEX(' ',HISTORICO,1)+1,6) IN 
(select distinct SUBSTRING(HISTORICO,CHARINDEX(' ',HISTORICO,1)+1,6) 
 from LYCEUM.DBO.FCAV_IMPORTCONTABIL where HISTORICO like '%estorno%')

 -- Verifica se há estornos na importação que precisam ir para o Protheus
SELECT distinct
	 SUBSTRING(CT2_HIST ,CHARINDEX(' ',CT2_HIST,1)+1,6) collate Latin1_General_CI_AI as cobranca,
	D_E_L_E_T_, CT2_DATA, CT2_LOTE, CT2_DOC,CT2_LINHA, CT2_DC,
	CT2_DEBITO,CT2_CREDIT, CT2_HIST,CT2_VALOR, CT2_CCD,CT2_CCC, R_E_C_N_O_
FROM LYCEUM.DBO.FCAV_IMPORTCONTABIL 
	left join DADOSADVP12.dbo.CT2010 
		on SUBSTRING(CT2_HIST ,CHARINDEX(' ',CT2_HIST,1)+1,6) = SUBSTRING(HISTORICO,CHARINDEX(' ',HISTORICO,1)+1,6) collate Latin1_General_CI_AI 
WHERE	--D_E_L_E_T_ = '' and
  CT2_DATA >= '20200101'
AND SUBSTRING(CT2_HIST ,CHARINDEX(' ',CT2_HIST,1)+1,6) 
	in (select distinct SUBSTRING(HISTORICO,CHARINDEX(' ',HISTORICO,1)+1,6) collate Latin1_General_CI_AI 
		from LYCEUM.DBO.FCAV_IMPORTCONTABIL where HISTORICO like '%estorno%')
AND			CT2_LOTE in ('008871','008870')
ORDER BY	CT2_LOTE,CT2_DOC DESC,CT2_LINHA
GO
--****************************************************************************
-- 2 -- CONFERE SE CREDITO E DEBITO BATEM
--****************************************************************************
begin
	WITH CONF_DEBITO 
	AS (SELECT
		  IMP_COBRANCA,
		  SUM(CAST(VALOR AS money)) AS VALOR 
		FROM LYCEUM.DBO.FCAV_IMPORT_DEB_CRED 
		WHERE TIPO_LANC = '1' 
		GROUP BY IMP_COBRANCA), 

		CONF_CRED
		AS (SELECT
		  IMP_COBRANCA,
		  SUM(CAST(VALOR AS money)) * -1 AS VALOR 
		FROM LYCEUM.DBO.FCAV_IMPORT_DEB_CRED
		 WHERE TIPO_LANC = '2' 
		GROUP BY IMP_COBRANCA), 

		CONF_SUM
		AS (SELECT
		  CD.IMP_COBRANCA,
		 SUM(ISNULL(CD.VALOR, '0,00') + ISNULL(CC.VALOR, '0,00')) AS CALC
		 FROM CONF_DEBITO CD
		LEFT OUTER JOIN CONF_CRED CC
		 ON CD.IMP_COBRANCA = CC.IMP_COBRANCA
		 GROUP BY CD.IMP_COBRANCA)

		SELECT
		  TEMP.* 
		FROM LYCEUM.DBO.FCAV_IMPORT_DEB_CRED TEMP 
		INNER JOIN CONF_SUM CONF
		  ON TEMP.IMP_COBRANCA = CONF.IMP_COBRANCA
		 WHERE CONF.CALC <> 0
end 
GO

--****************************************************************************
-- 3 -- VERIFICA SE TEM CLASSE VALOR CRED OU DEB EM BRANCO DE ACORDO COM O TIPO_LANC
--****************************************************************************
BEGIN
	SELECT SUBSTRING(HISTORICO,CHARINDEX(' ',HISTORICO,1)+1,6) as cobranca,* 
	FROM LYCEUM.DBO.FCAV_IMPORTCONTABIL  
	WHERE (TIPO_LANC = 3 AND CLASSE_VALOR_CRED = '' AND CLASSE_VALOR_DEB = '')
	   OR (TIPO_LANC = 2 AND CLASSE_VALOR_CRED = '')
	   OR (TIPO_LANC = 1 AND CLASSE_VALOR_DEB = '')
	   OR (CC_CRED ='' AND CC_DEB ='')  

END
GO

--****************************************************************************
-- 4 -- VERIFICA CENTRO DE CUSTO INATIVO / EXPIRADO / BLOQUEADO
--****************************************************************************
BEGIN
	SELECT CTT_TX_GER, CTT_CLVL, *
		FROM DADOSADVP12.dbo.CTT010
		WHERE  D_E_L_E_T_ = ''
		AND (CTT_BLOQ = '1' OR CTT_STATUS = 'I' OR CTT_DTEXSF < CONVERT(varchar,getdate(),112))
		AND CTT_CUSTO collate Latin1_General_CI_AI  IN (SELECT DISTINCT ISNULL(CC_DEB,CC_CRED) CENTRO_CUSTO
						  FROM LYCEUM.DBO.FCAV_IMPORTCONTABIL ) 
END
GO

	--****************************************************************************
	--		IDENTIFICAR O CENTRO DE CUSTO / CUSTO ATIVIDADE / CLASSE VALOR		--
	--****************************************************************************
BEGIN	
	DECLARE @cobranca numeric

	SET @cobranca = 214541			-- < -- Informe a cobrança

	SELECT DISTINCT TURMA, 
					CENTRO_DE_CUSTO,
					CTT_CATIV,
					CTT_CLVL
	FROM   LYCEUM.dbo.LY_TURMA tu
		left join DADOSADVP12.dbo.CTT010 ct 
			on CENTRO_DE_CUSTO = ct.CTT_CUSTO collate Latin1_General_CI_AI 
	WHERE  TURMA 
		like (SELECT DISTINCT NATUREZA 
			FROM   LYCEUM.dbo.LY_ITEM_LANC 
			WHERE  COBRANCA =  @cobranca)
END
GO				  
		--****************************************************************************
		--					LIBERACAO DO CENTRO DE CUSTO							--
		--****************************************************************************
BEGIN
		declare @centro_custo varchar(9)

		set @centro_custo = '313603003' -- INFORME O CENTRO DE CUSTO


		SELECT CTT_TX_GER, CTT_CLVL, *
		FROM DADOSADVP12.dbo.CTT010
		WHERE  D_E_L_E_T_ = ''
		and CTT_CUSTO = @centro_custo


		--CENTRO DE CUSTO VENCIDO
			UPDATE DADOSADVP12.dbo.CTT010
			SET
				CTT_DTEXSF = CONVERT(varchar,getdate()+1,112) ---Data de Vencimento
			WHERE CTT_CUSTO IN (@centro_custo)
			and CTT_DTEXSF < CONVERT(varchar,getdate(),112)

		--CENTRO DE CUSTO BLOQUEADO
			UPDATE DADOSADVP12.dbo.CTT010
			SET
				CTT_BLOQ = '2'			--- 2 desbloqueio - 1 bloqueia
			WHERE  --CTT_DTEXIS >= '20190118'AND 
			CTT_CUSTO IN (@centro_custo)
			AND CTT_BLOQ = '1'

		--CENTRO DE CUSTO INATIVO
			UPDATE DADOSADVP12.dbo.CTT010
			SET
				CTT_STATUS = 'A'			--- A Ativo - I Inativo
			WHERE  --CTT_DTEXIS >= '20190118'AND 
			CTT_CUSTO IN (@centro_custo)
			AND CTT_STATUS = 'I'

		SELECT CTT_TX_GER, CTT_CLVL, *
		FROM DADOSADVP12.dbo.CTT010
		WHERE  D_E_L_E_T_ = ''
		and CTT_CUSTO = @centro_custo
END
GO

--****************************************************************************
-- *** PESQUISA POR FATURAMENTO NO PROTHEUS ***
-- *** COLOCAR O NUMERO DA COBRANCA NO CAMPO CT2_HIST PARA PESQUISA ***
--****************************************************************************
	USE DADOSADVP12
	GO
	 SELECT 
	D_E_L_E_T_, CT2_DATA, CT2_LOTE, CT2_DOC,CT2_LINHA, CT2_DC,
	CT2_DEBITO,CT2_CREDIT, CT2_HIST,CT2_VALOR, CT2_CCD,CT2_CCC, R_E_C_N_O_
	 FROM		DADOSADVP12.dbo.CT2010
	 WHERE	--D_E_L_E_T_ = '' and
	  CT2_DATA >= '20190101'
	AND (  CT2_HIST LIKE '%210866%')
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



GO



--****************************************************************************
--			BLOCO PARA CONSULTAR AS CLIENTES SA1				--
--****************************************************************************

SELECT TOP 10 * FROM DADOSADVP12.dbo.SA1010 WHERE A1_XCODCAV = '61160438001101'

SELECT * FROM LYCEUM.dbo.LY_RESP_FINAN WHERE CGC_TITULAR ='61160438001101'
	

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
		WHERE COBRANCA in (211924)
	

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
				DT_ENVIO_CONTAB = '2020-09-25 00:00:00.000'
		WHERE
			 COBRANCA in(212952,212953)
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
			DT_ENVIO_CONTAB = '2020-09-07 00:00:00.000'
		WHERE
			COBRANCA in(211924)
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
