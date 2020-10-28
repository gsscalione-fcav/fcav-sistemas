/*
	TRIGGER TR_FCAV_REMOVE_EMAIL
	
	Descrição: Trigger para remover o e-mail de compra de curso nativo do Lyceum

	Autor: Gabriel S. Scalione
	Data: 21/03/2017
*/


ALTER TRIGGER TR_FCAV_REMOVE_EMAIL
ON LY_EMAIL_LOTE_DEST
FOR INSERT
AS
BEGIN
    DECLARE @v_id T_NUMERO
    DECLARE @v_assunto T_ALFALARGE
    DECLARE @v_nome_remetente T_ALFAMEDIUM

    SELECT
        @v_id = EL.ID_EMAIL_LOTE,
        @v_assunto = EL.assunto,
        @v_nome_remetente = EL.NOME_REMETENTE
    FROM inserted AS LD
    JOIN LY_EMAIL_LOTE AS EL
        ON LD.ID_EMAIL_LOTE = EL.ID_EMAIL_LOTE

    IF @v_assunto = 'Contato' and @v_nome_remetente = 'remetente_email_loja'
    BEGIN
        DELETE FROM LY_EMAIL_LOTE_DEST
        WHERE ID_EMAIL_LOTE = @v_id
        DELETE FROM LY_EMAIL_LOTE
        WHERE ID_EMAIL_LOTE = @v_id
    END
END
GO

