 IF EXISTS(SELECT * FROM SYS.views WHERE name = 'VW_FCAV_INI_FIM_CURSO_TURMA')
DROP VIEW dbo.VW_FCAV_INI_FIM_CURSO_TURMA
GO

--* ***************************************************************
--*
--*		*** VIEW VW_FCAV_INI_FIM_CURSO_TURMA ***
--*	
--*	DESCRICAO:
--*		- Traz as informações de data inicio e fim das turmas/cursos.
--*
--*	USO:
--*		- Auxiliar querys para geração de relatórios. 
--*
--*		SELECT * FROM VW_FCAV_INI_FIM_CURSO_TURMA WHERE CURSO = 'CEAI'
--*
--*	Autor: Gabriel
--*	Data de criação:	07/03/2014
--*
--* ***************************************************************

CREATE VIEW VW_FCAV_INI_FIM_CURSO_TURMA  
AS  
  
SELECT  
    OC.OFERTA_DE_CURSO,  
    (SELECT TOP 1  
        CASE  
            WHEN T2.CURSO IN ('ATUALIZACAO', 'PALESTRA') THEN (SELECT TOP 1 CURSO 
					 FROM LY_TURMA 
					 WHERE DISCIPLINA = T2.DISCIPLINA ORDER BY TURMA DESC)
            ELSE CS.CURSO
        END  
     FROM LY_TURMA T2
		INNER JOIN LY_CURSO CS
			ON CS.CURSO = T2.CURSO
    WHERE T2.TURMA = TU.TURMA
    ORDER BY T2.TURMA) AS CURSO,
	(SELECT TOP 1  
        CASE  
            WHEN T2.CURSO IN ('ATUALIZACAO', 'PALESTRA') THEN DI.NOME
            ELSE CS.NOME
        END  
     FROM LY_TURMA T2
		INNER JOIN LY_DISCIPLINA DI
			ON DI.DISCIPLINA = T2.DISCIPLINA
		INNER JOIN LY_CURSO CS
			ON CS.CURSO = T2.CURSO
    WHERE T2.TURMA = TU.TURMA
    ORDER BY T2.TURMA)   AS NOME_CURSO,
    TU.TURNO,  
    TU.CURRICULO,
	CASE WHEN TU.CURSO = 'CEAI' THEN 'USP'
	ELSE
		OC.UNIDADE_FISICA
	END AS UNIDADE_FISICA,
    CASE  
        WHEN oc.CONCURSO IS NULL THEN tu.TURMA  
        ELSE oc.CONCURSO  
    END AS CONCURSO,  
    CASE  
        WHEN oc.CONCURSO IS NULL THEN 'VD'  
        WHEN oc.CONCURSO IS NOT NULL THEN 'PS'  
    END AS TP_INGRESSO,  
    op.TURMA AS TURMA_PREF,  
    TU.CENTRO_DE_CUSTO,  
    TU.TURMA,  
    CAST(CAST(CR.AULAS_PREVISTAS AS int) AS varchar) + ' horas' AS CARGA_HORARIA,  
    MIN(tu.DT_INICIO) AS DT_INICIO,  
    MAX(tu.DT_FIM) AS DT_FIM,  
    TU.UNIDADE_RESPONSAVEL,  
    (SELECT TOP 1  
        CASE  
            WHEN CURSO IN ('ATUALIZACAO', 'PALESTRA') THEN 
					(SELECT TOP 1 CURSO 
					 FROM LY_TURMA 
					 WHERE DISCIPLINA = T2.DISCIPLINA ORDER BY TURMA DESC)  
            ELSE CURSO  
        END  
    FROM LY_TURMA T2  
    WHERE T2.TURMA = TU.TURMA)  
    AS COD_CURSO  
FROM LY_TURMA AS TU  
INNER JOIN LY_CURRICULO CR
	ON CR.CURRICULO = tu.CURRICULO
	AND CR.DT_EXTINCAO IS NULL
INNER JOIN LY_OPCOES_OFERTA OP  
    ON OP.TURMA = TU.TURMA
INNER JOIN LY_OFERTA_CURSO OC  
    ON OC.OFERTA_DE_CURSO = OP.OFERTA_DE_CURSO
	AND OC.CURRICULO = TU.CURRICULO

-------------------------------        
--Apenas para filtro        
--WHERE         
 --oc.OFERTA_DE_CURSO = 2024  
--TU.turma = 'CEAi T 20' 
--order by TU.DT_INICIO       
-------------------------------        
GROUP BY OC.OFERTA_DE_CURSO,  
         TU.CURSO,
		-- TU.FACULDADE,
         TU.TURNO,  
         TU.CURRICULO,
		 CR.CURRICULO,
		 CR.AULAS_PREVISTAS,  
         OP.TURMA,  
         OC.CONCURSO,  
         TU.CENTRO_DE_CUSTO,  
         TU.TURMA,  
         TU.UNIDADE_RESPONSAVEL,  
         OC.UNIDADE_FISICA
