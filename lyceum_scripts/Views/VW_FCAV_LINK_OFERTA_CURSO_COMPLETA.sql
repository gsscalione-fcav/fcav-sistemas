
IF OBJECT_ID('VW_FCAV_LINK_OFERTA_CURSO_COMPLETA', 'V') IS NOT NULL
    DROP VIEW VW_FCAV_LINK_OFERTA_CURSO_COMPLETA
GO

CREATE VIEW VW_FCAV_LINK_OFERTA_CURSO_COMPLETA
AS

SELECT
    CASE
        WHEN CURSO.FACULDADE = 'ATUAL' THEN 'Atualização'
        WHEN CURSO.FACULDADE = 'CAPAC' THEN 'Capacitação'
        WHEN CURSO.FACULDADE = 'ESPEC' THEN 'Especialização'
        WHEN CURSO.FACULDADE = 'PALES' THEN 'Palestra'
		WHEN CURSO.FACULDADE = 'DIFUS' THEN 'Palestra'
    END AS AREA,
    CASE
        WHEN OFERTA.CONCURSO IS NULL THEN V.TURMA
        ELSE OFERTA.CONCURSO
    END AS CONCURSO,
    OFERTA.OFERTA_DE_CURSO,
    CASE
        WHEN OFERTA.CONCURSO IS NULL THEN 'VD'
        ELSE 'PS'
    END AS TIPO_INSCRICAO,
    OFERTA.DESCRICAO_COMPL AS DESCRICAO,
    CASE
        WHEN OFERTA.DTINI IS NULL THEN '01/01/1900'
        ELSE CONVERT(varchar, OFERTA.DTINI, 103)
    END AS DATA_INICIAL,
    CASE
        WHEN OFERTA.DTFIM IS NULL THEN '01/01/1900'
        ELSE CONVERT(varchar, OFERTA.DTFIM, 103)
    END AS DATA_FIM,
    CASE
        WHEN V.DT_INICIO IS NULL THEN '01/01/1900'
        ELSE CONVERT(datetime, V.DT_INICIO)
    END AS INICIO_DO_CURSO,
    'https://sga.vanzolini.org.br/web/converte_link_portal.asp' +
    '?OFERTA_DE_CURSO=' + CONVERT(varchar, OFERTA.OFERTA_DE_CURSO) +
    '&tagturma=' + REPLACE(ISNULL(V.TURMA, OFERTA.CONCURSO), ' ', '%20') AS LINK
FROM LY_OFERTA_CURSO AS OFERTA
INNER JOIN LY_CURSO AS CURSO
    ON (OFERTA.CURSO = CURSO.CURSO)
INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA AS V
    ON V.OFERTA_DE_CURSO = OFERTA.OFERTA_DE_CURSO
--INNER JOIN LY_CONCURSO AS CONCURSO ON (OFERTA.CONCURSO = CONCURSO.CONCURSO)    