      
/****************************************************************              
--*              
--*  ***PROCEDURE PR_FCAV_CONSULTA_PESSOA ***              
--*               
--* DESCRICAO:              
--* - PROCEDURE PARA CONSULTAR AS INFORMAÇÕES IMPORTANTES REFERENTE A PESSOA.              
--*              
--* PARAMETROS:              
--* -             
--*               
--* USO:              
--* - O uso exclusivo.              
--*              
--* ALTERAÇÕES:              
--*                
--*              
--* Autor: Gabriel S. Scalione              
--* Data de criação: 26/11/2014              
    
SELECT * FROM #TMP_CANDIDATO_ALUNO WHERE PESSOA = 95677    
    
*****************************************************************/      
    
      
ALTER PROCEDURE PR_FCAV_CONSULTA_PESSOA @pessoa numeric,      
@nome_pessoa varchar(100),      
@cpf varchar(11),      
@e_mail varchar(100),      
@candidato varchar(20),      
@aluno varchar(20)      
      
-----------------------------------------------------------------------              
      
AS      
      
    
-----------------------------------------------------------------------                
SELECT    
    CA.PESSOA,    
    CA.CPF,    
    CA.RG_NUM,    
    CA.RG_TIPO,    
    CA.PASSAPORTE,    
    CA.CANDIDATO AS INSCRITO,    
    CA.SIT_CANDIDATO_VEST AS SITUACAO,    
    CA.DT_INSCRICAO AS DT_INSCRICAO,    
    OC.CONCURSO,    
    OC.OFERTA_DE_CURSO,    
    OC.CURSO,    
    OC.TURNO,    
    OC.CURRICULO,    
    OC.ANO_INGRESSO,    
    OC.PER_INGRESSO    
        
    INTO #TMP_CANDIDATO_ALUNO    
    
FROM LY_CANDIDATO CA    
INNER JOIN LY_OFERTA_CURSO OC    
    ON OC.CONCURSO = CA.CONCURSO    
WHERE OC.CONCURSO IS NOT NULL    
GROUP BY CA.PESSOA,    
         CA.CANDIDATO,    
         CA.CPF,    
   CA.RG_NUM,    
   CA.RG_TIPO,    
   CA.PASSAPORTE,    
         CA.SIT_CANDIDATO_VEST,    
         CA.DT_INSCRICAO,    
         OC.CONCURSO,    
         OC.OFERTA_DE_CURSO,    
         OC.CURSO,    
         OC.TURNO,    
         OC.CURRICULO,    
         OC.ANO_INGRESSO,    
         OC.PER_INGRESSO    
    
UNION ALL    
    
SELECT    
    AL.PESSOA,    
    NULL AS CPF,    
    NULL AS RG_NUM,    
    NULL AS RG_TIPO,    
    NULL AS PASSAPORTE,    
    AL.ALUNO AS INSCRITO,    
    AL.SIT_ALUNO AS SITUACAO,    
    AL.DT_INGRESSO AS DT_INSCRICAO,    
    OC.CONCURSO,    
    OC.OFERTA_DE_CURSO,    
    OC.CURSO,    
    OC.TURNO,    
    OC.CURRICULO,    
    OC.ANO_INGRESSO,    
    OC.PER_INGRESSO    
FROM LY_ALUNO AL    
INNER JOIN LY_OFERTA_CURSO OC    
    ON OC.CURSO = AL.CURSO    
    AND OC.TURNO = AL.TURNO    
    AND OC.CURRICULO = AL.CURRICULO    
    AND OC.ANO_INGRESSO = AL.ANO_INGRESSO    
    AND OC.PER_INGRESSO = AL.SEM_INGRESSO    
    AND OC.TURMA_PREF = AL.TURMA_PREF    
WHERE OC.CONCURSO IS NULL    
AND AL.CANDIDATO IS NULL    
AND AL.CONCURSO IS NULL    
GROUP BY AL.PESSOA,    
         AL.ALUNO,    
         AL.SIT_ALUNO,    
         AL.DT_INGRESSO,    
         OC.CONCURSO,    
         OC.OFERTA_DE_CURSO,    
         OC.CURSO,    
         OC.TURNO,    
         OC.CURRICULO,    
         OC.ANO_INGRESSO,    
         OC.PER_INGRESSO    
    
