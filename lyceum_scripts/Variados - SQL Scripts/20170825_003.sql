
SELECT DISTINCT
    ca.CONCURSO,
    ca.NOME_COMPL,
    ca.SEXO,
    ca.E_MAIL,
    ca.FONE,
    ca.FONE_CELULAR,
    ca.FONE_COMERCIAL,
    ca.RG_NUM,
    ca.CPF,
    LY_PESSOA.PROFISSAO,
    LY_PESSOA.NOME_EMPRESA,
    LY_PESSOA.CARGO,
    ca.SIT_CANDIDATO_VEST,
    al.SIT_ALUNO,
    FCAV_CANDIDATOS.CONVOCADO,
    cv.MATRICULADO,
    ca.DT_INSCRICAO,
    ca.FL_FIELD_02,
    ca.FL_FIELD_03,
    FCAV_CANDIDATOS.DATA_INSC,
    pm.SIT_MATRICULA
FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA pm
FULL OUTER JOIN ((((FCAV_CANDIDATOS FCAV_CANDIDATOS
INNER JOIN LY_CANDIDATO ca
    ON (FCAV_CANDIDATOS.CONCURSO = ca.CONCURSO)
    AND (FCAV_CANDIDATOS.CANDIDATO = ca.CANDIDATO))
INNER JOIN LY_PESSOA LY_PESSOA
    ON ca.PESSOA = LY_PESSOA.PESSOA)
LEFT OUTER JOIN LY_ALUNO al
    ON (ca.CONCURSO = al.CONCURSO)
    AND (ca.CANDIDATO = al.CANDIDATO))
LEFT OUTER JOIN LY_CONVOCADOS_VEST cv
    ON (ca.CONCURSO = cv.CONCURSO)
    AND (ca.CANDIDATO = cv.CANDIDATO))
    ON pm.ALUNO = al.ALUNO
WHERE ca.CONCURSO = 'CEGP T 66'
	or AL.TURMA_PREF = 'CEGP T 66'
ORDER BY ca.CONCURSO, ca.NOME_COMPL

