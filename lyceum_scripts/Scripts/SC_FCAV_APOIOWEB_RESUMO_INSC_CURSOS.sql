	SELECT 
	    oc.CONCURSO, oc.DATA_FIM, CONVERT(DATETIME, '20/03/2019', 103) AS DT_FINAL,
	    oc.NOME_CURSO, oc.INICIO_DO_CURSO, 
	    oc.DIAS_RESTANTES,  
	    -- 
	    CASE WHEN CONVERT(DATETIME, oc.DATA_FIM, 103) < getdate() THEN 'S' 
	                                                              ELSE 'N' 
	    END AS oferta_vencida, 
	    -- 
	    COUNT(insc.CONCURSO) AS inscricoes_periodo, 
	    -- 
	    SUM( 
	        CASE 
	            WHEN 
					 insc.CONCURSO IS NOT NULL AND( 
	                    insc.CONVOCADO = '0' OR insc.CONVOCADO = '' OR 
	                    insc.CONVOCADO = ' ' OR insc.CONVOCADO IS NULL 
					 ) THEN 1 
	                  ELSE 0 
	        END 
	    ) AS coord_nao_avaliados, 
	    -- 
	    SUM( 
	        CASE insc.CONVOCADO 
	            WHEN '1' THEN 1 
	                     ELSE 0 
	        END 
	    ) AS coord_selecionados, 
	    -- 
	    SUM( 
	        CASE insc.CONVOCADO 
	            WHEN '2' THEN 1 
	                     ELSE 0 
	        END 
	    ) AS coord_recusados, 
	    -- 
	    SUM( 
	        CASE insc.MATRICULADO 
	            WHEN '0' THEN 1 
	                     ELSE 0 
	        END 
	    ) AS sec_nao_processados, 
	    -- 
	    SUM( 
	        CASE insc.MATRICULADO 
	            WHEN 'N' THEN 1 
	                     ELSE 0 
	        END 
	    ) AS sec_convocados, 
	    -- 
	    SUM( 
	        CASE 
	            WHEN 
					insc.CONCURSO IS NOT NULL AND( 
						insc.MATRICULADO = 'X' OR 
						insc.DT_INSCRICAO IS NULL 
					) THEN 1 
	                 ELSE 0 
	            END 
	    ) AS sec_cancelados, 
	    
	    SUM( 
	        CASE insc.MATRICULADO 
	            WHEN 'S' THEN 1 
	                     ELSE 0 
	        END 
	    ) AS sec_prematriculado 
	FROM 
		VW_FCAV_LINK_OFERTA_CURSO oc
	       LEFT OUTER JOIN VW_FCAV_INSCRITOS insc
	       ON( insc.CONCURSO  =  oc.CONCURSO )
	WHERE oc.DATA_INICIAL >= CONVERT(DATETIME, '01/11/2018', 103)
	   AND oc.DATA_FIM <=  CONVERT(DATETIME, '20/03/2019', 103)

	GROUP BY oc.CONCURSO, oc.DATA_FIM,oc.NOME_CURSO, oc.INICIO_DO_CURSO,oc.DIAS_RESTANTES
	ORDER BY oc.INICIO_DO_CURSO

