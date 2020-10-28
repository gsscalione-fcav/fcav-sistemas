/*   
************************ VIEW VW_FCAV_INSCRITOS *************************************   
  
DESCRIÇÃO: View utilizada no ApoioWeb nas opções Resumo de Inscrições Total e por período   
  
ALTERAÇÕES:   
  
Autor: Gabriel S Scalione   
Data: 2016-03-09 16:28:47.403   
*/   
ALTER VIEW VW_FCAV_INSCRITOS   
AS   
  SELECT CA.CONCURSO,   
         ISNULL(CO.TIPO_INGRESSO, 'Inscricao_Site') AS TIPO_INGRESSO,  
         CA.CANDIDATO,   
         CA.NOME_COMPL,   
         lower(P.E_MAIL)as E_MAIL,   
		 '('+ p.DDD_FONE_CELULAR +')' + ' '+ p.CELULAR as NUM_CELULAR,
         isnull(CA.DT_INSCRICAO, FC.DATA_INSC) AS DT_INSCRICAO,   
         CASE   
           WHEN CA.DT_INSCRICAO IS NULL THEN 'X'   
           ELSE CV.MATRICULADO   
         END                                   AS MATRICULADO,   
         'S'                                   AS INSCR_INTERNET,   
         FC.DATA_INSC,   
         FC.CONVOCADO,   
         CA.OBS   
  FROM   LY_CANDIDATO CA   
         LEFT JOIN LY_CONVOCADOS_VEST CV   
                ON CA.CANDIDATO = CV.CANDIDATO   
                   AND CA.CONCURSO = CV.CONCURSO   
         INNER JOIN FCAV_CANDIDATOS FC   
                 ON CA.CANDIDATO = FC.CANDIDATO   
                    AND CA.CONCURSO = FC.CONCURSO   
         INNER JOIN LY_CONCURSO CO   
                 ON CO.CONCURSO = CA.CONCURSO
		 INNER JOIN LY_PESSOA P   
                 ON P.PESSOA = CA.PESSOA
  GROUP  BY CA.CONCURSO,   
            CO.TIPO_INGRESSO,   
            CA.CANDIDATO,   
            CA.NOME_COMPL,   
            P.E_MAIL,   
			P.DDD_FONE_CELULAR,
			P.CELULAR,
            CA.DT_INSCRICAO,   
            CV.MATRICULADO,   
            CA.INSCR_INTERNET,   
            FC.DATA_INSC,   
            FC.CONVOCADO,   
            CA.OBS   
  UNION ALL   
  SELECT MP.TURMA        CONCURSO,   
         'Venda Direta'  AS TIPO_INGRESSO,   
         ALUNO           AS CANDIDATO,   
         MP.NOME_COMPL,   
         lower(P.E_MAIL) as E_MAIL,
		 '('+ p.DDD_FONE_CELULAR +')' + ' '+ p.CELULAR as NUM_CELULAR,  
         MP.DT_MATRICULA DT_INSCRICAO,  
   CASE WHEN mp.SIT_ALUNO = 'Cancelado' Then 'X'  
   ELSE  
         'S' END      AS MATRICULADO,   
         'S'             AS INSCR_INTERNET,   
         MP.DT_MATRICULA AS DATA_INSC,   
         '1'             AS CONVOCADO,   
         '-'             AS OBS   
  FROM   VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP   
         INNER JOIN LY_PESSOA P   
                 ON P.PESSOA = MP.PESSOA   
         INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA T   
                 ON T.TURMA = MP.TURMA   
  WHERE  T.TP_INGRESSO = 'VD'   
  GROUP  BY MP.TURMA,   
            ALUNO,   
            MP.NOME_COMPL,   
            P.E_MAIL,
			P.DDD_FONE_CELULAR,
			P.CELULAR,   
			mp.SIT_ALUNO ,  
            MP.DT_MATRICULA 