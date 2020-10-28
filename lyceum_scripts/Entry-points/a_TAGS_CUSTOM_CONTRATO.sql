ALTER PROCEDURE a_TAGS_CUSTOM_CONTRATO @p_aluno T_CODIGO,      
@p_anoMatricula T_ANO,      
@p_periodoMatricula T_SEMESTRE2,      
@p_curricContratoChave T_NUMERO,      
@p_ofertaCurso T_NUMERO      
AS      
 ---------------------------------------------------------------            
 --[INÍCIO CUSTOMIZAÇÃO]            
 ---------------------------------------------------------------       
 --VARIÁVEIS       
 DECLARE @diasvenc int      
 DECLARE @ValorTotal numeric      
 DECLARE @curso varchar(20)      
       
 DECLARE @v_nome_presidente VARCHAR (200)      
 DECLARE @v_est_civil_presidente VARCHAR (200)       
 DECLARE @v_cpf_presidente VARCHAR (200)      
 DECLARE @v_rg_presidente VARCHAR (200)      
      
 DECLARE @v_carga_horaria_total VARCHAR (200)      
 DECLARE @v_duracao_prev VARCHAR (200)      
 DECLARE @v_num_disciplina VARCHAR (200)      
 DECLARE @v_prazo_maximo VARCHAR (200)      
       
 DECLARE @v_dt_venc_matr VARCHAR (200)      
 DECLARE @v_dt_venc_mens1 VARCHAR (200)      
 DECLARE @v_num_parcelas VARCHAR (200)      
 DECLARE @v_plano_escolhido VARCHAR (200)      
 DECLARE @v_valor_mens VARCHAR (200)      
 DECLARE @v_valor_matr VARCHAR (200)      
 DECLARE @v_valor_total VARCHAR (200)      
       
 DECLARE @v_cpf_cnpj_titular VARCHAR (200)      
 DECLARE @v_nome_titular VARCHAR (100)       
      
 ---------------------------------------------------------------      
       
 --Identifica o curso do aluno      
 SELECT      
   @curso = CURSO      
 FROM LY_ALUNO      
 WHERE ALUNO = @p_aluno      
      
 --BLOCO VERIFICA NUMERO DE DIAS VENCIMENTO       
 IF EXISTS (SELECT 1 FROM LY_PLANO_PGTO_INSCRONLINE P      
      JOIN LY_RESP_FINAN R ON P.RESP = R.RESP      
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
  @diasvenc = ISNULL(N_DIAS_VENC_BOL_MATR,0)      
   FROM LY_CONCURSO CO      
   INNER JOIN LY_OFERTA_CURSO OC      
  ON (OC.CONCURSO = CO.CONCURSO)      
   WHERE OC.OFERTA_DE_CURSO = @p_ofertaCurso      
      
 END -- FIM DO BLOCO NUMERO DE DIAS VENCIMENTO      
       
 --EXTRAIR O VALOR TOTAL DO CURSO CCOL      
 IF @curso = 'CCOL'      
 BEGIN      
  SELECT      
    @ValorTotal = ISNULL(CONVERT(INT,DESCR),0)      
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
  ISNULL(SP.CUSTO_UNITARIO, 0) AS VALOR      
       
 INTO #TMP_VALOR_CURSO       
       
 FROM LY_VALOR_SERV_PERIODO SP      
  INNER JOIN VW_FCAV_SERVICO_TURMA ST       
   ON ( ST.SERVICO = SP.SERVICO       
    AND ST.ANO  = SP.ANO       
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
  ON ( SM.SERVICO = SP.SERVICO       
   AND SM.ANO  = SP.ANO       
   AND SM.PERIODO = SP.PERIODO)      
 WHERE SP.SERVICO LIKE 'MATR%'      
        
------------------------------------------------------------       
--Inicio da junção das TAGS      
      
  ------------------------------------------------------------      
  --Retorna o Presidente da FCAV      
  SET @v_nome_presidente =       
  (      
   SELECT NOME_COMPL      
   FROM LY_DOCENTE      
   WHERE TITULACAO LIKE 'Presidente da Diretoria Executiva'      
  )      
        
  SET @v_est_civil_presidente =       
  (      
   SELECT LOWER(EST_CIVIL)      
   FROM LY_DOCENTE      
   WHERE TITULACAO LIKE 'Presidente da Diretoria Executiva'      
)      
        
  SET @v_cpf_presidente =       
  (      
   SELECT dbo.FN_FCAV_formatarCNPJCPF(CPF)      
   FROM LY_DOCENTE      
   WHERE TITULACAO LIKE 'Presidente da Diretoria Executiva'      
  )      
  SET @v_rg_presidente =       
  (      
   SELECT RG_NUM + ' - ' + RG_EMISSOR + '/' + RG_UF      
   FROM LY_DOCENTE      
   WHERE TITULACAO LIKE 'Presidente da Diretoria Executiva'      
  )      
        
  ------------------------------------------------------------      
  --Retorna a duração do curso      
  SET @v_duracao_prev =      
  (      
   SELECT      
     ISNULL((CAST(CR.PRAZO_CONC_PREV AS varchar) +      
     ' (' +      
     LTRIM(dbo.Numero_Extenso(CR.PRAZO_CONC_PREV)) +      
     ') ' +      
     CR.TIPO_PRAZO_CONCL), '0')      
   FROM LY_CURRICULO CR      
   INNER JOIN LY_ALUNO AL      
     ON (AL.CURSO = CR.CURSO      
     AND AL.TURNO = CR.TURNO      
     AND AL.CURRICULO = CR.CURRICULO)      
   WHERE AL.ALUNO = @p_aluno      
  )      
        
  ------------------------------------------------------------      
  --Retorna o número de disciplinas      
  SET @v_num_disciplina =       
  (      
   SELECT      
     CAST(COUNT(GR.DISCIPLINA) AS varchar) +      
     ' (' +      
     LTRIM(dbo.Numero_Extenso(COUNT(GR.DISCIPLINA))) +      
     ') '      
   FROM LY_GRADE GR      
   INNER JOIN LY_ALUNO AL      
     ON (AL.CURSO = GR.CURSO      
     AND AL.TURNO = GR.TURNO      
     AND AL.CURRICULO = GR.CURRICULO)      
   WHERE AL.ALUNO = @p_aluno      
  )      
      
  ------------------------------------------------------------      
  --Retorna o prazo máximo de conclusão do curso      
  SET @v_prazo_maximo =       
  (      
   SELECT      
     ISNULL(CAST(CR.PRAZO_MAX AS varchar) +      
     ' (' +      
     dbo.Numero_Extenso(CR.PRAZO_MAX) +      
     ') ' +      
     CR.TIPO_PRAZO_CONCL, '0')      
   FROM LY_CURRICULO CR      
   INNER JOIN LY_ALUNO AL      
     ON (AL.CURSO = CR.CURSO      
     AND AL.TURNO = CR.TURNO      
     AND AL.CURRICULO = CR.CURRICULO)      
   WHERE AL.ALUNO = @p_aluno      
  )      
        
  ------------------------------------------------------------      
  --Retorna a carga horária total do curso      
  SET @v_carga_horaria_total =       
  (      
   SELECT      
    ISNULL(CAST(CAST(CR.AULAS_PREVISTAS AS INT) AS VARCHAR),'0') +      
    ' (' +      
    LTRIM(dbo.Numero_Extenso(CR.AULAS_PREVISTAS)) +      
    ') '      
   FROM LY_CURRICULO CR      
   INNER JOIN LY_ALUNO AL      
     ON (AL.CURSO = CR.CURSO      
     AND AL.TURNO = CR.TURNO      
     AND AL.CURRICULO = CR.CURRICULO)      
   WHERE AL.ALUNO = @p_aluno      
  )      
        
  ----------------------------------------------------------      
  --Retorna a data de vencimento do boleto de pré-matricula      
  SET @v_dt_venc_matr =       
  (      
   SELECT        
    CONVERT(VARCHAR,(GETDATE() + @diasvenc),103) AS DT_VENC_MATR      
      
  )      
      
      
  ----------------------------------------------------------      
  --Retorna a data de vencimento da primeira mensalidade      
  SET @v_dt_venc_mens1 =       
  (      
   SELECT      
    CONVERT(varchar, (DATEADD(MS, -1, DATEADD(MM, DATEDIFF(MM, 0, DT_INICIO), 0)) + 14), 103)      
   FROM VW_FCAV_INI_FIM_CURSO_TURMA CT      
   WHERE CT.OFERTA_DE_CURSO = @p_ofertaCurso      
  )      
      
  ----------------------------------------------------------      
  --Retorna o valor total do curso      
  SET @v_valor_total =       
  (        
   SELECT      
    CASE WHEN @curso NOT LIKE 'CCOL' THEN      
     REPLACE(CAST(CONVERT(money, SUM(VALOR)) AS varchar), '.', ',') +       
     ' (' + LTRIM(dbo.Money_Extenso(CONVERT(money, SUM(VALOR)))) + ')'       
    ELSE      
     REPLACE(CAST(CONVERT(money, @ValorTotal) AS varchar), '.', ',') +            ' (' + LTRIM(dbo.Money_Extenso(CONVERT(money, @ValorTotal))) + ')'       
    END      
   FROM       
    #TMP_VALOR_CURSO VC      
    INNER JOIN LY_ALUNO AL      
    ON (AL.CURSO = vc.CURSO      
     AND AL.TURNO = vc.TURNO      
     AND AL.CURRICULO = vc.CURRICULO      
     AND AL.ANO_INGRESSO = VC.ANO      
     AND AL.SEM_INGRESSO = VC.PERIODO)      
   WHERE AL.ALUNO = @p_aluno    
     AND VC.SERVICO LIKE '%MENS%'    
   GROUP BY       
    VC.CURSO              
  )      
        
        
  ----------------------------------------------------------      
  --Retorna o valor da mensalidade do curso      
  SET @v_valor_mens =       
  (        
         
   SELECT      
    CASE WHEN @curso NOT LIKE 'CCOL'  THEN      
     REPLACE(CAST(CONVERT(money, ISNULL(VALOR / MAX(PP.NUM_PARCELAS), 0)) AS varchar), '.', ',') +      
     ' (' +      
     LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(VALOR / MAX(PP.NUM_PARCELAS), 0)))) +      
     ')'       
    ELSE       
    (SELECT      
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
   FROM      
    LY_PLANO_PGTO_PERIODO PP      
    INNER JOIN LY_ALUNO AL ON AL.ALUNO = PP.ALUNO      
    INNER JOIN #TMP_VALOR_CURSO VC ON VC.CURSO = AL.CURSO AND VC.TURNO = AL.TURNO AND VC.CURRICULO = AL.CURRICULO      
             AND VC.ANO = AL.ANO_INGRESSO AND VC.PERIODO = AL.SEM_INGRESSO      
                 
   WHERE       
    VC.SERVICO LIKE 'MENS%'      
    AND AL.ALUNO = @p_aluno      
   GROUP BY PP.NUM_PARCELAS,      
      VC.VALOR      
  )      
        
  ----------------------------------------------------------      
  --Retorna o valor do boleto de matricula      
  SET @v_valor_matr =       
  (        
   SELECT      
    CASE WHEN @curso NOT LIKE 'CCOL'  THEN      
     REPLACE(CAST(CONVERT(money, ISNULL(VALOR / MAX(PP.NUM_PARCELAS), 0)) AS varchar), '.', ',') +      
     ' (' +      
     LTRIM(dbo.Money_Extenso(CONVERT(money, ISNULL(VALOR / MAX(PP.NUM_PARCELAS), 0)))) +      
     ')'       
    ELSE       
    (SELECT      
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
   FROM      
    LY_PLANO_PGTO_PERIODO PP      
    INNER JOIN LY_ALUNO AL ON AL.ALUNO = PP.ALUNO      
    INNER JOIN #TMP_VALOR_CURSO VC ON VC.CURSO = AL.CURSO AND VC.TURNO = AL.TURNO AND VC.CURRICULO = AL.CURRICULO      
             AND VC.ANO = AL.ANO_INGRESSO AND VC.PERIODO = AL.SEM_INGRESSO      
                 
   WHERE       
    VC.SERVICO LIKE 'MENS%'      
    AND AL.ALUNO = @p_aluno      
   GROUP BY PP.NUM_PARCELAS,      
      VC.VALOR      
  )      
           
  ----------------------------------------------------------      
  --Retorna o valor do boleto de matricula      
  SET @v_num_parcelas =       
  (      
   SELECT      
    CASE      
    WHEN PP.NUM_PARCELAS = 1 THEN CAST(MAX(PP.NUM_PARCELAS) AS varchar) + ' (' + LTRIM(dbo.Numero_Extenso(MAX(PP.NUM_PARCELAS))) + ')'      
    ELSE CAST(PP.NUM_PARCELAS AS varchar) + ' (' + LTRIM(dbo.Numero_Extenso(PP.NUM_PARCELAS)) + ')'      
    END      
   FROM LY_PLANO_PGTO_PERIODO PP      
   WHERE ALUNO = @p_aluno      
      
   GROUP BY PP.NUM_PARCELAS      
      
   UNION      
         
   SELECT      
    '1' + ' (' + LTRIM(dbo.Numero_Extenso(1)) + ')'      
   FROM LY_ALUNO AL      
   WHERE NOT EXISTS (SELECT      
    1      
   FROM LY_PLANO_PGTO_PERIODO PP      
   WHERE ALUNO = @p_aluno)      
   AND ALUNO = @p_aluno      
  )      
           
  ----------------------------------------------------------      
  --Retorna o valor do boleto de matricula      
  SET @v_plano_escolhido =      
  (       
   SELECT      
    CASE      
    WHEN PP.NUM_PARCELAS = 1 THEN 'à vista'      
    WHEN (PP.NUM_PARCELAS = 12 OR PP.NUM_PARCELAS = 11) AND AL.CURSO = 'CEAI' THEN 'Parcelado Anual'      
    WHEN (PP.NUM_PARCELAS = 24 OR PP.NUM_PARCELAS = 23) AND AL.CURSO = 'CEAI' THEN 'Parcelado Bienal'      
    WHEN PP.NUM_PARCELAS = 5  AND AL.CURSO = 'CCOL' THEN 'Matrícula + 5 (Cinco) Parcelas'      
    WHEN PP.NUM_PARCELAS = 10 AND AL.CURSO = 'CCOL' THEN 'Matrícula + 10 (Dez) Parcelas'      
    WHEN PP.NUM_PARCELAS = 20 AND AL.CURSO = 'CCOL' THEN 'Matrícula + 20 (Vinte) Parcelas'      
    ELSE 'Parcelado'      
    END      
   FROM LY_PLANO_PGTO_PERIODO PP      
 INNER JOIN LY_ALUNO AL      
    ON (AL.ALUNO = PP.ALUNO)      
   WHERE PP.ALUNO = @p_aluno      
    AND PERCENT_DIVIDA_ALUNO > 0      
  )      
        
  ----------------------------------------------------------      
  --Retorna numero do CPF ou CNPJ      
  SET @v_cpf_cnpj_titular =      
  (       
   SELECT      
    CASE WHEN CGC_TITULAR IS NULL THEN RE.CPF_TITULAR      
    ELSE CGC_TITULAR      
    END      
   FROM LY_PLANO_PGTO_PERIODO PP  
   INNER JOIN LY_RESP_FINAN RE      
    ON (RE.RESP = PP.RESP)    
   WHERE PP.ALUNO = @p_aluno      
    AND PERCENT_DIVIDA_ALUNO > 0  
    AND OUTRAS_DIVIDAS = 'S'  
  )      
 
   ----------------------------------------------------------      
  --Retorna nome do titular responsavel financeiro      
  SET @v_nome_titular =      
  (       
   SELECT TOP 1    
    re.TITULAR      
   FROM LY_PLANO_PGTO_PERIODO PP  
   INNER JOIN LY_RESP_FINAN RE      
    ON (RE.RESP = PP.RESP)    
   WHERE PP.ALUNO = @p_aluno      
    AND PERCENT_DIVIDA_ALUNO > 0  
    AND OUTRAS_DIVIDAS = 'S'  
  )   
        
  ----------------------------------------------------------      
  SELECT       
    @v_nome_presidente		AS NOME_PRESIDENTE      
   ,@v_est_civil_presidente AS EST_CIVIL_PRESIDENTE      
   ,@v_cpf_presidente		AS CPF_PRESIDENTE      
   ,@v_rg_presidente		AS RG_PRESIDENTE      
   ,@v_carga_horaria_total  AS CARGA_HORARIA_TOTAL      
   ,@v_duracao_prev			AS DURACAO_PREV      
   ,@v_num_disciplina		AS NUM_DISCIPLINAS      
   ,@v_prazo_maximo			AS PRAZO_MAXIMO      
   ,@v_dt_venc_matr			AS DT_VENC_MATR      
   ,@v_dt_venc_mens1		AS DT_VENC_MENS1      
   ,@v_num_parcelas			AS NUM_PARCELAS      
   ,@v_plano_escolhido		AS PLANO_ESCOLHIDO      
   ,@v_valor_mens			AS VALOR_MENS      
   ,@v_valor_matr			AS VALOR_MATR      
   ,@v_valor_total			AS VALOR_TOTAL  
   ,@v_cpf_cnpj_titular		AS CPF_CNPJ
   ,@v_nome_titular			AS NOME_TITULAR    
      
      
 ---------------------------------------------------------------            
 --[FIM CUSTOMIZAÇÃO]            
 ---------------------------------------------------------------             
      
 RETURN