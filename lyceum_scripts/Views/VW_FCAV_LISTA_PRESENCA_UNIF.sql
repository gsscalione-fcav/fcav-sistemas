/*  
 VIEW VW_FCAV_LISTA_PRESENCA_UNIF  
  
Finalidade: Consulta para trazer a relaçao de alunos matriculados nas disciplinas do CEAI, unificando as Turmas para lista de presença.  
  
Autor: Gabriel Serrano Scalione  
Data: 2017-03-30 15:53:23.720  
  
*/  
  
ALTER VIEW VW_FCAV_LISTA_PRESENCA_UNIF   
AS   
  SELECT Replace(T.DISCIPLINA, ' ', '')                        AS DISCIP_COD,   
         DISCIP.NOME_COMPL                                     AS DISCIP_NOME,   
         A.DATA                           AS DATA_AULA,   
         A.TURMA                                               AS TURMA_COD,   
         C.CURSO                                               AS CURSO,   
         A.DEPENDENCIA                                         AS SALA,   
         D.NUM_FUNC                                            AS PROF_COD,   
         D.NOME_COMPL                                          AS PROF_NOME,   
         Substring(CONVERT(VARCHAR, A.HORA_INICIO, 114), 1, 5) AS HORA_INI,   
         Substring(CONVERT(VARCHAR, A.HORA_FIM, 114), 1, 5)    AS HORA_FINAL,   
         ALU.ALUNO                                             AS ALUNO_COD,   
         PES.NOME_COMPL                                        AS ALUNO_NOME,   
         MAT.SIT_MATRICULA                                     AS STATUS,   
         MAT.SIT_DETALHE                                       AS DETALHE,   
         A.LISTA                                               AS NRO_LISTA,   
         'Lyceum'                                              AS SISTEMA,   
         Cast(A.ANO AS VARCHAR) + '/'   
         + Cast(A.SEMESTRE AS VARCHAR)                         AS PERIODO   
  FROM   LY_TURMA T  
         INNER JOIN LY_AGENDA A   
                ON T.DISCIPLINA = A.DISCIPLINA   
                   AND T.TURMA = A.TURMA   
                   AND T.ANO = A.ANO   
                   AND T.SEMESTRE = A.SEMESTRE   
         LEFT JOIN LY_DOCENTE AS D   
                 ON A.NUM_FUNC = D.NUM_FUNC   
         LEFT JOIN LY_CURSO AS C   
                ON T.CURSO = C.CURSO   
         INNER JOIN LY_DISCIPLINA DISCIP   
                 ON DISCIP.DISCIPLINA = T.DISCIPLINA   
         INNER JOIN LY_MATRICULA AS MAT   
                 ON T.TURMA = MAT.TURMA   
                    AND T.DISCIPLINA = MAT.DISCIPLINA   
                    AND T.ANO = MAT.ANO   
                    AND T.SEMESTRE = MAT.SEMESTRE   
         INNER JOIN LY_ALUNO AS ALU   
                 ON MAT.ALUNO = ALU.ALUNO   
         INNER JOIN LY_PESSOA AS PES   
                 ON ALU.PESSOA = PES.PESSOA   
  WHERE  C.CURSO = 'CEAI'  
 and t.DISCIPLINA not like 'CEAI-RESERV'    
 --and t.DISCIPLINA = 'CEAI-GC'  
 --and month(a.DATA) = '3'  
  GROUP  BY T.DISCIPLINA,   
            DISCIP.NOME_COMPL,   
            A.DATA,   
            A.TURMA,   
            C.CURSO,   
            A.DEPENDENCIA,   
            D.NUM_FUNC,   
            D.NOME_COMPL,   
            A.HORA_INICIO,   
            A.HORA_FIM,   
            ALU.ALUNO,   
            PES.NOME_COMPL,   
            MAT.SIT_MATRICULA,   
            MAT.SIT_DETALHE,   
            A.LISTA,   
            A.ANO,   
            A.SEMESTRE   
 