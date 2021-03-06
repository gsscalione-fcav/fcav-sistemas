--* ***************************************************************
--*
--*		*** TRIGGER TR_FCAV_LY_CANDIDATO_INS_UPD  ***
--*	
--*	DESCRICAO:
--*     - Deixar a primeira letra de cada nome maiúscula
--*	    - Remove a convocação, se existir, quando o candidato é cancelado e não esteja matriculado.
--*	    - Insere um registro novo na tabela FCAV_CANDIDATOS	a cada vez que um curriculo novo for cadastrado
--*
--*	ALTERAÇÕES:
--*
--* Porção FCAV_CANDIDATOS
--*
--*     13/01/14 - Inserido a data de inscrição no INSERT para atualizar a tabela FCAV_CANDIDATOS com essa data.
--*     09/10/14 - Para o caso em que o candidato é transferido e está cancelado a data de inscrição estava ficando em branco,
--*                foi colocado esse If para validar essa condição de inscrito com a data em branco e faz um update na ly_candidato. Por Gabriel
--*     09/06/15 - Criado um filtro para inserir somente os candidatos que fizeram inscrição pelo site, não pegando o cadastro da secretaria.
--* ***************************************************************

ALTER TRIGGER [dbo].[TR_FCAV_LY_CANDIDATO_INS_UPD]
ON [dbo].[LY_CANDIDATO]
AFTER INSERT, UPDATE
AS
SET NOCOUNT ON
BEGIN
    BEGIN
        ------------------------------------------------------------------------
        -- Garante primeira maiúscula para NOME_COMPL
        ------------------------------------------------------------------------

        UPDATE cnd
        SET NOME_COMPL = dbo.FN_FCAV_PRIMEIRA_MAIUSCULA(cnd.NOME_COMPL)
        FROM
            INSERTED ins
                INNER JOIN dbo.LY_CANDIDATO cnd
                ON(
                        cnd.CONCURSO  = ins.CONCURSO
                    AND cnd.CANDIDATO = ins.CANDIDATO
                )
    END -- Garante primeira maiúscula para NOME_COMPL

    BEGIN
        ------------------------------------------------------------------------
        -- Remove a convocação, se existir, quando o candidato é cancelado
        -- e não esteja matriculado.
        ------------------------------------------------------------------------

	    DELETE cnv_vest
        FROM
            INSERTED ins
                INNER JOIN LY_CONVOCADOS_VEST cnv_vest
                ON(
                        cnv_vest.CONCURSO  = ins.CONCURSO
                    AND cnv_vest.CANDIDATO = ins.CANDIDATO
                )
        WHERE
            ins.SIT_CANDIDATO_VEST = 'Cancelado'
        --
        AND cnv_vest.MATRICULADO = 'N'
    END -- Remove a convocação, se existir, quando o candidato é cancelado
        -- e não esteja matriculado.

    BEGIN
        ------------------------------------------------------------------------
        -- Inicializa a data de inscrição
        ------------------------------------------------------------------------

	    UPDATE cnd
	    SET DT_INSCRICAO = GETDATE()
        FROM
            INSERTED ins
                INNER JOIN LY_CANDIDATO cnd
                ON(
                        cnd.CONCURSO  = ins.CONCURSO
                    AND cnd.CANDIDATO = ins.CANDIDATO
                )
        WHERE
            ins.SIT_CANDIDATO_VEST <> 'Cancelado'
        AND ins.DT_INSCRICAO IS NULL
    END -- Inicializa a data de inscrição

    BEGIN
        ------------------------------------------------------------------------
        -- Insere/atualiza FCAV_CANDIDATOS
        ------------------------------------------------------------------------

        ----------------------------------------------------
        -- Massa a ser inserida ou alterada
        
	    SELECT
            CASE WHEN _cnd.CANDIDATO IS NULL THEN 'I'
                                             ELSE 'U'
            END AS ACAO,
            --
		    ins.CANDIDATO,
		    ins.CONCURSO,
            --
		    CASE
                WHEN cv.PESSOA IS NULL
                    THEN '/CURRICULO_NÃO_ANEXADO'
			    ELSE
                    '/Curriculos/' +
                    ISNULL(pes.CPF, pes.PASSAPORTE) + '_' +
                    CONVERT(VARCHAR, ins.PESSOA, 20) +
                    '.' +                         -- A partir da versão 7 não há terminação na extensão
                    REPLACE(cv.EXTENSAO, '.', '') -- então, devemos retirar quando da versão 6 para trás
			    END AS LINK_CV,
            --
            ins.PESSOA,
            --
            cnd.DT_INSCRICAO AS DATA_INSC -- Pode ter sido inicializado na primeira parte desse script
                                          -- estando diferente de INSERTED
        INTO #wrk
	    FROM
            INSERTED ins
                INNER JOIN LY_CANDIDATO cnd -- Para recuperar DT_INSCRICAO - ver comentário acima
                ON(
                        cnd.CONCURSO  = ins.CONCURSO
                    AND cnd.CANDIDATO = ins.CANDIDATO
                )
                --
                LEFT OUTER JOIN LY_MINI_CURRICULO cv
                ON cv.PESSOA = ins.PESSOA
                --
                INNER JOIN LY_PESSOA pes
                ON pes.PESSOA = ins.PESSOA
                --
                LEFT OUTER JOIN dbo.FCAV_CANDIDATOS _cnd
                ON(
                        _cnd.CONCURSO  = ins.CONCURSO
                    AND _cnd.CANDIDATO = ins.CANDIDATO
                )
                --
                INNER JOIN LY_CONCURSO con
                ON con.CONCURSO = ins.CONCURSO

        ----------------------------------------------------
        -- Insere novos registros

        INSERT FCAV_CANDIDATOS(CANDIDATO, CONCURSO, LINK_CV, PESSOA, DATA_INSC)
        SELECT CANDIDATO, CONCURSO, LINK_CV, PESSOA, DATA_INSC
        FROM #wrk
        WHERE
            ACAO = 'I'
        AND NOT EXISTS(
                    SELECT *
                    FROM dbo.FCAV_CANDIDATOS can
                    WHERE
                        can.CONCURSO  = #wrk.CONCURSO
                    AND can.CANDIDATO = #wrk.CANDIDATO
                )

        ----------------------------------------------------
        -- Atualiza registros existentes

        UPDATE _cnd
        SET LINK_CV = wrk.LINK_CV
        FROM
            #wrk wrk
                inner JOIN dbo.FCAV_CANDIDATOS _cnd
                ON(
                        _cnd.CONCURSO  = wrk.CONCURSO
                    AND _cnd.CANDIDATO = wrk.CANDIDATO
                )
        WHERE wrk.ACAO = 'U'

        ----------------------------------------------------
        -- Clean-up

        DROP TABLE #wrk
    END -- Insere/atualiza FCAV_CANDIDATOS
END
