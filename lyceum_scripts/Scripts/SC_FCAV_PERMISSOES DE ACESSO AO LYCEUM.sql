/*
	SC_FCAV_PERMISSOES DE ACESSO AO LYCEUM
*/


DECLARE @perfil VARCHAR (14)


SET @perfil = 'FCAV_EDUCACAO'

--------------------------------------------------------------------------------
-- CONSULTA PERMISSÕES DE ALTERAÇÃO, CADASTRO E REMOCAO DO PERFIL PARA TRANSAÇÕES
	SELECT * FROM HD_PADTRANS
	WHERE PADACES = @perfil
	AND (TRANS LIKE '%Desconto%'
	  OR TRANS LIKE '%Bolsa%'
	  OR TRANS LIKE '%Plano%'
	  OR TRANS LIKE '%Div%'
	  OR TRANS LIKE '%Cobran%'
	  OR TRANS LIKE '%Cálculo/Recálculo%'
	  OR TRANS LIKE '%TFIN%'
	  ) 
----------------------------------------------------------------------------------
---- CONSULTA PERMISSÕES DE ALTERAÇÃO, CADASTRO E REMOCAO DO PERFIL PARA PROCESSOS
--SELECT * FROM HD_PADPROC
--	WHERE PADACES = @perfil
--	AND (PROCESSO LIKE '%GeraArq%'
--	  OR PROCESSO LIKE '%Bolsa%'
--	  OR PROCESSO LIKE '%Plano%'
--	  OR PROCESSO LIKE '%Div%'
--	  OR PROCESSO LIKE '%Cobran%'
--	  OR PROCESSO LIKE '%TFIN%')
--------------------------------------------------
-- BLOQUEIO DE ACESSOS DAS TRANSACOES E PROCESSOS FINANCEIROS
	UPDATE HD_PADTRANS
	SET
		  PODEALT = 'N'
		, PODECAD = 'N'
		, PODEREM = 'N'
	WHERE 
		PADACES = @perfil
	AND (   PODEALT = 'S'
		 OR PODECAD = 'S'
		 OR PODEREM = 'S'
		)
	AND (TRANS LIKE '%Desconto%'
	  OR TRANS LIKE '%Bolsa%'
	  OR TRANS LIKE '%Plano%'
	  OR TRANS LIKE '%Div%'
	  OR TRANS LIKE '%Cobran%'
	  --OR TRANS NOT IN ('Planos de Estudo','Turma-Plano Didático')
	  OR TRANS LIKE '%Cálculo/Recálculo%'
	  OR TRANS LIKE '%TFIN%'
	  )


DELETE HD_PADPROC
	WHERE PADACES = @perfil
	AND (PROCESSO LIKE '%GeraArq%'
	  OR PROCESSO LIKE '%Bolsa%'
	  OR PROCESSO LIKE '%Plano%'
	  OR PROCESSO LIKE '%Div%'
	  OR PROCESSO LIKE '%Cobran%'
	  OR PROCESSO LIKE '%TFIN%')


SELECT 
	u.USUARIO,
	u.NOME,
	SIS,
	SETOR
FROM HD_PADUSUARIO P
	INNER JOIN HD_USUARIO U
		ON U.USUARIO = P.USUARIO
where u.HABILITADO = 'S'
	AND (SETOR like '%Edu%'
	 or SETOR like '%USP%'
	 or SETOR like '%Paulist%'
	 or SETOR like '%Secr%'
	 or SETOR like '%Atend%')



SELECT 
	u.USUARIO
FROM HD_PADUSUARIO P
	INNER JOIN HD_USUARIO U
		ON U.USUARIO = P.USUARIO
where u.HABILITADO = 'S'
	AND PADACES != 'FCAV_EDUCACAO'
	AND (SETOR like '%Edu%'
		or SETOR like '%USP%'
		or SETOR like '%Paulist%'
		or SETOR like '%Secr%'
		or SETOR like '%Atend%')