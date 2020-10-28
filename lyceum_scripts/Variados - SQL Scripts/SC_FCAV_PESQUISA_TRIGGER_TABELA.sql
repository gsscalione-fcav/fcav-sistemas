

SELECT trg.name, trg.is_disabled, trg.is_instead_of_trigger
FROM
    sys.triggers trg
        INNER JOIN sys.objects obj
        ON obj.object_id = trg.parent_id
WHERE obj.name = 'LY_CANDIDATO'