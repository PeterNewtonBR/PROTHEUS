#include 'protheus.ch'

/*/{Protheus.doc} FN000001
Cadastrar pedido de compra automaticamente para insumos da Ordem de Serviço
Indicaçao de uso no ponto de entrada MNTA420P:
    https://tdn.totvs.com/pages/releaseview.action?pageId=520654181

@type function
@version  1.0.0
@author PSILVA
@since 01/12/2024
@return Boolean
/*/
User Function FN000001

    Local aArea    := FWGetArea()
    Local cOrdem := "000001"
    Local nAtual := 0
    Local aComprar := {} // array para os itens da compra automática
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
        FwAlertError("Usuário não autenticado", "Impossível continuar!")
    EndIf

    BeginSql Alias "QRY_INSUMO"

        // STJ OS Corretiva
        // ST4 Serviço
        // STL Insumo na OS
        // STG Insumo no Serviço

        // DUAS QUERYES, UMA PARA OS INSUMO QUE FORAM VINCULADOS NA OS E OUTRA PARA OS INSUMOS CADASTRADOS NO TIPO DE SERVIÇO

        SELECT
            PRODUTO,
            SUM(QTDE_EST) QTDE_EST,
            SUM(QTDE_SERV) QTDE_SERV
        FROM
            (
                /* QUERY PARA INSUMOS VINCULADOS À OS*/
                SELECT
                    STL.TL_CODIGO PRODUTO,
                    ISNULL(SB2.B2_QATU, 0) QTDE_EST,
                    STL.TL_QUANTID QTDE_SERV
                    /* OS CORRETIVA*/
                FROM
                    %Table:STJ% STJ
                    /* MANUTENÇÃO*/
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
                UNION
                /* QUERY PARA INSUMOS VINCULADOS AO SERVICO*/
                SELECT
                    STG.TG_CODIGO PRODUTO,
                    ISNULL(SB2.B2_QATU, 0) QTDE_EST,
                    STG.TG_QUANTID QTDE_SERV
                    /* OS CORRETIVA*/
                FROM
                    %Table:STJ% STJ
                    /* MANUTENÇÃO*/
                    INNER JOIN %Table:STF% STF ON STF.TF_SERVICO = STJ.TJ_SERVICO
                    AND STF.TF_FILIAL = STJ.TJ_FILIAL
                    /* INSUMOS DO SERVIÇO*/
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
        WHERE
            NOT EXISTS (
                SELECT
                    R_E_C_N_O_
                FROM
                    %Table:SC7% SC7
                WHERE
                    SC7.C7_CONTATO = %exp:'ATOSCR'+trim(cOrdem)%
                    AND SC7.C7_PRODUTO = INSUMOS.PRODUTO
                    AND SC7.%NotDel%
            )
        GROUP BY
            PRODUTO
    EndSql

    aDados := GetLastQuery()
    conout(aDados[2])

    DbSelectArea("QRY_INSUMO")
    ConOut("|=|=|=|=|=|=|=|=|=|=|=|=|=|= START U_FN000001 =|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|=|")
    QRY_INSUMO->(DbGoTop())

    While ! QRY_INSUMO->(Eof())
        nAtual++        

        // se a quantidade de insumos necessários for maior que a quantidade em estoque, deverá comprar
        If QRY_INSUMO->QTDE_SERV > 0 .AND. QRY_INSUMO->QTDE_SERV > QRY_INSUMO->QTDE_EST
            
            nQtdeBuy = QRY_INSUMO->QTDE_SERV - iIf(QRY_INSUMO->QTDE_EST < 0, 0, QRY_INSUMO->QTDE_EST)

            aadd(aComprar, {QRY_INSUMO->PRODUTO, nQtdeBuy})
            ConOut(QRY_INSUMO->PRODUTO)

        EndIf

        QRY_INSUMO->(DbSkip())
    EndDo
    
    QRY_INSUMO->(DbCloseArea())
    
    // se houver algo pra ser comprado, será feito o pedido de compra
    If len(aComprar) > 0

        MsgInfo("Alguns itens estão sem estoque e será feito um pedido de compra " + ;
            "automaticamente para a quantidade necessária.")

        //Adicionando os parametros do ParamBox     
        aadd(aPergs, {1, "Fornecedor", Space(TamSX3( 'A2_COD' )[1]) , "", ".T.", "SA2", ".T.", 80, .T.}) // MV_PAR01
        aadd(aPergs, {1, "Loja"      , Space(TamSX3( 'A2_LOJA' )[1]), "", ".T.", "", ".F.", 80, .T.}) // MV_PAR02
        aadd(aPergs, {1, "Condição de Pagamento", Space(TamSX3( 'AIA_CONDPG' )[1]) , "", "AIA->AIA_CODFOR = MV_PAR01", "SE4", ".T.", 80, .T.}) // MV_PAR03

        // Escolha do fornecedor
        If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
                        
            cFornec := MV_PAR01
            cLoja := MV_PAR02
            cCondPag := MV_PAR03

            aPergs := {}
                        
            DbSelectArea("SC7")
            
            // novo código para o pedido
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
                Prefixo para verificação não deixar incluir novamente o pedido, 
                pois esta função poderá ser chamada outras vezes em alteração.
                Definição do prefixo ATOSCR: 
                    AT = Automático;
                    OS = Ordem de serviço;
                    CR = Corretiva.
                    cOrdem = Código da OS CR na tabela STJ990
            */
            aadd(aCabec,{"C7_CONTATO" ,"ATOSCR"+trim(cOrdem)})

            aadd(aCabec,{"C7_FILENT" ,cFilAnt})

            For nX := 1 To len(aComprar)
                aLinha := {}
                nPreco := 0

                BeginSql Alias "QRY_PRECO"

                    // AIB -- FORNECEDOR - TABELA DE PREÇO PREÇO - PRODUTO
                    SELECT TOP (1) ISNULL(AIB_PRCCOM, 0) PRECO
                    FROM AIB990 AIB
                    WHERE AIB_CODFOR = %exp:cFornec%
                    AND AIB_CODPRO = %exp:aComprar[nX][1]%
                    AND AIB_LOJFOR = %exp:MV_PAR02%
                    AND AIB_DATVIG < %exp:dtos(dDataBase)%
                    AND D_E_L_E_T_ = ' '
                    ORDER BY AIB_DATVIG DESC
                    
                EndSql

                // aDados := GetLastQuery()
                // conout(aDados[2])

                If QRY_PRECO->PRECO <= 0

                    FwAlertError("Não existe valor cadastrado para geração do pedido de compra!", "Atenção")
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

            MsgInfo("Será inserido!")

            return .F.

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
