--* ***************************************************************  
--*  
--*         *** Procedure a_Matric_AbreContrato  ***  
--*    
--*   DESCRICAO:  
--*  - Está procedure foi criada pela Techne e por isso o nome dela   
--*  não possui o padrão fcav como está no nome.  
--*    
--*  - Procedure para criação de TAG's para serem incluídas no contrato   
--*  do Aluno após o ACEITE na finalização da matrícula(modo online).   
--*  
--*   PARAMETROS:  
--*     São utilizados conforme as tags são criadas para filtrar   
--*     o aluno referente ao curso e oferta de curso.  
--*  
--*   TAG's existentes:  
--*  '%%NOME_CURSO%%'      
--*  
--*   TAG's criadas:  
--*  
--*  '%%DURACAO_PREV%%'				- Retorna a duração do curso e o tipo: exemplo 2 dias ou 6 meses.  
--*  '%%MINIMO_INSCRITOS%%'			- Retorna a quantidade mínima de inscritos para o curso especificado.  
--*  '%%VALOR_TOTAL%%'				- Retorna o valor total do curso, para cursos com matrícula é a somatória da matrícula e a mensalidade.  
--*  '%%VALOR_MATR%%'				- Retorna o valor da matricula dependendo do curso especificado.  
--*  '%%VALOR_MENS%%'				- Retorna o valor da mensalidade dependendo do curso especificado.  
--*  '%%DT_VENC_MATR%%'				- Retorna a data do vencimento da matricula com base na tabela LY_PLANOS_OFERTADOS, usa-se a função FN_FCAV_GetDiaUtil.  
--*  '%%N_DIAS_VENC_BOL%%'			- Retorno o número dias de vencimento do boleto conforme LY_PLANOS_OFERTADOS.  
--*  '%%NUM_PARCELAS%%'				- Retorna quantidade de parcelas com base na tabela LY_PLANOS_OFERTADOS.  
--*  '%%PLANO_ESCOLHIDO%%'			- Retorna o plano que o aluno escolheu.  
--*  '%%NUM_DISCIPLINAS%%'			- Retorna o número de disciplinas do curso.  
--*  '%%CARGA_HORARIA_TOTAL%%'		- Retorna a carga horária total do curso.  
--*  '%%TURMA%%'					- Retorna a turma em que a oferta está vinculada. 
--*  '%%VERIFICA_MATR%%'			- Verifica se o curso possui valor de matrícula caso exista, será mostrado o valor e a data de vencimento da Matricula referente à aquele curso.  
--*  '%%POSSUI_BOLSA%%'				- Verifica se o aluno possui bolsa cadastrada no Flex Field LY_FL_PESSOA.
--*	  
--*   USO:  
--*  - É utilizado para incluir informações de Aluno, Valor, Data e Curso   
--*  no contrato que será visualizado pelo aluno no final do processo de Pré-matricula,   
--*  após do Aceite.   
--*  
--*   ALTERAÇÕES:  
--*		12/12/2013 - Colocando textos curtos para as TAGs. Por Gabriel S Scalione
--*		15/02/2014 - Acrescentado as TAGs que verifica se o curso possui TCC e se o curso possui taxa de matricula.  Por Gabriel S Scalione
--*		02/04/2014 - Verifica quando o curso for o CEAI para retornar o tipo de plano escolhido, Bienal ou Anual.  Por Gabriel S Scalione
--*		10/07/2014 - Verifica quando o curso for o CCOL para retornar o tipo de plano escolhido, valores de matricula e mensalidade.  Por Gabriel S Scalione
--*		06/10/2014 - Alteração das referente a CARGA HORARIA do curso, que agora traz somente a carga horária do curso, com base no cadastro do curriculo. Por Gabriel S Scalione
--*		09/01/2015 - Alteração da verificação da data de vencimento do boleto de matricula para PJ, se for PJ o sistema colocado número de dias com base no cadastro da tabela geral no HADES, item DiasVencPessJuridica. Por Gabriel S Scalione
--*		10/11/2015 - Acrescentado a TAG para trazer a data de vencimento da primeira mensalidade. Por Gabriel S Scalione


--*   Autor: Gabriel Scalione  
--*		Data de criação:  11/11/2013 
--*  
--* **************************************************************
  
--sysobjects  
  
ALTER PROCEDURE a_Matric_AbreContrato  --sempre que criar uma tag nova, executar novamente a alteração da procedure.  
(        
 @p_aluno AS T_CODIGO,        
 @p_ano AS T_ANO,        
 @p_periodo AS T_SEMESTRE2,        
 @p_ofertaCurso AS T_NUMERO,    
 @p_tabela_plano_pgto AS VARCHAR(50)  
  
  /*    
  O parâmetro @p_tabela_plano_pgto conterá o nome da tabela utilizada no plano de pagamento.    
  Valores possíveis:    
   - LY_PLANO_PGTO_PERIODO    
   - LY_PLANO_PGTO_ESPECIAL    
   - LY_PLANO_PGTO_INSCRONLINE    
  */    
)        
        
