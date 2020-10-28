/*   
	 VIEW VW_FCAV_DASHBOARD_EVADIDOS   

Finalidade: VIEW para consultar os alunos que foram cancelados ou trancados após o inicio da turma,    
   
Autor: Gabriel Scalione   
Data:  09/03/2018   
   
*/ 
ALTER VIEW VW_FCAV_DASHBOARD_EVADIDOS 
AS 
  SELECT CASE WHEN CO.GRUPO = '-CERT' or co.NOME_COMPL = 'José Joaquim do Amaral Ferreira' THEN 'Certificação'
		 WHEN mp.faculdade = 'Online' OR mp.faculdade = 'Semipresencial' THEN 'Paulista'
		ELSE CO.UNID_FISICA
		END AS GRUPO_RESP,
		CASE WHEN mp.unidade_responsavel = 'ATUAL' AND mp.FACULDADE = 'USP' THEN 'DIFUSAO'
			ELSE mp.UNIDADE_RESPONSAVEL 
		END AS UNID_RESP,  
         MP.CURSO, 
         MP.TURMA, 
         VT.DT_INICIO, 
         VT.DT_FIM, 
         HC.ALUNO, 
         MP.NOME_COMPL, 
         DT_ENCERRAMENTO                              AS DT_EVASAO, 
         DBO.fn_fcav_primeira_maiuscula(MOTIVO)       MOTIVO, 
         DBO.fn_fcav_primeira_maiuscula(CAUSA_ENCERR) AS CAUSA, 
         ''                                           AS OBS 
  FROM   LY_H_CURSOS_CONCL HC 
         INNER JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP 
                 ON MP.ALUNO = HC.ALUNO 
         INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT 
                 ON VT.TURMA = MP.TURMA 
         INNER JOIN VW_FCAV_COORDENADOR_TURMA CO 
                 ON CO.TURMA = VT.TURMA 
  WHERE  HC.DT_REABERTURA IS NULL 
         AND HC.DT_ENCERRAMENTO > VT.DT_INICIO 
         AND HC.DT_ENCERRAMENTO <= VT.DT_FIM 
         AND MP.TURMA = VT.TURMA
		 AND CO.TIPO_COORD = 'Coord'
  GROUP  BY CO.GRUPO, 
            CO.UNID_FISICA, 
            CO.NOME_COMPL, 
			mp.FACULDADE,
            MP.UNIDADE_RESPONSAVEL, 
            MP.CURSO, 
            MP.TURMA, 
            VT.DT_INICIO, 
            VT.DT_FIM, 
            HC.ALUNO, 
            MP.NOME_COMPL, 
            DT_ENCERRAMENTO, 
            MOTIVO, 
            CAUSA_ENCERR 
  UNION ALL 
  SELECT CASE WHEN CO.GRUPO = '-CERT' or co.NOME_COMPL = 'José Joaquim do Amaral Ferreira' THEN 'Certificação'
		 WHEN mp.faculdade = 'Online' OR mp.faculdade = 'Semipresencial' THEN 'Paulista'
		ELSE CO.UNID_FISICA
		END AS GRUPO_RESP,
		CASE WHEN mp.unidade_responsavel = 'ATUAL' AND mp.FACULDADE = 'USP' THEN 'DIFUSAO'
			ELSE mp.UNIDADE_RESPONSAVEL 
		END AS UNID_RESP,  
         MP.CURSO, 
         MP.TURMA, 
         VT.DT_INICIO, 
         VT.DT_FIM, 
         TR.ALUNO, 
         MP.NOME_COMPL, 
         TR.DT_INI                                    AS DT_EVASAO, 
         DBO.fn_fcav_primeira_maiuscula(MT.DESCRICAO) AS MOTIVO, 
         DBO.fn_fcav_primeira_maiuscula(CT.DESCRICAO) AS CAUSA, 
         TR.OBS 
  FROM   LY_TRANC_INTERV_DATA TR 
         LEFT JOIN LY_MOTIVO_TRANCAMENTO MT 
                ON MT.MOTIVO_TRANC = TR.MOTIVO_TRANC 
         LEFT JOIN LY_CAUSA_TRANCAMENTO CT 
                ON CT.CAUSA_TRANC = TR.CAUSA_TRANC 
         LEFT JOIN VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP 
                ON MP.ALUNO = TR.ALUNO 
         INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT 
                 ON VT.TURMA = MP.TURMA 
         INNER JOIN VW_FCAV_COORDENADOR_TURMA CO 
                 ON CO.TURMA = VT.TURMA 
  WHERE  TR.DT_REABERTURA IS NULL 
         AND TR.DT_INI > VT.DT_INICIO 
         AND TR.DT_INI <= VT.DT_FIM 
         AND MP.TURMA = VT.TURMA 
  GROUP  BY CO.GRUPO, 
            CO.UNID_FISICA, 
            CO.NOME_COMPL, 
            MP.UNIDADE_RESPONSAVEL, 
            MP.CURSO, 
            MP.TURMA, 
			mp.FACULDADE,
            VT.DT_INICIO, 
            VT.DT_FIM, 
            TR.ALUNO, 
            MP.NOME_COMPL, 
            TR.DT_INI, 
            MT.DESCRICAO, 
            CT.DESCRICAO, 
            TR.OBS 