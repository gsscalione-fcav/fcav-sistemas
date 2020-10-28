SELECT DISTINCT vw_fcav_ini_fim_curso_turma.concurso, 
                ly_agenda.data, 
                ly_agenda.hora_inicio, 
                ly_agenda.hora_fim, 
                ly_agenda.disciplina, 
                ly_docente.nome_compl, 
                ly_agenda.ano, 
                ly_agenda.semestre, 
                ly_agenda.dependencia, 
                vw_fcav_link_oferta_curso_completa.descricao, 
                vw_fcav_verifica_centro_custo.centro_custo_hades, 
                vw_fcav_ini_fim_curso_turma.dt_inicio, 
                vw_fcav_ini_fim_curso_turma.dt_fim, 
                ly_disciplina.nome_compl, 
                ly_disciplina.disciplina, 
                vw_fcav_ini_fim_curso_turma.curso, 
                vw_fcav_ini_fim_curso_turma.turma, 
                vw_fcav_monitor_aula.monitor_1, 
                vw_fcav_monitor_aula.monitor_2 
FROM   (((((LYCEUM.dbo.vw_fcav_ini_fim_curso_turma 
           VW_FCAV_INI_FIM_CURSO_TURMA 
            INNER JOIN LYCEUM.dbo.ly_agenda LY_AGENDA 
                    ON vw_fcav_ini_fim_curso_turma.turma = 
                       ly_agenda.turma) 
           INNER JOIN LYCEUM.dbo.vw_fcav_link_oferta_curso_completa 
                      VW_FCAV_LINK_OFERTA_CURSO_COMPLETA 
                   ON vw_fcav_ini_fim_curso_turma.concurso = 
                      vw_fcav_link_oferta_curso_completa.concurso) 
          INNER JOIN LYCEUM.dbo.vw_fcav_verifica_centro_custo 
                     VW_FCAV_VERIFICA_CENTRO_CUSTO 
                  ON vw_fcav_ini_fim_curso_turma.concurso = 
                     vw_fcav_verifica_centro_custo.concurso) 
         INNER JOIN LYCEUM.dbo.ly_docente LY_DOCENTE 
                 ON ly_agenda.num_func = ly_docente.num_func) 
        INNER JOIN LYCEUM.dbo.ly_disciplina LY_DISCIPLINA 
                ON ly_agenda.disciplina = ly_disciplina.disciplina) 
       LEFT OUTER JOIN LYCEUM.dbo.vw_fcav_monitor_aula 
                       VW_FCAV_MONITOR_AULA 
                    ON ( 
              ( 
( ly_agenda.disciplina = vw_fcav_monitor_aula.disciplina ) 
AND ( ly_agenda.turma = vw_fcav_monitor_aula.turma ) ) 
              AND ( ly_agenda.data = vw_fcav_monitor_aula.data ) ) 
                       AND ( ly_agenda.agenda = 
                             vw_fcav_monitor_aula.agenda ) 
WHERE  vw_fcav_ini_fim_curso_turma.curso = 'A-PDT' 
       AND ly_agenda.ano = 2018 
       AND ly_agenda.semestre = 0 
       AND vw_fcav_ini_fim_curso_turma.turma = 'A-PDT T 02' 
       AND ly_agenda.disciplina = 'A-PDT' 
ORDER  BY vw_fcav_ini_fim_curso_turma.concurso, 
          ly_agenda.disciplina, 
          ly_agenda.data 