AS        
BEGIN      
      
 CREATE TABLE #TAGS_RETORNO      
 (      
   TAG VARCHAR(200),      
   VALOR VARCHAR(200)      
 )      
       
 /*      
       
 INSERIR O CÓDIGO QUE IRÁ PREENCHER A TABELA DE RETORNO      
 NO BLOCO ABAIXO      
       
 EXEMPLO:      
       
 INSERT INTO #TAGS_RETORNO (tag, valor)      
 SELECT ''%%ANO_CONCLUSAO_2G%%'' AS tag,      
     anoconcl_2g AS valor      
 FROM ly_aluno      
 WHERE aluno = @p_aluno      
       
 */      
       
 ---------------------------------------------------------------      
 --[INÍCIO CUSTOMIZAÇÃO]      
 --------------------------------------------------------------- 
 
 -- TAG para trazer os dados pessoais da atual presidente da Vanzolini. A informação sobre o atual presidente, fica na titulação do Docente.
 
 -- Nome padrão na Titulação para identificar o atual presidente da Vanzolini 
 -- como "Presidente da Diretoria Executiva" (sem aspas).
 
 --	Ao termino do mandato, é preciso apagar a informação da Titulação e colocar o mesmo titulo para o novo presidente.
 
 
 DECLARE @presidencia VARCHAR(100)
 
  SELECT DISTINCT TOP 1
	@presidencia = TITULACAO
  FROM 
	LY_DOCENTE
  WHERE
	TITULACAO like 'Presidente%Diretoria%'

 
  INSERT INTO #TAGS_RETORNO (tag, valor)  
  SELECT DISTINCT
	'%%NOME_PRESIDENTE%%',
	NOME_COMPL AS NOME_PRESIDENTE
  FROM 
	LY_DOCENTE
  WHERE
	TITULACAO = @presidencia
 
  INSERT INTO #TAGS_RETORNO (tag, valor)  
  SELECT DISTINCT
	'%%EST_CIVIL_PRESIDENTE%%',
	LOWER(EST_CIVIL) AS EST_CIVIL_PRESIDENTE
  FROM 
	LY_DOCENTE
  WHERE
	TITULACAO = @presidencia
 
  INSERT INTO #TAGS_RETORNO (tag, valor)  
  SELECT DISTINCT
	'%%CPF_PRESIDENTE%%',
	dbo.FN_FCAV_formatarCNPJCPF(CPF) AS CPF_PRESIDENTE
  FROM 
	LY_DOCENTE
  WHERE
	TITULACAO = @presidencia

  INSERT INTO #TAGS_RETORNO (tag, valor)  
  SELECT DISTINCT
	'%%RG_PRESIDENTE%%',
	RG_NUM +' - '+ RG_EMISSOR +'/'+ RG_UF AS RG_PRESIDENTE
  FROM 
	LY_DOCENTE
  WHERE
	TITULACAO like 'Presidente%Diretoria%'
 
 
 ---------------------------------------------------------------
 
 declare @curso VARCHAR(20)
 
 --Carrega a variável curso, que será utilizada mais abaixo para identificar se o curso é CCOL
 SELECT
	@curso = CURSO
FROM
	LY_ALUNO
WHERE
	ALUNO = @p_aluno
 
 
	 --------------------------------------------------------------- 
	  --TAG para retornar a duração do curso   
	INSERT INTO #TAGS_RETORNO (tag, valor)  
	select   
	 '%%DURACAO_PREV%%',  
	 ISNULL((CAST(PRAZO_CONC_PREV AS VARCHAR) + ' (' + ltrim(dbo.Numero_Extenso(PRAZO_CONC_PREV)) + ')' + ' ' + TIPO_PRAZO_CONCL),'') AS DURACAO_PREV  
	from   
	 LY_ALUNO AL  
	 INNER JOIN LY_CURRICULO CR ON (AL.CURSO = CR.CURSO AND AL.TURNO = CR.TURNO AND AL.CURRICULO = CR.CURRICULO)  
	WHERE  
	 ALUNO = @p_aluno  
	    
	 ---------------------------------------------------------------      
	  --TAG para retornar a nome da disciplina  
	INSERT INTO #TAGS_RETORNO (tag, valor)  
	SELECT  DISTINCT 
		'%%NOME_DISCIPLINA%%',  
		CASE WHEN D.FACULDADE = 'ATUAL' THEN D.NOME
			ELSE ''
		END   AS NOME_DISCIPLINA
	FROM   
	 LY_ALUNO AL  
	 INNER JOIN LY_GRADE CR ON (AL.CURSO = CR.CURSO AND AL.TURNO = CR.TURNO AND AL.CURRICULO = CR.CURRICULO)  
	 INNER JOIN LY_DISCIPLINA D ON (D.DISCIPLINA = CR.DISCIPLINA)  
	WHERE  
	 ALUNO = @p_aluno  

	----------------------------------------------------  
	-- TAG para trazer o numero de disciplinas  
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT  
	  '%%NUM_DISCIPLINAS%%',  
	  CAST(COUNT(GRA.DISCIPLINA) AS VARCHAR) + ' (' + LTRIM(dbo.Numero_Extenso(COUNT(GRA.DISCIPLINA))) + ')' AS NUM_DISCIPLINAS  
	 FROM  
	  LY_GRADE GRA  
	  INNER JOIN LY_CURRICULO CUR ON (CUR.CURSO = GRA.CURSO AND CUR.TURNO = GRA.TURNO AND CUR.CURRICULO = GRA.CURRICULO)  
	  INNER JOIN LY_OFERTA_CURSO OFC ON (CUR.CURSO = OFC.CURSO AND CUR.TURNO = OFC.TURNO AND CUR.CURRICULO = OFC.CURRICULO)  
	 WHERE  
	  OFC.OFERTA_DE_CURSO = @p_ofertaCurso  
	  --AND GRA.DISCIPLINA NOT LIKE '%TCC%'  
	    
	----------------------------------------------------  
	-- TAG para trazer O PRAZO MÁXIMO PARA CONCLUSÃO DO CURSO.
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT   
	  '%%PRAZO_MAXIMO%%',  
	  CAST(PRAZO_MAX AS VARCHAR)   
	  + ' (' + dbo.Numero_Extenso(PRAZO_MAX)+ ') ' 
	  + CR.TIPO_PRAZO_CONCL AS PRAZO_MAXIMO
	 FROM  
		VW_FCAV_INI_FIM_CURSO_TURMA VC
		INNER JOIN LY_CURRICULO CR ON CR.CURRICULO = VC.CURRICULO
	 WHERE  
	  VC.OFERTA_DE_CURSO = @p_ofertaCurso  
	  
	----------------------------------------------------  
	-- TAG para trazer CARGA HORÁRIA TOTAL DO CURSO 
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT   
	  '%%CARGA_HORARIA_TOTAL%%',  
	  CAST(CAST(CUR.AULAS_PREVISTAS AS INT) AS VARCHAR) + ' '   
	  + '(' + LTRIM(dbo.Numero_Extenso(CUR.AULAS_PREVISTAS))+ ')' AS CARGA_HORARIA_TOTAL  
	 FROM  
	  LY_CURRICULO CUR  
	  INNER JOIN LY_OFERTA_CURSO OFC ON (CUR.CURSO = OFC.CURSO AND CUR.TURNO = OFC.TURNO AND CUR.CURRICULO = OFC.CURRICULO)   
	 WHERE  
	  OFERTA_DE_CURSO = @p_ofertaCurso  
	  


