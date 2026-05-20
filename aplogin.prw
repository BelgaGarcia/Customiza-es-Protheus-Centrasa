#Include "Protheus.ch"
 
User Function AfterLogin()
    Local cUser := RetCodUsr()
 
    //Filtra somente os pedidos que o usuário fez
    If nModulo == 5
        DbSelectArea('SC5')
        If cUser != '000000'
            SC5->(DbSetFilter({|| C5_X_USR == cUser }, "C5_X_USR == '"+cUser+"'"))
        EndIf
    EndIf
Return
