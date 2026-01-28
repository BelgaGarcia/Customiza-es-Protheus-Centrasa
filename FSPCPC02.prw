#include "totvs.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/ {Protheus.doc} FSPCPC02

Cadastro de Usuario X Maquina

@type function
@author Elcilei Lopes - DSM
@since 01/10/2024
@version P12
@database ORACLE
/*/
User Function FSPCPC02()

	Local oBrowse       := Nil
	Private cTitulo     := "Cadastro de Usuário X Maquina"
	Private cTabela     := "SZ2"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabela)
	oBrowse:SetDescription(cTitulo)

	oBrowse:DisableDetails()
	oBrowse:SetMenuDef("FSPCPC02")
	oBrowse:Activate()

Return NIL

/*/
	Funcao MenuDef
/*/
Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opções
	ADD OPTION aRotina TITLE "Visualizar"           ACTION "VIEWDEF.FSPCPC02"       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE "Incluir"              ACTION "VIEWDEF.FSPCPC02"       OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.FSPCPC02"       OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.FSPCPC02"       OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRotina


/*
	Função que Define o Modelo de Dados do Cadastro
*/
Static Function ModelDef()
	Local cAliasForm 		:= "SZ2"
	Local cAliasGrid 		:= "SZ2"
	Local cCamposCab        := "Z2_CODUSER|Z2_USUARIO|"
	Local oStructForm 		:= Nil
	Local oStructGrid		:= Nil
	Local oModel 			:= Nil
	Local bCancel   		:= {|oModel| cancForm(oModel)}
	Local bPreValidacao		:= {|oModel| preValid(oModel)}
	Local bPosValidacao		:= {|oModel| posValid(oModel)}
	Local bCommit			:= {|oModel| saveForm(oModel)}
	Local bLinePre			:= {|oModelGrid,  nLine,  cAction, cField| LinepreValid(oModelGrid,  nLine,  cAction, cField)}
	Local bActivate			:= {|oModel| activeForm(oModel) }
	Local bPreVal           := {|oModelGrid,  nLine,  cAction, cField| LinepreValid(oModelGrid,  nLine,  cAction, cField)}


	oStructForm	:= FWFormStruct( 1, cAliasForm , {|cCampo| AllTrim(cCampo)+"|" $ cCamposCab })
	oStructGrid := FWFormStruct( 1, cAliasGrid )//, {|cCampo| AllTrim(cCampo)+"|" $ cCamposDet })

	oModel	:= MPFormModel():New("MFSPCPC02",bPreValidacao,bPosValidacao,bCommit,bCancel)

	oStructForm:SetProperty( "Z2_CODUSER"		,   MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID,   'U_validaUsuario()'))


	oModel:AddFields( "SZ2FORM", /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	oModel:AddGrid( "SZ2GRID","SZ2FORM",oStructGrid,bLinePre,/*bLinePost*/,bPreVal,/*bPosVal*/)
	oModel:GetModel("SZ2GRID"):SetUniqueLine( { "Z2_CODUSER", "Z2_MAQUINA" } )

	//Nota: No modelo 2 os campos de cabeçalho precisam todos estar dentro da relação para correta gravação dos dados
	oModel:SetRelation("SZ2GRID",{{"Z2_CODUSER","Z2_CODUSER"}},(cAliasGrid)->(IndexKey(1)))
	oModel:SetPrimaryKey( { "Z2_FILIAL", "Z2_CODUSER", "Z2_MAQUINA" } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)

	oModel:GetModel("SZ2FORM"):SetDescription(cTitulo)

Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cAliasForm 		:= "SZ2"
	Local cAliasGrid 		:= "SZ2"
	Local cCamposCab        := "Z2_CODUSER|Z2_USUARIO|"
	Local cCamposDet        := "Z2_MAQUINA|Z2_DESCMAQ|"
	Local oModel 			:= Nil
	Local oStructForm		:= Nil
	Local oStructGrid		:= Nil
	Local oView				:= Nil
	Local nOperation		:= 3


	oModel 		:= FWLoadModel( "FSPCPC02" )
	nOperacao	:= oModel:GetOperation()

	oStructForm	:= FWFormStruct( 2, cAliasForm , {|cCampo| AllTrim(cCampo)+"|" $ cCamposCab })
	oStructGrid := FWFormStruct( 2, cAliasGrid , {|cCampo| AllTrim(cCampo)+"|" $ cCamposDet })

	oView 	:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField("VIEWFORM",oStructForm,"SZ2FORM")

	oView:AddGrid("VIEWGRID",oStructGrid,"SZ2GRID")

	oView:CreateHorizontalBox('SUPERIOR',20)
	oView:CreateHorizontalBox('INFERIOR',80)

	oView:SetOwnerView( "VIEWFORM",'SUPERIOR' )
	oView:SetOwnerView( "VIEWGRID",'INFERIOR' )


Return oView


/*
	Função para Validar os Dados Antes da Confirmação da Linha da Grid
*/
Static Function LinepreValid(oModelGrid, nLinha, cAcao, cCampo)
	Local oModel		:= oModelGrid:GetModel()
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.
	Local cCodUsuario	:= oModel:GetValue("SZ2FORM","Z2_CODUSER")
	Local cNomUsuario	:= oModel:GetValue("SZ2FORM","Z2_USUARIO")

	If ( cAcao == "SETVALUE" ) .And. ( cCampo == "Z2_MAQUINA" )
		oModel:SetValue("SZ2GRID","Z2_CODUSER",cCodUsuario)
		oModel:SetValue("SZ2GRID","Z2_USUARIO",cNomUsuario)
		oModel:SetValue("SZ2GRID","Z2_FILIAL",xFilial("SZ2"))
	Endif
Return lRet

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local nRecord		:= 0
	Local lRet			:= .T.


Return lRet

/*
	Função executado no Cancelamento da Tela de Cadastro
*/ 
Static Function cancForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

	If nOperation == MODEL_OPERATION_INSERT
		RollBackSX8()
	EndIf

Return lRet

/*
	Função para Validar os Dados Antes da Confirmação da Tela do Cadastro
*/
Static Function preValid(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

Return lRet

/*
	Função para Validar os Dados Após Confirmação da Tela de Cadastro - Verifica se pode incluir
*/
Static Function posValid(oModel)
	Local nOperation		:= oModel:GetOperation()
	Local cCodUsuario	    := oModel:GetValue("SZ2FORM","Z2_CODUSER")
    Local cMsgHelp          := ""
	Local lRet				:= .T.

	If ( nOperation == MODEL_OPERATION_INSERT )
		If Empty(cCodUsuario)
			cMsgHelp := "Código do usuário é obrigatório!"
			Help(,,"HELP",,cMsgHelp,1,0, NIL, NIL, NIL, NIL, NIL, {"Informe código do usuário."})
			lRet := .F.
		Endif
	Endif
Return lRet

/*/
	Função para Salvar os Dados do Cadastro usando MVC
/*/ 
Static Function saveForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRet 			:= .T.
	Local oModelGrid	:= oModel:GetModel( "SZ2GRID" )
	Local nX			:= 0
	Local nItem			:= 0
	Local cCodUsuario	:= oModel:GetValue("SZ2FORM","Z2_CODUSER")
	Local cNomUsuario	:= oModel:GetValue("SZ2FORM","Z2_USUARIO")

	if (nOperation == MODEL_OPERATION_UPDATE) .OR. (nOperation == MODEL_OPERATION_INSERT)
		////Atualizar numeracao dos itens
		If ( oModelGrid:Length() > 0 )
			for nX := 1 to oModelGrid:Length()
				oModelGrid:GoLine(nX)
				if !oModelGrid:IsDeleted()
					nItem++
					oModelGrid:SetValue("Z2_CODUSER",cCodUsuario)
					oModelGrid:SetValue("Z2_USUARIO",cNomUsuario)
					oModelGrid:SetValue("Z2_FILIAL",xFilial("SZ2"))
				endif
			Next
		endif
	endif

	FWModelActive(oModel)
	lRet := FWFormCommit(oModel)

Return lRet

/*/
	Validar usuário
/*/
User Function validaUsuario()
	Local aAreaSZ2      := SZ2->(GetArea())
	Local cMsgHelp      := ""
	Local lRet          := .T.
	Local cCodigoUser   := Z2_CODUSER

	dbSelectArea("SZ2")
	SZ2->(dbSetOrder(1))

	If ( SZ2->(dbSeek(FwxFilial("SZ2")+cCodigoUser)))
		cMsgHelp := "Já existe usuário cadastrado para esse código!"
		Help(,,"HELP",,cMsgHelp,1,0, NIL, NIL, NIL, NIL, NIL, {"Informe outro usuário."})
		lRet := .F.
	Endif

	RestArea(aAreaSZ2)
Return lRet
