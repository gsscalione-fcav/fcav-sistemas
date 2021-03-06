SELECT
    AL.CURSO,
    AL.TURMA,
    AL.SIT_ALUNO,
    AL.ALUNO,
    AL.NOME_COMPL,
    AL.DT_NASC,
    AL.IDADE_ATUAL,
    AL.NACIONALIDADE,
    AL.SEXO,
    AL.EST_CIVIL,
    AL.ENDERECO,
    AL.END_NUM,
    AL.END_COMPL,
    AL.BAIRRO,
    AL.END_MUNICIPIO,
    AL.END_PAIS,
    AL.CEP,
    AL.FONE,
    AL.CELULAR,
    AL.E_MAIL,
    AL.RG_NUM,
    AL.RG_TIPO,
    AL.RG_EMISSOR,
    AL.RG_UF,
    AL.RG_DTEXP,
    AL.CPF,
    AL.PROFISSAO,
    AL.NOME_EMPRESA,
    AL.DT_INICIO_TURMA,
    AL.DT_FIM_TURMA,
    AL.STATUS_TURMA,
    AL.DT_MATRICULA,
    AL.SIT_MATRICULA,
    AL.STATUS,
    AL.TITULAR,
    AL.CPF_CNPJ,
    AL.TIPO_BOLSA,
    AL.NUM_BOLSA,
    AL.PERC_VALOR,
    AL.VALOR,
    AL.MOTIVO AS MOTIVO_BOLSA,
    CASE
        WHEN TR.DT_INI IS NOT NULL AND
            TR.DT_REABERTURA IS NULL THEN 'TRANCADO'
        WHEN TR.DT_INI IS NOT NULL AND
            TR.DT_REABERTURA IS NOT NULL THEN 'RETORNO TRANCAMENTO'
        ELSE ''
    END
    AS SIT_TRANCAMENTO,
    CASE
        WHEN TR.DT_INI IS NOT NULL AND
            MT.DESCRICAO IS NULL THEN 'N�O INFORMADO'
        ELSE MT.DESCRICAO
    END
    AS MOTIVO_TRANC,
    TR.DT_INI,
    TR.DT_FIM,
    TR.DT_REABERTURA AS RETORNO_TRANCAMENTO,
    hc.ANO_ENCERRAMENTO,
    hc.SEM_ENCERRAMENTO,
    hc.DT_ENCERRAMENTO,
    hc.MOTIVO AS MOTIVO_CANCEL,
    hc.CAUSA_ENCERR,
    hc.DT_REABERTURA AS RETORNO_CANCELAMENTO


FROM VW_FCAV_INFO_ALUNOS_LYCEUM AL
LEFT JOIN LY_TRANC_INTERV_DATA TR
    ON TR.ALUNO = AL.ALUNO
LEFT JOIN LY_MOTIVO_TRANCAMENTO MT
    ON MT.MOTIVO_TRANC = TR.MOTIVO_TRANC
LEFT JOIN LY_CAUSA_TRANCAMENTO CT
    ON CT.CAUSA_TRANC = TR.CAUSA_TRANC
LEFT JOIN LY_H_CURSOS_CONCL HC
    ON HC.ALUNO = AL.ALUNO
    AND HC.CURSO = AL.CURSO
LEFT JOIN LY_CAUSA_ENCERR CE
    ON CE.CAUSA_ENCERR = HC.CAUSA_ENCERR

GROUP BY AL.CURSO,
         AL.TURMA,
         AL.SIT_ALUNO,
         AL.ALUNO,
         AL.NOME_COMPL,
         AL.DT_NASC,
         AL.IDADE_ATUAL,
         AL.NACIONALIDADE,
         AL.SEXO,
         AL.EST_CIVIL,
         AL.ENDERECO,
         AL.END_NUM,
         AL.END_COMPL,
         AL.BAIRRO,
         AL.END_MUNICIPIO,
         AL.END_PAIS,
         AL.CEP,
         AL.FONE,
         AL.CELULAR,
         AL.E_MAIL,
         AL.RG_NUM,
         AL.RG_TIPO,
         AL.RG_EMISSOR,
         AL.RG_UF,
         AL.RG_DTEXP,
         AL.CPF,
         AL.PROFISSAO,
         AL.NOME_EMPRESA,
         AL.DT_INICIO_TURMA,
         AL.DT_FIM_TURMA,
         AL.STATUS_TURMA,
         AL.DT_MATRICULA,
         AL.SIT_MATRICULA,
         AL.STATUS,
         AL.TITULAR,
         AL.CPF_CNPJ,
         AL.TIPO_BOLSA,
         AL.NUM_BOLSA,
         AL.PERC_VALOR,
         AL.VALOR,
         AL.MOTIVO,
         MT.DESCRICAO,
         TR.DT_INI,
         TR.DT_FIM,
         TR.DT_REABERTURA,
         HC.ANO_ENCERRAMENTO,
         HC.SEM_ENCERRAMENTO,
         HC.DT_ENCERRAMENTO,
         HC.CAUSA_ENCERR,
         HC.MOTIVO,
         HC.DT_REABERTURA