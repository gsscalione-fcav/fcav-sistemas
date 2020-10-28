/*
	VIEW VW_FCAV_APOIOWEB_RESUMO_INSC

Finalidade: 

Autor: Gabriel S.S.
Data: 2019-03-21 09:11:51.670

SELECT * FROM VW_FCAV_APOIOWEB_RESUMO_INSC WHERE CONCURSO = 'CCGB T 59'
SELECT aluno, valor_pagar FROM VW_FCAV_APOIOWEB_INGRESSANTES WHERE CONCURSO = 'CCGB T 59' and sit_matricula = 'Matriculado'
SELECT aluno, valor_pagar FROM vw_fcaV_alunos_venda_direta WHERE  CONCURSO = 'A-GI T 01' and sit_matricula = 'Matriculado'
select aluno, valor_pagar from VW_FCAV_APOIOWEB_INSCRITOS_VENDA_DIRETA WHERE  CONCURSO = 'A-GI T 01' and sit_matricula = 'Matriculado' order by aluno
select * from ly_lanc_debito where aluno = 'C201900059'

*/

ALTER VIEW VW_FCAV_APOIOWEB_RESUMO_INSC
AS

	SELECT distinct
		CS.CURSO,
	    oc.CONCURSO, 
	    oc.NOME_CURSO, oc.DATA_INICIAL, oc.DATA_FIM,
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
		inner join VW_FCAV_LINK_OFERTA_CURSO oc
			ON CS.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO

		LEFT JOIN FCAV_APOIOWEB_INGRESSANTES insc 
			ON INSC.CONCURSO = OC.CONCURSO
			AND INSC.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO

	GROUP BY oc.INICIO_DO_CURSO,oc.DATA_INICIAL, oc.DATA_FIM, oc.DIAS_RESTANTES, CS.curso,
	oc.CONCURSO, oc.NOME_CURSO