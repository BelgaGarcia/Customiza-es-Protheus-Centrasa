#include "totvs.ch"

/*/{Protheus.doc} MT680VAL
Validar apontamento de producao coletando o peso do Amarrado Centrasa
@type function
@author rodolfomagalhaes
@since 21/06/2024
/*/
User Function MT680VAL()

	Local lTudoOk   := ParamIXB

	If Alltrim(M->H6_OPERAC) == "02"

		If !Empty(M->H6_PRODUTO)
			DbSelectArea("SB1")
			SB1->(DbSetORder(1))
			SB1->(DbSeek(FwxFilial("SB1")+M->H6_PRODUTO))
			If (SB1->B1_UM $("KG|TL"))

				If M->H6_ZQUANT > 0
					lTudoOk := .T.
				Else
					lTudoOk := .F.
				EndIf

				If !lTudoOk
					FWAlertInfo("Para apontamentos de Expedição/Pesagem deste produto o campo Amarrado deverá ser informado!", "Aviso!")
				EndIf

			Else

				If M->H6_ZPESO > 0 .AND. M->H6_ZPESOBT > 0
					lTudoOk := .T.
				Else
					lTudoOk := .F.
				EndIf

				If !lTudoOk
					FWAlertInfo("Para apontamentos de Expedição/Pesagem o campo Peso e Peso Bruto deverá ser informado!", "Aviso!")
				EndIf

			EndIf

		EndIf



	Else
		lTudoOk:= .T.
	Endif

Return(lTudoOk)
