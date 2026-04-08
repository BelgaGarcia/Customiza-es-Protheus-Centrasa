#Include "Protheus.ch"

/*/ {Protheus.doc} M410ALOK

Ponto de Entrada que permite adicionar validações para o tratamento de exclusão de um item do PV.

@type function
@author Elcilei Lopes - DSM
@since 30/01/2026
@version P12
@database ORACLE

@see : https://tdn.totvs.com/pages/releaseview.action?pageId=6784565
/*/
User Function M410LDEL()
 	Local lRet                      := .T.                          as logical
	Local lValidaPVRefaturamento	:= GetNewPar("FS_LEXCPVR",.F.)  as logical

	If ( lValidaPVRefaturamento == .T. ) .And. ( Findfunction("faturamento.pedido.refaturamento.u_validaManutencaoPedido") )
		lRet := faturamento.pedido.refaturamento.u_validaManutencaoPedido("E")
	Endif

Return lRet
