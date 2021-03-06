/*
	TABELA TB_IMPORTACAO
	
	Descri��o: 
	
	Finalidade: 
	
	DATA: 25/10/2017
	
*/
USE FCAV_IMPORTACAO
GO

CREATE TABLE TB_IMPORTACAO (
	IMP_DATA_PROC  	VARCHAR	(8)	,
	IMP_LOTE		VARCHAR	(6)	,
	IMP_DOC  		VARCHAR	(6)	,
	IMP_FILIAL		VARCHAR	(2)	,
	IMP_LINHA  		VARCHAR	(3)	,
	IMP_MOEDA		VARCHAR	(2)	,
	IMP_TIPO_LANC	VARCHAR	(1)	,
	IMP_CONTA_DEB	VARCHAR	(20)	,
	IMP_CONTA_CRED	VARCHAR	(20)	,
	IMP_VALOR		FLOAT	(8)	,
	IMP_ORIGEM		VARCHAR	(100)	,
	IMP_HISTORICO	VARCHAR	(40)	,
	IMP_CC_DEB		VARCHAR	(9)	,
	IMP_CC_CRED		VARCHAR	(9)	,
	IMP_ITEM_CONTAB_DEB		VARCHAR	(9)	,
	IMP_ITEM_CONTAB_CRED	VARCHAR	(9)	,
	IMP_CLASSE_VALOR_DEB	VARCHAR	(9)	,
	IMP_CLASSE_VALOR_CRED	VARCHAR	(9)	,
	IMP_COD_CAV		VARCHAR	(18)	,
	IMP_LOJA_CLIENTE	VARCHAR	(2)	,
	IMP_COD_FORNEC		VARCHAR	(6)	,
	IMP_LOJA_FORNEC		VARCHAR	(2)	
)