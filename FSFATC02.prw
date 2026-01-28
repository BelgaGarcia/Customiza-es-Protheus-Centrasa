#include "totvs.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/ {Protheus.doc} FSFATC02

Cadastro de Conversao Unidade de Medida

@type function
@author Gabriel Gonçalves
@since 01/10/2025
@version P12
@database ORACLE
/*/
User Function FSFATC02()
	Local oBrowse		:= Nil

	Private cTitulo		:= "Conversao Unidade de Medida"
	Private cTabela		:= "SZ6"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabela)
	oBrowse:SetDescription(cTitulo)

	oBrowse:DisableDetails()
	oBrowse:SetMenuDef("FSFATC02")
	oBrowse:Activate()
Return NIL

/*/
	Funcao MenuDef
/*/
Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.FSFATC02"		OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.FSFATC02"		OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.FSFATC02"		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.FSFATC02"		OPERATION MODEL_OPERATION_DELETE	ACCESS 0 //OPERATION 5
Return aRotina

/*
	Função que Define o Modelo de Dados do Cadastro
*/
Static Function ModelDef()
	Local cAliasForm 		:= "SZ6"
	Local oStructForm 		:= Nil
	Local oModel 			:= Nil
	Local bCancel			:= {|oModel| cancForm(oModel)}
	Local bPreValidacao		:= {|oModel| preValid(oModel)}
	Local bPosValidacao		:= {|oModel| posValid(oModel)}
	Local bCommit			:= {|oModel| saveForm(oModel)}
	Local bActivate			:= {|oModel| activeForm(oModel) }

	oStructForm	:= FWFormStruct( 1, cAliasForm )

	oModel	:= MPFormModel():New("MFSFATC02",bPreValidacao,bPosValidacao,bCommit,bCancel)

	oModel:AddFields("SZ6FORM", /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	//Nota: No modelo 2 os campos de cabeçalho precisam todos estar dentro da relação para correta gravação dos dados
	oModel:SetPrimaryKey( { "Z6_FILIAL", "Z6_UMORIG", "Z6_UMDEST" } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)

	oModel:GetModel("SZ6FORM"):SetDescription(cTitulo)
Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cAliasForm 		:= "SZ6"
	Local oModel 			:= Nil
	Local oStructForm		:= Nil
	Local oView				:= Nil
	Local nOperation		:= 3

	oModel 		:= FWLoadModel( "FSFATC02" )
	nOperation	:= oModel:GetOperation()

	oStructForm	:= FWFormStruct( 2, cAliasForm )

	oView 	:= FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEWFORM",oStructForm,"SZ6FORM")
	oView:CreateHorizontalBox('TELA',100)
	oView:SetOwnerView( "VIEWFORM",'TELA' )
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
	//Local nOperation	:= oModel:GetOperation()
	Local lRetorno		:= .T.
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
	//Local nOperation	:= oModel:GetOperation()
	Local lRetorno		:= .T.

	FWModelActive(oModel)
	lRetorno := FWFormCommit(oModel)
Return lRetorno
