
/*
	JOB PARA VERIFICAR ALUNOS QUE POSSUEM BOLSA OU VOUCHER 100% E QUE NÃO POSSUEM BOLETOS GERADOS.

	APÓS A GERAÇÃO DOS BOLETOS, SERÁ GERADO AS RPS PARA ESSES CASOS.

	Autor: Gabriel S. Scalione
	Data: 13/02/2020

	Período de execução: Todos os dias - 07:30 e 12:00

*/

declare @DtVencIni datetime
declare @DtVencFim datetime
declare @date datetime = getdate()+10; 
declare @unidade VARCHAR(20)
declare @aluno varchar(20)
declare @cobranca numeric
declare @data_emissao datetime,
		@num_boleto numeric

set @data_emissao = CONVERT(DATE, getdate(),102)
set @DtVencIni = cast((GETDATE()- 30) as date)
set @DtVencFim = cast((GETDATE()+ 90) as date)--EOMONTH ( @date )

-- Cursor para percorrer os nomes dos objetos
DECLARE gerar_boleto CURSOR FOR

	WITH BOLSISTAS_100 AS (
		SELECT DISTINCT
				CO.ALUNO,
				CO.COBRANCA, 
				AL.UNIDADE_ENSINO
		FROM LY_BOLSA BO
			INNER JOIN LY_COBRANCA CO
				ON BO.ALUNO = CO.ALUNO
				AND CO.ESTORNO = 'N'
			INNER JOIN LY_ALUNO AL
				ON AL.ALUNO = BO.ALUNO 
				AND AL.ANO_INGRESSO >= 2020
				AND al.SIT_ALUNO = 'Ativo'
			INNER JOIN LY_ITEM_LANC IL
				ON IL.ALUNO = AL.ALUNO
				AND IL.COBRANCA = CO.COBRANCA
				AND IL.BOLETO IS NULL
			WHERE BO.VALOR = 1
	),

	VOUCHERS_100 AS (
		SELECT DISTINCT
			CO.ALUNO,
			CO.COBRANCA, 
			AL.UNIDADE_ENSINO
		FROM LY_COMPRA_OFERTA CO
			INNER JOIN LY_LOTE_VOUCHER LV
				ON LV.ID_LOTE_VOUCHER = CO.ID_LOTE_VOUCHER
			INNER JOIN LY_ALUNO AL
				ON AL.ALUNO = CO.ALUNO 
				AND AL.ANO_INGRESSO >= 2020
				AND AL.SIT_ALUNO = 'Ativo'
			INNER JOIN LY_ITEM_LANC IL
				ON IL.ALUNO = AL.ALUNO
				AND IL.COBRANCA = CO.COBRANCA
				AND IL.BOLETO IS NULL
		WHERE LV.DESCONTO = 100
	
	),

	RELACAO_ALUNOS AS (
			SELECT 
				ALUNO, 
				COBRANCA, 
				UNIDADE_ENSINO 
			FROM  
				BOLSISTAS_100 BO 
			GROUP BY ALUNO, COBRANCA,UNIDADE_ENSINO
			UNION ALL
			SELECT 
				ALUNO, 
				COBRANCA,
				UNIDADE_ENSINO 
			FROM  VOUCHERS_100 VO
			--GROUP BY ALUNO, COBRANCA,UNIDADE_ENSINO
			)


	SELECT 
		RA.ALUNO, 
		RA.COBRANCA, 
		RA.UNIDADE_ENSINO
	FROM 
		RELACAO_ALUNOS RA


	-- Abrindo Cursor para leitura
	OPEN gerar_boleto

	-- Lendo a próxima linha
	FETCH NEXT FROM gerar_boleto INTO @aluno, @cobranca, @unidade


	-- Percorrendo linhas do cursor (enquanto houverem)
	WHILE @@FETCH_STATUS = 0
	BEGIN

		if(@unidade = 'ESPEC') BEGIN

			--- GERACAO DE BOLETOS DE ESPECIALIZACAO
			EXEC PROC_GERA_BOLETO      
			  @unidade,				--@p_Unidade 
			  33,					--@p_Banco ,          
			  '0658-0',				--@p_Agencia ,          
			  '130070943',			--@p_Conta ,          
			  '2112116',			--@p_Convenio,          
			  101,					--@p_Carteira,          
			  @DtVencIni,			--@p_DtVencIni,          
			  @DtVencFim,			--@p_DtVencFim,          
			  'N',					--@p_ApenasFaturar,          
			  NULL,					--@p_RespFinan ,          
			  @aluno,				--@p_AlunoIni,
			  @aluno,				--@p_AlunoFim  
			  NULL,					--@p_Curso  
			  NULL,					--@p_TipoCurso  
			  NULL,					--@p_Curriculo  
			  NULL,					--@p_Conj_Aluno  
			  'S',					--@p_Boleto_Zerado  
			  'N',					--@p_Boleto_Negativo 
			  'N',					--@p_cobranca_com_nota 
			  NULL,					--@p_Unidade_Fisica 
			  NULL,					--@p_Apartir_Valor 
			  NULL,					--@p_tipo_cobranca 
			  'Grupo 001',			--@p_grupo_divida 
			  null,					--@p_depto 
			  'S'					--@p_online 

		END
		ELSE BEGIN
			--- GERACAO DE BOLETOS PARA OS CURSOS DE CAPAC, ATUAL E DIFUS
			EXEC PROC_GERA_BOLETO      
				  @unidade,				--@p_Unidade 
				  33,					--@p_Banco ,          
				  '0658-0',				--@p_Agencia ,          
				  '130070967',			--@p_Conta ,          
				  '2112140',			--@p_Convenio,          
				  101,					--@p_Carteira,          
				  @DtVencIni,			--@p_DtVencIni,          
				  @DtVencFim,			--@p_DtVencFim,          
				  'N',					--@p_ApenasFaturar,          
				  NULL,					--@p_RespFinan ,          
				  @aluno,				--@p_AlunoIni,
				  @aluno,				--@p_AlunoFim  
				  NULL,					--@p_Curso  
				  NULL,					--@p_TipoCurso  
				  NULL,					--@p_Curriculo  
				  NULL,					--@p_Conj_Aluno  
				  'S',					--@p_Boleto_Zerado  
				  'N',					--@p_Boleto_Negativo 
				  'N',					--@p_cobranca_com_nota 
				  NULL,					--@p_Unidade_Fisica 
				  NULL,					--@p_Apartir_Valor 
				  NULL,					--@p_tipo_cobranca 
				  'Grupo 002',			--@p_grupo_divida 
				  NULL,					--@p_depto 
				  'S'					--@p_online
			
		END


		
		SELECT @num_boleto = BOLETO FROM VW_COBRANCA_BOLETO WHERE COBRANCA = @cobranca AND ALUNO = @aluno
	
		EXEC GERA_RPS @num_boleto,   
					  @data_emissao,   
					  'FCAV' ,   
					  'E',			
					  'C'    ,   
					  'Tipo Valor' ,   
					  'N' ,   
					  0.00,   
					  5762


		-- Lendo a próxima linha
		FETCH NEXT FROM gerar_boleto INTO @aluno, @cobranca, @unidade
	END

-- Fechando Cursor para leitura
CLOSE gerar_boleto

-- Desalocando o cursor
DEALLOCATE gerar_boleto