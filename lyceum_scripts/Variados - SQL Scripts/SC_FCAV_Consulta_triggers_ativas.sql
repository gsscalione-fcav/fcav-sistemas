SELECT name, status = CASE WHEN OBJECTPROPERTY (id, 'ExecIsTriggerDisabled') = 0
    	THEN 'Enabled' ELSE 'Disabled' END,
   owner = OBJECT_NAME (parent_obj)
FROM  sysobjects
WHERE  type = 'TR'
AND
parent_obj = OBJECT_ID ('[LY_PESSOA]')


SELECT
    tbl.NAME, trg.NAME,
    trg.is_disabled,
    status = CASE WHEN trg.is_disabled = 1
    	THEN 'Disabled' ELSE 'Enabled' END
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


update LY_PESSOA 
set 
	E_MAIL = 'gabriel.scalione@vanzolini.org.br' 
where 
	NOME_COMPL like 'Gabriel Serrano Scalione'
	AND isnull(E_MAIL, '') <> ''
	AND ISNULL ((SELECT trg.is_disabled
					FROM
					sys.triggers trg
						INNER JOIN sys.objects tbl
						ON tbl.object_id = trg.parent_id
				WHERE
					tbl.name IN('LY_PESSOA') GROUP BY trg.is_disabled),0) = 1
					
SELECT
					
ISNULL ((SELECT trg.is_disabled
					FROM
					sys.triggers trg
						INNER JOIN sys.objects tbl
						ON tbl.object_id = trg.parent_id
				WHERE
					tbl.name IN('TEMPTABLE_FCAV_CANDIDATO_IMPORTA') GROUP BY trg.is_disabled),0)