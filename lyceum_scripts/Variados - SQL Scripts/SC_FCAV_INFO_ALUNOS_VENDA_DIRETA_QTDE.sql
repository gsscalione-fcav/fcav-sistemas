SELECT 
	   isnull(DO.NOME_COMPL, 'NAO_CADASTRADO') AS NOME_COORD, 
       isnull(CO.TIPO_COORD, 'NAO_CADASTRADO') AS TIPO_COORD, 
       CS.CURSO                                AS CURSO, 
       CS.NOME                                 AS NOME_CURSO, 
       CASE 
         WHEN OC.DTFIM >= Getdate() THEN 'Abertas' 
         ELSE 'Encerradas' 
       END                                     AS INSCRICOES, 
       VT.TURMA, 
       Year(VT.DT_INICIO)                      AS ANO, 
       Month(VT.DT_INICIO)                     AS MES, 
       (SELECT TOP 1 CASE 
                       WHEN CLASSIFICACAO NOT LIKE 'Cancel%' 
                            AND VT.DT_INICIO > Getdate() THEN 'Em Inscrição' 
                       WHEN CLASSIFICACAO NOT LIKE 'Cancel%' 
                            AND ( Getdate() BETWEEN VT.DT_INICIO AND VT.DT_FIM ) 
                     THEN 
                       'Em Andamento' 
                       WHEN CLASSIFICACAO NOT LIKE 'Cancel%' 
                            AND VT.DT_FIM <= Getdate() THEN 'Concluido' 
                       WHEN CLASSIFICACAO LIKE 'Cancel%' THEN 'Cancelada' 
                     END 
        FROM   LY_TURMA TU 
        WHERE  TU.TURMA = VT.TURMA 
               AND TU.SERIE = 1 
        GROUP  BY CLASSIFICACAO)               AS SITUACAO_TURMA, 
       (SELECT Count(VD.ALUNO) 
        FROM   VW_FCAV_ALUNOS_VENDA_DIRETA VD 
        WHERE  VD.TURMA = VT.TURMA 
        GROUP  BY VD.TURMA)                    AS NUM_INSCRITOS, 
       (SELECT Count(VD.ALUNO) 
        FROM   VW_FCAV_ALUNOS_VENDA_DIRETA VD 
        WHERE  VD.TURMA = VT.TURMA 
               AND VD.SIT_MATRICULA = 'Matriculado' 
        GROUP  BY VD.TURMA)                    AS NUM_ALUNOS, 
       (SELECT Count(VD.ALUNO) 
        FROM   VW_FCAV_ALUNOS_VENDA_DIRETA VD 
        WHERE  VD.TURMA = VT.TURMA 
               AND VD.SIT_MATRICULA = 'Cancelado' 
        GROUP  BY VD.TURMA)                    AS NUM_CANCELADOS, 
       (SELECT Count(VD.VALOR_PAGO) 
        FROM   VW_FCAV_ALUNOS_VENDA_DIRETA VD 
        WHERE  VD.TURMA = VT.TURMA 
               AND ( VD.VALOR_PAGO - VD.VALOR_PAGAR ) = 0 
               AND VALOR_PAGO IS NOT NULL 
        GROUP  BY TURMA)                       AS NUM_PAGANTES, 
       (SELECT Count(VD.ALUNO) 
        FROM   VW_FCAV_ALUNOS_VENDA_DIRETA VD 
        WHERE  TURMA = VT.TURMA 
               AND VD.PERC_VALOR = 'Percentual' 
               AND VD.VALOR = 1.000000 
        GROUP  BY TURMA)                       AS NUM_CORTESIAS 
FROM   VW_FCAV_INI_FIM_CURSO_TURMA VT 
       INNER JOIN LY_CURSO CS 
               ON CS.CURSO = VT.COD_CURSO 
       INNER JOIN LY_COORDENACAO CO 
               ON CO.CURSO = CS.CURSO 
       INNER JOIN LY_DOCENTE DO 
               ON DO.NUM_FUNC = CO.NUM_FUNC 
       INNER JOIN LY_OFERTA_CURSO OC 
               ON OC.OFERTA_DE_CURSO = VT.OFERTA_DE_CURSO 
WHERE  CO.TIPO_COORD = 'COORD' 
       AND VT.UNIDADE_RESPONSAVEL IN ( 'ATUAL' ) 
GROUP  BY CS.CURSO, 
          CS.NOME, 
          VT.TURMA, 
          OC.DTINI, 
          OC.DTFIM, 
          VT.DT_INICIO, 
          VT.DT_FIM, 
          DO.NOME_COMPL, 
          CO.TIPO_COORD 