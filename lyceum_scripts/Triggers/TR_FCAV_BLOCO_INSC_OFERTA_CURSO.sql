--* ***************************************************************
--*
--*		*** TRIGGER TR_FCAV_BLOCO_INSC_OFERTA_CURSO  ***
--*	
--*	Finalidade: Verificar se na linha do curriculo (ID_BLOCO_INSC_ONLINE = 6 ), o campo OPCIONAL 
--*				está vazio, caso esteja ele irá setar para 'N'. Esse campo não pode ficar nulo.
--*
--*	ALTERAÇÕES:
--*
--*    Autor: Gabriel Serrano Scalione
--*	   Data de criação: 21/09/2018
--*	
--* ***************************************************************

ALTER TRIGGER [dbo].[TR_FCAV_BLOCO_INSC_OFERTA_CURSO]
  ON [dbo].[LY_BLOCO_INSC_OFERTA_CURSO]
	AFTER INSERT
AS
  SET NOCOUNT ON
	
	UPDATE LY_BLOCO_INSC_OFERTA_CURSO SET OPCIONAL = 'N'
	FROM LY_BLOCO_INSC_OFERTA_CURSO B JOIN inserted I
		ON B.ID_BLOCO_INSC_OFERTA_CURSO = I.ID_BLOCO_INSC_OFERTA_CURSO AND B.OFERTA_DE_CURSO = I.OFERTA_DE_CURSO
	WHERE B.OPCIONAL IS NULL
	AND B.ID_BLOCO_INSC_ONLINE = 6
	
  SET NOCOUNT OFF