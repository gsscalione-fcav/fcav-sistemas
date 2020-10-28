
/*
	VIEW VW_FCAV_IGPM_TURMA

	Finalidade: Traz o IGPM que será aplicado na turma, utilizando como base o índice do 12ª mês, aplicado na 13ª mensalidade.

Autor: Gabriel S Scalione
Data: 14/09/2020
*/


CREATE VIEW VW_FCAV_IGPM_TURMA
AS
	WITH    
		 tu AS(    
		  SELECT    
		   tu.CURSO, tu.TURNO, tu.TURMA,    
		   --    
		   MIN(    
			CONVERT(VARCHAR, tu.ANO) + '/' + CONVERT(VARCHAR, tu.SEMESTRE)    
		   ) AS ANO_SEMESTRE_INICIO,    
		   --    
		   MIN(tu.DT_INICIO) AS DT_INICIO    
		  FROM dbo.LY_TURMA tu
			where tu.UNIDADE_RESPONSAVEL = 'ESPEC'
		  GROUP BY tu.CURSO, tu.TURNO, tu.TURMA    
		 )    
		SELECT DISTINCT
		 TU.TURMA, 
		 TU.ANO_SEMESTRE_INICIO,
		 TU.DT_INICIO,
		 --COR.ANO, 
		 --COR.MES,  
	  --   COR.VALOR,    
		 COR_ANT.ANO,
		 COR_ANT.MES,
		 COR_ANT.VALOR INDICE
		FROM    
		 dbo.LY_LANC_DEBITO ld,    
		 tu    
		  LEFT OUTER JOIN LY_CORRECAO COR    
		  ON(    
			COR.ANO = YEAR(TU.DT_INICIO) + 1    
		   AND COR.MES = MONTH(TU.DT_INICIO)    
		  )    
		  --    
		  LEFT OUTER JOIN LY_CORRECAO COR_ANT    
		  ON(    
			COR_ANT.ANO = CASE WHEN MONTH(TU.DT_INICIO) = 1 THEN YEAR(TU.DT_INICIO)
							ELSE YEAR(TU.DT_INICIO) + 1 END
		   AND COR_ANT.MES = CASE WHEN MONTH(TU.DT_INICIO) = 1 THEN 12 
							ELSE MONTH(DATEADD(mm, -1, TU.DT_INICIO)) END
		  )    
		WHERE   
			tu.ANO_SEMESTRE_INICIO = CONVERT(VARCHAR, ld.ANO_REF) + '/' + CONVERT(VARCHAR, ld.PERIODO_REF)    

