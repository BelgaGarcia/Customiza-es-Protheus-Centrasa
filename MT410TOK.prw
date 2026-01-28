#include "totvs.ch"

/*/{Protheus.doc} MT410TOK

Ponto de Entrada na validacao do pedido de Venda.
PE executado na validacao do Pedido de Venda.

@type function
@author	Gabriel Gonçalves
@since 31/01/2025
@version P12
@database Oracle

@return logical, lRet - Indica se foi validado
/*/
User Function MT410TOK()
	Local lRet		:= .T.

	//Altera a origem do produto de acordo com a entrada.
	If FindFunction("faturamento.pedido.u_origemProdutoEntrada")
		faturamento.pedido.u_origemProdutoEntrada()
	EndIf
Return lRet
