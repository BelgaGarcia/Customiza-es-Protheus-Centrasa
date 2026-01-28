#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} RelPc01
Função para geração de relatório de Plano de Corte
@type function
@version 1.0
@author rsimi
@since 18/02/2025
@return variant, Nenhum
/*/
User Function RelPc01()
	Local nx
	Local cArquivo          := ""
	Private cAlias          := GetNextAlias()
	Private cCRLF           := CRLF
	Private nMudaPag        := 0
	Private nLin            := 05
	Private nColItem        := 0
	Private nColProd        := 0
	Private nColLoc         := 0
	Private nColsDes        := 0
	Private nColun          := 0
	Private nColsQtdEnt     := 0
	Private nColqtdSol      := 0
	Private nColsSld        := 0
	Private nColiNVE        := 0
	Private nColdTnEC       := 0
	Private nColssol        := 0
	Private nColST          := 0
	Private NCOLIPI         := 0
	Private nColent         := 0
	Private nVlTot          := 0
	Private nVlToti         := 0
	Private cPqto           := ""
	Private cTransp         := ""
	Private cOpera          := ""
	Private nPage           := 1
	Private nLay
	Private nCol01          := 5
	Private nCol02          := 55
	Private nCol03          := 380
	Private nCol04          := 450
	Private nCol05          := 560
	Private nCol06          := 585
	Private nCol07          := 210
	Private nCol08          := 030
	Private nCol09          := 226
	Private nCol10          := 270
	Private nCol11          := 590
	Private nColFim         := 615
	Private nColC1          := 417
	Private nColC2          := 250
	Private nMeioPag        := (nColFim/2)
	Private cObs            := ""
	Private cObsb           := ""
	Private cObsc           := ""
	Private cNumReq         := ''
	Private lAdjustToLegacy := .F.
	Private lDisableSetup   := .F.
	Private nFlags          := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEMARGIN
	Private cPerg           := ""
	Private oPrinter        := nil
	Private _cPerg          := 'MTR105'
	Private aSt             := {}
	Private aIpI            := {}
	Private aAliqIpi        := {}
	Private aDIFAL          := {}
	Private aAliqIcm        := {}
	Private aTes            := {}
	Private oFont06         := nil
	Private oFont06n        := nil
	Private oFont08         := nil
	Private oFont08n        := nil
	Private oFont09         := nil
	Private oFont09n        := nil
	Private oFont10         := nil
	Private oFont10n        := nil
	Private oFont12N        := nil

	// Gera nome do arquivo temporário
	cArquivo := GetNextAlias() + "_" + cEmpAnt + "_" + cFilAnt + "_" + DToS(Date()) + "_" + StrTran(Time(),":","")

	// Configura impressora
	oPrinter := FWMSPrinter():New(cArquivo + ".rel", IMP_PDF, .F., GetTempPath(), .T.)
	oPrinter:SetResolution(78)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60,60,60,60)
	oPrinter:cPathPDF := GetTempPath()

	// Define fontes
	oFont06  := TFontEx():New(oPrinter,"Arial",20,20,.F.,.T.,.F.)
	oFont06n := TFontEx():New(oPrinter,"Arial",20,20,.T.,.T.,.F.)
	oFont08  := TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)
	oFont08n := TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)
	oFont09  := TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)
	oFont09n := TFontEx():New(oPrinter,"Arial",15,15,.F.,.T.,.F.)
	oFont10  := TFontEx():New(oPrinter,"Arial",10,10,.F.,.T.,.F.)
	oFont10n := TFontEx():New(oPrinter,"Arial",10,10,.T.,.T.,.F.)
	oFont12N := TFontEx():New(oPrinter,"Arial",12,12,.T.,.T.,.F.)

	nLay := oPrinter:GetOrientation()

	// Ajusta layout para paisagem
	If nLay == 2
		nColFim := 830
		nCol01  := 05
		nCol02  := 55
		nCol03  := 510
		nCol04  := 600
		nCol05  := 740
		nCol06  := 765
		nCol07  := 310
		nCol08  := 030
		nCol09  := 326
		nCol10  := 270
		nCol11  := 780
		nCol12  := 622
		nColC1  := nCol04
		nColC2  := 350
		oFont06  := TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)
		oFont06n := TFontEx():New(oPrinter,"Arial",08,08,.T.,.T.,.F.)
	EndIf

	// Gera cabeçalho
	Cabecalho(.F.,.T.)

	// Seção GERAL
	oBrush1 := TBrush():New(, CLR_GRAY)
	oPrinter:Fillrect({nLin, 000, nLin+25, nColFim}, oBrush1, "-2")
	nLin += 15
	nDescr := Len("GERAL")
	oPrinter:Say(nLin, (nColFim/2)-(nDescr/2), "GERAL", oFont09n:oFont,,CLR_WHITE)
	nLin += 10

	// Dados do cliente e produção
	oPrinter:Box(nLin,000,nLin+30,nMeioPag)
	oPrinter:Box(nLin,nMeioPag,nLin+30,nColFim)
	oPrinter:Line(nlin+15, 0, nlin+15, nColFim, CLR_BLACK,,)

	DbSelectArea('SC2')
	DbSetOrder(1)
	DbSeek(xFilial('SC2')+SC5->C5_NUM,.T.)

	DbSelectArea('SH1')
	DbSetOrder(5)
	DbSeek(xFilial('SH1')+SC2->C2_LINHA,.T.)

	oPrinter:Say(nLin+10, 5, 'Cliente: '+AllTrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")), oFont08n:oFont,,)
	oPrinter:Say(nLin+26, 5, 'LINHA DE PRODUCAO: '+SH1->H1_DESCRI, oFont08n:oFont,,)
	oPrinter:Say(nLin+10, (nMeioPag)+5, 'Data: '+DtoC(SC5->C5_EMISSAO), oFont08n:oFont,,)
	oPrinter:Say(nLin+26, (nMeioPag)+5, 'PRIORIDADE: '+SC2->C2_PRIOR, oFont08n:oFont,,)
	nLin += 30

	// Seção MATÉRIA PRIMA
	oPrinter:Fillrect({nLin, 000, nLin+25, nColFim}, oBrush1, "-2")
	nLin += 14
	nDescr := Len("MATÉRIA PRIMA")
	oPrinter:Say(nLin, (nColFim/2)-(nDescr/2), "MATÉRIA PRIMA", oFont09n:oFont,,CLR_WHITE)
	nLin += 10

	DbSelectArea('SB8')
	DbSetOrder(2)
	DbSeek(xFilial('SB8')+AvKey('',"B8_NUMLOTE")+SC5->C5_ZLOTCTL,.T.)

	oPrinter:Box(nLin,000,nLin+30,nColFim)
	oPrinter:Line(nlin, nMeioPag-100, nlin+30, nMeioPag-100, CLR_BLACK,,)
	oPrinter:Line(nlin+15, nMeioPag-100, nlin+15, nColFim, CLR_BLACK,,)
	oPrinter:Say(nLin+10, (nMeioPag-100)+5, 'Dimensões: '+AllTrim(Posicione("SB1",1,xFilial("SB1")+SB8->B8_PRODUTO,"B1_DESC")), oFont08n:oFont,,)
	oPrinter:Say(nLin+26, (nMeioPag-100)+5, 'Peso da Mp: '+Transform(SB8->B8_SALDO,"@E 999,999,999.99"), oFont08n:oFont,,)
	oPrinter:Say(nLin+26, (nMeioPag-100)+(nMeioPag/2), 'Cod Int: '+alltrim(SB8->B8_PRODUTO)+ "   Insp. Usina: "+AllTrim(SC5->C5_ZINSPE), oFont08n:oFont,,)


	nLin += 20
	oPrinter:Say(nLin, nColItem+5, 'ID '+AllTrim(SC5->C5_ZLOTCTL), oFont06n:oFont,,)
	nLin += 10

	// Seção PRODUÇÃO
	oPrinter:Fillrect({nLin, 000, nLin+25, nColFim}, oBrush1, "-2")
	nLin += 15
	nDescr := Len("PRODUÇÃO")
	oPrinter:Say(nLin, (nColFim/2)-(nDescr/2), "PRODUÇÃO", oFont09n:oFont,,CLR_WHITE)
	nLin += 11

	oPrinter:Fillrect({nLin, 000, nLin+30, nColFim}, oBrush1, "-2")
	oPrinter:Line(nlin+30, 000, nlin+30, nColFim, CLR_WHITE,,)
	oPrinter:Line(nlin, nCol02, nlin+30, nCol02, CLR_WHITE,,)
	oPrinter:Line(nlin, nCol10+90, nlin+30, nCol10+90, CLR_WHITE,,)
	oPrinter:Line(nlin, nCol10+180, nlin+30, nCol10+180, CLR_WHITE,,)
	nLin += 16

	// Cabeçalho da tabela
	oPrinter:Say(nLin, 20, "SQ", oFont09n:oFont,,CLR_WHITE)
	oPrinter:Say(nLin, nCol02+90, "DESCRIÇÃO DO ITEM", oFont09n:oFont,,CLR_WHITE)
	oPrinter:Say(nLin, nCol10+120, "QTDE", oFont09n:oFont,,CLR_WHITE)
	oPrinter:Say(nLin, nCol10+250, "PESO", oFont09n:oFont,,CLR_WHITE)
	nLin += 11

	// Gera conteúdo da tabela
	MkCont()
	nCont := 0
	TRB->(DbGoTop())
	While TRB->(!Eof())
		If !Empty(TRB->A2_OK)
			GeraGrid(nLin,.T.)
			nCont++

			oPrinter:Say(nLin+15, 30, AllTrim(Str(nCont))+'º', oFont08n:oFont,,)
			oPrinter:Say(nLin+10, nCol02+05, AllTrim(TRB->B1_DESC), oFont08n:oFont,,)
			oPrinter:Say(nLin+25, nCol02+05, 'Cod Interno: '+TRB->C2_PRODUTO, oFont08n:oFont,,)
			oPrinter:Say(nLin+25, nCol02+150, 'OP: '+TRB->(C2_NUM+C2_ITEM+C2_SEQUEN), oFont08n:oFont,,)

			If Val(TRB->C2_SEQUEN) > 1
				oPrinter:Say(nLin+15, nCol10+120, Transform(TRB->C2_ZQUANT,"@E 999,999,999.99"), oFont08n:oFont,,)
				oPrinter:Say(nLin+15, nCol10+250, Transform(TRB->C2_QUANT,"@E 999,999,999.99"), oFont08n:oFont,,)
			Else
				oPrinter:Say(nLin+15, nCol10+120, Transform(TRB->C6_ZQTDPLC,"@E 999,999,999.99"), oFont08n:oFont,,)
				oPrinter:Say(nLin+15, nCol10+250, Transform(TRB->C6_ZPESO,"@E 999,999,999.99"), oFont08n:oFont,,)
			EndIf
			nLin += 30
		EndIf
		TRB->(DbSkip())
	End

	// Seção OBSERVAÇÕES
	oPrinter:Fillrect({nLin, 000, nLin+25, nColFim}, oBrush1, "-2")
	nLin += 14
	nDescr := Len('OBSERVAÇÕES DO PLANO DE CORTE')
	oPrinter:Say(nLin, (nColFim/2)-100, 'OBSERVAÇÕES DO PLANO DE CORTE', oFont09n:oFont,,CLR_WHITE)
	nLin += 11

	nCont := 0
	TRB->(DbGoTop())
	While TRB->(!Eof())
		If !Empty(TRB->A2_OK)


			//If nCont == 0 .AND. !Empty(SC5->C5_ZENTREG)
				nCont++
				oPrinter:Box(nLin,000,nLin+30,nColFim)
				oPrinter:Say(nLin+10, 5, AllTrim(Str(nCont))+'º - '+AllTrim(TRB->C6_ZENTREG)+' '+AllTrim(TRB->C6_ZOBS), oFont08n:oFont,,)
				nLin += 16
                /*/
			Else
				If !Empty(TRB->C6_ZOBS)
					nCont++
					oPrinter:Box(nLin,000,nLin+30,nColFim)
					oPrinter:Say(nLin+10, 5, AllTrim(Str(nCont))+'º '+AllTrim(TRB->C6_ZOBS), oFont08n:oFont,,)
					nLin += 16
				EndIf
			EndIf
            /*/
		EndIf
		TRB->(DbSkip())
	End

	TRB->(DbCloseArea())

	If nCont == 0
		oPrinter:Box(nLin,000,nLin+30,nColFim)
	EndIf

	// Exibe preview do relatório
	oPrinter:Preview()
Return()

/*/{Protheus.doc} Cabecalho
Função para geração do cabeçalho do relatório
@type function
@version 1.0
@author Rubens_
@since 21/03/2025
@param lFim, logical, Indica se é o final do relatório
@param lIni, logical, Indica se é o início do relatório
@return variant, Posição vertical atual
/*/
Static Function Cabecalho(lFim, lIni)
	DEFAULT lFim := .F.
	DEFAULT lIni := .F.

	If oPrinter:Canceled()
		Return
	EndIf

	oPrinter:StartPage()
	cLogoD := GetSrvProfString("Startpath","") + "LOGO.BMP"

	oPrinter:SayBitmap(000,000,cLogoD,130,50)
	oPrinter:Say(20, nCol05-150, "Pedido Centrasa / NP ", oFont06n:oFont,,)
	oPrinter:Say(45, nCol05-150, SC5->C5_NUM, oFont06n:oFont,,)

	nLin := 60
Return nLin

/*/{Protheus.doc} GeraGrid
Função para criação do grid do relatório
@type function
@version 1.0
@author Rubens_
@since 21/03/2025
@param nLin, numeric, Linha atual do relatório
@param lBox, logical, Indica se deve desenhar a caixa
@return variant, Nenhum
/*/
Static Function GeraGrid(nLin, lBox)
	If lBox
		oPrinter:Box(nLin,000,nLin+30,nColFim)
	EndIf

	oPrinter:Line(nlin+15, nCol02, nlin+15, nCol10+90, CLR_BLACK,,)
	oPrinter:Line(nlin, nCol02, nlin+30, nCol02, CLR_BLACK,,)
	oPrinter:Line(nlin, nCol10+90, nlin+30, nCol10+90, CLR_BLACK,,)
	oPrinter:Line(nlin, nCol10+180, nlin+30, nCol10+180, CLR_BLACK,,)
Return()

/*/{Protheus.doc} MkCont
Função para criação da tabela temporária com os dados do relatório
@type function
@version 1.0
@author Desconhecido
@since Data não informada
@return variant, Nenhum
/*/
Static Function MkCont()
	Local aCpos      := {}
	Local aCampos    := {}
	Local aCampos1   := {}
	Local nI         := 0
	Private aRotina  := {}
	Private cCadastro := "Selecao de Op's"
	PRIVATE cIndexName := ''
	PRIVATE cIndexKey := ''
	PRIVATE cFilter := ''
	aRotOld := aRotina

	AADD(aRotina,{"Pesquisar", "AxPesqui", 0, 1})
	AADD(aRotina,{"Imprimir", "U_GerRel()", 0, 3})

	// Define campos da tabela temporária
	aAdd(aCpos,{"A2_OK"})
	aAdd(aCpos,{"C2_NUM"})
	aAdd(aCpos,{"C2_ITEM"})
	aAdd(aCpos,{"C2_SEQUEN"})
	aAdd(aCpos,{"C2_PRODUTO"})
	aAdd(aCpos,{"B1_DESC"})
	aAdd(aCpos,{"C2_QUANT"})
	aAdd(aCpos,{"C6_ZQTDPLC"})
	aAdd(aCpos,{"C6_ZPESO"})
	aAdd(aCpos,{"C6_ZOBS"})
	aAdd(aCpos,{"C6_ZENTREG"})

	// Obtém estrutura dos campos
	DbSelectArea("SX3")
	DbSetOrder(2)
	For nI := 1 To Len(aCpos)
		DbSeek(aCpos[nI,1])
		AADD(aCampos, {X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL})
		AADD(aCampos1, {X3_CAMPO, '', X3_TITULO, X3_PICTURE, X3_DECIMAL})
	Next nI

	// Cria tabela temporária
	oTempTable := FWTemporaryTable():New("TRB")
	oTempTable:SetFields(aCampos)
	oTempTable:Create()

	// Consulta dados
	DbSelectArea('SC6')
	cQuery := " SELECT SC6.R_E_C_N_O_ as REC, C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_QUANT, C6_ZQTDPLC, C6_ZPESO,C6_ZENTREG "
	cQuery += " FROM "+RetSqlName('SC2')+" SC2 "
	cQuery += " LEFT JOIN "+RetSqlName('SC6')+" SC6 ON C2_PEDIDO=C6_NUM AND C2_ITEMPV=C6_ITEM AND SC6.D_E_L_E_T_='' "
	cQuery += " WHERE C2_NUM='"+SC5->C5_NUM+"' AND SC2.D_E_L_E_T_='' ORDER BY C2_LINHA"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"graf")

	// Preenche tabela temporária
	DbSelectArea("graf")
	DbGoTop()
	While graf->(!Eof())
		SC6->(DbGoTo(graf->REC))
		Reclock("TRB",.T.)
		TRB->A2_OK      := '  '
		TRB->C2_NUM     := graf->C2_NUM
		TRB->C2_ITEM    := graf->C2_ITEM
		TRB->C2_SEQUEN  := graf->C2_SEQUEN
		TRB->C2_PRODUTO := graf->C2_PRODUTO
		TRB->B1_DESC    := Posicione("SB1",1,xFilial("SB1")+graf->C2_PRODUTO,"B1_DESC")
		TRB->C2_QUANT   := graf->C2_QUANT
		TRB->C6_ZQTDPLC := graf->C6_ZQTDPLC
		TRB->C6_ZPESO   := graf->C6_ZPESO
		TRB->C6_ZENTREG := graf->C6_ZENTREG
		TRB->C6_ZOBS    := AllTrim(SC6->C6_ZOBS)
		TRB->(MsUnlock())

		graf->(DbSkip())
	EndDo

	graf->(DbCloseArea())

	// Prepara browse
	DbSelectArea('TRB')
	DbGoTop()
	MarkBrow('TRB','A2_OK',,aCampos1,.F.,GetMark(,"TRB","A2_OK"))
	aRotina := aRotOld
Return()

/*/{Protheus.doc} GerRel
Função para fechar o browse
@type user function
@version 1.0
@author Desconhecido
@since Data não informada
@return variant, Nenhum
/*/
User Function GerRel()
	CloseBrowse()
Return()
