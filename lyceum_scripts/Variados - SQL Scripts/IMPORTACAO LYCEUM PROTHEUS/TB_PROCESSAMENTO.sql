/*
	TABELA TB_PROCESSAMENTO
	
	Descri��o: 
	
	Finalidade: 
	
	DATA: 25/10/2017
	
*/
USE FCAV_IMPORTACAO
GO

CREATE TABLE TB_PROCESSAMENTO (
	PRC_DATA_PROC  	VARCHAR	(8)	,
	PRC_LOTE		VARCHAR	(6)	,
	PRC_DOC  		VARCHAR	(6)	,
	PRC_FILIAL		VARCHAR	(2)	,
	PRC_LINHA  		VARCHAR	(3)	,
	PRC_MOEDA		VARCHAR	(2)	,
	PRC_TIPO_LANC	VARCHAR	(1)	,
	PRC_CONTA_DEB	VARCHAR	(20)	,
	PRC_CONTA_CRED	VARCHAR	(20)	,
	PRC_VALOR		FLOAT	(8)	,
	PRC_ORIGEM		VARCHAR	(100)	,
	PRC_HISTORICO	VARCHAR	(40)	,
	PRC_CC_DEB		VARCHAR	(9)	,
	PRC_CC_CRED		VARCHAR	(9)	,
	PRC_ITEM_CONTAB_DEB		VARCHAR	(9)	,
	PRC_ITEM_CONTAB_CRED	VARCHAR	(9)	,
	PRC_CLASSE_VALOR_DEB	VARCHAR	(9)	,
	PRC_CLASSE_VALOR_CRED	VARCHAR	(9)	,
	PRC_COD_CAV		VARCHAR	(18)	,
	PRC_LOJA_CLIENTE	VARCHAR	(2)	,
	PRC_COD_FORNEC		VARCHAR	(6)	,
	PRC_LOJA_FORNEC		VARCHAR	(2)	
)