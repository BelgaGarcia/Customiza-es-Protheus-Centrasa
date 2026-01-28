#include "totvs.ch"

/*/{Protheus.doc} MA410MNU
Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.
@type function
@version 1.0
@author rodolfomagalhaes
@since 30/09/2024
@return array, novo menu
/*/
User Function MA410MNU()
    aAdd(aRotina, {"Imp. Plano Corte", "producao.op.U_gerarPedido()", 0, 3, 0, NIL})
    aAdd(aRotina, {"Impressão Plano de Corte", "U_RelPc01", 0, 3, 0, NIL})
Return Nil
