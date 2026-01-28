#Include "Protheus.ch"

/*/ {Protheus.doc} M410ALOK

Ponto de entrada Exclusão do pedido de vendas
RETORNA SE DEVE EXCLUIR O PEDIDO DE VENDAS
Chamado no programa de exclusão de Pedidos de Venda

@type function
@author Elcilei Lopes - DSM
@since 09/12/2024
@version P12
@database ORACLE

@see : https://tdn.totvs.com/pages/releaseview.action?pageId=6784143
/*/
User Function M410ALOK()
 	Local lRet                      := .T.                          as logical
	Local lValidaPVRefaturamento	:= GetNewPar("FS_LEXCPVR",.F.)  as logical

	If ( lValidaPVRefaturamento == .T. ) .And. ( Findfunction("faturamento.pedido.refaturamento.u_validaManutencaoPedido") )
		lRet := faturamento.pedido.refaturamento.u_validaManutencaoPedido()
	Endif

Return lRet
