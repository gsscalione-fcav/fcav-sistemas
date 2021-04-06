/*
	EXEC PR_FCAV_LYCEUM_OFERTA_CURSO_ATUALIZA_PORTAL 12613,'S'

	EXEC PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO 12775,'S'
	select * from ly_curso where nome like '%soft skills%'
	SELECT DISTINCT curso, curriculo, turma, 
		ano, semestre periodo, unid_fisica, oferta_de_curso, concurso, 
		servico,
		custo_unitario
	FROM VW_FCAV_CONFERENCIA_DE_CADASTRADOS_TURMAS 
	WHERE TURMA = 'CCQPON T 09'
	
*/

--------------------------------------------------------------------------------------------
USE LYCEUM
GO

DECLARE @turma T_CODIGO
declare @tp_ingresso varchar(2)

SET @turma = 'A-OKRON T 01'

-------------------------------------------------------------------------------------------
-- 1 -- MONTA STRING PARA FAZER O INSERT NA TABELA IMPORTA_TURMAS DA BASE DE DADOS MYSQL DO SITE DA VANZOLINI
BEGIN
    SELECT DISTINCT
       CONCAT( 'INSERT INTO IMPORTA_TURMAS(id_turma, CURSO_OFERTADO, DTINI_OFERTA, DTFIM_OFERTA, TURMA, ANO, DT_INICIO, DT_FIM, SIT_TURMA, DIA_HORARIO_AULAS, LINK) VALUES (',
		OFERTA,
		',''' , 
		CURSO,
		''',''' ,
        CONVERT(varchar, DTINI_OFERTA,21),
        ''',''',
        CONVERT(varchar, CONVERT(varchar(11), DTFIM_OFERTA, 21) + '23:59:59', 21),
        ''',''' ,
        TURMA,
        ''',''' ,
        ANO,
        ''',''' ,
        CONVERT(varchar,DT_INICIO,21),
        ''',''' ,
        CONVERT(varchar,DT_FIM,21),
        ''',''' ,
        SIT_TURMA,
        ''',''' ,
        DIA_HORARIO_AULAS,
        ''',''' ,
        LINK,
        ''');' ) importar_BD_Mysql
    FROM VW_FCAV_INFO_CURSO_PORTAL
    WHERE TURMA IN (@turma)
	AND SIT_TURMA = 'EmInscricao'



    -- Ao final da importa��o execute o update abaixo colocando a turma, para deixar registrado a data da �ltima importa��o.
    UPDATE FCAV_INFO_CURSO_PORTAL2
    SET DT_IMPORT = GETDATE()
    WHERE TURMA IN (@turma)

END


select @tp_ingresso = TP_INGRESSO from VW_FCAV_INI_FIM_CURSO_TURMA where TURMA = @turma

-------------------------------------------------------------------------------------------
-- 2 -- MONTA STRING PARA FAZER O INSERT NA TABELA IMPORTA_TURMAS DA BASE DE DADOS MYSQL DO SITE DA VANZOLINI
BEGIN
    SELECT DISTINCT
		OFERTA,
		CURSO,
        CONVERT(varchar, DTINI_OFERTA,21)DTINI_OFERTA,
        CONVERT(varchar, CONVERT(varchar(11), DTFIM_OFERTA, 21) + '23:59:59', 21) DTFIM_OFERTA,
        TURMA,
        ANO,
        CONVERT(varchar,DT_INICIO,21) AS DT_INICIO,
        CONVERT(varchar,DT_FIM,21) AS DT_FIM,
        ISNULL(SIT_TURMA,'ATUALIZAR DADOS DO PORTAL') AS SIT_TURMA,
        DIA_HORARIO_AULAS,
        LINK
    FROM VW_FCAV_INFO_CURSO_PORTAL
    WHERE TURMA IN (@turma)
end


-------------------------------------------------------------------------------------------	
-- 3 -- INFORMA��O DE NOVAS TURMAS PARA CADASTRAR NO WORDPRESS
BEGIN
    SELECT
        DESCRICAO_COMPL as TITULO_NO_WORDPRESS,
        CARGA_HORARIA,
        FACULDADE AS LOCAL,
        CURSO AS CODIGO,
        RELACAO_DOCUMENTOS,
        COORDENADOR,
        VICE_COORD
    FROM VW_FCAV_INFO_CURSO_PORTAL
    WHERE
		TURMA IN (@turma)
    GROUP BY DT_IMPORT,
             DESCRICAO_COMPL,
             CARGA_HORARIA,
             FACULDADE,
             CURSO,
			 TURMA,
             RELACAO_DOCUMENTOS,
             COORDENADOR,
             VICE_COORD,
             APRESENTACAO_CURSO,
             OBJETIVOS,
             PROGRAMA,
             PUBLICO_ALVO,
             CORPO_DOCENTE,
             DIFERENCIAL,
             CERTIFICACAO,
             METODOLOGIA,
             SISTEMA_AVALIACAO,
             INVESTIMENTO
    ORDER BY DT_IMPORT DESC
END


--IF @tp_ingresso = 'PS'
-- --1-- VERIFICA��O DO CADASTRO PROCESSO SELETIVO
--BEGIN
--    SELECT
--		ISNULL(OFERTA_DE_CURSO,'OFERTA NAO CADASTRADA') AS OC, 
--		UNID_RESP,
--		CURSO,
--		NOME_CURSO,
--		DEPTO,
--		COORDENADOR,
--		VICE_COORD,
--		TURNO,
--		CURRICULO,
--		ANO_INI,
--		SEM_INI,
--		ISNULL(SERVICO_VINCULADO,'SERVICO NAO VINCULADO') SERVICO_VINCULADO,
--		ISNULL(DISCIPLINA_GRADE,'GRADE NAO CADASTRADA')DISCIPLINA_GRADE,
--		SERIE_IDEAL,
--		NOME,
--		CREDITOS,
--		CASE WHEN NIVEL_DISC != NIVEL then 'N�VEL DA TURMA DIFERENTE DA DISCIPLINA'
--		else NIVEL_DISC
--		end NIVEL,
--		TURMA,
--		ANO,
--		SEMESTRE,
--		TUR_UNID_FISICA,
--		DISC_TURMA,
--		DT_INICIO,
--		DT_FIM,
--		SERIE,
--		SIT_TURMA,
--		CASE WHEN CLASSIFICACAO != 'EmInscricao' then 'COLOCAR A TURMA EM INSCRICAO'
--		else CLASSIFICACAO
--		end CLASSIFICACAO,
--		AULAS_PREVISTAS,
--		NUM_ALUNOS,
--		CENTRO_DE_CUSTO,
--		CONCURSO,
--		TIPO_INGRESSO,
--		DTINI_CONCURSO,
--		DTFIM_CONCURSO,
--		ANO_INGR_ONLINE,
--		PER_INGR_ONLINE,
--		INGR_DTINI,
--		INGR_DTFIM,
--		INGR_ESCOLHE_PLANO,
--		INGR_MAX_RESP_FINAN,
--		INGR_DIAS_VENC_BOLETO,
--		CONTRATO,
--		OFERTA_DE_CURSO,
--		CURSO_OFERTADO,
--		DESCRICAO_ABREV,
--		DESCRICAO_COMPL,
--		TURMA_PREF,
--		ANO_INGRESSO,
--		PER_INGRESSO,
--		DTINI_OFERTA,
--		DTFIM_OFERTA,
--		VALOR_A_VISTA_ESTIMADO,
--		OP_OFERTA_TURMA,
--		ISNULL(PLANO,'N�O CADASTRADO') as PLANO,
--		ISNULL(PLANO, 'N�O CADASTRADO') as PLANOPAG,
--		DESCRICAO,
--		MES_INICIAL,
--		NUM_PARCELAS,
--		FORMA_PAGAMENTO,
--		NUM_PARCELAS_CARTAO,
--		N_DIAS_VENC_BOL,
--		SERVICO,
--		CUSTO_UNITARIO
--    FROM VW_FCAV_CURSOS_CADASTRADOS_LYCEUM
--    WHERE  
--	TURMA IN (@turma)

--	ORDER BY CURSO, OFERTA_DE_CURSO DESC, 
--		DT_INICIO, DISC_TURMA
--END
----2-- VERIFICA��O DO CADASTRO VENDA DIRETA
--ELSE
--BEGIN
--    SELECT
--		ISNULL(OFERTA_DE_CURSO,'OFERTA NAO CADASTRADA') AS OC, 
--		UNID_RESP,
--		CURSO,
--		NOME_CURSO,
--		DEPTO,
--		COORDENADOR,
--		VICE_COORD,
--		TURNO,
--		CURRICULO,
--		ANO_INI,
--		SEM_INI,
--		ISNULL(SERVICO_VINCULADO,'SERVICO NAO VINCULADO') SERVICO_VINCULADO,
--		ISNULL(DISCIPLINA_GRADE,'GRADE NAO CADASTRADA')DISCIPLINA_GRADE,
--		SERIE_IDEAL,
--		NOME,
--		CREDITOS,
--		CASE WHEN NIVEL_DISC != NIVEL then 'N�VEL DA TURMA DIFERENTE DA DISCIPLINA'
--		else NIVEL_DISC
--		end NIVEL,
--		TURMA,
--		ANO,
--		SEMESTRE,
--		TUR_UNID_FISICA,
--		DISC_TURMA,
--		DT_INICIO,
--		DT_FIM,
--		SERIE,
--		SIT_TURMA,
--		CASE WHEN CLASSIFICACAO != 'EmInscricao' then 'COLOCAR A TURMA EM INSCRICAO'
--		else CLASSIFICACAO
--		end CLASSIFICACAO,
--		AULAS_PREVISTAS,
--		NUM_ALUNOS,
--		CENTRO_DE_CUSTO,
--		CONTRATO,
--		OFERTA_DE_CURSO,
--		CURSO_OFERTADO,
--		DESCRICAO_ABREV,
--		DESCRICAO_COMPL,
--		TURMA_PREF,
--		ANO_INGRESSO,
--		PER_INGRESSO,
--		DTINI_OFERTA,
--		DTFIM_OFERTA,
--		VALOR_A_VISTA_ESTIMADO,
--		OP_OFERTA_TURMA,
--		ISNULL(PLANO,'N�O CADASTRADO') as PLANO,
--		ISNULL(PLANO, 'N�O CADASTRADO') as PLANOPAG,
--		DESCRICAO,
--		MES_INICIAL,
--		NUM_PARCELAS,
--		FORMA_PAGAMENTO,
--		NUM_PARCELAS_CARTAO,
--		N_DIAS_VENC_BOL,
--		SERVICO,
--		CUSTO_UNITARIO
--    FROM VW_FCAV_CURSOS_CADASTRADOS_LYCEUM
--    WHERE  
--	TURMA IN (@turma)

--	ORDER BY CURSO, OFERTA_DE_CURSO DESC, 
--		DT_INICIO, DISC_TURMA
--END



