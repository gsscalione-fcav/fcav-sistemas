--* ***************************************************************       
--*       
--*  *** TRIGGER TR_FCAV_CC_IMPORT  ***       
--*        
--* DESCRICAO:       
--* - Atualização e conferência de Centro de Custo       
--*        
--* PARAMETROS:       
--* -        
--*       
--* USO:       
--* - Atualizar a tabela FCAV_IMPCONT_CAD com o Centro de Custo e taxas cadastradas       
--* no Microsiga       
--*       
--* ALTERAÇÕES: 
--*      24/01/2018 - Otimização no script e colocado o filtro não verificar o centro de custo das turmas do CEAI. Gabriel SS.
--*       
--*        
--* Autor: João Paulo       
--* Data de criação: 01/04/2016       
--*        
--* ***************************************************************  
USE LYCEUM

GO
  
ALTER TRIGGER TR_FCAV_CC_IMPORT  
ON LY_TURMA  
AFTER UPDATE, INSERT  
AS  
  DECLARE @turma varchar(20)  
  DECLARE @cc varchar(20)  
  DECLARE @cc_final varchar(20)  
  DECLARE @cv varchar(2)  
  DECLARE @curriculo varchar(20)  
  DECLARE @turno varchar(20)  
  DECLARE @taxa_fcav varchar(2)  
  DECLARE @taxa_usp varchar(2)  
  DECLARE @taxa_poli varchar(2)  
  DECLARE @taxa_pro varchar(2)  
  DECLARE @curso varchar(20)  
  DECLARE @situacao varchar(20)  
  DECLARE @disciplina varchar(20)  
  DECLARE @assunto varchar(100)  
  DECLARE @texto varchar(8000)  
  DECLARE @endereco varchar(100)  
  DECLARE @destinatario varchar(200)  
  DECLARE @inicio_curso varchar(30)  
  DECLARE @centro_custo varchar(20)  
  DECLARE @serie numeric  
  
  SET @turma = NULL  
  SET @cc = NULL  
  SET @cv = NULL  
  SET @curriculo = NULL  
  SET @turno = NULL  
  SET @taxa_fcav = NULL  
  SET @taxa_usp = NULL  
  SET @taxa_poli = NULL  
  SET @taxa_pro = NULL  
  SET @curso = NULL  
  SET @situacao = NULL  
  SET @disciplina = NULL  
  SET @assunto = NULL  
  SET @texto = NULL  
  SET @endereco = NULL  
  SET @destinatario = NULL  
  SET @inicio_curso = NULL  
  SET @centro_custo = NULL  
  
  BEGIN  
    SELECT  
      @curso = CURSO,  
      @curriculo = CURRICULO,  
      @turno = TURNO,  
      @turma = TURMA,  
      @situacao = CLASSIFICACAO,  
      @cc = ISNULL(CENTRO_DE_CUSTO, '')  
    FROM INSERTED  
    WHERE SERIE = 1  
    GROUP BY CURSO,  
             TURNO,  
             CURRICULO,  
             TURMA,  
             CLASSIFICACAO,  
             CENTRO_DE_CUSTO  
  
    ------------------------------------------------------------------   
    -- ***BLOCO CONDIÇÃO PARA ALTERAÇÕES QUE NÃO POSSUAM O CAMPO CENTRO DE CUSTO PREENCHIDO NO INSERTED      
    SELECT  
      @cc_final =  
                 CASE  
                   WHEN @cc != VC.CENTRO_CUSTO_HADES THEN VC.CENTRO_CUSTO_HADES  
                   ELSE @cc  
                 END  
    FROM VW_FCAV_VERIFICA_CENTRO_CUSTO VC  
    WHERE VC.TURMA = @turma 

    GROUP BY VC.TURMA,  
             VC.CENTRO_CUSTO_HADES  
  
    UPDATE LY_TURMA  
    SET CENTRO_DE_CUSTO = @cc_final  
    WHERE TURMA = @turma  
    AND CURSO NOT LIKE 'CEAI'  
	AND (TURMA NOT LIKE '%EX%' OR TURMA NOT LIKE '%PROJ%')
  
	UPDATE LY_TURMA  
    SET CENTRO_DE_CUSTO = @cc  
    WHERE TURMA = @turma  
    AND CURSO LIKE 'CEAI'
	AND (TURMA NOT LIKE '%EX%' OR TURMA NOT LIKE '%PROJ%')
  
    -------------------------------------------------------------   
    --PREENCHE VARIÁVEL CLASSE VALOR @CV   
    SELECT  
      @cv = (CASE  
        WHEN UNIDADE_RESPONSAVEL = 'ESPEC' THEN '01'  
        WHEN UNIDADE_RESPONSAVEL = 'ATUAL' THEN '32'  
		WHEN UNIDADE_RESPONSAVEL = 'DIFUS' THEN '32'
        WHEN UNIDADE_RESPONSAVEL = 'CAPAC' THEN '31'  
      END)  
    FROM LY_TURMA  
    WHERE TURMA = @turma  
    GROUP BY UNIDADE_RESPONSAVEL  
  
    -------------------------------------------------------------   
    --PREENCHE AS TAXAS E ATUALIZA OS DADOS DA TABELA FCAV_IMPCONT_CAD   
    IF EXISTS (SELECT  
        1  
      FROM  --Producao   
   DADOSADVP12.dbo.CTT010   
   --Homologacao   
   --DADOSADV_HOMOL_P11.dbo.CTT010  
      WHERE CTT_CUSTO = @cc_final)  
    BEGIN  
      SELECT  
        @taxa_fcav = CTT_TX_GER,  
        @taxa_usp = CTT_TX_USP,  
        @taxa_poli = CTT_TX_POL,  
        @taxa_pro = CTT_TX_DEP  
      FROM  --Producao   
   DADOSADVP12.dbo.CTT010   
   --Homologacao   
   --DADOSADV_HOMOL_P11.dbo.CTT010  
      WHERE CTT_CUSTO = @cc_final  
    END  
    ELSE  
    BEGIN  
      SELECT  
        @taxa_fcav = '0',  
        @taxa_usp = '0',  
        @taxa_poli = '0',  
        @taxa_pro = '0'  
    END  
  
    DELETE FCAV_IMPCONT_CAD  
    WHERE TURMA = @turma  
  
    INSERT FCAV_IMPCONT_CAD  
      VALUES (@cc_final, SUBSTRING(@cc_final, 1, 3), @cv, @turma, @turma, @taxa_fcav, @taxa_usp, @taxa_poli, @taxa_pro)  
  
    
  END