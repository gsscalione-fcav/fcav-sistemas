SELECT 
    insc.CONCURSO, 
    insc.CANDIDATO, insc.NOME_COMPL, insc.E_MAIL, 
    insc.DT_INSCRICAO, insc.OBS,
    CASE WHEN ly_cand.SIT_CANDIDATO_VEST = 'Cancelado' THEN ly_cand.SIT_CANDIDATO_VEST
		 WHEN mat.SIT_ALUNO NOT LIKE 'Cancelado' THEN mat.SIT_MATRICULA
    END SIT_MATRICULA, 
    ly_cand.FL_FIELD_02, ly_cand.FL_FIELD_03, 
    cand.DATA_CONV, cand.DATA_SECRET, cand.PESSOA, cand.CONVOCADO, cand.DATA_INSC, 
    conv.MATRICULADO 
FROM 
    dbo.VW_FCAV_INSCRITOS insc 
      left outer join VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA2 mat 
      ON( 
              mat.CANDIDATO = insc.CANDIDATO 
          AND mat.CONCURSO  = insc.CONCURSO 
      ) 
      
      left outer join LY_CANDIDATO ly_cand 
      ON( 
              ly_cand.CANDIDATO = insc.CANDIDATO 
          AND ly_cand.CONCURSO  = insc.CONCURSO 
      ) 
      
      left outer join dbo.FCAV_CANDIDATOS cand 
      ON( 
              cand.CANDIDATO = insc.CANDIDATO 
          AND cand.CONCURSO  = insc.CONCURSO 
      ) 
      
      left outer join dbo.LY_CONVOCADOS_VEST conv 
      ON( 
              conv.CANDIDATO = insc.CANDIDATO 
          AND conv.CONCURSO  = insc.CONCURSO 
      ) 
WHERE 
    insc.CONCURSO='CELOG T 25' 

ORDER BY insc.NOME_COMPL



SELECT DBO.Decrypt('ÇV¢é3’¿Y¦ú?‚Ê]©EŠß,€ÅPžã')