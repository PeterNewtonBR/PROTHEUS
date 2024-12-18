#include 'protheus.ch'

/*/{Protheus.doc} FN000001
Cadastrar pedido de compra automaticamente para insumos da Ordem de Servi�o
Indica�ao de uso no ponto de entrada MNTA420P:
    https://tdn.totvs.com/pages/releaseview.action?pageId=520654181

@type function
@version  1.0.0
@author PSILVA
@since 01/12/2024
@return Boolean
/*/
User Function FN000001

    Local aArea    := FWGetArea()
    //Local aAreaSC7	:= SC7->(GetArea())
    Local cOrdem := "000001"
    Local nAtual := 0
    Local aComprar := {} // array para os itens da compra autom�tica
    Local aAlterar := {} // array para os itens da compra autom�tica que precisa ser alterados
    Local nQtdeBuy := 0
    Local cDoc := ""
    Local aCabec := {}
    Local aItens := {}
    Local aLinha := {}
    Local nX := 0
    Local aPergs   := {}
    Local nPreco := 0
    Local cFornec := ''
    Local cLoja := ''

    Local cAutoEmp := "99"
    Local cAutoFil := "01"
    Local cAutoUsu := "admin"
    Local cAutoSen := "a"
    Local cAutoAmb := "MNT"

    If Select("SX2") <= 0
        RPCSetEnv(cAutoEmp, cAutoFil, cAutoUsu, cAutoSen, cAutoAmb)
    EndIf

    If Empty(AllTrim(RetCodUsr()))
        FwAlertError("Usu�rio n�o autenticado", "Imposs�vel continuar!")
    EndIf

    BeginSql Alias "QRY_INSUMO"

        // STJ OS Corretiva
        // ST4 Servi�o
        // STL Insumo na OS
        // STG Insumo no Servi�o

        // DUAS QUERYES, UMA PARA OS INSUMO QUE FORAM VINCULADOS NA OS E OUTRA PARA OS INSUMOS CADASTRADOS NO TIPO DE SERVI�O

        SELECT
            PRODUTO,
            SUM(QTDE_EST) QTDE_EST,
            SUM(QTDE_SERV) QTDE_SERV,
            SUM(QTDE_SERV) - SC7.C7_QUANT AS QTDE_DIF, 
            CASE WHEN SC7.C7_NUM IS NULL THEN 1 ELSE 0 END AS CADCOMPRA // cadastra a compra?
            , SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRECO
            , SC7.C7_FORNECE, SC7.C7_LOJA, SC7.C7_FILENT
            , SC7.C7_EMISSAO, SC7.C7_COND, SC7.C7_CONTATO, SC7.R_E_C_N_O_
        FROM
            (
                /* QUERY PARA INSUMOS VINCULADOS � OS*/
                SELECT
                    STL.TL_CODIGO PRODUTO,
                    ISNULL(SB2.B2_QATU, 0) QTDE_EST,
                    STL.TL_QUANTID QTDE_SERV
                    /* OS CORRETIVA*/
                FROM
                    %Table:STJ% STJ
                    /* MANUTEN��O*/
                    INNER JOIN %Table:STF% STF ON STF.TF_SERVICO = STJ.TJ_SERVICO
                    AND STF.TF_FILIAL = STJ.TJ_FILIAL
                    /* INSUMOS NA OS*/
                    INNER JOIN %Table:STL% STL ON STL.TL_ORDEM = STJ.TJ_ORDEM
                    AND STL.TL_FILIAL = STJ.TJ_FILIAL
                    /* PRODUTOS*/
                    INNER JOIN %Table:SB1% SB1 ON SB1.B1_COD = STL.TL_CODIGO
                    LEFT JOIN %Table:SB2% SB2 ON SB2.B2_COD = STL.TL_CODIGO
                    AND SB2.%NotDel%
                WHERE STJ.TJ_ORDEM = %exp:cOrdem%
                    AND STJ.%NotDel%
                    AND STF.%NotDel%
                    AND STL.%NotDel%
                    AND SB1.%NotDel%
                UNION ALL
                /* QUERY PARA INSUMOS VINCULADOS AO SERVICO*/
                SELECT
                    STG.TG_CODIGO PRODUTO,
                    ISNULL(SB2.B2_QATU, 0) QTDE_EST,
                    STG.TG_QUANTID QTDE_SERV
                    /* OS CORRETIVA*/
                FROM
                    %Table:STJ% STJ
                    /* MANUTEN��O*/
                    INNER JOIN %Table:STF% STF ON STF.TF_SERVICO = STJ.TJ_SERVICO
                    AND STF.TF_FILIAL = STJ.TJ_FILIAL
                    /* INSUMOS DO SERVI�O*/
                    INNER JOIN %Table:STG% STG ON STG.TG_SERVICO = STF.TF_SERVICO
                    AND STG.TG_FILIAL = STJ.TJ_FILIAL
                    AND STG.TG_CODBEM = STF.TF_CODBEM
                    /* PRODUTOS*/
                    INNER JOIN %Table:SB1% SB1 ON SB1.B1_COD = STG.TG_CODIGO
                    LEFT JOIN %Table:SB2% SB2 ON SB2.B2_COD = STG.TG_CODIGO
                    AND SB2.%NotDel%
                WHERE STJ.TJ_ORDEM = %exp:cOrdem%
                    AND STJ.%NotDel%
                    AND STF.%NotDel%
                    AND STG.%NotDel%
                    AND SB1.%NotDel%
            ) AS INSUMOS
            LEFT JOIN %Table:SC7% SC7 ON SC7.C7_CONTATO = %exp:'ATOSCR'+trim(cOrdem)%
                AND SC7.C7_PRODUTO = INSUMOS.PRODUTO
                AND SC7.%NotDel%
            GROUP BY PRODUTO, SC7.C7_QUANT, SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRECO, 
            SC7.C7_FORNECE, SC7.C7_LOJA, SC7.C7_FILENT, 
            SC7.C7_EMISSAO, SC7.C7_COND, SC7.C7_CONTATO, SC7.R_E_C_N_O_
    EndSql

    aDados := GetLastQuery()
    conout(aDados[2])

    DbSelectArea("QRY_INSUMO")
    ConOut("|=|=|=|=|=|=|=|=|=|=|=|=|=|= START U_FN000001 =|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|")
    QRY_INSUMO->(DbGoTop())

    While ! QRY_INSUMO->(Eof())
        nAtual++        

        // se a quantidade de insumos necess�rios for maior que a quantidade em estoque, dever� comprar
        If QRY_INSUMO->CADCOMPRA == 1 && QRY_INSUMO->QTDE_SERV > 0 .AND. QRY_INSUMO->QTDE_SERV > QRY_INSUMO->QTDE_EST
            
            nQtdeBuy = QRY_INSUMO->QTDE_SERV - iIf(QRY_INSUMO->QTDE_EST < 0, 0, QRY_INSUMO->QTDE_EST)

            aadd(aComprar, {QRY_INSUMO->PRODUTO, nQtdeBuy})
            ConOut(QRY_INSUMO->PRODUTO)

        ElseIf QRY_INSUMO->QTDE_DIF <> 0 // alterar quantidade que j� foi feito o pedido

            aadd(aAlterar, {;
                QRY_INSUMO->PRODUTO,;
                QRY_INSUMO->QTDE_SERV,; 
                QRY_INSUMO->C7_NUM,; 
                QRY_INSUMO->C7_ITEM,; 
                QRY_INSUMO->C7_PRECO,; 
                QRY_INSUMO->C7_FORNECE,; 
                QRY_INSUMO->C7_LOJA,; 
                QRY_INSUMO->C7_FILENT,;
                QRY_INSUMO->C7_EMISSAO,;
                QRY_INSUMO->C7_COND,;
                QRY_INSUMO->C7_CONTATO,;
                QRY_INSUMO->R_E_C_N_O_;
            })

        EndIf

        QRY_INSUMO->(DbSkip())
    EndDo
    
    QRY_INSUMO->(DbCloseArea())
    
    // se houver algo pra ser comprado, ser� feito o pedido de compra
    If len(aAlterar) > 0
    
        nOpc := 4
        cDoc := aAlterar[1][3] // c�digo do pedido QRY_INSUMO->C7_NUM

        aadd(aCabec,{"C7_NUM" ,cDoc})
        aadd(aCabec,{"C7_FORNECE" ,aAlterar[1][6]})
        aadd(aCabec,{"C7_LOJA" ,aAlterar[1][7]})
        aadd(aCabec,{"C7_COND" ,aAlterar[1][10]})
        aadd(aCabec,{"C7_CONTATO" ,aAlterar[1][11]})
        aadd(aCabec,{"C7_FILENT" ,aAlterar[1][8]})

        For nX := 1 To len(aAlterar)
            aLinha := {}

            // Alterar item existente
            aadd(aLinha,{"C7_ITEM" ,aAlterar[nX][4],Nil})
            aadd(aLinha,{"C7_REC_WT" ,aAlterar[nX][12],Nil})
            aadd(aLinha,{"C7_PRODUTO" ,aAlterar[nX][1],Nil})
            aadd(aLinha,{"C7_QUANT" ,aAlterar[nX][2],Nil})
            aadd(aLinha,{"C7_PRECO" ,aAlterar[nX][5],Nil})
            aadd(aLinha,{"C7_TOTAL" ,aAlterar[nX][2] * aAlterar[nX][5],Nil})
            aAdd(aLinha,{"LINPOS","C7_ITEM" ,aAlterar[nX][4]})
            aAdd(aLinha,{"AUTDELETA","N" ,Nil})
            aadd(aItens,aLinha)

        Next nX

        lMsErroAuto := .F.
        MSExecAuto({|a,b,c,d| MATA120(a,b,c,d)},1,aCabec,aItens,nOpc)
        
        If !lMsErroAuto
            ConOut("Alterado PC: "+cDoc)
        Else
            ConOut("Erro na altera��o!")
            MostraErro()
        EndIf
        
    ElseIf len(aComprar) > 0

        MsgInfo("Alguns itens est�o sem estoque e ser� feito um pedido de compra " + ;
            "automaticamente para a quantidade necess�ria.")

        //Adicionando os parametros do ParamBox     
        aadd(aPergs, {1, "Fornecedor", Space(TamSX3( 'A2_COD' )[1]) , "", ".T.", "SA2", ".T.", 80, .T.}) // MV_PAR01
        aadd(aPergs, {1, "Loja"      , Space(TamSX3( 'A2_LOJA' )[1]), "", ".T.", "", ".F.", 80, .T.}) // MV_PAR02
        aadd(aPergs, {1, "Condi��o de Pagamento", Space(TamSX3( 'AIA_CONDPG' )[1]) , "", "AIA->AIA_CODFOR = MV_PAR01", "SE4", ".T.", 80, .T.}) // MV_PAR03

        // Escolha do fornecedor
        If ParamBox(aPergs, "Informe os par�metros", , , , , , , , , .F., .F.)
                        
            cFornec := MV_PAR01
            cLoja := MV_PAR02
            cCondPag := MV_PAR03

            aPergs := {}
                        
            DbSelectArea("SC7")
            
            // novo c�digo para o pedido
            cDoc := GetSXENum("SC7","C7_NUM")

            SC7->(dbSetOrder(1))
            
            While SC7->(dbSeek(xFilial("SC7")+cDoc))
                ConfirmSX8()
                cDoc := GetSXENum("SC7","C7_NUM")
            EndDo

            aCabec := {}
            aItens := {}

            aadd(aCabec,{"C7_NUM" ,cDoc})
            aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
            aadd(aCabec,{"C7_FORNECE" ,cFornec})
            aadd(aCabec,{"C7_LOJA" ,cLoja})
            aadd(aCabec,{"C7_COND" ,cCondPag})
            
            /* 
                Prefixo para verifica��o n�o deixar incluir novamente o pedido, 
                pois esta fun��o poder� ser chamada outras vezes em altera��o.
                Defini��o do prefixo ATOSCR: 
                    AT = Autom�tico;
                    OS = Ordem de servi�o;
                    CR = Corretiva.
                    cOrdem = C�digo da OS CR na tabela STJ990
            */
            aadd(aCabec,{"C7_CONTATO" ,"ATOSCR"+trim(cOrdem)})

            aadd(aCabec,{"C7_FILENT" ,cFilAnt})

            For nX := 1 To len(aComprar)
                aLinha := {}
                nPreco := 0

                BeginSql Alias "QRY_PRECO"

                    // AIB -- FORNECEDOR - TABELA DE PRE�O PRE�O - PRODUTO
                    SELECT TOP (1) ISNULL(AIB_PRCCOM, 0) PRECO
                    FROM AIB990 AIB
                    WHERE AIB_CODFOR = %exp:cFornec%
                    AND AIB_CODPRO = %exp:aComprar[nX][1]%
                    AND AIB_LOJFOR = %exp:MV_PAR02%
                    AND AIB_DATVIG < %exp:dtos(dDataBase)%
                    AND D_E_L_E_T_ = ' '
                    ORDER BY AIB_DATVIG DESC
                    
                EndSql

                aDados := GetLastQuery()
                conout(aDados[2])

                If QRY_PRECO->PRECO <= 0

                    FwAlertError("N�o existe valor cadastrado para gera��o do pedido de compra!", "Aten��o")
                    return .F.

                EndIf

                nPreco := QRY_PRECO->PRECO

                aadd(aLinha,{"C7_PRODUTO" ,aComprar[nX][1],Nil})
                aadd(aLinha,{"C7_QUANT" ,aComprar[nX][2],Nil})
                aadd(aLinha,{"C7_PRECO" ,nPreco ,Nil})
                aadd(aLinha,{"C7_TOTAL" ,nPreco * aComprar[nX][2],Nil})
                aadd(aItens,aLinha)

                QRY_PRECO->(DbCloseArea())

            Next nX

            MsgInfo("Ser� inserido!")

            nOpc        := 3
            lMsErroAuto := .F.
            MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCabec,aItens,nOpc)
            
            If !lMsErroAuto
                ConOut("Incluido PC: "+cDoc)
            Else
                ConOut("Erro na inclusao!")
                MostraErro()
            EndIf
        EndIf
    EndIf

    ConOut("|=|=|=|=|=|=|=|=|=|=|=|=|=|= END U_FN000001 =|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|")

return .F.


Static Function AlteraPC(nRecno,nOpc)
    Local aArea		:= GetArea()
    Local aAreaSC7	:= SC7->(GetArea())
    dbSelectArea("SC7")
    MsGoto(nRecno)
 
    //Mata120(ExpN1,ExpA1,ExpA2,ExpN2,ExpA1)
    /*
    ExpN1 = 1-Pedido de compras ou 2-Autorizacao de entrega
    ExpA1 = Array Cabecalho para Rotina Automatica 
    ExpA2 = Array Itens para Rotina Automatica 
    ExpN2 = Opcao do aRotina para Rotina Automatica 
    ExpA1 = Apresenta a Dialog da Rotina em Rotina Automatica (.T. ou .F.)
    */
    Mata120(1,/*aCabec*/,/*aItens*/,nOpc,.T.) 
    RestArea(aAreaSC7) 
    RestArea(aArea) 
Return .T.
