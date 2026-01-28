#include "totvs.ch"

/*/{Protheus.doc} A250PRLT
Executado na função A250DigLot( ) que e responsavel por fazer a digitatação dos Lotes que devem ser criados. 
NA DIG. DOS LOTES QDO UTILIZA PROD. AUTO

@type function
@version 1.0
@author rodolfomagalhaes
@since 20/01/2025

@obs 
 Garantir geracao LOTE caso o gatilho falhe para exibir na tela de digitacao padrao e mostrar ao usuario o codigo gerado

@return array, aRet - Novo Lote Sugerido
/*/
User Function A250PRLT()

	Local cLote    := ParamIXB[1] //-- Lote sugerido pelo sistema
	Local cData    := ParamIXB[2] //-- Data de Validade sugerida pelo sistema
	Local lExibeLt := ParamIXB[3] //-- Exibir a getdados para confirmação da sugestão do lote na tela.
	Local aRet     := {cLote, cData, lExibeLt} //-- Customizações do Cliente

	If Len(Alltrim(cLote)) <= 6
		aRet := dsm.genericos.U_fBuscaProximoLote(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), SC2->C2_PRODUTO)
	EndIf

Return aRet

