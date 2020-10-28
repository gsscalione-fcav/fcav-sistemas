/*     
   
 VIEW VW_FCAV_DASHBOARD_CONCLUINTES     
   
     
   
 Consulta que retorna os alunos concluintes com a situação final, se foram aprovados ou reprovados na turma.    
   
     
   
 Utilizada nas planilhas:     
   
  Relação de alunos Concluintes     
   
  DASHBOARD_2018     
   
     
   
Autor: Gabriel Scalione     
   
Data: 09/03/2018     
   
*/ 
ALTER VIEW VW_FCAV_DASHBOARD_CONCLUINTES 
AS 
  SELECT CASE WHEN CO.GRUPO = '-CERT' or co.NOME_COMPL = 'José Joaquim do Amaral Ferreira' THEN 'Certificação'
		 WHEN mp.faculdade = 'Online' OR mp.faculdade = 'Semipresencial' THEN 'Paulista'
		ELSE CO.UNID_FISICA
	END AS GRUPO_RESP,
    CASE WHEN mp.unidade_responsavel = 'ATUAL' AND mp.FACULDADE = 'USP' THEN 'DIFUSAO'
		ELSE mp.UNIDADE_RESPONSAVEL 
	END AS UNID_RESP,   
         MA.CURSO, 
         MA.TURMA, 
         DT_INICIO, 
         MA.DT_FIM, 
         SITUACAO_TURMA, 
         MA.ALUNO, 
         MA.NOME_COMPL, 
         MP.DT_MATRICULA, 
		 MP.SIT_MATRICULA,
		 MP.SIT_ALUNO,
         Cast(( Sum(NOTA_FINAL) / Count(DISCIPLINA) ) AS DECIMAL(10, 2)) AS 
            MEDIA_FINAL, 
         Cast(( Sum(FREQUENCIA) / Count(DISCIPLINA) ) AS DECIMAL(10, 2)) AS 
            FREQ_FINAL, 
         CASE 
           WHEN Cast(( Sum(NOTA_FINAL) / Count(DISCIPLINA) ) AS DECIMAL(10, 2)) 
                >= 
                7.0 
                AND Cast(( Sum(FREQUENCIA) / Count(DISCIPLINA) ) AS 
                         DECIMAL(10, 2) 
                    ) >= 83 
         THEN 'Aprovado' 
           ELSE 'Reprovado' 
         END   AS  SITUACAO_FINAL 
  FROM   VW_FCAV_MEDIA_FINAL_ALUNOS MA 
         INNER JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP 
                 ON MP.TURMA = MA.TURMA 
                    AND MP.ALUNO = MA.ALUNO 
         INNER JOIN VW_FCAV_COORDENADOR_TURMA CO 
                 ON CO.TURMA = MA.TURMA 
  WHERE 
	CO.TIPO_COORD = 'Coord'

  GROUP  BY CO.GRUPO, 
            CO.UNID_FISICA, 
            CO.NOME_COMPL, 
            UNID_RESP,
			mp.FACULDADE,
			mp.unidade_responsavel,
            MA.CURSO, 
            MA.TURMA, 
            DT_INICIO, 
            MA.DT_FIM, 
            SITUACAO_TURMA, 
            MA.ALUNO, 
            MA.NOME_COMPL, 
            MP.DT_MATRICULA,
			MP.SIT_MATRICULA,
			MP.SIT_ALUNO