  
CREATE PROCEDURE PROC_GERA_BOLETO      
  @p_Unidade T_CODIGO,          
  @p_Banco T_NUMERO_PEQUENO,          
  @p_Agencia T_ALFASMALL,          
  @p_Conta T_ALFASMALL,          
  @p_Convenio T_CODIGO,          
  @p_Carteira varchar(10),          
  @p_DtVencIni T_DATA,          
  @p_DtVencFim T_DATA,          
  @p_ApenasFaturar varchar(1),          
  @p_RespFinan T_CODIGO = null,          
  @p_AlunoIni T_CODIGO = null,          
  @p_AlunoFim T_CODIGO = null,          
  @p_Curso T_CODIGO = null,          
  @p_TipoCurso T_CODIGO = null,          
  @p_Curriculo T_CODIGO = null,          
  @p_Conj_Aluno T_CODIGO = null,        
  @p_Boleto_Zerado varchar(1) = 'N',        
  @p_Boleto_Negativo varchar(1) = 'N',        
  @p_cobranca_com_nota varchar(1) = 'N',        
  @p_Unidade_Fisica T_CODIGO = null,        
  @p_Apartir_Valor DECIMAL(14,6)=NULL,        
  @p_tipo_cobranca T_NUMERO_PEQUENO = NULL,    
  @p_grupo_divida T_CODIGO = null,    
  @p_depto T_CODIGO = null,          
  @p_online varchar(1) = 'S'    
