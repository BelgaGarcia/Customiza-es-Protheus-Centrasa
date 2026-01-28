#include "totvs.ch"

/*/{Protheus.doc} MTA650I
Atualizar O.Ps filhas
@type function
@version 1.0
@author rodolfomagalhaes
@since 18/12/2024

/*/
User Function MTA650I()

	Local cOpAtual     := SC2->C2_NUM
	Local cItemOp      := SC2->C2_ITEM
	Local cSequeOp     := SC2->C2_SEQUEN
	Local aAreaSC2     := SC2->(GetArea())
	Local aArea        := GetArea()
	Local cLinha       := ""
	Local cPedVenda    := ""
	Local cPedItem     := ""
	Local cObservacoes := ""
	Local cObsCentrasa := ""
	// Local cIdBobina := ""
	// Local cInspecao := ""

	DbSelectArea("SC2")
	SC2->(DbSetOrder(1))

	If !(cSequeOp == "001")

		If SC2->(DbSeek(C2_FILIAL+cOpAtual+cItemOp+"001"))

			If !Empty(SC2->C2_LINHA)
				cLinha := SC2->C2_LINHA
			EndIf

			cPedVenda    := SC2->C2_PEDIDO
			cPedItem     := SC2->C2_ITEMPV
			cObservacoes := SC2->C2_OBS
			cObsCentrasa := SC2->C2_ZOBS

		EndIf

	EndIf

	// If !Empty(cPedVenda)
	// 	DbSelectArea("SC5")
	// 	If SC5->(DbSeek(FwxFilial("SCS5")+cPedVenda))
	// 		cIdBobina := SC5->C5_ZLOTCTL
	// 		cInspecao := SC5->C5_ZINSPE
	// 	EndIf
	// EndIf

	RestArea(aAreaSC2)
	RestArea(aArea)

	If !Empty(cLinha)

		RecLock("SC2", .F.)

		SC2->C2_LINHA  := cLinha
		SC2->C2_PEDIDO := cPedVenda
		SC2->C2_ITEMPV := cPedItem
		SC2->C2_OBS    := cObservacoes
		SC2->C2_ZOBS   := cObsCentrasa

		SC2->(MsUnlock())

	EndIf

Return
