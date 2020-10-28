SELECT
    obj.type_desc, obj.name
FROM
    sys.syscomments txt
        INNER JOIN sys.objects obj
        ON obj.object_id = txt.id
WHERE txt.text LIKE '%Bolsa Concedida na Pr�-matr�cula%'
ORDER BY obj.type_desc, obj.name
