/*
	DELETE DEL_FCAV_CONTRATO_ATUALIZACAO
	
	Script para remover todos contratos vinculados aos cursos
	de Atualização, esse vinculo não existará mais, pois cursos de venda direta
	o contrato é salvo na tela Contrato Loja (TVEST055D.tp)
	
	Autor: Gabriel S.Scalione
	Data: 22/03/2017
*/

SELECT 
	* 
FROM 
	LY_CURRICULO_CONTRATO 
WHERE 
	CONTRATO IN (
'Contrato_ATUAL',
'Contrato_ATUAL_CERT',
'Contrato_BABrasil',
'Contrato_Venda_Diret',
'ContratoLoja'
)

DELETE
	LY_CURRICULO_CONTRATO 
WHERE 
	CONTRATO IN (
'Contrato_ATUAL',
'Contrato_ATUAL_CERT',
'Contrato_BABrasil',
'Contrato_Venda_Diret',
'ContratoLoja'
)



SELECT * FROM LY_CONTRATO
WHERE 
	CONTRATO IN (
'Contrato_ATUAL',
'Contrato_ATUAL_CERT',
'Contrato_BABrasil',
'Contrato_Venda_Diret',
'ContratoLoja'
)


DELETE LY_CONTRATO
WHERE 
	CONTRATO IN (
'Contrato_ATUAL',
'Contrato_ATUAL_CERT',
'Contrato_BABrasil',
'Contrato_Venda_Diret',
'ContratoLoja'
)

