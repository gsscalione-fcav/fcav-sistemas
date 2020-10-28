CREATE VIEW VW_FCAV_QUANTIDADE_ALUNOS_DISCIPLINAS 
AS
------------------------ TABELAS CONTADORAS DE ALUNOS ------------------------  
WITH tb_quantidade_alunos_ativos 
     AS (SELECT DI.DISCIPLINA,
				TU.DISCIPLINA NOME_DISCIPLINA, 
                TU.CURSO, 
                TU.TURMA, 
                DO.NUM_FUNC, 
                DOCENTE,
                COUNT(ALUNO) AS quantidade_alunos_ativos,
                0 AS quantidade_alunos_trancados,
                0 AS quantidade_alunos_desistentes
         FROM   VW_FCAV_HISTORICO_ACADEMICO TU 
                LEFT JOIN LY_DOCENTE DO 
					ON DO.NOME_COMPL = TU.DOCENTE
				INNER JOIN LY_DISCIPLINA DI
					ON DI.NOME = TU.DISCIPLINA
         WHERE  SITUACAO_HIST <> 'Cancelado' 
                AND SITUACAO_HIST <> 'Trancado' 
         GROUP  BY DI.DISCIPLINA,
				   TU.DISCIPLINA, 
                   TU.CURSO, 
                   TU.TURMA, 
                   DO.NUM_FUNC, 
                   TU.DOCENTE), 
     tb_quantidade_alunos_trancados 
     AS (SELECT DI.DISCIPLINA,
				TU.DISCIPLINA NOME_DISCIPLINA,  
                TU.CURSO, 
                TU.TURMA, 
                DO.NUM_FUNC, 
                TU.DOCENTE, 
                0 AS quantidade_alunos_ativos,
                Count(ALUNO) AS quantidade_alunos_trancados,
                0 AS quantidade_alunos_desistentes
         FROM   VW_FCAV_HISTORICO_ACADEMICO TU 
                LEFT JOIN LY_DOCENTE DO 
					ON DO.NOME_COMPL = TU.DOCENTE
				INNER JOIN LY_DISCIPLINA DI
					ON DI.NOME = TU.DISCIPLINA
         WHERE  SITUACAO_HIST <> 'Cancelado' 
                AND SITUACAO_HIST = 'Trancado'
         GROUP  BY DI.DISCIPLINA,
				   TU.DISCIPLINA, 
                   TU.CURSO, 
                   TU.TURMA, 
                   DO.NUM_FUNC, 
                   TU.DOCENTE), 
     tb_quantidade_alunos_desistentes 
     AS (SELECT DI.DISCIPLINA,
				TU.DISCIPLINA NOME_DISCIPLINA, 
                TU.CURSO, 
                TU.TURMA, 
                DO.NUM_FUNC, 
                TU.DOCENTE,
                0 AS quantidade_alunos_ativos,
                0 AS quantidade_alunos_trancados,
                Count(ALUNO) quantidade_alunos_desistentes 
         FROM   VW_FCAV_HISTORICO_ACADEMICO TU 
                LEFT JOIN LY_DOCENTE DO 
					ON DO.NOME_COMPL = TU.DOCENTE
				INNER JOIN LY_DISCIPLINA DI
					ON DI.NOME = TU.DISCIPLINA
         WHERE  SITUACAO_HIST = 'Cancelado' 
                AND SITUACAO_HIST <> 'Trancado'
         GROUP  BY DI.DISCIPLINA,
				   TU.DISCIPLINA, 
                   TU.CURSO, 
                   TU.TURMA, 
                   DO.NUM_FUNC, 
                   TU.DOCENTE) 

SELECT * FROM tb_quantidade_alunos_ativos
UNION ALL
SELECT * FROM tb_quantidade_alunos_trancados
UNION ALL 
SELECT * FROM tb_quantidade_alunos_desistentes
