#include "protheus.ch"

/*/{Protheus.doc} User Function U_PedidoPeriodo
    Verifica se um pedido pode ser realizado para um cliente aplicando a regra da quantidade de venda por período
    Regra da tabela SC9 - Pedidos Liberados
    @author Peter Newton
    @since 19/03/2023
    @version 1
    @param cCliente, cProduto, nQtdeDesej
    @return bool
    /*/
User Function PedidoPeriodo(cCliente, cProduto, nQtdeDesej)
    
    Local cComplQr        := "" // complementa query
    Local nLoop           := 0
    Local cNmSql          := ''
    Local cTxtRet         := "" // texto para informar quantidade já utilizada
    Local cTxtDisponivel  := "" // texto do cálculco de disponibilidade
    Local nQtdeDisponivel := 0
    Local lRetorno        := .T.
    Local cClientCod      := ""
    Local cClientNm       := ""
    Local cProdutoNm      := ""
    Local cTxtRegra    := ""

    nQtdeDesej := val(nQtdeDesej)

    BeginSql Alias "SQLPERIODO"

        SELECT ZZZ_QTDE, ZZZ_PERIOD, SB1.B1_UM, SX5.X5_DESCRI PERIODO, SB1.B1_DESC, SA1.A1_COD, SA1.A1_NOME
        FROM %table:ZZZ% ZZZ
        INNER JOIN %table:SB1% SB1 ON ZZZ.ZZZ_PRODUT = SB1.B1_COD
        INNER JOIN %table:SX5% SX5 ON SX5.X5_CHAVE = ZZZ_PERIOD
        INNER JOIN %table:SA1% SA1 ON SA1.A1_COD = ZZZ.ZZZ_CLIENT
        WHERE ZZZ.ZZZ_CLIENT = %Exp:cCliente%
        AND ZZZ.ZZZ_PRODUT = %Exp:cProduto%
        AND SX5.X5_TABELA = 'ZZ'

    EndSql
    
    While !SQLPERIODO->(EoF())

        nLoop++
        cComplQr := "%"
        cClientCod := SQLPERIODO->A1_COD
        cClientNm := SQLPERIODO->A1_NOME
        cProdutoNm := SQLPERIODO->B1_DESC

        if SQLPERIODO->ZZZ_PERIOD == "DIA"
            cComplQr += "AND SC9.C9_DATALIB = LEFT(CONVERT(VARCHAR(8), CAST(GETDATE() AS DATE), 112), 8) GROUP BY C9_DATALIB"
        elseif SQLPERIODO->ZZZ_PERIOD == "SEM"
            cComplQr += "AND CAST(DATEPART(YEAR, CONVERT(DATETIME, SC9.C9_DATALIB)) AS VARCHAR) + CAST(DATEPART(WK, CONVERT(DATETIME, SC9.C9_DATALIB)) AS VARCHAR) = CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) + CAST(DATEPART(WK, GETDATE()) AS VARCHAR) GROUP BY DATEPART(WK, CONVERT(DATETIME, SC9.C9_DATALIB))"
        elseif SQLPERIODO->ZZZ_PERIOD == "MES"
            cComplQr += "AND LEFT(SC9.C9_DATALIB, 6) = LEFT(CONVERT(VARCHAR(8), GETDATE(), 112), 6) GROUP BY LEFT(SC9.C9_DATALIB, 6)"
        elseif SQLPERIODO->ZZZ_PERIOD == "ANO"
            cComplQr += "AND CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) = CAST(DATEPART(YEAR, CONVERT(DATETIME, SC9.C9_DATALIB)) AS VARCHAR) GROUP BY DATEPART(YEAR, CONVERT(DATETIME, SC9.C9_DATALIB))"
        endif

        cComplQr += "%"

        cNmSql := "SQL"+cvaltochar(nLoop)

        BeginSql Alias cNmSql

            SELECT SUM(SC9.C9_QTDLIB) TOTAL
            FROM %table:SC9% SC9
            INNER JOIN %table:SC6% SC6 ON SC6.C6_NUM = SC9.C9_PEDIDO
                AND SC6.C6_ITEM = SC9.C9_ITEM
                AND SC6.D_E_L_E_T_ = ' '
            WHERE SC9.C9_CLIENTE = %Exp:cCliente%
            AND SC9.C9_PRODUTO = %Exp:cProduto%
            AND SC9.D_E_L_E_T_ = ' '
            %Exp:cComplQr%            

        EndSql
        
        cTxtRet += CRLF + "Limite por '" + PADR(TRIM(SQLPERIODO->PERIODO) + "'", 8) + " = " + PADR(cvaltochar(SQLPERIODO->ZZZ_QTDE), 5) + " " + SQLPERIODO->B1_UM
        cTxtRet += " | Atingido:  " + PADR(cvaltochar((cNmSql)->TOTAL), 5) + " " + SQLPERIODO->B1_UM

        nQtdeDisponivel := SQLPERIODO->ZZZ_QTDE - ((cNmSql)->TOTAL + nQtdeDesej)
        
        if nQtdeDisponivel == 0 
            cTxtDisponivel += CRLF + "<b>Limite por '" + TRIM(SQLPERIODO->PERIODO) + "': 0 "+ SQLPERIODO->B1_UM + "</b>"
        elseif nQtdeDisponivel < 0
            cTxtDisponivel += CRLF + "<b>Limite por '" + TRIM(SQLPERIODO->PERIODO) + "' excedido em: " + cvaltochar(nQtdeDisponivel) + " " + SQLPERIODO->B1_UM + "</b>"
            lRetorno := .F.
        else
            cTxtDisponivel += CRLF + "<b>Limite disponível por '" + TRIM(SQLPERIODO->PERIODO) + "': " + cvaltochar(nQtdeDisponivel) + " " + SQLPERIODO->B1_UM + "</b>"
        endif
        
        dbSelectArea(cNmSql)
        dbCloseArea()

        SQLPERIODO->(DbSkip())

    endDo

    if lRetorno == .F.

        cTxtRegra := "O produto : " + cProduto + " - " + cProdutoNm + CRLF
        cTxtRegra += "Não pode ser vendido para: " + cClientCod + " - " + cClientNm + CRLF
        cTxtRegra += "Devido à regra abaixo: " + CRLF + CRLF + CRLF 
        cTxtRegra += "<b>REGRA APLICADA</b>" + CRLF
        cTxtRet := cTxtRegra + cTxtRet + CRLF + CRLF + CRLF
        cTxtRet += "<b>SITUAÇÃO ATUAL</b>" + CRLF
        cTxtRet += cTxtDisponivel

        FWAlertWarning(cTxtRet, "Impossível continuar!")
    endif

    dbSelectArea("SQLPERIODO")
    dbCloseArea()
    
return lRetorno
