--* ***************************************************************         
--*         
--*  *** PROCEDURE a_APoI_Ly_lanc_debito  ***         
--*          
--* DESCRICAO:         
--*  - Está procedure foi criada pela Techne e por isso o nome dela            
--*  não possui o padrão fcav como está no nome.           
--*             
--*  - Inserir automaticamente grupos de itens de cobrança nas dívidas dos alunos             
--*         
--* USO:         
--* - Entry point disparada no momento da geração do boleto         
--*         
--* ALTERAÇÕES:      
--*  27/09/2017 - Grupo 04 foi comentado para que seja possível escolher outra conta      
--*      para os acordos conforme a unidade responsável. Gabriel Scalione.     
--*  27/03/2018 - EP Reajustado para atender as condições das contas.   
--*	 11/04/2019 - Retirado o Grupo 003 da regra conforme solicitação da Cláudia do Financeiro. Gabriel
--*
--* Autor: NATÁLIA ORSETTI (TECHNE)         
--* Data de criação: 25/10/2013         
--*          
--* ***************************************************************               
ALTER PROCEDURE a_apoi_ly_lanc_debito @ERRO             VARCHAR(1024) OUTPUT, 
                                       @LANC_DEB         NUMERIC(10), 
                                       @CODIGO_LANC      VARCHAR(20), 
                                       @ALUNO            VARCHAR(20), 
                                       @ANO_REF          NUMERIC(4), 
                                       @PERIODO_REF      NUMERIC(2), 
                                       @DATA             DATETIME, 
                                       @VALOR            NUMERIC(10, 2), 
                                       @LOTE             NUMERIC(10), 
                                       @DESCRICAO        VARCHAR(100), 
                                       @SOLICITACAO      NUMERIC(10), 
                                       @ITEM_SOLICITACAO NUMERIC(10), 
                                       @TRANCADO_CALCULO VARCHAR(1), 
                                       @GRUPO            VARCHAR(20) 
AS 
    -- [INÍCIO]                    
    DECLARE @UNID_RESP VARCHAR(20) 
    DECLARE @CURSO VARCHAR(20) 
	DECLARE @TURMA VARCHAR(20) 
    DECLARE @CENTRO_CUSTO VARCHAR(50) 
    DECLARE @ANO_INGRESSO T_ANO 
    DECLARE @SEM_INGRESSO T_SEMESTRE2 


	SET @UNID_RESP		= NULL
	SET @CURSO			= NULL
	SET @TURMA			= NULL
	SET @CENTRO_CUSTO	= NULL
	SET @ANO_INGRESSO	= NULL
	SET @SEM_INGRESSO	= NULL

    SELECT @CURSO = CURSO, 
           @ANO_INGRESSO = ANO_INGRESSO, 
           @SEM_INGRESSO = SEM_INGRESSO,
		   @TURMA = TURMA_PREF
    FROM   LY_ALUNO 
    WHERE  ALUNO = @ALUNO 

    SELECT @UNID_RESP = FACULDADE 
    FROM   LY_CURSO 
    WHERE  CURSO = @CURSO 

    SELECT @CENTRO_CUSTO = CENTRO_DE_CUSTO 
    FROM   LY_TURMA
    WHERE  CURSO = @CURSO
           AND SERIE = 1 
           AND TURMA = @TURMA
    GROUP  BY TURMA, 
              CENTRO_DE_CUSTO 

    IF ( @UNID_RESP = 'ESPEC' ) 
      BEGIN 
          UPDATE LY_LANC_DEBITO 
          SET    GRUPO = 'Grupo 001' 
          WHERE  LANC_DEB = @LANC_DEB 
                 AND ALUNO = @ALUNO 
      END 
    ELSE 
      BEGIN 
          --IF( @CENTRO_CUSTO LIKE '406%') 
          --  BEGIN 
          --      UPDATE LY_LANC_DEBITO 
          --      SET    GRUPO = 'Grupo 003' 
          --      WHERE  LANC_DEB = @LANC_DEB 
          --             AND ALUNO = @ALUNO 
          --  END 
          --ELSE 
          --  BEGIN 
                UPDATE LY_LANC_DEBITO 
                SET    GRUPO = 'Grupo 002' 
                WHERE  LANC_DEB = @LANC_DEB 
                       AND ALUNO = @ALUNO 
          --  END 
      END 

    --[FIM]     
    RETURN 