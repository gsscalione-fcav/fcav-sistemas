--* ***************************************************************  
--*  
--*  *** PROCEDURE a_calcula_valor_servico  ***  
--*   
--* DESCRICAO:  
--*  - Ajustar o valor do plano de pagamento para alunos do curso CEAI  
--*  
--* PARAMETROS:  
--*  
--* USO:  
--*  
--* ALTERA��ES: 
--*    	07/03:	A codifica��o foi removida porque na ver�o 7 do Lyceum n�o ser� mais utilizado a matricula avulsa. 
--*				Era utilizado essa EP porque os valores da d�vida de mensalidade Anual e Bienal eram diferentes 
--*				por conta da matricula avulsa. Gabriel
--*  
--* Autor:   
--* Data de cria��o:   2010-08-19

--* ***************************************************************   
ALTER PROCEDURE a_calcula_valor_servico (@p_servico T_CODIGO,
@p_aluno T_CODIGO,
@p_ano T_ANO,
@p_periodo T_SEMESTRE2,
@p_valor decimal(14, 6) OUTPUT,
@p_cod_lanc T_CODIGO OUTPUT,
@p_descricao T_ALFALARGE OUTPUT)
AS
    -----------------------------------------------------


    -----------------------------------------------------
    RETURN