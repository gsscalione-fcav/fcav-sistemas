ALTER PROCEDURE A_SCRIPT_GOOGLE_ANALYTICS
        @nome_sistema     varchar(500),
	    @pagina           varchar(10),
        @id_oferta        varchar(10),
        @id_compra        varchar(10),
        @aluno			  varchar(500),
        @concurso         varchar(250),
        @canditato        varchar(500),
		@script_analytics varchar(MAX) OUTPUT
AS
BEGIN
-- [INÍCIO] Customização - Não escreva código antes desta linha
	DECLARE @curso VARCHAR(20);
	DECLARE @valor DECIMAL;
	DECLARE @valor_a_vista DECIMAL;

	SET @script_analytics = ''

	IF @nome_sistema = 'Loja'
	BEGIN
		SELECT @curso = OC.CURSO, @valor_a_vista = OC.VALOR_A_VISTA_ESTIMADO, @valor = ISNULL(CO.VALOR,0)
		  FROM LY_COMPRA_OFERTA CO
		 INNER JOIN LY_OFERTA_CURSO OC ON CO.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO
		 WHERE ID_COMPRA_OFERTA = @id_compra

		SET @script_analytics = '<script>gtag(''event'',''compra'', {​​​​​​​​''event_category'':''atualizacao'',''event_label'':''' + @curso +''',''value'':''' + CONVERT(VARCHAR,CONVERT(DECIMAL(8,2), @valor)) + ''', ''non_interaction'': true}​​​​​​​​);</script>'
	END

	IF @nome_sistema = 'ProcessoSeletivo'
	BEGIN
		SELECT @curso = OC.CURSO, @valor_a_vista = OC.VALOR_A_VISTA_ESTIMADO, @valor = ISNULL(C.BOLETO_VALOR,0)
		  FROM LY_CANDIDATO C
		 INNER JOIN LY_OPCOES_PROC_SELETIVO V ON C.CONCURSO = V.CONCURSO
											 AND C.CANDIDATO = V.CANDIDATO
											 AND V.ORDEM = 1
		  INNER JOIN LY_OFERTA_CURSO OC ON V.OFERTA_DE_CURSO = OC.OFERTA_DE_CURSO 
		 WHERE C.CONCURSO = @concurso
		   AND C.CANDIDATO = @canditato

		SET @script_analytics = '<script>gtag(''event'',''inscricao'', {​​​​​​​​''event_category'':''especializacao'',''event_label'':''' + @curso +''',''value'':''' + CONVERT(VARCHAR,CONVERT(DECIMAL(8,2), @valor)) + ''', ''non_interaction'': true}​​​​​​​​);</script>'
	END
-- [FIM] Customização - Não escreva código após esta linha')
END