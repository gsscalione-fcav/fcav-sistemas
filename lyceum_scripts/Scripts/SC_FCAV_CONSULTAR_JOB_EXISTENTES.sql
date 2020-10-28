SELECT
    A.job_id,
    C.name AS job_name,
    E.name AS job_category,
    C.[enabled],
    C.[description],
    A.start_execution_date,
    A.last_executed_step_date,
    A.next_scheduled_run_date,
    CONVERT(VARCHAR, CONVERT(VARCHAR, DATEADD(SECOND, ( DATEDIFF(SECOND, A.start_execution_date, GETDATE()) % 86400 ), 0), 114)) AS time_elapsed,
    ISNULL(A.last_executed_step_id, 0) + 1 AS current_executed_step_id,
    D.step_name
FROM
    msdb.dbo.sysjobactivity                 A   WITH(NOLOCK)
    LEFT JOIN msdb.dbo.sysjobhistory        B   WITH(NOLOCK)    ON  A.job_history_id = B.instance_id
    JOIN msdb.dbo.sysjobs                   C   WITH(NOLOCK)    ON  A.job_id = C.job_id
    JOIN msdb.dbo.sysjobsteps               D   WITH(NOLOCK)    ON  A.job_id = D.job_id AND ISNULL(A.last_executed_step_id, 0) + 1 = D.step_id
    JOIN msdb.dbo.syscategories             E   WITH(NOLOCK)    ON  C.category_id = E.category_id
WHERE
    A.session_id = ( SELECT TOP 1 session_id FROM msdb.dbo.syssessions    WITH(NOLOCK) ORDER BY agent_start_date DESC ) 
    AND A.start_execution_date IS NOT NULL 
    AND A.stop_execution_date IS NULL
    
    
    