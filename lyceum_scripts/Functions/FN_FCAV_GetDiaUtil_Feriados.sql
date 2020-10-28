/*
	utilizado na job do aviso de vencimento da certificação e somente os feriados cadastrados na tabela LY_FERIADO

*/
    
CREATE function dbo.FN_FCAV_GetDiaUtil_Feriados (@DateStartSup smalldatetime , @Dias int)        
RETURNS smalldatetime        
AS        
BEGIN        
 Declare @Start Int        
 Declare @Count Int        
 Declare @DateStart Date    
 Select @DateStart = Dateadd(Day,1,@DateStartSup),  @Count = 0, @Start = 0        
 While @Count < @Dias        
 Begin        
  If  DatePart(WeekDay, @DateStart) Not In (7,1)       
  And @DateStart Not In ( Select DATA from LYCEUM.dbo.LY_FERIADO where TIPO = 'Feriado')        
   Select @Count = @Count + 1        
        
  Select @DateStart = Dateadd(day,1,@DateStart),       
     @Start = @Start + 1        
 End        
 RETURN  DateAdd(day,@Start,@DateStartSup)        
END 