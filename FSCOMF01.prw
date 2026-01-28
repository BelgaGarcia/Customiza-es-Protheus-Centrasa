#include "protheus.ch"             
#include "rwmake.ch"   
#include "fwprintsetup.ch"
#include "error.ch"
#include "common.ch"
#include "topconn.ch"   
#include 'fwmvcdef.ch'
#include "colors.ch"
#include "tbiconn.ch"
#include "fwmvcdef.ch"

User Function FSCOMF01()

    Local lRet := .F.
    Local cExc := "S" //-- M = Menu Protheus | S = Schedule

    If cExc == "S"
        RpcSetType(3)
        RpcSetEnv("01","001001")

        processaEnvioWorkFlow()

        RpcClearEnv()
    Else
        processaEnvioWorkFlow()
        lRet := .T.
    Endif

Return(lRet)

//+-----------------------------------------------------------------
//+ PTorres | Outubro/2024 | Processando o Envio do Workflow       +
//+-----------------------------------------------------------------
Static Function processaEnvioWorkFlow()

	Local cLayout           := ""
	Local cAnexos           := ""
	Local cDestin           := ""
    Local cEnderecoEmail    := GetNewPar("ZM_EMLPOD3","")
  
  	Private aSB6 := buscaRegPoderTerceiro()

    If ( !Empty(aSB6) ) .And. ( !Empty( cEnderecoEmail ))
		cLayout := layoutEnvioWorkFlow()
		cAnexos := ""
		cDestin := cEnderecoEmail

		enviaEmail(cDestin,"Poder de Terceiros",cLayout,cAnexos,.F.)
    Endif

Return(Nil)

//+-----------------------------------------------------------------
//+ PTorres | Outubro/2024 | Busca Registros em Poder de Terceiros +
//+-----------------------------------------------------------------
Static Function buscaRegPoderTerceiro()

    Local aAlias        := GetArea()
    Local cAlias        := GetNextAlias()
    Local cQuery        := ""

    Local aRet          := {}
    Local nDiasAVencer  := 0
    Local nDiasVencido  := 0
    Local nLimPrazo     := GetNewPar("FS_LDTIME",.F.)
    Local cRazaoSocial  := ""

	cQuery := " SELECT * FROM " + RetSqlTab("SB6") + " " + CRLF
    cQuery += " WHERE " + RetSqlDel("SB6") + CRLF
    cQuery += "   AND " + RetSqlFil("SB6") + CRLF
    cQuery += "   AND B6_SALDO   > 0 And B6_ZDATRET <> ' ' " + CRLF
    cQuery += " ORDER BY R_E_C_N_O_ " + CRLF

	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

    dbSelectArea("SA1")
    SA1->(dbSetorder(1))

    dbSelectArea("SA2")
    SA2->(dbSetorder(1))

	While (cAlias)->(!Eof())

        nDiasVencido    := -1
        nDiasAVencer    := -1

        If ( STOD((cAlias)->B6_ZDATRET) <= dDatabase  )
            nDiasVencido    := DateDiffDay(STOD((cAlias)->B6_ZDATRET),dDatabase)
        Else
            nDiasAVencer    := DateDiffDay(STOD((cAlias)->B6_ZDATRET),dDatabase)
        Endif

        If ( ( nDiasAVencer >= 0) .And. ( nDiasAVencer <= nLimPrazo ) ) .Or. ( nDiasVencido >= 0 )

            cRazaoSocial := ""    

            If ( (cAlias)->B6_TPCF  == "C" )
                If ( SA1->(dbSeek(FWxFilial("SA1")+(cAlias)->B6_CLIFOR+(cAlias)->B6_LOJA)) )
                    cRazaoSocial := SA1->A1_NOME
                Endif
            ElseIf ( (cAlias)->B6_TPCF  == "F" )
                If ( SA2->(dbSeek(FWxFilial("SA2")+(cAlias)->B6_CLIFOR+(cAlias)->B6_LOJA)) )
                    cRazaoSocial := SA2->A2_NOME
                Endif
            Endif        

            AADD( aRet , { (cAlias)->B6_FILIAL          ,; //-- 01
                           (cAlias)->B6_DOC             ,; //-- 02
                           (cAlias)->B6_SERIE           ,; //-- 03
                           (cAlias)->B6_CLIFOR          ,; //-- 04
                           (cAlias)->B6_LOJA            ,; //-- 05
                           cRazaoSocial                 ,; //-- 06    
                           (cAlias)->B6_PRODUTO         ,; //-- 07
                           STOD((cAlias)->B6_EMISSAO)   ,; //-- 08
                           STOD((cAlias)->B6_ZDATRET)   ,; //-- 09
                           nDiasAVencer                 ,; //-- 10
                           nDiasVencido                 ,; //-- 11
                           (cAlias)->B6_IDENT    })        //-- 12

        Endif

   		(cAlias)->(DbSkip())
	Enddo

	(cAlias)->(DbCloseArea())

    RestArea(aAlias)

