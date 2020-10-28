/*
	INFORME O CÓDIGO DE PESSOA PARA ALTERAR O E-MAIL
	
/*e_mail		-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL, NULL, NULL, 'gabriel.scalione@vanzolini%', NULL, NULL	
/*e_mail		-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL, NULL, NULL, 'aluno@%', NULL, NULL	
	
UPDATE LY_PESSOA
SET
	E_MAIL = 'gabriel.scalione@vanzolini.com.br'
where
	PESSOA = 65
*/

DECLARE @pessoa T_NUMERO
DECLARE @monta_email NUMERIC
DECLARE @novo_email varchar(100)

set @pessoa = 111132

select pessoa,NOME_COMPL,e_mail from LY_PESSOA WHERE PESSOA = @pessoa

SELECT 
	
	@monta_email = case when CHARINDEX(' ',NOME_COMPL,1) = 0 then LEN(NOME_COMPL)
	else	CHARINDEX(' ',NOME_COMPL,1)-1
	end 
FROM
	LY_PESSOA
WHERE
	PESSOA = @pessoa

SELECT 
	@novo_email= lower(substring(REPLACE(NOME_COMPL,'é','e'),1,@monta_email))+'@testemail.com.br'
FROM
	LY_PESSOA
WHERE
	PESSOA = @pessoa


UPDATE LY_PESSOA
SET
	E_MAIL = @novo_email
where
	PESSOA = @pessoa


ALTER TABLE LY_CANDIDATO DISABLE TRIGGER ALL
UPDATE LY_CANDIDATO		
SET
	E_MAIL = @novo_email
WHERE
	PESSOA = @pessoa
	
ALTER TABLE LY_CANDIDATO ENABLE TRIGGER ALL


select pessoa,NOME_COMPL,e_mail from LY_PESSOA WHERE PESSOA = @pessoa