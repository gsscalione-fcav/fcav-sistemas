/*######################################################    
  DASHBOARD - MASSA DE DADOS     
######################################################*/    
    
--SELECT * FROM VW_FCAV_CRONOGRAMA_TURMA_COORDENADOR    
--VW_FCAV_MEDIA_FINAL_ALUNOS    
--INDICE DE VAGAS PREENCHIDAS POR PERÍODO POR UNIDADE RESPONSAVEL    
    
ALTER VIEW VW_FCAV_DASHBOARD_FECHAMENTO_MATRICULA    
AS    
    
SELECT      
 CASE WHEN CO.GRUPO = '-CERT' or co.NOME_COMPL = 'José Joaquim do Amaral Ferreira' THEN 'Certificação'    
   WHEN VT.UNIDADE_FISICA = 'Online' OR VT.UNIDADE_FISICA = 'Semipresencial' THEN 'Paulista'    
  ELSE CO.UNID_FISICA    
 END AS GRUPO_RESP,    
    CASE WHEN CS.FACULDADE = 'ATUAL' AND VT.UNIDADE_FISICA = 'USP' THEN 'DIFUS'    
  ELSE CS.FACULDADE     
 END AS UNID_RESP,      
    CS.CURSO AS CURSO,      
    CS.NOME AS NOME_CURSO,      
     
    OC.OFERTA_DE_CURSO,    
    CASE WHEN VT.TP_INGRESSO = 'VD' THEN 'Venda Direta'    
   WHEN VT.TP_INGRESSO = 'PS' THEN 'Processo Seletivo'    
    END AS  TIPO_INGRESSO,    
    ISNULL(OC.CONCURSO, 'VENDA DIRETA') AS CONCURSO,    
    OC.DTINI AS DTINI_INSCRICAO,      
    OC.DTFIM AS DTFIM_INSCRICAO,      
    CASE      
        WHEN oc.DTFIM >= GETDATE() THEN 'Abertas'      
        WHEN oc.DTFIM <= GETDATE() THEN 'Encerradas'      
    END AS INSCRICOES,      
    OC.ANO_INGRESSO AS ANO_INICIO,      
    OC.PER_INGRESSO,      
    VT.TURMA,      
    VT.DT_INICIO,      
    VT.DT_FIM,      
    ISNULL((SELECT TOP 1      
        CASE      
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND      
                VT.DT_INICIO > GETDATE() THEN 'Em Inscrição'      
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND      
                (GETDATE() BETWEEN VT.DT_INICIO AND VT.DT_FIM) THEN 'Em Andamento'      
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND      
                VT.DT_FIM < GETDATE() THEN 'Concluido'      
            WHEN CLASSIFICACAO LIKE 'Cancel%' THEN 'Cancelada'    
   ELSE 'NÃO CLASSIFICADA'      
        END      
    FROM LY_TURMA TU      
    WHERE TU.TURMA = VT.TURMA      
    AND TU.SERIE = 1      
    GROUP BY CLASSIFICACAO), 'NÃO CLASSIFICADA')    
    AS SITUACAO_TURMA,      
    ISNULL((SELECT TOP 1      
        CASE      
            WHEN CLASSIFICACAO LIKE 'Cancel%' THEN 'Cancelada'     
            WHEN CLASSIFICACAO NOT LIKE 'Cancel%' AND      
                VT.DT_INICIO > GETDATE() THEN 'Em Inscrição'      
            ELSE 'Realizada'    
        END      
    FROM LY_TURMA TU      
    WHERE TU.TURMA = VT.TURMA      
    AND TU.SERIE = 1      
    GROUP BY CLASSIFICACAO),'Cancelada')    
    AS REALIZACAO,      
    (SELECT TOP 1     
  CASE WHEN CS.FACULDADE = 'PALES' THEN CS.VAGAS    
  ELSE ISNULL(NUM_ALUNOS, CS.VAGAS)      
  END    
    FROM LY_TURMA TU      
    WHERE TU.CURSO = CS.CURSO      
    AND TU.SERIE = 1      
    GROUP BY NUM_ALUNOS,      
             TURMA)      
    AS VAGAS_OFERECIDAS,    
        
 ISNULL((SELECT COUNT(INSCRITO)     
     FROM     
   VW_FCAV_CANDIDATOS_E_ALUNOS CA    
     WHERE CA.TURMA = VT.TURMA    
   AND CA.OFERTA_DE_CURSO = VT.OFERTA_DE_CURSO    
   )      
  ,0) AS TOTAL_INSCRITOS,    
        
    (SELECT      
        COUNT(CA.CANDIDATO)      
    FROM LY_CANDIDATO CA      
    INNER JOIN FCAV_CANDIDATOS FC      
        ON FC.CANDIDATO = CA.CANDIDATO      
        AND FC.CONCURSO = CA.CONCURSO     
    WHERE CA.CONCURSO = OC.CONCURSO      
    AND FC.CONVOCADO = '2'    
 AND FC.DATA_INSC <= VT.DT_INICIO)      
    AS RECUSADOS,      
     
 CASE      
    WHEN VT.UNIDADE_RESPONSAVEL IN ('PALES', 'ATUAL') THEN (SELECT      
            COUNT(ALUNO)      
        FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA      
        WHERE SIT_ALUNO = 'Cancelado'      
        AND TURMA = VT.TURMA    
  AND OFERTA_DE_CURSO = VT.OFERTA_DE_CURSO)      
    ELSE (SELECT      
           COUNT(mp.ALUNO)      
        FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP    
  INNER JOIN LY_CANDIDATO CA    
   ON CA.CANDIDATO = MP.CANDIDATO      
        WHERE SIT_ALUNO = 'Cancelado'      
         AND UNIDADE_RESPONSAVEL IN ('ESPEC', 'CAPAC')      
        AND CA.SIT_CANDIDATO_VEST = 'Cancelado'    
AND TURMA = VT.TURMA    
  AND OFERTA_DE_CURSO = VT.OFERTA_DE_CURSO    
        AND DT_MATRICULA <= VT.DT_INICIO)      
 END +    
 (SELECT      
        COUNT(CA.CANDIDATO)      
    FROM LY_CANDIDATO CA      
 INNER JOIN FCAV_CANDIDATOS FC      
        ON FC.CANDIDATO = CA.CANDIDATO      
        AND FC.CONCURSO = CA.CONCURSO    
 LEFT JOIN LY_ALUNO AL    
  ON AL.CANDIDATO = CA.CANDIDATO      
    WHERE CA.CONCURSO = OC.CONCURSO      
  AND SIT_CANDIDATO_VEST = 'Cancelado'      
  AND (FC.CONVOCADO != 2 OR FC.CONVOCADO IS NULL)    
  AND CA.DT_INSCRICAO IS NULL    
  AND AL.ALUNO IS NULL)  AS DESISTENTES,    
    
 (SELECT      
            COUNT(ALUNO)      
    FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA      
    WHERE SIT_MATRICULA = 'Matriculado'      
    AND TURMA = VT.TURMA    
    AND DT_MATRICULA <= (VT.DT_INICIO + 5)    
 AND OFERTA_DE_CURSO = VT.OFERTA_DE_CURSO) AS MATRICULADOS,    
    
 (SELECT COUNT(INSCRITO)     
  FROM VW_FCAV_DASHBOARD_REFUGO DR    
  WHERE VT.TURMA = DR.TURMA    
  AND DR.OFERTA_DE_CURSO = VT.OFERTA_DE_CURSO) AS REFUGOS,    
    
 (SELECT     
  COUNT(ALUNO)     
   FROM VW_FCAV_DASHBOARD_CONCLUINTES DC    
   WHERE DC.TURMA = VT.TURMA    
   AND DC.SIT_ALUNO != 'Cancelado'    
   AND DC.SIT_MATRICULA = 'Matriculado'    
   AND DC.DT_MATRICULA <= (VT.DT_INICIO + 5)    
    
 ) AS CONCLUINTES,    
    
 (SELECT COUNT(ALUNO)     
  FROM VW_FCAV_DASHBOARD_EVADIDOS DE    
  WHERE DE.TURMA = VT.TURMA    
  ) EVADIDOS,    
    
 format(vt.DT_INICIO, 'MMM/yyyy', 'pt-br') AS MES_ANO_INIC    
    
       
