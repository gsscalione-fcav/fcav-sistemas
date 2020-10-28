 IF EXISTS(SELECT * FROM SYS.procedures WHERE name = 'PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMMON')
DROP PROCEDURE dbo.PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMMON
go

--* ***************************************************************
--*
--*			*** PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMMON ***
--*	
--*	USO:
--*     Chamada via botões da interface do LyceumNG, transação TVEST040D
--*     Código comum a PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_FINANCEIRO e
--*     PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO
--*
--*	Histórico
--*
--*     13/03/2017 - Código removido de TR_FCAV_ENVIO_FORMULARIO
--*	
--* ***************************************************************

CREATE PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMMON(
    @OFERTA_DE_CURSO INT,
    --
    @TURMA     VARCHAR(20) OUTPUT,
    @CURRICULO VARCHAR(20) OUTPUT,
    @TURNO     VARCHAR(20) OUTPUT,
    --
    @valor_total    VARCHAR(2000) OUTPUT,
    @taxa_matricula VARCHAR(2000) OUTPUT,
    @valor_parcela  VARCHAR(2000) OUTPUT,
    @qtde_parcela   VARCHAR(2000) OUTPUT,
    @desc_avista    VARCHAR(200)  OUTPUT,
    --
    @dias_venc_matr VARCHAR(2000) OUTPUT,
    @data_venc_mens VARCHAR(2000) OUTPUT,
    --
    @centro_custo VARCHAR(50)   OUTPUT,
    @oferta_curso VARCHAR(2000) OUTPUT,
    --
    @CATEGORIA           VARCHAR(20)  OUTPUT,
    @NOME_CURSO          VARCHAR(200) OUTPUT,
    @NOME_TURMA          VARCHAR(200) OUTPUT,
    @LOCAL               VARCHAR(20)  OUTPUT,
    @COORDENADOR         VARCHAR(100) OUTPUT,
    @COORD_VICE          VARCHAR(100) OUTPUT,
    @DURACAO             VARCHAR(200) OUTPUT,
    @CARGA_HOR_TOTAL     VARCHAR(20)  OUTPUT,
    @DAT_INI             VARCHAR(20)  OUTPUT,
    @VENCTO_1_MENS       VARCHAR(20)  OUTPUT,
    @MATR                VARCHAR(8)   OUTPUT,
    @ANALISE_CUR         VARCHAR(8)   OUTPUT,
    @ENTREVISTA          VARCHAR(8)   OUTPUT,
    @PROVA               VARCHAR(8)   OUTPUT,
    @REDACAO             VARCHAR(8)   OUTPUT,
    @DATA_INICIO         VARCHAR(20)  OUTPUT,
    @DATA_FIM            VARCHAR(20)  OUTPUT,
    @ALTERACAO_CONT_PROG VARCHAR(8)   OUTPUT,
    @DIAS_HOR            VARCHAR(200) OUTPUT,
    @LINK_INSC           VARCHAR(200) OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
    IF NOT EXISTS(
            SELECT *
            FROM VW_FCAV_INI_FIM_CURSO_TURMA ct
            WHERE ct.OFERTA_DE_CURSO = @OFERTA_DE_CURSO
        )
    BEGIN
        RAISERROR('[PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMMON] Não há entrada correspondente em VW_FCAV_INI_FIM_CURSO_TURMA', 16, 1)
        RETURN @@ERROR
    END
    
    -------------------------------------------------------------

    SELECT
        @turma     = ct.TURMA,
        @curriculo = ISNULL(ct.CURRICULO, '.'),
        @turno     = ISNULL(ct.TURNO, '.'),
        --
        @valor_total    = ISNULL(oc.FL_FIELD_05, '.') /* Valor total do curso sem desconto*/,
        @taxa_matricula = '.',                        /* Não há, pois não trabalharemos com dívida de matrícula */
        @valor_parcela  = ISNULL(oc.FL_FIELD_06, '.') /* Valor da parcela */,
        @qtde_parcela   = ISNULL(oc.FL_FIELD_07, '.') /* Qtde de parcelas */,
        @desc_avista    = ISNULL(oc.FL_FIELD_08, '.') /* % de desconto à vista */,
        --
        @dias_venc_matr = ISNULL(oc.FL_FIELD_09, '.') /* Dias após aceite de vencimento do 1º boleto */,
        @data_venc_mens = ISNULL(oc.FL_FIELD_10, '.') /* DIa de vencimento das demais mensalidadess */
    FROM
        dbo.LY_OFERTA_CURSO oc
            INNER JOIN dbo.VW_FCAV_INI_FIM_CURSO_TURMA ct
            ON ct.OFERTA_DE_CURSO = oc.OFERTA_DE_CURSO
    WHERE oc.OFERTA_DE_CURSO = @OFERTA_DE_CURSO

    -------------------------------------------------------------

    SELECT @oferta_curso = CONVERT(VARCHAR, OC.OFERTA_DE_CURSO) + ' - ' + OC.DESCRICAO_COMPL
    FROM LY_OFERTA_CURSO OC
    WHERE OC.OFERTA_DE_CURSO = @OFERTA_DE_CURSO

    -------------------------------------------------------------

    SELECT
        @CATEGORIA = (CASE WHEN CUR.FACULDADE = 'ATUAL' THEN 'ATUALIZAÇÃO'
            WHEN CUR.FACULDADE = 'ESPEC' THEN 'ESPECIALIZAÇÃO'
            WHEN CUR.FACULDADE = 'CAPAC' THEN 'CAPACITAÇÃO'
            WHEN CUR.FACULDADE = 'PALES' THEN 'PALESTRA'
			WHEN CUR.FACULDADE = 'DIFUS' THEN 'DIFUSÃO' END),
        @NOME_CURSO = (CASE WHEN (CUR.FACULDADE = 'ATUAL' OR CUR.FACULDADE = 'PALES') AND VW.TP_INGRESSO = 'VD' THEN DIS.NOME
            ELSE CUR.NOME END),
        @NOME_TURMA = (CASE WHEN (CUR.FACULDADE = 'ATUAL' OR CUR.FACULDADE = 'PALES') AND VW.TP_INGRESSO = 'VD' THEN DIS.NOME+' - '+TUR.TURMA
            ELSE CUR.NOME+' - '+TUR.TURMA END),
        @LOCAL = TUR.FACULDADE,
        --
        @COORDENADOR =  ISNULL((SELECT DISTINCT
            NOME_COMPL
            FROM VW_FCAV_COORDENADOR_TURMA COORD
            WHERE
                COORD.TURMA = TUR.TURMA AND COORD.TIPO_COORD = 'COORD'),'NAO CADASTRADO'),
        --
        @COORD_VICE = ISNULL((SELECT DISTINCT
            NOME_COMPL
            FROM VW_FCAV_COORDENADOR_TURMA COORD
            WHERE COORD.TURMA = TUR.TURMA and COORD.TIPO_COORD != 'COORD' and (DT_FIM IS NULL OR DT_FIM > getdate())),'.'),
        --
        @DURACAO = ISNULL( (CAST(CURRI.PRAZO_CONC_PREV AS VARCHAR)+' '+CURRI.TIPO_PRAZO_CONCL),'999'),
        @CARGA_HOR_TOTAL = ISNULL(CAST(CURRI.AULAS_PREVISTAS AS DECIMAL),'999'),
        @DAT_INI = ISNULL((select top 1 CONVERT( VARCHAR,DT_INICIO,(103))from LY_TURMA where TURMA = TUR.TURMA order by DT_INICIO ),'01/01/00'),
        @VENCTO_1_MENS = ISNULL(TUR.FL_FIELD_08,'999'),
        --
        @DIAS_HOR = ISNULL(CONC.FL_FIELD_06,'.'),
        --
        @MATR           = CASE WHEN NULL IS NULL THEN 'NAO' ELSE 'SIM' END /* Não há, pois não trabalharemos com dívida de matrícula */,
        --
        @centro_custo = ISNULL(TUR.CENTRO_DE_CUSTO, 'NAO CADASTRADO'),
        --
        @ANALISE_CUR = ISNULL(CONC.FL_FIELD_01, 'NÃO'),
        @ENTREVISTA = ISNULL(CONC.FL_FIELD_02, 'NÃO'),
        @PROVA = ISNULL(CONC.FL_FIELD_03, 'NÃO'),
        @REDACAO = ISNULL(CONC.FL_FIELD_04, 'NÃO'),
        @DATA_INICIO = ISNULL(CONVERT(VARCHAR,OC.DTINI,(103)),'01/01/00'),
        @DATA_FIM = ISNULL(CONVERT(VARCHAR,OC.DTFIM,(103)),'01/01/00'),
        @ALTERACAO_CONT_PROG = ISNULL(CONC.FL_FIELD_05, 'NÃO'),
        @LINK_INSC = ISNULL(VW_LINK.LINK,'.')
    FROM
        LY_TURMA AS TUR
            INNER JOIN LY_CURSO AS CUR ON (TUR.CURSO = CUR.CURSO)
            INNER JOIN LY_CURRICULO AS CURRI ON (TUR.CURRICULO = CURRI.CURRICULO AND TUR.TURNO = CURRI.TURNO)
            INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA AS VW ON (TUR.TURMA = VW.TURMA)
            LEFT JOIN LY_CONCURSO AS CONC ON (VW.CONCURSO = CONC.CONCURSO)
            LEFT JOIN VW_FCAV_LINK_OFERTA_CURSO AS VW_LINK ON (VW.CONCURSO = VW_LINK.CONCURSO)
            INNER JOIN LY_DISCIPLINA AS DIS ON (TUR.DISCIPLINA = DIS.DISCIPLINA)
            INNER JOIN LY_OFERTA_CURSO OC ON (OC.OFERTA_DE_CURSO = VW.OFERTA_DE_CURSO)
    WHERE TUR.TURMA = @turma


    END
