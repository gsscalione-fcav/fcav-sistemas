﻿/*    

select * from ly_oferta_curso where oferta_de_curso = 12625

 select * from FCAV_CANDIDATOS where candidato = '202020249'

 select * from ly_aluno where candidato = '202020249'
--

Aluno Editor: A201400091
Senha: A201400091

SELECT * FROM VW_FCAV_CRONOGRAMA_TURMA_COORDENADOR WHERE 
Gera
/*pessoa		-*/ EXEC PR_FCAV_CONSULTA_PESSOA 128219,NULL,NULL,NULL,NULL ,NULL
/*pessoa		-*/ EXEC PR_FCAV_CONSULTA_PESSOA 128197,NULL,NULL,NULL,NULL ,NULL
/*nome			-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL,'%Rafael%Barçante%',NULL,NULL,NULL ,NULL
/*nome			-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL,'%Jack %',NULL,NULL,NULL ,NULL
/*cpf			-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL, NULL, '31273654897', NULL, NULL, NULL
/*e_mail		-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL, NULL, NULL,'%danilonck@outlook.com%', NULL, NULL
/*candidato		-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL,NULL,NULL,NULL,'202020179',NULL
/*aluno			-*/ EXEC PR_FCAV_CONSULTA_PESSOA NULL,NULL,NULL,NULL,NULL,'E201910011'

SELECT 
	habilitado, 
	NOME, 
	USUARIO AS LOGIN, 
	DBO.DECRYPT(SENHA) AS SENHA,
	ALTERAR_SENHA
FROM 
	HD_USUARIO 
WHERE NOME LIKE 'alyne%'
AND HABILITADO = 'S'

select * from fcav_webusers where nome like '%JESSICA%'

----# BLOQUEIO DE USUARIO #------

update HD_USUARIO 
set	HABILITADO = 'S',
	SENHA = dbo.Crypt('123456789'),
	ALTERAR_SENHA = 'S'
WHERE NOME LIKE 'Joaquim Sargaco%'


update fcav_webusers
set
	PASS = '140739'
WHERE ID = '88'

*/

if OBJECT_ID('TempDB.dbo.#TMP_CANDIDATO_ALUNO') IS NOT NULL
begin
	DROP TABLE #TMP_CANDIDATO_ALUNO
end
---------------------------------------------------------------------------------
----Acompanhamento das ultimas inscrições
begin
SELECT
    CA.PESSOA,
	CA.OBS,
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
GROUP BY CA.PESSOA,
         CA.CANDIDATO,
         CA.OBS,
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
    NULL AS OBS,
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


-----------------------------------------------------------------------
--CONSULTA

