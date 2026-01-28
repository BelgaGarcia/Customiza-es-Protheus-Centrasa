#include "totvs.ch"

#DEFINE MSG_ALERT    "Acompanhamento da evolução e programação"

/*/ {Protheus.doc} FSPCPC01

Acompanhamento da evolução e programação do chão de fábrica.

@type function
@author Elcilei Lopes - DSM
@since 06/09/2024
@version P12
@database ORACLE
/*/

User Function FSPCPC01()
	Local oBrowse   := Nil
	Local aColunas  := {}

	Private aRotina     := {}
	Private aPesquisa 	:= {}
	Private CAliasTMP	:= GetNextAlias()
	Private cTitulo     := "Acompanhamento da evolução e programação do chão de fábrica - ( 2 Clicks para mais OBS. )"
	Private oTable    	:= Nil

	SetModulo("SIGAPCP","PCP")

	aRotina := MenuDef()

	If ( !geraTabelaTmp(@aColunas) )
		Return
	Endif
	If getQryOrdemProducao()
		(cAliasTmp)->(DBSetOrder(1))
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias(oTable:getAlias())
		oBrowse:SetTemporary(.T.)
		oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
		oBrowse:OptionReport(.F.) //Disable Report Print
		oBrowse:SetFields(aColunas)
		oBrowse:DisableDetails()
		oBrowse:SetDescription(cTitulo)
		oBrowse:SetSeek(.T., aPesquisa)
		oBrowse:SetDoubleClick( {|| fDupClique() } )

		oBrowse:AddLegend("Empty(C2_DATRF)", "BR_VERDE")
		oBrowse:AddLegend("!Empty(C2_DATRF)", "BR_VERMELHO")

		oBrowse:Activate()

		If Select(cAliasTmp) > 0
			(cAliasTmp)->(DbCloseArea())
			oTable:Delete()
		EndIf

	Endif

	SetModulo("SIGA"+cModulo,cModulo)

Return

Static Function fDupClique()
	ShowLog((cAliasTmp)->C2_ZOBS)
Return

/*/
	Definição do Menu do cadastro
/*/
Static Function MenuDef()
	Local aRotina		:= {}
	Local aApontamento	:= {}

	aAdd( aApontamento, { "Blank/Chapa"			,"U_FSPCPC1CHAMAROTINAS('A')"			, 0, 6, 0, NIL } )
	aAdd( aApontamento, { "Rolo"				,"U_FSPCPC1CHAMAROTINAS('B')"			, 0, 6, 0, NIL } )
	aAdd( aApontamento, { "Aglutina Lotes"		,"U_FSPCPC1CHAMAROTINAS('D')"			, 0, 6, 0, NIL } )

	aAdd( aRotina, { "Imprimir Etiqueta Tiras"  ,"producao.etiquetas.u_etiquetaTiras"	, 0, 5, 0, NIL } )
	aAdd( aRotina, { "Apontamento"              ,aApontamento							, 0, 6, 0, NIL } )
	aAdd( aRotina, { "Alterar Prioridade/Linha" ,"producao.op.u_AlterarPrioridadeLinha"	, 0, 4, 0, NIL } )
	//aAdd( aRotina, { "Carga Máquina"            ,"U_FSPCPC1CHAMAROTINAS('C')"			, 0, 8, 0, NIL } )
	aAdd( aRotina, { "Conhecimento"            	,"estoque.conhecimento.u_Produto"		, 0, 8, 0, NIL } )
Return aRotina

