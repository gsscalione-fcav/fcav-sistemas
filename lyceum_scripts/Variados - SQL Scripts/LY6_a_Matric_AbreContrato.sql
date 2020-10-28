--* ***************************************************************  
--*  
--*         *** Procedure a_Matric_AbreContrato  ***  
--*    
--*   DESCRICAO:  
--*  - Está procedure foi criada pela Techne e por isso o nome dela   
--*  não possui o padrão fcav como está no nome.  
--*    
--*  - Procedure para criação de TAG's para serem incluídas no contrato   
--*  do Aluno após o ACEITE na finalização da matrícula(modo online).   
--*  
--*   PARAMETROS:  
--*     São utilizados conforme as tags são criadas para filtrar   
--*     o aluno referente ao curso e oferta de curso.  
--*  
--*      
--*   USO:  
--*  - É utilizado para incluir informações de Aluno, Valor, Data e Curso   
--*  no contrato que será visualizado pelo aluno no final do processo de Pré-matricula,   
--*  após do Aceite.   
--*  
--*   ALTERAÇÕES:  
--*		12/12/2013 - Colocando textos curtos para as TAGs. Por Gabriel S Scalione
--*		15/02/2014 - Acrescentado as TAGs que verifica se o curso possui TCC e se o curso possui taxa de matricula.  Por Gabriel S Scalione
--*		02/04/2014 - Verifica quando o curso for o CEAI para retornar o tipo de plano escolhido, Bienal ou Anual.  Por Gabriel S Scalione
--*		10/07/2014 - Verifica quando o curso for o CCOL para retornar o tipo de plano escolhido, valores de matricula e mensalidade.  Por Gabriel S Scalione
--*		06/10/2014 - Alteração das referente a CARGA HORARIA do curso, que agora traz somente a carga horária do curso, com base no cadastro do curriculo. Por Gabriel S Scalione
--*		09/01/2015 - Alteração da verificação da data de vencimento do boleto de matricula para PJ, se for PJ o sistema colocado número de dias com base no cadastro da tabela geral no HADES, item DiasVencPessJuridica. Por Gabriel S Scalione
--*		10/11/2015 - Acrescentado a TAG para trazer a data de vencimento da primeira mensalidade. Por Gabriel S Scalione
--*		01/02/2017 - Corração das TAGS e Otimização da EP, pois apresentava problema com cursos e o contrato não estava sendo gerado.
--*
--*   Autor: Gabriel Scalione  
--*		Data de criação:  11/11/2013 
--*  
--* **************************************************************


ALTER PROCEDURE a_Matric_AbreContrato  --sempre que criar uma tag nova, executar novamente a alteração da procedure.  
(@p_aluno AS T_CODIGO,
@p_ano AS T_ANO,
@p_periodo AS T_SEMESTRE2,
@p_ofertaCurso AS T_NUMERO,
@p_tabela_plano_pgto AS varchar(50))
AS

