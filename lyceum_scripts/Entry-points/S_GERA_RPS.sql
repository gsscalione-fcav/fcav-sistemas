/*
	Finalidade: Essa EP substitui a codificação padrão do Lyceum para gerar a RPS 
				setando a varíavel @p_substitui para 'S'


	select * from ly_boleto where NUMERO_RPS is NULL



*/

ALTER PROCEDURE S_GERA_RPS    
(    
 @p_boleto          T_NUMERO,              
 @p_dt_emissao      T_DATA,            
 @p_faculdade       T_CODIGO,             
 @p_Qualtipo        VARCHAR(1), -- Só pode ser E (Empresa) ou U (Unidade)      
 @p_Serie           VARCHAR(5),      
 @p_TipoValor       VARCHAR(50),    
 @p_Cob				T_SIMNAO,    
 @p_Aliquota		NUMERIC(5, 2),    
 @p_Codigo_Servico	T_NUMERO,    
 @p_substitui       varchar(1) OUTPUT    
)    
AS    
-- [INÍCIO] Customização - Não escreva código antes desta linha      
BEGIN 
	SET @p_substitui = 'N'    	
 RETURN    
END    
-- [FIM] Customização - Não escreva código após esta linha