/*/
	Gerar tabela TMP Browser
/*/
Static Function geraTabelaTmp(aColunas)
	Local aFields			:= {}
	Local aTamanhoX3 		:= {}
	Local bError			:= {|| }
	Local cMsgProcesso		:= ""
	Local lRet				:= .T.
	Local nTamCampo         := 0

	aColunas    := {}
	aPesquisa   := {}

	Begin Sequence

		lRet		:= .T.
		cError 		:= ""
		bError 		:= ErrorBlock({|oError| getErrorBlock(oError,@cError) } )

		oTable   	:= FWTemporaryTable():New( cAliasTmp )
		oTable:SetClobMemo(.T.)


		criaPequisaBrowser("Linha Prio","C",TAMSX3('C2_LINHA')[1]+TAMSX3('C2_PRIOR')[1] +TAMSX3('C5_NUM')[1],0,"@!","C2_LINHA+C2_PRIOR+C5_NUM",1)


		aTamanhoX3	:= FWTamSX3("C2_LINHA")
		aAdd(aFields,{"C2_LINHA" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Linha Prod.","C2_LINHA" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})
		criaPequisaBrowser("Linha Prod.",aTamanhoX3[3],aTamanhoX3[1],aTamanhoX3[2], "@!", "C2_LINHA",2)

		aTamanhoX3	:= FWTamSX3("C2_PRIOR")
		aAdd(aFields,{"C2_PRIOR" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Prioridade","C2_PRIOR" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})
		criaPequisaBrowser("Prioridade",aTamanhoX3[3], aTamanhoX3[1],aTamanhoX3[2],"@!", "C2_PRIOR",3)

		aTamanhoX3	:= FWTamSX3("C5_NUM")
		aAdd(aFields,{"C5_NUM" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Num. do Pedido","C5_NUM" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@X"})
		criaPequisaBrowser("Num. do Pedido",aTamanhoX3[3],aTamanhoX3[1],aTamanhoX3[2], "@X", "C5_NUM",4)

		aTamanhoX3	:= FWTamSX3("C5_ZINSPE")
		aAdd(aFields,{"C5_ZINSPE" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Inspecao","C5_ZINSPE" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})
		criaPequisaBrowser("Inspecao",aTamanhoX3[3], aTamanhoX3[1]	,aTamanhoX3[2], "@!", "C5_ZINSPE",5)

		aTamanhoX3	:= FWTamSX3("C5_ZLOTCTL")
		aAdd(aFields,{"C5_ZLOTCTL" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"ID Bobina","C5_ZLOTCTL" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})
		criaPequisaBrowser("Lote CTL",aTamanhoX3[3], aTamanhoX3[1],aTamanhoX3[2],"@!", "C5_ZLOTCTL",6)

		aTamanhoX3	:= FWTamSX3("D1_COD")
		aAdd(aFields,{"D1_COD" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Cod. da Bobina","D1_COD" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})
		criaPequisaBrowser("Cod. da Bobina",aTamanhoX3[3], aTamanhoX3[1],aTamanhoX3[2],"@!", "D1_COD",7)

		aTamanhoX3	:= FWTamSX3("B1_DESC")
		aAdd(aFields,{"TMP_DESBOB" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Desc. da Bobina","TMP_DESBOB" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})
		criaPequisaBrowser("Desc. da Bobina",aTamanhoX3[3], aTamanhoX3[1],aTamanhoX3[2],"@!", "TMP_DESBOB",8)

		aTamanhoX3	:= FWTamSX3("C2_NUM")
		nTamCampo   += aTamanhoX3[1]

		aTamanhoX3	:= FWTamSX3("C2_ITEM")
		nTamCampo   += aTamanhoX3[1]

		aTamanhoX3	:= FWTamSX3("C2_SEQUEN")
		nTamCampo   += aTamanhoX3[1]

		aAdd(aFields,{"TMP_ORDEM" , "C" , nTamCampo	,0 })
		aAdd(aColunas,{"Ord.Producao","TMP_ORDEM" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})
		criaPequisaBrowser("Ord.Producao", aTamanhoX3[3], aTamanhoX3[1]	,aTamanhoX3[2],"@!", "TMP_ORDEM",9)

		aTamanhoX3	:= FWTamSX3("C2_PRODUTO")
		aAdd(aFields,{"C2_PRODUTO" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Produto","C2_PRODUTO" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("B1_DESC")
		aAdd(aFields,{"TMP_DESPRD" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Descricao Produto","TMP_DESPRD" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})
		criaPequisaBrowser("Desc. Produto",aTamanhoX3[3], aTamanhoX3[1],aTamanhoX3[2],"@!", "TMP_DESPRD",10)

		aTamanhoX3	:= FWTamSX3("C2_QUANT")
		aAdd(aFields,{"TMP_AMARRA" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Qtde Amarrado","TMP_AMARRA" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@E 999999999.99"})

		aTamanhoX3	:= FWTamSX3("C2_QUANT")
		aAdd(aFields,{"C2_QUANT" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Qtde da OP","C2_QUANT" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@E 999999999.99"})

		aTamanhoX3	:= FWTamSX3("C2_QUJE")
		aAdd(aFields,{"C2_QUJE" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Qtde Produzida","C2_QUJE" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@E 999999999.99"})

		aTamanhoX3	:= FWTamSX3("C2_DATPRF")
		aAdd(aFields,{"C2_DATPRF" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Dt.Prev.Entrega","C2_DATPRF" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@D"})

		aTamanhoX3	:= FWTamSX3("C2_ROTEIRO")
		aAdd(aFields,{"C2_ROTEIRO" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Roteiro Oper.","C2_ROTEIRO" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("H8_OPER")
		aAdd(aFields,{"H8_OPER" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Operacao","H8_OPER" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("H8_RECURSO")
		aAdd(aFields,{"H8_RECURSO" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Cod. do recurso","H8_RECURSO" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("H8_DTINI")
		aAdd(aFields,{"H8_DTINI" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"DT Inicial","H8_DTINI" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("H8_HRINI")
		aAdd(aFields,{"H8_HRINI" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Hr Inicial","H8_HRINI" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("H8_DTFIM")
		aAdd(aFields,{"H8_DTFIM" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"DT Final","H8_DTFIM" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("H8_HRFIM")
		aAdd(aFields,{"H8_HRFIM" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Hr Final","H8_HRFIM" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("A1_CGC")
		aAdd(aFields,{"A1_CGC" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"CNPJ/CPF","A1_CGC" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("A1_NOME")
		aAdd(aFields,{"A1_NOME" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Nome","A1_NOME" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("C5_ZENTREG")
		aAdd(aFields,{"C5_ZENTREG" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Cli Entrega","C5_ZENTREG" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("C5_ZOBS")
		aAdd(aFields,{"C5_ZOBS" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Observacao", "C5_ZOBS" , aTamanhoX3[3] ,aTamanhoX3[1], aTamanhoX3[2], "@!"})

		aTamanhoX3	:= FWTamSX3("C2_ZOBS")
		aAdd(aFields,{"C2_ZOBS" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Observacao", "C2_ZOBS" , aTamanhoX3[3] ,aTamanhoX3[1], aTamanhoX3[2], "@!"})

		aTamanhoX3	:= FWTamSX3("C2_LOCAL")
		aAdd(aFields,{"C2_LOCAL" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"Armazem","C2_LOCAL" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		aTamanhoX3	:= FWTamSX3("C2_DATRF")
		aAdd(aFields,{"C2_DATRF" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2] })
		aAdd(aColunas,{"DT Fechamento","C2_DATRF" , aTamanhoX3[3] ,aTamanhoX3[1]	,aTamanhoX3[2],"@!"})

		oTable:SetFields( aFields )




		oTable:AddIndex("01", {"C2_LINHA","C2_PRIOR","C5_NUM"})
		oTable:AddIndex("02", {"C2_LINHA"})
		oTable:AddIndex("03", {"C2_PRIOR"})
		oTable:AddIndex("04", {"C5_NUM"})
		oTable:AddIndex("05", {"C5_ZINSPE"})
		oTable:AddIndex("06", {"C5_ZLOTCTL"})
		oTable:AddIndex("07", {"D1_COD"})
		oTable:AddIndex("08", {"TMP_DESBOB"})
		oTable:AddIndex("09", {"TMP_ORDEM"})
		oTable:AddIndex("10", {"TMP_DESPRD"})


		oTable:Create()

	End Sequence

	ErrorBlock(bError)

	If ( !Empty(cError) )
		cMsgProcesso += "Falha criar tabela temporaria." + CRLF + cError
		lRet := .F.
		MsgAlert(cMsgProcesso, MSG_ALERT)
	Endif

Return lRet

/*/
	query para selecionar ordem de producao
/*/
Static Function getQryOrdemProducao()
	Local cQuery 	:= ""
	Local nContReg	:= 0
	Local cCodUser	:= RetCodUsr()
	Local cMaquina 	:= ""

	dbSelectArea("SZ2")
	SZ2->(dbSetOrder(1))

	If ( SZ2->(dbSeek(FwxFilial("SZ2")+cCodUser)))
		While !SZ2->(Eof()) .And. SZ2->Z2_FILIAL == xFilial("SZ2") .And. SZ2->Z2_CODUSER == cCodUser
			If Empty(cMaquina)
				cMaquina := "('"+SZ2->Z2_MAQUINA+"'"
			Else
				cMaquina += ",'"+SZ2->Z2_MAQUINA+"'"
			Endif
			SZ2->(dbSkip())
		Enddo
		cMaquina += ")"

		cQuery += "INSERT INTO " + oTable:getRealName()
		cQuery += "     ("+CRLF
		cQuery += "     	TMP_ORDEM, C2_LINHA,C2_PRIOR,C5_NUM,C5_ZINSPE,C5_ZLOTCTL, D1_COD, TMP_DESBOB" +CRLF
		cQuery += "     	,TMP_DESPRD,TMP_AMARRA,C2_QUANT,C2_QUJE,C2_DATPRF,C2_ROTEIRO,C2_PRODUTO,C2_ZOBS, H8_OPER" +CRLF
		cQuery += "     	,H8_RECURSO, H8_DTINI, H8_HRINI, H8_DTFIM, H8_HRFIM, A1_CGC, A1_NOME, C5_ZOBS, C2_LOCAL" + CRLF
		cQuery += "     	,C5_ZENTREG, C2_DATRF" + CRLF
		cQuery += "		)" +CRLF

		cQuery += "SELECT DISTINCT "+CRLF
		cQuery += "		 C2_NUM||C2_ITEM||C2_SEQUEN AS TMP_ORDEM, C2_LINHA,C2_PRIOR,C5_NUM,C5_ZINSPE, C5_ZLOTCTL, D1_COD" + CRLF
		cQuery += " 	 ,SB1A.B1_DESC AS TMP_DESBOB"+CRLF
		cQuery += "		 ,SB1.B1_DESC AS TMP_DESPRD"+CRLF
		cQuery += "		,CASE "+CRLF
		cQuery += "		    WHEN  ( C2_QUANT > 0 ) AND ( B5_FATARMA > 0) THEN  CEIL(C2_QUANT/B5_FATARMA) "+CRLF
		cQuery += "		 ELSE "+CRLF
		cQuery += "         1 END AS TMP_AMARRA"+CRLF
		cQuery += "		,C2_QUANT, C2_QUJE, C2_DATPRF, C2_ROTEIRO, C2_PRODUTO, UTL_RAW.CAST_TO_VARCHAR2(C2_ZOBS) AS C2_ZOBS, G2_OPERAC AS H8_OPER, G2_RECURSO AS H8_RECURSO, C2_DATPRF AS H8_DTINI, '09:00' AS H8_HRINI, C2_DATPRF AS H8_DTFIM"+CRLF
		cQuery += "		, '09:10' AS H8_HRFIM, A1_CGC, A1_NOME, UTL_RAW.CAST_TO_VARCHAR2(C5_ZOBS) AS C5_ZOBS, C2_LOCAL, C5_ZENTREG, C2_DATRF"+CRLF

		cQuery += "FROM "+CRLF
		cQuery += "		"+RetSQLTab("SC2")+CRLF

		cQuery += "LEFT JOIN "+RetSQLTab("SB5")+" ON 1 = 1"+CRLF
		cQuery += "		AND "+RetSqlFil("SB5")+CRLF
		cQuery += "		AND "+RetSqlDel("SB5")+CRLF
		cQuery += "		AND SB5.B5_COD = SC2.C2_PRODUTO"+CRLF

		cQuery += "LEFT JOIN "+RetSQLTab("SB1")+" ON 1 = 1"+CRLF
		cQuery += "		AND "+RetSqlFil("SB1")+CRLF
		cQuery += "		AND "+RetSqlDel("SB1")+CRLF
		cQuery += "		AND SB1.B1_COD = SC2.C2_PRODUTO"+CRLF

		cQuery += "LEFT JOIN "+RetSQLTab("SC6")+" ON 1 = 1"+CRLF
		cQuery += "		AND "+RetSqlFil("SC6")+CRLF
		cQuery += "		AND "+RetSqlDel("SC6")+CRLF
		cQuery += "		AND SC6.C6_NUM = SC2.C2_PEDIDO"+CRLF
		cQuery += "		AND SC6.C6_ITEM = SC2.C2_ITEMPV"+CRLF

		cQuery += "LEFT JOIN "+RetSQLTab("SC5")+" ON 1 =1"+CRLF
		cQuery += "		AND "+RetSqlFil("SC5")+CRLF
		cQuery += "		AND "+RetSqlDel("SC5")+CRLF
		cQuery += "		AND SC5.C5_NUM = SC2.C2_PEDIDO "+CRLF

		cQuery += "LEFT JOIN "+RetSQLTab("SG2")+" ON 1 = 1"+CRLF
		cQuery += "		AND "+RetSqlFil("SG2")+CRLF
		cQuery += "		AND "+RetSqlDel("SG2")+CRLF
		cQuery += "		AND G2_PRODUTO = SC2.C2_PRODUTO"+CRLF
		cQuery += "		AND ( SG2.G2_OPERAC = ' ' OR SG2.G2_OPERAC = '01' )"+CRLF

		cQuery += "LEFT JOIN "+RetSQLTab("SA1")+" ON 1 = 1"+CRLF
		cQuery += "		AND "+RetSqlFil("SA1")+CRLF
		cQuery += "		AND "+RetSqlDel("SA1")+CRLF
		cQuery += "		AND SA1.A1_COD = SC5.C5_CLIENT"+CRLF
		cQuery += "		AND SA1.A1_LOJA = SC5.C5_LOJAENT"+CRLF

		cQuery += "LEFT JOIN "+RetSQLTab("SD4")+" ON 1 = 1"+CRLF
		cQuery += "		AND  "+RetSqlFil("SD4")+CRLF
		cQuery += "		AND  "+RetSqlDel("SD4")+CRLF
		cQuery += "		AND  SD4.D4_OP =   SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN"+CRLF
		cQuery += "		AND SD4.D4_COD = SC2.C2_PRODUTO" +CRLF

		cQuery += " LEFT JOIN SD1010 SD1" +CRLF
		cQuery += "       ON "+RetSqlFil("SD1")+CRLF +CRLF
		cQuery += "          AND SD1.D_E_L_E_T_ = '  '" +CRLF
		cQuery += "         AND D1_LOTECTL <> ' ' AND  D1_LOCAL<>'ZZ' " +CRLF
		cQuery += "        AND SD1.D1_LOTECTL = SC5.C5_ZLOTCTL" +CRLF

		cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1A" +CRLF
		cQuery += "     ON 1 = 1" +CRLF
		cQuery += "        AND SB1A.D_E_L_E_T_ = ' '" +CRLF
		cQuery += "        AND SB1A.B1_COD = SD1.D1_COD" +CRLF

		cQuery += " WHERE"+CRLF
		cQuery += "		"+RetSqlFil("SC2")+CRLF
		cQuery += "		AND "+RetSqlDel("SC2")+CRLF
		cQuery += "		AND C2_LINHA IN "+ cMaquina	+CRLF
		cQuery += " ORDER BY C2_LINHA,C2_PRIOR,C5_NUM"+CRLF

		nContReg := TCSqlExec(cQuery)

		If  ( nContReg >= 0 )
			lRet := .T.
		Else
			cMsg := "Não há dados a serem impresso!"
			Help(,,"HELP",,"Nenhum regstro encontrado",1,0)
			lRet := .F.
		Endif
	Else
		Help(,,"HELP",,"Usuário não possui Maquina cadastrada",1,0)
		lRet := .F.
	Endif
Return lRet

/*/
	Consultar descricao do produto SD4
/*/
Static Function getDescProduto(cNumOrdemProducao)
	Local cRet					:= ""

	Default cNumOrdemProducao	:= ""

	If SD4->(dbSeek(FwxFilial("SD4")+cNumOrdemProducao))
		cRet := posicione("SB1",1,xFilial("SB1")+SD4->D4_PRODUTO,"B1_DESC")
	Endif
Return cRet

/*/
	Pesquisa no registro do Browser
/*/
Static Function criaPequisaBrowser(cTitulo,cTipo,nTamanho,nDecimal,cPictur,cNomeCampo,nOrdem)

	aAdd(aPesquisa,{cTitulo,{{"LookUp",cTipo,nTamanho,nDecimal,cTitulo,cPictur}},nOrdem,.T.})

	//aSeek :=  {{"Código", {{"LookUp", "C", 3, 0, "",,}} , 1, .T. }}
Return

/*/
	Chamar rotina do processo
/*/
User Function FSPCPC1CHAMAROTINAS(cOpcao)
	Local nRec        := (cAliasTmp)->(Recno())
	Local nBlankSGrup := "" // Alltrim(SuperGetMV("ZV_GRPBLK1", .F., "0105|0106|0107|0108|0109|0110")) // Grupo Blank
	Local nRoloSGrup  := "" // Alltrim(SuperGetMV("ZV_GRPROL1", .F., "0111|0112|0113|0114|0116|0201")) // Grupo Rolos
	Local cGrupoProd  := ""
	Local nIndex	  := 0
	Local cParametro  := ""

	// ZV_GRPBLK1, ZV_GRPBL2, ZV_GRPBLK3 ... ZV_GRPBLK9
	For nIndex := 1 To 9
		cParametro := "ZV_GRPBLK"+Alltrim(Str(nIndex))
		If FWSX6Util():ExistsParam(cParametro)
			nBlankSGrup += GetMV(cParametro)
		Else
			EXIT
		EndIf
	Next nIndex

	// ZV_GRPROL1, ZV_GRPROL2, ZV_GRPROL3 ... ZV_GRPROL9
	For nIndex := 1 To 9
		cParametro := "ZV_GRPROL"+Alltrim(Str(nIndex))
		If FWSX6Util():ExistsParam(cParametro)
			nRoloSGrup += GetMV(cParametro)
		Else
			EXIT
		EndIf
	Next nIndex

	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(DbSeek(FwxFilial("SB1")+(cAliasTmp)->C2_PRODUTO))

	cGrupoProd := Alltrim(SB1->B1_GRUPO) + SB1->B1_ZSUBGRU

	If ( cOpcao == "A") .And. (FindFunction("producao.op.u_apontamentoBlankChapa"))

		If cGrupoProd $(nBlankSGrup)
			If LockByName("pontamentoBlankChapa_"+(cAliasTmp)->TMP_ORDEM,.F.,.F.)
				producao.op.u_apontamentoBlankChapa(cAliasTmp, nRec)
				UnLockByName("pontamentoBlankChapa_"+(cAliasTmp)->TMP_ORDEM,.F.,.F. )
			else
				Alert("Rotina já em execução!")

			EndIf
		Else
			FWAlertInfo("Tipo de apontamento Blank inválido para esta O.P!", "Blank")
		EndIf

	ElseIf ( cOpcao == "B") .And. (FindFunction("producao.op.u_apontamentoRolo"))

		If cGrupoProd $(nRoloSGrup)
			If LockByName("apontamentoRolo_"+(cAliasTmp)->TMP_ORDEM,.F.,.F.)
				producao.op.u_apontamentoRolo(cAliasTmp, nRec)
				UnLockByName("apontamentoRolo_"+(cAliasTmp)->TMP_ORDEM,.F.,.F. )
			else
				Alert("Rotina já em execução!")

			EndIf

		Else
			FWAlertInfo("Tipo de apontamento Rolos inválido para esta O.P!", "Rolos")
		EndIf

	ElseIf ( cOpcao == "C")
		MATA690()
	ElseIf ( cOpcao == "D") .And. (FindFunction("producao.op.u_aglutinaLotes"))
		producao.op.u_aglutinaLotes(cAliasTmp, nRec)
	EndIf

	If (cAliasTmp)->(AvZap())
		getQryOrdemProducao()
	EndIf

Return


