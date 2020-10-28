	
CREATE FUNCTION FN_FCAV_Remove_Acento(@Texto varchar(8000))
returns varchar(50)  
AS  
 
BEGIN
         declare @SemAcento varchar(50)  
 
         select @SemAcento = replace(@Texto,'á','a')   
         select @SemAcento = replace(@SemAcento,'à','a')   
         select @SemAcento = replace(@SemAcento,'ã','a')   
         select @SemAcento = replace(@SemAcento,'â','a')   
         select @SemAcento = replace(@SemAcento,'é','e')   
         select @SemAcento = replace(@SemAcento,'è','e')   
         select @SemAcento = replace(@SemAcento,'ê','e')   
         select @SemAcento = replace(@SemAcento,'í','i')   
         select @SemAcento = replace(@SemAcento,'ì','i')   
         select @SemAcento = replace(@SemAcento,'î','i')   
         select @SemAcento = replace(@SemAcento,'ó','o')   
         select @SemAcento = replace(@SemAcento,'ò','o')   
         select @SemAcento = replace(@SemAcento,'ô','o')   
         select @SemAcento = replace(@SemAcento,'õ','o')   
         select @SemAcento = replace(@SemAcento,'ú','u')   
         select @SemAcento = replace(@SemAcento,'ù','u')   
         select @SemAcento = replace(@SemAcento,'û','u')   
         select @SemAcento = replace(@SemAcento,'ü','u')   
         select @SemAcento = replace(@SemAcento,'ç','c')   
 
         return (UPPER(@SemAcento))  
END


