/*-----------------------------------------------------------
CORRIGIR MAPEAMENTO PARA O BANCO LYCEUM
-----------------------------------------------------------*/
USE LYCEUM
BEGIN
	-- cronos
	EXEC sp_change_users_login 'Auto_Fix', 'cronos'
	-- lyceumsa
	EXEC sp_change_users_login 'Auto_Fix', 'lyceumsa'
	-- ApoioWeb
	EXEC sp_change_users_login 'Auto_Fix', 'ApoioWeb'
	-- crystal
	EXEC sp_change_users_login 'Auto_Fix', 'crystal'

	-- gabriel.scalione
	EXEC sp_change_users_login 'Auto_Fix', 'gabriel.scalione'
	-- jonatas.santos
	EXEC sp_change_users_login 'Auto_Fix', 'jonatas.santos'
	-- CERT_USR
	EXEC sp_change_users_login 'Auto_Fix', 'CERT_USR'

END
GO

/*-----------------------------------------------------------
CORRIGIR MAPEAMENTO PARA O BANCO LyceumMart
-----------------------------------------------------------*/
USE LyceumMart
BEGIN
	-- cronos
	EXEC sp_change_users_login 'Auto_Fix', 'cronos'
	-- lyceumsa
	EXEC sp_change_users_login 'Auto_Fix', 'lyceumsa'
	-- ApoioWeb
	EXEC sp_change_users_login 'Auto_Fix', 'ApoioWeb'
	-- crystal
	EXEC sp_change_users_login 'Auto_Fix', 'crystal'
	
	-- gabriel.scalione
	EXEC sp_change_users_login 'Auto_Fix', 'gabriel.scalione'
	-- jonatas.santos
	EXEC sp_change_users_login 'Auto_Fix', 'jonatas.santos'

END
GO

/*-----------------------------------------------------------
CORRIGIR MAPEAMENTO PARA O BANCO HADES
-----------------------------------------------------------*/
USE HADES
BEGIN
	-- cronos
	EXEC sp_change_users_login 'Auto_Fix', 'cronos'
	-- lyceumsa
	EXEC sp_change_users_login 'Auto_Fix', 'lyceumsa'
	-- ApoioWeb
	EXEC sp_change_users_login 'Auto_Fix', 'ApoioWeb'
	-- Crystal
	EXEC sp_change_users_login 'Auto_Fix', 'crystal'

	-- gabriel.scalione
	EXEC sp_change_users_login 'Auto_Fix', 'gabriel.scalione'
	-- jonatas.santos
	EXEC sp_change_users_login 'Auto_Fix', 'jonatas.santos'

END
GO

/*-----------------------------------------------------------
CORRIGIR MAPEAMENTO PARA O BANCO KAIROS
-----------------------------------------------------------*/
USE Kairos
BEGIN
	-- cronos
	EXEC sp_change_users_login 'Auto_Fix', 'cronos'
	-- lyceumsa
	EXEC sp_change_users_login 'Auto_Fix', 'lyceumsa'
	-- ApoioWeb
	EXEC sp_change_users_login 'Auto_Fix', 'ApoioWeb'
	-- Crystal
	EXEC sp_change_users_login 'Auto_Fix', 'crystal'

	-- gabriel.scalione
	EXEC sp_change_users_login 'Auto_Fix', 'gabriel.scalione'
	-- jonatas.santos
	EXEC sp_change_users_login 'Auto_Fix', 'jonatas.santos'

END



/*-----------------------------------------------------------
CORRIGIR MAPEAMENTO PARA O BANCO PROTHEUS
-----------------------------------------------------------*/
USE DADOSADVP12
BEGIN
	-- lyceumsa
	EXEC sp_change_users_login 'Auto_Fix', 'lyceumsa'
	-- gabriel.scalione
	EXEC sp_change_users_login 'Auto_Fix', 'gabriel.scalione'
END

/*-----------------------------------------------------------
CORRIGIR MAPEAMENTO PARA O BANCO LYCEUM_MEDIA
-----------------------------------------------------------*/
USE LYCEUM_MEDIA
BEGIN
	-- cronos
	EXEC sp_change_users_login 'Auto_Fix', 'cronos'
	-- lyceumsa
	EXEC sp_change_users_login 'Auto_Fix', 'lyceumsa'
	-- ApoioWeb
	EXEC sp_change_users_login 'Auto_Fix', 'ApoioWeb'
	-- Crystal
	EXEC sp_change_users_login 'Auto_Fix', 'crystal'

	-- gabriel.scalione
	EXEC sp_change_users_login 'Auto_Fix', 'gabriel.scalione'
	-- jonatas.santos
	EXEC sp_change_users_login 'Auto_Fix', 'jonatas.santos'
	-- CERT_USR
	EXEC sp_change_users_login 'Auto_Fix', 'CERT_USR'
END