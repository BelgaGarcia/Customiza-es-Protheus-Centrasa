#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA103MNU - INCLUSÃO DE ROTINAS NO MENU

MenuDef - Monta o Array com opções da rotina, utilizado para inserir
novas opções no array aRotina

@author	   PTorres - DSM
@since	   Outubro/2024
@version   P12
@obs	   SIGACOM
@database  Oracle

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MTA103MNU()

    Local aArea := GetArea()
    Local lLiga := GetNewPar("ZM_TESPTER",.F.)

    If lLiga
        AADD( aRotina , { "Prazo x Prorrogação" , "compras.documentos.U_DataPrazoDevolucao(2)" , 0 , 4 , 0 , Nil } )
    Endif

    RestArea(aArea)

Return
