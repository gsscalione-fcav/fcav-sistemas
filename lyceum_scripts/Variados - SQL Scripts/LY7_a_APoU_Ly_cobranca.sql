        
ALTER PROCEDURE a_APoU_Ly_cobranca          
    @erro VARCHAR(1024) OUTPUT,      
    @oldCobranca NUMERIC(10), @oldAluno VARCHAR(20), @oldResp VARCHAR(20), @oldAno NUMERIC(4),       
    @oldMes NUMERIC(2), @oldNum_cobranca NUMERIC(3), @oldData_de_vencimento DATETIME,       
    @oldData_de_geracao DATETIME, @oldData_de_faturamento DATETIME, @oldLote NUMERIC(10),       
    @oldApenas_cobranca VARCHAR(1), @oldProtesto VARCHAR(1), @oldUltimo_item NUMERIC(10),       
    @oldUltimo_desc NUMERIC(10), @oldUltimo_encargo NUMERIC(10), @oldData_de_protesto DATETIME,       
    @oldData_canc_protesto DATETIME, @oldIdent_contabil VARCHAR(100), @oldTipo_doc VARCHAR(20),       
    @oldNum_doc VARCHAR(20), @oldDt_geracao_doc DATETIME, @oldDt_emissao_doc DATETIME,       
    @oldGera_doc VARCHAR(1), @oldData_cob_judicial DATETIME, @oldData_canc_cob_jud DATETIME,       
    @oldCobr_judicial VARCHAR(1), @oldCurso VARCHAR(20), @oldTurno VARCHAR(20), @oldCurriculo VARCHAR(20),       
    @oldUnid_fisica VARCHAR(20), @oldData_de_vencimento_orig DATETIME, @oldFl_field_01 VARCHAR(2000),       
    @oldEstorno VARCHAR(1), @oldDt_estorno DATETIME, @oldFl_field_02 VARCHAR(2000), @oldFl_field_03 VARCHAR(2000),       
    @oldFl_field_04 VARCHAR(2000), @oldFl_field_05 VARCHAR(2000), @oldFl_field_06 VARCHAR(2000),       
    @oldFl_field_07 VARCHAR(2000), @oldFl_field_08 VARCHAR(2000), @oldFl_field_09 VARCHAR(2000),       
    @oldFl_field_10 VARCHAR(2000),      
    @oldFl_field_11 VARCHAR(2000), @oldFl_field_12 VARCHAR(2000),         
    @oldFl_field_13 VARCHAR(2000), @oldFl_field_14 VARCHAR(2000), @oldFl_field_15 VARCHAR(2000),         
    @oldFl_field_16 VARCHAR(2000), @oldFl_field_17 VARCHAR(2000), @oldFl_field_18 VARCHAR(2000),         
    @oldFl_field_19 VARCHAR(2000), @oldFl_field_20 VARCHAR(2000),  @oldAr CHAR(1),   
    @cobranca NUMERIC(10), @aluno VARCHAR(20), @resp VARCHAR(20), @ano NUMERIC(4), @mes NUMERIC(2),       
    @num_cobranca NUMERIC(3), @data_de_vencimento DATETIME, @data_de_geracao DATETIME,       
    @data_de_faturamento DATETIME, @lote NUMERIC(10), @apenas_cobranca VARCHAR(1), @protesto VARCHAR(1),       
    @ultimo_item NUMERIC(10), @ultimo_desc NUMERIC(10), @ultimo_encargo NUMERIC(10),       
    @data_de_protesto DATETIME, @data_canc_protesto DATETIME, @ident_contabil VARCHAR(100),       
    @tipo_doc VARCHAR(20), @num_doc VARCHAR(20), @dt_geracao_doc DATETIME, @dt_emissao_doc DATETIME,       
    @gera_doc VARCHAR(1), @data_cob_judicial DATETIME, @data_canc_cob_jud DATETIME, @cobr_judicial VARCHAR(1),       
    @curso VARCHAR(20), @turno VARCHAR(20), @curriculo VARCHAR(20), @unid_fisica VARCHAR(20),       
    @data_de_vencimento_orig DATETIME, @fl_field_01 VARCHAR(2000), @estorno VARCHAR(1),       
    @dt_estorno DATETIME, @fl_field_02 VARCHAR(2000), @fl_field_03 VARCHAR(2000), @fl_field_04 VARCHAR(2000),       
    @fl_field_05 VARCHAR(2000), @fl_field_06 VARCHAR(2000), @fl_field_07 VARCHAR(2000),       
    @fl_field_08 VARCHAR(2000), @fl_field_09 VARCHAR(2000), @fl_field_10 VARCHAR(2000),    
    @fl_field_11 VARCHAR(2000), @fl_field_12 VARCHAR(2000), @fl_field_13 VARCHAR(2000),         
    @fl_field_14 VARCHAR(2000), @fl_field_15 VARCHAR(2000), @fl_field_16 VARCHAR(2000),         
    @fl_field_17 VARCHAR(2000), @fl_field_18 VARCHAR(2000), @fl_field_19 VARCHAR(2000),         
    @fl_field_20 VARCHAR(2000), @ar CHAR(1) OUTPUT    
  AS          
    -- [IN�CIO] Customiza��o - N�o escreva c�digo antes desta linha          
    SET @erro = NULL          
    -- [FIM] Customiza��o - N�o escreva c�digo ap�s esta linha 