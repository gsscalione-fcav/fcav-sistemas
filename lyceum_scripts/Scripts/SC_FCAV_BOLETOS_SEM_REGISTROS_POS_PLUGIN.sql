select
	* 
from LY_BOLETO
where
DATA_PROC >= '2019-01-11 00:00:00.000' and 
DATA_REGISTRO is null 
