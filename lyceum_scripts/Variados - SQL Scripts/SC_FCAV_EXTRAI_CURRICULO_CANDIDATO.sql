
drop table #wrk

declare @candidato varchar (20)

set @candidato = '201635073'

SELECT
        
		ins.CANDIDATO,
		ins.CONCURSO,
        --
		CASE
            WHEN cv.PESSOA IS NULL
                THEN '/CURRICULO_NÃO_ANEXADO'
			ELSE
                '/Curriculos/' +
                pes.CPF + '_' +
                CONVERT(VARCHAR, ins.PESSOA, 20) +
                '.' +                         -- A partir da versão 7 não há terminação na extensão
                REPLACE(cv.EXTENSAO, '.', '') -- então, devemos retirar quando da versão 6 para trás
			END AS LINK_CV,
        --
        ins.PESSOA,
        --
        ins.DT_INSCRICAO AS DATA_INSC -- Pode ter sido inicializado na primeira parte desse script
                                      -- estando diferente de INSERTED
  INTO #wrk
	FROM
        LY_CANDIDATO ins
            LEFT OUTER JOIN LY_MINI_CURRICULO cv
            ON cv.PESSOA = ins.PESSOA
            --
            INNER JOIN LY_PESSOA pes
            ON pes.PESSOA = ins.PESSOA
            --
            LEFT OUTER JOIN dbo.FCAV_CANDIDATOS _cnd
            ON(
                    _cnd.CONCURSO  = ins.CONCURSO
                AND _cnd.CANDIDATO = ins.CANDIDATO
            )
			INNER JOIN LY_CONCURSO con 
			ON(
                    ins.CONCURSO  = con.CONCURSO
            )
    WHERE
       
		 ins.CANDIDATO = @candidato

    ----------------------------------------------------------------------------
    -- Insere novos registros --------------------------------------------------

    INSERT FCAV_CANDIDATOS(CANDIDATO, CONCURSO, LINK_CV, PESSOA, DATA_INSC)
    SELECT CANDIDATO, CONCURSO, LINK_CV, PESSOA, DATA_INSC
    FROM #wrk
    
drop table #wrk