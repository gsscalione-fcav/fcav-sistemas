
SELECT
    tbl.NAME, trg.NAME,
    'disable trigger [' + trg.name + '] on [' + tbl.name + ']'
FROM
    sys.triggers trg
        INNER JOIN sys.objects tbl
        ON tbl.object_id = trg.parent_id
WHERE
    tbl.name IN(
        'FCAV_EMAIL_AUX', 'FCAV_WEBUSERS', 'LY_CANDIDATO', 'LY_EMAIL_LOTE_DEST', 'LY_EMAILS_BATCH',
        'LY_ENVIO_EMAIL', 'LY_MANTENEDORA', 'LY_OFERTA_CURSO_INTERESSE', 'LY_OPCOES', 'LY_REMETENTE_EMAIL',
        'TEMPTABLE_FCAV_CANDIDATO_IMPORTA', 'LY_PESSOA', 'LY_DOCENTE', 'LY_UNIDADE_FISICA'
    )
ORDER BY tbl.NAME, trg.name

--E as queries que desabilitam as triggers são:
disable trigger [CRO_Ly_candidato_Delete] on [LY_CANDIDATO]
disable trigger [CRO_Ly_candidato_Insert] on [LY_CANDIDATO]
disable trigger [CRO_Ly_candidato_Update] on [LY_CANDIDATO]
disable trigger [TR_FCAV_LY_CANDIDATO_INS_UPD] on [LY_CANDIDATO]
disable trigger [CRO_Ly_docente_Delete] on [LY_DOCENTE]
disable trigger [CRO_Ly_docente_Insert] on [LY_DOCENTE]
disable trigger [CRO_Ly_docente_Update] on [LY_DOCENTE]
disable trigger [TR_FCAV_REMOVE_EMAIL] on [LY_EMAIL_LOTE_DEST]
disable trigger [CRO_Ly_envio_email_Delete] on [LY_ENVIO_EMAIL]
disable trigger [CRO_Ly_envio_email_Insert] on [LY_ENVIO_EMAIL]
disable trigger [CRO_Ly_envio_email_Update] on [LY_ENVIO_EMAIL]
disable trigger [CRO_Ly_mantenedora_Delete] on [LY_MANTENEDORA]
disable trigger [CRO_Ly_mantenedora_Insert] on [LY_MANTENEDORA]
disable trigger [CRO_Ly_mantenedora_Update] on [LY_MANTENEDORA]
disable trigger [CRO_Ly_oferta_curso_interesse_Delete] on [LY_OFERTA_CURSO_INTERESSE]
disable trigger [CRO_Ly_oferta_curso_interesse_Insert] on [LY_OFERTA_CURSO_INTERESSE]
disable trigger [CRO_Ly_oferta_curso_interesse_Update] on [LY_OFERTA_CURSO_INTERESSE]
disable trigger [CRO_Ly_opcoes_Delete] on [LY_OPCOES]
disable trigger [CRO_Ly_opcoes_Insert] on [LY_OPCOES]
disable trigger [CRO_Ly_opcoes_Update] on [LY_OPCOES]
disable trigger [CRO_Ly_pessoa_Delete] on [LY_PESSOA]
disable trigger [CRO_Ly_pessoa_Insert] on [LY_PESSOA]
disable trigger [CRO_Ly_pessoa_Update] on [LY_PESSOA]
disable trigger [TR_FCAV_PRIMEIRA_MAIUSCULA_PESSOA] on [LY_PESSOA]
disable trigger [CRO_Ly_remetente_email_Delete] on [LY_REMETENTE_EMAIL]
disable trigger [CRO_Ly_remetente_email_Insert] on [LY_REMETENTE_EMAIL]
disable trigger [CRO_Ly_remetente_email_Update] on [LY_REMETENTE_EMAIL]
disable trigger [CRO_Ly_unidade_fisica_Delete] on [LY_UNIDADE_FISICA]
disable trigger [CRO_Ly_unidade_fisica_Insert] on [LY_UNIDADE_FISICA]
disable trigger [CRO_Ly_unidade_fisica_Update] on [LY_UNIDADE_FISICA]