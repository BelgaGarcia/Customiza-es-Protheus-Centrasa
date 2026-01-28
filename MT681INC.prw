#include "totvs.ch"

/*/{Protheus.doc} MT681INC
É executado após a gravação dos dados na rotina de inclusão do apontamento de produção PCP Mod2.
@type function
@author rodolfomagalhaes
@since 23/09/2024

@history 23/09/2024, rodolfo, Inserir item produzido no pedido de venda.
/*/
User Function MT681INC()

	Local lExecuta := SuperGetMV("ZV_ADDPRDP", .F., .T.) // Adiciona producao ao pedido de venda pai do plano de corte
	Local aArea    := GetArea()
	// Local oSay

	If lExecuta
		// FWMsgRun(, {|oSay| dsm.genericos.U_fAddItemPedidoVendaProducao(oSay) }, "Processando", "Inserindo item no pedido de vendas...")
	EndIf

	RestArea(aArea)

Return Nil
