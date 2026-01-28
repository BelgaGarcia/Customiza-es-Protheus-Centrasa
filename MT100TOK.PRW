#Include "Protheus.ch"

/*/ {Protheus.doc} MT100TOK 

Ponto de entrada na operação antes da gravação da Nota Fiscal de Entrada

@type function
@author Elcilei Lopes - DSM
@since 02/10/2024
@version P12
@database ORACLE

@history 28/08/2025, Gabriel Gonçalves, Retirada a função de movimento interno do Gerencial e adicionado validação de classificação.

@see : https://tdn.totvs.com/pages/releaseview.action?pageId=6085400
/*/
User Function MT100TOK()
	Local lRet			:= .T.
	
	If (Findfunction("compras.entrada.u_AjustaArmazemGerencial")) .And. ( (l103Class .And. Alltrim(SF1->F1_ESPECIE) == "GER") .Or. ( Type("cEspecie") == "C" .And. Alltrim(cEspecie) == "GER"  ))
		lRet := compras.entrada.u_AjustaArmazemGerencial()
	EndIf
Return lRet
