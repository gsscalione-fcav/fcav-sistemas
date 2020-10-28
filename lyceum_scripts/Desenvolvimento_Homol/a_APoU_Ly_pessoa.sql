/*
	EP para validar o endereço válido da pessoa

*/  
  
ALTER PROCEDURE a_APoU_Ly_pessoa                    
  @erro VARCHAR(1024) OUTPUT,    
  @oldPessoa NUMERIC(10), @oldHab_tac VARCHAR(20), @oldNome_compl VARCHAR(100), @oldNome_abrev VARCHAR(50),     
  @oldDt_nasc DATETIME, @oldMunicipio_nasc VARCHAR(20), @oldPais_nasc VARCHAR(50),     
  @oldNacionalidade VARCHAR(50), @oldNome_pai VARCHAR(100), @oldNome_mae VARCHAR(100),     
  @oldSexo VARCHAR(1), @oldEst_civil VARCHAR(30), @oldEnd_correto VARCHAR(1), @oldEndereco VARCHAR(50),     
  @oldEnd_num VARCHAR(15), @oldEnd_compl VARCHAR(50), @oldBairro VARCHAR(50), @oldEnd_municipio VARCHAR(20),     
  @oldCep VARCHAR(9), @oldFone VARCHAR(30), @oldProfissao VARCHAR(50), @oldNome_empresa VARCHAR(50),     
  @oldCargo VARCHAR(50), @oldEndcom VARCHAR(50), @oldEndcom_num VARCHAR(15), @oldEndcom_compl VARCHAR(50),     
  @oldEndcom_bairro VARCHAR(50), @oldEndcom_municipio VARCHAR(20), @oldEndcom_cep VARCHAR(9),     
  @oldFone_com VARCHAR(30), @oldFax VARCHAR(30), @oldRg_num VARCHAR(20), @oldRg_tipo VARCHAR(15),     
  @oldRg_emissor VARCHAR(15), @oldRg_uf VARCHAR(2), @oldRg_dtexp DATETIME, @oldCpf VARCHAR(14),     
  @oldAlist_num VARCHAR(17), @oldAlist_serie VARCHAR(15), @oldAlist_rm VARCHAR(15),     
  @oldAlist_csm VARCHAR(15), @oldAlist_dtexp DATETIME, @oldCr_num VARCHAR(17), @oldCr_cat VARCHAR(15),     
  @oldCr_serie VARCHAR(15), @oldCr_rm VARCHAR(15), @oldCr_csm VARCHAR(15), @oldCr_dtexp DATETIME,     
  @oldTeleitor_num VARCHAR(15), @oldTeleitor_zona VARCHAR(15), @oldTeleitor_secao VARCHAR(15),     
  @oldTeleitor_dtexp DATETIME, @oldCprof_num VARCHAR(15), @oldCprof_serie VARCHAR(15),     
  @oldCprof_uf VARCHAR(2), @oldCprof_dtexp DATETIME, @oldE_mail VARCHAR(100), @oldMailbox VARCHAR(100),     
  @oldHab_tac_data DATETIME, @oldObs VARCHAR(4000), @oldSenha_tac VARCHAR(40), @oldDt_falecimento DATETIME,     
  @oldResp_nome_compl VARCHAR(100), @oldResp_municipio_nasc VARCHAR(20), @oldResp_nacionalidade VARCHAR(15),     
  @oldResp_sexo VARCHAR(1), @oldResp_est_civil VARCHAR(30), @oldResp_endereco VARCHAR(50),     
  @oldResp_end_num VARCHAR(15), @oldResp_end_compl VARCHAR(50), @oldResp_bairro VARCHAR(50),     
  @oldResp_end_municipio VARCHAR(20), @oldResp_cep VARCHAR(9), @oldResp_fone VARCHAR(30),     
  @oldResp_rg_num VARCHAR(20), @oldResp_rg_tipo VARCHAR(15), @oldResp_rg_emissor VARCHAR(15),     
  @oldResp_rg_uf VARCHAR(2), @oldResp_cpf VARCHAR(14), @oldCelular VARCHAR(30), @oldFax_res VARCHAR(30),     
  @oldE_mail_com VARCHAR(100), @oldE_mail_interno VARCHAR(100), @oldNome_conjuge VARCHAR(100),     
  @oldObs_tel_res VARCHAR(100), @oldObs_tel_com VARCHAR(100), @oldDivida_biblio VARCHAR(1),     
  @oldNecessidade_especial VARCHAR(40), @oldNum_func NUMERIC(15), @oldResp_senha VARCHAR(30),     
  @oldTeleitor_mun VARCHAR(20), @oldEnd_pais VARCHAR(50), @oldEndcom_pais VARCHAR(50),     
  @oldResp_end_pais VARCHAR(50), @oldRenda_mensal NUMERIC(10, 2), @oldCor_raca VARCHAR(50),     
  @oldArea_prof VARCHAR(40), @oldEspecializacao VARCHAR(40), @oldCert_nasc_num VARCHAR(50),     
  @oldCert_nasc_folha VARCHAR(15), @oldCert_nasc_livro VARCHAR(15), @oldCert_nasc_emissao DATETIME,     
  @oldCert_nasc_cartorio_uf VARCHAR(2), @oldCert_nasc_cartorio_exped VARCHAR(100),     
  @oldFone_recados VARCHAR(30), @oldAutoriza_envio_mail VARCHAR(1), @oldConselho_regional VARCHAR(15),     
  @oldPermiteacescadsemsenha VARCHAR(1), @oldPassaporte VARCHAR(50), @oldPermite_usar_imagem VARCHAR(1),     
  @oldFormacao_pai VARCHAR(20), @oldFormacao_mae VARCHAR(20), @oldDepto_com VARCHAR(50),     
  @oldWinusuario VARCHAR(100), @oldRenda_familiar NUMERIC(10, 2), @oldId_censo VARCHAR(20),     
  @oldNr_regua VARCHAR(20), @oldSenha_alterada VARCHAR(1), @oldTipo_sanguineo VARCHAR(40),     
  @oldEtnia VARCHAR(40), @oldCredo VARCHAR(40), @oldQt_filhos NUMERIC(3), @oldPre_nome_social VARCHAR(100),     
  @oldStamp_atualizacao DATETIME, @oldDdd_fone VARCHAR(10), @oldDdd_fone_comercial VARCHAR(10),     
  @oldDdd_fone_celular VARCHAR(10), @oldDdd_fone_recado VARCHAR(10), @oldDdd_resp_fone VARCHAR(10),     
  @oldObs_fax_res VARCHAR(100), @oldObs_fax VARCHAR(100), @oldObs_cel VARCHAR(100),     
  @oldObs_tel_rec VARCHAR(100), @oldResp_fone_obs VARCHAR(100), @oldResp_rg_dtexp VARCHAR(100),     
  @oldCert_nasc_matricula VARCHAR(32), @oldContribui_renda VARCHAR(1), @oldResp_e_mail VARCHAR(100),     
  @oldDdd_fax_res VARCHAR(10), @oldLatitude VARCHAR(50), @oldLongitude VARCHAR(50),     
  @oldNome_social VARCHAR(100),    
  @pessoa NUMERIC(10), @hab_tac VARCHAR(20), @nome_compl VARCHAR(100), @nome_abrev VARCHAR(50),     
  @dt_nasc DATETIME, @municipio_nasc VARCHAR(20), @pais_nasc VARCHAR(50), @nacionalidade VARCHAR(50),     
  @nome_pai VARCHAR(100), @nome_mae VARCHAR(100), @sexo VARCHAR(1), @est_civil VARCHAR(30),     
  @end_correto VARCHAR(1), @endereco VARCHAR(50), @end_num VARCHAR(15), @end_compl VARCHAR(50),     
  @bairro VARCHAR(50), @end_municipio VARCHAR(20), @cep VARCHAR(9), @fone VARCHAR(30),     
  @profissao VARCHAR(50), @nome_empresa VARCHAR(50), @cargo VARCHAR(50), @endcom VARCHAR(50),     
  @endcom_num VARCHAR(15), @endcom_compl VARCHAR(50), @endcom_bairro VARCHAR(50), @endcom_municipio VARCHAR(20),     
  @endcom_cep VARCHAR(9), @fone_com VARCHAR(30), @fax VARCHAR(30), @rg_num VARCHAR(20),     
  @rg_tipo VARCHAR(15), @rg_emissor VARCHAR(15), @rg_uf VARCHAR(2), @rg_dtexp DATETIME,     
  @cpf VARCHAR(14), @alist_num VARCHAR(17), @alist_serie VARCHAR(15), @alist_rm VARCHAR(15),     
  @alist_csm VARCHAR(15), @alist_dtexp DATETIME, @cr_num VARCHAR(17), @cr_cat VARCHAR(15),     
  @cr_serie VARCHAR(15), @cr_rm VARCHAR(15), @cr_csm VARCHAR(15), @cr_dtexp DATETIME,     
  @teleitor_num VARCHAR(15), @teleitor_zona VARCHAR(15), @teleitor_secao VARCHAR(15),     
  @teleitor_dtexp DATETIME, @cprof_num VARCHAR(15), @cprof_serie VARCHAR(15), @cprof_uf VARCHAR(2),     
  @cprof_dtexp DATETIME, @e_mail VARCHAR(100), @mailbox VARCHAR(100), @hab_tac_data DATETIME,     
  @obs VARCHAR(4000), @senha_tac VARCHAR(40), @dt_falecimento DATETIME, @resp_nome_compl VARCHAR(100),     
  @resp_municipio_nasc VARCHAR(20), @resp_nacionalidade VARCHAR(15), @resp_sexo VARCHAR(1),     
  @resp_est_civil VARCHAR(30), @resp_endereco VARCHAR(50), @resp_end_num VARCHAR(15),     
  @resp_end_compl VARCHAR(50), @resp_bairro VARCHAR(50), @resp_end_municipio VARCHAR(20),     
  @resp_cep VARCHAR(9), @resp_fone VARCHAR(30), @resp_rg_num VARCHAR(20), @resp_rg_tipo VARCHAR(15),     
  @resp_rg_emissor VARCHAR(15), @resp_rg_uf VARCHAR(2), @resp_cpf VARCHAR(14), @celular VARCHAR(30),     
  @fax_res VARCHAR(30), @e_mail_com VARCHAR(100), @e_mail_interno VARCHAR(100), @nome_conjuge VARCHAR(100),     
  @obs_tel_res VARCHAR(100), @obs_tel_com VARCHAR(100), @divida_biblio VARCHAR(1),     
  @necessidade_especial VARCHAR(40), @num_func NUMERIC(15), @resp_senha VARCHAR(30),     
  @teleitor_mun VARCHAR(20), @end_pais VARCHAR(50), @endcom_pais VARCHAR(50), @resp_end_pais VARCHAR(50),     
  @renda_mensal NUMERIC(10, 2), @cor_raca VARCHAR(50), @area_prof VARCHAR(40), @especializacao VARCHAR(40),     
  @cert_nasc_num VARCHAR(50), @cert_nasc_folha VARCHAR(15), @cert_nasc_livro VARCHAR(15),     
  @cert_nasc_emissao DATETIME, @cert_nasc_cartorio_uf VARCHAR(2), @cert_nasc_cartorio_exped VARCHAR(100),     
  @fone_recados VARCHAR(30), @autoriza_envio_mail VARCHAR(1), @conselho_regional VARCHAR(15),     
  @permiteacescadsemsenha VARCHAR(1), @passaporte VARCHAR(50), @permite_usar_imagem VARCHAR(1),     
  @formacao_pai VARCHAR(20), @formacao_mae VARCHAR(20), @depto_com VARCHAR(50), @winusuario VARCHAR(100),     
  @renda_familiar NUMERIC(10, 2), @id_censo VARCHAR(20), @nr_regua VARCHAR(20), @senha_alterada VARCHAR(1),     
  @tipo_sanguineo VARCHAR(40), @etnia VARCHAR(40), @credo VARCHAR(40), @qt_filhos NUMERIC(3),     
  @pre_nome_social VARCHAR(100), @stamp_atualizacao DATETIME, @ddd_fone VARCHAR(10),     
  @ddd_fone_comercial VARCHAR(10), @ddd_fone_celular VARCHAR(10), @ddd_fone_recado VARCHAR(10),     
  @ddd_resp_fone VARCHAR(10), @obs_fax_res VARCHAR(100), @obs_fax VARCHAR(100), @obs_cel VARCHAR(100),     
  @obs_tel_rec VARCHAR(100), @resp_fone_obs VARCHAR(100), @resp_rg_dtexp VARCHAR(100),     
  @cert_nasc_matricula VARCHAR(32), @contribui_renda VARCHAR(1), @resp_e_mail VARCHAR(100),     
  @ddd_fax_res VARCHAR(10), @latitude VARCHAR(50), @longitude VARCHAR(50), @nome_social VARCHAR(100)    
AS                   
 -- [INÍCIO] Customização - Não escreva código antes desta linha                    
 
	 --IF EXISTS( SELECT 1 FROM   
		--			LY_PESSOA pe  
    
		--			INNER JOIN HD_MUNICIPIO MU   
		--			 ON MU.MUNICIPIO = pe.END_MUNICIPIO  
		--			WHERE   
		--			 ENDERECO LIKE 'nÃ£o informado'  
		--			 AND PE.PESSOA = @pessoa )  
	 --BEGIN   
		--  SET @erro = 'Identificamos que o endereço informado não é um endereço válido, por favor atualizar seu endereço.'  
	 --END                          

 -- [FIM] Customização - Não escreva código após esta linha                    
return   
  