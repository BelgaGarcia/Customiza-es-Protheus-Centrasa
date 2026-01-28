#include "totvs.ch"

/*/{Protheus.doc} MT680EST
É chamado no estorno das produções PCP, modelo I e II. É utilizado para validar se pode ocorrer o estorno do apontamento ou não
Remover apontaento do pedido de venda caso necessário
@type function
@version 1.0
@author rodolfomagalhaes
@since 24/09/2024
@return logical, retornar autorizacao 
/*/
User Function MT680EST()

	Local lRet     := .T.
	Local lExecuta := SuperGetMV("ZV_ADDPRDP", .F., .T.) // Adiciona producao ao pedido de venda pai do plano de corte
	Local aArea    := GetArea()

	If lExecuta
		FWMsgRun(, {|oSay| lRet := dsm.genericos.U_fRemItemPedidoVendaProducao(oSay) }, "Processando", "Estornando item no pedido de vendas...")
	EndIf

	RestArea(aArea)

Return lRet
