#include "totvs.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/ {Protheus.doc} FSFATC01

Cadastro de Romaneio

@type function
@author Gabriel Gonçalves
@since 27/02/2025
@version P12
@database ORACLE
/*/
User Function FSFATC01()
	Local oBrowse		:= Nil

	Private cTitulo		:= "Cadastro de Romaneio"
	Private cTabela		:= "SZ5"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabela)
	oBrowse:SetDescription(cTitulo)

	oBrowse:DisableDetails()
	oBrowse:SetMenuDef("FSFATC01")
	oBrowse:Activate()
Return NIL

/*/
	Funcao MenuDef
/*/
Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.FSFATC01"		OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.FSFATC01"		OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //OPERATION 3
	//ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.FSFATC01"		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.FSFATC01"		OPERATION MODEL_OPERATION_DELETE	ACCESS 0 //OPERATION 5

	ADD OPTION aRotina TITLE "Relatorio"		ACTION "faturamento.romaneio.u_relatorioRomaneio()"		OPERATION 9	ACCESS 0 //OPERATION 9
Return aRotina

/*
	Função que Define o Modelo de Dados do Cadastro
*/
Static Function ModelDef()
	Local cAliasForm 		:= "SZ5"
	Local cAliasGrid 		:= "SZ5"
	Local cCamposCab		:= "Z5_DOC|Z5_EMISSAO|Z5_DOCCLI|Z5_CODCLI|Z5_LOJACLI|Z5_NOME|Z5_NOMEMOT|Z5_PLACA|Z5_USER|"
	Local cCamposDet		:= "Z5_ITEM|Z5_COD|Z5_DESCRI|Z5_UM|Z5_QUANT|Z5_LOCAL|Z5_LOCALIZ|Z5_LOTECTL|Z5_CODINSP|Z5_NOTA|Z5_SERIE|Z5_ITEMNF|Z5_OBS|"
	Local oStructForm 		:= Nil
	Local oStructGrid		:= Nil
	Local oModel 			:= Nil
	Local bCancel			:= {|oModel| cancForm(oModel)}
	Local bPreValidacao		:= {|oModel| preValid(oModel)}
	Local bPosValidacao		:= {|oModel| posValid(oModel)}
	Local bCommit			:= {|oModel| saveForm(oModel)}
	//Local bLinePre			:= {|oModelGrid,  nLine,  cAction, cField| linePreValid(oModelGrid,  nLine,  cAction, cField)}
	Local bActivate			:= {|oModel| activeForm(oModel) }
	//Local bPreVal			:= {|oModelGrid,  nLine,  cAction, cField| linePreValid(oModelGrid,  nLine,  cAction, cField)}
	//Local aGatilho			:= {}

	oStructForm	:= FWFormStruct( 1, cAliasForm , {|cCampo| AllTrim(cCampo)+"|" $ cCamposCab })
	oStructGrid := FWFormStruct( 1, cAliasGrid , {|cCampo| AllTrim(cCampo)+"|" $ cCamposDet })

	/*aGatilho	:= FwStruTrigger('Z5_CODCLI', 'Z5_NOME', 'Posicione("SA1", 1, FwxFilial("SA1") + M->Z5_CODCLI + M->Z5_LOJACLI, "A1_NOME")', .F., '', 0, '', Nil,'01')
	oStructGrid:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

	aGatilho	:= FwStruTrigger('Z5_LOJACLI', 'Z5_NOME', 'Posicione("SA1", 1, FwxFilial("SA1") + M->Z5_CODCLI + M->Z5_LOJACLI, "A1_NOME")', .F., '', 0, '', Nil,'01')
	oStructGrid:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])*/

	oModel	:= MPFormModel():New("MFSFATC01",bPreValidacao,bPosValidacao,bCommit,bCancel)

	oModel:AddFields("SZ5FORM", /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	oModel:AddGrid("SZ5GRID","SZ5FORM",oStructGrid,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
	oModel:GetModel("SZ5GRID"):SetUniqueLine( { "Z5_COD", "Z5_LOCAL", "Z5_LOCALIZ", "Z5_LOTECTL", "Z5_NOTA", "Z5_SERIE", "Z5_ITEMNF" } )
	//oModel:GetModel("SZ5GRID"):SetOnlyView(.T.)

	//Nota: No modelo 2 os campos de cabeçalho precisam todos estar dentro da relação para correta gravação dos dados
	oModel:SetRelation("SZ5GRID",{{"Z5_DOC","Z5_DOC"},{"Z5_EMISSAO","Z5_EMISSAO"},{"Z5_DOCCLI","Z5_DOCCLI"},{"Z5_CODCLI","Z5_CODCLI"},{"Z5_LOJACLI","Z5_LOJACLI"},{"Z5_NOME","Z5_NOME"},{"Z5_NOMEMOT","Z5_NOMEMOT"},{"Z5_PLACA","Z5_PLACA"},{"Z5_USER","Z5_USER"}},(cAliasGrid)->(IndexKey(1)))
	oModel:SetPrimaryKey( { "Z5_FILIAL", "Z5_DOC", "Z5_ITEM", "Z5_COD" } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)

	oModel:GetModel("SZ5FORM"):SetDescription(cTitulo)
Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cAliasForm 		:= "SZ5"
	Local cAliasGrid 		:= "SZ5"
	Local cCamposCab		:= "Z5_DOC|Z5_EMISSAO|Z5_DOCCLI|Z5_CODCLI|Z5_LOJACLI|Z5_NOME|Z5_NOMEMOT|Z5_PLACA|Z5_USER|"
	Local cCamposDet		:= "Z5_ITEM|Z5_COD|Z5_DESCRI|Z5_UM|Z5_QUANT|Z5_LOCAL|Z5_LOCALIZ|Z5_LOTECTL|Z5_CODINSP|Z5_NOTA|Z5_SERIE|Z5_ITEMNF|Z5_OBS|"
	Local oModel 			:= Nil
	Local oStructForm		:= Nil
	Local oStructGrid		:= Nil
	Local oView				:= Nil
	Local nOperation		:= 3

	oModel 		:= FWLoadModel( "FSFATC01" )
	nOperation	:= oModel:GetOperation()

	oStructForm	:= FWFormStruct( 2, cAliasForm , {|cCampo| AllTrim(cCampo)+"|" $ cCamposCab })
	oStructGrid := FWFormStruct( 2, cAliasGrid , {|cCampo| AllTrim(cCampo)+"|" $ cCamposDet })

	oView 	:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField("VIEWFORM",oStructForm,"SZ5FORM")

	oView:AddGrid("VIEWGRID",oStructGrid,"SZ5GRID")
	oView:AddIncrementField("VIEWGRID","Z5_ITEM")

	oView:AddUserButton('Adicionar Produtos','CLIPS', {|| faturamento.romaneio.U_gerarRomaneio(oModel)},'Adicionar Produto',VK_F4, {MODEL_OPERATION_INSERT}) 

	oView:CreateHorizontalBox('SUPERIOR',25)
	oView:CreateHorizontalBox('INFERIOR',75)

	oView:SetOwnerView( "VIEWFORM",'SUPERIOR' )
	oView:SetOwnerView( "VIEWGRID",'INFERIOR' )
Return oView

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)
	//Local nOperation	:= oModel:GetOperation()
	Local lRetorno		:= .T.
Return lRetorno

/*
	Função executado no Cancelamento da Tela de Cadastro
*/ 
Static Function cancForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRetorno		:= .T.

	If nOperation == MODEL_OPERATION_INSERT
		RollBackSX8()
	EndIf
Return lRetorno

/*
	Função para Validar os Dados Antes da Confirmação da Tela do Cadastro
*/
Static Function preValid(oModel)
	//Local nOperation	:= oModel:GetOperation()
	Local lRetorno		:= .T.
Return lRetorno

/*
	Função para Validar os Dados Após Confirmação da Tela de Cadastro - VerIfica se pode incluir
*/
Static Function posValid(oModel)
	//Local nOperation		:= oModel:GetOperation()
	Local lRetorno			:= .T.
Return lRetorno

/*/
	Função para Salvar os Dados do Cadastro usando MVC
/*/ 
Static Function saveForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRetorno		:= .T.
	Local oModelForm	:= oModel:GetModel( "SZ5FORM" )
	Local oModelGrid	:= oModel:GetModel( "SZ5GRID" )
	Local nItemGrid		:= 0

	FWModelActive(oModel)
	lRetorno := FWFormCommit(oModel)
	
	If lRetorno
		If nOperation == MODEL_OPERATION_INSERT
			////Atualizar numeracao dos itens
			If ( oModelGrid:Length() > 0 )
				DbSelectArea("SD2")
				SD2->(DbSetOrder(3))
				SD2->(DbGoTop())

				DbSelectArea("SBF")
				SBF->(DbSetOrder(1))
				SBF->(DbGoTop())

				For nItemGrid := 1 To oModelGrid:Length()
					oModelGrid:GoLine(nItemGrid)
					If !oModelGrid:IsDeleted()
						If SD2->(DbSeek( FwxFilial("SD2") + oModelGrid:GetValue("Z5_NOTA") + oModelGrid:GetValue("Z5_SERIE") + oModelForm:GetValue("Z5_CODCLI") + oModelForm:GetValue("Z5_LOJACLI") + oModelGrid:GetValue("Z5_COD")+ oModelGrid:GetValue("Z5_ITEMNF") ))
							RecLock("SD2", .F.)
								SD2->D2_ZROMAN	:= oModelForm:GetValue("Z5_DOC")
							SD2->(MsUnlock())
						ElseIf SBF->(DbSeek( FwxFilial("SBF") + oModelGrid:GetValue("Z5_LOCAL") + oModelGrid:GetValue("Z5_LOCALIZ") + oModelGrid:GetValue("Z5_COD") + AvKey(" ","BF_NUMSERI") + oModelGrid:GetValue("Z5_LOTECTL") ))
							RecLock("SBF", .F.)
								SBF->BF_ZROMAN	:= oModelForm:GetValue("Z5_DOC")
							SBF->(MsUnlock())
						EndIf
					EndIf
				Next nItemGrid
			EndIf
		ElseIf nOperation == MODEL_OPERATION_DELETE
			faturamento.romaneio.u_excluirRomaneio(oModel)
		EndIf
	EndIf
Return lRetorno
