USE LYCEUM_MEDIA
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Gabriel Scalione
-- Create date: 2020-11-18
-- Description:	Trigger para disponibilizar o link do certificado na página de aviso na Central do Aluno.
-- =============================================
CREATE TRIGGER dbo.TR_FCAV_LINK_CERTIFICADO
   ON  dbo.certificados
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here

	DECLARE @aluno varchar(20),
			@curso varchar(20),
			@turma varchar(20),
			@url_aprovado varchar(255)

	/* Carrega as variáveis */
	SELECT 
		@aluno = ALUNO,
		@curso = CURSO,
		@turma = TURMA,
		@url_aprovado = URL_APROVACAO
	FROM 
		INSERTED

	/*Verifica se o certificado foi liberado. 
	  Se for verdadeiro insere na tabela de Aviso do Lyceum o link do certificado.
	  Se for falso verifica se url_aprovado está vazio e apaga a linha referente ao certificado.*/

	IF @url_aprovado IS NOT NULL 
	BEGIN
		INSERT INTO LYCEUM.DBO.LY_AVISO
		(ALUNO,DTINI,DTFIM,MENSAGEM,CURSO,SERIE,TIPO_AVISO,UNID_RESPONSAVEL,UNID_FISICA,
		 TURNO,CURRICULO,CONCURSO,DATA_INCLUSAO,USUARIO,DESTINO,ORDEM,LOTE,ANEXO_ID)
		VALUES
		(@aluno,CONVERT(DATE,GETDATE(),102),CONVERT(DATE,GETDATE()+500,102),'<p><a href="'+ @url_aprovado +'">Clique aqui para visualizar seu Certificado</a></p>',
		@curso,NULL,'I',NULL,NULL,NULL,NULL,NULL,CONVERT(DATE,GETDATE(),102),'zeus',NULL,NULL,NULL,NULL)	
	END
	ELSE 
	BEGIN
		IF @url_aprovado IS NULL 
		BEGIN
			DELETE LYCEUM.DBO.LY_AVISO WHERE @aluno = ALUNO AND MENSAGEM LIKE '%Clique aqui para visualizar seu Certificado%' 
		END
	END

END
GO
