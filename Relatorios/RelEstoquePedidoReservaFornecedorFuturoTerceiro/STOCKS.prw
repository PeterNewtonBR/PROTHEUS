//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe505
Classes para montagem de um relatório com listagem de informações
@type Function
@author Atilio
@since 04/04/2023
@see https://tdn.totvs.com/display/public/framework/TReport e https://tdn.totvs.com/display/public/framework/TRSection e https://tdn.totvs.com/display/public/framework/TRFunction e https://tdn.totvs.com/display/public/framework/TRCell
@obs 
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function STOCKS()
    Local aArea := FWGetArea()
    Local oReport
    Local aPergs   := {}
    Local cProdDe
    Local cProdAte
    Local cTipoDe
    Local cTipoAte
    Local cGrupo
    Local nOrden   := 1
    //
    Local aCombo   := {"Sim","Não"}
    Local aCmbMzer := {"> 0", "= 0", "< 0"}
    Local aOrdem := {"Código", "Nome", "Estoque Pedido", "Em Estoque", "Em Reserva", "Em Fornecedor", "Futuro", "Em Terceiros"}
    Local cAutoEmp := "99"
    Local cAutoFil := "01"
    Local cAutoUsu := "admin"
    Local cAutoSen := "a"
    Local cAutoAmb := "FAT"
    Private cTabela := "ZZA"

    If Select("SX2") <= 0
        RPCSetEnv(cAutoEmp, cAutoFil, cAutoUsu, cAutoSen, cAutoAmb)
    EndIf

    If Empty(AllTrim(RetCodUsr()))
        FwAlertError("Usuário não autenticado", "Impossível continuar!")
    EndIf
    //

    cProdDe  := Space(TamSX3('B1_COD')[1])
    cProdAte := StrTran(cProdDe, ' ', 'Z')
    cTipoDe  := Space(TamSX3('B1_TIPO')[1])
    cTipoAte := StrTran(cTipoDe, ' ', 'Z')

    cGrupo  := Space(TamSX3('B1_GRUPO')[1])
     
    //Adicionando os parametros do ParamBox     
    aAdd(aPergs, {1, "Filial",     "01",  "", ".T.", "FWSM0",  ".T.", 80,  .T.}) // MV_PAR01
    aAdd(aPergs, {1, "Grupo",     cGrupo,  "", ".T.", "SBM",  ".T.", 80,  .F.}) // MV_PAR01
    aAdd(aPergs, {2, "Ativos",     1,  aCombo, 80, "",  .T.}) // MV_PAR02
    aAdd(aPergs, {2, "Controle Estoque",     1,  aCombo, 80, "",  .T.}) // MV_PAR03
    aAdd(aPergs, {2, "Estoque",     1,  aCmbMzer, 80, "",  .T.}) // MV_PAR04
    aAdd(aPergs, {2, "Ordernar por",     1,  aOrdem, 80, "",  .T.}) // MV_PAR04

    //Se a pergunta for confirma, cria as definicoes do relatorio
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
        //MV_PAR05 := Val(cValToChar(MV_PAR05))
 
        oReport := fReportDef()
        oReport:PrintDialog()
    EndIf
     
    FWRestArea(aArea)


Return
 