----------------------------------------------------------
-- BLOCO PARA VERIFICAR A PARTE FINANCEIRA DO CURSO 	  

IF(@curso NOT LIKE 'CCOL')  --Esse curso CCOL possui mais de 2 planos de pagamentos, por conta disso foi feito uma condição para tratar somente desse curso 
BEGIN
	  ----------------------------------------------------  
	  -- TAG para trazer o VALOR TOTAL DO CURSO  
	INSERT INTO #TAGS_RETORNO (tag, valor)  
	  
	SELECT    
	 '%%VALOR_TOTAL%%',  
	 REPLACE(CAST(CONVERT(MONEY,SUM(VALOR_TOTAL)) AS VARCHAR),'.',',')+ ' '   
	 + '(' + LTRIM(dbo.Money_Extenso(CONVERT(MONEY,SUM(VALOR_TOTAL)))) + ')' AS VALOR_TOTAL  
	 FROM   
	 (  
	  SELECT distinct
	   VSP.SERVICO,  
	   ISNULL(CUSTO_UNITARIO,0) AS VALOR_TOTAL  
	  FROM   
	   LY_VALOR_SERV_PERIODO VSP  
	  INNER JOIN VW_FCAV_SERVICO_TURMA ST ON (ST.SERVICO = VSP.SERVICO AND ST.ANO = VSP.ANO AND ST.SEMESTRE = VSP.PERIODO)  
	  INNER JOIN LY_PLANO_PGTO_INSCRONLINE POF ON (POF.OFERTA_DE_CURSO = ST.OFERTA_DE_CURSO)  
	  INNER JOIN LY_PLANOS_OFERTADOS pl on (POF.OFERTA_DE_CURSO = pl.OFERTA_DE_CURSO)  
	  WHERE  
	   VSP.SERVICO LIKE 'MENS%' 

	   AND ALUNO = @p_aluno    
	    
	  UNION  
	  
	  SELECT   
	   VSP.SERVICO,  
	   ISNULL(vsp.CUSTO_UNITARIO,0) AS VALOR_TOTAL  
	  FROM   
	   LY_VALOR_SERV_PERIODO VSP  
	   --INNER JOIN LY_CURRICULO CUR ON (CUR.CURSO = SUBSTRING(VSP.SERVICO,6,20))    
	   INNER JOIN LY_SERVICO_MATRICULA SM ON (VSP.SERVICO = SM.SERVICO)
	   INNER JOIN LY_ALUNO ALU ON (ALU.CURSO = SM.CURSO AND ALU.TURNO = SM.TURNO AND ALU.CURRICULO = SM.CURRICULO)    
	   INNER JOIN LY_OPCOES_MATRICULA OM ON (OM.ANO = VSP.ANO AND OM.PERIODO = VSP.PERIODO AND OM.CURSO = ALU.CURSO)  
	  WHERE  
	   VSP.SERVICO LIKE 'MATR%'  
	   AND ALUNO = @p_aluno  
	 ) AS VALOR_TOTAL  

 ----------------------------------------------------  
	  -- TAG para trazer o VALOR DA MENSALIDADE  
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT  TOP 1
	  '%%VALOR_MENS%%',  
	  REPLACE(CAST(CONVERT(MONEY,ISNULL(CUSTO_UNITARIO/max(pof.NUM_PARCELAS),0)) AS VARCHAR),'.',',') +   
	  ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL(CUSTO_UNITARIO/max(pof.NUM_PARCELAS),0)))) + ')' AS VALOR_MENS
	 FROM   
	  LY_VALOR_SERV_PERIODO VSP  
	  INNER JOIN VW_FCAV_SERVICO_TURMA ST ON (ST.SERVICO = VSP.SERVICO AND ST.ANO = VSP.ANO AND ST.SEMESTRE = VSP.PERIODO)  
	  INNER JOIN LY_PLANO_PGTO_INSCRONLINE ppi ON (ppi.OFERTA_DE_CURSO = ST.OFERTA_DE_CURSO)  
	  INNER JOIN LY_PLANOS_OFERTADOS pof on (ppi.OFERTA_DE_CURSO = pof.OFERTA_DE_CURSO AND pof.NUM_PARCELAS = POF.NUM_PARCELAS)  
	 WHERE  
	  VSP.SERVICO LIKE 'MENS%'  
	 -- AND pof.NUM_PARCELAS > 1
	  AND ST.OFERTA_DE_CURSO = @p_ofertaCurso  
	  AND ppi.ALUNO = @p_aluno    
	 group by  
	  pof.NUM_PARCELAS, CUSTO_UNITARIO  
	UNION  
	 SELECT   
	  '%%VALOR_MENS%%',  
	  '0,00' + ' ' + '(' + ltrim(dbo.Money_Extenso(0)) + ')' AS VALOR_MENS
	 FROM  
	  LY_ALUNO AL  
	 WHERE  
	  NOT EXISTS  
	  (  
	   SELECT   
		 1  
	   FROM   
		LY_VALOR_SERV_PERIODO VSP  
		INNER JOIN VW_FCAV_SERVICO_TURMA ST ON (ST.SERVICO = VSP.SERVICO AND ST.ANO = VSP.ANO AND ST.SEMESTRE = VSP.PERIODO)  
		INNER JOIN LY_PLANO_PGTO_INSCRONLINE ppi ON (ppi.OFERTA_DE_CURSO = ST.OFERTA_DE_CURSO)  
		INNER JOIN LY_PLANOS_OFERTADOS pof on (ppi.OFERTA_DE_CURSO = pof.OFERTA_DE_CURSO AND pof.NUM_PARCELAS = POF.NUM_PARCELAS)  
	   WHERE  
		VSP.SERVICO LIKE 'MENS%'  
		--AND pof.NUM_PARCELAS > 1
		AND ST.OFERTA_DE_CURSO = @p_ofertaCurso  
		AND ppi.ALUNO = @p_aluno  
	  )  
	 AND ALUNO = @p_aluno

	------------------------------------------------------  
	-- TAG para verificar se o curso possui Matricula.  
	 --TABELA TEMPORARIA PARA VALOR DA MATRICULA  
	 SELECT   
	  REPLACE(CAST(CONVERT(MONEY,ISNULL(CUSTO_UNITARIO,0)) AS VARCHAR),'.',',') +   
	  ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL(CUSTO_UNITARIO,0)))) + ')' AS VALOR_MATR  
	  
	 INTO #VALOR_MATR  
	  
	 FROM   
	  LY_VALOR_SERV_PERIODO VSP  
	  --INNER JOIN LY_CURRICULO CUR ON (CUR.CURSO = SUBSTRING(VSP.SERVICO,6,20))  
	  INNER JOIN LY_SERVICO_MATRICULA SM ON (VSP.SERVICO = SM.SERVICO)
	  INNER JOIN LY_ALUNO ALU ON (ALU.CURRICULO = SM.CURRICULO)    
	  INNER JOIN LY_OPCOES_MATRICULA OM ON (OM.ANO = VSP.ANO AND OM.PERIODO = VSP.PERIODO AND OM.CURSO = ALU.CURSO)  
	 WHERE 
	  VSP.SERVICO LIKE 'MATR%'  
	  AND ALUNO = @p_aluno  
	UNION  
	 SELECT   
	  ' ' AS VALOR_MATR  
	 FROM  
	  LY_ALUNO AL  
	 WHERE  
	  NOT EXISTS  
	  (  
	   SELECT   
		 1  
	   FROM   
		LY_VALOR_SERV_PERIODO VSP  
		--INNER JOIN LY_CURRICULO CUR ON (CUR.CURSO = SUBSTRING(VSP.SERVICO,6,20))  
		INNER JOIN LY_SERVICO_MATRICULA SM ON (VSP.SERVICO = SM.SERVICO)
		INNER JOIN LY_ALUNO ALU ON (ALU.CURRICULO = SM.CURRICULO)    
		INNER JOIN LY_OPCOES_MATRICULA OM ON (OM.ANO = VSP.ANO AND OM.PERIODO = VSP.PERIODO AND OM.CURSO = ALU.CURSO)  
	   WHERE  
		VSP.SERVICO LIKE 'MATR%'  
		AND ALUNO = AL.ALUNO  
	  )  
	 AND ALUNO = @p_aluno  
	  
	  
	 --TABELA TEMPORARIA PARA DATA DE VENCIMENTO DA MATRICULA  
	 
	 -- ALTERA A DATA DE VENCIMENTO SE O RESPONSÁVEL É PESSOA JURIDICA 
		DECLARE @v_DESCR INT
		DECLARE @v_DT_VENC_MATR VARCHAR(30)
		
		IF EXISTS (SELECT 1 FROM LY_PLANO_PGTO_INSCRONLINE P JOIN LY_RESP_FINAN R ON P.RESP = R.RESP
					WHERE R.CGC_TITULAR IS NOT NULL AND P.ALUNO = @p_aluno)
		BEGIN
		
			SELECT 
				@v_DESCR = CONVERT(INT,DESCR)
			FROM 
				HADES..HD_TABELAITEM
			WHERE 
				TABELA = 'DiasVencPessJuridica'
				AND ITEM = 'DIAS'
		  
			SELECT
			 	@v_DT_VENC_MATR = CONVERT(VARCHAR,dbo.FN_FCAV_GetDiaUtil(GETDATE(), @v_DESCR),103)
				  
			FROM  
				LY_PLANOS_OFERTADOS POF  
				INNER JOIN LY_OFERTA_CURSO OFC ON (POF.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO)  
			WHERE   
				POF.PLANO = 1  
				AND OFC.OFERTA_DE_CURSO = @p_ofertaCurso  
			END
		ELSE
			BEGIN	
		
			 SELECT
			  
				@v_DT_VENC_MATR = CONVERT(VARCHAR,dbo.FN_FCAV_GetDiaUtil(GETDATE(), N_DIAS_VENC_BOL),103)
			   
			 FROM  
			  LY_PLANOS_OFERTADOS POF  
			  INNER JOIN LY_OFERTA_CURSO OFC ON (POF.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO)  
			 WHERE   
			  POF.PLANO = 1  
			  AND OFC.OFERTA_DE_CURSO = @p_ofertaCurso  
		 
		END  
	--------------------------------------
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	  
	 SELECT top 1  
	  '%%VERIFICA_MATR%%',  
	  CASE WHEN EXISTS (SELECT  
			 1  
			FROM   
			 LY_VALOR_SERV_PERIODO VSP  
		--	 INNER JOIN LY_CURRICULO CUR ON (CUR.CURSO = SUBSTRING(VSP.SERVICO,6,20))  
			INNER JOIN LY_SERVICO_MATRICULA SM ON (VSP.SERVICO = SM.SERVICO)
			 INNER JOIN LY_ALUNO ALU ON (ALU.CURRICULO = SM.CURRICULO)    
			 INNER JOIN LY_OPCOES_MATRICULA OM ON (OM.ANO = VSP.ANO AND OM.PERIODO = VSP.PERIODO AND OM.CURSO = ALU.CURSO)  
			WHERE  
			 VSP.SERVICO LIKE 'MATR%'  
			 AND ALUNO = @p_aluno)  
		THEN 'da taxa de matrícula no valor de R$ ' + (SELECT * FROM #VALOR_MATR) + ' com vencimento em ' + @v_DT_VENC_MATR +' e'  
		ELSE   
		  'de'  
	  END AS VERIFICA_MATR  
	 FROM   
	  LY_VALOR_SERV_PERIODO VSP  
	  --INNER JOIN LY_CURRICULO CUR ON (CUR.CURSO = SUBSTRING(VSP.SERVICO,6,20))  
	  INNER JOIN LY_SERVICO_MATRICULA SM ON (VSP.SERVICO = SM.SERVICO)
	  INNER JOIN LY_ALUNO ALU ON (ALU.CURRICULO = SM.CURRICULO)     
	  INNER JOIN LY_OPCOES_MATRICULA OM ON (OM.ANO = VSP.ANO AND OM.PERIODO = VSP.PERIODO AND OM.CURSO = ALU.CURSO)  
	  
	  ----------------------------------------------------  
	  -- TAG para trazer o VALOR DA MATRICULA  
	INSERT INTO #TAGS_RETORNO (tag, valor)  
	 SELECT   
	  '%%VALOR_MATR%%',  
	  REPLACE(CAST(CONVERT(MONEY,ISNULL(CUSTO_UNITARIO,0)) AS VARCHAR),'.',',') +   
	  ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL(CUSTO_UNITARIO,0)))) + ')'AS VALOR_MATR  
	 FROM   
	  LY_VALOR_SERV_PERIODO VSP  
	  --INNER JOIN LY_CURRICULO CUR ON (CUR.CURSO = SUBSTRING(VSP.SERVICO,6,20))    
	  INNER JOIN LY_SERVICO_MATRICULA SM ON (VSP.SERVICO = SM.SERVICO)
	  INNER JOIN LY_ALUNO ALU ON (ALU.CURSO = SM.CURSO AND ALU.TURNO = SM.TURNO AND ALU.CURRICULO = SM.CURRICULO)    
	  INNER JOIN LY_OPCOES_MATRICULA OM ON (OM.ANO = VSP.ANO AND OM.PERIODO = VSP.PERIODO AND OM.CURSO = ALU.CURSO)  
	 WHERE  
	  VSP.SERVICO LIKE 'MATR%'  
	  AND ALUNO = @p_aluno  
	UNION  
	 SELECT   
	  '%%VALOR_MATR%%',  
	  '0,00' + ' ' + '(' + ltrim(dbo.Money_Extenso(0)) + ')' AS VALOR_MATR  
	 FROM  
	  LY_ALUNO AL  
	 WHERE  
	  NOT EXISTS  
	  (  
	   SELECT   
		 1  
	   FROM   
		LY_VALOR_SERV_PERIODO VSP  
		--INNER JOIN LY_CURRICULO CUR ON (CUR.CURSO = SUBSTRING(VSP.SERVICO,6,20))    
		INNER JOIN LY_SERVICO_MATRICULA SM ON (VSP.SERVICO = SM.SERVICO)
		INNER JOIN LY_ALUNO ALU ON (ALU.CURSO = SM.CURSO AND ALU.TURNO = SM.TURNO AND ALU.CURRICULO = SM.CURRICULO)    
		INNER JOIN LY_OPCOES_MATRICULA OM ON (OM.ANO = VSP.ANO AND OM.PERIODO = VSP.PERIODO AND OM.CURSO = ALU.CURSO)  
	   WHERE  
		VSP.SERVICO LIKE 'MATR%'  
		AND ALUNO = AL.ALUNO  
	  )  
	 AND ALUNO = @p_aluno  

	 ----------------------------------------------------  
	  -- TAG PARA TRAZER A DATA DE VENCIMENTO DA MATRICULA    
	  IF EXISTS (SELECT 1 FROM LY_PLANO_PGTO_INSCRONLINE P JOIN LY_RESP_FINAN R ON P.RESP = R.RESP
					WHERE R.CGC_TITULAR IS NOT NULL AND P.ALUNO = @p_aluno)
		BEGIN
		
			SELECT 
				@v_DESCR = CONVERT(INT,DESCR)
			FROM 
				HADES..HD_TABELAITEM
			WHERE 
				TABELA = 'DiasVencPessJuridica'
				AND ITEM = 'DIAS'
			INSERT INTO #TAGS_RETORNO (tag, valor) 
			SELECT
				'%%DT_VENC_MATR%%',
			 	CONVERT(VARCHAR,dbo.FN_FCAV_GetDiaUtil(GETDATE(), @v_DESCR),103)
				  
			FROM  
				LY_PLANOS_OFERTADOS POF  
				INNER JOIN LY_OFERTA_CURSO OFC ON (POF.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO)  
			WHERE   
				POF.PLANO = 1  
				AND OFC.OFERTA_DE_CURSO = @p_ofertaCurso  
			END
		ELSE
			BEGIN	
			 INSERT INTO #TAGS_RETORNO (tag, valor) 
			 SELECT
				'%%DT_VENC_MATR%%',
				CONVERT(VARCHAR,dbo.FN_FCAV_GetDiaUtil(GETDATE(), N_DIAS_VENC_BOL),103)
			   
			 FROM  
			  LY_PLANOS_OFERTADOS POF  
			  INNER JOIN LY_OFERTA_CURSO OFC ON (POF.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO)  
			 WHERE   
			  POF.PLANO = 1  
			  AND OFC.OFERTA_DE_CURSO = @p_ofertaCurso  
		 
		END   
		
	 ----------------------------------------------------  
	  -- TAG para trazer a data de vencimento primeira mensalidade de acordo com o plano de oferta

	 INSERT INTO #TAGS_RETORNO (tag, valor) 
		 SELECT
			'%%DT_VENC_MENS1%%',
			'15/'+cast(POF.MES_INICIAL as varchar)+'/'+CAST(ANO_INGRESSO as varchar)
			
		 FROM  
		  LY_PLANOS_OFERTADOS POF  
		  INNER JOIN LY_OFERTA_CURSO OFC ON (POF.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO) 
		 WHERE   
		  POF.PLANO = 1  
		  AND OFC.OFERTA_DE_CURSO = @p_ofertaCurso  

	 
	 
	----------------------------------------------------  
	  -- TAG para trazer o número de PARCELAS  
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT  TOP 1
	  '%%NUM_PARCELAS%%',  
	  CASE WHEN po.NUM_PARCELAS = 1 THEN CAST(MAX(po.NUM_PARCELAS) AS VARCHAR) + ' ' + '(' + ltrim(dbo.Numero_Extenso(MAX(po.NUM_PARCELAS))) + ')'  
		ELSE CAST(po.NUM_PARCELAS AS VARCHAR) + ' ' + '(' + ltrim(dbo.Numero_Extenso(po.NUM_PARCELAS)) + ')'  
	  END AS NUM_PARCELAS  
	 FROM  
	  LY_PLANOS_OFERTADOS po   
	  inner join LY_PLANO_PGTO_INSCRONLINE POF ON (POF.OFERTA_DE_CURSO = po.OFERTA_DE_CURSO)    
	 WHERE  
	  po.PLANOPAG like 'MENS%'  
	  and po.OFERTA_DE_CURSO = @p_ofertaCurso  
	  and ALUNO = @p_aluno  
	 group by  
	  po.NUM_PARCELAS, POF.NUM_PARCELAS  
	UNION  
	 SELECT   
	  '%%NUM_PARCELAS%%',  
	  '1' + ' ' + '(' + ltrim(dbo.Numero_Extenso(1)) + ')' AS NUM_PARCELAS  
	 FROM  
	  LY_ALUNO AL  
	 WHERE  
	  NOT EXISTS  
	  (  
	   SELECT   
		 1  
	   FROM   
		LY_PLANO_PGTO_INSCRONLINE POF 
		inner join LY_PLANOS_OFERTADOS pl on (POF.OFERTA_DE_CURSO = pl.OFERTA_DE_CURSO)    
	   WHERE  
		pl.PLANOPAG like 'MENS%'  
		and pl.OFERTA_DE_CURSO = @p_ofertaCurso  
		and ALUNO = @p_aluno  
	  )  
	 AND ALUNO = @p_aluno  
	  
	----------------------------------------------------  
	  -- TAG para trazer o plano escolhido  
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT  DISTINCT 
	  '%%PLANO_ESCOLHIDO%%',  
	  CASE WHEN NUM_PARCELAS = 1 THEN 'à vista'  
		   WHEN (NUM_PARCELAS = 12 OR NUM_PARCELAS = 11) AND Ltrim(Rtrim(oc.CURSO)) like 'CEAI' THEN 'Parcelado Anual'   
		WHEN (NUM_PARCELAS = 24 OR NUM_PARCELAS = 23) AND Ltrim(Rtrim(oc.CURSO)) like 'CEAI' THEN 'Parcelado Bienal'  
		ELSE 'Parcelado'   
	  END AS PLANO_ESCOLHIDO  
	 FROM  
	  LY_PLANO_PGTO_INSCRONLINE pl   
	  inner join LY_OFERTA_CURSO oc on (pl.OFERTA_DE_CURSO = oc.OFERTA_DE_CURSO and oc.OFERTA_DE_CURSO  = @p_ofertaCurso)  
	 WHERE   
	  pl.OFERTA_DE_CURSO = @p_ofertaCurso  
	  and ALUNO = @p_aluno  

 END --FIM DO IF(@curso not like CCOL)  


