/*      
  VIEW VW_FCAV_LISTA_LANCHES       
    
Finalidade: Utilizado para trazer a quantidade de alunos da disciplinas com quantidade de lanches, contando com monitores se houver.    
    
Autor: Gabriel Serrano Scalione      
Data: 20/12/2017      
*/     
ALTER VIEW VW_FCAV_LISTA_LANCHES     
AS     
  SELECT DATA,     
         DIA,     
         HORA_INICIO,     
         HORA_FIM,     
         AG.TURMA,     
         AG.DISCIPLINA,     
         NOME_DISCIPLINA,     
         CATEGORIA,     
         UNIDADE,     
         SALA,     
         DOCENTE,     
         Count(ALUNO)     
         AS ALUNOS,     
         Count(ALUNO) + 1 + CASE WHEN EXISTS(SELECT 1 FROM VW_FCAV_MONITOR_AULA     
         MO WHERE MO.DISCIPLINA = AG.DISCIPLINA AND MO.DATA = AG.DATA )THEN 1     
         ELSE 0 END     
         AS LANCHES,     
         CANCELADA     
  FROM   VW_FCAV_AGENDA_ALUNO_DISCIPLINA AG     
  where     
 TURMA not like 'A-PDT%'    
  GROUP  BY DATA,     
            DIA,     
            HORA_INICIO,     
            HORA_FIM,     
            TURMA,     
            DISCIPLINA,     
            NOME_DISCIPLINA,     
            CATEGORIA,     
            UNIDADE,     
            SALA,     
            DOCENTE,     
            CANCELADA 