	
CREATE FUNCTION FN_FCAV_Remove_Acento(@Texto varchar(8000))
returns varchar(50)  
AS  
 
BEGIN
         declare @SemAcento varchar(50)  
 
         select @SemAcento = replace(@Texto,'�','a')   
         select @SemAcento = replace(@SemAcento,'�','a')   
         select @SemAcento = replace(@SemAcento,'�','a')   
         select @SemAcento = replace(@SemAcento,'�','a')   
         select @SemAcento = replace(@SemAcento,'�','e')   
         select @SemAcento = replace(@SemAcento,'�','e')   
         select @SemAcento = replace(@SemAcento,'�','e')   
         select @SemAcento = replace(@SemAcento,'�','i')   
         select @SemAcento = replace(@SemAcento,'�','i')   
         select @SemAcento = replace(@SemAcento,'�','i')   
         select @SemAcento = replace(@SemAcento,'�','o')   
         select @SemAcento = replace(@SemAcento,'�','o')   
         select @SemAcento = replace(@SemAcento,'�','o')   
         select @SemAcento = replace(@SemAcento,'�','o')   
         select @SemAcento = replace(@SemAcento,'�','u')   
         select @SemAcento = replace(@SemAcento,'�','u')   
         select @SemAcento = replace(@SemAcento,'�','u')   
         select @SemAcento = replace(@SemAcento,'�','u')   
         select @SemAcento = replace(@SemAcento,'�','c')   
 
         return (UPPER(@SemAcento))  
END