FROM VW_FCAV_INI_FIM_CURSO_TURMA VT      
      
INNER JOIN LY_CURSO CS      
    ON CS.CURSO = VT.CURSO      
      
LEFT JOIN VW_FCAV_COORDENADOR_TURMA CO    
 ON CO.TURMA = VT.TURMA    
      
INNER JOIN LY_OFERTA_CURSO OC      
    ON OC.OFERTA_DE_CURSO = VT.OFERTA_DE_CURSO      
      
WHERE CO.TIPO_COORD = 'COORD'      
      
GROUP BY OC.ANO_INGRESSO,      
         OC.PER_INGRESSO,      
         OC.DTINI,      
         OC.DTFIM,    
         OC.OFERTA_DE_CURSO,      
         OC.CONCURSO,      
      
         CS.FACULDADE,      
         CS.CURSO,      
         CS.NOME,      
         CS.VAGAS,      
      
         VT.TURMA,      
         VT.DT_INICIO,      
         VT.DT_FIM,      
         VT.UNIDADE_RESPONSAVEL,    
   VT.UNIDADE_FISICA,    
         VT.TP_INGRESSO,    
         VT.CONCURSO,    
   VT.OFERTA_DE_CURSO,    
      
         CO.TIPO_COORD,    
   CO.GRUPO,    
   CO.NOME_COMPL,    
   CO.UNID_FISICA 