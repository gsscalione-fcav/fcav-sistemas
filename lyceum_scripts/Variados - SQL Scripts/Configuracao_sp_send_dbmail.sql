-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO

-- To update the currently configured value for this feature.
RECONFIGURE
GO

sp_configure 'show advanced options', 1 

GO 
RECONFIGURE; 
GO 
sp_configure 'Ole Automation Procedures', 1 
GO 
RECONFIGURE; 
GO 
sp_configure 'show advanced options', 1 
GO 
RECONFIGURE;


USE MASTER 
GO 
SP_CONFIGURE 'show advanced options', 1 
GO 
RECONFIGURE WITH OVERRIDE 
/* Enable Database Mail XPs Advanced Options in SQL Server */ 
go
SP_CONFIGURE 'Database Mail XPs', 1 
go
RECONFIGURE WITH OVERRIDE 
go
SP_CONFIGURE 'show advanced options', 0 
go
RECONFIGURE WITH OVERRIDE 

go
use msdb
go
exec sp_helptext sp_send_dbmail
