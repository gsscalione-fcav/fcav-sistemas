/*

SC_FCAV_GERACAO_BOLETOS_FATURAMENTO

Finalidade: Utilizada para geração de boletos e faturamentos por script ao inves de utilizar o 
			Lyceum para execução do processo.

Autor: Gabriel S. Scalione
Data: 19/09/2019
*/

--select * from LY_AGREGA_ITEM_COBRANCA 
--SELECT * FROM LY_ITEM_LANC where cobranca = 206671 --ALUNO = 'E201830089'



USE LYCEUM

GO

declare @DtVencIni datetime
declare @DtVencFim datetime
declare @date datetime = getdate()+10; 

set @DtVencIni = cast((GETDATE()- 90) as date)
set @DtVencFim = EOMONTH ( @date )


SELECT 
	CO.DATA_DE_VENCIMENTO,
	IL.COBRANCA,
	IL.ITEMCOBRANCA,
	IL.ALUNO,
	IL.BOLETO,
	IL.PARCELA,
	IL.DATA,
	IL.VALOR,
	IL.DESCRICAO,
	LD.GRUPO
FROM 
	LY_ITEM_LANC IL
	INNER JOIN LY_COBRANCA CO
		ON CO.COBRANCA = IL.COBRANCA
	LEFT JOIN LY_LANC_DEBITO LD
		ON LD.LANC_DEB = IL.LANC_DEB
WHERE CO.DATA_DE_VENCIMENTO BETWEEN @DtVencIni AND @DtVencFim
 --AND IL.COBRANCA = 206671
 AND il.DESCRICAO != 'VALOR ACORDADO'
 AND IL.COBRANCA IN (SELECT COBRANCA FROM LY_ITEM_LANC WHERE COBRANCA = IL.COBRANCA AND BOLETO IS NULL)
 AND CO.DATA_DE_VENCIMENTO >= '2019-01-01 23:59:59.000'
 AND IL.DT_ENVIO_CONTAB IS NULL





--- GERACAO DE BOLETOS DE ATUALIZACAO	   
EXEC PROC_GERA_BOLETO      
  'ATUAL',				--@p_Unidade 
  33,					--@p_Banco ,          
  '0658-0',				--@p_Agencia ,          
  '130070967',			--@p_Conta ,          
  '2112140',			--@p_Convenio,          
  101,					--@p_Carteira,          
  @DtVencIni,			--@p_DtVencIni,          
  @DtVencFim,			--@p_DtVencFim,          
  'N',					--@p_ApenasFaturar,          
  NULL,					--@p_RespFinan ,          
  NULL,					--@p_AlunoIni,
  NULL,					--@p_AlunoFim  
  null,					--@p_Curso  
  null,					--@p_TipoCurso  
  null,					--@p_Curriculo  
  null,					--@p_Conj_Aluno  
  'S',					--@p_Boleto_Zerado  
  'N',					--@p_Boleto_Negativo 
  'N',					--@p_cobranca_com_nota 
  null,					--@p_Unidade_Fisica 
  NULL,					--@p_Apartir_Valor 
  NULL,					--@p_tipo_cobranca 
  'Grupo 002',			--@p_grupo_divida 
  null,					--@p_depto 
  'S'					--@p_online 


--- GERACAO DE BOLETOS DE CAPACITACAO
EXEC PROC_GERA_BOLETO      
  'CAPAC',				--@p_Unidade 
  33,					--@p_Banco ,          
  '0658-0',				--@p_Agencia ,          
  '130070967',			--@p_Conta ,          
  '2112140',			--@p_Convenio,          
  101,					--@p_Carteira,          
  @DtVencIni,			--@p_DtVencIni,          
  @DtVencFim,			--@p_DtVencFim,          
  'N',					--@p_ApenasFaturar,          
  NULL,					--@p_RespFinan ,          
  NULL,					--@p_AlunoIni,
  NULL,					--@p_AlunoFim  
  null,					--@p_Curso  
  null,					--@p_TipoCurso  
  null,					--@p_Curriculo  
  null,					--@p_Conj_Aluno  
  'S',					--@p_Boleto_Zerado  
  'N',					--@p_Boleto_Negativo 
  'N',					--@p_cobranca_com_nota 
  null,					--@p_Unidade_Fisica 
  NULL,					--@p_Apartir_Valor 
  NULL,					--@p_tipo_cobranca 
  'Grupo 002',			--@p_grupo_divida 
  null,					--@p_depto 
  'S'					--@p_online 

--- GERACAO DE BOLETOS DE DIFUSAO
EXEC PROC_GERA_BOLETO      
  'DIFUS',				--@p_Unidade 
  33,					--@p_Banco ,          
  '0658-0',				--@p_Agencia ,          
  '130070967',			--@p_Conta ,          
  '2112140',			--@p_Convenio,          
  101,					--@p_Carteira,          
  @DtVencIni,			--@p_DtVencIni,          
  @DtVencFim,			--@p_DtVencFim,          
  'N',					--@p_ApenasFaturar,          
  NULL,					--@p_RespFinan ,          
  NULL,					--@p_AlunoIni,
  NULL,					--@p_AlunoFim  
  null,					--@p_Curso  
  null,					--@p_TipoCurso  
  null,					--@p_Curriculo  
  null,					--@p_Conj_Aluno  
  'S',					--@p_Boleto_Zerado  
  'N',					--@p_Boleto_Negativo 
  'N',					--@p_cobranca_com_nota 
  null,					--@p_Unidade_Fisica 
  NULL,					--@p_Apartir_Valor 
  NULL,					--@p_tipo_cobranca 
  'Grupo 002',			--@p_grupo_divida 
  null,					--@p_depto 
  'S'					--@p_online 

--- GERACAO DE BOLETOS DE ESPECIALIZACAO
EXEC PROC_GERA_BOLETO      
  'ESPEC',				--@p_Unidade 
  33,					--@p_Banco ,          
  '0658-0',				--@p_Agencia ,          
  '130070943',			--@p_Conta ,          
  '2112116',			--@p_Convenio,          
  101,					--@p_Carteira,          
  @DtVencIni,			--@p_DtVencIni,          
  @DtVencFim,			--@p_DtVencFim,          
  'N',					--@p_ApenasFaturar,          
  NULL,					--@p_RespFinan ,          
  NULL,					--@p_AlunoIni,
  NULL,					--@p_AlunoFim  
  null,					--@p_Curso  
  null,					--@p_TipoCurso  
  null,					--@p_Curriculo  
  null,					--@p_Conj_Aluno  
  'S',					--@p_Boleto_Zerado  
  'N',					--@p_Boleto_Negativo 
  'N',					--@p_cobranca_com_nota 
  null,					--@p_Unidade_Fisica 
  NULL,					--@p_Apartir_Valor 
  NULL,					--@p_tipo_cobranca 
  'Grupo 001',			--@p_grupo_divida 
  null,					--@p_depto 
  'S'					--@p_online 

