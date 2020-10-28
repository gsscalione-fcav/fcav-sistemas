/*
	Essa consulta é a original do campo de parametro de Unidade/Empresa/Mantenedora do processo de geração de RPS.
	Foi alterado para que traga somente a empresa FCAV, para facilitar o departamento financeiro.

	Gabriel S Scalione 
	02/05/2019
*/
Select COD,DESCR from(SELECT FACULDADE cod, NOME_COMP descr, 'Unidade' TIPO FROM VW_UNIDADE_FISICA Union Select EMPRESA cod,NOME descr,'Empresa' TIPO FROM LY_EMPRESA )t Where tipo='%%Tipo%%'