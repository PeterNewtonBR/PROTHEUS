#include "protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

/*/{Protheus.doc} AlvaraValido
Verificar se o alvará de um determinado cliente está válido para um produto em determinado período.
@type function
@version  1
@author Peter Newton
@since 28/06/2023
/*/
user function AlvaraValido(cCliente, cProduto, dDataVerif)

    local lRetorno := .T.

    If Select("SQLALVARA") > 0
        dbSelectArea("SQLALVARA")
        dbCloseArea()
    EndIf

    BeginSQL Alias "SQLALVARA"

        SELECT TOP(1) B1_VERALVA, SA1.A1_NOME, ZZA.ZZA_DTVCTO
        FROM %table:SB1% SB1 
        INNER JOIN %table:SA1% SA1 ON SA1.A1_COD = %Exp:cCliente% 
        LEFT JOIN %table:ZZA% ZZA ON ZZA.ZZA_CLIENT = SA1.A1_COD 
            AND ZZA.ZZA_PRODUT = SB1.B1_COD
            AND ZZA.ZZA_FILIAL = SB1.B1_FILIAL
            AND ISNULL(SA1.A1_EST, '') = ISNULL(ZZA.ZZA_UF, '')
	        AND ISNULL(SA1.A1_COD_MUN, '') = ISNULL(ZZA.ZZA_CODMUN, '') 
        WHERE SB1.B1_COD = %Exp:cProduto%

    EndSQL

    // verificar se este produto precisa de alvará
    if SQLALVARA->B1_VERALVA == "S"

        // Se o alvará for inexistente, invalidará
        if Vazio(SQLALVARA->ZZA_DTVCTO)
            lRetorno := .F.
            FWAlertError("Alavará <b>INEXISTENTE</b> para o produto de código: "+cProduto+"<br>- Verifique se o alvará pertence ao mesmo estado e/ou município do cliente.", "Impossível Prosseguir")
            return lRetorno
        endif

        // Se o alvará estiver vencido, invalidará
        if StoD(SQLALVARA->ZZA_DTVCTO) < dDataVerif
            lRetorno := .F.
            FWAlertError("Alavará <b>VENCIDO</b> para o produto de código: "+cProduto, "Impossível Prosseguir")
        endif

    endif

    dbSelectArea("SQLALVARA")
    dbCloseArea()

return lRetorno
