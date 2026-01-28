#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} M460FIM - PONTO DE ENTRADA APÓS A GRAVAÇÃO DA NF-e

Após o destravamento de todas as tabelas envolvidas na gravação do
documento de saída, depois de fechar a operação realizada neste.

@author	   PTorres - DSM
@since	   Outubro/2024
@version   P12
@obs	   SIGAFAT
@database  Oracle

@see https://tdn.totvs.com/pages/releaseview.action?pageId=6784180
@see faturamento.pedido.Enviasaldogerencial

Alteracoes Realizadas desde a Estruturacao Inicial
Data          Programador     	Motivo
24/10/2024    Elcilei Lopes   	Criar documento de entrada para gerar saldo gerencial
24/10/2024    Gabriel Gonçalves Tela para preencher Peso e Volume da nota
/*/
//-------------------------------------------------------------------
User Function M460FIM()
	Local lLiga       := GetNewPar("ZM_TESPTER",.F.)
	Local lLigaSaldo  := GetNewPar("ZM_FATSGER",.F.)

	If ( lLiga == .T. ) .And. (Findfunction("compras.documentos.U_DataPrazoDevolucao"))
		compras.documentos.U_DataPrazoDevolucao(3)
	Endif

	If ( lLigaSaldo == .T.) .And. (Findfunction("faturamento.pedido.u_Enviasaldogerencial"))
		faturamento.pedido.u_Enviasaldogerencial()
	Endif

	If (FindFunction("faturamento.nf.u_telaPesoVolume"))
		faturamento.nf.u_telaPesoVolume()
	EndIf
Return