-----------------------------------------------------------------------    
--CONSULTA    
    
SELECT    
    PE.PESSOA,    
    PE.NOME_COMPL,    
    PE.CPF,    
    PE.RG_NUM,    
    PE.RG_TIPO,    
    PE.PASSAPORTE,    
    CONVERT(VARCHAR,pe.DT_NASC,103) AS DT_NAS,    
    PE.E_MAIL,    
    TCA.CPF     AS CAND_CPF,    
    TCA.RG_NUM     AS CAND_RGNUM,    
	TCA.RG_TIPO    AS CAND_RG_TIPO,    
	TCA.PASSAPORTE AS CAND_PASSAPORTE,    
    --PRODUCAO    
    --PE.SENHA_TAC,    
    --HOMOLOGACAO    
    DBO.Decrypt(PE.SENHA_TAC) AS SENHA,    
    CASE    
        WHEN TCA.CONCURSO IS NOT NULL THEN TCA.INSCRITO    
        ELSE ''    
    END AS CANDIDATO,    
    CASE    
        WHEN TCA.CONCURSO IS NOT NULL THEN TCA.SITUACAO    
        ELSE ''    
    END AS SIT_CANDIDATO,    
    CASE    
        WHEN TCA.CONCURSO IS NOT NULL THEN TCA.CONCURSO    
        ELSE ''    
    END AS CONCURSO,    
	ISNULL(TCA.DT_INSCRICAO, FC.DATA_INSC) AS DT_INSCRICAO,    
    CASE    
        WHEN EXISTS (SELECT    
                1    
            FROM LY_CONVOCADOS_VEST    
            WHERE CANDIDATO = TCA.INSCRITO    
            AND CONCURSO = TCA.CONCURSO) THEN 'CONVOCADO'    
        ELSE 'NÃO CONVOCADO'    
    END SIT_CONVOCADO,    
    CT.CONTRATO_ACEITO,    
    CT.DATA_ACEITE,
    AL.DT_INGRESSO,
    AL.ALUNO,
    AL.SIT_ALUNO,
    AL.CURSO,
    AL.TURMA_PREF,
    CASE
        WHEN TCA.CONCURSO IS NULL THEN 'Venda Direta'
        ELSE 'Processo Seletivo'
    END AS TIPO_INGRESSO,
	(SELECT isnull(SIT_MATRICULA,'----')
		FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA     
		WHERE MA.ALUNO = AL.ALUNO
		  AND MA.CURSO = AL.CURSO
		  AND MA.CURRICULO = AL.CURRICULO
		  AND MA.TURNO = AL.TURNO GROUP BY SIT_MATRICULA    
	) AS SIT_MATRICULA,    
	(SELECT ISNULL(TURMA, '----')
		FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA     
		WHERE MA.OFERTA_DE_CURSO = TCA.OFERTA_DE_CURSO
		  GROUP BY TURMA    
	) AS TURMA,    
    CASE    
        WHEN EXISTS (SELECT    
                1    
            FROM LY_H_CURR_ALUNO    
            WHERE ALUNO = TCA.INSCRITO) THEN 'Transferido'    
        ELSE 'Normal'    
    END ORIGEM,    
    PI.PLANOPAG AS PLANO_ESCOLHIDO,    
    PP.PLANOPAG AS PLANO_PGTO_PERIODO,    
    CASE    
        WHEN RE.CGC_TITULAR IS NULL THEN RE.CPF_TITULAR    
        WHEN RE.CPF_TITULAR IS NULL THEN RE.CGC_TITULAR    
        ELSE NULL    
    END AS DOC_TITULAR,    
    RE.TITULAR,    
    PP.PERCENT_DIVIDA_ALUNO,    
    BL.TIPO_BOLSA,    
    BL.NUM_BOLSA,    
    BL.PERC_VALOR,    
    BL.VALOR,    
    BL.MOTIVO,
    (SELECT DISTINCT   
        SUM(VALOR)    
    FROM LY_ITEM_LANC IIL    
    WHERE IIL.ALUNO = AL.ALUNO    
    AND (IIL.DESCRICAO != 'VALOR ACORDADO'    
    AND IIL.ACORDO IS NULL))    
    AS VALOR_PAGAR    
