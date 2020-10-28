select 
ca.SIT_CANDIDATO_VEST,
ca.candidato,
fc.CONVOCADO,
al.SIT_ALUNO,
al.*

 from
ly_aluno al
left join LY_CANDIDATO ca
	on ca.candidato = al.CANDIDATO
left join FCAV_CANDIDATOS fc
	on fc.CANDIDATO = ca.CANDIDATO
left join LY_CONVOCADOS_VEST cv
	on cv.CANDIDATO = ca.CANDIDATO
where
	ca.CONCURSO = 'CCAN T 15'
ORDER BY CA.CANDIDATO


 select * from VW_FCAV_INI_FIM_CURSO_TURMA where turma = 'ceai t 28 sab'
	TURMA = 'CCAN T 15'