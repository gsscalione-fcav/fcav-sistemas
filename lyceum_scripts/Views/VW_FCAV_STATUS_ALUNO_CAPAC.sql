--*   VW_FCAV_STATUS_ALUNO_CAPAC WHERE TURMA = 'CCGB T 30'     
--*     
--*   - View criada para ser usada nos certificados de capacitação     
--*   coordenados pelo Alberto Ramos, pois para os cursos dele, além     
--*   dos certificados para quem termina o curso, existem certificados     
--*   de participação para quem finalizou e ficou reprovado por nota.     
--*     
--* ALTERAÇÃO:   
--*  - 18/09/2017: Houve a necessidade de retirar a VW_FCAV_MATRICULA_E_PRE_MATRICULA, pois    
--*       nesse formato só trazia alunos matriculados e pré-matriculados e a view   
--*       é utilizada para saber quais são os alunos aprovados e reprovados. Gabriel SS   
--*     
--*   Data de Criação: 03/11/2016     
--*   João Paulo     
ALTER VIEW VW_FCAV_STATUS_ALUNO_CAPAC 
AS 
  SELECT AL.CURSO, 
         MP.TURMA, 
         AL.ALUNO, 
         AL.NOME_COMPL, 
         (SELECT Count(DISCIPLINA) 
          FROM   LY_TURMA TU 
          WHERE  TU.TURMA = MP.TURMA)           DIS_TURMA, 
         (SELECT Count(DISCIPLINA) 
          FROM   LY_MATRICULA M2 
          WHERE  M2.ALUNO = AL.ALUNO 
             AND M2.TURMA = MP.TURMA 
             AND M2.SIT_MATRICULA = 'Aprovado' 
             AND M2.SIT_DETALHE = 'Curricular') AS DISC_APROVADAS, 
         CASE 
           WHEN (SELECT Count(DISCIPLINA) 
                 FROM   LY_TURMA TU 
                 WHERE  TU.TURMA = MP.TURMA) = (SELECT Count(DISCIPLINA) 
                                                FROM   LY_MATRICULA M2 
                                                WHERE  M2.ALUNO = AL.ALUNO 
                                                   AND M2.TURMA = MP.TURMA 
                                                   AND M2.SIT_MATRICULA = 'Aprovado' 
                                                   AND M2.SIT_DETALHE = 'Curricular') 
         THEN 'Aprovado' 
           ELSE 'Reprovado' 
         END AS SIT_FINAL, 
         MP.SIT_MATRICULA, 
         MP.SIT_DETALHE 
  FROM   LY_MATRICULA MP 
         INNER JOIN LY_ALUNO AL 
                 ON AL.ALUNO = MP.ALUNO 
         INNER JOIN LY_CURSO CS 
                 ON CS.CURSO = AL.CURSO 
  WHERE  CS.FACULDADE = 'CAPAC' 
  GROUP  BY AL.CURSO, 
            MP.TURMA, 
            AL.ALUNO, 
            AL.NOME_COMPL, 
            MP.SIT_MATRICULA, 
            MP.SIT_DETALHE 
  UNION ALL 
  SELECT AL.CURSO, 
         HIST.TURMA, 
         AL.ALUNO, 
         AL.NOME_COMPL, 
         (SELECT Count(DISCIPLINA) 
          FROM   LY_TURMA TU 
          WHERE  TU.TURMA = HIST.TURMA)         AS DIS_TURMA, 
         (SELECT Count(DISCIPLINA) 
          FROM   LY_HISTMATRICULA M2 
          WHERE  M2.ALUNO = AL.ALUNO 
             AND M2.TURMA = HIST.TURMA 
             AND M2.SITUACAO_HIST = 'Aprovado' 
             AND M2.SIT_DETALHE = 'Curricular') AS DISC_APROVADAS, 
         CASE 
           WHEN (SELECT Count(DISCIPLINA) 
                 FROM   LY_TURMA TU 
                 WHERE  TU.TURMA = HIST.TURMA) = (SELECT Count(DISCIPLINA) 
                                                  FROM   LY_HISTMATRICULA M2 
                                                  WHERE  M2.ALUNO = AL.ALUNO 
                                                     AND M2.TURMA = HIST.TURMA 
                                                     AND M2.SITUACAO_HIST = 'Aprovado' 
                                                     AND M2.SIT_DETALHE = 'Curricular') 
         THEN 'Aprovado' 
           ELSE 'Reprovado' 
         END  AS SIT_FINAL, 
         HIST.SITUACAO_HIST, 
         HIST.SIT_DETALHE 
  FROM   LY_HISTMATRICULA HIST 
         INNER JOIN LY_ALUNO AL 
                 ON ( AL.ALUNO = HIST.ALUNO ) 
         INNER JOIN LY_CURSO CS 
                 ON CS.CURSO = AL.CURSO 
  WHERE  CS.FACULDADE = 'CAPAC' 
  GROUP  BY AL.CURSO, 
            HIST.TURMA, 
            AL.ALUNO, 
            AL.NOME_COMPL, 
            HIST.SITUACAO_HIST, 
            HIST.SIT_DETALHE  