--pesquisar o nome do campo nas tabelas do sistema

SELECT distinct
*
 --T.name AS Tabela
FROM 
 sys.sysobjects    AS T (NOLOCK) 
 INNER JOIN sys.all_columns AS C (NOLOCK) 
	ON T.id = C.object_id 
	--AND T.XTYPE = 'U' 
WHERE 
 C.NAME LIKE '%CURRICULO_DESC%'
ORDER BY 
 T.name ASC

