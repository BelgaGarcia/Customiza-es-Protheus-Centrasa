#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PE01NFESEFAZ
                             
PE para incluir mensagens personalizadas e alterar informações do Array de Produtos

@type function
@author Gabriel Gonçalves
@since 24/10/2024
@version P12
@database MSSQL

@return aRetorno Array de Retorno do Fonte NFESEFAZ {aProd, cMensCli, cMensFis, aDest, aNota, aInfoItem, aDupl, aTransp, aEntrega, aRetirada, aVeiculo, aReboque, aNfVincRur, aEspVol, aNfVinc, aDetPag, aObsCont, aMed}
/*/
User Function PE01NFESEFAZ()
	Local aRetorno		:= PARAMIXB
	Local lLigaSegUM	:= GetNewPar("ZM_SEGUNME", .F.)
	Local lNFSaida		:= aRetorno[5,4] == "1"
	Local lNFEntrada	:= aRetorno[5,4] == "0"

	If lNFSaida //Regras para as notas de saida
		// Realiza tratamento da segunda unidade de medida
		If lLigaSegUM .And. (Findfunction("faturamento.nf.u_segundaUnidadeMedida"), .T.)
			aRetorno := faturamento.nf.u_segundaUnidadeMedida(aRetorno)
		EndIf

		// Adiciona as mensagens customizadas da quarta nota
		If FindFunction("faturamento.nf.dadosComplementares.u_quartaNota")
			aRetorno[3]	:= aRetorno[3] + ' ' + faturamento.nf.dadosComplementares.u_quartaNota(aRetorno[1])
		EndIf

		// Realiza tratamento do icms diferido - OBS: DEVE SER A PRIMEIRA MSG
		If FindFunction("faturamento.nf.dadosComplementares.u_icmsDiferido")
			aRetorno[3] := faturamento.nf.dadosComplementares.u_icmsDiferido() + aRetorno[3]
		EndIf

	ElseIf lNFEntrada //Regras para as notas de entrada
	EndIf
Return aRetorno
