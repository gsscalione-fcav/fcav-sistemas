--* ***************************************************************   
--*   
--*  *** VIEW VW_FCAV_MATRICULA_E_PRE_MATRICULA  ***   
--*    
--* DESCRICAO:   
--* - View criada para que verifique os Centro de Custos cadastrados no HADES.dbo.ITEMTABELA e não vinculados na TURMA.  
--*   
--* PARAMETROS:   
--* - Como a tabela HADES.dbo.ITEMTABELA não possui uma chave primária, utilizei left outer join o campo DESCR  
--* comparando com o concurso ou com turma, retirando os espaços e traços, para trazer o registro correto.  
--*   
--* USO:   
--* - O uso será para auxiliar a identificar as TURMAS/DISCIPLINAS que ainda não possuem centro de custo cadastrado.  
--*   
--* ALTERAÇÕES:   
--*   
--*   
--* Autor: Gabriel   
--* Data de criação: 27/03/2014   
--*   
--* ***************************************************************   
ALTER VIEW VW_FCAV_MATRICULA_E_PRE_MATRICULA 
AS 
  SELECT C.FACULDADE, 
         AL.CURSO, 
         AL.TURNO, 
         AL.CURRICULO, 
         ANO, 
         SEMESTRE, 
         AL.CONCURSO, 
         DISCIPLINA, 
         'N' AS DISPENSADA, 
         TURMA, 
         AL.PESSOA, 
         MA.ALUNO, 
         AL.NOME_COMPL, 
         CASE 
           WHEN SIT_MATRICULA LIKE 'Aprovado' 
                 OR SIT_MATRICULA LIKE 'Rep Nota' 
                 OR SIT_MATRICULA LIKE 'Rep Freq' THEN 'Matriculado' 
           ELSE SIT_MATRICULA 
         END AS SIT_MATRICULA, 
         DT_MATRICULA, 
         LANC_DEB, 
         DT_ULTALT, 
         SERIE_CALCULO, 
         COBRANCA_SEP, 
         SIT_DETALHE, 
         GRUPO_ELETIVA, 
         DT_INSERCAO 
  FROM   LY_MATRICULA MA 
         INNER JOIN LY_ALUNO AL 
                 ON ( AL.ALUNO = MA.ALUNO ) 
         INNER JOIN LY_CURSO C 
                 ON C.CURSO = AL.CURSO 
  GROUP  BY C.FACULDADE, 
            AL.CURSO, 
            AL.TURNO, 
            AL.CURRICULO, 
            ANO, 
            SEMESTRE, 
            AL.CONCURSO, 
            DISCIPLINA, 
            TURMA, 
            AL.PESSOA, 
            MA.ALUNO, 
            AL.NOME_COMPL, 
            SIT_MATRICULA, 
            DT_MATRICULA, 
            LANC_DEB, 
            DT_ULTALT, 
            SERIE_CALCULO, 
            COBRANCA_SEP, 
            SIT_DETALHE, 
            GRUPO_ELETIVA, 
            DT_INSERCAO 
  UNION ALL 
  SELECT C.FACULDADE, 
         AL.CURSO, 
         AL.TURNO, 
         AL.CURRICULO, 
         ANO, 
         SEMESTRE, 
         AL.CONCURSO, 
         DISCIPLINA, 
         DISPENSADA, 
         TURMA, 
         AL.PESSOA, 
         PM.ALUNO, 
         AL.NOME_COMPL, 
         'Pre-Matriculado' SIT_MATRICULA, 
         DT_CONFIRMACAO    AS DT_MATRICULA, 
         LANC_DEB, 
         DT_ULTALT, 
         SERIE_CALCULO, 
         COBRANCA_SEP, 
         SIT_DETALHE, 
         GRUPO_ELETIVA, 
         DT_INSERCAO 
  FROM   LY_PRE_MATRICULA PM 
         INNER JOIN LY_ALUNO AL 
                 ON ( PM.ALUNO = AL.ALUNO ) 
         INNER JOIN LY_CURSO C 
                 ON C.CURSO = AL.CURSO 
  GROUP  BY C.FACULDADE, 
            AL.CURSO, 
            AL.TURNO, 
            AL.CURRICULO, 
            ANO, 
            SEMESTRE, 
            AL.CONCURSO, 
            DISCIPLINA, 
            DISPENSADA, 
            TURMA, 
            AL.PESSOA, 
            PM.ALUNO, 
            AL.NOME_COMPL, 
            DT_CONFIRMACAO, 
            LANC_DEB, 
            DT_ULTALT, 
            SERIE_CALCULO, 
            COBRANCA_SEP, 
            SIT_DETALHE, 
            GRUPO_ELETIVA, 
            DT_INSERCAO 
 UNION ALL
   SELECT C.FACULDADE, 
         AL.CURSO, 
         AL.TURNO, 
         AL.CURRICULO, 
         ANO, 
         SEMESTRE, 
         AL.CONCURSO, 
         DISCIPLINA, 
         'N' AS DISPENSADA, 
         TURMA, 
         AL.PESSOA, 
         HI.ALUNO, 
         AL.NOME_COMPL, 
         CASE 
           WHEN HI.SITUACAO_HIST LIKE 'Aprovado' 
                 OR HI.SITUACAO_HIST LIKE 'Rep Nota' 
                 OR HI.SITUACAO_HIST LIKE 'Rep Freq' THEN 'Matriculado' 
           ELSE  HI.SITUACAO_HIST
         END AS SIT_MATRICULA, 
         al.DT_INGRESSO as DT_MATRICULA, 
         LANC_DEB, 
         DT_ULTALT, 
         NULL AS SERIE_CALCULO, 
         COBRANCA_SEP, 
         SIT_DETALHE, 
         GRUPO_ELETIVA, 
         DT_MATRICULA DT_INSERCAO 
  FROM   LY_HISTMATRICULA HI 
         INNER JOIN LY_ALUNO AL 
                 ON ( AL.ALUNO = HI.ALUNO ) 
         INNER JOIN LY_CURSO C 
                 ON C.CURSO = AL.CURSO 
  GROUP  BY C.FACULDADE, 
            AL.CURSO, 
            AL.TURNO, 
            AL.CURRICULO, 
            ANO, 
            SEMESTRE, 
            AL.CONCURSO, 
            DISCIPLINA, 
            TURMA, 
            AL.PESSOA, 
            HI.ALUNO, 
            AL.NOME_COMPL, 
            HI.SITUACAO_HIST, 
            AL.DT_INGRESSO, 
            LANC_DEB, 
            DT_ULTALT, 
            COBRANCA_SEP, 
            SIT_DETALHE, 
            GRUPO_ELETIVA, 
            HI.DT_MATRICULA