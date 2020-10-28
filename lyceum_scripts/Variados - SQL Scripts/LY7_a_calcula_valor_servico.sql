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
--* ALTERAÇÕES: 
--*    	07/03:	A codificação foi removida porque na verão 7 do Lyceum não será mais utilizado a matricula avulsa. 
--*				Era utilizado essa EP porque os valores da dívida de mensalidade Anual e Bienal eram diferentes 
--*				por conta da matricula avulsa. Gabriel
--*  
--* Autor:   
--* Data de criação:   2010-08-19

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