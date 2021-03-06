
SELECT DISTINCT
    LY_DISCIPLINA.NOME_COMPL,
    LY_DISCIPLINA.DISCIPLINA,
    VW_FCAV_INI_FIM_CURSO_TURMA.CURSO,
    VW_FCAV_MONITOR_AULA.MONITOR_1,
    VW_FCAV_MONITOR_AULA.MONITOR_2,
    LY_CURSO.NOME,
    FCAV_LISTA_MATERIAL.MATERIAL,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.HORA_ENTRADA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.HORA_SAIDA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DIA_AULA,
	VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.NUM_AULA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.ANO,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.PERIODO,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DISCIPLINA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.SALA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DOCENTE
FROM (((((LYCEUM.dbo.VW_FCAV_CRONOGRAMA_TURMA_DOCENTE VW_FCAV_CRONOGRAMA_TURMA_DOCENTE
INNER JOIN LYCEUM.dbo.LY_DISCIPLINA LY_DISCIPLINA
    ON VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DISCIPLINA = LY_DISCIPLINA.DISCIPLINA)
LEFT OUTER JOIN LYCEUM.dbo.LY_CURSO LY_CURSO
    ON VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.CURSO = LY_CURSO.CURSO)
LEFT OUTER JOIN LYCEUM.dbo.VW_FCAV_VERIFICA_CENTRO_CUSTO VW_FCAV_VERIFICA_CENTRO_CUSTO
    ON VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.TURMA = VW_FCAV_VERIFICA_CENTRO_CUSTO.TURMA)
LEFT OUTER JOIN LYCEUM.dbo.FCAV_LISTA_MATERIAL FCAV_LISTA_MATERIAL
    ON (VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DISCIPLINA = FCAV_LISTA_MATERIAL.DISCIPLINA)
    AND (VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.NUM_AULA = FCAV_LISTA_MATERIAL.AULA))
LEFT OUTER JOIN LYCEUM.dbo.VW_FCAV_INI_FIM_CURSO_TURMA VW_FCAV_INI_FIM_CURSO_TURMA
    ON VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.TURMA = VW_FCAV_INI_FIM_CURSO_TURMA.TURMA)
LEFT OUTER JOIN LYCEUM.dbo.VW_FCAV_MONITOR_AULA VW_FCAV_MONITOR_AULA
    ON (VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.TURMA = VW_FCAV_MONITOR_AULA.TURMA)
    AND (VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.AGENDA = VW_FCAV_MONITOR_AULA.AGENDA)
WHERE VW_FCAV_INI_FIM_CURSO_TURMA.CURSO = 'CEAI'
	AND VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.ANO = 2018
	AND VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.PERIODO = 3
--	AND VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.TURMA = ''
	AND VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DISCIPLINA = 'CEAI-TCC'


GROUP BY

    LY_DISCIPLINA.NOME_COMPL,
    LY_DISCIPLINA.DISCIPLINA,
    VW_FCAV_INI_FIM_CURSO_TURMA.CURSO,
    VW_FCAV_MONITOR_AULA.MONITOR_1,
    VW_FCAV_MONITOR_AULA.MONITOR_2,
    LY_CURSO.NOME,
    FCAV_LISTA_MATERIAL.MATERIAL,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.HORA_ENTRADA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.HORA_SAIDA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DIA_AULA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.ANO,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.PERIODO,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DISCIPLINA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.SALA,
    VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.DOCENTE,
	VW_FCAV_CRONOGRAMA_TURMA_DOCENTE.NUM_AULA



