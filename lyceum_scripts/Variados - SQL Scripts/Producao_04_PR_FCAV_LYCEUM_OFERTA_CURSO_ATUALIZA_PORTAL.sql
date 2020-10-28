  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
--  
-- Em produção, alterar o código de inicialização de @DESTINATARIO e  
-- @encaminha_email e a chamada a SP_SEND_DBMAIL  
--  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
  
--* ***************************************************************  
--*  
--*   *** PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_ATUALIZA_PORTAL ***  
--*   
--* USO:   
--*     Chamada via interface do LyceumNG, transação TVEST040D  
--*     Botão 'Atuallizar os dados do Portal'  
--*  
--* Histórico  
--*  
--*     13/03/2017 - Código removido de TR_FCAV_ENVIO_FORMULARIO  
--*   
--* ***************************************************************  
  
ALTER PROCEDURE dbo.PR_FCAV_LYCEUM_OFERTA_CURSO_ATUALIZA_PORTAL(  
    @OFERTA_DE_CURSO INT, @txtAtualizaPortal varchar  
)  
AS  
BEGIN  
    DECLARE @TURMA T_CODIGO  
  
    SELECT @TURMA = vw_cur_tur.TURMA  
    FROM VW_FCAV_INI_FIM_CURSO_TURMA vw_cur_tur /* TURMA em LY_OFERTA_CURSO não é preenchida */  
    WHERE vw_cur_tur.OFERTA_DE_CURSO = @OFERTA_DE_CURSO  
  
    DECLARE @assunto VARCHAR(100)  
    DECLARE @destinatario VARCHAR(200)  
    DECLARE @encaminha_email VARCHAR(200)  
    DECLARE @texto VARCHAR(8000)  
  
    DECLARE @OBJETIVOS VARCHAR (MAX)  
    DECLARE @PROGRAMA VARCHAR (MAX)  
    DECLARE @PUBLICO VARCHAR (MAX)  
    DECLARE @CORPO_DOC VARCHAR (MAX)  
    DECLARE @INVEST VARCHAR (MAX)  
    DECLARE @APRESENTACAO VARCHAR (MAX)  
    DECLARE @DIFERENCIAL VARCHAR (MAX)  
    DECLARE @PERFIL VARCHAR (MAX)  
    DECLARE @CERTIFIC VARCHAR (MAX)  
    DECLARE @METODOLOGIA VARCHAR (MAX)  
    DECLARE @SISTEMA_AVAL VARCHAR (MAX)  
    DECLARE @PROC_SELET VARCHAR (MAX)  
    DECLARE @VALOR VARCHAR (20)  
    DECLARE @DATA_INI_TURMA VARCHAR(10)  
    DECLARE @DATA_FIM_TURMA VARCHAR(10)  
    DECLARE @DATA_INI_OFERTA VARCHAR(10)  
    DECLARE @DATA_FIM_OFERTA VARCHAR(10)  
    DECLARE @SIT_TURMA VARCHAR (15)  
  
    SET @OBJETIVOS = NULL  
    SET @PROGRAMA = NULL  
    SET @PUBLICO = NULL  
    SET @CORPO_DOC = NULL  
    SET @INVEST = NULL  
    SET @APRESENTACAO = NULL  
    SET @DIFERENCIAL = NULL  
    SET @PERFIL = NULL  
    SET @CERTIFIC = NULL  
    SET @METODOLOGIA = NULL  
    SET @SISTEMA_AVAL = NULL  
    SET @PROC_SELET = NULL  
    SET @VALOR = NULL  
    SET @DATA_INI_TURMA = NULL  
    SET @DATA_FIM_TURMA = NULL  
    SET @DATA_INI_OFERTA = NULL  
    SET @DATA_FIM_OFERTA = NULL  
    SET @SIT_TURMA = NULL  
  
 IF @txtAtualizaPortal = 'S' AND @OFERTA_DE_CURSO IS NOT NULL  
 BEGIN  
   
  SET @txtAtualizaPortal = 'N'  
   
  SET @ASSUNTO =  'Dados do portal atualizados. TURMA: ' + @TURMA  
  
  -------------------------------------------------------------  
  
  SELECT @DESTINATARIO =  
    -- Desenvolvimento/homologação  
    --'joao.neves@vanzolini.org.br; gabriel.scalione@vanzolini.org.br; mvaraujo@vanzolini-ead.org.br; ecampos@vanzolini-ead.org.br'  
  
    -- Produção  
    'maiara.souza@vanzolini.org.br; monica.pereira@vanzolini.org.br'  
  -------------------------------------------------------------  
  
  SELECT @encaminha_email =  
    -- Desenvolvimento/homologação  
    --'joao.neves@vanzolini.org.br; gabriel.scalione@vanzolini.org.br; mvaraujo@vanzolini-ead.org.br; ecampos@vanzolini-ead.org.br'  
  
    -- Produção  
    CASE  
     WHEN FACULDADE = 'USP'  
            THEN 'secretariausp@vanzolini.org.br'  
        WHEN UNIDADE_RESPONSAVEL = 'ATUAL' AND FACULDADE = 'Paulista'  
            THEN 'mayla.alencar@vanzolini.org.br; elivana.moura@vanzolini.org.br'   
        WHEN (UNIDADE_RESPONSAVEL = 'CAPAC' OR UNIDADE_RESPONSAVEL = 'ESPEC') AND FACULDADE = 'Paulista'  
            THEN 'adriana.pereira@vanzolini.org.br; elivana.moura@vanzolini.org.br'    
    END  
  FROM LY_TURMA  
  WHERE TURMA = @turma  
       
  -------------------------------------------------------------  
  
  SELECT  
   @OBJETIVOS = CASE WHEN V.OBJETIVOS = ISNULL(T.OBJETIVOS,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @PROGRAMA = CASE WHEN V.PROGRAMA = ISNULL(T.PROGRAMA,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @PUBLICO = CASE WHEN V.PUBLICO_ALVO = ISNULL(T.PUBLICO_ALVO,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @CORPO_DOC = CASE WHEN V.CORPO_DOCENTE = ISNULL(T.CORPO_DOCENTE,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @INVEST = CASE WHEN V.INVESTIMENTO = ISNULL(T.INVESTIMENTO,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @APRESENTACAO = CASE WHEN V.APRESENTACAO_CURSO = ISNULL(T.APRESENTACAO_CURSO,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @DIFERENCIAL = CASE WHEN V.DIFERENCIAL = ISNULL(T.DIFERENCIAL,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @PERFIL = CASE WHEN V.PERFIL_ALUNO = ISNULL(T.PERFIL_ALUNO,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @CERTIFIC = CASE WHEN V.CERTIFICACAO = ISNULL(T.CERTIFICACAO,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @METODOLOGIA = CASE WHEN V.METODOLOGIA = ISNULL(T.METODOLOGIA,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @SISTEMA_AVAL = CASE WHEN V.SISTEMA_AVALIACAO = ISNULL(T.SISTEMA_AVALIACAO,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @PROC_SELET = CASE WHEN V.PROCESSO_SELETIVO = ISNULL(T.PROCESSO_SELETIVO,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @VALOR = CASE WHEN V.VALOR_CURSO = ISNULL(T.VALOR_CURSO,'...') THEN 'OK' ELSE 'ALTERADO' END,  
   @DATA_INI_TURMA = CASE WHEN V.DT_INICIO = T.DT_INICIO THEN 'OK' ELSE 'ALTERADO' END,  
   @DATA_FIM_TURMA = CASE WHEN V.DT_FIM = T.DT_FIM THEN 'OK' ELSE 'ALTERADO' END,  
   @DATA_INI_OFERTA = CASE WHEN V.DTINI_OFERTA = T.DTINI_OFERTA THEN 'OK' ELSE 'ALTERADO' END,  
   @DATA_FIM_OFERTA = CASE WHEN V.DTFIM_OFERTA = T.DTFIM_OFERTA THEN 'OK' ELSE 'ALTERADO' END,  
   @SIT_TURMA = CASE WHEN V.SIT_TURMA = ISNULL(T.SIT_TURMA,'...') THEN 'OK' ELSE 'ALTERADO' END  
  FROM   
   VW_FCAV_INFO_CURSO_PORTAL2 V  
    INNER JOIN FCAV_INFO_CURSO_PORTAL2 T ON (V.TURMA = T.TURMA AND V.CURSO = T.CURSO AND V.CURRICULO = T.CURRICULO AND V.DISCIPLINA = T.DISCIPLINA AND ISNULL(V.DOCENTE,'0000') = ISNULL(T.DOCENTE,'0000') AND V.PERIODO = T.PERIODO)  
  WHERE T.TURMA_PREF = @TURMA  
  -------------------------------------------------------------  
  
  SELECT  
   @TEXTO =  
    CASE  
     WHEN ISNULL((SELECT DISTINCT 1 FROM FCAV_INFO_CURSO_PORTAL2 WHERE TURMA_PREF = @TURMA),'0') = 1 THEN (  
      SELECT  'Foi feita atualização dos dados de uma turma para portal da Fundação.  
      <BR>  
      <BR>  
      <ul>  
      <li> Turma:  <b>'+@TURMA+'</b>  
      <li> Objetivos: '+@OBJETIVOS+'  
      <li> Programa: '+@PROGRAMA+'  
      <li> Público Alvo: '+@PUBLICO+'  
      <li> Corpo Docente: '+@CORPO_DOC+'  
      <li> Investimento: '+@INVEST+'  
      <li> Apresentação: '+@APRESENTACAO+'  
      <li> Diferencial: '+@DIFERENCIAL+'  
      <li> Perfil: '+@PERFIL+'  
      <li> Certificação: '+@CERTIFIC+'  
      <li> Metodologia: '+@METODOLOGIA+'  
      <li> Sistema Avaliação: '+@SISTEMA_AVAL+'  
      <li> Processo Seletivo: '+@PROC_SELET+'  
      <li> Valor do Curso: '+@VALOR+'  
      <li> Data início Turma: '+@DATA_INI_TURMA+'  
      <li> Data fim Turma: '+@DATA_FIM_TURMA+'  
      <li> Data início Oferta: '+@DATA_INI_OFERTA+'  
      <li> Data fim Oferta: '+@DATA_FIM_OFERTA+'  
      <li> Situação da Turma: '+@SIT_TURMA+'  
      </ul>  
      <BR> ')  
     ELSE  
      (SELECT 'Nova turma cadastrada.<BR>Código: '+@TURMA + '<BR>')  
     END  
   -------------------------------------------------------------  
  
  EXEC  
   MSDB.dbo.SP_SEND_DBMAIL  
    @PROFILE_NAME =  
     -- Desenvolvimento/homologação  
     --FCAV_HOMOLOGACAO,  
     -- Produção  
     VANZOLINI_BD,  
    @RECIPIENTS = @DESTINATARIO,  
    @copy_recipients = @encaminha_email,  
    @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',  
    @SUBJECT = @assunto,  
    @BODY = @TEXTO,  
    @BODY_FORMAT = HTML  
  
  -- *** UPDATE PARA ATUALIZAR A TABELA QUE MANDA AS INFORMAÇÕES DAS TURMAS PARA O PORTAL  
  -- *** INICIO  
  DELETE FCAV_INFO_CURSO_PORTAL2 WHERE TURMA = @TURMA  
  
  ALTER TABLE FCAV_INFO_CURSO_PORTAL2  
  DROP COLUMN [SEQUENCIAL]  
  
  INSERT FCAV_INFO_CURSO_PORTAL2  
  SELECT *, NULL AS DT_IMPORT FROM VW_FCAV_INFO_CURSO_PORTAL2  
  WHERE TURMA = @TURMA  
  
  ALTER TABLE FCAV_INFO_CURSO_PORTAL2  
  ADD [SEQUENCIAL] [int] IDENTITY (1, 1) NOT NULL  
 END  
 --------------------------------------------------------------------------  
 --condições para retornar o valor na grid oculta da tela da oferta do NG, NÃO REMOVER. Gabriel  
 IF @txtAtualizaPortal = 'N'  
 BEGIN  
  SELECT 5 AS VALOR  
 END  
 ELSE  
 BEGIN  
  SELECT 3 AS VALOR  
 END  
 --------------------------------------------------------------------------   
END  