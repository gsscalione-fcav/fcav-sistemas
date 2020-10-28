
/*
	CADASTRO DE LOGIN DE USUÁRIOS NO APOIOWEB

*/


--CASO SEJA COORDENADOR OU VICE, PEGAR O CPF NA LY_DOCENTE
SELECT NOME_COMPL,CPF,E_MAIL
FROM LY_DOCENTE
WHERE 
	NOME_COMPL = 'Fernando Garcia'

--VERIFICAR QUAL FOI O ÚLTIMO ID CADASTRADO
	SELECT 
		* FROM FCAV_WEBUSERS ORDER BY ID DESC
update FCAV_WEBUSERS 
set
	ID = 56
where "USER" = '37302382808'


USE LYCEUM
GO

INSERT INTO FCAV_WEBUSERS (ID,
    "USER",
    PASS,
    NOME,
    CARGO,
    EMAIL,
    STATUS,
    CODIGO_TOT,
    STATUS_TOT,
    GRUPO)
 VALUES (55,    								--ID,
    '37302382808',								--USER,
    'pro456',									--PASS,
    'Alvaro Marinho Marques',					--NOME,
    'Dep. Eng. de Produção',					--CARGO,
    'alvaro.marques@vanzolini.com.br',			--EMAIL,
    '2',										--STATUS,
    NULL,										--CODIGO_TOT,
    NULL,										--STATUS_TOT,
    NULL										--GRUPO
    )

