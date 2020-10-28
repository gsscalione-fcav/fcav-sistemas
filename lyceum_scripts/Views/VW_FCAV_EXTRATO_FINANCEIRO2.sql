  
 /*  
 ESTA VIEW ACRESCENTA A DATA DE FATURAMENTO, FOI CRIADO PARA NCO GERAR POSSIVEL PROBLEMA NA OUTRA VIEW QUE I UTILIZADA PARA RELATSRIO DO ROGIRIO  
  
 Atualizacao: 
       22/11/2016 - O subselect do campo DATA_DE_PAGAMENTO estava trazendo mais de um resultado, foi alterado para trazer somente o top 1. Gabriel SS.  
       12/12/2016 - Alterado o corpo para utilizar as CTEs  
       
       17/01/2017 - View foi customizada. Toda a tratativa foi para store procedure SP_FCAV_EXTRATO_FINANCEIRO2 
					que é executada por uma JOB que alimenta a tabela FCAV_EXTRATO_FINANCEIRO2.

	SELECT * FROM FCAV_EXTRATO_FINANCEIRO2 WHERE CENTRO_DE_CUSTO IS NULL AND ANO_REF = 2018
       
 */  
  
ALTER VIEW VW_FCAV_EXTRATO_FINANCEIRO2 AS  
SELECT *  
FROM FCAV_EXTRATO_FINANCEIRO2  