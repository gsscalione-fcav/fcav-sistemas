IF EXISTS (SELECT * 
           FROM   sys.VIEWS 
           WHERE  NAME = 'VW_FCAV_QUANTIDADE_ALUNOS_DISCIPLINAS') 
  DROP VIEW VW_FCAV_QUANTIDADE_ALUNOS_DISCIPLINAS 

go 

CREATE VIEW VW_FCAV_QUANTIDADE_ALUNOS_DISCIPLINAS 
AS 
  ------------------------ TABELAS CONTADORAS DE ALUNOS ------------------------   
  WITH tb_quantidade_alunos_ativos 
       AS (SELECT DI.DISCIPLINA, 
                  HA.DISCIPLINA NOME_DISCIPLINA, 
                  TU.CURSO, 
                  TU.TURMA,
                  HA.ANO,
                  HA.SEMESTRE,
                  DO.NUM_FUNC, 
                  HA.DOCENTE,
                  COUNT(ALUNO)  AS quantidade_alunos_ativos, 
                  0             AS quantidade_alunos_trancados, 
                  0             AS quantidade_alunos_desistentes 
           FROM   VW_FCAV_HISTORICO_ACADEMICO HA 
                  INNER JOIN LY_DOCENTE DO 
                         ON DO.NOME_COMPL = HA.DOCENTE 
                  INNER JOIN LY_TURMA TU 
                         ON TU.TURMA = HA.TURMA
                         AND TU.ANO = HA.ANO
                         AND TU.SEMESTRE = HA.SEMESTRE
                  INNER JOIN LY_DISCIPLINA DI
						 ON DI.DISCIPLINA = TU.DISCIPLINA
						 AND DI.NOME = HA.DISCIPLINA
						 
           WHERE  SITUACAO_HIST <> 'Cancelado' 
                  AND SITUACAO_HIST <> 'Trancado' 
           GROUP  BY DI.DISCIPLINA, 
                     HA.DISCIPLINA, 
                     TU.CURSO, 
                     TU.TURMA,
                     HA.ANO,
					 HA.SEMESTRE, 
                     DO.NUM_FUNC, 
                     HA.DOCENTE), 
       tb_quantidade_alunos_trancados 
       AS (SELECT DI.DISCIPLINA, 
                  HA.DISCIPLINA NOME_DISCIPLINA, 
                  TU.CURSO, 
                  TU.TURMA,
                  HA.ANO,
                  HA.SEMESTRE, 
                  DO.NUM_FUNC, 
                  HA.DOCENTE, 
                  0             AS quantidade_alunos_ativos, 
                  Count(ALUNO)  AS quantidade_alunos_trancados, 
                  0             AS quantidade_alunos_desistentes 
           FROM   VW_FCAV_HISTORICO_ACADEMICO HA 
                  INNER JOIN LY_DOCENTE DO 
                         ON DO.NOME_COMPL = HA.DOCENTE 
                  INNER JOIN LY_TURMA TU 
                         ON TU.TURMA = HA.TURMA
                         AND TU.ANO = HA.ANO
                         AND TU.SEMESTRE = HA.SEMESTRE
                  INNER JOIN LY_DISCIPLINA DI
						 ON DI.DISCIPLINA = TU.DISCIPLINA
						 AND DI.NOME = HA.DISCIPLINA
           WHERE  SITUACAO_HIST <> 'Cancelado' 
                  AND SITUACAO_HIST = 'Trancado' 
           GROUP  BY DI.DISCIPLINA, 
                     HA.DISCIPLINA, 
                     TU.CURSO, 
                     TU.TURMA,
                     HA.ANO,
					 HA.SEMESTRE,
                     DO.NUM_FUNC, 
                     HA.DOCENTE), 
       tb_quantidade_alunos_desistentes 
       AS (SELECT DI.DISCIPLINA, 
                  HA.DISCIPLINA NOME_DISCIPLINA, 
                  TU.CURSO, 
                  TU.TURMA,
                  HA.ANO,
                  HA.SEMESTRE,
                  DO.NUM_FUNC, 
                  HA.DOCENTE, 
                  0             AS quantidade_alunos_ativos, 
                  0             AS quantidade_alunos_trancados, 
                  Count(ALUNO)  quantidade_alunos_desistentes 
           FROM   VW_FCAV_HISTORICO_ACADEMICO HA 
                  INNER JOIN LY_DOCENTE DO 
                         ON DO.NOME_COMPL = HA.DOCENTE 
                  INNER JOIN LY_TURMA TU 
                         ON TU.TURMA = HA.TURMA
                         AND TU.ANO = HA.ANO
                         AND TU.SEMESTRE = HA.SEMESTRE
                  INNER JOIN LY_DISCIPLINA DI
						 ON DI.DISCIPLINA = TU.DISCIPLINA
						 AND DI.NOME = HA.DISCIPLINA
           WHERE  SITUACAO_HIST = 'Cancelado' 
                  AND SITUACAO_HIST <> 'Trancado' 
           GROUP  BY DI.DISCIPLINA, 
                     HA.DISCIPLINA, 
                     TU.CURSO, 
                     TU.TURMA,
                     HA.ANO,
					 HA.SEMESTRE,
                     DO.NUM_FUNC, 
                     HA.DOCENTE) 
  SELECT * 
  FROM   tb_quantidade_alunos_ativos 
  UNION ALL 
  SELECT * 
  FROM   tb_quantidade_alunos_trancados 
  UNION ALL 
  SELECT * 
  FROM   tb_quantidade_alunos_desistentes 