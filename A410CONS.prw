#include "totvs.ch"

/*/{Protheus.doc} A410CONS
SERVE P/INCLUIR BOTOES NA ENCHOICEBAR
É chamada no momento de montar a enchoicebar do pedido de vendas, e serve para incluir mais botões com rotinas de usuário

@type function
@version 1.0
@author helersonoliveira
@since 02/10/2024
@return array, novo menu

@history 26/11/2025, elcilei.lopes, Alterado a chamada da função para novo programa.

/*/
User Function A410CONS()

    aBotao := {}
    Aadd(aBotao , {"Inc.Item Sucata",{||faturamento.pedido.U_inclusaoSucata()},"Sucata"})

Return(aBotao)
