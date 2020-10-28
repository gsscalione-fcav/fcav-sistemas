
WITH INSCRITOS_TURMA 
AS 
(	
	SELECT 
			insc.CONCURSO, 
			insc.CANDIDATO, 
			insc.NOME_COMPL, 
			insc.E_MAIL, 
			insc.DT_INSCRICAO,
			insc.OBS, 
			CASE WHEN ly_cand.SIT_CANDIDATO_VEST = 'Cancelado' THEN ly_cand.SIT_CANDIDATO_VEST   
				 	WHEN mat.SIT_ALUNO NOT LIKE 'Cancelado' THEN mat.SIT_MATRICULA  
				END SIT_MATRICULA,  
			ly_cand.FL_FIELD_02, 
			ly_cand.FL_FIELD_03, 
			ly_cand.DT_INSCRICAO as Candidato_dt_inscr,
			cand.DATA_CONV, 
			cand.DATA_SECRET, 
			cand.PESSOA, 
			cand.CONVOCADO, 
			cand.DATA_INSC, 
			conv.MATRICULADO 
		FROM 
			dbo.VW_FCAV_INSCRITOS insc 
			    left outer join VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA2 mat 
			    on( 
			            mat.CANDIDATO = insc.CANDIDATO 
			        AND mat.CONCURSO  = insc.CONCURSO 
			    ) 
			    -- 
			    left outer join LY_CANDIDATO ly_cand 
			    on( 
			            ly_cand.CANDIDATO = insc.CANDIDATO 
			        AND ly_cand.CONCURSO  = insc.CONCURSO 
			    ) 
			    -- 
			    left outer join dbo.FCAV_CANDIDATOS cand 
			    ON( 
			            cand.CANDIDATO = insc.CANDIDATO 
			        AND cand.CONCURSO  = insc.CONCURSO 
			    ) 
			    -- 
			    left outer join dbo.LY_CONVOCADOS_VEST conv 
			    ON( 
			            conv.CANDIDATO = insc.CANDIDATO 
			        AND conv.CONCURSO  = insc.CONCURSO 
			    ) 
		WHERE 
			insc.CONCURSO='CELOG T 28'
	
	)

SELECT 
	CONCURSO,
	CANDIDATO,
	DT_INSCRICAO,
	DATA_INSC,
	Candidato_dt_inscr,
	case when Candidato_dt_inscr is null then 'X'
	end as conta_cancelado,
	
	case when SIT_MATRICULA is null then '0'
	else SIT_MATRICULA
	end as conta_NaoProcess

FROM INSCRITOS_TURMA



SELECT CONCURSO,
CANDIDATO,
NOME_COMPL,
SIT_CANDIDATO_VEST,
DT_INSCRICAO
FROM LY_CANDIDATO 
WHERE 
	--CANDIDATO IN ('201910126','201910170','201910173')
	CONCURSO = 'CELOG T 28' AND
	DT_INSCRICAO IS NULL