Return(aRet)

//+-----------------------------------------------------------------
//+ PTorres | Outubro/2024 | Monta o Layout de Envio do Workflow   +
//+-----------------------------------------------------------------
Static Function layoutEnvioWorkFlow()

    Local cHtml := ''
    Local nX    := 0

    cHtml := '<html>'
    cHtml += '<head>'
    cHtml += '<meta http-equiv="Content-Language" content="en-us">'
    cHtml += '<meta http-equiv="Content-Type"'
    cHtml += 'content="text/html; charset=iso-8859-1">'
    cHtml += '<meta name="ProgId" content="FrontPage.Editor.Document">'
    cHtml += '<meta name="GENERATOR" content="Microsoft FrontPage 6.0">'
    cHtml += '<title>CENTRASA</title>'
    cHtml += '</head>'
    cHtml += '<body background="" style="background-repeat: no-repeat"'
    cHtml += 'bgcolor="#FFFFFF" bgproperties="fixed">'
    cHtml += '<script>'
    cHtml += 'function commaToNumber(cNumber) {'
    cHtml += '	return parseFloat(cNumber.replace(",", "."));'
    cHtml += '}'
    cHtml += 'function formatZeros(nNumber) {'
    cHtml += '   var cNumber = nNumber.toString().replace(".", ",");'
    cHtml += '   var nPos = cNumber.search(",");'
    cHtml += '   var nDif = cNumber.length - nPos;'
    cHtml += '   if(nPos == -1)'
    cHtml += '      cNumber = cNumber+",00";'
    cHtml += '   else if( nDif == 2 )'
    cHtml += '      cNumber = cNumber+"0";'
    cHtml += '   else if( nDif >= 4 )'
    cHtml += '      cNumber = cNumber.substr(0, cNumber.length - nDif + 3);'   
    cHtml += '   return cNumber;'
    cHtml += '}'
    cHtml += '</script>'
    cHtml += '<form action="mailto:%WFMailTo%" onSubmit="return FrontPage_Form1_Validator(this)" method="POST" name="FrontPage_Form1">'
    cHtml += '<table width="100%" border="0" background="" >'
    cHtml += '      <tr>'
    cHtml += '        <th width="74%" scope="col"><div align="left"><font color="#FFFFFF" size="4" face="Arial"><strong></strong></font></th>
    cHtml += '	       <BR>A seguir, relacao de documentos que estao com o limite de retorno proximo:<BR></p> <font color="#FFFFFF" size="2" face="Arial"><strong></strong></font></div>'
    cHtml += '        <BR>'
    cHtml += '      </tr>'
    cHtml += '</table>'

    If Len(aSB6) > 0
        cHtml += '<table border="0" width="80%" bgcolor="#FFFFFF" bordercolor="#D3D3D3" bordercolordark="#D3D3D3" bordercolorlight="#D3D3D3">'
        cHtml += '       <tr>'			
        cHtml += '           <td align="center" width="050" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>FILIAL</b></font></td>'			
        cHtml += '           <td align="center" width="050" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>DOCUMENTO</b></font></td>'
        cHtml += '           <td align="center" width="025" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>SERIE</b></font></td>'
        cHtml += '           <td align="center" width="025" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>CLI|FOR</b></font></td>'
        cHtml += '           <td align="center" width="100" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>LOJA</b></font></td>'
        cHtml += '           <td align="center" width="500" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>RAZAO SOCIAL</b></font></td>'
        cHtml += '           <td align="center" width="150" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>PRODUTO</b></font></td>'
        cHtml += '           <td align="center" width="150" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>EMISSAO</b></font></td>'
        cHtml += '           <td align="center" width="150" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>DATA PRAZO</b></font></td>'
        cHtml += '           <td align="center" width="150" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>DIAS A VENCER</b></font></td>'
        cHtml += '           <td align="center" width="150" bgcolor="#87CEEB" height="25"><font size="2" face="Arial"><b>DIAS VENCIDOS</b></font></td>'
        cHtml += '       </tr>'

        For nX := 1 To Len(aSB6)
            cHtml += '   <tr>'
            cHtml += '       <td align="center" width="050" height="25"><font size="2" face="Arial">'+AllTrim(aSB6[nX,1])+'</font></td>'
            cHtml += '       <td align="center" width="050" height="25"><font size="2" face="Arial">'+AllTrim(aSB6[nX,2])+'</font></td>'
            cHtml += '       <td align="center" width="025" height="25"><font size="2" face="Arial">'+AllTrim(aSB6[nX,3])+'</font></td>'
            cHtml += '       <td align="center" width="025" height="25"><font size="2" face="Arial">'+AllTrim(aSB6[nX,4])+'</font></td>'
            cHtml += '       <td align="center" width="025" height="25"><font size="2" face="Arial">'+AllTrim(aSB6[nX,5])+'</font></td>'
            cHtml += '       <td align="left" width="500" height="25"><font size="2" face="Arial">'+AllTrim(aSB6[nX,6])+'</font></td>'
            cHtml += '       <td align="center" width="025" height="25"><font size="2" face="Arial">'+AllTrim(aSB6[nX,7])+'</font></td>'
            cHtml += '       <td align="center" width="025" height="25"><font size="2" face="Arial">'+cValToChar(aSB6[nX,8])+'</font></td>'
            cHtml += '       <td align="center" width="025" height="25"><font size="2" face="Arial">'+cValToChar(aSB6[nX,9])+'</font></td>'
            cHtml += '       <td align="center" width="100" height="25"><font size="2" face="Arial">'+Iif(aSB6[nX,10] == -1,"",AllTrim(Str(aSB6[nX,10])))+'</font></td>'
            cHtml += '       <td align="center" width="100" height="25"><font size="2" face="Arial">'+Iif(aSB6[nX,11] == -1,"",AllTrim(Str(aSB6[nX,11])))+'</font></td>'
          //  cHtml += '       <td align="center" width="100" height="25"><font size="2" face="Arial">'+AllTrim(aSB6[nX,11])+'</font></td>'
            cHtml += '   </tr>'
        Next nX

        cHtml += '</table>'
    Endif

    cHtml += '</form>'
    cHtml += '</body>'
    cHtml += '</html>'

