#include "totvs.ch"

/*/{Protheus.doc} MT103FIM
Chamar enderecamento automatico apos classificar NF
@type function
@version 1.0
@author rodolfomagalhaes
@since 09/10/2024

@history 28/08/2025, Gabriel Gonçalves, Adicionada a função de movimento interno do Gerencial.
@history 24/11/2025, Elcilei Lopes, Adicionado rotina para baixar titulo de retorno beneficiamento

@see Desativar MV_DISTMOV para enderecamento automatico
/*/
User Function MT103FIM()
	Local nOpcao			:= PARAMIXB[1] // Opção Escolhida pelo usuario no aRotina
	Local nConfirma			:= PARAMIXB[2] // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
	Local aArea				:= GetArea()
	Local lLigaPrazoDev		:= GetNewPar("ZM_TESPTER",.F.)
	Local lLigaEndAuto		:= GetNewPar("ZM_ENDAUTM",.F.)
	Local cNaoClassifica	:= SuperGetMV("ZM_NOTEND",.F., '1924/2924' )// cfop's que nao devem ser endereçados.
	Local lLigaBaixGer		:= GetNewPar("ZM_BXGEREN",.F.)
	Local lLgBXDacaoInd		:= GetNewPar("FS_BXDCIND",.F.)

	If ( nOpcao == 3 ) .AND. ( nConfirma == 1 )
		If ( lLigaEndAuto == .T.) .And. (Findfunction("estoque.nf.u_enderecarAutomatico")) .AND. !ALLTRIM(SD1->D1_CF)$cNaoClassifica
			estoque.nf.U_enderecarAutomatico()
		EndIf

		If ( lLigaPrazoDev == .T. ) .And. (Findfunction("compras.documentos.U_DataPrazoDevolucao"))
			compras.documentos.U_DataPrazoDevolucao(1)
		EndIf

		If ( lLgBXDacaoInd == .T. ) .And. ( Findfunction("compras.entrada.u_baixaTituloDacaoIndustrializacao") )
			compras.entrada.u_baixaTituloDacaoIndustrializacao()
		Endif

	ElseIf ( nOpcao == 4 ) .AND. ( nConfirma == 1 )
		If ( lLigaBaixGer == .T. ) .And. (Findfunction("estoque.movimentointerno.u_Nfgerencial")) .And. (!Empty(SF1->F1_ZNFGER))
			estoque.movimentointerno.u_Nfgerencial()
		EndIf

		If ( lLigaEndAuto == .T.) .And. (Findfunction("estoque.nf.u_enderecarAutomatico")) .And. (!Empty(SF1->F1_ZNFGER)) .AND. !ALLTRIM(SD1->D1_CF)$cNaoClassifica
			estoque.nf.U_enderecarAutomatico()
		EndIf

	EndIf

	restarea(aArea)

Return nil
