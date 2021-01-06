------------------------------------------------------------------
-- Gerador de Senhas
------------------------------------------------------------------
declare @numero varchar(max) = '1234567890'
declare @tamanho int = 6

;with cte as (
    select
        1 as contador,
        substring(@numero, 1 + (abs(checksum(newid())) % len(@numero)), 1) as numero
    union all
    select
        contador + 1,
        substring(@numero, 1 + (abs(checksum(newid())) % len(@numero)), 1)
    from cte where contador < @tamanho)
--select * from cte option (maxrecursion 0)
select (
    select '' + numero from cte
    for xml path(''), type, root('txt')
    ).value ('/txt[1]', 'varchar(max)')
option (maxrecursion 0) 



---------------------------------------------------------
-- Ou
---------------------------------------------------------

select 	concat(replicate('0',cast(6-len(cast(RAND()*1000000 as int)) as varchar)),cast(cast(RAND()*1000000 as int) as varchar)) SENHA_GERADA