Return(cHtml)

//+-----------------------------------------------------------------
//+ PTorres | Outubro/2024 | Realiza o Envio do E-mail             +
//+-----------------------------------------------------------------
Static Function enviaEmail(cDestin,cAssunto,cMensagem,cAnexos,lUsaLogado)

	Local lMailAuth	    := SuperGetMv("MV_RELAUTH",,.F.)
	Local cMailServer   := SuperGetMv("MV_RELSERV",,"")
	Local cMailConta    := SuperGetMV("MV_RELACNT",,"")
	Local cMailFrom	    := SuperGetMV("MV_RELFROM",,"")
	Local cMailSenha    := SuperGetMV("MV_RELPSW" ,,"")
	Local lUseSSL	    := SuperGetMV("MV_RELSSL" ,,.F.)
	Local lUseTLS	    := SuperGetMV("MV_RELTLS" ,,.F.)

	Local cServer	    := ""
	Local nPort		    := 0
	Local nErro		    := 0
	Local nAt		    := At(':',cMailServer)
	Local oMail         := Nil
	Local lEnviou	    := .F.
	Local cEmailLog     := ""

	Default cAnexos     := ""
	Default cMensagem   := ""
	Default cDestin	    := ""
	Default lUsaLogado  := .F.

	If (nAt > 0)
		cServer	:= SubStr(cMailServer,1,(nAt - 1))
		nPort	:= Val(AllTrim(SubStr(cMailServer,(nAt + 1),Len(cMailServer))))
	Else
		cServer	:= cMailServer
	Endif

	oMail := TMailManager():New()
	oMail:SetUseSSL(lUseSSL)
	oMail:SetUseTLS(lUseTLS)
	oMail:Init("", cServer, cMailConta, cMailSenha , 0 , nPort)

	nErro := oMail:SMTPConnect()

	If (nErro == 0)
		If lMailAuth
			nErro := oMail:SMTPAuth(cMailConta,cMailSenha)
			
			If nErro != 0
				nErro := oMail:SMTPAuth(cMailConta,cMailSenha)
				
				If nErro != 0
					Return .F.
				Endif
			EndIf
		Endif

		If (nErro == 0)
			oMessage := TMailMessage():New()

			oMessage:Clear()

			oMessage:cFrom 		:= cMailFrom
			oMessage:cTo 		:= AllTrim(cDestin)
			oMessage:cCc 		:= ""
			oMessage:cBcc 		:= cEmailLog
			oMessage:cSubject 	:= cAssunto
			oMessage:cBody 		:= cMensagem

			If (nErro == 0)
				nErro := oMessage:Send(oMail)
				
				If nErro == 0
					lEnviou := .T.
				Endif
			Endif

			oMail:SmtpDisconnect()
		Endif
	Endif

Return(lEnviou)
