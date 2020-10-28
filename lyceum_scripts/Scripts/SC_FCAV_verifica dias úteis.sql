sp_helptext FN_FCAV_GetDiaUtil


select * from LY_FERIADO where data >= '2019-12-24'

select * from  LYCEUM.dbo.LY_FERIADO where data >= '2019-12-24' and TIPO = 'Feriado'

select LYCEUM.dbo.FN_FCAV_GetDiaUtil(cast('2019-12-24' as datetime)-1,1)
select LYCEUM.dbo.FN_FCAV_GetDiaUtil(getdate()-1,1)
select LYCEUM.dbo.FN_FCAV_GetDiaUtil_Feriados (cast('2019-12-24' as datetime)-1,1)
select LYCEUM.dbo.FN_FCAV_GetDiaUtil_Feriados (getdate()-1,1)