/*
    SP utilizada na JOB que alimenta a tabela SP_FCAV_AVALIACAO_DOCENTE
	
	SELECT COD_AVAL, * FROM #tmp_respostas_alunos WHERE APLICACAO LIKE '%MBAGPT03EENCI%'
	SELECT * FROM #tmp_avaliacao_disciplinas  WHERE APLICACAO LIKE '%MBAGPT03EENCI%'
	SELECT * FROM #tmp_alunos_turma_disicplina WHERE TURMA LIKE 'MBA%GP%T%03%' AND DISCIPLINA LIKE 'CEAI%bdd%'
	SELECT * FROM #tb_salas_turmas
	SELECT * FROM #tmp_avaliacao_aluno_turma WHERE   TURMA LIKE 'CEAI%2020%3%' AND DISCIPLINA LIKE 'CEAI%TCC%'
	SELECT * FROM FCAV_AVALIACAO_DOCENTE where cod_aval = 'MBAGPT03EENCI'
	
	SELECT * FROM VW_FCAV_MATRICULA_E_PRE_MATRICULA WHERE TURMA LIKE 'D%DBDON%' 

	EXEC SP_FCAV_AVALIACAO_DOCENTE
	
Criação: 23/04/2019

*/

ALTER PROCEDURE SP_FCAV_AVALIACAO_DOCENTE
AS
	SET NOCOUNT ON
	BEGIN
		----------------------------------------------------------------------------  
		-- Determina a massa de dados para os alunos que responderem Avaliação
		----------------------------------------------------------------------------  
		SELECT
			AV.ALUNO,
			DATEADD(DD, DATEDIFF(DD, 0, PQ.DATA_PART), 0) AS
			DT_PREENCHIMENTO,
			SUBSTRING(AQ.TITULO, 1, 2)+' Avaliação' AS
			AVALIACAO,
			AQ.TITULO,
			AQ.DT_INICIO,
			AQ.DT_FIM,
			PQ.TIPO_QUESTIONARIO,
			PQ.QUESTIONARIO,
			PQ.APLICACAO,
			CASE
				WHEN QA.TIPO_OBJETO = 'OUTROS' THEN 'CURSO'
				ELSE QA.TIPO_OBJETO
			END AS
			TIPO_AVALIADO,
			QE.ASPECTO,
			AD.CODIGO AS
			AVALIADO,
			ISNULL(AD.DESCRICAO, 'INFRAESTRUTURA DO CURSO') AS
			NOME_AVALIADO,
			QE.QUESTAO,
			CASE
				WHEN QE.QUESTAO_OBJETIVA IS NOT NULL THEN 'Objetiva'
				ELSE 'Subjetiva'
			END AS
			TIPO_QUESTAO,
			ISNULL(
				SUBSTRING(QE.QUESTAO_OBJETIVA,1,CASE WHEN CHARINDEX('?',QE.QUESTAO_OBJETIVA) = 0 THEN LEN(QE.QUESTAO_OBJETIVA) 
				ELSE CHARINDEX('?',QE.QUESTAO_OBJETIVA)
				END) , QE.QUESTAO_SUBJETIVA)
			AS PERGUNTAS,
			ISNULL(CONVERT(varchar(2000), QU.DESCRICAO), RE.RESPOSTA_SUBJETIVA) AS
			RESPOSTA,
			ISNULL(CONVERT(varchar(2000), QU.VALOR), 'Comentario') AS
			VALOR,
			CASE
				WHEN PQ.QUESTIONARIO like 'Aval%Mod2' THEN CASE
						WHEN QU.VALOR BETWEEN 0 AND 2 THEN 'Péssimo'
						WHEN QU.VALOR BETWEEN 3 AND 4 THEN 'Ruim'
						WHEN QU.VALOR BETWEEN 5 AND 6 THEN 'Regular'
						WHEN QU.VALOR BETWEEN 7 AND 8 THEN 'Bom'
						WHEN QU.VALOR BETWEEN 9 AND 10 THEN 'Excelente'
						ELSE 'Nao avaliado'
					END
				ELSE CASE
						WHEN QU.VALOR = 5 THEN 'Péssimo'
						WHEN QU.VALOR = 4 THEN 'Ruim'
						WHEN QU.VALOR = 3 THEN 'Regular'
						WHEN QU.VALOR = 2 THEN 'Bom'
						WHEN QU.VALOR = 1 THEN 'Excelente'
						ELSE 'Nao avaliado'
					END
			END AS
			NOTA,
			
			SUBSTRING(
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PQ.APLICACAO,' ',''),'/',''),'-',''),'_',''),'0A',''), ---1º parametro da substring
				CASE WHEN PQ.APLICACAO LIKE 'DIS%'OR PQ.APLICACAO LIKE 'INF%' OR PQ.APLICACAO LIKE 'DI2%' OR PQ.APLICACAO LIKE 'PAR%' THEN 4
					 WHEN PQ.APLICACAO LIKE 'DO%' OR PQ.APLICACAO LIKE 'DI%' OR PQ.APLICACAO LIKE 'IN%' OR PQ.APLICACAO LIKE 'PA%' THEN 3
					 WHEN PQ.APLICACAO LIKE '%DO%' THEN 4  
					 ELSE 1
				END ,				---2º parametro da substring
				19					--3º parametro da substring
				) 
				+ 
				CASE WHEN PQ.QUESTIONARIO = 'Aval_Parcial_Mod4' THEN 'P'
					-- WHEN PQ.QUESTIONARIO = 'Aval_Online' THEN 'O'
					ELSE ''
				END
				AS COD_AVAL

			INTO #tmp_respostas_alunos 
		FROM 
			LY_AVALIADOR AV 
				INNER JOIN LY_PARTICIPACAO_QUEST PQ 
						ON PQ.CODIGO			= AV.CODIGO 
						AND PQ.TIPO_OBJETO	= AV.TIPO_OBJETO
					
				INNER JOIN LY_APLIC_QUESTIONARIO AQ
						ON AQ.TIPO_QUESTIONARIO	= PQ.TIPO_QUESTIONARIO 
						AND AQ.QUESTIONARIO		= PQ.QUESTIONARIO 
						AND AQ.APLICACAO		= PQ.APLICACAO 
						AND AQ.ATIVO			= 'S'

				INNER JOIN LY_QUESTAO QE 
						ON QE.TIPO_QUESTIONARIO	= AQ.TIPO_QUESTIONARIO 
						AND QE.QUESTIONARIO		= AQ.QUESTIONARIO 

				INNER JOIN LY_QUESTAO_APLICADA QA 
						ON QA.TIPO_QUESTIONARIO	= QE.TIPO_QUESTIONARIO 
						AND QA.QUESTIONARIO		= QE.QUESTIONARIO 
						AND QA.QUESTAO			= QE.QUESTAO 
						AND QA.PAR_CODIGO		= AV.ALUNO
						AND QA.PAR_TIPO_OBJETO	= AV.TIPO_OBJETO 
						AND QA.APLICACAO		= PQ.APLICACAO
						AND QA.PAR_CODIGO		= PQ.CODIGO
						AND QA.PAR_TIPO_OBJETO	= PQ.TIPO_OBJETO
				
				INNER JOIN LY_AVALIADO AD 
						ON AD.TIPO_OBJETO	= QA.TIPO_OBJETO 
						AND AD.CODIGO	= QA.CODIGO

				LEFT JOIN LY_RESPOSTA RE 
						ON RE.CODIGO			 = AD.CODIGO
						AND RE.TIPO_OBJETO		 = AD.TIPO_OBJETO
						and re.AVA_TIPO_OBJETO	 = pq.TIPO_OBJETO
						aND RE.AVA_CODIGO		 = PQ.CODIGO
						AND RE.TIPO_QUESTIONARIO = QA.TIPO_QUESTIONARIO
						AND RE.AVA_CODIGO		 = QA.PAR_CODIGO
						AND RE.AVA_TIPO_OBJETO	 = QA.PAR_TIPO_OBJETO
						AND RE.QUESTAO			 = QA.QUESTAO
						AND RE.TIPO_OBJETO		 = QA.TIPO_OBJETO
						AND RE.APLICACAO		 = QA.APLICACAO
						AND RE.APLICACAO		 = PQ.APLICACAO
		
				LEFT JOIN LY_CONCEITO_RESPOSTA CO 
						ON CO.CODIGO				 = AD.CODIGO 
						AND CO.TIPO_OBJETO		 = AD.TIPO_OBJETO 
						AND CO.TIPO_QUESTIONARIO = PQ.TIPO_QUESTIONARIO 
						AND CO.QUESTAO			 = RE.QUESTAO 
						AND CO.TIPO				 = QE.TIPO 
						AND CO.APLICACAO		 = PQ.APLICACAO
						AND CO.QUESTAO			 = QE.QUESTAO 
						AND CO.CHAVE_RESP		 = RE.CHAVE_RESP 
				LEFT JOIN LY_CONCEITOS_QUEST QU 
					ON QU.CONCEITO = CO.CONCEITO 
						AND QU.TIPO = CO.TIPO 
		WHERE	convert(date,AQ.DT_FIM + 15) >= convert(date,getdate())   ---limite para trazer somente as avaliações que estão abertas e por um periodo de 15 dias após encerramento.
			--AND AQ.QUESTIONARIO LIKE '%Mod1'
			
		----------------------------------------------------------------------------
		--Determina Tabela Temporaria com Codigo da Avaliacao para Disciplina
		----------------------------------------------------------------------------
		SELECT
			AVALIADO AS DISCIPLINA,
			APLICACAO,
			COD_AVAL
 				
			INTO  #tmp_avaliacao_disciplinas
		FROM 
			#tmp_respostas_alunos 
		WHERE
			TIPO_AVALIADO = 'DISCIPLINA'
		GROUP BY AVALIADO ,
			APLICACAO,
			COD_AVAL

		----------------------------------------------------------------------------
		--- RELACIONA OS ALUNOS MATRICULADOS NAS DISCIPLINAS, ANO E PERIODO
		----------------------------------------------------------------------------
		SELECT 
			CS.FACULDADE UNIDADE_RESPONSAVEL,
			CS.CURSO,
			CS.NOME AS NOME_CURSO,
			CASE WHEN CS.CURSO = 'CEAI' AND AL.TURMA != 'CEAI T 34 SAB' THEN AC.TURMA_CEAI
			ELSE AL.TURMA END AS TURMA,
			AL.ALUNO,
			AL.NOME_COMPL NOME_AVALIADOR,
			AL.SIT_MATRICULA, 
			AL.DISCIPLINA,
			AL.ANO,
			AL.SEMESTRE,
			CASE WHEN CS.CURSO = 'CEAI' AND AL.TURMA != 'CEAI T 34 SAB' THEN REPLACE(REPLACE(REPLACE(AC.TURMA_CEAI,' ',''),'/',''),'-','') 
				ELSE REPLACE(REPLACE(REPLACE(AL.TURMA,' ',''),'/',''),'-','') 
			END AS CODTUR
			into #tmp_alunos_turma_disicplina
		FROM 
			VW_FCAV_MATRICULA_E_PRE_MATRICULA AL 
			LEFT JOIN VW_FCAV_ALUNOS_MATRICULADOS_CEAI AC
				ON AC.DISCIPLINA = AL.DISCIPLINA
				AND AC.ANO = AL.ANO	
				AND AC.SEMESTRE = AL.SEMESTRE
			INNER JOIN LY_CURSO CS
				ON CS.CURSO = AL.CURSO
			WHERE 
				AL.ANO >= 2018
				AND AL.SIT_MATRICULA = 'Matriculado'
		GROUP BY CS.FACULDADE,
				CS.CURSO,
				CS.NOME,
				AC.TURMA_CEAI,
				AL.TURMA,
				AL.ALUNO,
				AL.NOME_COMPL,
				AL.SIT_MATRICULA, 
				AL.DISCIPLINA,
				AL.ANO,
				AL.SEMESTRE
		

		----------------------------------------------------------------------------
		--- SALAS DA TURMAS
		----------------------------------------------------------------------------
		SELECT DISTINCT
			CASE WHEN TU.CURSO = 'CEAI' THEN AL.TURMA_CEAI
				ELSE TU.TURMA
			END AS TURMA,
			tu.DISCIPLINA,
			TU.DEPENDENCIA AS SALA
			INTO #tb_salas_turmas
		FROM 
		  LY_TURMA TU
		  LEFT JOIN VW_FCAV_ALUNOS_MATRICULADOS_CEAI AL
			ON AL.TURMA_ORIGEM = TU.TURMA
			AND AL.DISCIPLINA = TU.DISCIPLINA
			AND AL.ANO = TU.ANO
			AND AL.SEMESTRE = TU.SEMESTRE


		----------------------------------------------------------------------------
		-- CRIAÇÃO DA TABELA TEMPORÁRIA QUE IRÁ ALIMENTAR A FCAV_AVALIACAO_DOCENTE
		----------------------------------------------------------------------------
		SELECT
			AR.COD_AVAL,
			AL.UNIDADE_RESPONSAVEL,
			AL.CURSO,
			AL.NOME_CURSO,
			AL.TURMA,
			AL.ALUNO,
			NOME_AVALIADOR,
			AL.SIT_MATRICULA, 
			AR.DT_PREENCHIMENTO,
			AL.DISCIPLINA,
			AL.ANO,
			AL.SEMESTRE,
			AR.DT_INICIO,
			AR.DT_FIM,
			AR.QUESTIONARIO,
			AR.APLICACAO,
			AR.TIPO_AVALIADO,
			AR.ASPECTO,
			AR.AVALIADO,
			AR.NOME_AVALIADO,
			AR.QUESTAO,
			AR.TIPO_QUESTAO,
			RTRIM(REPLACE(AR.PERGUNTAS,' (Obrigatório)','')) AS PERGUNTAS,
			AR.RESPOSTA,
			AR.VALOR,
			AR.NOTA,
			tu.SALA 
			
			
		INTO #tmp_avaliacao_aluno_turma 
		  
		FROM  #tmp_respostas_alunos AR

		INNER JOIN #tmp_avaliacao_disciplinas AD 
			ON AD.COD_AVAL = AR.COD_AVAL

		INNER JOIN #tmp_alunos_turma_disicplina AL
			ON  AL.ALUNO		= AR.ALUNO
			AND AL.DISCIPLINA	= AD.DISCIPLINA
			AND AL.CODTUR = SUBSTRING(AR.COD_AVAL,1,LEN(CODTUR))

		LEFT JOIN #tb_salas_turmas tu
			on tu.turma = al.TURMA
			and tu.disciplina = al.DISCIPLINA
				
		GROUP  BY 
			
		    AL.UNIDADE_RESPONSAVEL,
			AL.CURSO,
			AL.NOME_CURSO,
			AL.TURMA,
			AL.ALUNO,
			NOME_AVALIADOR,
			AL.SIT_MATRICULA, 
			AL.DISCIPLINA,
			AL.ANO,
			AL.SEMESTRE,
			AR.COD_AVAL,
			AR.DT_INICIO,
			AR.DT_FIM,
			AR.QUESTIONARIO,
			AR.DT_PREENCHIMENTO,
			AR.APLICACAO,
			AR.TIPO_AVALIADO,
			AR.ASPECTO,
			AR.AVALIADO,
			AR.NOME_AVALIADO,
			AR.QUESTAO,
			AR.TIPO_QUESTAO,
			AR.PERGUNTAS,
			AR.RESPOSTA,
			AR.VALOR,
			AR.NOTA,
			tu.SALA

	--Preencha a tabela FCAV_AVALIACAO_DOCENTE
		BEGIN
			BEGIN TRANSACTION

				DROP TABLE FCAV_AVALIACAO_DOCENTE
								
				SELECT *
					INTO FCAV_AVALIACAO_DOCENTE
				FROM #tmp_avaliacao_aluno_turma
				ORDER BY UNIDADE_RESPONSAVEL, CURSO, TURMA

			COMMIT
		END

		----------------------------------------------------------------------------  
		-- Clean-up  
		----------------------------------------------------------------------------  

		BEGIN
			DROP TABLE #tmp_respostas_alunos
			DROP TABLE #tmp_avaliacao_disciplinas
			DROP TABLE #tmp_alunos_turma_disicplina
			DROP TABLE #tmp_avaliacao_aluno_turma
		END -- Clean-up  
END