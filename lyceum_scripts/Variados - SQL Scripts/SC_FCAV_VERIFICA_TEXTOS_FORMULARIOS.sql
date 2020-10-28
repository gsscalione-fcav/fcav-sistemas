

DECLARE
    @OFERTA_DE_CURSO INT,
    --
    @TURMA     VARCHAR(20) ,
    @CURRICULO VARCHAR(20) ,
    @TURNO     VARCHAR(20) ,
    --
    @valor_total    VARCHAR(2000) ,
    @taxa_matricula VARCHAR(2000) ,
    @valor_parcela  VARCHAR(2000) ,
    @qtde_parcela   VARCHAR(2000) ,
    @desc_avista    VARCHAR(200)  ,
    --
    @dias_venc_matr VARCHAR(2000) ,
    @data_venc_mens VARCHAR(2000) ,
    --
    @centro_custo VARCHAR(50)   ,
    @oferta_curso VARCHAR(2000) ,
    --
    @CATEGORIA           VARCHAR(20)  ,
    @NOME_CURSO          VARCHAR(200) ,
    @NOME_TURMA          VARCHAR(200) ,
    @LOCAL               VARCHAR(20)  ,
    @COORDENADOR         VARCHAR(100) ,
    @COORD_VICE          VARCHAR(100) ,
    @DURACAO             VARCHAR(200) ,
    @CARGA_HOR_TOTAL     VARCHAR(20)  ,
    @DAT_INI             VARCHAR(20)  ,
    @VENCTO_1_MENS       VARCHAR(20)  ,
    @MATR                VARCHAR(8)   ,
    @ANALISE_CUR         VARCHAR(8)   ,
    @ENTREVISTA          VARCHAR(8)   ,
    @PROVA               VARCHAR(8)   ,
    @REDACAO             VARCHAR(8)   ,
    @DATA_INICIO         VARCHAR(20)  ,
    @DATA_FIM            VARCHAR(20)  ,
    @ALTERACAO_CONT_PROG VARCHAR(8)   ,
    @DIAS_HOR            VARCHAR(200) ,
    @LINK_INSC           VARCHAR(200) 


SET @OFERTA_DE_CURSO = 1432


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
            WHEN CUR.FACULDADE = 'PALES' THEN 'PALESTRA' END),
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
            WHERE COORD.TURMA = TUR.TURMA and COORD.TIPO_COORD != 'COORD'),'.'),
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
        @centro_custo = ISNULL(TUR.CENTRO_DE_CUSTO, 'NAO_CADASTRADO'),
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



SELECT 
	@CATEGORIA AS CATEGORIA,
    @NOME_CURSO AS NOME_CURSO,
    @NOME_TURMA AS NOME_TURMA,
    @LOCAL AS LOCAL,
    --
    @COORDENADOR AS COORDENADOR, 
    --
    @COORD_VICE AS COORD_VICE,
    --
    @DURACAO AS DURACAO,
    @CARGA_HOR_TOTAL AS CARGA_HOR_TOTAL,
    @DAT_INI AS DAT_INI,
    @VENCTO_1_MENS AS VENCTO_1_MENS,
    --
    @DIAS_HOR AS DIAS_HOR ,
    --
    @MATR AS MATR,
    --
    @centro_custo AS centro_custo,
    --
    @ANALISE_CUR AS ANALISE_CUR,
    @ENTREVISTA AS ENTREVISTA,
    @PROVA AS PROVA,
    @REDACAO AS REDACAO,
    @DATA_INICIO AS DATA_INICIO,
    @DATA_FIM AS DATA_FIM,
    @ALTERACAO_CONT_PROG AS ALTERACAO_CONT_PROG,
    @LINK_INSC AS LINK_INSC