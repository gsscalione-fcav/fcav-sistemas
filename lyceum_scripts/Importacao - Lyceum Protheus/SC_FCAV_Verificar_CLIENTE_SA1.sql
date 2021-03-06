USE LYCEUM
GO


DECLARE @DATA_INI DATE
DECLARE @DATA_FIM DATE   

SET @DATA_INI = cast((GETDATE()- 45) as date)
SET @DATA_FIM = cast((GETDATE()+ 90) as date) 


SELECT DISTINCT
 ISNULL (CASE WHEN RESP.CPF_TITULAR IS NULL  
  THEN RESP.CGC_TITULAR  
  ELSE RESP.CPF_TITULAR END,'')					AS COD_CAV,  
  
 ISNULL (RESP.CPF_TITULAR,'')					AS CPF,  
 ISNULL (RESP.CGC_TITULAR,'')					AS CNPJ,  
 '01'											AS LOJA,  
 DBO.FN_FCAV_Remove_Acento(ISNULL 
	(REPLACE(CONVERT(VARCHAR,ltrim(RESP.TITULAR),40),';',',')
		,'')				)					AS NOME,
 DBO.FN_FCAV_Remove_Acento(ISNULL 
	(REPLACE(CONVERT(VARCHAR,ltrim(RESP.TITULAR),20),';',',')
		,'')				)					AS NOME_FANT,  
 ISNULL 
	(REPLACE((LTRIM(RESP.ENDERECO)+', '+RESP.END_NUM),';',',') 
		,'')									AS ENDERECO,  
 'F'											AS TIPO_CLI,  
 ISNULL (CASE WHEN MUN.UF = '00' THEN 'SP'
			ELSE MUN.UF END ,'')				AS ESTADO,  
 ISNULL (CASE WHEN MUN.UF = '00' THEN 'SAO PAULO'
		 ELSE REPLACE(MUN.NOME,';',',')
		 END ,'')								AS CIDADE,  
 
 ISNULL (RESP.CEP ,'')							AS CEP,  
 ISNULL (CASE WHEN RESP.CEP = '00000000' THEN 'NAO INFORMADO'
			ELSE REPLACE(RESP.BAIRRO,';',',')END 
			,'')								AS BAIRRO,  
 DBO.FN_FCAV_Remove_Acento(ISNULL 
	(REPLACE(CONVERT(VARCHAR,ltrim(RESP.TITULAR),40),';',',')
		,'')			)						AS CONTATO,  
 ISNULL (CASE WHEN RESP.CPF_TITULAR IS NULL THEN '501'  
			ELSE '504' END,'')					AS NATUREZA  
  
 FROM  
  LY_ALUNO AS ALU  
 LEFT JOIN LY_PESSOA AS PES ON (ALU.PESSOA=PES.PESSOA)  
 LEFT JOIN LY_COBRANCA AS COB ON (ALU.ALUNO = COB.ALUNO)  
 LEFT JOIN LY_CURSO AS CUR ON (COB.CURSO = CUR.CURSO)  
 LEFT JOIN LY_ITEM_CRED AS ICRED ON (COB.COBRANCA = ICRED.COBRANCA )--AND TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL)  
 LEFT JOIN LY_ITEM_LANC AS ILAN ON (COB.COBRANCA = ILAN.COBRANCA)  
 LEFT OUTER JOIN LY_BOLETO AS BOL ON (ILAN.BOLETO = BOL.BOLETO AND BOL.BOLETO IS NOT NULL)  
 LEFT OUTER JOIN LY_RESP_FINAN AS RESP ON (COB.RESP = RESP.RESP)  
 LEFT OUTER JOIN HADES.dbo.HD_MUNICIPIO AS MUN ON (RESP.END_MUNICIPIO = MUN.MUNICIPIO)  
 LEFT OUTER JOIN FCAV_IMPCONT_CAD AS FCAD ON (ALU.TURMA_PREF = FCAD.TURMA) -- OR T.TURMA = FCAD.TURMA OR HIST.TURMA = FCAD.TURMA) 
  
WHERE  
-- *** SE CASO N�O HOUVER REGISTROS DE CR�DITOS, O FILTRO SER� NO FATURAMENTO  
--ALU.ALUNO = 'C201700389'
 ILAN.DATA >= @DATA_INI  
AND ILAN.DATA <= (select cast(@data_fim as varchar)+' 23:59:59.000') 
AND RESP.CGC_TITULAR = '61160438001101'
  
--  ***** FINAL DO COMENT�RIO DOS DADOS DA SA1  



SELECT A1_XCODCAV, * FROM DADOSADVP12.dbo.SA1010 SA
				where sa.A1_CGC = '61160438001101'