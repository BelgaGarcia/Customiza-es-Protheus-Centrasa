#include 'totvs.ch'

/*/{Protheus.doc} MT100LOK
Substituir TES e Cód. Operação no documento de entrada caso exita devolução para a NF de Beneficiamento em questão.
@type function
@author rodolfomagalhaes
@since 11/09/2024

@history 17/11/2025, Elcilei Lopes - DsmSolutions, Refatorar código fonte sepando funcao do ponto de entrada

@See compras.entrada.mudaOperacaTesBeneficiamento()
/*/
User Function MT100LOK()
	Local lRet      		:= .T.

	If Findfunction("compras.entrada.u_mudaOperacaTesBeneficiamento" )
		lRet := compras.entrada.u_mudaOperacaTesBeneficiamento()
	Endif
	
Return lRet
