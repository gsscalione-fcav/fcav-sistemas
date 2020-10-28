
SELECT  
   
 CUR_CODCUR collate Latin1_General_CI_AI AS CURSO,    
 TUR_CODTUR collate Latin1_General_CI_AI AS TURMA,
 PEL_DESCRI as PERIODO,
 CASE WHEN TUR_DATFIN <= GETDATE() THEN 'Ex-aluno'    
  ELSE 'Aluno'    
 END SIT_ALUNO,    
 PE.PES_CODTEL collate Latin1_General_CI_AI AS ALUNO,    
 PE.PES_NOME collate Latin1_General_CI_AI AS NOME_COMPL,    
 PE.PES_DATNAS AS DT_NASC,    
 YEAR (GETDATE()) - YEAR(PE.PES_DATNAS) AS IDADE_ATUAL,    
 PAI_NACION collate Latin1_General_CI_AI AS NACIONALIDADE,    
 CASE WHEN PE.PES_SEXO = 'F' THEN 'Feminino'    
   WHEN PE.PES_SEXO = 'M' THEN 'Masculino'    
 END collate Latin1_General_CI_AI AS SEXO,    
 PE.PES_ESTCIV collate Latin1_General_CI_AI AS EST_CIVIL,    
 PE.PES_ENDERE collate Latin1_General_CI_AI AS ENDERECO,    
 NULL AS END_NUM,    
 PE.PES_COMEND collate Latin1_General_CI_AI AS END_COMPL,    
 PE.PES_BAIRRO collate Latin1_General_CI_AI AS BAIRRO,    
 MUN_NOME collate Latin1_General_CI_AI AS END_MUNICIPIO,    
 PAI_NOME collate Latin1_General_CI_AI AS END_PAIS,    
 PE.PES_CEP collate Latin1_General_CI_AI AS CEP,    
 PE.PES_FONE collate Latin1_General_CI_AI AS FONE,    
 PE.PES_FONCEL collate Latin1_General_CI_AI AS CELULAR,    
 LOWER(PE.PES_EMAIL) collate Latin1_General_CI_AI AS E_MAIL,    
 PE.PES_NRODOC2 collate Latin1_General_CI_AI AS RG_NUM,    
 'RG' AS RG_TIPO,    
 PE.PES_ORGEMIDOC2 collate Latin1_General_CI_AI AS RG_EMISSOR,    
 NULL AS RG_UF,    
 PE.PES_DATDOC2 AS RG_DTEXP,    
 PE.PES_NRODOC1 collate Latin1_General_CI_AI AS CPF,    
 (SELECT TOP 1 FPP_FUNCAO FROM tb_formacao_profissional_pes  WHERE fpp_pesid = PE.pes_id) collate Latin1_General_CI_AI AS PROFISSAO,    
 (SELECT TOP 1 FPP_EMPRESA FROM tb_formacao_profissional_pes  WHERE fpp_pesid = PE.PES_ID)collate Latin1_General_CI_AI AS NOME_EMPRESA,    
 TUR_DATINI AS DT_INICIO_TURMA,    
 TUR_DATFIN AS DT_FIM_TURMA,    
 CASE WHEN TUR_DATFIN <= GETDATE() THEN 'Encerrada'    
  ELSE 'Aberta'    
 END STATUS_TURMA,    
 ING_DATENT AS DATA_MATRICULA,    
 CASE WHEN MAL_SITMAT = 'ATIVO' THEN 'Matriculado'  -- 'MATRICULADO','APROVADO','REP FREQ','REP NOTA','CANCELADO','TRANCADO','DISPENSADO','ESPERA','INCONCLUIDO'    
   WHEN MAL_SITMAT = 'CANCEL' THEN 'Cancelado'    
   WHEN MAL_SITMAT = 'TRANCA' THEN 'Trancado'    
   WHEN MAL_SITMAT = 'DESIST' THEN 'Cancelado'    
   WHEN MAL_SITMAT = 'TRAEXT' THEN 'Trancado'    
 END collate Latin1_General_CI_AI AS SIT_MATRICULA,    
 CASE WHEN MAL_SITMAT = 'ATIVO' AND TUR_DATFIN < GETDATE() THEN 'Concluído'    
   WHEN MAL_SITMAT = 'ATIVO' AND TUR_DATFIN >= GETDATE() THEN 'Cursando'    
 END AS STATUS,    
 RESP.PES_NOME AS TITULAR,    
 RESP.PES_NRODOC1 collate Latin1_General_CI_AI AS CPF_CNPJ,    
 DES_DESCRI AS TIPO_BOLSA,    
 1 AS NUM_BOLSA,    
 CASE WHEN pda_percen IS NOT NULL THEN 'Percentual'    
   WHEN pda_valor IS NOT NULL  THEN 'Valor'    
 END AS PESC_VALOR,    
 CASE WHEN pda_percen IS NOT NULL THEN pda_percen/100    
   WHEN pda_valor IS NOT NULL  THEN pda_valor    
 END AS VALOR,    
 NULL AS MOTIVO,    
 DIS_DISTEL collate Latin1_General_CI_AI AS DISCIPLINA,    
 DIS_DESDIS collate Latin1_General_CI_AI AS NOME_DISCIPLINA,    
 CAD_DATA AS DATA_INICIO_DISCIPLINA,    
 CONVERT (VARCHAR,HOR_HORINI,108) AS HORA_ENTRADA,    
 CONVERT (VARCHAR,HOR_HORFIN,108) AS HORA_SAIDA
