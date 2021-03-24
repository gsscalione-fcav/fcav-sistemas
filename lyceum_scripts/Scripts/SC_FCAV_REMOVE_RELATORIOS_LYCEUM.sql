
	select * from HD_RELATORIO where RELATORIO in ('FCAV_Atestado_CEAI','FCAV_Declaracao_CEAI','FCAV_Declaracao_CEAI_USP')
		
	select * from HD_PADREL where RELATORIO in ('FCAV_Atestado_CEAI','FCAV_Declaracao_CEAI','FCAV_Declaracao_CEAI_USP')

		delete HD_PADREL where RELATORIO in ('FCAV_Atestado_CEAI','FCAV_Declaracao_CEAI','FCAV_Declaracao_CEAI_USP')
		delete HD_RELATORIO where RELATORIO in ('FCAV_Atestado_CEAI','FCAV_Declaracao_CEAI','FCAV_Declaracao_CEAI_USP')