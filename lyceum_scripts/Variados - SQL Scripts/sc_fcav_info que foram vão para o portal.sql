SELECT CURSO_OFERTADO,
	   DTINI_OFERTA,
	   DTFIM_OFERTA,
	   TURMA,
	   ANO,
	   DT_INICIO,
	   DT_FIM,
	   SIT_TURMA,
	   DIA_HORARIO_AULAS,
	   LINK
FROM 
	VW_FCAV_INFO_CURSO_PORTAL 
where turma	in ('CEQP T 64', 'CEGP T 69', 'CEAI T 31', 'CCGO T 01')
and ANO = 2018

group by 
	CURSO_OFERTADO,
	DTINI_OFERTA,
	DTFIM_OFERTA,
	TURMA,
	ANO,
	DT_INICIO,
	DT_FIM,
	SIT_TURMA,
	DIA_HORARIO_AULAS,
	LINK
