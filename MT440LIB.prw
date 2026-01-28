#include "totvs.ch"

/*/{Protheus.doc} MT440LIB

Redefinir quantidade a ser liberada

@author	   Gabriel Gonçalves
@since	   27/10/2025
@version   P12
@database  Oracle

@see https://tdn.totvs.com/display/public/PROT/MT440LIB+-+Redefinir+quantidade+a+ser+liberada
@see faturamento.nf.quantidadeLiberada
/*/
User Function MT440LIB()
	Local nRetorno	:= ParamIxb[1]	as numeric

	/*If (FindFunction("faturamento.nf.u_quantidadeLiberada"))
		nRetorno	:= faturamento.nf.u_quantidadeLiberada(nRetorno)
	EndIf*/
Return nRetorno
