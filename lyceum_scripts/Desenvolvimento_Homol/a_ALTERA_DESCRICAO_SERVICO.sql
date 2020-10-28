    
--* ***************************************************************    
--*    
--*   *** PROCEDURE a_ALTERA_DESCRICAO_SERVICO  ***    
--*    
--* DESCRICAO:    
--*    
--* PARAMETROS:    
--*    
--* USO:    
--*     - Inclus�o de mensagem personlizada para a NFe    
--*    
--* Altera��es:    
--*    
--*     09/03/2017 - Exclus�o do corpo da entry-point para a vers�o 7    
--*     13/03/2017 - Reinclus�o do corpo e ajuste    
--*                  A vers�o 'default' n�o traz os nomes dos alunos    
--*    
--* ***************************************************************    
    
CREATE PROCEDURE a_ALTERA_DESCRICAO_SERVICO    
  @p_tipo              VARCHAR(20),    
  @p_boleto_cobranca   T_NUMERO,    
  @p_descricao         T_ALFAEXTRALARGE OUTPUT,    
  @p_codigo_servico    NUMERIC(10,0),    
  @p_Aliquota          NUMERIC(10,2),    
  @p_nota_fiscal_serie VARCHAR(20)    
AS    
BEGIN    
    /*    
        -- Mock para testes    
        DECLARE @p_boleto_cobranca T_NUMERO    
        DECLARE @p_descricao       T_ALFAEXTRALARGE    
    
        SET @p_boleto_cobranca = 78485    
    */    
    
    DECLARE @CC          VARCHAR (20)    
    DECLARE @CURSO       VARCHAR (200)    
    DECLARE @COMPLEMENTO VARCHAR (2000)    
    --    
    DECLARE @ALUNOS VARCHAR(MAX)    
    
    DECLARE @MSG_BOLSA	 VARCHAR (100)
    
    BEGIN    
        ------------------------------------------------------------------------    
        -- Determina o centro de curso, curso e texto complementar da cobran�a    
        --    
        -- H� problemas nessa view, VW_FCAV_BOLETO_TURMA, n�o tratados:    
        --    
        --      - Depend�ncia com a tabela FCAV_IMPCONT_CADv    
        --      - N�o foi estressada a refer�ncia entre LD e outras para chegar em TU,    
        --        garantindo 100% de efic�cia    
        ------------------------------------------------------------------------    
    
        SET @CC          = '.'    
        SET @CURSO       = '.'    
        SET @COMPLEMENTO = '.'    
		SET @MSG_BOLSA	 = '.'
		
        SELECT    
            @CC    = ISNULL(CENTRO_CUSTO, '.'),    
            @CURSO   = ISNULL(CURSO,        '.'),    
            @COMPLEMENTO = ISNULL(COMPLEMENTO,  '.')    
        FROM VW_FCAV_BOLETO_TURMA    
        WHERE BOLETO = @p_boleto_cobranca    
    END -- Determina o centro de curso, curso e texto complementar da cobran�a -    
    
    BEGIN    
        ------------------------------------------------------------------------    
        -- Determina os alunos    
        ------------------------------------------------------------------------    
    
        DECLARE cCursor CURSOR LOCAL FAST_FORWARD FOR    
        SELECT    
            DISTINCT /* O boleto pode ser de mais de uma cobran�a do mesmo aluno */    
                pes.NOME_COMPL    
        FROM    
            dbo.LY_ITEM_LANC il    
                INNER JOIN(    
                    dbo.LY_COBRANCA cob    
                        INNER JOIN(    
                            dbo.LY_ALUNO aln    
                                INNER JOIN dbo.LY_PESSOA pes    
                                ON pes.PESSOA = aln.PESSOA    
                        )    
                        ON aln.ALUNO = cob.ALUNO    
                )    
                ON cob.COBRANCA = il.COBRANCA    
        WHERE    
            il.BOLETO = @p_boleto_cobranca    
        ORDER BY pes.NOME_COMPL    
    
        DECLARE @NOME_COMPL T_ALFALARGE    
    
        OPEN cCursor    
        FETCH cCursor INTO @NOME_COMPL    
    
        SET @ALUNOS = 'Aluno(s): '    
    
        WHILE @@FETCH_STATUS = 0    
        BEGIN    
            SET @ALUNOS = @ALUNOS + @NOME_COMPL + '|'    
    
            FETCH cCursor INTO @NOME_COMPL    
        END    
    END -- Determina os alunos -------------------------------------------------    
    
    BEGIN -- Identifica��o de bolsa 100% para exibi��o na descri�ao da nota ----	
		IF EXISTS (
				SELECT 1
				FROM			LY_ITEM_LANC IL
					INNER JOIN	LY_BOLSA B 
								ON IL.ALUNO		= B.ALUNO 
							   AND IL.NUM_BOLSA = B.NUM_BOLSA
				WHERE 
						IL.BOLETO		= @p_boleto_cobranca
					AND	B.VALOR			= '1.000000'
					)
			
			SELECT @MSG_BOLSA = 'Concessao de Bolsa 100%'
		
		ELSE
			SELECT @MSG_BOLSA = '.'
		
		
    END -- Identifica��o de bolsa 100% para exibi��o na descri�ao da nota ------
    
    
    ----------------------------------------------------------------------------    
    -- Inicializa @p_descricao, ainda sem o nome dos alunos    
    --    
    -- Os alunos ser�o inclu�dos a posteriori para garantir o limite m�ximo de    
    -- 1000 caracteres segundo layout da PMSP    
    ----------------------------------------------------------------------------    
    
    SET    
        @p_descricao =    
            'Curso: ' + @CURSO + '|' +    
            'CC: '    + @CC    + '|' +    
            --    
           '|' +    
            @COMPLEMENTO + '|' +    
            --    
            '|' +    
            --
            @MSG_BOLSA + '|' +    
            --
            '|' +    
            'Valor aproximado dos Impostos:|' +    
         'Municipais  - R$ 0,00 (0%)|'     +    
         'Federais    - R$ 0,00 (0%)|'     +    
            --    
            '|' +    
            'IMUNE A IMPOSTOS DE ACORDO COM O ART. 150, INC. VI, AL�NEA C DA CONSTITUI��O FEDERAL, ART. 9, INC. VI, AL�NEA C DO C�DIGO TRIBUT�RIO NACIONAL E ARTS. 170 E 171 DO REGULAMENTO DO IMPOSTO DE RENDA.'    
    
    ----------------------------------------------------------------------------    
    -- Acrescenta @ALUNOS, garantindo n�o ultrapassar 1000 caracteres    
    ----------------------------------------------------------------------------    
    
    SET    
        @p_descricao =    
            CASE    
                WHEN LEN(@p_descricao) + LEN(@ALUNOS) > 1000    
                    THEN    
                        LEFT(@ALUNOS, 1000 - LEN(@p_descricao) - 1 /* vamos garantir que termine em | */) +    
                        '|'    
                    ELSE    
                        @ALUNOS    
            END +    
            @p_descricao    
    
    RETURN    
END 