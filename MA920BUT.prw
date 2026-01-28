#include "totvs.ch"

/*/{Protheus.doc} MA920BUT - Inclusão de Botões

O ponto é chamado no momento da definição dos botões padrões da consulta da nota Fiscal de Saída.
Para adicionar mais de um botão, é necessário adicionar mais subarrays ao array de retorno

@author	   Gabriel Gonçalves
@since	   27/10/2025
@version   P12
@database  Oracle

@see https://tdn.totvs.com/pages/releaseview.action?pageId=723310244
@see faturamento.nf.telaPesoVolume
/*/
User Function MA920BUT()
	Local aRetorno	:= {}	as array

	aRetorno	:= {{"POSCLI", {|| faturamento.nf.u_telaPesoVolume()}, "Peso e Volume"}}
Return aRetorno
