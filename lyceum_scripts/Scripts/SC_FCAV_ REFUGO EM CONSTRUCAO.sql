if OBJECT_ID('TempDB.dbo.#TMP_CANDIDATO_ALUNO') IS NOT NULL
begin
	DROP TABLE #TMP_CANDIDATO_ALUNO
end
----------------------------------------------------------------------------------------------------------------------
SELECT
    CA.PESSOA,
    CA.CPF,
    CA.RG_NUM,
    CA.RG_TIPO,
    CA.PASSAPORTE,
    CA.CANDIDATO AS INSCRITO,
    CA.SIT_CANDIDATO_VEST AS SITUACAO,
    ISNULL(CA.DT_INSCRICAO, FC.DATA_INSC) AS DT_INSCRICAO,
    OC.CONCURSO AS CONCURSO,
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
INNER JOIN FCAV_CANDIDATOS FC
	ON FC.CANDIDATO = CA.CANDIDATO
	AND FC.CONCURSO = CA.CONCURSO
WHERE OC.CONCURSO IS NOT NULL
	AND CA.SIT_CANDIDATO_VEST !='Cancelado'
GROUP BY CA.PESSOA,
         CA.CANDIDATO,
         CA.CPF,
		 CA.RG_NUM,
		 CA.RG_TIPO,
		 CA.PASSAPORTE,
         CA.SIT_CANDIDATO_VEST,
         CA.DT_INSCRICAO,
		 FC.DATA_INSC,
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
    ISNULL(OC.CONCURSO, 'VD') CONCURSO,
    OC.OFERTA_DE_CURSO,
    OC.CURSO,
    OC.TURNO,
    OC.CURRICULO,
    OC.ANO_INGRESSO,
    OC.PER_INGRESSO
FROM LY_ALUNO AL
INNER JOIN LY_OFERTA_CURSO OC
    ON  OC.CURSO = AL.CURSO
    AND OC.TURNO = AL.TURNO
    AND OC.CURRICULO = AL.CURRICULO
    AND OC.ANO_INGRESSO = AL.ANO_INGRESSO
    AND OC.PER_INGRESSO = AL.SEM_INGRESSO
    AND OC.TURMA_PREF = AL.TURMA_PREF
WHERE OC.CONCURSO IS NULL
AND AL.CANDIDATO IS NULL
AND AL.CONCURSO IS NULL
AND AL.SIT_ALUNO = 'Ativo'
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
	VT.UNIDADE_RESPONSAVEL,
	TCA.CURSO,
	TCA.OFERTA_DE_CURSO,
	TCA.CONCURSO,
	VT.TURMA,
	VT.DT_INICIO,
	VT.DT_FIM,
	
    PE.PESSOA,
    TCA.INSCRITO,
    PE.NOME_COMPL,
    PE.CPF,
    PE.E_MAIL,
	PE.DDD_FONE,   
	PE.FONE,
	PE.DDD_FONE_CELULAR,
	PE.CELULAR,
	TCA.DT_INSCRICAO,
    CASE
        WHEN TCA.CONCURSO IS NOT NULL THEN TCA.SITUACAO
        ELSE ''
    END AS SIT_CANDIDATO,
    CASE
        WHEN TCA.CONCURSO IS NOT NULL THEN TCA.CONCURSO
        ELSE ''
    END AS CONCURSO,
    CASE
        WHEN EXISTS (SELECT
                1
            FROM LY_CONVOCADOS_VEST
            WHERE CANDIDATO = TCA.INSCRITO
            AND CONCURSO = TCA.CONCURSO) THEN 'CONVOCADO'
        ELSE 'N�O CONVOCADO'
    END SIT_CONVOCADO,
    AL.DT_INGRESSO,
    AL.ALUNO,
    AL.SIT_ALUNO,
    AL.CURSO,
    AL.TURMA_PREF,
    CASE
        WHEN TCA.CONCURSO IS NULL THEN 'Venda Direta'
        ELSE 'Processo Seletivo'
    END AS TIPO_INGRESSO,
    (SELECT top 1 SIT_MATRICULA 
	 FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA 
	 WHERE MA.ALUNO = AL.ALUNO GROUP BY SIT_MATRICULA
	 ) AS SIT_MATRICULA,
	(SELECT top 1 TURMA 
	 FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA 
	 WHERE MA.ALUNO = AL.ALUNO GROUP BY TURMA
	 ) AS TURMA
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
    
FULL JOIN  LY_PESSOA PE
    ON PE.PESSOA = TCA.PESSOA

LEFT JOIN LY_PROSPECTO_CAPTACAO PC
    ON PC.PESSOA = PE.PESSOA
    
LEFT JOIN LY_COMPRA_OFERTA CM
	ON CM.ALUNO = AL.ALUNO

LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT
	ON VT.OFERTA_DE_CURSO = TCA.OFERTA_DE_CURSO
	AND VT.CURSO = TCA.CURSO	
    AND VT.TURNO = TCA.TURNO
    AND VT.CURRICULO = TCA.CURRICULO
    

GROUP BY 
		VT.UNIDADE_RESPONSAVEL,
		TCA.CURSO,
		VT.CURSO,
		VT.OFERTA_DE_CURSO,
		TCA.OFERTA_DE_CURSO,
		TCA.CONCURSO,
		VT.TURMA,
		VT.DT_INICIO,
		VT.DT_FIM,
		PC.DT_INSERCAO,
        PE.PESSOA,
        PE.NOME_COMPL,
        PE.PASSAPORTE,
        PE.DDD_FONE,
		PE.FONE,
		PE.DDD_FONE_CELULAR,
		PE.CELULAR,
        TCA.CPF,
        TCA.INSCRITO,
        TCA.SITUACAO,
        TCA.DT_INSCRICAO,
        FC.DATA_INSC,
        PE.SENHA_TAC,
        AL.DT_INGRESSO,
        AL.CANDIDATO,
        AL.ALUNO,
        AL.SIT_ALUNO,
        AL.CURSO,
		AL.TURMA_PREF,
        PE.CPF,
        PE.RG_NUM,
		PE.RG_TIPO,
        PE.E_MAIL,
        CM.FORMA_PAGAMENTO

ORDER BY
		VT.DT_INICIO,
		VT.UNIDADE_RESPONSAVEL,
		VT.CURSO,
		VT.OFERTA_DE_CURSO,
		TCA.CONCURSO,
		VT.TURMA


DROP TABLE #TMP_CANDIDATO_ALUNO