USE LYCEUM
GO

UPDATE LY_PESSOA 
SET
	SENHA_TAC = dbo.Crypt(CPF)
WHERE
	PESSOA = 118080
	and SENHA_TAC IS NULL
GO


select *
from LY_PESSOA 

WHERE
	PESSOA = 121380
GO