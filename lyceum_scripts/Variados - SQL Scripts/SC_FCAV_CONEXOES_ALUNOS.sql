select 
	CONVERT(varchar, dt_login,112),	
	COUNT(aluno)
from 
	Ly_Log_Conexoes 
group by 
	CONVERT(varchar, dt_login,112)
	
order by COUNT(aluno) desc, CONVERT(varchar, dt_login,112)

