
DECLARE @IGPM_BOLSA_PARC bit  
DECLARE @IGPM_PERC T_DECIMAL_MEDIO_PRECISO6  
DECLARE @IGPM_PERC_ANT T_DECIMAL_MEDIO_PRECISO6  
DECLARE @IGPM_VALOR T_DECIMAL_MEDIO  
DECLARE @VALOR_BOLSA T_DECIMAL_MEDIO  
DECLARE @IGPM_BOLSA T_DECIMAL_MEDIO  
DECLARE @IGPM_NAO_CALCULADO bit  


Declare @cobranca numeric
declare @LANC_DEB  numeric
            --    
declare @CURSO  t_codigo
declare @TURNO  T_codigo
declare @parcela numeric

set @cobranca = 211122
set @CURSO = 'CEGP'
set @TURNO = 'MISTO'


select @LANC_DEB = lanc_deb , @parcela = PARCELA
from LY_ITEM_LANC where COBRANCA = @cobranca and LANC_DEB is not null 

select *
from LY_ITEM_LANC where COBRANCA = @cobranca


SET @IGPM_NAO_CALCULADO =  CASE  
								WHEN NOT EXISTS (SELECT  
										*  
									FROM dbo.LY_ITEM_LANC  
									WHERE COBRANCA = @cobranca  
									AND PARCELA = @parcela  
									AND DESCRICAO = 'Acrescimo de IGPM') THEN 1  
								ELSE 0  
							END  


SELECT  SUM(VALOR)  bolsa
FROM dbo.LY_ITEM_LANC  
WHERE COBRANCA = @cobranca  
AND NUM_BOLSA IS NOT NULL  
AND DESCRICAO LIKE 'Bolsa%'  
AND ITEM_ESTORNADO IS NULL  


SET @IGPM_BOLSA_PARC =  
                        CASE  
                            WHEN EXISTS (SELECT  
                                    *  
                                FROM dbo.LY_ITEM_LANC  
                                WHERE COBRANCA = @cobranca  
                                AND NUM_BOLSA IS NOT NULL  
                                AND DESCRICAO LIKE 'Bolsa%'  
                                AND ITEM_ESTORNADO IS NULL) THEN 1  
                            ELSE 0  
                        END  
IF @IGPM_BOLSA_PARC = 1  
            AND @IGPM_NAO_CALCULADO = 0
       
        BEGIN  
            WITH tu  
            AS (SELECT  
                tu.CURSO,  
                tu.TURNO,  
                tu.TURMA,  
                --    
                MIN(  
                CONVERT(varchar, tu.ANO) + '/' + CONVERT(varchar, tu.SEMESTRE)  
                ) AS ANO_SEMESTRE_INICIO,  
                --    
                MIN(tu.DT_INICIO) AS DT_INICIO  
            FROM dbo.LY_TURMA tu  
            GROUP BY tu.CURSO,  
                     tu.TURNO,  
					 tu.TURMA)  
            SELECT  
                @IGPM_PERC = COR.VALOR,  
                @IGPM_PERC_ANT = COR_ANT.VALOR  
            FROM dbo.LY_LANC_DEBITO ld,  
                 tu  
                 LEFT OUTER JOIN LY_CORRECAO COR  
                     ON (  
                     COR.ANO = YEAR(TU.DT_INICIO) + 1  
                     AND COR.MES = MONTH(TU.DT_INICIO)  
                     )  
                 --    
                 LEFT OUTER JOIN LY_CORRECAO COR_ANT  
                     ON (  
                     COR_ANT.ANO = YEAR(DATEADD(mm, -1, TU.DT_INICIO)) + 1  
                     AND COR_ANT.MES = MONTH(DATEADD(mm, -1, TU.DT_INICIO))  
                     )  
            WHERE ld.LANC_DEB = @LANC_DEB  
            --    
            AND tu.CURSO = @CURSO  
            AND tu.TURNO = @TURNO  
            AND tu.ANO_SEMESTRE_INICIO = CONVERT(varchar, ld.ANO_REF) + '/' + CONVERT(varchar, ld.PERIODO_REF)  
  
  
            SELECT  
                @VALOR_BOLSA =  
                SUM(VALOR)  
            FROM dbo.LY_ITEM_LANC  
            WHERE COBRANCA = @cobranca  
            AND NUM_BOLSA IS NOT NULL  
            AND DESCRICAO LIKE 'Bolsa%'  
            AND ITEM_ESTORNADO IS NULL  
  
            SET @IGPM_BOLSA =  
		            @VALOR_BOLSA * @IGPM_PERC  
       
        END  

select  @cobranca as cobranca,
		@CURSO as curso,
		@TURNO as turno,
		@LANC_DEB LANC_DEB, 
		@IGPM_NAO_CALCULADO as IGPM_NAO_CALCULADO,
		@IGPM_BOLSA_PARC IGPM_BOLSA_PARC, 
		@IGPM_PERC as IGPM_PERC, 
		@IGPM_BOLSA as IGPM_bolsa