SELECT TOP 200
	TCA.DT_INSCRICAO,
	AL.DT_INGRESSO,
	TCA.CURSO,
	TCA.TURNO,
	TCA.CURRICULO,
	TCA.OFERTA_DE_CURSO AS OFERTA,
	VT.TURMA,
	TCA.CONCURSO,
    PE.PESSOA,
    TCA.INSCRITO,
    PE.NOME_COMPL,
    PE.CPF,
    PE.RG_NUM,
    PE.RG_TIPO,
    PE.E_MAIL,
	DBO.Decrypt(PE.SENHA_TAC) AS SENHA,
    TCA.OBS,
    CASE WHEN TCA.CONCURSO IS NOT NULL THEN TCA.SITUACAO
        ELSE ''
    END AS SIT_CANDIDATO,
    CASE WHEN TCA.CONCURSO IS NOT NULL THEN TCA.CONCURSO
        ELSE ''
    END AS CONCURSO,
    CASE WHEN EXISTS (SELECT
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
    CASE WHEN TCA.CONCURSO IS NULL THEN 'Venda Direta'
        ELSE 'Processo Seletivo'
    END AS TIPO_INGRESSO,
    (SELECT top 1 SIT_MATRICULA 
	 FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA 
	 WHERE MA.ALUNO = AL.ALUNO GROUP BY SIT_MATRICULA
	 ) AS SIT_MATRICULA,
	 (SELECT top 1 ALOCADO
	 FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA 
	 WHERE MA.ALUNO = AL.ALUNO GROUP BY ALOCADO
	 ) AS ALOCADO,
	(SELECT top 1 TURMA 
	 FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MA 
	 WHERE MA.ALUNO = AL.ALUNO GROUP BY TURMA
	 ) AS TURMA,
    CASE
        WHEN EXISTS (SELECT
                1
            FROM LY_H_CURR_ALUNO
            WHERE ALUNO = TCA.INSCRITO) THEN 'Transferido'
        ELSE 'Normal'
    END ORIGEM,
	REP.EMPRESA,
	REP.RAZAO_SOCIAL,
	REP.CNPJ,
	REP.REPRESENTANTE,
	REP.SENHA,
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
    BL.VALOR,
    BL.MOTIVO,
	VO.VOUCHER,
	VO.DESCONTO,
	VO.DESC_PERC_VALOR,
	VALOR_PAGAR,
	VALOR_PAGO

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

LEFT JOIN VW_FCAV_INI_FIM_CURSO_TURMA VT
	ON VT.OFERTA_DE_CURSO = TCA.OFERTA_DE_CURSO

LEFT JOIN VW_FCAV_ALUNOS_COM_VOUCHERS VO
	ON VO.ALUNO = AL.ALUNO
LEFT JOIN VW_FCAV_EXTFIN_LY EX
	ON EX.ALUNO = AL.ALUNO

left join 
	(select	pr.id_prospecto_captacao,
			em.empresa, 
			em.razao_social,
			em.nome,
			em.cnpj,
			em.pessoa, 
			pe.nome_compl representante,
			pe.e_mail,
			DBO.DECRYPT(pe.senha_tac) senha
			
	 from LY_EMPRESA EM
		LEFT JOIN LY_PESSOA PE
			ON EM.PESSOA = PE.PESSOA
		LEFT JOIN LY_PROSPECTO_CAPTACAO PR
			ON PR.EMPRESA = EM.EMPRESA
	) REP
	ON REP.ID_PROSPECTO_CAPTACAO = CM.ID_PROSPECTO_CAPTACAO

--WHERE vt.OFERTA_DE_CURSO = 12607
--	--PC.EMPRESA IS NOT NULL
--	--AND VT.UNIDADE_RESPONSAVEL = 'PALES'
	
GROUP BY PC.DT_INSERCAO,
		 PC.EMPRESA,
         PE.PESSOA,
         PE.NOME_COMPL,
         PE.PASSAPORTE,
         PE.DT_NASC,
         TCA.OBS,
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
         AL.CURSO,
		 AL.TURMA_PREF,
         PE.CPF,
         PE.RG_NUM,
		 PE.RG_TIPO,
         PE.E_MAIL,
         PP.PLANOPAG,
         RE.RESP,
         RE.TITULAR,
         PP.PERCENT_DIVIDA_ALUNO,
         BL.TIPO_BOLSA,
         BL.NUM_BOLSA,
         BL.PERC_VALOR,
         BL.VALOR,
         BL.MOTIVO,
		 VO.VOUCHER,
		 VO.DESCONTO,
		 VO.DESC_PERC_VALOR,
         CT.CONTRATO_ACEITO,
         CT.DATA_ACEITE,
		 RE.CGC_TITULAR,
         RE.CPF_TITULAR,
         CM.FORMA_PAGAMENTO,
		 VT.TURMA,
		 EX.VALOR_PAGAR,
		 EX.VALOR_PAGO,
		 REP.EMPRESA,
		 REP.RAZAO_SOCIAL,
		 REP.CNPJ,
		 REP.REPRESENTANTE,
		 REP.SENHA

ORDER BY 
YEAR(TCA.DT_INSCRICAO) DESC, MONTH(TCA.DT_INSCRICAO) DESC, DAY(TCA.DT_INSCRICAO) DESC, DATEPART(HOUR, TCA.DT_INSCRICAO) DESC, DATEPART(MINUTE, TCA.DT_INSCRICAO) DESC,
YEAR(AL.DT_INGRESSO) DESC, MONTH(AL.DT_INGRESSO) DESC, DAY(AL.DT_INGRESSO) DESC, DATEPART(HOUR, AL.DT_INGRESSO) DESC, DATEPART(MINUTE, AL.DT_INGRESSO) DESC

--DATEPART(HOUR, IL.DATA) DESC, DATEPART(MINUTE, IL.DATA) DESC
PRINT ('ALUNOS RECÉM PRE_MATRICULADOS  ********** ')


DROP TABLE #TMP_CANDIDATO_ALUNO
end

-----------------------------------------------------------------------
--ENVIO DE E-MAIL

--SELECT TOP 100
--	SIT_EMAIL_LOTE,
--	NUMERO_TENTATIVAS,
--	DATA_ULTIMA_TENTATIVA,
--	MENSAGEM_ERRO,
--	EL.*,
--	PESSOA,
--	ALUNO,
--	EMAIL_DESTINATARIO,
--	NOME_DESTINATARIO
--FROM LY_EMAIL_LOTE EL 
--INNER JOIN LY_EMAIL_LOTE_DEST ED
--	ON ED.ID_EMAIL_LOTE = EL.ID_EMAIL_LOTE
--ORDER BY EL.ID_EMAIL_LOTE DESC


--SELECT * 
--FROM msdb.dbo.sysmail_allitems 

----where subject = 'LISTA DE ESPERA'
----body like '%Palestra - Liderança e Clima Organizacional - Práticas de Liderança na Construção de um Excelente Ambiente de Trabalho.%'
--order by mailitem_id desc