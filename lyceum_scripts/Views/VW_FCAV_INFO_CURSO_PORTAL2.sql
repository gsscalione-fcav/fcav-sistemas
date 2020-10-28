/*    
 VIEW VW_FCAV_INFO_CURSO_PORTAL2  WHERE TURMA = 'CEAI T 33' 
*/    
    
    
ALTER VIEW VW_FCAV_INFO_CURSO_PORTAL2    
AS    
    
SELECT    
    OC.UNIDADE_FISICA AS FACULDADE,    
    ISNULL((SELECT TOP 1
				NOME_COMPL
            FROM VW_FCAV_COORDENADOR_TURMA COORD
            WHERE COORD.TURMA = tu.TURMA
            AND COORD.TIPO_COORD = 'COORD'
            GROUP BY NOME_COMPL),'NAO CADASTRADO') AS COORDENADOR,    
    ISNULL((SELECT TOP 1
				NOME_COMPL
            FROM VW_FCAV_COORDENADOR_TURMA COORD
            WHERE COORD.TURMA = tu.TURMA 
            AND COORD.TIPO_COORD != 'COORD'
            GROUP BY NOME_COMPL),'.') AS VICE_COORD,    
    tu.CURSO,    
    --*** tu.TURNO,      
    tu.CURRICULO,    
    oc.OFERTA_DE_CURSO AS OFERTA,    
    oc.CURSO AS CURSO_OFERTADO,    
    OC.DESCRICAO_COMPL,    
    oc.DTINI AS DTINI_OFERTA,    
    oc.DTFIM AS DTFIM_OFERTA,    
    CASE    
        WHEN OC.CONCURSO IS NULL AND    
            oc.OFERTA_DE_CURSO IS NOT NULL THEN 'VENDA DIRETA'    
        WHEN OC.CONCURSO IS NULL AND    
            oc.OFERTA_DE_CURSO IS NULL THEN NULL    
        ELSE CO.CONCURSO    
    END AS CONCURSO,    
    oc.TURMA_PREF,    
    --*** CASE WHEN OC.CONCURSO IS NULL THEN oc.DTINI       
    --***  ELSE co.DT_INICIO END AS DTINI_CONCURSO,      
    --*** CASE WHEN OC.CONCURSO IS NULL THEN oc.DTFIM      
    --***  ELSE co.DT_FIM END AS DTFIM_CONCURSO,        
    tu.TURMA,    
    TU.ANO,    
    TU.SEMESTRE AS PERIODO,    
    --*** GR.DISCIPLINA AS GRADE_CURRICULAR,      
    --*** TU.SERIE,      
    TU.DISCIPLINA,    
    --tu.DT_INICIO AS DT_INICIO,        
    (SELECT     
        MIN(L1.DT_INICIO)    
    FROM LY_TURMA L1    
    WHERE L1.TURMA = tu.TURMA    
    GROUP BY L1.TURMA)    
    AS DT_INICIO,    
    --tu.DT_FIM AS DT_FIM,      
    (SELECT    
        MAX(L1.DT_FIM)    
    FROM LY_TURMA L1    
    WHERE L1.TURMA = tu.TURMA    
    GROUP BY L1.TURMA)    
    AS DT_FIM,    
    --*** AGE.NUM_FUNC,      
    ISNULL((SELECT    
        DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(LTRIM(RTRIM(D.NOME_COMPL)))    
    FROM LY_DOCENTE D    
    WHERE AGE.NUM_FUNC = D.NUM_FUNC), 'Não Cadastrado')    
    AS DOCENTE,    
    --*** NULL AS FOTO, --(SELECT FOTO FROM LY_FOTO_DOCENTE WHERE NOT EXISTS (SELECT 1 FROM LY_FOTO_DOCENTE F WHERE F.NUM_FUNC = AGE.NUM_FUNC)) AS FOTO,      
    ISNULL(D.ATUACAO_PROFIS,'Não Cadastrado') as ATUACAO_PROFIS,    
    (SELECT TOP 1    
        CLASSIFICACAO    
    FROM LY_TURMA T2    
    WHERE T2.TURMA = TU.TURMA    
    AND T2.SERIE = '1')    
    AS SIT_TURMA,    
    --*** TU.NUM_ALUNOS VAGAS,      
    oo.CARGA_HORARIA,    
    ISNULL(OC.FL_FIELD_05, '.') AS VALOR_CURSO,    
    ISNULL(C.FL_FIELD_01, '.') AS APRESENTACAO_CURSO,    
    ISNULL(C.FL_FIELD_04, '.') AS DIFERENCIAL,    
    ISNULL(C.FL_FIELD_05, '.') AS PERFIL_ALUNO,    
    ISNULL(C.FL_FIELD_06, '.') AS CERTIFICACAO,    
    ISNULL(C.FL_FIELD_07, '.') AS METODOLOGIA,    
    ISNULL(C.FL_FIELD_08, '.') AS SISTEMA_AVALIACAO,    
    ISNULL(C.FL_FIELD_10, '.') AS PROCESSO_SELETIVO,    
    
    CASE    
        WHEN (C.FACULDADE = 'ESPEC' OR    
            C.FACULDADE = 'CAPAC') THEN ISNULL(C.FL_FIELD_02, '.')    
        ELSE ISNULL(C.FL_FIELD_02, '.')    
    END AS OBJETIVOS,    
    
    CASE    
        WHEN (C.FACULDADE = 'ESPEC' OR    
            C.FACULDADE = 'CAPAC') THEN ISNULL(C.FL_FIELD_03, '.')    
        ELSE ISNULL(C.FL_FIELD_03, '.')    
    END AS CORPO_DOCENTE,    
    
    CASE    
        WHEN (C.FACULDADE = 'ESPEC' OR    
            C.FACULDADE = 'CAPAC') THEN ISNULL(C.FL_FIELD_09, '.')    
        ELSE ISNULL(C.FL_FIELD_09, '.')    
    END AS INVESTIMENTO,    
    
    
    ISNULL(C.FL_FIELD_05, '.') AS PUBLICO_ALVO,    
    ISNULL(OC.FL_FIELD_04, '.') AS PROGRAMA,    
    
    CASE    
        WHEN OO.TP_INGRESSO = 'VD' THEN (SELECT TOP 1    
                ISNULL(OP.HORARIO_DESCRICAO, '.')    
            FROM LY_OPCOES_OFERTA op    
            WHERE op.OFERTA_DE_CURSO = oc.OFERTA_DE_CURSO)    
        ELSE ISNULL(CO.FL_FIELD_06, '.')    
    END AS DIA_HORARIO_AULAS,    
    ISNULL(CO.FL_FIELD_07, '.') AS RELACAO_DOCUMENTOS,    
      
 LINK    
    
