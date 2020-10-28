SELECT DISTINCT ly_docente.nome_compl, 
                ly_agenda.data, 
                ly_agenda.disciplina, 
                ly_agenda.turma, 
                ly_agenda.dependencia, 
                ly_aluno.aluno, 
                ly_aluno.nome_compl, 
                ly_matricula.sit_matricula, 
                ly_matricula.sit_detalhe, 
                ly_agenda.lista, 
                ly_agenda.hora_inicio, 
                ly_agenda.hora_fim, 
                vw_fcav_monitor_aula.monitor_1, 
                vw_fcav_monitor_aula.monitor_2, 
                vw_fcav_reposicao_aula.reposicao_do_dia, 
                vw_fcav_cronograma_turma_docente.num_aula 
FROM   ((((lyceum.dbo.vw_fcav_cronograma_turma_docente 
          VW_FCAV_CRONOGRAMA_TURMA_DOCENTE 
           LEFT OUTER JOIN lyceum.dbo.ly_agenda LY_AGENDA 
                        ON 
           ( ( 
           ( ( vw_fcav_cronograma_turma_docente.turma = 
               ly_agenda.turma ) 
             AND 
           ( 
                       vw_fcav_cronograma_turma_docente.dia_aula = 
                       ly_agenda.data ) ) 
                         AND ( 
                     vw_fcav_cronograma_turma_docente.disciplina = 
                     ly_agenda.disciplina ) ) 
                       AND ( vw_fcav_cronograma_turma_docente.ano = 
                             ly_agenda.ano ) ) 
                     AND ( vw_fcav_cronograma_turma_docente.periodo = 
                           ly_agenda.semestre )) 
          INNER JOIN (lyceum.dbo.ly_aluno LY_ALUNO 
                      INNER JOIN lyceum.dbo.ly_matricula LY_MATRICULA 
                              ON ly_aluno.aluno = ly_matricula.aluno) 
                  ON ( ly_agenda.disciplina = ly_matricula.disciplina ) 
                     AND ( ly_agenda.turma = ly_matricula.turma )) 
         LEFT OUTER JOIN lyceum.dbo.ly_docente LY_DOCENTE 
                      ON ly_agenda.num_func = ly_docente.num_func) 
        LEFT OUTER JOIN lyceum.dbo.vw_fcav_monitor_aula VW_FCAV_MONITOR_AULA 
                     ON 
        ( ( ly_agenda.agenda = vw_fcav_monitor_aula.agenda ) 
          AND ( ly_agenda.disciplina = vw_fcav_monitor_aula.disciplina ) ) 
        AND ( ly_agenda.turma = vw_fcav_monitor_aula.turma )) 
       LEFT OUTER JOIN lyceum.dbo.vw_fcav_reposicao_aula VW_FCAV_REPOSICAO_AULA 
                    ON 
       ( ly_agenda.reposicao = vw_fcav_reposicao_aula.reposicao ) 
       AND ( ly_agenda.agenda = vw_fcav_reposicao_aula.agenda ) 
WHERE  ly_agenda.disciplina = 'CCPLGP-DLF' 
       AND ly_agenda.turma = 'CCPLGP T 01' 
       AND ly_matricula.sit_matricula = 'Matriculado' 
       AND ly_agenda.lista = 57364 
ORDER  BY ly_aluno.nome_compl

