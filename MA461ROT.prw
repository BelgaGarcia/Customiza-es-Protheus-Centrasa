#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MA461ROT - INCLUSÃO DE ROTINAS NO MENU

Têm por objetivo incluir opções personalizadas no menu "aRotina". 
Deve retornar um array onde cada subarray é uma linha a ser adicionada
no aRotina padrão.

@author	   PTorres - DSM
@since	   Outubro/2024
@version   P12
@obs	   SIGAFAT
@database  Oracle

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User function MA461ROT()

    Local lLiga := GetNewPar("ZM_TESPTER",.F.)

    If lLiga
        AADD( aRotina , { "Prazo x Prorrogação" , "compras.documentos.U_DataPrazoDevolucao(4)" , 9 , 0 } )
    Endif

Return
