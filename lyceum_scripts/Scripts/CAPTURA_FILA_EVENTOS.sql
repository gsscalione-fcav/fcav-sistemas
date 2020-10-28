  
 CREATE PROCEDURE CAPTURA_FILA_EVENTOS  
 @TABELA       VARCHAR(50),  
 @OPERACAO      VARCHAR(1),  
 @CHAVE_OBJETO_1    VARCHAR(50),  
 @CHAVE_OBJETO_2    VARCHAR(50),  
 @CHAVE_OBJETO_3    VARCHAR(50),  
 @CHAVE_OBJETO_4    VARCHAR(50),  
 @CHAVE_OBJETO_5    VARCHAR(50),  
 @CHAVE_OBJETO_6    VARCHAR(50),  
 @CHAVE_OBJETO_7    VARCHAR(50),  
 @CHAVE_OBJETO_8    VARCHAR(50),  
 @CHAVE_OBJETO_9    VARCHAR(50),  
 @CHAVE_OBJETO_10   VARCHAR(50)  
AS  
BEGIN  
 DECLARE @SUBSTITUI   VARCHAR(1)  
 SET @SUBSTITUI = 'N'  
  
  EXEC s_CAPTURA_FILA_EVENTOS @TABELA, @OPERACAO, @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4, @CHAVE_OBJETO_5, @CHAVE_OBJETO_6, @CHAVE_OBJETO_7, @CHAVE_OBJETO_8, @CHAVE_OBJETO_9, @CHAVE_OBJETO_10, @SUBSTITUI OUTPUT  
  
  IF (@SUBSTITUI = 'N')  
 BEGIN  
  -- Variaveis  
  DECLARE @SISTEMA_DESTINO  VARCHAR(50)  
  DECLARE @ACAO     VARCHAR(30)  
  DECLARE @OBJETO    VARCHAR(100)  
  
   -- Verifica se precisa adicionar na fila de integração  
  IF EXISTS(SELECT TOP 1 1 FROM LY_SISTEMA_DESTINO_INTEGRACAO)  
  BEGIN  
   -- Cria o cursor para percorrer todas as operacoes e objetos da integracao  
   DECLARE db_cursor_integracao CURSOR FOR   
   SELECT SIS.SISTEMA_DESTINO,  
     OBJ.OPERACAO,  
     OBJ.OBJETO  
   FROM LY_OBJETOS_SISTEMA_DESTINO OBJ  
   INNER JOIN LY_SISTEMA_DESTINO_INTEGRACAO SIS  
    ON OBJ.ID_SISTEMA_DESTINO = SIS.ID_SISTEMA_DESTINO  
   WHERE OBJ.HABILITADO = 'S'  
    AND TABELA_LYCEUM = @TABELA  
  
    OPEN db_cursor_integracao    
   FETCH NEXT FROM db_cursor_integracao INTO @SISTEMA_DESTINO, @ACAO, @OBJETO    
  
    WHILE @@FETCH_STATUS = 0    
   BEGIN    
    IF @ACAO = 'INSERT' AND @OPERACAO = 'I'  
    BEGIN  
     EXEC s_CANCELA_CAPTURA_FILA_EVENTOS @SISTEMA_DESTINO, @OBJETO, @TABELA, @OPERACAO, @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4, @CHAVE_OBJETO_5, @CHAVE_OBJETO_6, @CHAVE_OBJETO_7, @CHAVE_OBJETO_8, @CHAVE_OBJETO_9, @CHAVE_OBJETO_10, @SUBSTITUI OUTPUT  
  
      IF (@SUBSTITUI = 'N')  
     BEGIN  
      INSERT INTO LY_INTEGRACAO_FILA_EVENTOS (DATA_INCLUSAO, SISTEMA_DESTINO, OBJETO, OPERACAO, CHAVE_1, CHAVE_2, CHAVE_3, CHAVE_4, CHAVE_5, CHAVE_6, CHAVE_7, CHAVE_8, CHAVE_9, CHAVE_10)  
      VALUES (GETDATE(), @SISTEMA_DESTINO, @OBJETO, 'I', @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4, @CHAVE_OBJETO_5, @CHAVE_OBJETO_6, @CHAVE_OBJETO_7, @CHAVE_OBJETO_8, @CHAVE_OBJETO_9, @CHAVE_OBJETO_10)  
     END  
    END  
    ELSE IF @ACAO = 'UPDATE' AND @OPERACAO = 'U'  
    BEGIN  
     EXEC s_CANCELA_CAPTURA_FILA_EVENTOS @SISTEMA_DESTINO, @OBJETO, @TABELA, @OPERACAO, @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4, @CHAVE_OBJETO_5, @CHAVE_OBJETO_6, @CHAVE_OBJETO_7, @CHAVE_OBJETO_8, @CHAVE_OBJETO_9, @CHAVE_OBJETO_10, @SUBSTITUI OUTPUT  
  
      IF (@SUBSTITUI = 'N')  
     BEGIN  
      INSERT INTO LY_INTEGRACAO_FILA_EVENTOS (DATA_INCLUSAO, SISTEMA_DESTINO, OBJETO, OPERACAO, CHAVE_1, CHAVE_2, CHAVE_3, CHAVE_4, CHAVE_5, CHAVE_6, CHAVE_7, CHAVE_8, CHAVE_9, CHAVE_10)  
      VALUES (GETDATE(), @SISTEMA_DESTINO, @OBJETO, 'U', @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4, @CHAVE_OBJETO_5, @CHAVE_OBJETO_6, @CHAVE_OBJETO_7, @CHAVE_OBJETO_8, @CHAVE_OBJETO_9, @CHAVE_OBJETO_10)  
     END  
    END  
    ELSE IF @ACAO = 'DELETE' AND @OPERACAO = 'D'  
    BEGIN  
     EXEC s_CANCELA_CAPTURA_FILA_EVENTOS @SISTEMA_DESTINO, @OBJETO, @TABELA, @OPERACAO, @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4, @CHAVE_OBJETO_5, @CHAVE_OBJETO_6, @CHAVE_OBJETO_7, @CHAVE_OBJETO_8, @CHAVE_OBJETO_9, @CHAVE_OBJETO_10, @SUBSTITUI OUTPUT  
       
     IF (@SUBSTITUI = 'N')  
     BEGIN  
      INSERT INTO LY_INTEGRACAO_FILA_EVENTOS (DATA_INCLUSAO, SISTEMA_DESTINO, OBJETO, OPERACAO, CHAVE_1, CHAVE_2, CHAVE_3, CHAVE_4, CHAVE_5, CHAVE_6, CHAVE_7, CHAVE_8, CHAVE_9, CHAVE_10)  
      VALUES (GETDATE(), @SISTEMA_DESTINO, @OBJETO, 'D', @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4, @CHAVE_OBJETO_5, @CHAVE_OBJETO_6, @CHAVE_OBJETO_7, @CHAVE_OBJETO_8, @CHAVE_OBJETO_9, @CHAVE_OBJETO_10)  
     END  
    END  
      
    FETCH NEXT FROM db_cursor_integracao INTO @SISTEMA_DESTINO, @ACAO, @OBJETO   
   END   
  
    CLOSE db_cursor_integracao    
   DEALLOCATE db_cursor_integracao   
  END  
 END  
END  