ELSE -- TAGS exclusivas para o curso CCOL
 BEGIN
	----------------------------------------------------  
	  -- TAG para trazer o plano escolhido  
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT  DISTINCT
	  '%%PLANO_ESCOLHIDO%%',  
	  CASE  WHEN NUM_PARCELAS =  1 THEN 'À vista'  
		    WHEN NUM_PARCELAS =  5 AND Ltrim(Rtrim(oc.CURSO)) like 'CCOL' THEN 'Matrícula + 5 (Cinco) Parcelas'   
			WHEN NUM_PARCELAS = 10 AND Ltrim(Rtrim(oc.CURSO)) like 'CCOL' THEN 'Matrícula + 10 (Dez) Parcelas'   
			WHEN NUM_PARCELAS = 20 AND Ltrim(Rtrim(oc.CURSO)) like 'CCOL' THEN 'Matrícula + 20 (Vinte) Parcelas'  
	  END AS PLANO_ESCOLHIDO  
	 FROM  
	  LY_PLANO_PGTO_INSCRONLINE pp   
	  inner join LY_OFERTA_CURSO oc on (pp.OFERTA_DE_CURSO = oc.OFERTA_DE_CURSO and oc.OFERTA_DE_CURSO = @p_ofertaCurso)
	 WHERE   
	  pp.OFERTA_DE_CURSO = @p_ofertaCurso  
	  and ALUNO = @p_aluno 
	
	----------------------------------------------------  
	  -- TAG para trazer o número de PARCELAS  
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT TOP 1
	  '%%NUM_PARCELAS%%',  
	  CASE  WHEN pp.NUM_PARCELAS =  1 THEN CAST(MAX(pp.NUM_PARCELAS) AS VARCHAR) + ' ' + '(' + ltrim(dbo.Numero_Extenso(MAX(pp.NUM_PARCELAS))) + ')'
			WHEN pp.NUM_PARCELAS =  5 THEN CAST(MAX(pp.NUM_PARCELAS) AS VARCHAR) + ' ' + '(' + ltrim(dbo.Numero_Extenso(MAX(pp.NUM_PARCELAS))) + ')'
			WHEN pp.NUM_PARCELAS = 10 THEN CAST(MAX(pp.NUM_PARCELAS) AS VARCHAR) + ' ' + '(' + ltrim(dbo.Numero_Extenso(MAX(pp.NUM_PARCELAS))) + ')'
			WHEN pp.NUM_PARCELAS = 20 THEN CAST(MAX(pp.NUM_PARCELAS) AS VARCHAR) + ' ' + '(' + ltrim(dbo.Numero_Extenso(MAX(pp.NUM_PARCELAS))) + ')'
		ELSE CAST(pp.NUM_PARCELAS AS VARCHAR) + ' ' + '(' + ltrim(dbo.Numero_Extenso(pp.NUM_PARCELAS)) + ')'  
	  END AS NUM_PARCELAS  
	 FROM  
		LY_PLANO_PGTO_INSCRONLINE pp    
	 WHERE  
	  pp.OFERTA_DE_CURSO = @p_ofertaCurso  
	  AND ALUNO = @p_aluno 
	 group by  
	  pp.NUM_PARCELAS  
	  	 
	----------------------------------------------------  
	-- SCRIPT PARA ALIMENTARA A VARIÁVEL @ValorTotal, somente para o curso CCOL
	 DECLARE @ValorTotal NUMERIC
	 
	 SELECT DISTINCT
		@ValorTotal = DESCR 
	 FROM 
		HD_TABELAITEM T
		INNER JOIN LY_ALUNO A ON SUBSTRING(T.ITEM,1,4) = A.CURSO 
							 AND SUBSTRING(T.ITEM,6,4) = CAST(A.ANO_INGRESSO AS VARCHAR)
							 AND SUBSTRING(T.ITEM,11,1) = CAST(A.SEM_INGRESSO AS VARCHAR)
	 WHERE
		A.ALUNO = @p_aluno
	
	----------------------------------------------------  
	  -- TAG para trazer o VALOR TOTAL DO CURSO CCOL	
	INSERT INTO #TAGS_RETORNO (tag, valor)    
	
	 SELECT DISTINCT 
	  '%%VALOR_TOTAL%%',  
	  REPLACE(CAST(CONVERT(MONEY,ISNULL(@ValorTotal,0)) AS VARCHAR),'.',',') + ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL(@ValorTotal,0)))) + ')' AS VALOR_TOTAL  
	 FROM   
	  LY_ALUNO A
	  INNER JOIN LY_PLANO_PGTO_INSCRONLINE  P ON A.ALUNO = P.ALUNO
	 WHERE  
	  A.ALUNO = @p_aluno
	  
	----------------------------------------------------  
	  -- TAG para trazer o VALOR DA MENSALIDADE

	INSERT INTO #TAGS_RETORNO (tag, valor)
	 SELECT DISTINCT
	  '%%VALOR_MENS%%',  
	  CASE  WHEN P.NUM_PARCELAS =  1 then REPLACE(CAST(CONVERT(MONEY,ISNULL(@ValorTotal,0)) AS VARCHAR),'.',',') + ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL(@ValorTotal,0)))) + ')' 
			WHEN P.NUM_PARCELAS =  5 then REPLACE(CAST(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)) AS VARCHAR),'.',',') + ' ' + '(' + dbo.Money_Extenso(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0))) + ')' 
			WHEN p.NUM_PARCELAS = 10 then REPLACE(CAST(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)) AS VARCHAR),'.',',') + ' ' + '(' + dbo.Money_Extenso(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0))) + ')' 
			WHEN p.NUM_PARCELAS = 20 then REPLACE(CAST(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)) AS VARCHAR),'.',',') + ' ' + '(' + dbo.Money_Extenso(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0))) + ')' 
	  END AS VALOR_MENS  
	 FROM   
		LY_LANC_DEBITO L
		JOIN LY_ALUNO A ON L.ALUNO = A.ALUNO
		JOIN LY_PLANO_PGTO_PERIODO P ON L.ALUNO = P.ALUNO AND L.ANO_REF = P.ANO AND L.PERIODO_REF = P.PERIODO
		LEFT JOIN LY_DESCONTO_PLANO_PGTO DP ON A.CURSO = DP.CURSO AND A.TURNO = DP.TURNO AND A.CURRICULO = DP.CURRICULO
				AND A.CONCURSO = DP.CONCURSO AND P.NUM_PARCELAS = DP.NUM_PARCELAS
		JOIN LY_CURRICULO CR ON A.CURSO = CR.CURSO AND A.TURNO = CR.TURNO AND A.CURRICULO = CR.CURRICULO
		JOIN LY_VALOR_SERV_PERIODO SP ON CR.SERVICO = SP.SERVICO AND L.ANO_REF = SP.ANO AND L.PERIODO_REF = SP.PERIODO
	 WHERE  
	  A.ALUNO = @p_aluno
	 
	----------------------------------------------------  
	  -- TAG para trazer o VALOR DA MATRICULA  
	
	INSERT INTO #TAGS_RETORNO (tag, valor)      
	 
	 SELECT DISTINCT
	  '%%VALOR_MATR%%',  
	  CASE  WHEN P.NUM_PARCELAS =  1 then REPLACE(CAST(CONVERT(MONEY,ISNULL(0,0)) AS VARCHAR),'.',',') + ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL(0,0)))) + ')' 
			WHEN P.NUM_PARCELAS =  5 then REPLACE(CAST(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)) AS VARCHAR),'.',',') + ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)))) + ')' 
			WHEN p.NUM_PARCELAS = 10 then REPLACE(CAST(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)) AS VARCHAR),'.',',') + ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)))) + ')' 
			WHEN p.NUM_PARCELAS = 20 then REPLACE(CAST(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)) AS VARCHAR),'.',',') + ' ' + '(' + ltrim(dbo.Money_Extenso(CONVERT(MONEY,ISNULL((SP.CUSTO_UNITARIO - DP.DESCONTO) / DP.NUM_PARCELAS,0)))) + ')' 
	  END AS VALOR_MATR  
	 FROM   
	  LY_LANC_DEBITO L
		JOIN LY_ALUNO A ON L.ALUNO = A.ALUNO
		JOIN LY_PLANO_PGTO_PERIODO P ON L.ALUNO = P.ALUNO AND L.ANO_REF = P.ANO AND L.PERIODO_REF = P.PERIODO
		LEFT JOIN LY_DESCONTO_PLANO_PGTO DP ON A.CURSO = DP.CURSO AND A.TURNO = DP.TURNO AND A.CURRICULO = DP.CURRICULO
				AND A.CONCURSO = DP.CONCURSO AND P.NUM_PARCELAS = DP.NUM_PARCELAS
		JOIN LY_CURRICULO CR ON A.CURSO = CR.CURSO AND A.TURNO = CR.TURNO AND A.CURRICULO = CR.CURRICULO
		JOIN LY_VALOR_SERV_PERIODO SP ON CR.SERVICO = SP.SERVICO AND L.ANO_REF = SP.ANO AND L.PERIODO_REF = SP.PERIODO 
	 WHERE  
	  A.ALUNO = @p_aluno


	----------------------------------------------------  
	  -- TAG para trazer a numero de dias para vencimento da matricula  
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT   
	  '%%N_DIAS_VENC_BOL%%',  
	  ISNULL((CAST(N_DIAS_VENC_BOL AS VARCHAR) + ' ' + '(' + ltrim(dbo.Numero_Extenso(N_DIAS_VENC_BOL)) + ')'),'') as N_DIAS_VENC_BOL  
	 FROM  
	  LY_PLANOS_OFERTADOS POF  
	  INNER JOIN LY_OFERTA_CURSO OFC ON (POF.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO)  
	 WHERE   
	  POF.PLANO = 1  
	  AND OFC.OFERTA_DE_CURSO = @p_ofertaCurso  

	----------------------------------------------------  
	  -- TAG PARA TRAZER A DATA DE VENCIMENTO DA MATRICULA  
	INSERT INTO #TAGS_RETORNO (tag, valor)   
	 SELECT   
	  '%%DT_VENC_MATR%%',  
	  CONVERT(VARCHAR,dbo.FN_FCAV_GetDiaUtil(GETDATE(), N_DIAS_VENC_BOL),103) as DT_VENC_MATR  
	 FROM  
	  LY_PLANOS_OFERTADOS POF  
	  INNER JOIN LY_OFERTA_CURSO OFC ON (POF.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO)  
	 WHERE   
	  POF.PLANO = 1  
	  AND OFC.OFERTA_DE_CURSO = @p_ofertaCurso


	 ----------------------------------------------------  
	  -- TAG para trazer a data de vencimento primeira mensalidade

	 INSERT INTO #TAGS_RETORNO (tag, valor) 
		 SELECT
			'%%DT_VENC_MENS1%%',
			'15/'+cast(month(VC.DT_INICIO)as varchar)+'/'+CAST(year(VC.DT_INICIO)as varchar)		   
		 FROM  
		  LY_PLANOS_OFERTADOS POF  
		  INNER JOIN LY_OFERTA_CURSO OFC ON (POF.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO)  
		  INNER JOIN VW_FCAV_INI_FIM_CURSO_TURMA VC ON VC.OFERTA_DE_CURSO = OFC.OFERTA_DE_CURSO
		 WHERE   
		  POF.PLANO = 1  
		  AND OFC.OFERTA_DE_CURSO = @p_ofertaCurso  

	

 END --FIM do ELSE	
 
 
 ---------------------------------------------------------------      
 --[FIM CUSTOMIZAÇÃO]      
 ---------------------------------------------------------------      
        
 SELECT * FROM #TAGS_RETORNO ORDER BY TAG, VALOR      
       
 END 