--* ***************************************************************  
--*  
--*  *** PROCEDURE A_PROC_LISTA_NFE  ***  
--*   
--* DESCRICAO:  
--*  - Monta dados e link sobre Nota Fiscal dos boletos que ficam disponíveis no AOnline
--*
--* ALTERAÇÕES:   
--*		07/12/2017 - Alterado o link de http para https. Gabriel Scalione
--*  
--* Autor: Techne
--*	Date: 2014-06-03 10:39:37.250
--*   
--* ***************************************************************   
  
ALTER PROCEDURE [DBO].[A_PROC_LISTA_NFE](@P_ALUNO T_CODIGO)  
   AS     
    
    SELECT DISTINCT              
      ANO_NOTA AS ANO            
     ,MES_NOTA AS MES            
     ,NFSE AS NFSE            
     ,CODIGO_VERIFICACAO AS CODIGOVERIFICACAO            
     -- ,CONVERT(VARCHAR,DATA_EMISSAO_NFE,103) AS DATAEMISSAO             
     ,DATA_EMISSAO_NFE AS DATAEMISSAO             
     ,VALOR_SERVICO AS VALORSERVICO            
     ,('<a title="NFSe" href="https://'+ LINK +'" target="blank">https://'+ LINK +'</a>') AS LINK            
    FROM A_VW_CONSULTA_RPS A             
    WHERE ALUNO = @P_ALUNO            
--    AND LINK IS NOT NULL             
    -- Tratamento para não exibir notas de titulos estornados      
    and NOT exists (select 1 from LY_COBRANCA where COBRANCA = a.COBRANCA and estorno = 'S' and FL_FIELD_01 is NOt null)      
      
    UNION  
      
    SELECT DISTINCT              
      ANO AS ANO            
     ,MES AS MES            
     ,NFSE AS NFSE            
     ,CODIGO_VERIFICACAO AS CODIGOVERIFICACAO            
     -- ,CONVERT(VARCHAR,DATA_EMISSAO_NFE,103) AS DATAEMISSAO             
     ,DATA_EMISSAO_NFE AS DATAEMISSAO             
     ,VALOR_SERVICO AS VALORSERVICO            
     ,('<a title="NFSe" href="https://'+ LINK +'" target="blank">https://'+ LINK +'</a>') AS LINK            
    FROM A_VW_CONSULTA_RPS_POR_BOLETO b             
    WHERE ALUNO = @P_ALUNO            
--    AND LINK IS NOT NULL             
    -- Tratamento para não exibir notas de titulos estornados      
    and NOT exists (select 1 from LY_COBRANCA where COBRANCA = b.COBRANCA and estorno = 'S' and FL_FIELD_01 is NOt null)  
      
    ORDER BY ANO, MES DESC