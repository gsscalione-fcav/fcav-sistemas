/*
		VIEW VW_FCAV_RESUMO_INSC_GERAL

	Finalidade: Trazer o resumo das inscrições de todas as inscrições do Lyceum realizadas 
				a partir de 2014.

Autor: Gabriel S Scalione
Data: 2021-02-12

*/

CREATE VIEW VW_FCAV_RESUMO_INSC_GERAL
AS

	SELECT distinct
		CS.CURSO,
	    oc.CONCURSO, 
	    oc.NOME_CURSO, 
		oc.DATA_INICIAL, 
		oc.DATA_FIM,
		oc.INICIO_DO_CURSO, 
	    oc.DIAS_RESTANTES,  
	    -- 
	    CASE WHEN CONVERT(DATETIME, oc.DATA_FIM, 103) < getdate() THEN 'S' 
	                                                              ELSE 'N' 
	    END AS oferta_vencida, 
	    -- 
	    COUNT(COD_INSCR) AS inscricoes_periodo, 
	    -- 
	    SUM( 
	        CASE WHEN insc.SELEC_COORD = 'Nao_Avaliado' 
				 AND insc.SIT_CANDIDATO != 'Cancelado'
				THEN 1 ELSE 0 
	        END 
	    ) AS coord_nao_avaliados, 
	    -- 
	    SUM( 
	        CASE WHEN insc.SELEC_COORD = 'Selecionado'
				AND insc.SIT_CANDIDATO != 'Cancelado'
	            THEN 1 ELSE 0 
	        END 
	    ) AS coord_selecionados, 
	    -- 
	    SUM( 
	        CASE insc.SELEC_COORD 
	            WHEN 'Recusado' THEN 1 
	                     ELSE 0 
	        END 
	    ) AS coord_recusados, 
	    -- 
	    SUM( 
	        CASE WHEN  insc.SELEC_COORD    =  'Selecionado' 
	               AND insc.SIT_CONVOCADO  =  'NÃO CONVOCADO'
				   AND insc.SIT_CANDIDATO !=  'Cancelado'	
				 THEN 1 ELSE 0 
	        END 
	    ) AS sec_nao_processados, 
	    -- 
	    SUM( 
	        CASE WHEN insc.SELEC_COORD = 'CONVOCADO'
				AND insc.SIT_CANDIDATO != 'Cancelado'
				THEN 1 ELSE 0 
	        END 
	    ) AS sec_convocados, 
	    -- 
	    SUM( 
	        CASE WHEN insc.SIT_CANDIDATO = 'Cancelado' 
				THEN 1 ELSE 0 
	        END +
			CASE WHEN insc.SIT_ALUNO = 'Cancelado' 
				and insc.SIT_CANDIDATO != 'Cancelado' 
				THEN 1 ELSE 0
			 END
	    ) AS sec_cancelados, 
	    
	    SUM( 
	        CASE WHEN insc.SIT_MATRICULA = 'Pre-Matriculado' 
				AND VALOR_PAGAR > 0.00
				and insc.SIT_CANDIDATO != 'Cancelado'
				THEN 1 ELSE 0 
	        END 
	    ) AS sec_prematriculado,

		sum(
			--Vouchers
			case when (insc.SIT_MATRICULA = 'Matriculado' 
					OR  insc.SIT_MATRICULA = 'Pre-Matriculado' )
					AND DESCONTO = 100.00
					AND DESC_PERC_VALOR = 'Percentual'
					AND VALOR_PAGAR = 0.00
					AND insc.SIT_CANDIDATO != 'Cancelado' 
			  then 1 else 0
			end 
			+
			--Bolsistas
			case when (insc.SIT_MATRICULA = 'Matriculado' 
					OR  insc.SIT_MATRICULA = 'Pre-Matriculado' )
					AND VALOR = 1
					AND PERC_VALOR = 'Percentual'
					AND insc.SIT_CANDIDATO != 'Cancelado' 
			  then 1 else 0
			end
			+
			--Cursos Gratuitos
			case when (insc.SIT_MATRICULA = 'Matriculado' 
					OR  insc.SIT_MATRICULA = 'Pre-Matriculado' )
					AND VALOR_PAGAR = 0 
					AND VALOR = NULL
					AND PERC_VALOR = NULL
					AND DESCONTO = null
					AND DESC_PERC_VALOR = NULL
					AND insc.SIT_CANDIDATO != 'Cancelado' 
				
			  then 1 else 0
			end
			+
			--Cursos Gratuitos
			case when (insc.SIT_MATRICULA = 'Matriculado' 
					OR  insc.SIT_MATRICULA = 'Pre-Matriculado' )
					AND INSC.CURSO = 'A-DS'
					AND VALOR_PAGAR = 0 
			  then 1 else 0
			end
		) as sec_matr_bolsistas_100,
		
		sum(
			case when insc.SIT_MATRICULA = 'Matriculado' 
					AND VALOR_PAGAR > 0.00
					AND insc.SIT_CANDIDATO != 'Cancelado' 
			  then 1 else 0
			end 
		) as sec_matriculados_pagantes,
		
		sum(
			case when (insc.SIT_MATRICULA = 'Matriculado' and  oc.TIPO_INSCRICAO = 'PS') 
					  or (insc.SIT_ALUNO != 'Cancelado' and oc.TIPO_INSCRICAO = 'VD')  
				then cast(isnull(VALOR_PAGAR,0) as decimal(10,2))
			  else 0
			end 
		) as sec_total_pagar

	FROM LY_OFERTA_CURSO CS
		inner join VW_FCAV_LINK_OFERTA_CURSO_COMPLETA oc
			ON CS.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO

		LEFT JOIN FCAV_APOIOWEB_INGRESSANTES insc 
			ON INSC.CONCURSO = OC.CONCURSO
			AND INSC.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO
	WHERE CS.ANO_INGRESSO>=2018
	GROUP BY oc.INICIO_DO_CURSO,oc.DATA_INICIAL, oc.DATA_FIM, oc.DIAS_RESTANTES, CS.curso,
	oc.CONCURSO, oc.NOME_CURSO