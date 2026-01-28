#Include "Protheus.ch"

/*/ {Protheus.doc} MA103OPC

Ponto de entrada adicionar item no menu documento de entrada

@type function
@author Elcilei Lopes - DSM
@since 26/09/2024
@version P12
@database ORACLE

@history 12/12/2025, Elcilei Lopes - DSM, Adicionar a chamada da rotina de refaturamento

@see : https://tdn.totvs.com/pages/releaseview.action?pageId=6085341
/*/
User Function MA103OPC()
	Local aRet                  := {}
	Local lLigaNotaGerencial    := GetNewPar("ZM_NFGEREN",.F.)
	Local lLigaRetIndustrial	:= GetNewPar("FS_RETINDN",.F.)
	Local lLigaRefaturamento	:= GetNewPar("FS_LREFATM",.F.)


	If ( lLigaNotaGerencial == .T.)
		aAdd(aRet,{"Copia NF Gerencial", "compras.entrada.u_Notagerencial", 0, 5})
	Endif

	If (lLigaRetIndustrial == .T.) .And. ( Findfunction("compras.entrada.u_devolucaoIndustrializacao") )
		aAdd(aRet,{"Devolucao do Retorno", "compras.entrada.u_devolucaoIndustrializacao", 0, 3})
	Endif

	If (lLigaRefaturamento == .T.) .And. ( Findfunction("compras.entrada.refaturamento.u_GerarRefaturamento") )
		aAdd(aRet,{"Refaturamento Centrasa", "compras.entrada.refaturamento.u_GerarRefaturamento", 0, 4})
	Endif


Return aRet

