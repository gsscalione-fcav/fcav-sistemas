 DROP TABLE #TMP_VALOR_CURSO
 
 --TABELA TEMPORÁRIA PARA TRAZER O VALOR DOS SERVIÇOS VINCULADOS AOS CURSOS  
  SELECT  
    ST.CURSO,  
    ST.TURNO,  
    ST.CURRICULO,  
    SP.ANO,  
    SP.PERIODO,  
    SP.SERVICO,  
    ISNULL(SP.CUSTO_UNITARIO, 0) AS VALOR INTO #TMP_VALOR_CURSO  
  
  FROM LY_VALOR_SERV_PERIODO SP  
  INNER JOIN VW_FCAV_SERVICO_TURMA ST  
    ON (ST.SERVICO = SP.SERVICO  
    AND ST.ANO = SP.ANO  
    AND ST.SEMESTRE = SP.PERIODO)  
  WHERE SP.SERVICO LIKE 'MENS%'  
  
  UNION    --optou-se por usar o UNION, porque só com os parâmetros do join retornava mais de um resultado.  
  
  SELECT  
    SM.CURSO,  
    SM.TURNO,  
    SM.CURRICULO,  
    SP.ANO,  
    SP.PERIODO,  
    SP.SERVICO,  
    ISNULL(SP.CUSTO_UNITARIO, 0) AS VALOR  
  FROM LY_VALOR_SERV_PERIODO SP  
  INNER JOIN LY_SERVICO_MATRICULA SM  
    ON (SM.SERVICO = SP.SERVICO  
    AND SM.ANO = SP.ANO  
    AND SM.PERIODO = SP.PERIODO)  
  WHERE SP.SERVICO LIKE 'MATR%'  

DECLARE @valor numeric


SELECT 
      '%%VERIFICA_MATR%%',  
      CASE  
        WHEN --@curso NOT LIKE 'CCOL' AND  
          EXISTS (SELECT  
            1  
          FROM #TMP_VALOR_CURSO VC  
          INNER JOIN LY_ALUNO AL  
            ON (AL.CURSO = VC.CURSO  
			    AND AL.TURNO = VC.TURNO  
			    AND VC.CURRICULO = AL.CURRICULO
			    AND AL.ANO_INGRESSO = VC.ANO
			    AND AL.SEM_INGRESSO = VC.PERIODO) 
          WHERE VC.SERVICO LIKE 'MATR%'  
          AND ALUNO = 'C201700091') 
          THEN 
			  'da taxa de matrícula no valor de R$ ' +  
			  REPLACE(CAST(CONVERT(money, ISNULL(MIN(VALOR), 0)) AS varchar), '.', ',') +  
			  ' (' +  
			  LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(MIN(VALOR), 0)))) +  
			  ')' +  
			  ' com vencimento em ' +  
			  CONVERT(varchar, (dbo.FN_FCAV_GetDiaUtil(GETDATE(), 1)), 103) +  
			  ' e'  
        --WHEN @curso LIKE 'CCOL' THEN 'da taxa de matrícula no valor de R$ ' + (SELECT  
        --    CASE  
        --      WHEN P.NUM_PARCELAS = 1 THEN REPLACE(CAST(CONVERT(money, ISNULL(@ValorTotal, 0)) AS varchar), '.', ',') +  
        --        ' (' + LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(@ValorTotal, 0)))) + ')'  
        --      WHEN P.NUM_PARCELAS = 5 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +  
        --        ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'  
        --      WHEN p.NUM_PARCELAS = 10 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +  
        --        ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'  
        --      WHEN p.NUM_PARCELAS = 20 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +  
        --        ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'  
        --    END  
        --  FROM LY_LANC_DEBITO L  
        --  INNER JOIN LY_ALUNO A  
        --    ON L.ALUNO = A.ALUNO  
        --  INNER JOIN LY_PLANO_PGTO_PERIODO P  
        --    ON L.ALUNO = P.ALUNO  
        --    AND L.ANO_REF = P.ANO  
        --    AND L.PERIODO_REF = P.PERIODO  
        --  LEFT JOIN LY_DESCONTO_PLANO_PGTO DP  
        --    ON A.CURSO = DP.CURSO  
        --    AND A.TURNO = DP.TURNO  
        --    AND A.CURRICULO = DP.CURRICULO  
        --    AND A.CONCURSO = DP.CONCURSO  
        --    AND P.NUM_PARCELAS = DP.NUM_PARCELAS  
        --  INNER JOIN LY_CURRICULO CR  
        --    ON A.CURSO = CR.CURSO  
        --    AND A.TURNO = CR.TURNO  
        --    AND A.CURRICULO = CR.CURRICULO  
        --  INNER JOIN LY_VALOR_SERV_PERIODO SP  
        --    ON CR.SERVICO = SP.SERVICO  
        --    AND L.ANO_REF = SP.ANO  
        --    AND L.PERIODO_REF = SP.PERIODO  
        --  WHERE A.ALUNO = @p_aluno)  
        --  +  
        --  ' com vencimento em '  
        --  +  
        --  CONVERT(varchar, (dbo.FN_FCAV_GetDiaUtil(GETDATE(), @diasvenc)), 103)  
        --  + ' e'  
        ELSE 'de'  
      END AS VERIFICA_MATR  
    FROM #TMP_VALOR_CURSO VC  
    INNER JOIN LY_ALUNO AL  
      ON (AL.CURSO = VC.CURSO  
      AND AL.TURNO = VC.TURNO  
      AND VC.CURRICULO = AL.CURRICULO
      AND AL.ANO_INGRESSO = VC.ANO
      AND AL.SEM_INGRESSO = VC.PERIODO) 
    WHERE ALUNO = 'C201700091' 