#include "totvs.ch"

/*/{Protheus.doc} FSFISR01

Relatorio Fiscais de Notas (Entradas / Saidas)

@type Function
@author Gabriel Goncalves
@since 05/11/2025
@version P12
@database Oracle

/*/
User Function FSFISR01()
    Local nOpcao    := 0    as integer

    nOpcao  := Aviso("Relatórios Fiscais","Qual tipo de relatório deseja imprimir?",{"Entrada","Saida"})

    If nOpcao == 1
        fiscal.relatorios.u_notasEntrada()
    ElseIf nOpcao == 2
        fiscal.relatorios.u_notasSaida()
    EndIf
Return
