#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} SPDFISBLCK
//TODO Ponto de entrada para geração da obrigação para o CD Embu (K200 e K280), este ponto desconsidera toda a execução padrão do Protheus como seus pacotes
@author Rubens Simi
@since 23/08/25
@version 1.0
@return retorna array de cursores para geração do bloco K

// @history 22/10/2026 - Fabio Nascimento - Chamado:15350 - INCONSISTENCIA DE SALDO ARQUIVO SPED / K200
// Ajustes: chave completa do K200 por participante, tamanho COD_PART,
// quebra de agrupamento e consulta SBF/SA1 por filial/produto corrente.
// -----------------------------------------------------------------------------


@type function
/*/
User Function SPDFISBLCK()
	Local aRet := {}
	Local dDataIni := PARAMIXB[1]
	Local dDataFin := PARAMIXB[2]
	Local cAlias0210 := ''
	Local cAliasK200 := ''
	Local cAliasK220 := ''
	Local cAliasK230 := ''
	Local cAliasK235 := ''
	Local cAliasK250 := ''
	Local cAliasK255 := ''
	Local cAliasK210 := ''
	Local cAliasK215 := ''
	Local cAliasK260 := ''
	Local cAliasK265 := ''
	Local cAliasK270 := ''
	Local cAliasK275 := ''
	Local cAliasK280 :=	''
	Local cAliasK290 :=	''
	Local cAliasK291 :=	''
	Local cAliasK292 :=	''
	Local cAliasK300 :=	''
	Local cAliasK301 :=	''
	Local cAliasK302 :=	''
	Private lCpoBZTP	:= SBZ->(ColumnPos("BZ_TIPO")) > 0 .AND. SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
	Private cTipo00		:= If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) // 00: Mercadoria Revenda
	Private cTipo01		:= If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) // 01: Materia-Prima
	Private cTipo02		:= If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) // 02: Embalagem
	Private cTipo03		:= If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) // 03: Produto em Processo
	Private cTipo04		:= If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) // 04: Produto Acabado
	Private cTipo05		:= If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) // 05: SubProduto
	Private cTipo06		:= If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) // 06: Produto Intermediario
	Private cTipo10		:= If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'")) // 10: Outros Insumos

	Private cAlmTerc	:= GetAlmTerc()

	//-----------------------------------------------------------------
	//Cria alias e tabelas temporárias do bloco K
	//-----------------------------------------------------------------
	u_TmpBlcK(@cAlias0210,@cAliasK200,@cAliasK220,@cAliasK230,@cAliasK235,@cAliasK250,@cAliasK255,@cAliasK210, @cAliasK215, @cAliasK260, @cAliasK265, @cAliasK270,@cAliasK275,@cAliasK280,@cAliasK290,@cAliasK291,@cAliasK292,@cAliasK300,@cAliasK301,@cAliasK302 )


	//Geração do bloco k200
	Regk200(cAliasK200, dDataIni, dDataFin)



	aAdd(aRet,cAlias0210)
	aAdd(aRet,cAliasK200)
	aAdd(aRet,cAliasK220)
	aAdd(aRet,cAliasK230)
	aAdd(aRet,cAliasK235)
	aAdd(aRet,cAliasK250)
	aAdd(aRet,cAliasK255)
	aAdd(aRet,cAliasK210)
	aAdd(aRet,cAliasK215)
	aAdd(aRet,cAliasK260)
	aAdd(aRet,cAliasK265)
	aAdd(aRet,cAliasK270)
	aAdd(aRet,cAliasK275)
	aAdd(aRet,cAliasK280)
	aAdd(aRet,cAliasK290)
	aAdd(aRet,cAliasK291)
	aAdd(aRet,cAliasK292)
	aAdd(aRet,cAliasK300)
	aAdd(aRet,cAliasK301)
	aAdd(aRet,cAliasK302)

Return aRet



/*/{Protheus.doc} REGK200
//TODO Gero registro K200, Especifico para Centrasa, padrão não atende
@author Rubens Simi
@since 23/08/25
@version 1.0
@return Cursor com as informações preenchidas
@param cAliasK200, characters, descricao
@param dDataIni, date, descricao
@param dDataFin, date, descricao
@type function
/*/
Static Function REGK200(cAliasK200, dDataIni, dDataFin)

	Local cAliProp		:= "K_"+CriaTrab(Nil,.F.)
	Local cAliSumTer:=''
	Local aK200			:= array(4)

	GetListPrd(@cAliProp,dDataIni,dDataFin)
	cAliSumTer := CriaTrab(Nil,.F.)
	CreaSumTerc(@cAliSumTer)

	aK200 := {cAliasK200 ,NIL ,{} ,NIL}

	JobK200(0,"JobK200",aK200,cAliProp,cAliSumTer,dDataFin)

// atualiza o saldo proprio descontando ou n? o saldo de terceiro
	ProcSumTerc(cAliasK200,cAliSumTer)


Return


static Function JobK200(nThread,cName,aK200,cAliasTmp,cAliSumTer,dDataAte)

	Local nSaldo		:= 0
	Local cProdAtu		:= ""
	Local cAliK200		:= ""
	Local cSB9Filial	:= xFilial("SB9")
	Local aProdDeAte	:= {}
	Local cCOD_PART		:= ""
	Local cIND_EST		:= ""
	Local nRecIni
	Local nRecFin
	Local cLocProc      := GetMvNNR("MV_LOCPROC",'99')
	Local cClientAtu     := ""
	Local cAliasSBF      := ""
	Local cQuery         := ""
	Local lGravaGrupo    := .F.




	nRecIni := 1
	nRecFin := 9999999999999999999999
	cAliK200 := aK200[1]

//??????????????????????????????
//?Chama o PE SPDFIS001 para realizar a troca dos Tipos     ?
//??????????????????????????????
	TrocaTipo()



//???????????????
//?Posiciona no RECNO Inicial ?
//???????????????
	(cAliasTmp)->(dbGoto(nRecIni))

// PROCLOGATU gravado "na m?", pois em multi-thread n? tem IDCV8 preenchido
//GravaCV8("6", "MATXSPED", "Bloco K - Thread: "+StrZero(nThread,2)+" - K200|01: Inicio SLD Proprio "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()), "", "", "", NIL, cIDCV8MOV)
//??????????????????????????????????????
//?Processa Saldo de Propriedade do Informante no Informante: IND_EST = 0   ?
//??????????????????????????????????????
	cProdAtu := (cAliasTmp)->B9_COD
	cClientAtu	:= (cAliasTmp)->(D3E_CLIENT+D3E_LOJA)
	aAdd(aProdDeAte,cProdAtu)
	While !(cAliasTmp)->(Eof()) .And. !(cAliasTmp)->(Recno()) > nRecFin
		If cProdAtu == (cAliasTmp)->B9_COD
			//?????????????????????????????????????
			//?Roda a CALCEST apenas quando o produto foi movimentado entre o ultimo  ?
			//?fechamento de estoque e a data final de processamento do Bloco K       ?
			//?????????????????????????????????????
			If (cAliasTmp)->STATS == "S" .Or. (cAliasTmp)->B9_LOCAL == cLocProc
				nSaldo += CalcEst((cAliasTmp)->B9_COD,(cAliasTmp)->B9_LOCAL,dDataAte+1,Nil,.F.)[1]
			ElseIf (cAliasTmp)->STATS == "N"
				nSaldo += (cAliasTmp)->B9_QINI
			EndIf

			(cAliasTmp)->(dbSkip())
			//??????????????????????
			//?Quando mudar o produto, grava o registro ?
			//??????????????????????
			// CHAMADO 15350: finaliza o agrupamento quando chegar ao EOF ou mudar produto/participante
			lGravaGrupo := (cAliasTmp)->(Eof())
			If !lGravaGrupo
				lGravaGrupo := cProdAtu <> (cAliasTmp)->B9_COD .Or. cClientAtu <> (cAliasTmp)->(D3E_CLIENT+D3E_LOJA)
			EndIf

			If lGravaGrupo
				If !nSaldo == 0
					// CHAMADO 15350: apos o dbSkip(), usar sempre o produto que estava sendo processado
					If Posicione("SB1",1,xFilial("SB1")+AllTrim(cProdAtu),"B1_TIPO") == "MP"
						cAliasSBF := GetNextAlias()
						cQuery := " SELECT SBF.BF_FILIAL, SBF.BF_PRODUTO, SUM(SBF.BF_QUANT) AS BF_QUANT, "
						cQuery += " SBF.BF_LOCALIZ, SA1.A1_COD, SA1.A1_LOJA "
						cQuery += " FROM " + RetSqlName("SBF") + " SBF "
						cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
						cQuery += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
						cQuery += " AND SA1.A1_CGC = SBF.BF_LOCALIZ "
						cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
						cQuery += " WHERE SBF.BF_FILIAL = '" + xFilial("SBF") + "' "
						cQuery += " AND SBF.BF_PRODUTO = '" + AllTrim(cProdAtu) + "' "
						cQuery += " AND SBF.BF_QUANT > 0 "
						cQuery += " AND SBF.D_E_L_E_T_ = ' ' "
						cQuery += " GROUP BY SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOCALIZ, SA1.A1_COD, SA1.A1_LOJA "
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBF, .F., .T.)

						(cAliasSBF)->(dbGoTop())
						While (cAliasSBF)->(!Eof())
							cIND_EST  := "2"
							cCOD_PART := "SA1" + (cAliasSBF)->A1_COD + (cAliasSBF)->A1_LOJA
							// Chave K200: FILIAL + DATA + PRODUTO + IND_EST + COD_PART
							If !(cAliK200)->(MSSeek(cSB9Filial + DTOS(dDataAte) + cProdAtu + cIND_EST + cCOD_PART))
								Reclock(cAliK200,.T.)
								(cAliK200)->FILIAL   := cSB9Filial
								(cAliK200)->REG      := "K200"
								(cAliK200)->DT_EST   := dDataAte
								(cAliK200)->COD_ITEM := cProdAtu
								(cAliK200)->QTD      := (cAliasSBF)->BF_QUANT
								(cAliK200)->IND_EST  := cIND_EST
								(cAliK200)->COD_PART := cCOD_PART
								(cAliK200)->(MsUnLock())
							EndIf
							(cAliasSBF)->(dbSkip())
						EndDo

						(cAliasSBF)->(dbCloseArea())
					else
						If Empty(cClientAtu)
							cIND_EST := "0"
							cCOD_PART := space(len((cAliK200)->COD_PART))

						Else
							cIND_EST := "2"
							cCOD_PART := "SA1" + cClientAtu
						EndIf

						If (cAliK200)->(MSSeek(cSB9Filial+dtos(dDataAte)+cProdAtu+cIND_EST+cCOD_PART))
							Reclock(cAliK200,.F.)
							(cAliK200)->QTD += nSaldo
							(cAliK200)->(MsUnLock())
						Else
							Reclock(cAliK200,.T.)
							(cAliK200)->FILIAL		:= cSB9Filial
							(cAliK200)->REG			:= "K200"
							(cAliK200)->DT_EST		:= dDataAte
							(cAliK200)->COD_ITEM	:= cProdAtu
							(cAliK200)->QTD			:= nSaldo
							(cAliK200)->IND_EST		:= cIND_EST
							(cAliK200)->COD_PART	:= cCOD_PART
							(cAliK200)->(MsUnLock())
						EndIf
					endif
				EndIf
				If !(cAliasTmp)->(Eof())
					cClientAtu := (cAliasTmp)->(D3E_CLIENT+D3E_LOJA)
					cProdAtu := (cAliasTmp)->B9_COD
				EndIf
				nSaldo := 0
			EndIf
		EndIf
	EndDo

// PROCLOGATU gravado "na m?", pois em multi-thread n? tem IDCV8 preenchido
	//GravaCV8("6", "MATXSPED", "Bloco K - Thread: "+StrZero(nThread,2)+" - K200|02: Inicio SLD Terceiros "+ Alltrim(DtoC(Date())) + " - " + Alltrim(Time()), "", "", "", NIL, cIDCV8MOV)

	(cAliasTmp)->(dbGoto(nRecFin))
	cProdAtu := (cAliasTmp)->B9_COD

	aAdd(aProdDeAte,cProdAtu)

//??????????????????????????????????????
//?Processa Saldo DE Terceiros para gravacao de IND_EST 2			        ?
//?----------------------------------------------------------------------- ?
//?Tratamento quando unico codigo de produto esteja contido o saldo de  	?
//?terceiros e,possa ter, saldo proprio e ou saldo de terceito				?
//?O processamento fica fora do loop principal pois depende da gravacao do ?
//?IND_EST = 0, pois a CALCEST retorna a QTDE somando o saldo DE TERCEIROS ?
//??????????????????????????????????????
	GetSldTerc("D" ,dDataAte ,aProdDeAte[1] ,aProdDeAte[2] ,cAliK200, cAliSumTer)

//??????????????????????????????????????
//?Processa Saldo EM Terceiros para gravacao de IND_EST 2			        ?
//?----------------------------------------------------------------------- ?
//?Tratamento quando unico codigo de produto esteja contido o saldo em  	?
//?terceiros e,possa ter, saldo proprio e ou saldo de terceito				?
//?O processamento fica fora do loop principal pois depende da gravacao do ?
//?IND_EST = 0, pois a CALCEST retorna a QTDE somando o saldo EM TERCEIROS ?
//??????????????????????????????????????
	GetSldTerc("E" ,dDataAte ,aProdDeAte[1] ,aProdDeAte[2] ,cAliK200, cAliSumTer)


Return


Static Function TrocaTipo()

	Local aTipo			:= {}
	Local cTipo			:= ""
	Local nX

	Local aTipos := {}
	Local cTipos := ''
	Local lVldBlkTp := FindFunction('VldBlkTp')

	If ExistBlock("SPDFIS001")
		aTipo := ExecBlock("SPDFIS001", .F., .F., {aTipo})
	EndIf

	For nX := 1 to Len(aTipo)
		If !(aTipo[nX][2] $ "07|08|09")
			If "|" $ aTipo[nX][1]
				aTipo[nX][1] := StrTran(aTipo[nX][1],"|","','")
			EndIf
			cTipo		:= "cTipo" + aTipo[nX][2]
			&(cTipo)	:= "'" + aTipo[nX][1] + "'"
		EndIf
	Next nX

	If Len(aTipo) > 0
		cTipos := ''
		cTipos += cTipo00 + ','
		cTipos += cTipo01 + ','
		cTipos += cTipo02 + ','
		cTipos += cTipo03 + ','
		cTipos += cTipo04 + ','
		cTipos += cTipo05 + ','
		cTipos += cTipo06 + ','
		cTipos += cTipo10

		aTipos := STRTOKARR( cTipos, ',')

		If lVldBlkTp .And. !VldBlkTp(aTipos)
			// Inconsistencia no Bloco K, mesmo tipo de produto em par?etro MV_BLKTP diferentes ap? PE
			//	ProcLogAtu(STR0001,STR0045+Alltrim(DtoC(Date())) + " - " + Alltrim(Time())) //MENSAGEM | "N? ?permitido mesmo tipo de produto em par?etro MV_BLKTP(*) diferentes. "
		EndIf
	EndIf

Return


Static Function CreaSumTerc(cAliSumTer)
	Local aCampos
	Local nTamCod := TamSX3("B1_COD" )[1]
	Local aTamQtd := TamSX3("B2_QATU" )

	aCampos := {}
	AADD(aCampos,{"FILIAL"		,"C",TamSX3("D1_FILIAL" )[1],0})
	AADD(aCampos,{"DT_EST"		,"D",TamSX3("D1_DTDIGIT")[1],0})
	AADD(aCampos,{"COD_ITEM"	,"C",nTamCod				,0})
	AADD(aCampos,{"QTDFIS"		,"N",aTamQtd[1]			,aTamQtd[2]})
	AADD(aCampos,{"QTDVIR"		,"N",aTamQtd[1]			,aTamQtd[2]})

	If TcCanOpen(cAliSumTer)
		TcDelFile(cAliSumTer)
	EndIf

	FwDbCreate(cAliSumTer,aCampos,"TOPCONN",.T.)
	DbUseArea(.T.,"TOPCONN",cAliSumTer,cAliSumTer,.T.)
	DBCreateIndex(cAliSumTer+'1', 'FILIAL+DT_EST+COD_ITEM', { || 'FILIAL+DT_EST+COD_ITEM' })

Return .T.



/*/{Protheus.doc} TmpBlcK
//TODO Gera os cursores temporarios
@author Rubens Simi
@since 23/08/25
@version 1.0
@return Retorna os cursores criados
@param cAlias0210, characters, descricao
@param cAliasK200, characters, descricao
@param cAliasK220, characters, descricao
@param cAliasK230, characters, descricao
@param cAliasK235, characters, descricao
@param cAliasK250, characters, descricao
@param cAliasK255, characters, descricao
@param cAliasK210, characters, descricao
@param cAliasK215, characters, descricao
@param cAliasK260, characters, descricao
@param cAliasK265, characters, descricao
@param cAliasK270, characters, descricao
@param cAliasK275, characters, descricao
@param cAliasK280, characters, descricao
@param cAliasK290, characters, descricao
@param cAliasK291, characters, descricao
@param cAliasK292, characters, descricao
@param cAliasK300, characters, descricao
@param cAliasK301, characters, descricao
@param cAliasK302, characters, descricao
@type function
/*/
User Function TmpBlcK(cAlias0210,cAliasK200,cAliasK220,cAliasK230,cAliasK235,cAliasK250,cAliasK255,cAliasK210, cAliasK215, cAliasK260, cAliasK265, cAliasK270,cAliasK275,cAliasK280,cAliasK290,cAliasK291,cAliasK292,cAliasK300,cAliasK301,cAliasK302 )

	Local aCampos := {}
	Local nTamFil := TamSX3("D1_FILIAL")[1]
	Local nTamDt := TamSX3("D1_DTDIGIT")[1]
	Local aTamQtd := TamSX3("B2_QATU")
	Local nTamOP := TamSX3("D3_OP")[1]
	Local nTamCod := TamSX3("B1_COD")[1]
	Local nTamChave := TamSX3("D1_COD")[1] + TamSX3("D1_SERIE")[1] + TamSX3("D1_FORNECE")[1] + TamSX3("D1_LOJA")[1]

	// CHAMADO 15350: COD_PART recebe prefixo da tabela (SA1/SA2) + codigo + loja
	Local nTamPar := Max( 3 + TamSX3("A1_COD")[1] + TamSX3("A1_LOJA")[1], 3 + TamSX3("A2_COD")[1] + TamSX3("A2_LOJA")[1] )
	Local nTamReg := 4
	Local cArq0210 := ''
	Local cArqK200 := ''
	Local cArqK220 := ''
	Local cArqK230 := ''
	Local cArqK235 := ''
	Local cArqK250 := ''
	Local cArqK255 := ''
	Local cArqK210 := ''
	Local cArqK215 := ''
	Local cArqK260 := ''
	Local cArqK265 := ''
	Local cArqK270 := ''
	Local cArqK280 :=''
	Local cArqK290 :=''
	Local cArqK291 :=''
	Local cArqK292 :=''
	Local cArqK300 :=''
	Local cArqK301 :=''
	Local cArqK302 :=''
	//Local aIndex   :={}
	//Local oTrb

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO 0210
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro 0210
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //***Código do produto que fará o relacionamento com registro pai 0200
	AADD(aCampos,{"COD_I_COMP" ,"C",nTamCod ,0}) //Campo 02 do registro 0210
	AADD(aCampos,{"QTD_COMP" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 03 do registro 0210
	AADD(aCampos,{"PERDA" ,"N",5 ,2}) //Campo 04 do registro 0210

	cAlias0210 := "0210"
	cArq0210 := Left( cAlias0210, 7 ) + "1"
	//aAdd(aIndex,{ cArq0210, {"FILIAL","COD_ITEM","COD_I_COMP"} })
	//u_PCGTEMP2(aCampos,aIndex,@oTrb,@cAlias0210)

	oTempTable := FWTemporaryTable():New( cAlias0210 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArq0210, {"FILIAL","COD_ITEM","COD_I_COMP"} )
	oTempTable:Create()

	DbSelectArea(cAlias0210)
	DbSetOrder(1)

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K200
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K200
	AADD(aCampos,{"DT_EST" ,"D",nTamDt ,0}) //Campo 02 do registro K200
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 03 do registro K200
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 04 do registro K200
	AADD(aCampos,{"IND_EST" ,"C",1 ,0}) //Campo 05 do registro K200
	AADD(aCampos,{"COD_PART" ,"C",nTamPar,0}) //Campo 06 do registro K200

	cAliasK200 := "K200"
	cArqK200 := Left( cAliasK200, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK200 )
	oTemptable:SetFields(aCampos )

	// CHAMADO 15350: o indice deve refletir a chave utilizada nos MSSeek do K200
	oTempTable:AddIndex(cArqK200, {"FILIAL","DT_EST","COD_ITEM","IND_EST","COD_PART"} )
	oTempTable:Create()

	DbSelectArea(cAliasK200)
	DbSetOrder(1)

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K220
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K220
	AADD(aCampos,{"DT_MOV" ,"D",nTamDt ,0}) //Campo 02 do registro K220
	AADD(aCampos,{"COD_ITEM_O" ,"C",nTamCod ,0}) //Campo 03 do registro K220
	AADD(aCampos,{"COD_ITEM_D" ,"C",nTamCod ,0}) //Campo 04 do registro K220
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 05 do registro K220

	cAliasK220 := "K220"
	cArqK220 := Left( cAliasK220, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK220 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK220, {"FILIAL"} )
	oTempTable:Create()

	DbSelectArea(cAliasK220)
	DbSetOrder(1)
	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K230
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K230
	AADD(aCampos,{"DT_INI_OP" ,"D",nTamDt ,0}) //Campo 02 do registro K230
	AADD(aCampos,{"DT_FIN_OP" ,"C",nTamDt ,0}) //Campo 03 do registro K230
	AADD(aCampos,{"COD_DOC_OP" ,"C",nTamOP ,0}) //***Campo 04 do registro K230. Campo utilizado para fazer relacionamento com registro filho K230
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 05 do registro K230
	AADD(aCampos,{"QTD_ENC" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 06 do registro K230

	cAliasK230 := "K230"
	cArqK230 := Left( cAliasK230, 7 ) + "1"

	oTempTable := FWTemporaryTable():New( cAliasK230 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK230, {"FILIAL","COD_DOC_OP"} )
	oTempTable:Create()

	DbSelectArea(cAliasK230)
	DbSetOrder(1)

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K235
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K235
	AADD(aCampos,{"DT_SAIDA" ,"D",nTamDt ,0}) //Campo 02 do registro K235
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 03 do registro K235
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 04 do registro K235
	AADD(aCampos,{"COD_INS_SU" ,"C",nTamCod ,0}) //Campo 05 do registro K235
	AADD(aCampos,{"COD_DOC_OP" ,"C",nTamOP ,0}) //***Campo de ligação com registro K230, o relacionamento de K230 e K235 será feito por este campo

	cAliasK235 := "K235"
	cArqK235 := Left( cAliasK235, 7 ) + "1"

	oTempTable := FWTemporaryTable():New( cAliasK235 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK235, {"FILIAL","COD_DOC_OP"} )
	oTempTable:Create()

	DbSelectArea(cAliasK235)
	DbSetOrder(1)

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K250
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K250
	AADD(aCampos,{"CHAVE" ,"C",nTamChave ,0}) //***Campo de ligação com registros filho K255
	AADD(aCampos,{"DT_PROD" ,"D",nTamDt ,0}) //Campo 02 do registro K250
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 03 do registro K250
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 04 do registro K250

	cAliasK250 := "K250"
	cArqK250 := Left( cAliasK250, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK250 )
	oTemptable:SetFields(aCampos )
	//oTempTable:AddIndex(cArqK250, {"FILIAL","DTOS(DT_PROD)","COD_ITEM"} )
	oTempTable:AddIndex(cArqK250, {"FILIAL","DT_PROD","COD_ITEM"} )
	oTempTable:Create()

	DbSelectArea(cAliasK250)
	DbSetOrder(1)

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K255
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do registro K255
	AADD(aCampos,{"CHAVE" ,"C",nTamChave ,0}) //***Campo de ligação com registros pai K250
	AADD(aCampos,{"DT_CONS" ,"D",nTamDt ,0}) //Campo 02 do registro K255
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Campo 03 do registro K255
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 04 do registro K255
	AADD(aCampos,{"COD_INS_SU" ,"C",nTamCod ,0}) //Campo 05 do registro K250

	cAliasK255 := "K255"
	cArqK255 := Left( cAliasK255, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK255 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK255, {"FILIAL","CHAVE"} )
	oTempTable:Create()

	DbSelectArea(cAliasK255)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K210
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"DT_INI_OS" ,"C",nTamReg ,0}) //Campo 01 do Registro K210
	AADD(aCampos,{"DT_FIN_OS" ,"C",nTamChave ,0}) //Campo 02 do Registro K210
	AADD(aCampos,{"COD_DOC_OS" ,"D",nTamDt ,0}) //Campo 03 do Registro K210
	AADD(aCampos,{"COD_ITEM_O" ,"C",nTamCod ,0}) //Campo 04 do Registro K210
	AADD(aCampos,{"QTD_ORI" ,"N",aTamQtd[1],aTamQtd[2]}) //Campo 05 do Registro K210

	cAliasK210 := "K210"
	cArqK210 := Left( cAliasK210, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK210 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK210, {"FILIAL","COD_ITEM_O"} )
	oTempTable:Create()

	DbSelectArea(cAliasK210)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K215
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Campo 01 do Registro K215
	AADD(aCampos,{"COD_DOC_OS" ,"C",nTamChave ,0}) // Campo chave de ligação com o registro pai K210
	AADD(aCampos,{"COD_ITEM_D" ,"D",nTamDt ,0}) //Campo 02 do Registro K215
	AADD(aCampos,{"QTD_DES" ,"C",nTamCod ,0}) //Campo 03 do Registro K215

	cAliasK215 := "K215"
	cArqK215 := Left( cAliasK215, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK215 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK215, {"FILIAL","COD_DOC_OS"} )
	oTempTable:Create()

	DbSelectArea(cAliasK215)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K260
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K260"
	AADD(aCampos,{"COD_OP_OS" ,"C",nTamChave ,0}) // Código de identificação da ordem de produção, no reprocessamento, ou da ordem de serviço, no reparo
	AADD(aCampos,{"COD_ITEM" ,"D",nTamDt ,0}) //Código do produto/insumo a ser reprocessado/reparado ou já reprocessado/reparado
	AADD(aCampos,{"DT_SAIDA" ,"C",nTamCod ,0}) //Data de saída do estoque
	AADD(aCampos,{"QTD_SAIDA" ,"C",nTamCod ,0}) //Quantidade de saída do estoque
	AADD(aCampos,{"DT_RET" ,"C",nTamCod ,0}) //Data de retorno ao estoque (entrada)
	AADD(aCampos,{"QTD_RET" ,"C",nTamCod ,0}) //Quantidade de retorno ao estoque (entrada)

	cAliasK260 := "K260"
	cArqK260 := Left( cAliasK260, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK260 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK260, {"FILIAL","COD_OP_OS"} )
	oTempTable:Create()

	DbSelectArea(cAliasK260)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K265
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K265"
	AADD(aCampos,{"COD_OP_OS" ,"C",nTamChave ,0}) // Campo chave que liga ao registro Pai K260
	AADD(aCampos,{"COD_ITEM" ,"D",nTamDt ,0}) //Código da mercadoria (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD_CONS" ,"C",nTamCod ,0}) //Quantidade consumida à saída do estoque
	AADD(aCampos,{"QTD_RET" ,"C",nTamCod ,0}) //Quantidade retornada à entrada em estoque

	cAliasK265 := "K265"
	cArqK265 := Left( cAliasK265, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK265 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK265, {"FILIAL","COD_OP_OS"} )
	oTempTable:Create()

	DbSelectArea(cAliasK265)
	DbSetOrder(1)

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K270
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K270"
	AADD(aCampos,{"DT_INI_AP" ,"C",nTamChave ,0}) // Data inicial do período de apuração em que ocorreu o apontamento que está sendo corrigido
	AADD(aCampos,{"DT_FIN_AP" ,"D",nTamDt ,0}) //Data final do período de apuração em que ocorreu o apontamento que está sendo corrigido
	AADD(aCampos,{"COD_OP_OS" ,"C",nTamCod ,0}) //Código de identificação da ordem de produção ou da ordem de serviço que está sendo corrigida
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Código da mercadoria que está sendo corrigido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD_COR_P" ,"C",nTamCod ,0}) //Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
	AADD(aCampos,{"QTD_COR_N" ,"C",nTamCod ,0}) //Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior
	AADD(aCampos,{"ORIGEM " ,"C",nTamCod ,0}) //Origem da correção, conforme manual do Sped

	cAliasK270 := "K270"
	cArqK270 := Left( cAliasK270, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK270 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK270, {"FILIAL","COD_OP_OS"} )
	oTempTable:Create()

	DbSelectArea(cAliasK270)
	DbSetOrder(1)

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K275
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0}) //Filial
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K275"
	AADD(aCampos,{"COD_OP_OS" ,"C",nTamChave ,0}) // Campo chave que liga ao registro Pai K270
	AADD(aCampos,{"COD_ITEM" ,"D",nTamDt ,0}) //Código da mercadoria (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD_COR_P" ,"C",nTamCod ,0}) //Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
	AADD(aCampos,{"QTD_COR_N" ,"C",nTamCod ,0}) //Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior
	AADD(aCampos,{"COD_INS_SU" ,"C",nTamCod ,0}) //Código do insumo que foi substituído, caso ocorra a substituição, relativo aos Registros K235/K255

	cAliasK275 := "K275"
	cArqK275 := Left( cAliasK275, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK275 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK275, {"FILIAL","COD_OP_OS"} )
	oTempTable:Create()

	DbSelectArea(cAliasK275)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K280
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K280"
	AADD(aCampos,{"DT_EST" ,"D",nTamDt ,0}) //Data do estoque final escriturado que está sendo corrigido
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Código do item (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD_COR_P" ,"N",aTamQtd[1],aTamQtd[2]}) //Quantidade de correção positiva de apontamento ocorrido em período de apuração anterior
	AADD(aCampos,{"QTD_COR_N" ,"N",aTamQtd[1],aTamQtd[2]}) //Quantidade de correção negativa de apontamento ocorrido em período de apuração anterior
	AADD(aCampos,{"IND_EST" ,"C",1,0}) //Indicador do tipo de estoque
	AADD(aCampos,{"COD_PART" ,"C",nTamPar ,0 }) //Código do participante

	cAliasK280 := "K280"
	cArqK280 := Left( cAliasK280, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK280 )
	oTemptable:SetFields(aCampos )

	oTempTable:AddIndex(cArqK280, {"FILIAL","DT_EST","COD_ITEM","IND_EST","COD_PART"} )
	oTempTable:Create()

	DbSelectArea(cAliasK280)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K290
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K290"
	AADD(aCampos,{"DT_INI_OP" ,"D",nTamDt ,0}) //Data de início da ordem de produção
	AADD(aCampos,{"DT_FIN_OP" ,"D",nTamDt ,0}) //Data de conclusão da ordem de produção
	AADD(aCampos,{"COD_DOC_OP" ,"C",nTamOP ,0}) //Código de identificação da ordem de produção

	cAliasK290 := "K290"
	cArqK290 := Left( cAliasK290, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK290 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK290, {"FILIAL","COD_DOC_OP"} )
	oTempTable:Create()

	DbSelectArea(cAliasK290)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K291
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K291"
	AADD(aCampos,{"COD_DOC_OP","C",nTamOP,0}) // Código de identificação da ordem de produção
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Código do item produzido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2] ,0}) //Quantidade de produção acabada

	cAliasK291 := "K291"
	cArqK291 := Left( cAliasK291, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK291 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK291, {"FILIAL","COD_DOC_OP","COD_ITEM"} )
	oTempTable:Create()

	DbSelectArea(cAliasK291)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K292
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K292"
	AADD(aCampos,{"COD_DOC_OP","C",nTamOP,0}) // Código de identificação da ordem de produção
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Código do item produzido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2] ,0}) //Quantidade de produção acabada

	cAliasK292 := "K292"
	cArqK292 := Left( cAliasK292, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK292 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK292, {"FILIAL","COD_DOC_OP","COD_ITEM"} )
	oTempTable:Create()

	DbSelectArea(cAliasK292)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K300
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"CHAVE" ,"C",nTamChave ,0}) //Campo de ligação com registros K301 e K302
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K300"
	AADD(aCampos,{"DT_PROD" ,"D",nTamDt ,0}) //Data do reconhecimento da produção ocorrida no terceiro

	cAliasK300 := "K300"
	cArqK300 := Left( cAliasK300, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK300 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK300, {"FILIAL","CHAVE"} )
	oTempTable:Create()

	DbSelectArea(cAliasK300)
	DbSetOrder(1)


	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K301
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K301"
	AADD(aCampos,{"CHAVE" ,"C",nTamChave,0}) // Campo de ligação com registro K300
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Código do item produzido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2] ,0}) //Quantidade produzida

	cAliasK301 := "K301"
	cArqK301 := Left( cAliasK301, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK301 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK301, {"FILIAL","CHAVE"} )
	oTempTable:Create()

	DbSelectArea(cAliasK301)
	DbSetOrder(1)

	//--------------------------------------------
	//Criacao do Arquivo de Trabalho - BLOCO K302
	//--------------------------------------------
	aCampos := {}
	AADD(aCampos,{"FILIAL" ,"C",nTamFil ,0})
	AADD(aCampos,{"REG" ,"C",nTamReg ,0}) //Texto fixo contendo "K302"
	AADD(aCampos,{"CHAVE" ,"C",nTamChave,0}) // Campo de ligação com registro K300
	AADD(aCampos,{"COD_ITEM" ,"C",nTamCod ,0}) //Código do item produzido (campo 02 do Registro 0200)
	AADD(aCampos,{"QTD" ,"N",aTamQtd[1],aTamQtd[2] ,0}) //Quantidade consumida

	cAliasK302 := "K302"
	cArqK302 := Left( cAliasK302, 7 ) + "1"


	oTempTable := FWTemporaryTable():New( cAliasK302 )
	oTemptable:SetFields(aCampos )
	oTempTable:AddIndex(cArqK302, {"FILIAL","CHAVE"} )
	oTempTable:Create()

	DbSelectArea(cAliasK302)
	DbSetOrder(1)

Return







Static Function GetSldTerc(cTipoTerc ,dDataAte ,cCodProdDe ,cCodProdAte ,cAliK200, cAliSumTer)
	Local cQuery     := ""
	Local cSB9Filial := xFilial("SB9")
	Local cAliTerc   := CriaTrab(Nil,.F.)
	Local cIND_EST
	Local lPropr
	Local cKey
	Local cPessoa
	Local nSaldoFis
	Local nSaldoVir
	Local nB6QtGtSlT1 := TamSX3("B6_QUANT")[1]
	Local nB6QtGtSlT2 := TamSX3("B6_QUANT")[2]
	Local nD3KQtGtSlT1 := TamSX3("D3K_QTDE")[1]
	Local nD3KQtGtSlT2 := TamSX3("D3K_QTDE")[2]
	Local nD2QtGtSlT1 := TamSX3("D2_QUANT")[1]
	Local nD2QtGtSlT2 := TamSX3("D2_QUANT")[2]
	Local nD1QtGtSlT1 := TamSX3("D1_QUANT")[1]
	Local nD1QtGtSlT2 := TamSX3("D1_QUANT")[2]

	cQuery := QryTerc(cTipoTerc,dDataAte,cCodProdDe,cCodProdAte)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTerc,.T.,.T.)
	TCSetField(cAliTerc, "B6_QUANT","N",nB6QtGtSlT1,nB6QtGtSlT2)
	TCSetField(cAliTerc, "D3K_QTDE","N",nD3KQtGtSlT1,nD3KQtGtSlT2)
	TCSetField(cAliTerc, "D2_QUANT","N",nD2QtGtSlT1,nD2QtGtSlT2)
	TCSetField(cAliTerc, "D1_QUANT","N",nD1QtGtSlT1,nD1QtGtSlT2)
	While !(cAliTerc)->(Eof())

		If !Empty((cAliTerc)->(B6_CLIFOR+B6_LOJA)) .And. (cAliTerc)->SALDO <> 0
			// descontar do saldo proprio, o saldo DE Terceiro
			If cTipoTerc == "D"
				cIND_EST := "2"
			Else
				If cTipoTerc == "E"
					cIND_EST := "1"
				EndIf
			EndIf

			If (cAliSumTer)->(MsSeek(cSB9Filial+DTOS(dDataAte)+(cAliTerc)->(B6_PRODUTO)))

				nSaldoFis := 0
				nSaldoVir := 0
				If ((cAliSumTer)->QTDFIS + (cAliTerc)->SALDOFIS) <> 0
					nSaldoFis := Iif((cAliTerc)->SALDOFIS > 0, (cAliTerc)->SALDOFIS, 0)
					nSaldoFis += Iif((cAliSumTer)->QTDFIS > 0, (cAliSumTer)->QTDFIS, 0)
				EndIf

				nSaldoVir := (cAliSumTer)->QTDVIR + (cAliTerc)->SALDOVIR

				Reclock(cAliSumTer,.F.)
				(cAliSumTer)->QTDFIS := nSaldoFis
				(cAliSumTer)->QTDVIR := nSaldoVir
				(cAliSumTer)->(MsUnLock())
			Else
				Reclock(cAliSumTer,.T.)
				(cAliSumTer)->FILIAL   := cSB9Filial
				(cAliSumTer)->DT_EST   := dDataAte
				(cAliSumTer)->COD_ITEM := (cAliTerc)->B6_PRODUTO
				(cAliSumTer)->QTDFIS   := (cAliTerc)->SALDOFIS
				(cAliSumTer)->QTDVIR   := (cAliTerc)->SALDOVIR
				(cAliSumTer)->(MsUnLock())
			EndIf

			lPropr := (cAliTerc)->(columnpos('B6_CLIPROP')) > 0 .and. !Empty((cAliTerc)->B6_CLIPROP) .and.;
				(cAliTerc)->(Columnpos('B6_LJCLIPR')) > 0 .and. !Empty((cAliTerc)->B6_LJCLIPR)
			If lPropr
				cKey := 'SA1'+(cAliTerc)->(B6_CLIPROP+B6_LJCLIPR)
			else
				cPessoa := AllTrim((cAliTerc)->PESSOA)
				cKey := cPessoa+(cAliTerc)->B6_CLIFOR+(cAliTerc)->B6_LOJA
			Endif
			If (cAliK200)->(MsSeek(cSB9Filial+DTOS(dDataAte)+(cAliTerc)->(B6_PRODUTO+cIND_EST)+cKey))
				If ((cAliK200)->QTD + (cAliTerc)->SALDO) <= 0
					Reclock(cAliK200,.F.)
					DbDelete()
					(cAliK200)->(MsUnLock())
				Else
					Reclock(cAliK200,.F.)
					(cAliK200)->QTD	+= (cAliTerc)->SALDO
					(cAliK200)->(MsUnLock())
				EndIf
			Else
				if (cAliTerc)->SALDO>0
					Reclock(cAliK200,.T.)
					(cAliK200)->FILIAL		:= cSB9Filial
					(cAliK200)->REG			:= "K200"
					(cAliK200)->DT_EST		:= dDataAte
					(cAliK200)->COD_ITEM	:= (cAliTerc)->B6_PRODUTO
					(cAliK200)->QTD			:= (cAliTerc)->SALDO
					(cAliK200)->IND_EST		:= cIND_EST
					(cAliK200)->COD_PART	:= cKey
					(cAliK200)->(MsUnLock())
				EndIf
			EndIf
		EndIf
		(cAliTerc)->(dbSkip())
	EndDo

	(cAliTerc)->(dbCloseArea())
Return




Static Function GetAlmTerc()

	Local cRet			:= ""
	Local lConTerc		:= SuperGetMv("MV_CONTERC",.F.,.F.)
	Local cCusFil		:= SuperGetMv("MV_CUSFIL",.F.,"A")
	Local lVldCus		:= cCusFil == 'F' .Or. cCusFil == 'E'

	If lConTerc .And. lVldCus
		cRet := GetMvNNR('MV_ALMTERC','80')
	EndIf

Return cRet






/*/{Protheus.doc} QryTerc
Montagem de query para selecionar os produtos que tem saldo em terceiro ou de terceiro
@author reynaldo
@since 23/08/25
@version 1.0
@return ${return}, ${return_description}
@param cTipoTerc, characters, descricao
@param dDataAte, date, descricao
@param nSldTesN3, numeric, descricao
@param cCodProdDe, characters, descricao
@param cCodProdAte, characters, descricao
@type function
/*/
Static Function QryTerc(cTipoTerc,dDataAte,cCodProdDe,cCodProdAte)
	Local cQuery    := ""
	Local lAliasD3E := AliasInDic("D3E")
	Local lAliasD3K := AliasInDic("D3K")
	Local lAlmTerc  := !Empty(cAlmTerc)
	Local nTamDhCli := TamSX3("DH_CLIENTE")[1]
	Local nTamDhLoj := TamSX3("DH_LOJACLI")[1]
	Local lCliProp  := .F.

	dbselectArea('SB6')
	lCliProp:= SB6->(ColumnPos("B6_CLIPROP")) > 0 .and. SB6->(ColumnPos("B6_LJCLIPR")) > 0

	cQuery := ""
	cQuery += "SELECT B6_PRODUTO "
	cQuery += "	,PESSOA "
	cQuery += "	,B6_CLIFOR "
	cQuery += "	,B6_LOJA "
	If lCliProp
		cQuery += ",B6_CLIPROP, B6_LJCLIPR"
	EndIf
	cQuery += "	,CASE "
	cQuery += 	" WHEN SUM(REQUISICAO)<=0 "
	cQuery += 		"AND SUM(RETORNO)*-1>(SUM(REQUISICAO)*-1) THEN SUM(REMESSA)+ SUM(RETORNO) "
	cQuery += 		"ELSE SUM(REMESSA)+ SUM(REQUISICAO) "
	cQuery += 		"END SALDO "
	cQuery += " ,SUM(SALDOFIS) SALDOFIS "
	cQuery += " ,SUM(SALDOVIR) SALDOVIR "
	cQuery += "FROM ( "
// Seleciona os registros da SB6 que s? remessa DE e EM terceiros
	cQuery += "SELECT "
	cQuery += "	'A' QRY "
	cQuery += "	,'" +cTipoTerc+ "' TERC "
	cQuery += "	,B6_PRODUTO "
	cQuery += "	,( "
	cQuery += "		CASE "
	cQuery += "			WHEN B6_TPCF = 'C' "
	cQuery += "				THEN 'SA1' "
	cQuery += "			WHEN B6_TPCF = 'F' "
	cQuery += "				THEN 'SA2' "
	cQuery += "			END "
	cQuery += "		) PESSOA "
	cQuery += ",B6_CLIFOR "
	cQuery += ",B6_LOJA "
	If lCliProp
		cQuery += ",B6_CLIPROP, B6_LJCLIPR"
	EndIf
	cQuery += ",F4_ESTOQUE "
	cQuery += ",B6_QUANT REMESSA "
	cQuery += ",0 RETORNO "
	cQuery += ",0 REQUISICAO "

	cQuery += ",(CASE "
	cQuery += "  WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='S' THEN SB6.B6_QUANT "
	cQuery += "  WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='S' THEN SB6.B6_QUANT *-1 "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOFIS " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += ",(CASE "
	cQuery += "	 WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='N' THEN SB6.B6_QUANT "
	cQuery += "	 WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='N' THEN SB6.B6_QUANT *-1"
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOVIR " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += "FROM "+RetSqlName("SB6")+" SB6 "
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "AND SB1.B1_COD = SB6.B6_PRODUTO "
	cQuery += "AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuery += "	AND SF4.F4_CODIGO = SB6.B6_TES "
	cQuery += "	AND SF4.F4_PODER3 = 'R' "
	If lAlmTerc
		cQuery += " AND (( SF4.F4_ESTOQUE = 'S') OR  (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2')) "
	EndIf
	cQuery += "	AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SB6.B6_FILIAL = '"+xFilial("SB6")+"' "
	cQuery += "	AND SB6.B6_PRODUTO BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "	AND SB6.B6_TIPO = '"+cTipoTerc+"' "
	cQuery += "	AND SB6.B6_DTDIGIT <= '"+dtos(dDataAte)+"' "
	cQuery += "	AND SB6.D_E_L_E_T_ = ' ' AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SB6.B6_PRODUTO AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

	cQuery += "AND NOT EXISTS( "
	cQuery += "SELECT 1 FROM "+ RetSqlName("SDH") +" SDH "
	cQuery += "JOIN "+ RetSqlName("SD1") +" SD1 "
	cQuery += "ON SD1.D1_FILIAL = '"+ xFilial("SD1") +"' AND SDH.DH_IDENTNF = SD1.D1_NUMSEQ AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SDH.DH_FILIAL = '"+ xFilial("SDH") +"' AND SB6.B6_DOC = SD1.D1_DOC AND SB6.B6_SERIE = SD1.D1_SERIE AND SD1.D1_FORNECE = SB6.B6_CLIFOR AND SD1.D1_LOJA = SB6.B6_LOJA AND SD1.D1_COD = SB6.B6_PRODUTO AND SD1.D1_QUANT = SB6.B6_QUANT AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += ") "

	cQuery += "AND NOT EXISTS( "
	cQuery += "SELECT 1 FROM "+ RetSqlName("SDH") +" SDH "
	cQuery += "JOIN "+ RetSqlName("SD2") +" SD2 "
	cQuery += "ON SD2.D2_FILIAL = '"+ xFilial("SD2") +"' AND SDH.DH_IDENTNF = SD2.D2_NUMSEQ AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SDH.DH_FILIAL = '"+ xFilial("SDH") +"' AND SD2.D2_COD = SB6.B6_PRODUTO AND SB6.B6_DOC = SD2.D2_DOC AND SB6.B6_SERIE = SD2.D2_SERIE AND SD2.D2_CLIENTE = SB6.B6_CLIFOR AND SD2.D2_LOJA = SB6.B6_LOJA AND SD2.D2_QUANT = SB6.B6_QUANT AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += ") "


	cQuery += "UNION ALL "
// Seleciona os registros da SB6 que s? retorno de remessa(devolucao) DE e EM terceiros, desde que encontre a remessa de terceiro respectivo
	cQuery += "SELECT "
	cQuery += "	'B' QRY "
	cQuery += "	,'" +cTipoTerc+ "' TERC "
	cQuery += "	,SB6.B6_PRODUTO "
	cQuery += "	,( CASE "
	cQuery += "			WHEN SB6REM.B6_TPCF = 'C' "
	cQuery += "				THEN 'SA1' "
	cQuery += "			WHEN SB6REM.B6_TPCF = 'F' "
	cQuery += "				THEN 'SA2' "
	cQuery += "			END "
	cQuery += "		) PESSOA "
	cQuery += "	,SB6REM.B6_CLIFOR "
	cQuery += "	,SB6REM.B6_LOJA "
	If lCliProp
		cQuery += ",SB6REM.B6_CLIPROP, SB6REM.B6_LJCLIPR"
	EndIf
	cQuery += "	,SF4.F4_ESTOQUE "
	cQuery += "	,0 "
	cQuery += "	,SB6.B6_QUANT * - 1 B6_QUANT "
	cQuery += "	,0 "

	cQuery += ",(CASE "
	cQuery += "  WHEN SF4.F4_CODIGO <'501' AND SF4REM.F4_ESTOQUE ='S' THEN SB6.B6_QUANT "
	cQuery += "  WHEN SF4.F4_CODIGO >'500' AND SF4REM.F4_ESTOQUE ='S' THEN SB6.B6_QUANT *-1 "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOFIS " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += ",(CASE "
	cQuery += "WHEN SF4.F4_CODIGO <'501' AND SF4REM.F4_ESTOQUE = 'N' THEN SB6.B6_QUANT "
	cQuery += "WHEN SF4.F4_CODIGO >'500' AND SF4REM.F4_ESTOQUE = 'N' THEN SB6.B6_QUANT *-1 "
	cQuery += "ELSE 0 "
	cQuery += "END "
	cQuery += "	 ) SALDOVIR " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += "FROM "+RetSqlName("SB6")+" SB6 "
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "	AND SB1.B1_COD = SB6.B6_PRODUTO "
	cQuery += "	AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "	AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "
	If lCpoBZTP
		cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "LEFT JOIN "+RetSqlName("SB6")+" SB6REM ON SB6REM.B6_FILIAL = '"+xFilial("SB6")+"' "
	cQuery += "	AND SB6REM.B6_IDENT = SB6.B6_IDENT "
	cQuery += "	AND SB6REM.B6_TIPO = '"+cTipoTerc+"' "
	cQuery += "	AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO "
	cQuery += "	AND SB6REM.B6_DTDIGIT <= '"+dtos(dDataAte)+"' "
	cQuery += "	AND SB6REM.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4REM ON SF4REM.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuery += "	AND SF4REM.F4_CODIGO = SB6REM.B6_TES "
	cQuery += "	AND SF4REM.F4_PODER3 = 'R' "
	If lAlmTerc
		cQuery += " AND (( SF4REM.F4_ESTOQUE = 'S') OR  (SF4REM.F4_ESTOQUE = 'N' AND SF4REM.F4_CONTERC <> '2')) "
	EndIf
	cQuery += "	AND SF4REM.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuery += "	AND SF4.F4_CODIGO = SB6.B6_TES "
	cQuery += "	AND SF4.F4_PODER3 = 'D' "
	If lAlmTerc
		cQuery += " AND (( SF4.F4_ESTOQUE = 'S') OR  (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2')) "
	EndIf
	cQuery += "	AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SB6.B6_FILIAL = '"+xFilial("SB6")+"' "
	cQuery += "	AND SB6.B6_PRODUTO BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "	AND SB6.B6_TIPO = '"+cTipoTerc+"' "
	cQuery += "	AND SB6.B6_DTDIGIT <= '"+dtos(dDataAte)+"' "
	cQuery += "	AND SB6.D_E_L_E_T_ = ' ' AND "
	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SB6.B6_PRODUTO AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

	cQuery += "AND NOT EXISTS( "
	cQuery += "SELECT 1 FROM "+ RetSqlName("SDH") +" SDH "
	cQuery += "JOIN "+ RetSqlName("SD1") +" SD1 "
	cQuery += "ON SD1.D1_FILIAL = '"+ xFilial("SD1") +"' AND SDH.DH_IDENTNF = SD1.D1_NUMSEQ AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SDH.DH_FILIAL = '"+ xFilial("SDH") +"' AND SB6.B6_DOC = SD1.D1_DOC AND SB6.B6_SERIE = SD1.D1_SERIE AND SD1.D1_FORNECE = SB6.B6_CLIFOR AND SD1.D1_LOJA = SB6.B6_LOJA AND SD1.D1_COD = SB6.B6_PRODUTO AND SD1.D1_QUANT = SB6.B6_QUANT AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += ") "

	cQuery += "AND NOT EXISTS( "
	cQuery += "SELECT 1 FROM "+ RetSqlName("SDH") +" SDH "
	cQuery += "JOIN "+ RetSqlName("SD2") +" SD2 "
	cQuery += "ON SD2.D2_FILIAL = '"+ xFilial("SD2") +"' AND SDH.DH_IDENTNF = SD2.D2_NUMSEQ AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SDH.DH_FILIAL = '"+ xFilial("SDH") +"' AND SB6.B6_DOC = SD2.D2_DOC AND SB6.B6_SERIE = SD2.D2_SERIE AND SD2.D2_CLIENTE = SB6.B6_CLIFOR AND SD2.D2_LOJA = SB6.B6_LOJA AND SD2.D2_COD = SB6.B6_PRODUTO AND SD2.D2_QUANT = SB6.B6_QUANT AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += ") "

//Saldos distribuidos pela D3K j?s? tratados na query C, n? deve compor remessa de retorno
	cQuery += "AND NOT EXISTS( "
	cQuery += "SELECT 1 FROM "+ RetSqlName("SD3")+" SD3 "
	If lAliasD3K
		cQuery += "JOIN "+RetSqlName("D3K")+" D3K ON D3K.D3K_FILIAL = '"+xFilial("D3K")+"' "
		cQuery += 	"AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
		cQuery += 	"AND D3K.D3K_CLIENT = SB6.B6_CLIFOR AND D3K.D3K_LOJA = SB6.B6_LOJA "
		cQuery += 	"AND D3K.D3K_COD = SD3.D3_COD "
		cQuery += 	"AND D3K.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE "
	cQuery += "SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
	cQuery += "AND SD3.D3_EMISSAO <= '"+DToS(dDataAte)+"' "
	cQuery += "AND SD3.D3_CF LIKE 'RE%' "
	cQuery += "AND SD3.D3_COD = SB6.B6_PRODUTO "
	cQuery += "AND SD3.D3_OP <> '  ' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD3.D3_COD AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf
	cQuery += ")"

	If cTipoTerc == "D"

		cQuery += "UNION ALL "
		// Seleciona os registros da SB6 que s? requisicao de insumos DE terceiros, quando apontado na rotina apontamento de terceiros
		cQuery += "SELECT "
		cQuery += "	'C' QRY "
		cQuery += ",'" +cTipoTerc+ "' TERC "
		cQuery += ",SD3.D3_COD ,'SA1' "
		If lAliasD3K
			cQuery += ",D3K.D3K_CLIENT ,D3K.D3K_LOJA"
			If lCliProp
				cQuery += ",' ',' '"
			EndIf
			cQuery += ",'S' "
			cQuery += ",0 "                 // remessa
			cQuery += ",0 "                 // retorno
			cQuery += ",(D3K.D3K_QTDE*-1) " // requisicao
			cQuery += ",(D3K.D3K_QTDE*-1) " // saldofis
			cQuery += ",0 "                 // saldovir
		Else
			cQuery += ",' ' D3K_CLIENT ,' ' D3K_LOJA"
			If lCliProp
				cQuery += ",' ',' '"
			EndIf
			cQuery += ",'S' "
			cQuery += ",0 "            // remessa
			cQuery += ",0 "            // retorno
			cQuery += ",0 "            // requisicao
			cQuery += ",0 "            // saldofis
			cQuery += ",0 "            // saldovir
		EndIf
		cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
		If lAliasD3K
			cQuery += "JOIN "+RetSqlName("D3K")+" D3K ON D3K.D3K_FILIAL = '"+xFilial("D3K")+"' "
			cQuery += 	"AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
			cQuery += 	"AND D3K.D3K_COD = SD3.D3_COD "
			cQuery += 	"AND D3K.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery += "	AND SB1.B1_COD = SD3.D3_COD "
		cQuery += "	AND SB1.B1_COD NOT LIKE 'MOD%' "
		cQuery += "	AND SB1.B1_CCCUSTO = ' ' "
		cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "
		If lCpoBZTP
			cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += "WHERE "
		cQuery += "SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
		cQuery += "AND SD3.D3_EMISSAO <= '"+dtos(dDataAte)+"' "
		cQuery += "AND SD3.D3_CF LIKE 'RE%' "
		cQuery += "AND SD3.D3_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
		cQuery += "AND SD3.D3_OP <> '  ' "
		cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND "
		If lCpoBZTP
			cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
		Else
			cQuery += "SB1.B1_TIPO "
		EndIF
		cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
		If lAliasD3E
			cQuery += "AND NOT EXISTS( "
			cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
			cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
			cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
			cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD3.D3_COD AND D3E.D_E_L_E_T_ = ' ' "
			cQuery += ") "
		EndIf

		cQuery += "UNION ALL "
		// Seleciona os registros da SD3 que s? producao de produtos DE terceiros, quando apontado na rotina apontamento de terceiros
		cQuery += "SELECT "
		cQuery += "	'D' QRY "
		cQuery += "	,'" +cTipoTerc+ "' TERC "
		cQuery += " ,SD3.D3_COD ,'SA1' "
		If lAliasD3K
			cQuery += ",D3K.D3K_CLIENT ,D3K.D3K_LOJA"
			If lCliProp
				cQuery += ",' ',' '"
			EndIf
			cQuery += ",'S' "
			cQuery += ",0 "            // remessa
			cQuery += ",0 "            // retorno
			cQuery += ",D3K.D3K_QTDE " // requisicao
			cQuery += ",D3K.D3K_QTDE " // saldofis
			cQuery += ",0 "            // saldovir
		Else
			cQuery += ",' ' D3K_CLIENT ,' ' D3K_LOJA"
			If lCliProp
				cQuery += ",' ',' '"
			EndIf
			cQuery += ",'S' "
			cQuery += ",0 "            // remessa
			cQuery += ",0 "            // retorno
			cQuery += ",0 "            // requisicao
			cQuery += ",0 "            // saldofis
			cQuery += ",0 "            // saldovir
		EndIf
		cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
		cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery += "	AND SB1.B1_COD = SD3.D3_COD "
		cQuery += "	AND SB1.B1_COD NOT LIKE 'MOD%' "
		cQuery += "	AND SB1.B1_CCCUSTO = ' ' "
		cQuery += "	AND SB1.D_E_L_E_T_ = ' ' "
		If lCpoBZTP
			cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
		EndIf
		If lAliasD3K
			cQuery += "JOIN "+RetSqlName("D3K")+" D3K ON D3K.D3K_FILIAL = '"+xFilial("D3K")+"' "
			cQuery += 	"AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
			cQuery += 	"AND D3K.D3K_COD = SD3.D3_COD "
			cQuery += 	"AND D3K.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += "WHERE "
		cQuery += "SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
		cQuery += "AND SD3.D3_EMISSAO <= '"+dtos(dDataAte)+"' "
		cQuery += "AND (SD3.D3_CF LIKE 'PR%' OR SD3.D3_CF LIKE 'DE%' ) "
		cQuery += "AND SD3.D3_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
		cQuery += "AND SD3.D3_OP <> '  ' "
		cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND "
		If lCpoBZTP
			cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
		Else
			cQuery += "SB1.B1_TIPO "
		EndIf
		cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
		If lAliasD3E
			cQuery += "AND NOT EXISTS( "
			cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
			cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
			cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
			cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD3.D3_COD AND D3E.D_E_L_E_T_ = ' ' "
			cQuery += ") "
		EndIf

		cQuery += "UNION ALL "
		// Seleciona os registros da SD2 que s? produtos produzidos com insumos DE terceiros, quando apontado na rotina apontamento de terceiros
		cQuery += " SELECT "
		cQuery += "	'E' QRY "
		cQuery += "	,'" +cTipoTerc+ "' TERC "
		cQuery += "	,SD2.D2_COD ,'SA1' ,SD2.D2_CLIENTE ,SD2.D2_LOJA"
		If lCliProp
			cQuery += ",' ',' '"
		EndIf
		cQuery += ",'S' "
		cQuery += ",0 "                 // remessa
		cQuery += ",0 "                 // retorno
		cQuery += ",(SD2.D2_QUANT*-1) " // requisicao
		cQuery += ",(SD2.D2_QUANT*-1) " // saldofis
		cQuery += ",0 "                 // saldovir

		cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
		cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
		cQuery += "			SB1.B1_FILIAL = '" + xFilial("SB1") +"' "
		cQuery += "			AND SB1.B1_COD = SD2.D2_COD "
		cQuery += "			AND SB1.B1_COD NOT LIKE 'MOD%' "
		cQuery += "			AND SB1.B1_CCCUSTO = ' ' "
		cQuery += "			AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "		LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON "
		cQuery += "			SBZ.BZ_FILIAL = '" + xFilial("SBZ") +"' "
		cQuery += "			AND SBZ.BZ_COD = SB1.B1_COD "
		cQuery += "			AND SBZ.D_E_L_E_T_ = ' ' "
		cQuery += "	WHERE "
		cQuery += "		SD2.D2_FILIAL = '" + xFilial("SD2") +"' "
		cQuery += " 	AND SD2.D2_EMISSAO <= '" + DTOS(dDataAte) + "' "
		cQuery += "		AND SD2.D2_EMISSAO >= (  "
		cQuery += "			SELECT "
		cQuery += "				MIN( SD3.D3_EMISSAO ) "
		cQuery += "			FROM " + RetSqlName("SD3") + " SD3 "
		If lAliasD3K
			cQuery += "				JOIN " + RetSqlName("D3K") + " D3K ON "
			cQuery += "					D3K.D3K_FILIAL = '" + xFilial("D3K") +"' "
			cQuery += "					AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
			cQuery += "					AND D3K.D3K_COD = SD3.D3_COD "
			cQuery += "					AND D3K.D_E_L_E_T_ = ' ' "
		Endif
		cQuery += "			WHERE "
		cQuery += "				SD3.D3_FILIAL = '" + xFilial("SD3") +"' "
		If lAliasD3K
			cQuery += "			AND D3K.D3K_CLIENT = SD2.D2_CLIENTE "
			cQuery += "			AND D3K.D3K_LOJA = SD2.D2_LOJA "
		Endif
		cQuery += "				AND SD3.D3_COD = SD2.D2_COD "
		cQuery += "				AND SD3.D3_CF LIKE 'PR%' "
		cQuery += "				AND SD3.D3_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
		cQuery += "				AND SD3.D_E_L_E_T_ = ' ' ) AND "

		If lCpoBZTP
			cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
		Else
			cQuery += "SB1.B1_TIPO "
		EndIf
		cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
		If lAliasD3E
			cQuery += "AND NOT EXISTS( "
			cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
			cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
			cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
			cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD2.D2_COD AND D3E.D_E_L_E_T_ = ' ' "
			cQuery += ") "
		EndIf

	EndIf

	//-- Opera?o triangular (Recebimento)
	cQuery += "UNION ALL "
	cQuery += " SELECT "
	cQuery += "	'F' QRY "
	cQuery += "	,'" +cTipoTerc+ "' TERC "
	cQuery += "		,SD1.D1_COD B6_PRODUTO, "
	cQuery += "    (CASE "
	cQuery += "			WHEN SDH.DH_CLIENTE = '" + Space(nTamDhCli) + "' AND SDH.DH_LOJACLI = '" + Space(nTamDhLoj) + "' THEN 'SA2' "
	cQuery += "			ELSE 'SA1' "
	cQuery += "		END) PESSOA, "
	cQuery += "     (CASE "
	cQuery += "      	WHEN SDH.DH_CLIENTE = '" + Space(nTamDhCli) + "' THEN SDH.DH_FORNECE "
	cQuery += "         ELSE SDH.DH_CLIENTE "
	cQuery += "      END) B6_CLIFOR, "
	cQuery += "     (CASE "
	cQuery += "      	WHEN SDH.DH_LOJACLI = '" + Space(nTamDhLoj) + "' THEN SDH.DH_LOJAFOR "
	cQuery += "         ELSE SDH.DH_LOJACLI"
	cQuery += "      END) B6_LOJA "
	If lCliProp
		cQuery += ",' ',' '"
	EndIf
	cQuery += "     ,F4_ESTOQUE "

	If cTipoTerc == "D"
		cQuery += " 	,SD1.D1_QUANT REMESSA "
		cQuery += " 	,0 RETORNO "
		cQuery += " 	,0 REQUISICAO "
	Else
		cQuery += " 	,0 REMESSA "
		cQuery += " 	,(SD1.D1_QUANT * -1) RETORNO "
		cQuery += " 	,0 REQUISICAO "
	EndIf

	cQuery += ",(CASE "
	cQuery += "  WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='S' THEN SD1.D1_QUANT "
	cQuery += "  WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='S' THEN SD1.D1_QUANT *-1 "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOFIS " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += ",(CASE "
	cQuery += "	 WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='N' THEN SD1.D1_QUANT *-1 "
	cQuery += "	 WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='N' THEN SD1.D1_QUANT "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOVIR " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
	cQuery += "			SB1.B1_FILIAL = '" + xFilial("SB1") +"' "
	cQuery += "			AND SB1.B1_COD = SD1.D1_COD "
	cQuery += "			AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "			AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "			AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "		LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON "
	cQuery += "			SBZ.BZ_FILIAL = '" + xFilial("SBZ") +"' "
	cQuery += "			AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "			AND SBZ.D_E_L_E_T_ = ' ' "
	cQuery += "		INNER JOIN " + RetSqlName("SDH") + " SDH ON "
	cQuery += "			SDH.DH_FILIAL = '" + xFilial("SDH") +"' "
	cQuery += "			AND SDH.DH_IDENTNF = SD1.D1_NUMSEQ "
	cQuery += "			AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuery += "	AND SF4.F4_CODIGO = SD1.D1_TES "
	If cTipoTerc == "D"
		cQuery += "	AND SF4.F4_PODER3 = 'R' "
	Else
		cQuery += "	AND SF4.F4_PODER3 = 'D' "
	EndIf
	cQuery += "		AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "	WHERE "
	cQuery += "		SD1.D1_DTDIGIT <= '"+dtos(dDataAte)+"' "
	cQuery += "		AND SD1.D1_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "		AND SD1.D_E_L_E_T_ = ' ' AND "

	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD1.D1_COD AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

	//-- Opera?o triangular (Devolu?o)

	cQuery += "UNION ALL "
	cQuery += " SELECT "
	cQuery += "	'G' QRY "
	cQuery += "	,'" +cTipoTerc+ "' TERC "
	cQuery += "		,SD2.D2_COD B6_PRODUTO, "
	cQuery += "    (CASE "
	cQuery += "			WHEN SDH.DH_CLIENTE = '" + Space(nTamDhCli) + "' AND SDH.DH_LOJACLI = '" + Space(nTamDhLoj) + "' THEN 'SA2' "
	cQuery += "			ELSE 'SA1' "
	cQuery += "		END) PESSOA, "
	cQuery += "     (CASE "
	cQuery += "      	WHEN SDH.DH_CLIENTE = '" + Space(nTamDhCli) + "' THEN SDH.DH_FORNECE "
	cQuery += "         ELSE SDH.DH_CLIENTE "
	cQuery += "      END) B6_CLIFOR, "
	cQuery += "     (CASE "
	cQuery += "      	WHEN SDH.DH_LOJACLI = '" + Space(nTamDhLoj) + "' THEN SDH.DH_LOJAFOR "
	cQuery += "         ELSE SDH.DH_LOJACLI"
	cQuery += "      END) B6_LOJA "
	If lCliProp
		cQuery += ",' ',' '"
	EndIf
	cQuery += "     ,'S' F4_ESTOQUE,"

	If cTipoTerc == "D"
		cQuery += " 	0 REMESSA "
		cQuery += " 	,(SD2.D2_QUANT * -1) RETORNO "
		cQuery += " 	,0 REQUISICAO"
	Else
		cQuery += " 	SD2.D2_QUANT REMESSA "
		cQuery += " 	,0 RETORNO "
		cQuery += " 	,0 REQUISICAO"
	EndIf

	cQuery += ",(CASE "
	cQuery += "  WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='S' THEN SD2.D2_QUANT "
	cQuery += "  WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='S' THEN SD2.D2_QUANT *-1 "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOFIS " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += ",(CASE "
	cQuery += "	 WHEN SF4.F4_CODIGO <'501' AND SF4.F4_ESTOQUE ='N' THEN 0 "
	cQuery += "	 WHEN SF4.F4_CODIGO >'500' AND SF4.F4_ESTOQUE ='N' THEN SD2.D2_QUANT "
	cQuery += "  ELSE 0 "
	cQuery += "  END "
	cQuery += "	 ) SALDOVIR " // Se movimentou estoque, deve considerar para abater no saldo proprio. se n?o movimentou deve considerar somente a quantidade de saiu.

	cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += "		INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
	cQuery += "			SB1.B1_FILIAL = '" + xFilial("SB1") +"' "
	cQuery += "			AND SB1.B1_COD = SD2.D2_COD "
	cQuery += "			AND SB1.B1_COD NOT LIKE 'MOD%' "
	cQuery += "			AND SB1.B1_CCCUSTO = ' ' "
	cQuery += "			AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "		LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON "
	cQuery += "			SBZ.BZ_FILIAL = '" + xFilial("SBZ") +"' "
	cQuery += "			AND SBZ.BZ_COD = SB1.B1_COD "
	cQuery += "			AND SBZ.D_E_L_E_T_ = ' ' "
	cQuery += "		INNER JOIN " + RetSqlName("SDH") + " SDH ON "
	cQuery += "			SDH.DH_FILIAL = '" + xFilial("SDH") +"' "
	cQuery += "			AND SDH.DH_IDENTNF = SD2.D2_NUMSEQ "
	cQuery += "			AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuery += "	AND SF4.F4_CODIGO = SD2.D2_TES "
	If cTipoTerc == "D"
		cQuery += "	AND SF4.F4_PODER3 = 'D' "
	Else
		cQuery += "	AND SF4.F4_PODER3 = 'R' "
	EndIf
	cQuery += "		AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "	WHERE "
	cQuery += "		SD2.D2_EMISSAO <= '"+dtos(dDataAte)+"' "
	cQuery += "		AND SD2.D2_COD BETWEEN '"+cCodProdDe+"' AND '"+cCodProdAte+"' "
	cQuery += "		AND SD2.D_E_L_E_T_ = ' ' AND "

	If lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += "SB1.B1_TIPO "
	EndIF
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	If lAliasD3E
		cQuery += "AND NOT EXISTS( "
		cQuery += "SELECT 1 FROM "+ RetSqlName("D3E") +" D3E "
		cQuery += "JOIN "+ RetSqlName("SA1") +" SA1 "
		cQuery += "ON SA1.A1_FILIAL = '"+ xFilial("SA1") +"' AND SA1.A1_COD = D3E.D3E_CLIENT AND SA1.A1_LOJA = D3E.D3E_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D3E.D3E_FILIAL = '"+ xFilial("D3E") +"' AND D3E.D3E_COD = SD2.D2_COD AND D3E.D_E_L_E_T_ = ' ' "
		cQuery += ") "
	EndIf

	cQuery += ") SaldoTerceiro "
	cQuery += " GROUP BY B6_PRODUTO, PESSOA ,B6_CLIFOR ,B6_LOJA "
	If lCliProp
		cQuery += ",B6_CLIPROP,B6_LJCLIPR"
	EndIf
	cQuery += " ORDER BY 1 "

	cQuery := ChangeQuery(cQuery)

Return cQuery


Static Function ProcSumTerc(cAliK200,cAliSumTer)
	Local cAliasQry
	Local cTableTerc
	Local cQuery
	Local aArea
	Local aAreaK200
	Local nQtd

	aArea := GetArea()
	cTableTerc := cAliSumTer
	cQuery := ""
	cQuery += "SELECT FILIAL,DT_EST,COD_ITEM, QTDFIS ,QTDVIR "
	cQuery += "FROM " + cTableTerc + " "
	cQuery += "WHERE "
	cQuery += " (QTDFIS >0 "
	cQuery += " OR QTDVIR <0) "
	cQuery += "AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY COD_ITEM "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := CriaTrab(,.F.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If Select(cAliasQry) >0
		dbSelectArea(cAliK200)
		aAreaK200 := GetArea()
		dbSetOrder(1) // FILIAL+DTOS(DT_EST)+COD_ITEM+IND_EST+COD_PART

		While !(cAliasQry)->(Eof())

			If MsSeek((cAliasQry)->(FILIAL+DT_EST+COD_ITEM+"0"))

				nQtd := 0
				If (cAliasQry)->QTDFIS > 0
					nQtd += (cAliasQry)->QTDFIS
				EndIf
				If (cAliasQry)->QTDVIR < 0
					nQtd -= (cAliasQry)->QTDVIR
				EndIf

				If ((cAliK200)->QTD - nQtd) <= 0
					Reclock(cAliK200,.F.)
					DbDelete()
					(cAliK200)->(MsUnLock())
				Else
					Reclock(cAliK200,.F.)
					(cAliK200)->QTD -= nQtd
					(cAliK200)->(MsUnLock())
				EndIf
			EndIf

			(cAliasQry)->(dbSkip())
		EndDo

		(cAliasQry)->(dbCloseArea())

		RestArea(aAreaK200)
	EndIf
	RestArea(aArea)

Return
