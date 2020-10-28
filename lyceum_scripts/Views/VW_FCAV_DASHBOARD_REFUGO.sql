/*   
   
 VIEW VW_FCAV_DASHBOARD_REFUGO   
   
   
   
 VIEW PARA TRAZER OS INSCRITOS QUE FICARAM DE LADO, OU SEJA, NÃO FOI TOMADO NENHUMA AÇÃO   
   
   
   
 UTILIZADO:   
   
   - PLANILHA DO DASHBOARD   
   
   
   
Autor: Gabriel Scalione   
   
Data: 13/03/2017   
   
   
   
*/ 
ALTER VIEW VW_FCAV_DASHBOARD_REFUGO 
AS 
  SELECT CASE 
           WHEN CO.GRUPO = '-CERT' 
                 OR CO.NOME_COMPL = 'José Joaquim do Amaral Ferreira' THEN 
           'Certificação' 
           ELSE CO.UNID_FISICA 
         END                       AS GRUPO_RESP, 
         VT.UNIDADE_RESPONSAVEL    UNID_RESP, 
         VT.CURSO, 
         VT.OFERTA_DE_CURSO, 
         VT.CONCURSO, 
         VT.TURMA, 
         (SELECT TOP 1 CASE 
                         WHEN CLASSIFICACAO NOT LIKE 'Cancel%' 
                              AND VT.DT_INICIO > Getdate() THEN 'Em Inscrição' 
                         WHEN CLASSIFICACAO NOT LIKE 'Cancel%' 
                              AND ( Getdate() BETWEEN VT.DT_INICIO AND 
                                  VT.DT_FIM ) 
                       THEN 
                         'Em Andamento' 
                         WHEN CLASSIFICACAO NOT LIKE 'Cancel%' 
                              AND VT.DT_FIM < Getdate() THEN 'Concluido' 
                         WHEN CLASSIFICACAO LIKE 'Cancel%' THEN 'Cancelada' 
                         ELSE 'NÃO CLASSIFICADA' 
                       END 
          FROM   LY_TURMA TU 
          WHERE  TU.TURMA = VT.TURMA 
                 AND TU.SERIE = 1 
          GROUP  BY CLASSIFICACAO) AS SITUACAO_TURMA, 
         VT.DT_INICIO, 
         VT.DT_FIM, 
         PE.PESSOA, 
         TCA.INSCRITO, 
         PE.NOME_COMPL, 
         PE.CPF, 
         PE.E_MAIL, 
         PE.DDD_FONE, 
         PE.FONE, 
         PE.DDD_FONE_CELULAR       AS DDD_CELULAR, 
         PE.CELULAR, 
         TCA.DT_INSCRICAO, 
         TCA.SITUACAO              AS SIT_CANDIDATO, 
         CASE 
           WHEN EXISTS (SELECT 1 
                        FROM   LY_CONVOCADOS_VEST 
                        WHERE  CANDIDATO = TCA.INSCRITO 
                               AND CONCURSO = TCA.CONCURSO) THEN 'CONVOCADO' 
           ELSE 'NÃO CONVOCADO' 
         END                       SIT_CONVOCADO, 
         AL.DT_MATRICULA           DT_INGRESSO, 
         AL.ALUNO, 
         AL.SIT_ALUNO, 
         AL.SIT_MATRICULA, 
         CASE 
           WHEN TCA.CONCURSO IS NULL THEN 'Venda Direta' 
           ELSE 'Processo Seletivo' 
         END                       AS TIPO_INGRESSO,
		 format(TCA.DT_INSCRICAO, 'MMM/yyyy', 'pt-br') AS MES_ANO_INSC
  FROM   VW_FCAV_CANDIDATOS_E_ALUNOS TCA 
         LEFT JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA AL 
                ON CASE 
                     WHEN AL.CANDIDATO IS NULL THEN AL.ALUNO 
                     ELSE AL.CANDIDATO 
                   END = TCA.INSCRITO 
         LEFT JOIN LY_PESSOA PE 
                ON PE.PESSOA = TCA.PESSOA 
         LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT 
                ON VT.OFERTA_DE_CURSO = TCA.OFERTA_DE_CURSO 
         INNER JOIN VW_FCAV_COORDENADOR_TURMA CO 
                 ON CO.TURMA = VT.TURMA 
  WHERE  ( AL.SIT_MATRICULA != 'Matriculado' 
           AND AL.SIT_ALUNO != 'Cancelado' ) 
          OR ( TCA.SITUACAO != 'Cancelado' 
               AND AL.SIT_MATRICULA IS NULL ) 
  GROUP  BY VT.DT_INICIO, 
            VT.DT_FIM, 
            VT.OFERTA_DE_CURSO, 
            VT.UNIDADE_RESPONSAVEL, 
            VT.CURSO, 
            VT.TURMA, 
            VT.CONCURSO, 
            PE.PESSOA, 
            PE.NOME_COMPL, 
            PE.CPF, 
            PE.E_MAIL, 
            PE.DDD_FONE, 
            PE.FONE, 
            PE.DDD_FONE_CELULAR, 
            PE.CELULAR, 
            TCA.OFERTA_DE_CURSO, 
            TCA.CONCURSO, 
            TCA.CURSO, 
            TCA.INSCRITO, 
            TCA.DT_INSCRICAO, 
            TCA.SITUACAO, 
            TCA.TURMA, 
            AL.DT_MATRICULA, 
            AL.ALUNO, 
            AL.SIT_ALUNO, 
            AL.SIT_MATRICULA, 
            CO.TIPO_COORD, 
            CO.GRUPO, 
            CO.NOME_COMPL, 
            CO.UNID_FISICA 