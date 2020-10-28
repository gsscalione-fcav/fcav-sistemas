SELECT
			    insc.CONCURSO,
			    insc.CANDIDATO, insc.NOME_COMPL, insc.E_MAIL,
			    insc.DT_INSCRICAO, insc.OBS,
			    CASE WHEN ly_cand.SIT_CANDIDATO_VEST = 'Cancelado' THEN ly_cand.SIT_CANDIDATO_VEST  
				 	  WHEN mat.SIT_ALUNO NOT LIKE 'Cancelado' THEN mat.SIT_MATRICULA 
				 END SIT_MATRICULA, 
			    ly_cand.FL_FIELD_02, ly_cand.FL_FIELD_03,
			    ly_cand.DT_INSCRICAO as candidato_dt_inscr,
			    cand.DATA_CONV, cand.DATA_SECRET, cand.PESSOA, cand.CONVOCADO, cand.DATA_INSC,
				CASE WHEN conv.MATRICULADO IS NULL 
						AND (MAT.SIT_MATRICULA = 'Matriculado' or MAT.SIT_MATRICULA = 'Pre-Matriculado') THEN 'S'
					ELSE conv.MATRICULADO
				END AS MATRICULADO
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
			    insc.CONCURSO='CCGQP T 06'
		
			ORDER BY insc.NOME_COMPL