FROM #TMP_CANDIDATO_ALUNO TCA    
    
LEFT JOIN LY_ALUNO AL    
    ON  CASE WHEN AL.CANDIDATO IS NULL THEN al.ALUNO    
			 ELSE AL.CANDIDATO    
	    END = TCA.INSCRITO    
    AND AL.CURSO = TCA.CURSO    
    AND AL.TURNO = TCA.TURNO    
    AND AL.CURRICULO = TCA.CURRICULO    
    AND AL.ANO_INGRESSO = TCA.ANO_INGRESSO    
    AND AL.SEM_INGRESSO = TCA.PER_INGRESSO    
    
LEFT JOIN FCAV_CANDIDATOS FC    
 ON FC.CANDIDATO = TCA.INSCRITO    
 AND FC.CONCURSO = TCA.CONCURSO    
    
LEFT JOIN LY_CONTRATO_ALUNO CT    
    ON CT.ALUNO = AL.ALUNO    
    
LEFT JOIN LY_PLANO_PGTO_INSCRONLINE PI    
    ON PI.ALUNO = AL.ALUNO    
    AND PI.OFERTA_DE_CURSO = TCA.OFERTA_DE_CURSO    
    
LEFT JOIN LY_PLANO_PGTO_PERIODO PP    
    ON PP.ALUNO = AL.ALUNO    
    
LEFT JOIN LY_RESP_FINAN RE    
    ON RE.RESP = PP.RESP    
    
LEFT JOIN LY_BOLSA BL    
    ON BL.ALUNO = AL.ALUNO    
        
FULL JOIN  LY_PESSOA PE    
    ON PE.PESSOA = TCA.PESSOA    
    
LEFT JOIN LY_PROSPECTO_CAPTACAO PC    
    ON PC.PESSOA = PE.PESSOA    
    
    
WHERE PE.PESSOA LIKE @pessoa    
OR PE.NOME_COMPL LIKE @nome_pessoa    
OR PE.CPF LIKE @cpf    
OR PE.E_MAIL LIKE @e_mail    
OR TCA.INSCRITO LIKE @candidato    
OR AL.ALUNO LIKE @aluno    
    
    
GROUP BY PC.DT_INSERCAO,    
         PE.PESSOA,    
         PE.NOME_COMPL,    
         PE.PASSAPORTE,    
         PE.DT_NASC,    
         TCA.CPF,    
         TCA.RG_NUM,    
         TCA.RG_TIPO,    
         TCA.PASSAPORTE,    
         TCA.CONCURSO,
         TCA.OFERTA_DE_CURSO,    
         TCA.INSCRITO,    
         TCA.SITUACAO,    
         TCA.DT_INSCRICAO,    
         FC.DATA_INSC,    
         PE.SENHA_TAC,    
         AL.DT_INGRESSO,    
         AL.ALUNO,    
         AL.SIT_ALUNO,    
         AL.CURSO,    
		 AL.TURMA_PREF,
		 AL.CURRICULO,
		 AL.TURNO,
         PE.CPF,    
         PE.RG_NUM,    
		 PE.RG_TIPO,    
         PE.E_MAIL,    
         PI.PLANOPAG,    
         PP.PLANOPAG,    
         RE.RESP,    
         RE.TITULAR,    
         PP.PERCENT_DIVIDA_ALUNO,    
         BL.TIPO_BOLSA,    
         BL.NUM_BOLSA,    
         BL.PERC_VALOR,    
         BL.VALOR,    
         BL.MOTIVO,    
         CT.CONTRATO_ACEITO,    
         CT.DATA_ACEITE,    
         RE.CGC_TITULAR,    
         RE.CPF_TITULAR    
    
    
DROP TABLE #TMP_CANDIDATO_ALUNO    
      
      
    RETURN