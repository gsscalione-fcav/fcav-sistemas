	
		
		WITH tu
            AS (SELECT
				tu.UNIDADE_RESPONSAVEL,
                tu.CURSO,
                tu.TURNO,
                tu.TURMA,
                --  
                MIN(
                CONVERT(varchar, tu.ANO) + '/' + CONVERT(varchar, tu.SEMESTRE)
                ) AS ANO_SEMESTRE_INICIO,
                --  
                MIN(tu.DT_INICIO) AS DT_INICIO
            FROM dbo.LY_TURMA tu
            GROUP BY tu.CURSO,
                     tu.TURNO,
                     tu.TURMA,
				     tu.UNIDADE_RESPONSAVEL)
            SELECT  distinct
			 tu.TURMA,
			 tu.ANO_SEMESTRE_INICIO,
			 DT_INICIO,
			 YEAR(TU.DT_INICIO) + 1 ANO_IGPM,
			 MONTH(TU.DT_INICIO) MES_IGPM,
             COR.VALOR as IGPM
			 --,  COR_ANT.VALOR as IGPM_MESANTERIOR
            FROM dbo.LY_LANC_DEBITO ld,
                 tu
				 --
                 LEFT OUTER JOIN LY_CORRECAO COR
                     ON (
                     COR.ANO = YEAR(TU.DT_INICIO) + 1
                     AND COR.MES = MONTH(TU.DT_INICIO)
                     )
                 --  
                 LEFT OUTER JOIN LY_CORRECAO COR_ANT
                     ON (
                     COR_ANT.ANO = YEAR(DATEADD(mm, -1, TU.DT_INICIO)) + 1  
                     AND COR_ANT.MES = MONTH(DATEADD(mm, -1, TU.DT_INICIO))  
                     )
            WHERE tu.UNIDADE_RESPONSAVEL = 'ESPEC'
            AND tu.ANO_SEMESTRE_INICIO = CONVERT(varchar, ld.ANO_REF) + '/' + CONVERT(varchar, ld.PERIODO_REF)
			and year(DT_INICIO) >= 2018
		--	and COR.VALOR is not null
			order by turma, DT_INICIO,MONTH(TU.DT_INICIO)
			
