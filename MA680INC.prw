#include "totvs.ch"

/*/{Protheus.doc} MT680INC
Executado após a inclusão de uma ordem de produção PCP Mod. I.
@type function
@author rodolfomagalhaes
@since 23/09/2024

@history 23/09/2024, rodolfo, Inserir item produzido no pedido de venda.
/*/
User Function MT680INC()

	Local lExecuta := SuperGetMV("ZV_ADDPRDP", .F., .T.) // Adiciona producao ao pedido de venda pai do plano de corte
	Local aArea    := GetArea()
	Local oSay

	If lExecuta
		// FWMsgRun(, {|oSay| dsm.genericos.U_fAddItemPedidoVendaProducao(oSay) }, "Processando", "Inserindo item no pedido de vendas...")
	EndIf

	RestArea(aArea)

Return Nil
