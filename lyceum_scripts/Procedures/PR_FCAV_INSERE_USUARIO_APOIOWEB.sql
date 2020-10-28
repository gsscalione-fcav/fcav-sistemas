IF EXISTS (SELECT
        *
    FROM SYS.procedures
    WHERE name = 'PR_FCAV_INSERE_USUARIO_APOIOWEB')
    DROP PROCEDURE PR_FCAV_INSERE_USUARIO_APOIOWEB
GO
--* ***************************************************************
--*
--*			*** PROCEDURE PR_FCAV_INSERE_USUARIO_APOIOWEB ***
--*	
--*	USO: 
--*     Inserir usuário para dar o acesso ao APOIOWEB
--*
--* Criado por: 
--*		Gabriel S. Scalione
--*		Data: 17/08/2017
--* ***************************************************************
CREATE PROCEDURE PR_FCAV_INSERE_USUARIO_APOIOWEB (
		
		@user varchar(12),
		@pass varchar(6),
		@nome varchar(50),
		@cargo varchar(50),
		@email varchar(50),
		@status varchar(4),
		@codigo_tot varchar(6),
		@status_tot varchar(4),
		@grupo varchar(10))
AS
BEGIN
	
	declare @id int

	SELECT @id = MAX(ID)+1 FROM FCAV_WEBUSERS
	
	set @codigo_tot = NULL
	set @status_tot = NULL

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
        VALUES (@id, @user, @pass, @nome, @cargo, @email, @status, @codigo_tot, @status_tot, @grupo)

END
GO