AS          
-- [INÍCIO]          
BEGIN          
  DECLARE @v_resp as T_CODIGO          
  DECLARE @v_query as varchar(1000)          
  DECLARE @v_contadorperc numeric(16,4)          
  DECLARE @v_percentual T_PERCENTUAL          
  DECLARE @v_lote as T_NUMERO          
  DECLARE @v_Errors varchar(8000)           
  DECLARE @v_ErrosCount INT          
  DECLARE @v_contador_erros T_NUMERO_GRANDE          
  DECLARE @v_contador as T_NUMERO_GRANDE          
  DECLARE @v_C_RESP_FINAN_ROWS as T_NUMERO          
  DECLARE @v_aluno      T_CODIGO          
  DECLARE @v_Error_ID as T_NUMERO          
  DECLARE @v_sessao_id  T_NUMERO          
  DECLARE @v_sessao_id_str varchar(40)          
  DECLARE @v_count      T_NUMERO          
  DECLARE @v_Msg_Refresh varchar(4000)          
  DECLARE @v_dtvenc     T_DATA          
  DECLARE @v_cont_ant   T_NUMERO          
  DECLARE @v_cont_atual T_NUMERO          
  DECLARE @v_straux1 varchar(100)          
  DECLARE @v_straux2 varchar(100)          
  DECLARE @v_straux3 varchar(100)            
  DECLARE @aux_banco varchar (10)          
  DECLARE @v_apenas_faturamento_resp VARCHAR(1)          
  DECLARE @v_apenasfaturar_ant VARCHAR(1)          
  DECLARE @v_chave T_NUMERO        
  DECLARE @v_cobranca T_NUMERO        
  DECLARE @v_tem_cobranca varchar(1)        
    
  DECLARE @v_banco_grupo T_NUMERO_PEQUENO          
  DECLARE @v_agencia_grupo T_ALFASMALL          
  DECLARE @v_conta_grupo T_ALFASMALL          
  DECLARE @v_convenio_grupo T_CODIGO          
  DECLARE @v_boleto_unico VARCHAR(1)          
          
  EXEC tipobanco @aux_banco OUTPUT          
          
  EXECUTE spProcInicia 'PROC_GERA_BOLETO'          
          
 -- ---------------------------------------------------------------------------          
 --    Validação de parâmetros OBRIGATÓRIOS          
 -- ---------------------------------------------------------------------------          
 IF @p_Unidade is NOT null            
    BEGIN           
    SELECT @v_count = isnull(COUNT(*),0)           
    FROM LY_FACULDADE WHERE FACULDADE = @p_Unidade          
    IF @v_count is null or @v_count < 1           
      BEGIN           
               SELECT @v_Errors = 'Unidade inválida: ' + @p_Unidade          
               EXEC SetErro @v_Errors, 'UNIDADE'          
               EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
               GOTO FIM_PROC          
      END          
    END          
  ELSE            
    BEGIN           
      SELECT @v_Errors = 'Unidade não informada'          
      EXEC SetErro @v_Errors, 'UNIDADE'          
      EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
    END          
          
 IF @p_ApenasFaturar is NOT null            
    BEGIN          
      IF @p_ApenasFaturar <> 'S' AND @p_ApenasFaturar <> 'N'          
        BEGIN           
          SELECT @v_Errors = 'Parâmetro Operação inválido: ' + @p_ApenasFaturar          
          EXEC SetErro @v_Errors, 'APENAS FATURAR'          
          EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
          GOTO FIM_PROC          
        END          
    END          
  ELSE            
   BEGIN           
      SELECT @v_Errors = 'Parâmetro Apenas Faturar Cobrança não informado'          
      EXEC SetErro @v_Errors, 'APENAS FATURAR'          
      EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
   END          
          
          
  IF @p_ApenasFaturar = 'N'          
    BEGIN          
      IF @p_Banco is null BEGIN          
          SELECT @v_Errors = 'BANCO não informado'          
          EXEC SetErro @v_Errors, 'BANCO'          
          EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
          GOTO FIM_PROC          
        END           
      ELSE           
        IF @p_Agencia is null BEGIN          
            SELECT @v_Errors = 'AGÊNCIA não informada'          
            EXEC SetErro @v_Errors, 'AGÊNCIA'          
            EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
            GOTO FIM_PROC          
          END          
        ELSE           
          IF @p_Conta is NULL BEGIN          
              SELECT @v_Errors = 'CONTA não informada'          
              EXEC SetErro @v_Errors, 'CONTA'          
              EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
              GOTO FIM_PROC          
            END          
          ELSE           
            IF @p_Carteira is NULL BEGIN          
                SELECT @v_Errors = 'CARTEIRA não informada'          
                EXEC SetErro @v_Errors, 'CARTEIRA'          
                EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
                GOTO FIM_PROC          
              END          
            ELSE BEGIN      
              SELECT @v_count = isnull(COUNT(*),0) FROM LY_CONTA_CONVENIO       
              WHERE BANCO = @p_Banco AND AGENCIA = @p_Agencia AND CONTA_BANCO = @p_Conta AND CONVENIO = @p_Convenio AND CARTEIRA = @p_Carteira AND ATIVO = 'S'      
                    
              IF @v_count is null or @v_count <> 1               
                BEGIN              
                  SET @v_straux1 = CONVERT(VARCHAR(5),@p_Banco)              
                  SELECT @v_Errors = 'CONVÊNIO não relacionado a conta corrente informada ou não ativo: Banco: ' + @v_straux1 + ', Agência: ' + @p_Agencia + ', Conta: ' + @p_Conta + ', Convênio: ' + @p_Convenio + ' e Carteira: ' + @p_Carteira      
                  EXEC SetErro @v_Errors, 'CONVÊNIO'              
                  EXEC spProcLog null, null, null, null, null, null, null, null, null, null              
                  GOTO FIM_PROC              
                END      
                      
              SELECT @v_count = isnull(COUNT(*),0) FROM LY_OPCOES_BOLETO              
              WHERE BANCO = @p_Banco AND AGENCIA = @p_Agencia AND CONTA_BANCO = @p_Conta AND CARTEIRA = @p_Carteira              
                         
              IF @v_count is null or @v_count <> 1               
                BEGIN              
                  SET @v_straux1 = CONVERT(VARCHAR(5),@p_Banco)              
                 SELECT @v_Errors = 'Opções de boleto não cadastrada: Banco: ' + @v_straux1 + ', Agência: ' + @p_Agencia + ', Conta: ' + @p_Conta + ' e Carteira: ' + @p_Carteira              
                  EXEC SetErro @v_Errors, 'CONTA'              
                  EXEC spProcLog null, null, null, null, null, null, null, null, null, null              
                  GOTO FIM_PROC              
                END              
            END       
    END          
          
 IF @p_DtVencIni is null or ISDATE(@p_DtVencIni) <> 1            
    BEGIN           
      SELECT @v_Errors = 'Data de vencimento inicial não informada ou inválida'       
      EXEC SetErro @v_Errors, 'DATA VENC'              
      EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
    END          
          
 IF @p_DtVencFim is null   or ISDATE(@p_DtVencFim) <> 1            
    BEGIN           
      SELECT @v_Errors = 'Data de vencimento final não informada ou inválida'          
      EXEC SetErro @v_Errors, 'DATA VENC'              
 EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
    END          
          
 IF @p_DtVencFim < @p_DtVencIni           
    BEGIN           
      SELECT @v_Errors = 'Data de vencimento final menor que a inicial'          
      EXEC SetErro @v_Errors, 'DATA VENC'              
      EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
    END          
          
          
 -- ---------------------------------------------------------------------------          
 --    Validação de parâmetros  NÃO obrigatórios          
 -- ---------------------------------------------------------------------------          
 IF @p_RespFinan IS NOT NULL          
   BEGIN          
          SELECT @v_count = isnull(COUNT(*),0)            
     FROM LY_RESP_FINAN WHERE RESP = @p_RespFinan          
          IF @v_count is null or @v_count <> 1          
       BEGIN                  
             SELECT @v_Errors = 'Responsavél Financeiro inválido'          
             EXEC SetErro @v_Errors, 'RESP'          
             EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
             GOTO FIM_PROC          
       END          
   END          
           
 IF @p_AlunoIni IS NOT NULL           
 BEGIN          
     SELECT @v_count = isnull(COUNT(*),0)            
     FROM VW_ALUNO WHERE ALUNO = @p_AlunoIni          
     IF @v_count is null or @v_count = 0           
            BEGIN          
         SELECT @v_Errors = 'Aluno inicial inválido: Aluno = ' + @p_AlunoIni          
                EXEC SetErro @v_Errors, 'ALUNO INICIAL'          
                EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
         GOTO FIM_PROC          
     END          
 END          
          
 IF @p_AlunoFim IS NOT NULL          
    BEGIN          
          SELECT @v_count = isnull(COUNT(*),0)           
     FROM VW_ALUNO WHERE ALUNO = @p_AlunoFim          
          IF @v_count is null or @v_count = 0          
             BEGIN          
               SELECT @v_Errors = 'Aluno final inválido: Aluno = ' + @p_AlunoFim           
   EXEC SetErro @v_Errors, 'ALUNO FINAL'          
               EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
               GOTO FIM_PROC          
             END          
     END          
          
 -- * ATENÇÃO: Acrescentar permissões *          
 IF @p_Curso is not NULL          
  BEGIN          
  SELECT @v_count = isnull(COUNT(*),0)           
  FROM VW_CURSO WHERE CURSO = @p_Curso          
  IF @v_count is null or @v_count <> 1           
       BEGIN           
      SELECT @v_Errors = 'Curso inválido: ' + @p_Curso           
                EXEC SetErro @v_Errors, 'CURSO'          
                EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
      END          
  END          
          
 IF @p_Curriculo is not NULL          
  BEGIN          
   SELECT @v_count = isnull(COUNT(*),0)          
   FROM LY_CURRICULO WHERE CURRICULO = @p_Curriculo          
   IF @v_count is null or @v_count <> 1           
     BEGIN           
      SELECT @v_Errors = 'Currículo inválido: ' + @p_Curriculo           
               EXEC SetErro @v_Errors, 'CURRÍCULO'          
               EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
     END          
  END          
          
  IF @p_Conj_Aluno IS NOT NULL        
    BEGIN        
        SELECT @v_count = isnull(COUNT(*),0)        
        FROM LY_CONJ_ALUNO WHERE CONJ_ALUNO = @p_Conj_Aluno        
        
        IF @v_count is null or @v_count = 0           
          BEGIN        
            SELECT @v_Errors = 'Conjunto de Aluno inválido.'        
            exec seterro @v_Errors, 'Conj_Aluno'        
            EXEC spProcLog null, null, null, null, null, null, null, null, null, null        
            GOTO FIM_PROC        
          END        
    END        
        
  IF @p_Boleto_Zerado is NOT null            
    BEGIN          
      IF @p_Boleto_Zerado <> 'S' AND @p_Boleto_Zerado <> 'N'          
        BEGIN           
          SELECT @v_Errors = 'Parâmetro Operação inválido: ' + @p_Boleto_Zerado          
          EXEC SetErro @v_Errors, 'BOLETO ZERADO'          
          EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
          GOTO FIM_PROC          
        END          
    END          
  ELSE            
   BEGIN           
      SELECT @v_Errors = 'Parâmetro Boleto Zerado não informado'          
      EXEC SetErro @v_Errors, 'BOLETO ZERADO'          
      EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
   END          
        
 IF @p_Boleto_Negativo is NOT null            
    BEGIN          
      IF @p_Boleto_negativo <> 'S' AND @p_Boleto_negativo <> 'N'          
        BEGIN           
          SELECT @v_Errors = 'Parâmetro Operação inválido: ' + @p_Boleto_Zerado          
          EXEC SetErro @v_Errors, 'BOLETO NEGATIVO'          
          EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
          GOTO FIM_PROC          
        END          
    END          
  ELSE            
   BEGIN           
      SELECT @v_Errors = 'Parâmetro Boleto Negativo não informado'          
      EXEC SetErro @v_Errors, 'BOLETO NEGATIVO'          
      EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
   END          
        
 IF @p_Unidade_Fisica is not NULL          
  BEGIN          
   SELECT @v_count = isnull(COUNT(*),0)          
   FROM LY_FACULDADE WHERE FACULDADE = @p_Unidade_Fisica          
   IF @v_count is null or @v_count < 1           
     BEGIN           
      SELECT @v_Errors = 'Unidade Física inválida: ' + @p_Unidade_Fisica           
               EXEC SetErro @v_Errors, 'UNIDADE FISICA'          
               EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      GOTO FIM_PROC          
     END          
  END          
          
  IF @p_Apartir_Valor is not NULL          
   BEGIN          
     IF @p_Apartir_Valor = 0        
       BEGIN        
           SELECT @v_Errors = 'O Valor Apartir que o boleto será gerado deve ser maior que 0(zero): ' + @p_Apartir_Valor           
           EXEC SetErro @v_Errors, 'APARTIR DO VALOR'          
           EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
           GOTO FIM_PROC        
       END        
     IF @p_Apartir_Valor < 0        
       BEGIN        
         SELECT @v_Errors = 'O Valor Apartir que o boleto será gerado não deve ser negativo: ' + @p_Apartir_Valor           
         EXEC SetErro @v_Errors, 'APARTIR DO VALOR'          
         EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
         GOTO FIM_PROC        
       END           
   END        
           
  IF @p_tipo_cobranca is not NULL          
    BEGIN          
      IF (@p_tipo_cobranca <> 1) and (@p_tipo_cobranca <> 2 ) and (@p_tipo_cobranca <> 3 ) and (@p_tipo_cobranca <> 4 ) and (@p_tipo_cobranca <> 5 )        
        BEGIN        
           SELECT @v_Errors = 'O tipo de cobrança é inválida'           
           EXEC SetErro @v_Errors, 'TIPO DE COBRANÇA'          
           EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
  GOTO FIM_PROC        
        END                 
    END        
       
  IF @p_grupo_divida is not NULL          
    BEGIN          
       SELECT @v_count = isnull(COUNT(*),0)          
       FROM LY_AGREGA_ITEM_COBRANCA WHERE GRUPO = @p_grupo_divida          
       IF @v_count is null or @v_count = 0    
         BEGIN           
          SELECT @v_Errors = 'Grupo de Dívidas inválido: ' + @p_grupo_divida          
          EXEC SetErro @v_Errors, 'GRUPO'          
          EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
          GOTO FIM_PROC          
         END          
           
       IF @p_ApenasFaturar = 'N'          
  BEGIN     
     SELECT @v_count = isnull(COUNT(*),0)          
     FROM LY_AGREGA_ITEM_COBRANCA     
     WHERE GRUPO = @p_grupo_divida    
     AND BANCO  = @p_Banco    
     AND AGENCIA = @p_Agencia    
     AND CONTA_BANCO = @p_Conta    
     AND CONVENIO = @p_Convenio     
     AND (@p_Carteira IS NULL OR CARTEIRA = @p_Carteira)    
    
    IF @v_count is null or @v_count = 0    
   BEGIN    
     SET @v_straux1 = CONVERT(VARCHAR(5),@p_Banco)    
     SELECT @v_Errors = 'Não existe Grupo de Dívidas para o Banco: ' + @v_straux1 + ' Agencia: ' + @p_Agencia + ' Conta: ' +  @p_Conta + ' Convênio: ' + @p_Convenio    
     EXEC SetErro @v_Errors, 'GRUPO'          
     EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
     GOTO FIM_PROC          
   END                   
  END     
    END    
          
  IF @p_depto is not NULL    
 BEGIN    
     SELECT @v_count = isnull(COUNT(*),0)          
     FROM LY_DEPTO WHERE DEPTO = @p_depto          
     IF @v_count is null or @v_count < 1           
       BEGIN           
        SELECT @v_Errors = 'Departamento inválido: ' + @p_depto           
                 EXEC SetErro @v_Errors, 'DEPTO'          
                 EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
        GOTO FIM_PROC          
       END             
 END     
     
           
  -- -------------------------------------------------------------------------------------          
  --   Seleciona os débitos para os quais deve-se gerar/corrigir a cobrança a partir dos parâmetros          
  -- -------------------------------------------------------------------------------------          
  SELECT @v_contador = 0          
  SELECT @v_contador_erros = 0          
          
  EXEC GET_CONNECT_ID @v_sessao_id output          
  SELECT @v_sessao_id_str = RTRIM(CONVERT(VARCHAR(40),@v_sessao_id)  )        
  SET @v_count = 0          
          
  --zera o contador de boletos gerados          
  DELETE FROM LY_AUX_CONTADOR where SESSAO_ID = @v_sessao_id_str         
  INSERT INTO LY_AUX_CONTADOR (SESSAO_ID, CONTADOR)         
  VALUES (@v_sessao_id_str,0)        
        
