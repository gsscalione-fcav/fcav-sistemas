/* 
  VIEW VW_FCAV_AGENDA_TURMA_DISCIPLINA 

  Finalidade: Utilizada para atender a planilha da Educação solicitada pelo chamado 
 */ 
ALTER VIEW VW_FCAV_AGENDA_TURMA_DISCIPLINA 
AS 
  SELECT TUR.FACULDADE                                                        AS 
         UNIDADE, 
         TUR.UNIDADE_RESPONSAVEL                                              AS 
            MODALIDADE, 
         CS.NOME                                                              AS 
            NOME_CURSO, 
         TUR.CURSO                                                            AS 
            CURSO, 
         TUR.TURMA, 
         TUR.CLASSIFICACAO                                                    AS 
            SIT_TURMA, 
         V.DT_INICIO                                                          AS 
            DT_INICIO_TURMA, 
         Month(V.DT_INICIO) 
         MES, 
         V.DT_FIM                                                             AS 
            DT_FIM_TURMA, 
         TUR.ANO, 
         TUR.SEMESTRE                                                         AS 
            PERIODO, 
         TUR.SERIE, 
         TUR.DISCIPLINA                                                       AS 
            DISCIPLINA, 
         (SELECT D.NOME_COMPL 
          FROM   LY_DISCIPLINA D 
          WHERE  TUR.DISCIPLINA = D.DISCIPLINA)                               AS 
            NOME_DISCIPLINA, 
         AGE.NUM_FUNC, 
         DBO.fn_fcav_primeira_maiuscula(Ltrim(Rtrim(DOC.NOME_COMPL)))         AS 
            DOCENTE, 
         --LOWER(E_MAIL) AS E_MAIL,     
         TUR.DT_INICIO                                                        AS 
            DT_INICIO_DISCIPLINA, 
         CARGA_HORARIA, 
         AGE.DATA                                                             AS 
            DIA_AULA, 
         CASE 
           WHEN DIA_SEMANA = 1 THEN 'domingo' 
           WHEN DIA_SEMANA = 2 THEN 'segunda-feira' 
           WHEN DIA_SEMANA = 3 THEN 'terça-feira' 
           WHEN DIA_SEMANA = 4 THEN 'quarta-feira' 
           WHEN DIA_SEMANA = 5 THEN 'quinta-feira' 
           WHEN DIA_SEMANA = 6 THEN 'sexta-feira' 
           WHEN DIA_SEMANA = 7 THEN 'sábado' 
         END                                                                  AS 
            DIA_DA_SEMANA, 
         CONVERT (VARCHAR, HORA_INICIO, 108)                                  AS 
            HORA_ENTRADA, 
         CONVERT (VARCHAR, HORA_FIM, 108)                                     AS 
            HORA_SAIDA, 
         CONVERT (VARCHAR, rank() 
                             OVER( 
                               PARTITION BY TUR.DISCIPLINA, TUR.TURMA 
                               ORDER BY TUR.TURMA, TUR.DISCIPLINA, AGE.DATA)) AS 
            NUM_AULA, 
         CASE 
           WHEN AGE.EVENTO_CUMP = 'S' THEN 'SIM' 
           WHEN AGE.EVENTO_CUMP = 'N' THEN 'NÃO' 
         END 
            AULA_CUMPRIDA, 
         CASE 
           WHEN AGE.CANCELADA = 'S' THEN 'SIM' 
           WHEN AGE.CANCELADA = 'N' THEN 'NÃO' 
         END                                                                  AS 
            AULA_CANCELADA, 
         AGE.DEPENDENCIA                                                      AS 
            SALA, 
         AGE.AGENDA                                                           AS 
            NUM_AGENDA_LYCEUM 
  FROM   LY_TURMA TUR 
         INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA V 
                 ON TUR.TURMA = V.TURMA 
                    AND TUR.TURNO = V.TURNO 
                    AND TUR.CURRICULO = V.CURRICULO 
         LEFT JOIN LY_AGENDA AGE 
                ON TUR.TURMA = AGE.TURMA 
                   AND TUR.DISCIPLINA = AGE.DISCIPLINA 
                   AND AGE.ANO = TUR.ANO 
                   AND AGE.SEMESTRE = TUR.SEMESTRE 
         INNER JOIN LY_DOCENTE DOC 
                 ON DOC.NUM_FUNC = AGE.NUM_FUNC 
         INNER JOIN LY_CURSO CS 
                 ON CS.CURSO = TUR.CURSO 
  WHERE  AGE.NUM_FUNC != 83484 
         AND TUR.ANO >= 2019 
  GROUP  BY TUR.CURSO, 
            CS.NOME, 
            TUR.FACULDADE, 
            V.CONCURSO, 
            TUR.UNIDADE_RESPONSAVEL, 
            TUR.TURMA, 
            V.DT_INICIO, 
            V.DT_FIM, 
            TUR.CLASSIFICACAO, 
            TUR.ANO, 
            TUR.SEMESTRE, 
            TUR.SERIE, 
            TUR.DT_INICIO, 
            TUR.DISCIPLINA, 
            AGE.NUM_FUNC, 
            DOC.NOME_COMPL, 
            DOC.E_MAIL, 
            HORA_INICIO, 
            HORA_FIM, 
            AGE.DIA_SEMANA, 
            AGE.DATA, 
            V.CARGA_HORARIA, 
            AGE.EVENTO_CUMP, 
            AGE.CANCELADA, 
            AGE.DEPENDENCIA, 
            AGE.AGENDA 