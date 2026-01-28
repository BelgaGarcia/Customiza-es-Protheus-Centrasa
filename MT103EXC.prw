#Include "Protheus.ch"

/*/ {Protheus.doc} MT103EXC

Ponto de entrada para validar exclusão Documento entrada

@type function
@author Elcilei Lopes - DSM
@since 09/12/2024
@version P12
@database ORACLE

@see : https://tdn.totvs.com/pages/releaseview.action?pageId=184781713
/*/
User Function MT103EXC()
	Local lRet                  := .T.                          as logical
	Local lLigExcRefaturamento  := GetNewPar("FS_LEXCREF",.F.)  as logical

	If ( lLigExcRefaturamento == .T. ) .And. ( Findfunction("compras.entrada.refaturamento.u_verificaExisteRefaturamento") )
		lRet := compras.entrada.refaturamento.u_verificaExisteRefaturamento()
	Endif

Return lRet
