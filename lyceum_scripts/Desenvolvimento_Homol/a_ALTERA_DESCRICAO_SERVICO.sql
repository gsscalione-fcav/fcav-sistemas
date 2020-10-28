    
--* ***************************************************************    
--*    
--*   *** PROCEDURE a_ALTERA_DESCRICAO_SERVICO  ***    
--*    
--* DESCRICAO:    
--*    
--* PARAMETROS:    
--*    
--* USO:    
--*     - Inclusão de mensagem personlizada para a NFe    
--*    
--* Alterações:    
--*    
--*     09/03/2017 - Exclusão do corpo da entry-point para a versão 7    
--*     13/03/2017 - Reinclusão do corpo e ajuste    
--*                  A versão 'default' não traz os nomes dos alunos    
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
        -- Determina o centro de curso, curso e texto complementar da cobrança    
        --    
        -- Há problemas nessa view, VW_FCAV_BOLETO_TURMA, não tratados:    
        --    
        --      - Dependência com a tabela FCAV_IMPCONT_CADv    
        --      - Não foi estressada a referência entre LD e outras para chegar em TU,    
        --        garantindo 100% de eficácia    
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
    END -- Determina o centro de curso, curso e texto complementar da cobrança -    
    
    BEGIN    
        ------------------------------------------------------------------------    
        -- Determina os alunos    
        ------------------------------------------------------------------------    
    
        DECLARE cCursor CURSOR LOCAL FAST_FORWARD FOR    
        SELECT    
            DISTINCT /* O boleto pode ser de mais de uma cobrança do mesmo aluno */    
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
    
    BEGIN -- Identificação de bolsa 100% para exibição na descriçao da nota ----	
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
		
		
    END -- Identificação de bolsa 100% para exibição na descriçao da nota ------
    
    
    ----------------------------------------------------------------------------    
    -- Inicializa @p_descricao, ainda sem o nome dos alunos    
    --    
    -- Os alunos serão incluídos a posteriori para garantir o limite máximo de    
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
            'IMUNE A IMPOSTOS DE ACORDO COM O ART. 150, INC. VI, ALÍNEA C DA CONSTITUIÇÃO FEDERAL, ART. 9, INC. VI, ALÍNEA C DO CÓDIGO TRIBUTÁRIO NACIONAL E ARTS. 170 E 171 DO REGULAMENTO DO IMPOSTO DE RENDA.'    
    
    ----------------------------------------------------------------------------    
    -- Acrescenta @ALUNOS, garantindo não ultrapassar 1000 caracteres    
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