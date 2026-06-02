#Include "Protheus.ch"

/*------------------------------------------------------------------------------------------------------*
 | P.E.:  AfterLogin                                                                                    |
 | Desc:  Função chamada após o login do usuário e no MDI a cada nova aba                               |
 | Links: http://tdn.totvs.com/pages/releaseview.action?pageId=6815186                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function AfterLogin()
    //u_TLPPIncs()
    //fiscal.relatorios.u_notasSaida()
    //custom.relatorio.u_relatorioPorTipo()
    fiscal.relatorios.u_notasSaida()
    custom.writelogs.WriteLogs("Login realizado com sucesso!")
    //u_FSPCPC01()
Return
 