BEGIN

  CREATE TABLE #TAGS_RETORNO (
    TAG varchar(200),
    VALOR varchar(200)
  )
  ---------------------------------------------------------------      
  --[INÍCIO CUSTOMIZAÇÃO]      
  --------------------------------------------------------------- 
  --VARIÁVEIS 
  DECLARE @diasvenc int
  DECLARE @ValorTotal numeric
  DECLARE @curso varchar(20)

  ---------------------------------------------------------------

  --Identifica o curso do aluno
  SELECT
    @curso = CURSO
  FROM LY_ALUNO
  WHERE ALUNO = @p_aluno

  --BLOCO VERIFICA NUMERO DE DIAS VENCIMENTO 
  IF EXISTS (SELECT
      1
    FROM LY_PLANO_PGTO_INSCRONLINE P
    JOIN LY_RESP_FINAN R
      ON P.RESP = R.RESP
    WHERE R.CGC_TITULAR IS NOT NULL
    AND P.ALUNO = @p_aluno)
  BEGIN
    SELECT
      @diasvenc = CONVERT(int, DESCR)
    FROM HADES..HD_TABELAITEM
    WHERE TABELA = 'DiasVencPessJuridica'
    AND ITEM = 'DIAS'
  END
  ELSE
  BEGIN
    SELECT
      @diasvenc = ISNULL(N_DIAS_VENC_BOL_MATR, 0)
    FROM LY_CONCURSO CO
    INNER JOIN LY_OFERTA_CURSO OC
      ON (OC.CONCURSO = CO.CONCURSO)
    WHERE OC.OFERTA_DE_CURSO = @p_ofertaCurso

  END -- FIM DO BLOCO NUMERO DE DIAS VENCIMENTO

  --EXTRAIR O VALOR TOTAL DO CURSO CCOL
  IF @curso = 'CCOL'
  BEGIN
    SELECT
      @ValorTotal = ISNULL(CONVERT(int, DESCR), 0)
    FROM HD_TABELAITEM T
    INNER JOIN LY_ALUNO A
      ON SUBSTRING(T.ITEM, 1, 4) = A.CURSO
      AND SUBSTRING(T.ITEM, 6, 4) = CAST(A.ANO_INGRESSO AS varchar)
      AND SUBSTRING(T.ITEM, 11, 1) = CAST(A.SEM_INGRESSO AS varchar)
    WHERE A.ALUNO = @p_aluno
  END

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

  UNION				--optou-se por usar o UNION, porque só com os parâmetros do join retornava mais de um resultado.

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

  ------------------------------------------------------------	
  --Inicio das TAGS

  ------------------------------------------------------------
  --Retorna o Presidente da FCAV
  INSERT INTO #TAGS_RETORNO (tag, valor)
    SELECT DISTINCT
      '%%NOME_PRESIDENTE%%',
      NOME_COMPL AS NOME_PRESIDENTE
    FROM LY_DOCENTE
    WHERE TITULACAO LIKE 'Presidente da Diretoria Executiva'

  INSERT INTO #TAGS_RETORNO (tag, valor)
    SELECT DISTINCT
      '%%EST_CIVIL_PRESIDENTE%%',
      LOWER(EST_CIVIL) AS EST_CIVIL_PRESIDENTE
    FROM LY_DOCENTE
    WHERE TITULACAO LIKE 'Presidente da Diretoria Executiva'

  INSERT INTO #TAGS_RETORNO (tag, valor)
    SELECT DISTINCT
      '%%CPF_PRESIDENTE%%',
      dbo.FN_FCAV_formatarCNPJCPF(CPF) AS CPF_PRESIDENTE
    FROM LY_DOCENTE
    WHERE TITULACAO LIKE 'Presidente da Diretoria Executiva'

  INSERT INTO #TAGS_RETORNO (tag, valor)
    SELECT DISTINCT
      '%%RG_PRESIDENTE%%',
      RG_NUM + ' - ' + RG_EMISSOR + '/' + RG_UF AS RG_PRESIDENTE
    FROM LY_DOCENTE
    WHERE TITULACAO LIKE 'Presidente da Diretoria Executiva'

  ------------------------------------------------------------
  --Retorna a duração do curso
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%DURACAO_PREV%%',
      ISNULL((CAST(CR.PRAZO_CONC_PREV AS varchar) +
      ' (' +
      LTRIM(dbo.Numero_Extenso(CR.PRAZO_CONC_PREV)) +
      ') ' +
      CR.TIPO_PRAZO_CONCL), '0') AS DURACAO_PREV
    FROM LY_CURRICULO CR
    INNER JOIN LY_ALUNO AL
      ON (AL.CURSO = CR.CURSO
      AND AL.TURNO = CR.TURNO
      AND AL.CURRICULO = CR.CURRICULO)
    WHERE AL.ALUNO = @p_aluno
    )

  ------------------------------------------------------------
  --Retorna o número de disciplinas
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%NUM_DISCIPLINAS%%',
      CASE
        WHEN @curso = 'CEAI' THEN CAST(11 AS varchar)
          + ' (' + dbo.Numero_Extenso(11)
          + ')'
        ELSE CAST(COUNT(GR.DISCIPLINA) AS varchar)
          + ' (' + LTRIM(dbo.Numero_Extenso(COUNT(GR.DISCIPLINA)))
          + ')'
      END AS NUM_DISCIPLINAS
    FROM LY_GRADE GR
    INNER JOIN LY_ALUNO AL
      ON (AL.CURSO = GR.CURSO
      AND AL.TURNO = GR.TURNO
      AND AL.CURRICULO = GR.CURRICULO)
    WHERE AL.ALUNO = @p_aluno
    )

  ------------------------------------------------------------
  --Retorna o prazo máximo de conclusão do curso
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%PRAZO_MAXIMO%%',
      ISNULL(CAST(CR.PRAZO_MAX AS varchar) +
      ' (' +
      dbo.Numero_Extenso(CR.PRAZO_MAX) +
      ') ' +
      CR.TIPO_PRAZO_CONCL, '0') AS PRAZO_MAXIMO
    FROM LY_CURRICULO CR
    INNER JOIN LY_ALUNO AL
      ON (AL.CURSO = CR.CURSO
      AND AL.TURNO = CR.TURNO
      AND AL.CURRICULO = CR.CURRICULO)
    WHERE AL.ALUNO = @p_aluno
    )

  ------------------------------------------------------------
  --Retorna a carga horária total do curso
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%CARGA_HORARIA_TOTAL%%',
      ISNULL(CAST(CAST(CR.AULAS_PREVISTAS AS int) AS varchar), '0') +
      ' (' +
      LTRIM(dbo.Numero_Extenso(CR.AULAS_PREVISTAS)) +
      ') ' AS CARGA_HORARIA_TOTAL
    FROM LY_CURRICULO CR
    INNER JOIN LY_ALUNO AL
      ON (AL.CURSO = CR.CURSO
      AND AL.TURNO = CR.TURNO
      AND AL.CURRICULO = CR.CURRICULO)
    WHERE AL.ALUNO = @p_aluno
    )

  ----------------------------------------------------------
  --Retorna a data de vencimento do boleto de pré-matricula
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%DT_VENC_MATR%%',
      CONVERT(varchar, (dbo.FN_FCAV_GetDiaUtil(GETDATE(), @diasvenc)), 103)
      AS DT_VENC_MATR

    )

  ----------------------------------------------------------
  --Retorna a data de vencimento da primeira mensalidade
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%DT_VENC_MENS1%%',
      CONVERT(varchar, (DATEADD(MS, -1, DATEADD(MM, DATEDIFF(MM, 0, DT_INICIO), 0)) + 14), 103)
      AS DT_VENC_MENS1
    FROM VW_FCAV_INI_FIM_CURSO_TURMA CT
    WHERE CT.OFERTA_DE_CURSO = @p_ofertaCurso
    )

  ----------------------------------------------------------
  --Retorna o valor total do curso
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%VALOR_TOTAL%%',
      CASE
        WHEN @curso NOT LIKE 'CCOL' THEN REPLACE(CAST(CONVERT(money, SUM(VALOR)) AS varchar), '.', ',') +
          ' (' + LTRIM(dbo.Money_Extenso(CONVERT(money, SUM(VALOR)))) + ')'
        ELSE REPLACE(CAST(CONVERT(money, @ValorTotal) AS varchar), '.', ',') +
          ' (' + LTRIM(dbo.Money_Extenso(CONVERT(money, @ValorTotal))) + ')'
      END AS VALOR_TOTAL
    FROM #TMP_VALOR_CURSO VC
    INNER JOIN LY_ALUNO AL
      ON (AL.CURSO = vc.CURSO
      AND AL.TURNO = vc.TURNO
      AND AL.CURRICULO = vc.CURRICULO
      AND AL.ANO_INGRESSO = VC.ANO
      AND AL.SEM_INGRESSO = VC.PERIODO)
    WHERE AL.ALUNO = @p_aluno
    GROUP BY VC.CURSO
    )

  ----------------------------------------------------------
  --Retorna o valor da mensalidade do curso
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%VALOR_MENS%%',
      CASE
        WHEN @curso NOT LIKE 'CCOL' THEN REPLACE(CAST(CONVERT(money, ISNULL(VALOR / MAX(PP.NUM_PARCELAS), 0)) AS varchar), '.', ',') +
          ' (' +
          LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(VALOR / MAX(PP.NUM_PARCELAS), 0)))) +
          ')'
        ELSE (SELECT
            CASE
              WHEN P.NUM_PARCELAS = 1 THEN REPLACE(CAST(CONVERT(money, ISNULL(@ValorTotal, 0)) AS varchar), '.', ',') +
                ' (' + LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(@ValorTotal, 0)))) + ')'
              WHEN P.NUM_PARCELAS = 5 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
              WHEN p.NUM_PARCELAS = 10 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
              WHEN p.NUM_PARCELAS = 20 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
            END
          FROM LY_LANC_DEBITO L
          INNER JOIN LY_ALUNO A
            ON L.ALUNO = A.ALUNO
          INNER JOIN LY_PLANO_PGTO_PERIODO P
            ON L.ALUNO = P.ALUNO
            AND L.ANO_REF = P.ANO
            AND L.PERIODO_REF = P.PERIODO
          LEFT JOIN LY_DESCONTO_PLANO_PGTO DP
            ON A.CURSO = DP.CURSO
            AND A.TURNO = DP.TURNO
            AND A.CURRICULO = DP.CURRICULO
            AND A.CONCURSO = DP.CONCURSO
            AND P.NUM_PARCELAS = DP.NUM_PARCELAS
          INNER JOIN LY_CURRICULO CR
            ON A.CURSO = CR.CURSO
            AND A.TURNO = CR.TURNO
            AND A.CURRICULO = CR.CURRICULO
          INNER JOIN LY_VALOR_SERV_PERIODO SP
            ON CR.SERVICO = SP.SERVICO
            AND L.ANO_REF = SP.ANO
            AND L.PERIODO_REF = SP.PERIODO
          WHERE A.ALUNO = @p_aluno)
      END AS VALOR_MENS
    FROM LY_PLANO_PGTO_PERIODO PP
    INNER JOIN LY_ALUNO AL
      ON AL.ALUNO = PP.ALUNO
    INNER JOIN #TMP_VALOR_CURSO VC
      ON VC.CURSO = AL.CURSO
      AND VC.TURNO = AL.TURNO
      AND VC.CURRICULO = AL.CURRICULO
      AND VC.ANO = AL.ANO_INGRESSO
      AND VC.PERIODO = AL.SEM_INGRESSO

    WHERE VC.SERVICO LIKE 'MENS%'
    AND AL.ALUNO = @p_aluno
    GROUP BY PP.NUM_PARCELAS,
             VC.VALOR
    )

  ----------------------------------------------------------
  --Retorna o valor do boleto de matricula
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%VALOR_MATR%%',
      CASE
        WHEN @curso NOT LIKE 'CCOL' THEN REPLACE(CAST(CONVERT(money, ISNULL(VALOR, 0)) AS varchar), '.', ',') +
          ' (' +
          LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(VALOR, 0)))) +
          ')'
        ELSE (SELECT
            CASE
              WHEN P.NUM_PARCELAS = 1 THEN REPLACE(CAST(CONVERT(money, ISNULL(@ValorTotal, 0)) AS varchar), '.', ',') +
                ' (' + LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(@ValorTotal, 0)))) + ')'
              WHEN P.NUM_PARCELAS = 5 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
              WHEN p.NUM_PARCELAS = 10 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
              WHEN p.NUM_PARCELAS = 20 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
            END
          FROM LY_LANC_DEBITO L
          INNER JOIN LY_ALUNO A
            ON L.ALUNO = A.ALUNO
          INNER JOIN LY_PLANO_PGTO_PERIODO P
            ON L.ALUNO = P.ALUNO
            AND L.ANO_REF = P.ANO
            AND L.PERIODO_REF = P.PERIODO
          LEFT JOIN LY_DESCONTO_PLANO_PGTO DP
            ON A.CURSO = DP.CURSO
            AND A.TURNO = DP.TURNO
            AND A.CURRICULO = DP.CURRICULO
            AND A.CONCURSO = DP.CONCURSO
            AND P.NUM_PARCELAS = DP.NUM_PARCELAS
          INNER JOIN LY_CURRICULO CR
            ON A.CURSO = CR.CURSO
            AND A.TURNO = CR.TURNO
            AND A.CURRICULO = CR.CURRICULO
          INNER JOIN LY_VALOR_SERV_PERIODO SP
            ON CR.SERVICO = SP.SERVICO
            AND L.ANO_REF = SP.ANO
            AND L.PERIODO_REF = SP.PERIODO
          WHERE A.ALUNO = @p_aluno)
      END AS VALOR_MATR
    FROM LY_PLANO_PGTO_PERIODO PP
    INNER JOIN LY_ALUNO AL
      ON AL.ALUNO = PP.ALUNO
    INNER JOIN #TMP_VALOR_CURSO VC
      ON VC.CURSO = AL.CURSO
      AND VC.TURNO = AL.TURNO
      AND VC.CURRICULO = AL.CURRICULO
      AND VC.ANO = AL.ANO_INGRESSO
      AND VC.PERIODO = AL.SEM_INGRESSO

    WHERE VC.SERVICO LIKE 'MATR%'
    AND AL.ALUNO = @p_aluno
    GROUP BY PP.NUM_PARCELAS,
             VC.VALOR
    )

  ----------------------------------------------------------
  --Retorna o valor do boleto de matricula
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%NUM_PARCELAS%%',
      CASE
        WHEN PP.NUM_PARCELAS = 1 THEN CAST(MAX(PP.NUM_PARCELAS) AS varchar) + ' (' + LTRIM(dbo.Numero_Extenso(MAX(PP.NUM_PARCELAS))) + ')'
        ELSE CAST(PP.NUM_PARCELAS AS varchar) + ' (' + LTRIM(dbo.Numero_Extenso(PP.NUM_PARCELAS)) + ')'
      END AS NUM_PARCELAS
    FROM LY_PLANO_PGTO_PERIODO PP
    WHERE ALUNO = @p_aluno

    GROUP BY PP.NUM_PARCELAS

    UNION

    SELECT
      '%%NUM_PARCELAS%%',
      '1' + ' (' + LTRIM(dbo.Numero_Extenso(1)) + ')'
      AS NUM_PARCELAS
    FROM LY_ALUNO AL
    WHERE NOT EXISTS (SELECT
      1
    FROM LY_PLANO_PGTO_PERIODO PP
    WHERE ALUNO = @p_aluno)
    AND ALUNO = @p_aluno
    )

  ----------------------------------------------------------
  --Retorna o valor do boleto de matricula
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%PLANO_ESCOLHIDO%%',
      CASE
        WHEN PP.NUM_PARCELAS = 1 THEN 'à vista'
        WHEN (PP.NUM_PARCELAS = 12 OR
          PP.NUM_PARCELAS = 11) AND
          AL.CURSO = 'CEAI' THEN 'Parcelado Anual'
        WHEN (PP.NUM_PARCELAS = 24 OR
          PP.NUM_PARCELAS = 23) AND
          AL.CURSO = 'CEAI' THEN 'Parcelado Bienal'
        WHEN PP.NUM_PARCELAS = 5 AND
          AL.CURSO = 'CCOL' THEN 'Matrícula + 5 (Cinco) Parcelas'
        WHEN PP.NUM_PARCELAS = 10 AND
          AL.CURSO = 'CCOL' THEN 'Matrícula + 10 (Dez) Parcelas'
        WHEN PP.NUM_PARCELAS = 20 AND
          AL.CURSO = 'CCOL' THEN 'Matrícula + 20 (Vinte) Parcelas'
        ELSE 'Parcelado'
      END AS PLANO_ESCOLHIDO
    FROM LY_PLANO_PGTO_PERIODO PP
    INNER JOIN LY_ALUNO AL
      ON (AL.ALUNO = PP.ALUNO)
    WHERE PP.ALUNO = @p_aluno
    AND PERCENT_DIVIDA_ALUNO > 0
    )

  ----------------------------------------------------------
  --Verifica se o curso possui matricula
  INSERT INTO #TAGS_RETORNO (tag, valor)
    (
    SELECT
      '%%VERIFICA_MATR%%',
      CASE
        WHEN @curso NOT LIKE 'CCOL' AND
          EXISTS (SELECT
            1
          FROM #TMP_VALOR_CURSO VC
          INNER JOIN LY_ALUNO AL
            ON (AL.CURSO = VC.CURSO
            AND AL.TURNO = VC.TURNO
            AND VC.CURRICULO = AL.CURRICULO)
          WHERE VC.SERVICO LIKE 'MATR%'
          AND ALUNO = @p_aluno) THEN 'da taxa de matrícula no valor de R$ ' +
          REPLACE(CAST(CONVERT(money, ISNULL(VALOR, 0)) AS varchar), '.', ',') +
          ' (' +
          LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(VALOR, 0)))) +
          ')' +
          ' com vencimento em ' +
          CONVERT(varchar, (dbo.FN_FCAV_GetDiaUtil(GETDATE(), @diasvenc)), 103) +
          ' e'
        WHEN @curso LIKE 'CCOL' THEN 'da taxa de matrícula no valor de R$ ' + (SELECT
            CASE
              WHEN P.NUM_PARCELAS = 1 THEN REPLACE(CAST(CONVERT(money, ISNULL(@ValorTotal, 0)) AS varchar), '.', ',') +
                ' (' + LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(@ValorTotal, 0)))) + ')'
              WHEN P.NUM_PARCELAS = 5 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
              WHEN p.NUM_PARCELAS = 10 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
              WHEN p.NUM_PARCELAS = 20 THEN REPLACE(CAST(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0)) AS varchar), '.', ',') +
                ' (' + dbo.Money_Extenso(CONVERT(money, ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS, 0))) + ')'
            END
          FROM LY_LANC_DEBITO L
          INNER JOIN LY_ALUNO A
            ON L.ALUNO = A.ALUNO
          INNER JOIN LY_PLANO_PGTO_PERIODO P
            ON L.ALUNO = P.ALUNO
            AND L.ANO_REF = P.ANO
            AND L.PERIODO_REF = P.PERIODO
          LEFT JOIN LY_DESCONTO_PLANO_PGTO DP
            ON A.CURSO = DP.CURSO
            AND A.TURNO = DP.TURNO
            AND A.CURRICULO = DP.CURRICULO
            AND A.CONCURSO = DP.CONCURSO
            AND P.NUM_PARCELAS = DP.NUM_PARCELAS
          INNER JOIN LY_CURRICULO CR
            ON A.CURSO = CR.CURSO
            AND A.TURNO = CR.TURNO
            AND A.CURRICULO = CR.CURRICULO
          INNER JOIN LY_VALOR_SERV_PERIODO SP
            ON CR.SERVICO = SP.SERVICO
            AND L.ANO_REF = SP.ANO
            AND L.PERIODO_REF = SP.PERIODO
          WHERE A.ALUNO = @p_aluno)
          +
          ' com vencimento em '
          +
          CONVERT(varchar, (dbo.FN_FCAV_GetDiaUtil(GETDATE(), @diasvenc)), 103)
          + ' e'
        ELSE 'de'
      END AS VERIFICA_MATR
    FROM #TMP_VALOR_CURSO VC
    INNER JOIN LY_ALUNO AL
      ON (AL.CURSO = VC.CURSO
      AND AL.TURNO = VC.TURNO
      AND VC.CURRICULO = AL.CURRICULO)
    WHERE VC.SERVICO LIKE 'MATR%'
    AND ALUNO = @p_aluno
    )
  ---------------------------------------------------------------      
  --[FIM CUSTOMIZAÇÃO]      
  ---------------------------------------------------------------      

  SELECT
    *
  FROM #TAGS_RETORNO
  ORDER BY TAG, VALOR

END