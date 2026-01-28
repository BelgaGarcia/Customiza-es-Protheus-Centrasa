#include "totvs.ch"

/*/ {Protheus.doc} M410LIOK
busca complemento do icms
@type function
@author Helerson - DSM
@since 02/11/2024
@version P12
@database ORACLE
/*/

User Function M410LIOK()

	Local lRet := .T.
	Local lLigaBusca := GetNewPar("ZM_BUSCAIC",.F.)

	If ( lLigaBusca == .T.) .And. (Findfunction("fiscal.complementoFiscal.u_buscaIcms"))

		fiscal.complementoFiscal.u_buscaIcms()
		
	EndIf

Return lRet
