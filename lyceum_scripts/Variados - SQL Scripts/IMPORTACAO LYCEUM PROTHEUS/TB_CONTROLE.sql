/*
	TABELA TB_CONTROLE
	
	Descri��o: Essa Tabela possui dados vindo da tabela CT2010, contabilidade do PROTHEUS.
	
	Finalidade: Ser� utilizada como controle dos t�tulos que j� foram importados com os t�tulos 
				da tabela TB_PROCESSAMENTO. Caso aprovadas v�o para a Tabela TB_IMPORTACAO.
	
	DATA: 25/10/2017
	
*/
USE FCAV_IMPORTACAO
GO

CREATE TABLE TB_CONTROLE (
	CRT_DATA_PROC  	VARCHAR	(8)	,
	CRT_LOTE		VARCHAR	(6)	,
	CRT_DOC  		VARCHAR	(6)	,
	CRT_FILIAL		VARCHAR	(2)	,
	CRT_LINHA  		VARCHAR	(3)	,
	CRT_MOEDA		VARCHAR	(2)	,
	CRT_TIPO_LANC	VARCHAR	(1)	,
	CRT_CONTA_DEB	VARCHAR	(20)	,
	CRT_CONTA_CRED	VARCHAR	(20)	,
	CRT_VALOR		FLOAT	(8)	,
	CRT_ORIGEM		VARCHAR	(100)	,
	CRT_HISTORICO	VARCHAR	(40)	,
	CRT_CC_DEB		VARCHAR	(9)	,
	CRT_CC_CRED		VARCHAR	(9)	,
	CRT_ITEM_CONTAB_DEB		VARCHAR	(9)	,
	CRT_ITEM_CONTAB_CRED	VARCHAR	(9)	,
	CRT_CLASSE_VALOR_DEB	VARCHAR	(9)	,
	CRT_CLASSE_VALOR_CRED	VARCHAR	(9)	,
	CRT_COD_CAV		VARCHAR	(18)	,
	CRT_LOJA_CLIENTE	VARCHAR	(2)	,
	CRT_COD_FORNEC		VARCHAR	(6)	,
	CRT_LOJA_FORNEC		VARCHAR	(2)	
)