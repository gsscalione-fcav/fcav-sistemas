ALTER PROCEDURE a_APoI_Ly_pre_matricula    
  @erro VARCHAR(1024) OUTPUT,    
  @aluno VARCHAR(20), @disciplina VARCHAR(20), @ano NUMERIC(4), @semestre NUMERIC(2),     
  @turma VARCHAR(20), @subturma1 VARCHAR(20), @subturma2 VARCHAR(20), @serie_ideal NUMERIC(3),     
  @mens_erro VARCHAR(2000), @lanc_deb NUMERIC(10), @confirmada VARCHAR(1), @dispensada VARCHAR(1),     
  @manual VARCHAR(1), @dt_ultalt DATETIME, @cobranca_sep VARCHAR(1), @serie_calculo NUMERIC(3),     
  @dt_insercao DATETIME, @dt_confirmacao DATETIME, @sit_detalhe VARCHAR(50), @grupo_eletiva VARCHAR(20),     
  @num_chamada NUMERIC(10), @confirmacao_lider VARCHAR(1),   
  @Opcao NUMERIC(3), @DISCIPLINA_SUBST VARCHAR(20), @TURMA_SUBST VARCHAR(20), @ALOCADO VARCHAR(1),  
  @cumpriu_grupo VARCHAR(1)    
AS    
	  -- [INÍCIO] Customização - Não escreva código antes desta linha   
	    
	DECLARE 
		@v_TURMA T_CODIGO,  
		@v_CURSO T_CODIGO,  
		@V_UNID_RESP T_CODIGO,
		@max_alunos NUMERIC, 
		@alu_inscritos NUMERIC


	-- BUSCA CURSO  
	SELECT  
		@v_CURSO = CURSO  
	FROM 
		LY_ALUNO  
	WHERE 
		ALUNO = @aluno  

	--BUSCA A UNIDADE RESPONSÁVEL  
	SELECT 
		@V_UNID_RESP = FACULDADE 
	FROM 
		LY_CURSO 
    WHERE 
		CURSO = @v_CURSO
	

	--BUSCA O NÚMERO MÁXIMO DE ALUNOS DA TURMA PARA AS PALESTRAS                
	SELECT            
		@max_alunos = MAX(C.VAGAS)      
	FROM 
		LY_TURMA T      
	INNER JOIN LY_CURSO C ON C.CURSO = T.CURSO               
	WHERE                
	  T.UNIDADE_RESPONSAVEL = 'PALES'
	AND T.TURMA = @turma
	            
	--CONTA O NÚMERO DE ALUNOS PRE_MATRICULADOS EM PALESTRAS                
	SELECT             
		@alu_inscritos = ISNULL(COUNT(P.ALUNO),0)
	FROM                
		LY_PRE_MATRICULA P      
	INNER JOIN LY_TURMA T ON P.TURMA = T.TURMA                
	WHERE                
	  T.UNIDADE_RESPONSAVEL = 'PALES' 
	AND P.TURMA = @turma

	-- SE CURSO FOR CEAI, BUSCA PELA TURMA REFERENTE AO ANO E PERIODO E ASSOCIA A PRÉ-MATRICULA DO ALUNO  
	IF (@v_CURSO = 'CEAI' OR @V_UNID_RESP = 'PALES')
	BEGIN  
	-- BUSCA PRIMEIRA TURMA CRIADA PARA AS DISCIPLINAS CADASTRADAS NA PRÉ-MATRICULA  
		SELECT 
			@v_TURMA = TURMA  
		FROM 
			LY_TURMA T  
		WHERE 
			ANO =		 @ano 
		AND SEMESTRE =	 @semestre 
		AND DISCIPLINA = @disciplina 
		AND T.SIT_TURMA = 'Aberta'    
	 
		UPDATE LY_PRE_MATRICULA 
		SET 
			TURMA = @v_TURMA 
		WHERE 
			ALUNO =		 @aluno 
		AND DISCIPLINA = @disciplina 
		AND ANO =		 @ano 
		AND SEMESTRE =   @semestre  
	END    

	--SE O NÚMERO DE INSCRITOS FOR MAIOR QUE O NUMERO DE VAGAS, NÃO ALOCA O ALUNO.
	IF (
			@alu_inscritos > @max_alunos 
		AND @V_UNID_RESP = 'PALES'
	   )
	   BEGIN  
		UPDATE LY_PRE_MATRICULA 
		SET 
			ALOCADO = 'N' 
		WHERE 
			ALUNO = @aluno 
	   END  

RETURN    
  -- [FIM] Customização - Não escreva código após esta linha 