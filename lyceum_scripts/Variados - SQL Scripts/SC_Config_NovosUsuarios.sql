SELECT 
	DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(LEFT(LTRIM(RTRIM(replace(NOME,'.',' '))),1)) +'.'+
	DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(REVERSE(SUBSTRING(REVERSE(LTRIM(RTRIM(replace(NOME,'.',' ')))),0 ,
								   CHARINDEX(' ',REVERSE(LTRIM(RTRIM(replace(NOME,'.',' ')))))))) as USUARIO,
	NOME,
	dbo.Decrypt(SENHA)SENHA,
	*
FROM 
	HD_USUARIO 
WHERE 
	HABILITADO = 'S'
	AND SIS = 'Lyceum'
	
	

	
SELECT 
	@pessoa = PESSOA,
	
	@login = LOWER(LEFT(LTRIM(RTRIM(replace(nome_compl,'.',' '))), CHARINDEX(' ',LTRIM(RTRIM(replace(nome_compl,'.',' '))))-1) +'.'+
			  REVERSE(SUBSTRING(REVERSE(LTRIM(RTRIM(replace(nome_compl,'.',' ')))),0 , CHARINDEX(' ',REVERSE(LTRIM(RTRIM(replace(nome_compl,'.',' ')))))))), --O login é composto do "nome.ultimonome"
	
	@senha = UPPER(SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('SHA1', CPF)), 3, 40))		--atribui a senha o CPF criptografado em SHA1
FROM 
	LY_PESSOA 
WHERE 
	NOME_COMPL LIKE @nome_pessoa
	OR PESSOA = @pessoa

	

