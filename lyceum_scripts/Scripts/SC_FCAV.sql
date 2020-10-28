declare @apoioweb varchar(20)
set @apoioweb = 'apoioweb'

SELECT 
	ID,
	"USER",
	PASS,
	NOME,
	CARGO,
	EMAIL,
	STATUS,
	CODIGO_TOT,
	STATUS_TOT,
	GRUPO
FROM FCAV_WEBUSERS  FW
	INNER JOIN HD_TABELAITEM TI
		ON TI.ITEM = FW.STATUS
		AND TI.TABELA = 'PerfilAcessoApoioWeb'
WHERE 
	@apoioweb = @apoioweb
	
	
exec PR_FCAV_LISTA_APOIOWEB_USERS 'apoioweb'