FROM     
 TB_PESSOA PE    
 INNER JOIN tb_ingresso on (ing_pesid = pes_id)    
 INNER JOIN tb_curso on (ing_curid=cur_id and CUR_ARCID = '33')    
 INNER JOIN tb_mestre_aluno on (ing_id = mal_ingid)    
 INNER JOIN tb_turma on (mal_turid = tur_id)    
 INNER JOIN TB_MUNICIPIO ON PES_CODMUN = MUN_ID    
 INNER JOIN TB_UNIDADE_FEDERACAO ON MUN_UFID = UFE_ID    
 INNER JOIN TB_PAIS ON UFE_PAISID = PAI_ID    
 INNER JOIN tb_contrato_fin on (cfi_pesid = pes_id AND cfi_turid = tur_id)    
 INNER JOIN tb_responsavel_fin on (rfi_cfiid = cfi_id)    
 LEFT  JOIN tb_responsavel_desacr ON (pda_rfiid = rfi_id)    
 LEFT  JOIN tb_desconto on (pda_desid = des_id)    
 INNER JOIN TB_PESSOA RESP ON (RFI_PESID = RESP.PES_ID)    
 INNER JOIN TB_PERIODO_LETIVO ON (PEL_PERID=TUR_PERID)    
 INNER JOIN TB_MESTRE_DISCIPLINA ON (MDI_MALID = MAL_ID)    
 INNER JOIN TB_TURMA_DISCIP ON (MDI_TURDISID = TDI_TURDISID)     
 INNER JOIN TB_DISCIPLINA ON (TDI_DISCID = DIS_DISID)    
 INNER JOIN TB_CRONOGRAMA_AULA_MESTRE tcam ON (CAM_TDIID = TDI_TURDISID)    
 INNER JOIN TB_CRONOGRAMA_AULA_DATA on (CAM_ID = CAD_CAMID)    
 INNER JOIN TB_CRONOGRAMA_AULA ON (CAU_CADID = CAD_ID)    
 inner join TB_HORARIO ON CAU_HORID = HOR_ID
 INNER JOIN TB_PARCELA ON (PAR_CFIID = CFI_ID)
 inner JOIN TB_PARCELA_PAG ON (PPA_PARID = PAR_ID and PPA_DATPAG IS NOT NULL)
WHERE     
 CAU_NROAULA = '1'    
 AND year(CAD_DATA) >= 2010  
 and  MAL_SITMAT = 'ATIVO'
GROUP BY  
 CUR_CODCUR,  
 TUR_CODTUR,  
 PEL_DESCRI,
 TUR_DATFIN,  
 TUR_DESCRI,  
 PE.PES_ID,  
 PE.PES_CODTEL,  
 PE.PES_NOME,    
 PE.PES_DATNAS,    
 PE.PES_DATNAS,  
 PAI_NACION,    
 PE.PES_SEXO,    
 PE.PES_ESTCIV,  
 PE.PES_ENDERE,  
 PE.PES_COMEND,  
 PE.PES_BAIRRO,  
 MUN_NOME,  
 PAI_NOME,  
 PE.PES_CEP,  
 PE.PES_FONE,  
 PE.PES_FONCEL,  
 PE.PES_EMAIL,   
 PE.PES_NRODOC2,  
 PE.PES_ORGEMIDOC2,  
 PE.PES_DATDOC2,  
 PE.PES_NRODOC1,  
 TUR_DATINI,  
 TUR_DATFIN,  
 ING_DATENT,  
 MAL_SITMAT,  
 RESP.PES_NOME,  
 RESP.PES_NRODOC1,  
 DES_DESCRI,  
 pda_percen,  
 pda_valor,  
 DIS_DISTEL,  
 DIS_DESDIS,  
 CAD_DATA,  
 HOR_HORINI,  
 HOR_HORFIN  
   
  