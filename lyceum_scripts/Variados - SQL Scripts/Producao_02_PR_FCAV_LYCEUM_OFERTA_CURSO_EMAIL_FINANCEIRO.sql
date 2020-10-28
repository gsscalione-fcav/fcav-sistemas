  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
--  
-- Em produ��o, alterar o c�digo de inicializa��o de @DESTINATARIO e  
-- @encaminha_email e a chamada a SP_SEND_DBMAIL  
--  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
  
--* ***************************************************************  
--*  
--*   *** PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_FINANCEIRO ***  
--*   
--* USO:   
--*     Chamada via interface do LyceumNG, transa��o TVEST040D  
--*     Bot�o 'Enviar formul�rio para o financeiro'  
--*  
--* Hist�rico  
--*  
--*     13/03/2017 - C�digo removido de TR_FCAV_ENVIO_FORMULARIO  
--*   
--* ***************************************************************  
  
ALTER PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_FINANCEIRO(  
    @OFERTA_DE_CURSO INT, @txtEnviarFinan varchar  
)  
AS  
SET NOCOUNT ON  
BEGIN  
    DECLARE @turma VARCHAR(20)  
    DECLARE @curriculo VARCHAR(20)  
    DECLARE @turno VARCHAR(20)  
    DECLARE @centro_custo VARCHAR(20)  
    DECLARE @inicio_curso VARCHAR(30)  
    DECLARE @oferta_curso varchar(200)  
  
    DECLARE @assunto VARCHAR(100)  
    DECLARE @destinatario VARCHAR(200)  
    DECLARE @encaminha_email VARCHAR(200)  
    DECLARE @telefone VARCHAR(200)  
    DECLARE @texto VARCHAR(8000)  
  
    DECLARE @valor_total VARCHAR(2000)  
    DECLARE @taxa_matricula VARCHAR(2000)  
    DECLARE @valor_parcela VARCHAR(2000)  
    DECLARE @qtde_parcela VARCHAR(2000)  
    DECLARE @desc_avista VARCHAR(200)  
    DECLARE @dias_venc_matr VARCHAR(2000)  
    DECLARE @data_venc_mens VARCHAR(2000)  
  
    DECLARE @CATEGORIA VARCHAR(20)  
    DECLARE @NOME_CURSO VARCHAR(200)  
    DECLARE @NOME_TURMA VARCHAR(200)  
    DECLARE @LOCAL VARCHAR(20)  
    DECLARE @COORDENADOR VARCHAR(100)  
    DECLARE @COORD_VICE VARCHAR(100)  
    DECLARE @DURACAO VARCHAR(200)  
    DECLARE @CARGA_HOR_TOTAL VARCHAR(20)  
    DECLARE @DAT_INI VARCHAR(20)  
    DECLARE @VENCTO_1_MENS VARCHAR(20)  
    DECLARE @MATR VARCHAR (8)  
    DECLARE @ANALISE_CUR VARCHAR(8)  
    DECLARE @ENTREVISTA VARCHAR (8)  
    DECLARE @PROVA VARCHAR (8)  
    DECLARE @REDACAO VARCHAR (8)  
    DECLARE @DATA_INICIO VARCHAR (20)  
    DECLARE @DATA_FIM  VARCHAR (20)  
    DECLARE @ALTERACAO_CONT_PROG VARCHAR (8)  
    DECLARE @DIAS_HOR VARCHAR (200)  
    DECLARE @LINK_INSC VARCHAR (200)  
  
 IF @txtEnviarFinan = 'S' AND @OFERTA_DE_CURSO IS NOT NULL  
 BEGIN  
   
  SET @txtEnviarFinan = 'N'  
  
  EXECUTE  
   PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMMON  
    @OFERTA_DE_CURSO,  
    --  
    @TURMA          OUTPUT, @CURRICULO      OUTPUT, @TURNO         OUTPUT,  
    @valor_total    OUTPUT, @taxa_matricula OUTPUT, @valor_parcela OUTPUT, @qtde_parcela OUTPUT, @desc_avista OUTPUT,  
    @dias_venc_matr OUTPUT, @data_venc_mens OUTPUT,  
    @centro_custo   OUTPUT, @oferta_curso   OUTPUT,  
    --  
    @CATEGORIA   OUTPUT, @NOME_CURSO  OUTPUT, @NOME_TURMA          OUTPUT, @LOCAL    OUTPUT, @COORDENADOR   OUTPUT,  
    @COORD_VICE  OUTPUT, @DURACAO     OUTPUT, @CARGA_HOR_TOTAL     OUTPUT, @DAT_INI  OUTPUT, @VENCTO_1_MENS OUTPUT,  
    @MATR        OUTPUT, @ANALISE_CUR OUTPUT, @ENTREVISTA          OUTPUT, @PROVA    OUTPUT, @REDACAO       OUTPUT,  
    @DATA_INICIO OUTPUT, @DATA_FIM    OUTPUT, @ALTERACAO_CONT_PROG OUTPUT, @DIAS_HOR OUTPUT, @LINK_INSC     OUTPUT  
  
  -------------------------------------------------------------  
  
  SET @ASSUNTO =  'Solicita��o - Cadastro de Plano de Pagamento para Turma: ' + @turma  
  
  -------------------------------------------------------------  
  
  SET @DESTINATARIO =  
    -- Desenvolvimento/homologa��o  
    --'joao.neves@vanzolini.org.br; gabriel.scalione@vanzolini.org.br; mvaraujo@vanzolini-ead.org.br; ecampos@vanzolini-ead.org.br'  
  
    -- Produ��o  
    'claudia.liberal@vanzolini.org.br; danitiela.kermessi@vanzolini.org.br; victor.passadore@vanzolini.org.br'  
  
  -------------------------------------------------------------  
  SELECT  
   @encaminha_email =  
    -- Desenvolvimento/homologa��o  
    --'joao.neves@vanzolini.org.br; gabriel.scalione@vanzolini.org.br; mvaraujo@vanzolini-ead.org.br; ecampos@vanzolini-ead.org.br'  
  
    -- Produ��o  
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
  SELECT @telefone =  
  (CASE WHEN FACULDADE = 'Paulista' THEN 'Secretaria Acad�mica Paulista: Via e-mail secretariapta@vanzolini.org.br ou pelo telefone: (11) 3145-3700'  
  WHEN FACULDADE = 'USP' THEN ' Secretaria Acad�mica USP: Via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11) 5525-5830'  
  END)  
  FROM LY_TURMA  
  WHERE TURMA = @turma  
       
  -------------------------------------------------------------  
  SELECT @INICIO_CURSO = ISNULL(CONVERT(VARCHAR,DT_INICIO,103),'.')  
  FROM VW_FCAV_INI_FIM_CURSO_TURMA  
  WHERE TURMA = @turma  
         
  -------------------------------------------------------------  
  SELECT @TEXTO =  
  'Solicito o cadastro referente ao Plano de Pagamento para a turma '+ @turma +', conforme dados mencionados abaixo.  
  
  <BR>  
  <ul>  
  <li> Nome do Curso:  <b>'+@NOME_CURSO+'</b>  
  <li> Turma:  <b>'+@NOME_TURMA+'</b>  
  <li> Local do curso:  <b>'+@LOCAL+'</b>  
  <li> Coordenador:  <b>'+@COORDENADOR+'</b>  
  <li> Vice Coordenador:  <b>'+@COORD_VICE+'</b>  
  <li> Dura��o:  <b>'+@DURACAO+'</b>  
  <li> Carga Hor�ria Total:  <b>'+@CARGA_HOR_TOTAL+' Horas</b>  
  <li> Centro de Custo:  <b>'+@centro_custo+'</b>  
  <li> Curriculo Vigente:  <b>'+@curriculo+'</b>  
  <li> Turno da Turma:  <b>'+@turno+'</b>  
  <li> Oferta de Curso:  <b>'+@oferta_curso+'</b>  
  <li> Valor do Total do Curso sem desconto:  <b>'+@valor_total+'</b>  
  <li> Taxa de Matr�cula (se houver):  <b>'+@taxa_matricula+'</b>  
  <li> Valor de Parcela:  <b>'+@valor_parcela+'</b>  
  <li> Quantidade de Parcelas:  <b>'+@qtde_parcela+'</b>  
  <li> Desconto para pagto � vista:  <b>'+@desc_avista+'%</b>  
  <li> Vencto Matr�cula ap�s Aceite (Dias):  <b>'+@dias_venc_matr+'</b>  
  <li> Vencto 1� Mensalidade (Dia/M�s/Ano):  <b>'+@data_venc_mens+'</b>  
  </ul>  
  
  <BR>  
  
  Inicio previsto do curso: <b>' + @INICIO_CURSO + '</b>  
  <BR><BR>  
  Qualquer d�vida estamos � disposi��o.  
  <BR><BR>'+@telefone  
  FROM LY_TURMA  
  WHERE TURMA = @turma  
  
  -------------------------------------------------------------  
  
  EXEC  
   MSDB.dbo.SP_SEND_DBMAIL  
    @PROFILE_NAME =  
     -- Desenvolvimento/homologa��o  
     --FCAV_HOMOLOGACAO,  
     -- Produ��o  
     VANZOLINI_BD,  
    @RECIPIENTS = @destinatario,  
    @copy_recipients = @encaminha_email,  
    @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',  
    @SUBJECT = @assunto,  
    @BODY = @texto,  
    @BODY_FORMAT = HTML  
 END  
 --------------------------------------------------------------------------  
 ----condi��es para retornar o valor na grid do NG, N�O REMOVER. Gabriel  
 IF @txtEnviarFinan = 'N'  
 BEGIN  
  SELECT 5 AS VALOR  
 END  
 ELSE  
 BEGIN  
  SELECT 3 AS VALOR  
 END  
 --------------------------------------------------------------------------  
END  