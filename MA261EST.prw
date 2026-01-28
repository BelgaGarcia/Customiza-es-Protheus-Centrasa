#Include "Protheus.ch"

/*/ {Protheus.doc} MA261EST

Ponto de entrada Valida efetuação de estorno tranferencia
Este ponto de entrada é chamado após a confirmação do estorno das transferencias.

@type function
@author Elcilei Lopes - DSM
@since 09/12/2024
@version P12
@database ORACLE

@see : https://tdn.totvs.com/pages/releaseview.action?pageId=6087618
/*/
User Function MA261EST()
	Local lRet                  := .T.                          as logical
	Local lEstornoRefaturamento := GetNewPar("FS_LESTREF",.F.)  as logical

	If ( lEstornoRefaturamento == .T. ) .And. ( Findfunction("estoque.transferencia.refaturamento.u_validaEstornoRefaturamento") )
		lRet := estoque.transferencia.refaturamento.u_validaEstornoRefaturamento()
	Endif

Return lRet
