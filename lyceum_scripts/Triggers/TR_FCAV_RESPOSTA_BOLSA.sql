-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Gabriel S. Scalione
-- Create date: 2019-10-09
-- Description:	Gatilho para colocar a resposta do interesse de bolsa no campo de obs do candidato.
-- =============================================
ALTER TRIGGER TR_FCAV_RESPOSTA_BOLSA 
   ON LY_PARTICIPACAO_QUEST
   AFTER INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Insert statements for trigger here

	declare @verifica_quest_bolsa T_CODIGO

	set @verifica_quest_bolsa = (select TIPO_QUESTIONARIO from inserted)

	
	if (@verifica_quest_bolsa = 'QI_BOLSA')
	begin

		if OBJECT_ID('TempDB.dbo.#tmp_resposta_bolsa') IS NOT NULL
			begin
				DROP TABLE #tmp_resposta_bolsa
			end

		SELECT
			AV.CANDIDATO,
			DATEADD(DD, DATEDIFF(DD, 0, PQ.DATA_PART), 0) AS
			DT_PREENCHIMENTO,
			SUBSTRING(AQ.TITULO, 1, 2)+' Avalia��o' AS
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
			QU.TIPO,
			ISNULL(CONVERT(varchar(2000), QU.DESCRICAO), RE.RESPOSTA_SUBJETIVA) AS
			RESPOSTA,
			ISNULL(CONVERT(varchar(2000), QU.VALOR), 'Comentario') AS
			VALOR

			into #tmp_resposta_bolsa

		from LY_AVALIADOR AV 
		INNER JOIN LY_PARTICIPACAO_QUEST PQ 
				ON PQ.CODIGO			= AV.CODIGO 
				AND PQ.TIPO_OBJETO	= AV.TIPO_OBJETO
				AND PQ.TIPO_QUESTIONARIO = 'QI_BOLSA'
					
		INNER JOIN LY_APLIC_QUESTIONARIO AQ
				ON AQ.TIPO_QUESTIONARIO	= PQ.TIPO_QUESTIONARIO 
				AND AQ.QUESTIONARIO		= PQ.QUESTIONARIO 
				AND AQ.APLICACAO		= PQ.APLICACAO 

		LEFT JOIN LY_QUESTAO QE 
				ON QE.TIPO_QUESTIONARIO	= AQ.TIPO_QUESTIONARIO 
				AND QE.QUESTIONARIO		= AQ.QUESTIONARIO 
				AND QE.TIPO			= 'BOLSA01'

		LEFT JOIN LY_QUESTAO_APLICADA QA 
				ON QA.TIPO_QUESTIONARIO	= QE.TIPO_QUESTIONARIO 
				AND QA.QUESTIONARIO		= QE.QUESTIONARIO 
				AND QA.QUESTAO			= QE.QUESTAO 
				AND QA.PAR_TIPO_OBJETO	= AV.TIPO_OBJETO 
				AND QA.APLICACAO		= PQ.APLICACAO
				AND QA.PAR_CODIGO		= PQ.CODIGO
				AND QA.PAR_TIPO_OBJETO	= PQ.TIPO_OBJETO

		LEFT JOIN LY_AVALIADO AD 
				ON AD.TIPO_OBJETO	= QA.TIPO_OBJETO 
				AND AD.CODIGO	= QA.CODIGO

		LEFT JOIN LY_RESPOSTA RE 
				ON RE.CODIGO			 = AD.CODIGO
				AND RE.TIPO_OBJETO		 = AD.TIPO_OBJETO
				AND re.AVA_TIPO_OBJETO	 = pq.TIPO_OBJETO
				AND RE.AVA_CODIGO		 = PQ.CODIGO
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
				AND QE.TIPO				 = 'BOLSA01'

		LEFT JOIN LY_CONCEITOS_QUEST QU 
			ON QU.CONCEITO = CO.CONCEITO 
				AND QU.TIPO = CO.TIPO 

		
		UPDATE LY_CANDIDATO
		SET
			OBS = CONVERT(VARCHAR,CA.DT_INSCRICAO,103) + ' - Tem interesse no processo seletivo como aluno pagante? R: ' + RESPOSTA + ' <br> '

		FROM LY_CANDIDATO CA 
			INNER JOIN #tmp_resposta_bolsa TRB
				ON CA.CANDIDATO = TRB.CANDIDATO
		WHERE ca.CANDIDATO = trb.CANDIDATO
		AND CA.OBS IS NULL

		--clean-up
		drop table #tmp_resposta_bolsa
	end

END
GO
