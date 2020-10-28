  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
--  
-- Em produ��o, alterar o c�digo de inicializa��o de @DESTINATARIO e  
-- a chamada a SP_SEND_DBMAIL  
--  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
-- !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O !! ATEN��O  
  
  
--* ***************************************************************  
--*  
--*   *** PROCEDURE PR_FCAV_LYCEUM_OFERTA_CURSO_EMAIL_COMUNICACAO ***  
--*   
--* USO:   
--*     Chamada via interface do LyceumNG, transa��o TVEST040D  
--*     Bot�o 'Enviar formul�rio para a secretaria'  
--*  
--* Hist�rico  
--*  
--*     13/03/2017 - C�digo removido de TR_FCAV_ENVIO_FORMULARIO  
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
    -- Desenvolvimento/homologa��o  
    'gabriel.scalione@vanzolini.org.br; joao.neves@vanzolini.org.br; mvaraujo@vanzolini-ead.org.br; ecampos@vanzolini-ead.org.br;'  
  
    -- Produ��o  
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
					THEN 'Secretaria Acad�mica Paulista: Via e-mail secretariapta@vanzolini.org.br ou pelo telefone: (11) 3145-3700'  
				   WHEN FACULDADE = 'USP'   
					THEN ' Secretaria Acad�mica USP: Via e-mail secretariausp@vanzolini.org.br ou pelo telefone: (11)5525-5830'  
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
   'Solicito a abertura da turma '+ @turma +' no site para divulga��o.  
   <BR>  
   <BR>  
   <BR>  
   <ul><b>Informa��es sobre o Curso </b>  
   <li> Categoria do Curso:  <b>'+@CATEGORIA+'</b>  
   <li> Nome do Curso:  <b>'+@NOME_CURSO+'</b>  
   <li> Turma:  <b>'+@NOME_TURMA+'</b>  
   <li> Sigla:  <b>'+@turma+'</b>  
   <li> Local do curso:  <b>'+@LOCAL+'</b>  
   <li> Coordenador:  <b>'+@COORDENADOR+'</b>  
   <li> Vice Coordenador:  <b>'+@COORD_VICE+'</b>  
   <li> Dura��o:  <b>'+@DURACAO+'</b>  
   <li> Carga Hor�ria Total:  <b>'+@CARGA_HOR_TOTAL+' Horas</b>  
   <li> Data In�cio do Curso:  <b>'+@DAT_INI+'</b>  
   <li> Vencto Matr�cula ap�s Aceite (Dias):  <b>'+@dias_venc_matr+'</b>  
   <li> Vencto 1� Mensalidade (Dia/M�s/Ano):  <b>'+@data_venc_mens+'</b>  
   <BR>  
   <BR> <b>Hor�rios</b>  
   <li> Dias e Hor�rios das aulas:  <b>'+@DIAS_HOR+'</b>  
   <BR>  
   <BR> <b>Valores</b>  
   <li> Possui Taxa de Matr�cula?:  <b>'+@MATR+'</b>  
   <li> Taxa de Matr�cula (se houver):  <b>'+@taxa_matricula+'</b>  
   <li> Valor de Parcela:  <b>'+@valor_parcela+'</b>  
   <li> Quantidade de Parcelas:  <b>'+@qtde_parcela+'</b>  
   <li> Desconto para pagto � vista:  <b>'+@desc_avista+'%</b>  
   <li> Curriculo:  <b>'+@curriculo+'</b>  
   <BR>  
   <BR><B>Centro de Custo</B>  
   <li> Centro de Custo:  <b>'+@centro_custo+'</b>  
   <br>  
   <br><b>Crit�rios para Sele��o:</b>  
   <li> An�lise Curricular: <b>'+@ANALISE_CUR+'</b>  
   <li> Entrevista: <b>'+@ENTREVISTA+'</b>  
   <li> Prova: <b>'+@PROVA+'</b>  
   <li> Reda��o: <b>'+@REDACAO+'</b>  
   <br>  
   <br> <B>Processo Seletivo:</B>  
   <li> In�cio: <b>'+@DATA_INICIO+'</b>  
   <li> T�rmino: <b>'+@DATA_FIM+'</b>  
   <BR>  
   <BR> <B>Documentos para Matr�cula:</B>  
   <li>  
   <BR>  
   <BR> <B>Altera��o no Conte�do Program�tico?:</B>  
   <li>  
   </ul>  
  
   <BR>  
  
   Inicio previsto do curso: <b>' + @INICIO_CURSO + '</b><BR>  
   Link para a inscri��o LYCEUM: <b>'+@LINK_INSC+'</b>  
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
     FCAV_HOMOLOGACAO,  
     -- Produ��o  
     --VANZOLINI_BD,  
    @RECIPIENTS = @DESTINATARIO,  
    @blind_copy_recipients = 'suporte_techne@vanzolini.org.br',  
    @SUBJECT = @assunto,  
    @BODY = @TEXTO,  
    @BODY_FORMAT = HTML  
 END  
   
 --------------------------------------------------------------------------  
 --condi��es para retornar o valor na grid oculta da tela da oferta do NG, N�O REMOVER. Gabriel  
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