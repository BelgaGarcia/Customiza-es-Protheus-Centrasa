#include "totvs.ch"  

/*/{Protheus.doc} M410PVNF

Ponto de Entrada na preparação do documento no pedido de venda
	
@type function	
@author	Gabriel Goncalves
@since 11/02/2025
@version P12
@database Oracle
/*/
User Function M410PVNF()
	Local lRetorno		:= .T.
	Local lLigaBusca	:= GetNewPar("ZM_BUSCAIC", .F.)
	
	If lRetorno .And. lLigaBusca .And. (Findfunction("fiscal.complementoFiscal.u_buscaIcms"))
		lRetorno	:= fiscal.complementoFiscal.u_buscaIcms()
	EndIf
Return lRetorno
