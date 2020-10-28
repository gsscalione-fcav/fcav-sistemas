-- --------------------------------------------------
-- TABLE: LY_BLOCO_INSC_OFERTA_CURSO
---- --------------------------------------------------

UPDATE LY_BLOCO_INSC_OFERTA_CURSO WHERE	ID_BLOCO_INSC_ONLINE = 6
SET
	OPCIONAL = NULL -- N para deixar o upload obrigatório
WHERE
	ID_BLOCO_INSC_ONLINE = 6


	select * from LY_BLOCO_INSC_OFERTA_CURSO WHERE	ID_BLOCO_INSC_ONLINE = 6 and OFERTA_DE_CURSO in (2022)