FROM LY_TURMA AS tu    
INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA oo    
    ON TU.TURMA = oo.TURMA    
INNER JOIN LY_OFERTA_CURSO oc    
    ON (oc.OFERTA_DE_CURSO = oo.OFERTA_DE_CURSO)    
LEFT JOIN LY_CONCURSO co    
    ON (CO.CONCURSO = OC.CONCURSO)    
LEFT JOIN LY_AGENDA AGE    
    ON (tu.TURMA = AGE.TURMA    
    AND tu.DISCIPLINA = AGE.DISCIPLINA)    
LEFT JOIN LY_DOCENTE D    
    ON AGE.NUM_FUNC = D.NUM_FUNC    
INNER JOIN VW_FCAV_LINK_OFERTA_CURSO_COMPLETA LO    
    ON LO.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO    
INNER JOIN LY_OPCOES_OFERTA OP    
    ON OP.OFERTA_DE_CURSO = oc.OFERTA_DE_CURSO    
INNER JOIN LY_CURSO C    
    ON C.CURSO = TU.CURSO    
    
-------------------------------        
--Apenas para filtro        
WHERE oo.CURSO NOT LIKE '%teste%'    
AND YEAR(oo.DT_INICIO) >= '2016'    
--AND OO.OFERTA_DE_CURSO = 1814
-------------------------------        
GROUP BY tu.TURMA,    
         tu.CURSO,    
         CO.CONCURSO,    
         oc.OFERTA_DE_CURSO,    
         tu.CURRICULO,    
         tu.ANO,    
         tu.SEMESTRE,    
         tu.TURNO,    
         oc.DTINI,    
         oc.DTFIM,    
         co.DT_INICIO,    
         co.DT_FIM,    
         TU.DISCIPLINA,    
         tu.DT_INICIO,    
         oo.TP_INGRESSO,    
         tu.DT_FIM,    
         TU.SEMESTRE,    
         TU.SERIE,    
         TU.CLASSIFICACAO,    
         OC.UNIDADE_FISICA ,    
         TU.NUM_ALUNOS,    
         oc.TURMA_PREF,    
         oo.CARGA_HORARIA,    
         TU.DT_ULTALT,    
         D.NOME_COMPL,    
         oc.CURSO,    
         oc.CONCURSO,    
         OC.DESCRICAO_COMPL,    
         AGE.NUM_FUNC,    
         LO.OFERTA_DE_CURSO,    
         OC.FL_FIELD_04,    
         OC.FL_FIELD_05,    
         D.ATUACAO_PROFIS,    
         LINK,    
         C.FACULDADE,    
         CO.FL_FIELD_01,    
         CO.FL_FIELD_02,    
         CO.FL_FIELD_03,    
         CO.FL_FIELD_04,    
         CO.FL_FIELD_05,    
         CO.FL_FIELD_06,    
         CO.FL_FIELD_07,    
         C.FL_FIELD_01,    
         C.FL_FIELD_02,    
         C.FL_FIELD_03,    
         C.FL_FIELD_04,    
         C.FL_FIELD_05,    
         C.FL_FIELD_06,    
         C.FL_FIELD_07,    
         C.FL_FIELD_08,    
         C.FL_FIELD_09,    
         C.FL_FIELD_10