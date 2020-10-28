ALTER PROCEDURE  a_TAGS_CUSTOM_SERVICO  
   @p_aluno T_CODIGO,   
   @p_servico T_CODIGO   
   AS
   
  ---------------------------------------------------------------        
	--[INÍCIO CUSTOMIZAÇÃO]        
	---------------------------------------------------------------   
	--VARIÁVEIS   
	DECLARE @v_nome_coord VARCHAR (200)   
	DECLARE @v_carga_horaria_total VARCHAR (200)  
	DECLARE @v_periodo_conclusao VARCHAR (200)
	DECLARE @v_curso T_CODIGO
    
    ------------------------------------------------------------   
	--Inicio da junção das TAGS  
  
  ------------------------------------------------------------
	--Retorna o curso do aluno
	SET @v_curso = 
	(
		SELECT CURSO FROM LY_ALUNO where ALUNO = @p_aluno
	)
  
	------------------------------------------------------------
	--Retorna o nome do Coordenador do curso
	SET @v_nome_coord = 
	(
		SELECT 
			ISNULL(DO.NOME_COMPL, 'NÃO CADASTRADO')
		FROM
			LY_COORDENACAO CO
			LEFT JOIN LY_DOCENTE DO
				ON DO.NUM_FUNC = CO.NUM_FUNC
		WHERE
			CO.CURSO = @v_curso
			AND TIPO_COORD = 'COORD'
	)  

    ------------------------------------------------------------  
	--Retorna a carga horária total do curso  
	SET @v_carga_horaria_total =   
	(  
		SELECT  
			ISNULL(CAST(CAST(CR.AULAS_PREVISTAS AS INT) AS VARCHAR),'0') +  
			' (' +  
			LTRIM(dbo.Numero_Extenso(CR.AULAS_PREVISTAS)) +  
			') '  
		FROM LY_CURRICULO CR  
			INNER JOIN LY_ALUNO AL  
			ON (AL.CURSO = CR.CURSO  
			AND AL.TURNO = CR.TURNO  
			AND AL.CURRICULO = CR.CURRICULO)  
		WHERE AL.ALUNO = @p_aluno
			
	) 
	
	
	------------------------------------------------------------  
	--Retorna o período de conclusão  
	SET @v_periodo_conclusao =   
	(  
		SELECT  TOP 1
			DBO.FN_FCAV_MES_EXT (MONTH(MIN(CT.DT_INICIO))) +  
			'/' + CAST(YEAR(MIN(CT.DT_INICIO)) AS VARCHAR) +
			' a ' +
			DBO.FN_FCAV_MES_EXT (MONTH(MAX(CT.DT_FIM))) +  
			'/' + CAST(YEAR(MAX(CT.DT_FIM)) AS VARCHAR)
		FROM VW_FCAV_RESUMO_MATRICULA_E_PRE_MATRICULA MP 
			 INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA CT
				ON  CT.TURMA = MP.TURMA
		WHERE MP.ALUNO = @p_aluno
			AND CT.CURSO = @v_curso
		GROUP BY
			CT.DT_INICIO, CT.DT_FIM
	) 

	
	
	SELECT   
		 @v_nome_coord				AS NOME_COORD  
		,@v_carga_horaria_total		AS CARGA_HORARIA  
		,@v_periodo_conclusao		AS PERIODO_CONCLUSAO
		 
   
    RETURN