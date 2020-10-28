use master
go
---1
sp_configure 'show advanced options', 1;

GO

RECONFIGURE;

GO

sp_configure 'Ole Automation Procedures', 1;

GO

RECONFIGURE;

GO

--2

GRANT EXECUTE ON sp_OACreate            TO lyceumsa
GRANT EXECUTE ON sp_OADestroy           TO lyceumsa
GRANT EXECUTE ON sp_OAGetErrorInfo      TO lyceumsa
GRANT EXECUTE ON sp_OAGetProperty       TO lyceumsa
GRANT EXECUTE ON sp_OAMethod            TO lyceumsa
GRANT EXECUTE ON sp_OASetProperty       TO lyceumsa
GRANT EXECUTE ON sp_OAStop              TO lyceumsa
GO


SELECT *
FROM sys.sysusers
WHERE name = 'lyceumsa'