Static Function fReportDef()
    Local oReport
    Local oSection := Nil
     
    //Criacao do componente de impressao
    oReport := TReport():New( "STOCKS",;
        "Relação de Estoque dos Produtos",;
        ,;
        {|oReport| fRepPrint(oReport),};
        )
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .F.
    oReport:oPage:SetPaperSize(9)
     
    //Orientacao do Relatorio
    oReport:SetLandscape()
     
    // 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetDevice(6)

    //Define que será impressa a página de parâmetros do relatório
    oReport:ShowParamPage()

    //Definicoes da fonte utilizada
    oReport:SetLineHeight(50)
    oReport:nFontBody := 12
     
    //Criando a secao de dados
    oSection := TRSection():New( oReport,;
        "Dados",;
        {"QRY_REP"})
    oSection:SetTotalInLine(.F.)
     
    //Colunas do relatorio
    // TRCell():New(oSection, "B1_COD",    "QRY_REP", "Codigo",     /*cPicture*/, 15, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .T.)
    // TRCell():New(oSection, "B1_DESC",   "QRY_REP", "Descricao",  /*cPicture*/, 30, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    // TRCell():New(oSection, "B1_TIPO",   "QRY_REP", "Tipo",       /*cPicture*/, 02, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    // TRCell():New(oSection, "TIPODESCR", "QRY_REP", "Tp. Descr.", /*cPicture*/, 55, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    // TRCell():New(oSection, "B1_UM",     "QRY_REP", "Unid. Med.", /*cPicture*/, 02, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    // TRCell():New(oSection, "UMDESCR",   "QRY_REP", "UM. Descr.", /*cPicture*/, 40, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    
    TRCell():New(oSection, "B1_FILIAL" , "QRY_REP", "Emp"           , /*cPicture*/, 5  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "B1_COD" , "QRY_REP", "Produto"       , /*cPicture*/, 15 , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "B1_DESC", "QRY_REP", "Descrição"     , /*cPicture*/, 100, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "B1_UM"  , "QRY_REP", "Unid."         , /*cPicture*/, 04 , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "EST_PED", "QRY_REP", "Est. Pedido"   , /*cPicture*/, 15 , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "ESTOQUE", "QRY_REP", "Estoque"       , /*cPicture*/, 15 , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "RESERVA", "QRY_REP", "Reserva"       , /*cPicture*/, 15 , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "FORNECEDOR", "QRY_REP", "Fornecedor"    , /*cPicture*/, 15 , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "FUTURO", "QRY_REP", "Futuro"        , /*cPicture*/, 15 , /*lPixel*/, {|| EST_PED + ESTOQUE - RESERVA + FORNECEDOR}, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New(oSection, "TERCEIROS", "QRY_REP", "Dep. Terceiros", /*cPicture*/, 15 , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
     
    //Quebras do relatorio
    // oBreak := TRBreak():New(oSection, oSection:Cell("B1_TIPO"), {||"Total da Quebra"}, .F.)
 
    //Totalizadores

    TRFunction():New(oSection:Cell("B1_COD"), , "COUNT", , , "@E 999,999,999", , .F.)
     
Return oReport
 
Static Function fRepPrint(oReport)
    Local aArea    := FWGetArea()
    Local cQryReport  := ""
    Local oSectDad := Nil
    Local nAtual   := 0
    Local nTotal   := 0
    Local aDados    := Nil

    CheckFile("SC9", "SC9990")
    CheckFile("SB6", "SB6990")

    //Pegando as secoes do relatorio
    oSectDad := oReport:Section(1)
     
    //Montando consulta de dados
    cQryReport += "SELECT B1_FILIAL, "        + CRLF
    cQryReport += "    B1_COD, "        + CRLF
    cQryReport += "    B1_DESC, "        + CRLF
    cQryReport += "    B1_TIPO, "        + CRLF
    cQryReport += "    '' AS TIPODESCR, "        + CRLF
    cQryReport += "    B1_UM, "        + CRLF
    cQryReport += "    '' AS UMDESCR "        + CRLF
    cQryReport += "FROM "        + CRLF
    cQryReport += "    " + RetSQLName("SB1") + " SB1 "        + CRLF
    // cQryReport += "    LEFT JOIN " + RetSQLName("SX5") + " SX5 ON ( "        + CRLF
    // cQryReport += "       X5_FILIAL = '" + FWxFilial("SX5") + "' "        + CRLF
    // cQryReport += "       AND X5_TABELA = '02' "        + CRLF
    // cQryReport += "       AND X5_CHAVE = B1_TIPO "        + CRLF
    // cQryReport += "       AND SX5.D_E_L_E_T_ = ' ' "        + CRLF
    // cQryReport += "    ) "        + CRLF
    // cQryReport += "    LEFT JOIN " + RetSQLName("SAH") + " SAH ON ( "        + CRLF
    // cQryReport += "       AH_FILIAL = '" + FWxFilial("SAH") + "' "        + CRLF
    // cQryReport += "       AND AH_UNIMED = B1_UM "        + CRLF
    // cQryReport += "       AND SAH.D_E_L_E_T_ = ' ' "        + CRLF
    // cQryReport += "    ) "        + CRLF
    cQryReport += "WHERE "        + CRLF
    cQryReport += "    B1_FILIAL = '" + FWxFilial("SB1") + "' "        + CRLF
    // cQryReport += "    AND B1_COD >= '" + MV_PAR01 + "' "        + CRLF
    // cQryReport += "    AND B1_COD <= '" + MV_PAR02 + "' "        + CRLF
    // cQryReport += "    AND B1_TIPO >= '" + MV_PAR03 + "' "        + CRLF
    // cQryReport += "    AND B1_TIPO <= '" + MV_PAR04 + "' "        + CRLF
    // cQryReport += "    AND B1_MSBLQL != '1' "        + CRLF
    cQryReport += "    AND SB1.D_E_L_E_T_ = ' ' "        + CRLF
    cQryReport += "ORDER BY "        + CRLF
    cQryReport += "    B1_TIPO "        
    // If MV_PAR05 == 1
    //     cQryReport += "    B1_COD "        + CRLF
    // ElseIf MV_PAR05 == 2
    //     cQryReport += "    B1_DESC "        + CRLF
    // ElseIf MV_PAR05 == 3
    //     cQryReport += "    B1_UM "        + CRLF
    // EndIf
     
    //Executando consulta e setando o total da regua
    //PlsQuery(cQryReport, "QRY_REP")

    BeginSql Alias "QRY_REP"

        // SELECT B1_FILIAL,B1_COD, 
        //     B1_DESC, 
        //     B1_TIPO, 
        //     '' AS TIPODESCR, 
        //     B1_UM, 
        //     '' AS UMDESCR 
        // FROM %Table:SB1% SB1 
        // WHERE B1_FILIAL = '  ' 
        // AND SB1.D_E_L_E_T_ = ' ' 

        SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM

            // definir na query a situação do pedido
            , (SELECT ISNULL(SUM(SC7.C7_QUANT), 0) FROM %Table:SC7% SC7 WHERE SC7.C7_PRODUTO = SB1.B1_COD AND SC7.C7_FILIAL = %exp:MV_PAR01% AND SC7.%notDel%) AS EST_PED
            , (SELECT ISNULL(SUM(SB2.B2_QATU), 0) FROM %Table:SB2% SB2 WHERE SB2.B2_COD = SB1.B1_COD AND SB2.B2_FILIAL = %exp:MV_PAR01% AND SB2.%notDel%) AS ESTOQUE
            , (SELECT ISNULL(SUM(SC0.C0_QUANT), 0) FROM %Table:SC0% SC0 WHERE SC0.C0_PRODUTO = SB1.B1_COD AND SC0.C0_FILIAL = %exp:MV_PAR01% AND SC0.%notDel%) AS RESERVA
            , (SELECT ISNULL(SUM(SC9.C9_QTDLIB), 0) FROM %Table:SC9% SC9 WHERE SC9.C9_PRODUTO = SB1.B1_COD AND SC9.C9_FILIAL = %exp:MV_PAR01% AND SC9.%notDel%) AS FORNECEDOR
            , 0 FUTURO
            , (SELECT ISNULL(SUM(SB6.B6_QUANT), 0) FROM %Table:SB6% SB6 WHERE SB6.B6_PRODUTO = SB1.B1_COD AND SB6.B6_FILIAL = %exp:MV_PAR01% AND SB6.%notDel%) AS TERCEIROS

        FROM %Table:SB1% SB1
        WHERE SB1.%notDel%

    EndSql

    aDados := GetLastQuery()
    conout(aDados[2])

    DbSelectArea("QRY_REP")
    Count to nTotal
    oReport:SetMeter(nTotal)
     
    //Enquanto houver dados
    oSectDad:Init()
    QRY_REP->(DbGoTop())

    While ! QRY_REP->(Eof())
     
        //Incrementando a regua
        nAtual++
        oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        oReport:IncMeter()
         
        //Imprimindo a linha atual
        oSectDad:PrintLine()
         
        QRY_REP->(DbSkip())
    EndDo
    oSectDad:Finish()
    QRY_REP->(DbCloseArea())
     
    FWRestArea(aArea)
Return
