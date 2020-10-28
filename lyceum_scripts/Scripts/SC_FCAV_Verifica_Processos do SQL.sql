select spid, blocked, hostname=left(hostname,20), program_name=left(program_name,20),
       WaitTime_Seg = convert(int,(waittime/1000))  ,open_tran, status
From master.dbo.sysprocesses 
where blocked > 0
order by spid

--sp_lock

