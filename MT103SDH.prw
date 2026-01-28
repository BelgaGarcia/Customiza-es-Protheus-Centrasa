#include "totvs.ch"

/*/{Protheus.doc} MT103SDH
Ponto de Entrada localizado na função NfeNfeCob documento de cobertura que tem comofuncionalidade principal
passar os parâmetros de cabeçalho e itens para permitir a gravação posterior na tabela SD1 entre outras
que contenham dados vindos da SDH.

Controlar os dados preenchidos automatico NF cobertura a partir SDH

@type function
@version 1.0
@author rodolfomagalhaes
@since 02/10/2024
@return array, cabecaolho e item nf entrada
/*/
User Function MT103SDH()

    Local aCab        := ParamIXB[1]
    Local aItens      := ParamIXB[2]
    Local nItem
    Local nPosLoteCtl   := 0
/*/
    If Len(aItens) > 0

        nPosLoteCtl := aScan(aItens[1], { |x| Upper(Alltrim(x[1])) == "D1_LOTECTL" })

        For nItem := 1 to len(aItens)

            aItens[nItem][nPosLoteCtl][2] := SD1->D1_LOTECTL

        Next

    EndIf
/*/
Return({aCab,aItens})
