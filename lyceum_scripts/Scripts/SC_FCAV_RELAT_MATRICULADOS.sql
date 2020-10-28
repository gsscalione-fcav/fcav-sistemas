/*
	SC_FCAV_RELAT_MATRICULADOS

	Finalidade: Script utilizado na planilha de Relatório de Matricula de Alunos Lyceum.xls

	SELECT * FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA WHERE ALUNO = 'E201910009'

Autor: Gabriel Serrano Scalione
Data: 19/02/2019

*/

SELECT
	CT.UNIDADE_RESPONSAVEL,
	mp.CURSO,
	CS.NOME AS NOME_CURSO,
	mp.TURMA,
	 ISNULL((SELECT TOP 1      
        CASE      
            WHEN (CLASSIFICACAO IS NULL OR CLASSIFICACAO NOT LIKE 'Cancel%') AND      
                CT.DT_INICIO > GETDATE() THEN 'Em Inscrição'      
            WHEN (CLASSIFICACAO IS NULL OR CLASSIFICACAO NOT LIKE 'Cancel%') AND      
                (GETDATE() BETWEEN CT.DT_INICIO AND CT.DT_FIM) THEN 'Em Andamento'      
            WHEN (CLASSIFICACAO IS NULL OR CLASSIFICACAO NOT LIKE 'Cancel%') AND      
                CT.DT_FIM < GETDATE() THEN 'Concluido'      
            WHEN CLASSIFICACAO LIKE 'Cancel%' THEN 'Cancelada'   
			ELSE 'NÃO CLASSIFICADA' 
        END      
    FROM LY_TURMA TU      
    WHERE TU.TURMA = ct.TURMA      
    AND TU.SERIE = 1      
    GROUP BY CLASSIFICACAO), 'NÃO CLASSIFICADA')     
    AS STATUS_TURMA,
	MP.FACULDADE AS UNIDADE_FISICA,
	MP.ALUNO,
	PE.NOME_COMPL AS NOME,
	pe.CPF AS CPF,
	pe.RG_NUM,
	LOWER(pe.E_MAIL) AS E_MAIL,

	case when PE.DDD_FONE_CELULAR is null AND LEN(replace(replace(pe.CELULAR,'-',''),' ','')) > 9 then left(replace(replace(pe.CELULAR,'-',''),' ',''),2)
	else PE.DDD_FONE_CELULAR END AS DDD_CELULAR,
	RIGHT(replace(replace(pe.CELULAR,'-',''),' ',''),9) as CELULAR,

	case when PE.DDD_FONE is null AND LEN(replace(replace(pe.FONE,'-',''),' ','')) > 8 then left(replace(replace(pe.FONE,'-',''),' ',''),2)
	else PE.DDD_FONE END AS DDD_FONE,
	RIGHT(replace(replace(pe.FONE,'-',''),' ',''),8) as TELEFONE,
	mp.SIT_MATRICULA AS SIT_MATRICULA,
	min(mp.DT_MATRICULA) AS DT_MATRICULA,
	CT.DT_INICIO AS DT_INICIO_TURMA,
	DATEDIFF(day,min(mp.DT_MATRICULA), ct.DT_INICIO) AS Ate_30Dias

FROM
	VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA mp 
	INNER JOIN LY_PESSOA pe on (PE.PESSOA= MP.PESSOA)
	INNER JOIN LY_CURSO CS 
		ON CS.CURSO = MP.CURSO
	INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA CT
		ON CT.TURMA = MP.TURMA
--WHERE 
--	MP.TURMA = 'CEAI T 34'
GROUP BY
	ct.UNIDADE_RESPONSAVEL,
	mp.CURSO,
	CS.NOME,
	ct.TURMA,
	mp.TURMA,
	MP.FACULDADE,
	MP.ALUNO,
	PE.NOME_COMPL,
	pe.RG_NUM,
	pe.CPF,
	pe.E_MAIL,
	ct.DT_INICIO,
	ct.DT_FIM,
	PE.DDD_FONE_CELULAR,
	pe.CELULAR,
	PE.DDD_FONE,
	pe.FONE,
	mp.SIT_MATRICULA,
	--DT_MATRICULA,
	CT.DT_INICIO
ORDER BY
	mp.CURSO, mp.TURMA, MP.ALUNO