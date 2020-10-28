ALTER VIEW VW_FCAV_INAD_CNPJ AS    
    
--************************************************************    
--* - View criada para exibir o CNPJ dos clientes inadimplentes     
--*   para serem importados no Certiflex.    
--*    
--* - O filtro fixo é para títulos da Certificação "E1_CATIV IN ('401','402','403') e do 800 ao 899"    
--*   e que estejam sem nenhuma baixa a partir de 3 dias atrás.    
--*    
--************************************************************    
SELECT     
 SA1.A1_CGC AS CNPJ    
FROM   SE1010 SE1    
 INNER JOIN  SA1010 SA1 ON SE1.E1_CLIENTE = SA1.A1_COD    
WHERE SE1.D_E_L_E_T_ = ''    
 AND SA1.D_E_L_E_T_ = ''    
 AND (E1_CATIV IN ('401','402','403') OR 
	  E1_CATIV BETWEEN '800' AND '899')   
 AND (E1_BAIXA = '' OR E1_SALDO > 0)  
 AND E1_VENCREA <  DATEADD(DAY,-3,GETDATE())    
 AND E1_PREFIXO <> 'ACO'  
  
GROUP BY    
 SA1.A1_CGC    
    
UNION ALL    
    
SELECT     
 SA1.A1_CGC AS CNPJ    
FROM   SE1010 SE1    
 INNER JOIN  SA1010 SA1 ON SE1.E1_CLIENTE = SA1.A1_COD    
WHERE SE1.D_E_L_E_T_ = ''    
 AND SA1.D_E_L_E_T_ = ''    
 AND (E1_CATIV IN ('401','402','403') OR 
 E1_CATIV BETWEEN '800' AND '899')
 AND (E1_BAIXA = ''  OR E1_SALDO > 0)  
 AND E1_PREFIXO = 'ACO'    
  
GROUP BY    
 SA1.A1_CGC 