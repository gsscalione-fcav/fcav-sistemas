/*
	Relaciona todos os alunos que fizeram o pagamento por cart�o que n�o possui boleto gerado.

*/

ALTER VIEW VW_FCAV_PGTOS_CARTAO_SEM_BOLETO
AS

with TMP_CANDIDATO_ALUNO
as (
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
FROM LY_CANDIDATO CA
INNER JOIN LY_OFERTA_CURSO OC
    ON OC.CONCURSO = CA.CONCURSO
INNER JOIN FCAV_CANDIDATOS FC
	ON FC.CANDIDATO = CA.CANDIDATO
	AND FC.CONCURSO = CA.CONCURSO
WHERE OC.CONCURSO IS NOT NULL
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
)
-----------------------------------------------------------------------
--CONSULTA

SELECT
	TCA.CURSO,
	TCA.TURNO,
	TCA.CURRICULO,
	TCA.OFERTA_DE_CURSO AS OFERTA,
	TCA.CONCURSO,
    PE.PESSOA,
    TCA.INSCRITO,
    PE.NOME_COMPL,
    PE.CPF,
    PE.E_MAIL,   
    AL.ALUNO,
    AL.SIT_ALUNO,
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
	 ) AS TURMA,
    PP.PLANOPAG AS PLANO_PGTO_PERIODO,
    CM.FORMA_PAGAMENTO,
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
	CM.COBRANCA,
	CB.BOLETO,
	CO.DATA_DE_VENCIMENTO,
    BL.VALOR,
    BL.MOTIVO,
    (SELECT DISTINCT
        SUM(VALOR)
    FROM LY_ITEM_LANC IIL
    WHERE IIL.ALUNO = AL.ALUNO
    AND (IIL.DESCRICAO != 'VALOR ACORDADO'
    AND IIL.ACORDO IS NULL))
    AS VALOR_PAGAR,
	NF.NUMERO_RPS,
	NF.DATA_EMISSAO_RPS,
	NF.DATA_ENVIO_RPS,
	NF.LINK_RPS,
	NF.VALOR_SERVICO_RPS,
	NF.NUMERO_NFE,
	NF.DATA_EMISSAO_NFE,
	VO.VOUCHER,
	VO.DESC_PERC_VALOR,
	VO.DESCONTO

FROM TMP_CANDIDATO_ALUNO TCA

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
    
LEFT JOIN LY_COMPRA_OFERTA CM
	ON CM.ALUNO = AL.ALUNO

inner JOIN VW_COBRANCA_BOLETO CB
	ON CB.COBRANCA = CM.COBRANCA

LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT
	ON VT.OFERTA_DE_CURSO = TCA.OFERTA_DE_CURSO
LEFT JOIN LY_COBRANCA CO 
	ON CO.ALUNO = AL.ALUNO
	AND CO.COBRANCA = CM.COBRANCA
LEFT JOIN LY_COBRANCA_NOTA_FISCAL NF
	ON NF.COBRANCA = CO.COBRANCA
LEFT JOIN VW_FCAV_ALUNOS_COM_VOUCHERS VO
	ON VO.ALUNO = AL.ALUNO
	AND VO.OFERTA_DE_CURSO = CM.OFERTA_DE_CURSO
	
WHERE
--	PC.EMPRESA IS NOT NULL
--	AND VT.UNIDADE_RESPONSAVEL = 'PALES'
CM.FORMA_PAGAMENTO = 'Cartao' AND 
CM.DATA_INCLUSAO >= '2018-11-01 00:00:00.000'
--CB.BOLETO IS NULL

	
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
         TCA.TURNO,
		 TCA.CURRICULO,
         TCA.INSCRITO,
         TCA.SITUACAO,
         TCA.DT_INSCRICAO,
         TCA.CURSO,
		 TCA.OFERTA_DE_CURSO,
         FC.DATA_INSC,
         PE.SENHA_TAC,
         AL.DT_INGRESSO,
         AL.CANDIDATO,
         AL.ALUNO,
         AL.SIT_ALUNO,
		 AL.TURMA_PREF,
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
         RE.CPF_TITULAR,
         CM.FORMA_PAGAMENTO,
		 CM.COBRANCA,
		 CB.BOLETO,
		 CO.DATA_DE_VENCIMENTO,
		 VT.TURMA,
		 NF.NUMERO_RPS,
		 NF.DATA_EMISSAO_RPS,
		 NF.DATA_ENVIO_RPS,
		 NF.LINK_RPS,
		 NF.VALOR_SERVICO_RPS,
		 NF.NUMERO_NFE,
		 NF.DATA_EMISSAO_NFE,
		 VO.VOUCHER,
		 VO.DESC_PERC_VALOR,
		 VO.DESCONTO

