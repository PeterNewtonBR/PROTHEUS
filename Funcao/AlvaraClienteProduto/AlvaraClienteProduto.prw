#include "protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

/*/{Protheus.doc} MTA410
@Description Ponto de entrada no pedido de venda
@Author 	 Peter Newton
@Since  	 12/06/2023
/*/
User Function MTA410(Args)
    
    Local aArea      := GetArea()
    Local aAreaC5    := SC5->(GetArea())
    Local oDados     := DadosGrid():New()
    Local lRet       := .T.
    Local i          := 0
    Local aQtdeItems := 0
    Local dDataVerif := M->C5_EMISSAO
    
    oDados:SetGrid(aHeader, aCols)

    // Capturar todos os dados da Grid
    aDados := oDados:GetAll()
    aQtdeItems := aDados:GetNames()

    for i := 1 to len(aQtdeItems)

        if lRet == .F. 
            exit
        endif
        // Capturar dados da linha
        aItem := oDados:GetLine(i)
        lRet := AlvaraValido(M->C5_CLIENTE, aItem["C6_PRODUTO"], dDataVerif) 
                
    next i
       
    RestArea(aAreaC5)
    RestArea(aArea)
    
Return lRet

static function AlvaraValido(cCliente, cProduto, dDataVerif)

    local lRetorno := .T.

    If Select("SQLALVARA") > 0
        dbSelectArea("SQLALVARA")
        dbCloseArea()
    EndIf

    BeginSQL Alias "SQLALVARA"

        SELECT TOP(1) B1_VERALVA, SA1.A1_NOME, ZZA.ZZA_DTVCTO
        FROM %table:SB1% SB1 
        INNER JOIN %table:SA1% SA1 ON SA1.A1_COD = %Exp:cCliente% 
            AND SA1.%notDel%
        LEFT JOIN %table:ZZA% ZZA ON ZZA.ZZA_CLIENT = SA1.A1_COD 
            AND ZZA.ZZA_PRODUT = SB1.B1_COD
            AND ZZA.ZZA_FILIAL = SB1.B1_FILIAL
            AND ISNULL(SA1.A1_EST, '') = ISNULL(ZZA.ZZA_UF, '')
	        AND ISNULL(SA1.A1_COD_MUN, '') = ISNULL(ZZA.ZZA_CODMUN, '') 
            AND ZZA.%notDel%
        WHERE SB1.B1_COD = %Exp:cProduto%
        AND SB1.%notDel%

    EndSQL

    conout(GetLastQuery()[2])

    // verificar se este produto precisa de alvar�
    if SQLALVARA->B1_VERALVA == "S"

        // Se o alvar� for inexistente, invalidar�
        if Vazio(SQLALVARA->ZZA_DTVCTO)
            lRetorno := .F.
            FWAlertError("Alavar� <b>INEXISTENTE</b> para o produto de c�digo: "+cProduto+"<br>- Verifique se o alvar� pertence ao mesmo estado e/ou munic�pio do cliente.", "Imposs�vel Prosseguir")
        endif

        // Se o alvar� estiver vencido, invalidar�
        if StoD(SQLALVARA->ZZA_DTVCTO) < dDataVerif
            lRetorno := .F.
            FWAlertError("Alavar� <b>VENCIDO</b> para o produto de c�digo: "+cProduto, "Imposs�vel Prosseguir")
        endif

    endif

    dbSelectArea("SQLALVARA")
    dbCloseArea()

return lRetorno
