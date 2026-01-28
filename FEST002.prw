#Include 'totvs.ch'
#Include 'FWMVCDef.ch'

Static cTitulo := "Qualidade do Material"
Static cAliasMVC := "SZ1"

/*/{Protheus.doc} FEST002
Manutencao Cadastro Qualidade Materiais
@type function
@author rodolfomagalhaes
@since 19/06/2024
/*/
User Function FEST002()
	Local aArea   := FWGetArea()
	Local oBrowse
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasMVC)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)
Return Nil

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.FEST002" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.FEST002" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.FEST002" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.FEST002" OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()

	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local bPre    := Nil
	Local bPos    := Nil
	Local bCancel := Nil
	Local oModel  := Nil

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("FEST002M", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("SZ1MASTER", /*cOwner*/, oStruct)
	oModel:SetDescription(cTitulo)
	oModel:GetModel("SZ1MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:SetPrimaryKey({'Z1_FILIAL,Z1_COD'})

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel("FEST002")
	Local oStruct := FWFormStruct(2, cAliasMVC)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SZ1", oStruct, "SZ1MASTER")
	oView:CreateHorizontalBox("TELA" , 100 )
	oView:SetOwnerView("VIEW_SZ1", "TELA")

Return oView