-- -------------------------------------------------------------------          
  --  Obtenção do número de lote dos boletos          
  -- -------------------------------------------------------------------          
  EXEC GET_NUMERO 'Lote', '0' , @v_lote OUTPUT          
          
  EXEC GetErrorsCount @v_ErrosCount OUTPUT          
          
  IF @v_ErrosCount  > 0          
    BEGIN          
      select @v_Errors = 'Erro na obtenção do lote de boletos'          
      EXEC SetErro @v_Errors, 'LOTE'          
      EXEC spProcLog null, null, null, null, null, null, null, null, null, null          
      RETURN          
    END          
          
  -- Cria cursor C_RESP_FINAN_PROC_BOLETO DINAMICAMENTE  a partir dos parâmetros          
          
  DECLARE C_RESP_FINAN_PROC_BOLETO CURSOR READ_ONLY FOR           
  SELECT DISTINCT COB.RESP           
  FROM LY_ALUNO ALU, VW_CURSO CUR, LY_COBRANCA COB           
  WHERE COB.ALUNO = ALU.ALUNO AND ALU.CURSO = CUR.CURSO           
    AND CUR.FACULDADE = @p_Unidade           
    AND ((@p_Unidade_Fisica is NOT null AND ALU.UNIDADE_FISICA = @p_Unidade_Fisica) or @p_Unidade_Fisica is null)           
    AND ((@p_RespFinan is NOT null AND COB.RESP = @p_RespFinan) or @p_RespFinan is null)          
    AND ((@p_AlunoIni is NOT null AND ALU.ALUNO >= @p_AlunoIni) or @p_AlunoIni is null)          
    AND ((@p_AlunoFim is not NULL  AND ALU.ALUNO <= @p_AlunoFim) or @p_AlunoFim is null)          
    AND ((@p_Curso is not NULL AND ALU.CURSO = @p_Curso) or @p_Curso is null)    
 AND ((@p_depto is NOT null AND CUR.DEPTO = @p_depto) or @p_depto is null)           
    AND ((@p_TipoCurso is not NULL AND CUR.TIPO = @p_TipoCurso) or @p_TipoCurso is null)             
    AND ((@p_Curriculo is not NULL AND ALU.CURRICULO = @p_Curriculo) or @p_Curriculo is null)         
    AND ((@p_tipo_cobranca is NOT null AND COB.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)            
    AND ((@p_conj_aluno is not NULL AND exists  (SELECT 1 FROM LY_CONJ_ALUNO WHERE ALU.ALUNO = LY_CONJ_ALUNO.ALUNO and  CONJ_ALUNO = @p_conj_aluno )) or @p_conj_aluno is null)                  
    AND ((@p_grupo_divida is not null and EXISTS (SELECT 1 FROM  LY_ITEM_LANC I, LY_LANC_DEBITO D WHERE COB.COBRANCA = I.COBRANCA AND I.LANC_DEB = D.LANC_DEB AND D.GRUPO = @p_grupo_divida)) OR      
         (@p_grupo_divida IS NULL AND EXISTS (SELECT 1 FROM  LY_ITEM_LANC I, LY_LANC_DEBITO D WHERE COB.COBRANCA = I.COBRANCA AND I.LANC_DEB = D.LANC_DEB AND D.GRUPO IS NULL)))      
    AND cob.data_de_vencimento >= @p_dtvencIni         
    AND cob.data_de_vencimento <= @p_DtVencFim        
         
         
  -- -------------------------------------------------------------------          
  --  Geração dos boletos para cada responsável financeiro          
  -- -------------------------------------------------------------------           
          
    OPEN C_RESP_FINAN_PROC_BOLETO          
    SELECT @v_C_RESP_FINAN_ROWS = COUNT(*) FROM        
(  SELECT DISTINCT COB.RESP           
   FROM LY_ALUNO ALU, VW_CURSO CUR, LY_COBRANCA COB           
  WHERE COB.ALUNO = ALU.ALUNO AND ALU.CURSO = CUR.CURSO           
    AND CUR.FACULDADE = @p_Unidade          
    AND ((@p_Unidade_Fisica is NOT null AND ALU.UNIDADE_FISICA = @p_Unidade_Fisica) or @p_Unidade_Fisica is null)           
    AND ((@p_RespFinan is NOT null AND COB.RESP = @p_RespFinan) or @p_RespFinan is null)          
    AND ((@p_AlunoIni is NOT null AND ALU.ALUNO >= @p_AlunoIni) or @p_AlunoIni is null)          
    AND ((@p_AlunoFim is not NULL  AND ALU.ALUNO <= @p_AlunoFim) or @p_AlunoFim is null)          
    AND ((@p_Curso is not NULL AND ALU.CURSO = @p_Curso) or @p_Curso is null)    
 AND ((@p_depto is NOT null AND CUR.DEPTO = @p_depto) or @p_depto is null)            
    AND ((@p_TipoCurso is not NULL AND CUR.TIPO = @p_TipoCurso) or @p_TipoCurso is null)             
    AND ((@p_Curriculo is not NULL AND ALU.CURRICULO = @p_Curriculo) or @p_Curriculo is null)           
    AND ((@p_tipo_cobranca is NOT null AND COB.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)          
    AND ((@p_conj_aluno is not NULL AND exists  (SELECT 1 FROM LY_CONJ_ALUNO WHERE ALU.ALUNO = LY_CONJ_ALUNO.ALUNO and CONJ_ALUNO = @p_conj_aluno )) or @p_conj_aluno is null)                  
    AND ((@p_grupo_divida is not null and EXISTS (SELECT 1 FROM LY_ITEM_LANC I, LY_LANC_DEBITO D WHERE COB.COBRANCA = I.COBRANCA AND I.LANC_DEB = D.LANC_DEB AND D.GRUPO = @p_grupo_divida)) OR      
         (@p_grupo_divida IS NULL AND EXISTS (SELECT 1 FROM LY_ITEM_LANC I, LY_LANC_DEBITO D WHERE COB.COBRANCA = I.COBRANCA AND I.LANC_DEB = D.LANC_DEB AND D.GRUPO IS NULL)))      
    AND cob.data_de_vencimento >= @p_dtvencIni         
    AND cob.data_de_vencimento <= @p_DtVencFim        
) TAUX         
        
    FETCH NEXT FROM C_RESP_FINAN_PROC_BOLETO INTO @v_Resp          
        
 -- Loop no cursor de responsáveis financeiros.           
    WHILE @@FETCH_STATUS = 0           
      BEGIN          
             
        SELECT @v_cont_ant = CONTADOR          
        FROM LY_AUX_CONTADOR          
        WHERE SESSAO_ID = @v_sessao_id_str          
                       
                     
--    SET @v_dtvenc = @p_DtVencIni          
              
--      WHILE @v_dtvenc <= @p_DtVencFim          
--        BEGIN          
              
        BEGIN TRANSACTION NOVO_BOLETO          
        SAVE TRANSACTION NOVO_BOLETO          
                  
        -- Verificação do parâmetro apenas_faturamento do cadastro de responsável financeiro          
        SELECT @v_apenas_faturamento_resp = APENAS_FATURAMENTO,  @v_boleto_unico = isnull(BOLETO_UNICO, 'N')          
        FROM LY_RESP_FINAN          
        WHERE RESP = @v_Resp          
            
        IF @p_ApenasFaturar = 'N' AND  @v_apenas_faturamento_resp = 'S'          
          BEGIN          
            SELECT @v_apenasfaturar_ant = @p_ApenasFaturar          
            SELECT @p_ApenasFaturar = @v_apenas_faturamento_resp              
          END          
            
        -- Limpa e preenche tabela auxiliar de cobrancas        
        -- para não incluir cobranças de alunos que não        
        -- obedeçam os parâmetros informados (curso, etc)...        
        DELETE FROM LY_ITENS_AUX        
        WITH (ROWLOCK)        
        WHERE sessao_id = @v_sessao_id_str        
             
        INSERT INTO LY_ITENS_AUX (sessao_id, chave, cobranca)        
        SELECT @v_sessao_id_str, cobranca, cobranca        
        FROM LY_COBRANCA c, LY_ALUNO a, LY_CURSO cur          
        WHERE c.RESP = @v_resp       
               AND ((cur.FACULDADE = @p_Unidade and  @v_boleto_unico = 'N') OR   @v_boleto_unico = 'S')    
               AND c.aluno = a.aluno        
               AND a.curso = cur.curso         
               AND c.data_de_vencimento >= @p_dtvencIni         
               AND c.data_de_vencimento <= @p_DtVencFim        
               AND ((@p_grupo_divida is not null and EXISTS (SELECT 1 FROM LY_COBRANCA COB, LY_ITEM_LANC I, LY_LANC_DEBITO D WHERE COB.COBRANCA = I.COBRANCA AND I.LANC_DEB = D.LANC_DEB AND c.COBRANCA = COB.COBRANCA  AND D.GRUPO = @p_grupo_divida)) OR    
                    (@p_grupo_divida IS NULL AND EXISTS (SELECT 1 FROM LY_COBRANCA COB, LY_ITEM_LANC I, LY_LANC_DEBITO D WHERE COB.COBRANCA = I.COBRANCA AND I.LANC_DEB = D.LANC_DEB AND c.COBRANCA = COB.COBRANCA AND D.GRUPO IS NULL)))    
               AND (A.ALUNO >= @p_AlunoIni or @p_AlunoIni is null)           
               AND (A.ALUNO <= @p_AlunoFim or @p_AlunoFim is null)           
               AND (A.CURSO = @p_Curso or @p_Curso is null)           
               AND (A.CURRICULO = @p_Curriculo or @p_Curriculo is null)          
               AND ((@p_tipo_cobranca is NOT null AND C.NUM_COBRANCA = @p_tipo_cobranca) or @p_tipo_cobranca is null)    
               AND (exists (SELECT 1 FROM LY_CONJ_ALUNO WHERE A.ALUNO = LY_CONJ_ALUNO.ALUNO and  CONJ_ALUNO = @p_conj_aluno) or @p_conj_aluno is null)                  
               AND (cur.TIPO = @p_TipoCurso or @p_TipoCurso is null)    
               AND (cur.DEPTO = @p_depto or @p_depto is null)             
               AND NOT EXISTS(SELECT 1 FROM LY_ITEM_LANC IL WHERE c.COBRANCA  = IL.COBRANCA AND IL.BOLETO IS NOT NULL)             
               
        SET @v_tem_cobranca = 'S'        
            
        IF @v_tem_cobranca = 'S'        
          BEGIN        
              
              -- Cria cursor com datas de vencimento        
            DECLARE C_DATAVENC CURSOR READ_ONLY FOR           
            SELECT DISTINCT data_de_vencimento           
            FROM LY_ITENS_AUX i, LY_COBRANCA c        
            WHERE sessao_id = @v_sessao_id_str        
            AND i.cobranca = c.cobranca        
                   
            OPEN C_DATAVENC         
            FETCH NEXT FROM C_DATAVENC INTO @v_dtvenc        
            WHILE @@FETCH_STATUS = 0         
              BEGIN        
                EXEC GERA_BOLETO_RESP           
                      @v_sessao_id_str,           
                      @p_Banco,           
                      @p_Agencia,           
                      @p_Conta,           
    @p_Convenio,           
                      @p_Carteira,          
                      @v_Resp,           
                      @p_ApenasFaturar,           
                      @v_DtVenc,           
                      'S',           
                      @v_Lote,           
                      @p_Boleto_Zerado,        
                      @p_Boleto_Negativo,        
                      @p_cobranca_com_nota,        
                      @p_Apartir_Valor,        
                      @p_tipo_cobranca,    
        @p_online       
                EXEC GetErrorsCount @v_ErrosCount OUTPUT          
                FETCH NEXT FROM C_DATAVENC INTO @v_dtvenc        
              END -- loop dt venc        
            CLOSE C_DATAVENC        
            DEALLOCATE C_DATAVENC        
          END -- tinha cobranca        
            
          --Se ocorreu alteração no parâmetro @p_ApenasFaturar devido ao campo apenas_faturamento do resp. finan. voltar ao valor inicial          
        IF @v_apenasfaturar_ant = 'N' AND  @v_apenas_faturamento_resp = 'S'          
          BEGIN          
             SELECT @p_ApenasFaturar = @v_apenasfaturar_ant          
          END          
            
        EXEC GetErrorsCount @v_ErrosCount OUTPUT          
            
        IF @v_ErrosCount  > 0          
          BEGIN          
              EXEC GetErros @v_Errors OUTPUT          
              ROLLBACK TRAN NOVO_BOLETO          
              if @aux_banco = 'SQL'           
              Commit transaction -- pois o rollback até um save point não decrementa a variavel @@trancount   -- pois o rollback até um save point não decrementa a variavel @@trancount            
              -- pois o rollback até um save point não decrementa a variavel @@trancount            
              EXEC SetErro @v_Errors          
              --EXECUTE spProcLog @v_resp, Null, Null, null, null, null, null, null, null, null        
              SELECT @v_contador_erros = @v_contador_erros + 1          
              --BREAK          
          END          
        ELSE          
          BEGIN          
            if @aux_banco = 'SQL'           
              COMMIT TRANSACTION NOVO_BOLETO          
          END          
            
--          SELECT @v_dtvenc = DATEADD(day, 1 , @v_dtvenc)          
--        END          
                
        SELECT  @v_count = CONTADOR          
        FROM LY_AUX_CONTADOR          
        WHERE SESSAO_ID = @v_sessao_id_str          
                  
             
        SELECT @v_contador = @v_contador + 1          
        SELECT @v_contadorperc = @v_contador           
        SELECT @v_percentual = @v_contadorperc / @v_C_RESP_FINAN_ROWS          
        SET @v_straux1 = convert(varchar(10),@v_contador)          
        SET @v_straux2 = convert(varchar(10),@v_C_RESP_FINAN_ROWS)          
        SET @v_straux3 = convert(varchar(10),@v_count)          
        SELECT @v_Msg_Refresh = substring('Processando Resp. Fin.: ' + @v_straux1 + '/' + @v_straux2 + ' - Total de Boletos: ' + @v_straux3 + ' Resp.:' + convert(varchar(10),@v_Resp) ,1,255)                    
        EXECUTE spProcRefresh @v_percentual, @v_Msg_Refresh          
            
--Alterado Paulok          
--inicio          
        begin          
          SELECT @v_count = isnull(COUNT(*),0)            
          FROM ZZCRO_ERROS WITH (ROWLOCK)        
          WHERE SPID = @v_sessao_id          
          IF @v_count = 0          
            BEGIN          
              -- SEM Erros          
              SELECT @v_cont_atual = CONTADOR          
              FROM LY_AUX_CONTADOR          
              WHERE SESSAO_ID = @v_sessao_id_str          
                  
              IF @v_cont_ant <> @v_cont_atual  or @p_ApenasFaturar = 'S'        
                EXECUTE spProcLog @v_resp, Null, Null, null, null, null, null, null, null, null, ' [Sucesso]'          
            END          
          ELSE          
            -- ERROS          
            EXECUTE spProcLog @v_resp, Null, Null, null, null, null, null, null, null, null          
        --          
        END          
--fim          
                
        IF @aux_banco <> 'SQL'         
          COMMIT TRANSACTION        
            
        FETCH NEXT FROM C_RESP_FINAN_PROC_BOLETO INTO @v_resp          
      END          
          
    CLOSE C_RESP_FINAN_PROC_BOLETO          
    DEALLOCATE C_RESP_FINAN_PROC_BOLETO          
          
    SELECT  @v_count = CONTADOR          
    FROM LY_AUX_CONTADOR          
    WHERE SESSAO_ID = @v_sessao_id_str          
          
          
    IF @v_contador_erros > 0          
      BEGIN          
        SET @v_straux1 = convert(varchar(10),@v_contador_erros)          
        SET @v_straux2 = convert(varchar(10),@v_C_RESP_FINAN_ROWS)          
        SET @v_Errors = 'Procedure executada com erros: ' + @v_straux1 + ' dos ' + @v_straux2 + ' responsáveis financeiros selecionados não tiveram boletos gerados.'          
      END          
    ELSE          
      BEGIN          
        SET @v_straux1 = convert(varchar(10), @v_count)          
        SET @v_Errors = 'Geração de boletos e/ou faturamento de cobrança efetuada com sucesso. Número de boletos gerados ou cobranças faturadas: ' + @v_straux1          
      END          
          
FIM_PROC:          
  EXECUTE spProcFinaliza @v_Errors           
  RETURN           
END          
-- [FIM]           