/*        
  **VW_FCAV_ALUNOS_VENDA_DIRETA**        
          
 - VIEW PARA TRAZER A RELAÇÃO DE ALUNOS QUE FIZERAM A INSCRICAO POR VENDA DIRETA.    
        

      select * from VW_FCAV_ALUNOS_VENDA_DIRETA where turma = 'A-AT T 12'  
    select * from VW_FCAV_EXTFIN_LY where turma = 'A-45001.18 T 02'  

Atualização:        
 22/09/2017 - Agora verifica os pagamentos por Cartao.   
 04/01/2018 - Acrescentado os campos LY_BOLSA.PERC_VALOR, LY_BOLSA.VALOR. Gabriel S. Scalione  
 04/07/2018 - Ajuste do campo Dt_ingresso para vir como formato date e   
   
            
Autor: Gabriel S. Scalione         
Criação: 02/09/2015        
*/ 
ALTER VIEW VW_FCAV_ALUNOS_VENDA_DIRETA 
AS 
  WITH RESUMO_MATRICULA_E_PRE_MATRICULA 
       AS (SELECT AL.CURSO, 
                  AL.TURNO, 
                  AL.CURRICULO, 
                  MA.TURMA, 
                  AL.PESSOA, 
                  AL.CANDIDATO, 
                  MA.ALUNO, 
                  AL.NOME_COMPL, 
                  AL.ANO_INGRESSO, 
                  AL.SEM_INGRESSO, 
                  AL.SIT_ALUNO, 
                  AL.DT_INGRESSO,         
                  CASE 
                    WHEN SIT_MATRICULA LIKE 'Aprovado' 
                          OR SIT_MATRICULA LIKE 'Rep Nota' 
                          OR SIT_MATRICULA LIKE 'Rep Freq' 
                          OR SIT_MATRICULA LIKE 'Trancado' THEN 'Matriculado' 
                    ELSE SIT_MATRICULA 
                  END AS SIT_MATRICULA, 
                  SIT_DETALHE, 
                  'S' AS ALOCADO, 
                  AL.TIPO_INGRESSO, 
                  AL.TURMA_PREF 
           FROM   LY_MATRICULA MA 
                  INNER JOIN LY_ALUNO AL 
                          ON ( AL.ALUNO = MA.ALUNO ) 
                             AND AL.CONCURSO IS NULL 
           WHERE  NOME_COMPL NOT LIKE '%teste%' 
                  AND MA.SIT_MATRICULA NOT LIKE 'Dispensado' 
                  AND AL.SIT_ALUNO NOT LIKE 'Cancelado' 
           GROUP  BY AL.CURSO, 
                     AL.TURNO, 
                     AL.CURRICULO, 
                     MA.TURMA, 
                     AL.PESSOA, 
                     AL.CANDIDATO, 
                     MA.ALUNO, 
                     AL.DT_INGRESSO, 
                     AL.NOME_COMPL, 
                     AL.ANO_INGRESSO, 
                     AL.SEM_INGRESSO, 
                     AL.SIT_ALUNO, 
                     SIT_MATRICULA, 
                     SIT_DETALHE, 
                     AL.TIPO_INGRESSO, 
                     AL.TURMA_PREF 
           UNION ALL 
           SELECT AL.CURSO, 
                  AL.TURNO, 
                  AL.CURRICULO, 
                  HI.TURMA, 
                  AL.PESSOA, 
                  AL.CANDIDATO, 
                  HI.ALUNO, 
                  AL.NOME_COMPL, 
                  AL.ANO_INGRESSO, 
                  AL.SEM_INGRESSO, 
                  AL.SIT_ALUNO, 
                  AL.DT_INGRESSO, 
                  CASE 
                    WHEN SITUACAO_HIST LIKE 'Aprovado' 
                          OR SITUACAO_HIST LIKE 'Rep Nota' 
                          OR SITUACAO_HIST LIKE 'Rep Freq' 
                          OR SITUACAO_HIST LIKE 'Trancado' THEN 'Matriculado' 
                    ELSE SITUACAO_HIST 
                  END AS SIT_MATRICULA, 
                  SIT_DETALHE, 
                  'S' AS ALOCADO, 
                  AL.TIPO_INGRESSO, 
                  AL.TURMA_PREF 
           FROM   LY_HISTMATRICULA HI 
                  INNER JOIN LY_ALUNO AL 
                          ON ( AL.ALUNO = HI.ALUNO ) 
                             AND AL.CONCURSO IS NULL 
           WHERE  NOME_COMPL NOT LIKE '%teste%' 
                  AND HI.SITUACAO_HIST NOT LIKE 'Dispensado' 
                  AND AL.SIT_ALUNO NOT LIKE 'Cancelado' 
           GROUP  BY AL.CURSO, 
                     AL.TURNO, 
                     AL.CURRICULO, 
                     HI.TURMA, 
                     AL.PESSOA, 
                     AL.CANDIDATO, 
                     HI.ALUNO, 
                     AL.NOME_COMPL, 
                     AL.ANO_INGRESSO, 
                     AL.SEM_INGRESSO, 
                     AL.SIT_ALUNO, 
                     AL.DT_INGRESSO, 
                     SITUACAO_HIST, 
                     SIT_DETALHE, 
                     AL.TIPO_INGRESSO, 
                     AL.TURMA_PREF 
           UNION ALL 
           SELECT AL.CURSO, 
                  AL.TURNO, 
                  AL.CURRICULO, 
                  PM.TURMA, 
                  AL.PESSOA, 
                  AL.CANDIDATO, 
                  PM.ALUNO, 
                  AL.NOME_COMPL, 
                  AL.ANO_INGRESSO, 
                  AL.SEM_INGRESSO, 
                  AL.SIT_ALUNO, 
                  AL.DT_INGRESSO,
                  'Pre-Matriculado' SIT_MATRICULA, 
                  PM.SIT_DETALHE, 
                  PM.ALOCADO, 
                  AL.TIPO_INGRESSO, 
                  AL.TURMA_PREF 
           FROM   LY_PRE_MATRICULA PM 
                  INNER JOIN LY_ALUNO AL 
                          ON ( PM.ALUNO = AL.ALUNO ) 
                             AND AL.CONCURSO IS NULL 
           WHERE  NOME_COMPL NOT LIKE '%teste%' 
                  AND AL.SIT_ALUNO NOT LIKE 'Cancelado' 
           GROUP  BY AL.CURSO, 
                     AL.TURNO, 
                     AL.CURRICULO, 
                     PM.TURMA, 
                     AL.PESSOA, 
                     AL.CANDIDATO, 
                     PM.ALUNO, 
                     AL.NOME_COMPL, 
                     AL.ANO_INGRESSO, 
                     AL.SEM_INGRESSO, 
                     AL.SIT_ALUNO, 
                     AL.DT_INGRESSO, 
                     PM.SIT_DETALHE, 
                     PM.ALOCADO, 
                     AL.TIPO_INGRESSO, 
                     AL.TURMA_PREF 
           UNION ALL 
           SELECT AL.CURSO, 
                  AL.TURNO, 
                  AL.CURRICULO, 
                  AL.TURMA_PREF, 
                  AL.PESSOA, 
                  AL.CANDIDATO, 
                  AL.ALUNO, 
                  AL.NOME_COMPL, 
                  AL.ANO_INGRESSO, 
                  AL.SEM_INGRESSO, 
                  AL.SIT_ALUNO, 
                  AL.DT_INGRESSO,           
                  'Cancelado' AS SIT_MATRICULA, 
                  'NA'        ALOCADO, 
                  'Cancelado' AS SIT_DETALHE, 
                  AL.TIPO_INGRESSO, 
                  AL.TURMA_PREF 
           FROM   LY_ALUNO AL 
           WHERE  NOME_COMPL NOT LIKE '%teste%' 
                  AND AL.SIT_ALUNO LIKE 'Cancelado' 
                  AND AL.CONCURSO IS NULL 
           GROUP  BY AL.CURSO, 
                     AL.TURNO, 
                     AL.CURRICULO, 
                     AL.PESSOA, 
                     AL.CANDIDATO, 
                     AL.ALUNO, 
                     AL.NOME_COMPL, 
                     AL.ANO_INGRESSO, 
                     AL.SEM_INGRESSO, 
                     AL.SIT_ALUNO, 
                     AL.DT_INGRESSO, 
                     AL.TIPO_INGRESSO, 
                     AL.TURMA_PREF) --FIM WITH             
  -----------------------------------------------------------------------------------  
  -- Relação dos alunos com financeiro  
  -----------------------------------------------------------------------------------  
  SELECT TU.UNIDADE_RESPONSAVEL, 
         TU.TURMA, 
         TU.CONCURSO, 
         OC.DTINI                                             AS DATA_INICIAL, 
         OC.DTFIM                                             AS DATA_FIM, 
         SO.SUB_GRUPO                                         AS AREA, 
         CS.NOME                                              AS DESCRICAO, 
         TU.DT_INICIO                                         AS INICIO_DO_CURSO, 
         TU.DT_FIM                                            AS FIM_DO_CURSO, 
         TU.TP_INGRESSO                                       AS TIPO_INSCRICAO, 
         PM.ALUNO, 
         PE.NOME_COMPL, 
         PM.SIT_MATRICULA, 
         PM.ALOCADO, 
         PE.FONE, 
         PE.FONE_COM, 
         PE.CELULAR, 
         Lower(PE.E_MAIL)                                     AS E_MAIL, 
         PE.RG_NUM, 
         PE.CPF, 
         DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(MU.NOME)              AS CIDADE, 
         MU.UF, 
         PM.DT_INGRESSO, 
         EX.TITULAR                                           AS RESP_FINANCEIRO, 
         CASE 
           WHEN EX.CPF_TITULAR IS NULL THEN EX.CGC_TITULAR 
           WHEN EX.CGC_TITULAR IS NULL THEN EX.CPF_TITULAR 
         END                                                  AS CPF_CNPJ, 
         EX.VALOR_PAGAR, 
         EX.VALOR_PAGO, 
         EX.BOLETO, 
         EX.DATA_DE_VENCIMENTO, 
         ISNULL(BO.TIPO_BOLSA, ( 'Voucher - ' + AV.VOUCHER )) AS TIPO_BOLSA, 
         ISNULL(BO.PERC_VALOR, AV.DESC_PERC_VALOR)            AS PERC_VALOR, 
         CASE 
           WHEN ISNULL(BO.PERC_VALOR, AV.DESC_PERC_VALOR) = 'Percentual' THEN ( 
           ISNULL(BO.VALOR, AV.DESCONTO) ) * 100 
           ELSE ISNULL(BO.VALOR, AV.DESCONTO) 
         END                                                  AS VALOR 
  FROM   RESUMO_MATRICULA_E_PRE_MATRICULA PM 
         INNER JOIN LY_PESSOA PE 
                 ON PE.PESSOA = PM.PESSOA 
         LEFT JOIN HD_MUNICIPIO MU 
                ON MU.MUNICIPIO = PE.END_MUNICIPIO 
         LEFT JOIN VW_FCAV_ALUNOS_COM_VOUCHERS AV 
                ON AV.ALUNO = PM.ALUNO 
                   AND AV.TURMA = PM.TURMA 
         INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA TU 
                 ON TU.TURMA = PM.TURMA 
         INNER JOIN LY_OFERTA_CURSO OC 
                 ON TU.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO 
         INNER JOIN LY_CURSO CS 
                 ON CS.CURSO = PM.CURSO 
         LEFT JOIN LY_SUB_GRUPO_OFERTA SO 
                ON OC.ID_SUB_GRUPO_OFERTA = SO.ID_SUB_GRUPO_OFERTA 
         LEFT JOIN LY_BOLSA BO 
                ON PM.ALUNO = BO.ALUNO 
                   AND BO.TIPO_BOLSA != 'Acerto' 
         LEFT JOIN VW_FCAV_EXTFIN_LY EX 
                ON EX.ALUNO = PM.ALUNO 
                   AND EX.TURMA = PM.TURMA 
                   AND EX.CODIGO_LANC != 'ACORDO' 
  WHERE  TU.TP_INGRESSO = 'VD'  
         AND ( ( ( PM.SIT_ALUNO = 'Cancelado' 
                   AND EX.BOLETO IS NOT NULL ) 
                  OR EX.BOLETO IS NOT NULL 
                  OR ( BO.TIPO_BOLSA IS NOT NULL ) 
                  OR NOT EXISTS (SELECT 1 
                                 FROM   VW_FCAV_EXTFIN_LY 
                                 WHERE  ALUNO = EX.ALUNO 
                                        AND TURMA = EX.TURMA) ) 
                OR TU.UNIDADE_RESPONSAVEL = 'PALES' 
                OR AV.DESCONTO = 100 ) 
  GROUP  BY TU.UNIDADE_RESPONSAVEL, 
            TU.TURMA, 
            TU.CONCURSO, 
            OC.DTINI, 
            OC.DTFIM, 
            SO.SUB_GRUPO, 
            CS.NOME, 
            TU.DT_INICIO, 
            TU.DT_FIM, 
            TU.TP_INGRESSO, 
            PM.ALUNO, 
            PE.NOME_COMPL, 
            PM.SIT_ALUNO, 
            PM.SIT_MATRICULA, 
            PM.ALOCADO, 
            PE.FONE, 
            PE.FONE_COM, 
            PE.CELULAR, 
            PE.E_MAIL, 
            PE.RG_NUM, 
            PE.CPF, 
            MU.NOME, 
            MU.UF, 
            PM.DT_INGRESSO, 
            EX.TITULAR, 
            EX.CGC_TITULAR, 
            EX.CPF_TITULAR, 
            EX.COBRANCA, 
            EX.DATA_DE_VENCIMENTO, 
            EX.VALOR_PAGAR, 
            EX.VALOR_PAGO, 
            EX.BOLETO, 
            BO.TIPO_BOLSA, 
            BO.PERC_VALOR, 
            BO.VALOR, 
            AV.VOUCHER, 
            AV.DESC_PERC_VALOR, 
            AV.DESCONTO 
  UNION ALL 
  SELECT TU.UNIDADE_RESPONSAVEL, 
         TU.TURMA, 
         TU.CONCURSO, 
         OC.DTINI                                             AS DATA_INICIAL, 
         OC.DTFIM                                             AS DATA_FIM, 
         SO.SUB_GRUPO                                         AS AREA, 
         CS.NOME                                              AS DESCRICAO, 
         TU.DT_INICIO                                         AS INICIO_DO_CURSO, 
         TU.DT_FIM                                            AS FIM_DO_CURSO, 
         TU.TP_INGRESSO                                       AS TIPO_INSCRICAO, 
         PM.ALUNO, 
         PE.NOME_COMPL, 
         PM.SIT_MATRICULA, 
         PM.ALOCADO, 
         PE.FONE, 
         PE.FONE_COM, 
         PE.CELULAR, 
         Lower(PE.E_MAIL)                                     AS E_MAIL, 
         PE.RG_NUM, 
         PE.CPF, 
         DBO.FN_FCAV_PRIMEIRA_MAIUSCULA(MU.NOME)              AS CIDADE, 
         MU.UF, 
         PM.DT_INGRESSO, 
         EX.TITULAR                                           AS RESP_FINANCEIRO, 
         CASE 
           WHEN EX.CPF_TITULAR IS NULL THEN EX.CGC_TITULAR 
           WHEN EX.CGC_TITULAR IS NULL THEN EX.CPF_TITULAR 
         END                                                  AS CPF_CNPJ, 
         EX.VALOR_PAGAR, 
         EX.VALOR_PAGO, 
         EX.BOLETO, 
         EX.DATA_DE_VENCIMENTO, 
         ISNULL(BO.TIPO_BOLSA, ( 'Voucher - ' + AV.VOUCHER )) AS TIPO_BOLSA, 
         ISNULL(BO.PERC_VALOR, AV.DESC_PERC_VALOR)            AS PERC_VALOR, 
         CASE 
           WHEN ISNULL(BO.PERC_VALOR, AV.DESC_PERC_VALOR) = 'Percentual' THEN ( 
           ISNULL(BO.VALOR, AV.DESCONTO) ) * 100 
           ELSE ISNULL(BO.VALOR, AV.DESCONTO) 
         END                                                  AS VALOR 
  FROM   RESUMO_MATRICULA_E_PRE_MATRICULA PM 
         INNER JOIN LY_PESSOA PE 
                 ON PE.PESSOA = PM.PESSOA 
         LEFT JOIN HD_MUNICIPIO MU 
                ON MU.MUNICIPIO = PE.END_MUNICIPIO 
         LEFT JOIN VW_FCAV_ALUNOS_COM_VOUCHERS AV 
                ON AV.ALUNO = PM.ALUNO 
                   AND AV.TURMA = PM.TURMA 
         INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA TU 
                 ON TU.TURMA = PM.TURMA 
         INNER JOIN LY_OFERTA_CURSO OC 
                 ON TU.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO 
         INNER JOIN LY_CURSO CS 
                 ON CS.CURSO = PM.CURSO 
         LEFT JOIN LY_SUB_GRUPO_OFERTA SO 
                ON OC.ID_SUB_GRUPO_OFERTA = SO.ID_SUB_GRUPO_OFERTA 
         LEFT JOIN LY_BOLSA BO 
                ON BO.ALUNO = PM.ALUNO 
                   AND BO.TIPO_BOLSA != 'Acerto' 
         LEFT JOIN VW_FCAV_EXTFIN_LY EX 
                ON EX.ALUNO = PM.ALUNO 
                   AND EX.TURMA = PM.TURMA 
                   AND EX.CODIGO_LANC != 'ACORDO' 
         LEFT JOIN LY_ITEM_CRED IC 
                ON EX.COBRANCA = IC.COBRANCA 
  WHERE  TU.TP_INGRESSO = 'VD' 
         --AND TU.TURMA = 'A-AGM T 01'  
         --and al.ALUNO = 'A201900155'  
         AND EXISTS (SELECT 1 
                     FROM   LY_PEDIDO_PGTO_COBRANCAS 
                     WHERE  COBRANCA = EX.COBRANCA) 
         AND EX.BOLETO IS NULL 
  GROUP  BY TU.UNIDADE_RESPONSAVEL, 
            TU.TURMA, 
            TU.CONCURSO, 
            OC.DTINI, 
            OC.DTFIM, 
            SO.SUB_GRUPO, 
            CS.NOME, 
            TU.DT_INICIO, 
            TU.DT_FIM, 
            TU.TP_INGRESSO, 
            PM.ALUNO, 
            PE.NOME_COMPL, 
            PM.SIT_ALUNO, 
            PM.SIT_MATRICULA, 
            PM.ALOCADO, 
            PE.FONE, 
            PE.FONE_COM, 
            PE.CELULAR, 
            PE.E_MAIL, 
            PE.RG_NUM, 
            PE.CPF, 
            MU.NOME, 
            MU.UF, 
            PM.DT_INGRESSO, 
            EX.TITULAR, 
            EX.CGC_TITULAR, 
            EX.CPF_TITULAR, 
            EX.COBRANCA, 
            EX.DATA_DE_VENCIMENTO, 
            EX.VALOR_PAGAR, 
            EX.VALOR_PAGO, 
            EX.BOLETO, 
            BO.TIPO_BOLSA, 
            BO.PERC_VALOR, 
            BO.VALOR, 
            AV.VOUCHER, 
            AV.DESC_PERC_VALOR, 
            AV.DESCONTO 