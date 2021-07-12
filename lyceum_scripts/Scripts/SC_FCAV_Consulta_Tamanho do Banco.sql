SP_SPACEUSED

SELECT name, database_id, create_date  
FROM sys.databases ;  

USE controle_dba 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use Temporario 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use DADOSADVP12 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use LYCEUM 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use HADES 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use LyceumMart 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use ReportServer 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use ReportServerTempDB 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use Kairos 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use LYCEUM_MEDIA 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use ECP_old 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use ECP_MEDIA 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use TAF 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

use ECP 
GO 
SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  

SP_SPACEUSED


SELECT file_id, name, type_desc, physical_name, size, max_size  
FROM sys.database_files ;  
GO  