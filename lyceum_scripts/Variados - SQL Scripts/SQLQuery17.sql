  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
--  
-- Em produção, alterar o código de inicialização de @DESTINATARIO e  
-- a chamada a SP_SEND_DBMAIL  
--  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
-- !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO !! ATENÇÃO  
  
  
--* ***************************************************************  
--*  
--*   *** PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO ***  
--*   
--* USO:   
--*     Chamada via interface do LyceumNG, transação TVEST040D  
--*     Botão 'Enviar formulário para a secretaria'  
--*  
--* Histórico  
--*  
--*     13/03/2017 - Código removido de TR_FCAV_ENVIO_FORMULARIO  
--*   
--* ***************************************************************  
  
ALTER PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO(  
    @OFERTA_DE_CURSO INT, @txtEnviarSec varchar  
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
  
 IF @txtEnviarSec = 'S' AND @OFERTA_DE_CURSO IS NOT NULL  
 BEGIN  
   
  SET @txtEnviarSec = 'N'  
   
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
  
  SET @ASSUNTO =  'Dados para abertura de turma no site: ' + @turma  
  
  -------------------------------------------------------------  
  
  SELECT  
   @DESTINATARIO =  
    -- Desenvolvimento/homologação  
    'gabriel.scalione@vanzolini.org.br; joao.neves@vanzolini.org.br; mvaraujo@vanzolini-ead.org.br; ecampos@vanzolini-ead.org.br;'  
  
    -- Produção  
    --CASE  
    -- WHEN FACULDADE = 'USP'  
    --        THEN 'secretariausp@vanzolini.org.br'  
    --    WHEN (UNIDADE_RESPONSAVEL = 'ATUAL' OR UNIDADE_RESPONSAVEL = 'PALES') AND (FACULDADE = 'Online' or FACULDADE = 'Paulista')  
    --        THEN 'mayla.alencar@vanzolini.org.br; elivana.moura@vanzolini.org.br'   
    --    WHEN (UNIDADE_RESPONSAVEL = 'CAPAC' OR UNIDADE_RESPONSAVEL = 'ESPEC') AND FACULDADE = 'Paulista'  
    --        THEN 'adriana.pereira@vanzolini.org.br; elivana.moura@vanzolini.org.br'    
    --END  
  FROM LY_TURMA  
  WHERE TURMA = @TURMA  
  
  -------------------------------------------------------------  
  
  SELECT @telefone =  
			  (CASE   
				   WHEN (FACULDADE = 'Online' or FACULDADE = 'Paulista' OR FACULDADE = 'Semipresencial')   
					THEN 'Secretaria Acadêmica Paulista: Via e-mail secretariapta@vanzolini.org.br ou pelo telefone: (11) 3145-3700'  
				   WHEN FACULDADE = 'USP'   
					THEN ' Secretaria Acadêmica USP: Via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11)5525-5830'  
				   ELSE	'.'
			  END)
  FROM LY_TURMA  
  WHERE TURMA = @turma  
       
  -------------------------------------------------------------  
  SELECT @INICIO_CURSO =   
   ISNULL(CONVERT(VARCHAR,DT_INICIO,103),'.')  
  FROM VW_FCAV_INI_FIM_CURSO_TURMA  
  WHERE TURMA = @turma  
       
  -------------------------------------------------------------  
  
  SELECT @TEXTO =  
   'Solicito a abertura da turma '+ @turma +' no site para divulgação.  
   <BR>  
   <BR>  
   <BR>  
   <ul><b>Informações sobre o Curso </b>  
   <li> Categoria do Curso:  <b>'+@CATEGORIA+'</b>  
   <li> Nome do Curso:  <b>'+@NOME_CURSO+'</b>  
   <li> Turma:  <b>'+@NOME_TURMA+'</b>  
   <li> Sigla:  <b>'+@turma+'</b>  
   <li> Local do curso:  <b>'+@LOCAL+'</b>  
   <li> Coordenador:  <b>'+@COORDENADOR+'</b>  
   <li> Vice Coordenador:  <b>'+@COORD_VICE+'</b>  
   <li> Duração:  <b>'+@DURACAO+'</b>  
   <li> Carga Horária Total:  <b>'+@CARGA_HOR_TOTAL+' Horas</b>  
   <li> Data Início do Curso:  <b>'+@DAT_INI+'</b>  
   <li> Vencto Matrícula após Aceite (Dias):  <b>'+@dias_venc_matr+'</b>  
   <li> Vencto 1ª Mensalidade (Dia/Mês/Ano):  <b>'+@data_venc_mens+'</b>  
   <BR>  
   <BR> <b>Horários</b>  
   <li> Dias e Horários das aulas:  <b>'+@DIAS_HOR+'</b>  
   <BR>  
   <BR> <b>Valores</b>  
   <li> Possui Taxa de Matrícula?:  <b>'+@MATR+'</b>  
   <li> Taxa de Matrícula (se houver):  <b>'+@taxa_matricula+'</b>  
   <li> Valor de Parcela:  <b>'+@valor_parcela+'</b>  
   <li> Quantidade de Parcelas:  <b>'+@qtde_parcela+'</b>  
   <li> Desconto para pagto à vista:  <b>'+@desc_avista+'%</b>  
   <li> Curriculo:  <b>'+@curriculo+'</b>  
   <BR>  
   <BR><B>Centro de Custo</B>  
   <li> Centro de Custo:  <b>'+@centro_custo+'</b>  
   <br>  
   <br><b>Critérios para Seleção:</b>  
   <li> Análise Curricular: <b>'+@ANALISE_CUR+'</b>  
   <li> Entrevista: <b>'+@ENTREVISTA+'</b>  
   <li> Prova: <b>'+@PROVA+'</b>  
   <li> Redação: <b>'+@REDACAO+'</b>  
   <br>  
   <br> <B>Processo Seletivo:</B>  
   <li> Início: <b>'+@DATA_INICIO+'</b>  
   <li> Término: <b>'+@DATA_FIM+'</b>  
   <BR>  
   <BR> <B>Documentos para Matrícula:</B>  
   <li>  
   <BR>  
   <BR> <B>Alteração no Conteúdo Programático?:</B>  
   <li>  
   </ul>  
  
   <BR>  
  
   Inicio previsto do curso: <b>' + @INICIO_CURSO + '</b><BR>  
   Link para a inscrição LYCEUM: <b>'+@LINK_INSC+'</b>  
   <BR><BR>  
   Qualquer dúvida estamos à disposição.  
   <BR><BR>'+@telefone  
  FROM LY_TURMA  
  WHERE TURMA = @turma  
  
  -------------------------------------------------------------  
  
  EXEC  
   MSDB.dbo.SP_SEND_DBMAIL  
    @PROFILE_NAME =  
     -- Desenvolvimento/homologação  
     FCAV_HOMOLOGACAO,  
     -- Produção  
     --VANZOLINI_BD,  
    @RECIPIENTS = @DESTINATARIO,  
    @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',  
    @SUBJECT = @assunto,  
    @BODY = @TEXTO,  
    @BODY_FORMAT = HTML  
 END  
   
 --------------------------------------------------------------------------  
 --condições para retornar o valor na grid oculta da tela da oferta do NG, NÃO REMOVER. Gabriel  
 IF @txtEnviarSec = 'N'  
 BEGIN  
  SELECT 5 AS VALOR  
 END  
 ELSE  
 BEGIN  
  SELECT 3 AS VALOR  
 END  
 --------------------------------------------------------------------------  
   
END  