#include "totvs.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/{Protheus.doc} A175GRV
Ponto Entrada apos liberacao endereço CQ
@type function
@version 1.0
@author rodolfomagalhaes
@since 20/01/2025

@history 20/01/2025, Rodolfo Carvalho, U_fAddItemPedidoVendaProducao - Implementar ajuste pedido faturamento neste momento pois e aqui o saldo esta liberado
@history 07/05/2025, Gabriel Gonçalves, Reestruturada toda a rotina no ponto de entrada

/*/
User function A175GRV()
	Local aArea 	:= GetArea()

	Private cAliasSD7	:= ""

	If !FWIsInCallStack('U_FSPCPC01')
		ajustaApontameto()
	EndIf

	RestArea(aArea)
Return

/*
	Ajusta apontamento
*/
Static Function ajustaApontameto()
	Local cQuery	:= ""

	cQuery	:= queryLiberacao()
	MPSysOpenQuery(cQuery, cAliasSD7 := GetNextAlias())

	dbSelectArea("SH6")
	DbOrderNickName('DSMSH6001')

	(cAliasSD7)->(DbGoTop())
	While (cAliasSD7)->(!EoF())
		If SH6->(DbSeek(FwxFilial("SH6")+(cAliasSD7)->D7_PRODUTO+(cAliasSD7)->D7_LOTECTL))
			SH6->(DbSetOrder(3))

			If SH6->(DbSeek(FwxFilial("SH6")+(cAliasSD7)->D7_PRODUTO+SH6->H6_OP+"02"+(cAliasSD7)->D7_LOTECTL))
				If dsm.genericos.U_fValidaExisteEndereco((cAliasSD7)->D7_LOCDEST, (cAliasSD7)->D7_LOCALIZ)
					If enderecarQualidade()
						If grupoRolos()
							If !(Substr(SH6->H6_OP,9,3) == "001")
								u_alt381Auto(SH6->H6_OP, (cAliasSD7)->D7_PRODUTO, (cAliasSD7)->D7_LOTECTL, (cAliasSD7)->D7_LOCALIZ, (cAliasSD7)->D7_QTDE)
							EndIf
						EndIf

						// ADD item Pedido de Venda
						If Substr(SH6->H6_OP,9,3) == "001" // Somente executar para a O.P do Produto que esta no pedido de venda. Não executando para O.Ps filhas
							SetModulo("SIGAFAT","FAT")
							dsm.genericos.U_fAddItemPedidoVendaProducao()
							SetModulo("SIGAQIP","QIP")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		(cAliasSD7)->(DbSkip())
	EndDo

	(cAliasSD7)->(DbCloseArea())
Return

/*
	Query da liberação
*/
Static Function queryLiberacao()
	Local cQuery	:= ""	as character

	cQuery += " SELECT " + CRLF
	cQuery += "        * "		+ CRLF

	cQuery += " FROM " + CRLF
	cQuery += "     " + RetSQLTab("SD7") + CRLF

	cQuery += " WHERE " + CRLF
	cQuery += " 	    1 = 1 " + CRLF
	cQuery += "	 		AND " + RetSqlFil("SD7") + CRLF
	cQuery += " 		AND D7_NUMERO  = '"+SD7->D7_NUMERO+"'" + CRLF
	cQuery += " 		AND D7_PRODUTO  = '"+SD7->D7_PRODUTO+"'" + CRLF
	cQuery += " 		AND D7_LOTECTL  = '"+SD7->D7_LOTECTL+"'" + CRLF
	cQuery += " 		AND D7_TIPO  = '1'" + CRLF
	cQuery += " 		AND D7_ESTORNO  = ' '" + CRLF
	cQuery += "	    	AND " + RetSqlDel("SD7") + CRLF

	cQuery += " ORDER BY SD7.R_E_C_N_O_"
Return cQuery

/*
	Endereçar Saldo do Qualidade
*/
Static Function enderecarQualidade()
	Local aCabecalhoSDA	:= {}	as array
	Local aItemSDB		:= {}	as array
	Local aItensSDB		:= {}	as array
	Local aArea			:= GetArea()	as array
	Local lRetorno		:= .F.	as logical

	DbSelectArea("SDA")
	SDA->(DbSetOrder(1))

	SDA->(DbGoTop()) // Posiciona o cabeçalho
	If SDA->(DbSeek(xFilial("SDA") + (cAliasSD7)->D7_PRODUTO + (cAliasSD7)->D7_LOCDEST + (cAliasSD7)->D7_NUMSEQ))
		If SDA->DA_SALDO > 0
			aAdd(aCabecalhoSDA	, {"DA_PRODUTO", SDA->DA_PRODUTO	, Nil})
			aAdd(aCabecalhoSDA	, {"DA_NUMSEQ" , SDA->DA_NUMSEQ		, Nil})

			aAdd(aItemSDB	, {"DB_ITEM"   , "0001"			, Nil})
			aAdd(aItemSDB	, {"DB_ESTORNO", " "			, Nil})
			aAdd(aItemSDB	, {"DB_LOCALIZ", (cAliasSD7)->D7_LOCALIZ	, Nil})
			aAdd(aItemSDB	, {"DB_DATA"   , Date()			, Nil})
			aAdd(aItemSDB	, {"DB_QUANT"  , SDA->DA_SALDO	, Nil})

			aAdd(aItensSDB, aItemSDB)

			lMsErroAuto := .F.
			MATA265(aCabecalhoSDA, aItensSDB, 3)

			If lMsErroAuto
				cError := getError()
				addLogs(cError)
			Else
				lRetorno := .T.
			EndIf
		EndIf
	Else
		FWAlertError("Saldo a endereçar nao encontrado (SDA).", "Saldo")
	EndIf

	RestArea(aArea)
Return lRetorno

/*
	Valida Grupo de Rolos
*/
Static Function grupoRolos()
	Local nIndex		:= 0
	Local lRetorno		:= .F.
	Local cRoloGrupo	:= ""
	Local cParametro	:= ""

	// ZV_GRPROL1, ZV_GRPROL2, ZV_GRPROL3 ... ZV_GRPROL9
	For nIndex := 1 To 9
		cParametro := "ZV_GRPROL"+Alltrim(Str(nIndex))

		If FWSX6Util():ExistsParam(cParametro)
			cRoloGrupo += GetMV(cParametro)
		Else
			EXIT
		EndIf
	Next nIndex

	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(DbSeek(FwxFilial("SB1")+SD7->D7_PRODUTO))

	cGrupoProduto := Alltrim(SB1->B1_GRUPO) + SB1->B1_ZSUBGRU

	If cGrupoProduto $ cRoloGrupo
		lRetorno	:= .T.
	EndIf
Return lRetorno
