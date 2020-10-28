
DECLARE @DATA_DE	AS DATE
DECLARE @DATA_ATE	AS DATE
DECLARE @MSG		AS VARCHAR (100)
DECLARE @FILENAME	AS VARCHAR (30)

SET @DATA_DE	= CONVERT(date,GETDATE())
SET @DATA_ATE	= DATEADD(WEEK,2,CONVERT(date,GETDATE()))
SET @MSG		= 'Extração semanal do cadastro de turmas para alimentação do Moodle de '+ CONVERT(VARCHAR, @DATA_DE,103)+' ate '+ CONVERT(varchar, @DATA_ATE,103)+'.'
SET @FILENAME	= CONVERT(VARCHAR, @DATA_DE)+'_'+ CONVERT(varchar, @DATA_ATE)+'.csv'

EXEC MSDB.dbo.SP_SEND_DBMAIL 
	@profile_name = VANZOLINI_BD,
	@recipients = 'codely.pedro.henrique@gmail.com;pedro.henrique@codely.com.br;helbert@codely.com.br',
	@blind_copy_recipients = 'gabriel.scalione@vanzolini.com.br',
	@subject = 'Cadastro Turmas - Moodle',
	@body = @MSG,
	@query =
			'
			SELECT 
				CURSO, 
				TURMA, 
				ANO_SEMESTRE,
				DISCIPLINA,  
				NOME_DISCIPLINA, 
				CONVERT(varchar,DATA_INICIO_DISCIPLINA,103) AS DATA_INICIO_DISCIPLINA, 
				DOCENTE, 
				CPF, 
				E_MAIL,  
				SISTEMA
			FROM LYCEUM.dbo.VW_FCAV_DOCENTE_TURMA_DISCIPLINA 
			WHERE 
				DATA_INICIO_DISCIPLINA >= CONVERT(date,GETDATE())
			AND DATA_INICIO_DISCIPLINA <= DATEADD(WEEK,2,CONVERT(date,GETDATE()))',

    @attach_query_result_as_file = 1,
    @query_result_separator ='	',
    @exclude_query_output =1,
    @query_result_no_padding=1,
    @query_result_header =1,
			  
    @query_attachment_filename = @FILENAME
