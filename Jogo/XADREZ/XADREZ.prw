#include "totvs.ch"

/*/{Protheus.doc} Xadrez
Jogo de Xadrez criado em ADVPL
@type function
@version  1.0
@author Peter Newton
@since 30/06/2023
/*/
User Function Xadrez()

    Local x
    Local x2
    Local nNomeCasa
    Local nAddVert
    Local nAddHori
    Local cMacro
    Private aPosPecas := {}
    Private oDlg

    // DEFINI��ES
    Private cSrcFiles   := "\_Custom\Xadrez ADVPL\imagem\"
    Private cImgLoop    := cSrcFiles + "vazio.png"
    Private cImgVazio    := cSrcFiles + "vazio.png"
    Private cImgCanto   := cSrcFiles + "canto.png"
    Private cImgXadrez  := cSrcFiles + "tabuleiro.png"
    Private cImgBdRed  := cSrcFiles + "brdred.png"
    Private cImgBdBlue  := cSrcFiles + "brdblue.png"
    Private cImgBdGreen  := cSrcFiles + "brdgreen.png"
    Private cImgPPeao   := cSrcFiles + "ppeao.png"
    Private cImgPTorre  := cSrcFiles + "ptorre.png"
    Private cImgPCavalo := cSrcFiles + "pcavalo.png"
    Private cImgPDama   := cSrcFiles + "pdama.png"
    Private cImgPBispo  := cSrcFiles + "pbispo.png"
    Private cImgPRei    := cSrcFiles + "prei.png"
    Private cImgBPeao   := cSrcFiles + "bpeao.png"
    Private cImgBTorre  := cSrcFiles + "btorre.png"
    Private cImgBCavalo := cSrcFiles + "bcavalo.png"
    Private cImgBDama   := cSrcFiles + "bdama.png"
    Private cImgBBispo  := cSrcFiles + "bbispo.png"
    Private cImgBRei    := cSrcFiles + "brei.png"
    Private nAltUtil    := 300 // altura �til espa�o dentro da janela
    Private nIniHorInfo    := 300 // altura �til espa�o dentro da janela
    Private nAltBottom  := 45 // altura do bottom do FwDialogModal
    Private nLargUtil   := 432 // largura do FwDialogModal
    Private aPosInicial :={14, 16} // posicial inicial do tabuleiro em [horizontal, vertical], iniciando ao lado superior esquerdo
    Private nTamTablr   := 270 // tamanho do tabuleiro
    Private nTamPeca    := 25 // tamanho do tabuleiro
    Private nQtdeCasas  := 8
    Private nStop       := 0
    Private nTempo      := 10
    Private nAddBdVert := -3.5 // quantidade de ajuste para adicionar na borda verticalmente relacionado � imagem da pe�a
    Private nAddBdHori := -4.3 // quantidade de ajuste para adicionar na borda horizontalmente relacionado � imagem da pe�a
    Private nAddBdTama := 8.8 //  quantidade de ajuste para adicionar no tamanho relacionado � imagem da pe�a
    Private nLimite     := nTempo
    Private nPosCasa    :={0 , 0} // posi��o da casa iniciando no canto superior esquerdo
    Private cUltmCasa := '' // �ltima casa selecionada
    Private cPenultCasa := '' // pen�ltima casa selecionada
    Private cUltmPeca := '' // �ltima pe�a selecionada
    Private cPenultPeca := '' // pen�ltima pe�a selecionada
    Private cTeste := ""
    Private aTmp // apenas para n�o chamar fun��o v�rias vezes
    Private nPosCapHor := 302 // posi��o inicial do espa�o de capturas na horizontal
    Private nPosCapVer := 40 // posi��o inicial do espa�o de capturas na vertical
    Private aCapBranca := {} // pe�as brancas capturadas
    Private aCapPreta := {} // pe�as pretas capturadas
    Private aPosIniPec := []
    Private nTamCasa := nTamTablr / nQtdeCasas // tamanho de cada casa
    Private aClearObj := {} // array para limpar os objetos criados
    Private aClrCaps := {} // array para limpar os objetos criados para as imagens das pe�as capturadas
    Private cPecaVez := iif(randomize(1, 3) == 1, 'p', 'b') // escolher quem vai iniciar, pe�a preta ou branca
    Private aPodeCaptu := {} // array com as casas que podem ser capturadas, vai se alterando a cada click
    Private aPodeMover := {} // array com as casas que podem receber a pe�a escolhida, vai se alterando a cada click
    Private bTheEnd := .F.
    Private aCasas := {}

    // Verifica��es
    if !file(cImgXadrez)
        return FWAlertError("Imagem do tabuleiro n�o encontrada no caminho especificado:<br>"+cImgXadrez, "Imposs�vel continuar")
    endif
    
    // inicializa��o de objetos para as imagens
    // foi necess�rio criar aqui a inicializa��o
    // devido � fun��o Clear n�o estar enxergando
    for x := 1 to (nQtdeCasas*4)
        &("oBRed"+cvaltochar(x)+" := NIL")
    next
    for x := 1 to (nQtdeCasas*4)
        &("oBBlue"+cvaltochar(x)+" := NIL")
    next
    for x := 1 to (nQtdeCasas*4)
        &("oBGreen"+cvaltochar(x)+" := NIL")
    next
    for x := 1 to 32 // 32 � a quantidade de pe�as no tabuleiro
        &("oCaps"+cvaltochar(x)+" := NIL")
    next
            
    //oDlg := MSDialog():New(0,0,600,800,'XADREZ ADVPL',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
    oDlg := FwDialogModal():New()
    oDlg:SetTitle('Xadrez ADVPL')
    oDlg:SetPos(000, 000)
    oDlg:SetSize(nAltUtil+nAltBottom, nLargUtil)
    oDlg:SetEscClose(.T.)
    oDlg:CreateDialog()

    oPnl := oDlg:GetPanelMain()
    
    // tabuleiro
    oTBitmap1 := TBitmap():Create(oPnl, 0, 0, nAltUtil, nAltUtil, NIL, cImgXadrez, .T., /*{||Alert("Clique em TBitmap")}*/, NIL, .F., .T., NIL, NIL, .F., NIL, .T., NIL, .F.)
    
    // tipo de fonte
    oFont := TFont():New('Courier new',,-18,.T.)

    oLbJogvez:= TSay():Create(oPnl,{||'Joga '+iif(cPecaVez == 'p', 'Preta', 'Branca')},1, nIniHorInfo,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,nLargUtil-nIniHorInfo,20,,,,,,,2,2)
    // label para a coordenada clicada
    oLbCoorAt:= TSay():Create(oPnl,{||'Coordenada'},10, nIniHorInfo,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,nLargUtil-nIniHorInfo,20,,,,,,,2,2)
    // label nome da pe�a
    oLbNomePeca:= TSay():Create(oPnl,{||'Nome da Pe�a'},20, nIniHorInfo,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,nLargUtil-nIniHorInfo,20,,,,,,,2,2)
    
    oBtnNewGame := TButton():New( nAltUtil-20, nIniHorInfo, "Novo Jogo",oPnl,{||NewGame()}, nLargUtil-nIniHorInfo-1,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    //oLblSay:= TSay():Create(oPnl,{||'...'},30, 300,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20,,,,,,,2,2)

    // casas da horizontal
    for x := 1 to nQtdeCasas
        
        // c�lculo para posi��o horizontal
        nAddHori := aPosInicial[2]+(nTamCasa*(x-1))+(nTamCasa/2)-(nTamPeca/2)
        
        // casas da vertical
        for x2 := 1 to nQtdeCasas

            // c�lculo para posi��o centralizada da pe�a na casa da vez em vertical
            nAddVert := aPosInicial[1]+(nTamCasa*(x2-1))+(nTamCasa/2)-(nTamPeca/2)

            // nome da casa em coordenada, ex.: a3, a4, a5, ...
            cNomeCasa := chr(96+x)+cvaltochar(x2)

            // cria��o das coordenadas de cada casa
            // cada array conter� [horizontal, vertical]
            &("aPosCasa"+cNomeCasa+" := {nAddHori, nAddVert}")
            aadd(aCasas, cNomeCasa)
            // criado uma execu��o da string devido ao valor da vari�vel n�o estar sendo levado, por causa do loop estava sempre o mesmo valor para todos os clicks
            cMacro := ('oCasa'+cNomeCasa+' := TBitmap():Create(oPnl, nAddVert, nAddHori, nTamPeca, nTamPeca, NIL, cImgVazio, .T., {||ClickCasa("'+cNomeCasa+'")}, NIL, .F., .T., NIL, NIL, .F., NIL, .T., NIL, .F.)')
            &(cMacro)

        next
    next

    // inicia a posi��o inicial das pe�as
    SetPosition()
    
    oDlg:AddCloseButton({||Fechar()}, 'Fechar')

    oDlg:Activate()
    
Return

/*/{Protheus.doc} NewGame
iniciar novo jogo
@type function
@author Peter Newton
@since 12/07/2023
/*/
Static Function NewGame()
    
    local x

    if FWAlertNoYes("Deseja realmente iniciar uma nova partida?", 'Novo Jogo')

        for x := 1 to len(aCasas)
            SetCasa(aCasas[x], 'vazio')
        next

        for x := 1 to len(aClrCaps)    
        // ATEN��O ATEN��O ATEN��O caso n�o esteja removendo a imagem, 
        // veja se a vari�vel da mesma foi iniciada no array em um 'for' 
        // ap�s as declara��es de vari�veis
            if type(aClrCaps[x]) == "O"
                &("FwFreeObj("+aClrCaps[x]+")")
            endif
        next

        SetPosition()
        ClearObjs()
        bTheEnd := .F.
        aPodeCaptu := {}
        aPodeMover := {}        
        cUltmPeca := ""
        cUltmCasa := ""
       
    endif

Return

/*/{Protheus.doc} GetPositions
Posi��es iniciais do jogo, ou carregadas de um arquivo
@type function
@author Peter Newton
@since 08/07/2023
/*/
Static Function GetPositions()
    
    // verificar se tem jogada salva em json pra ser carregada e continuar o jogo

    // posi��o inicial de cada pe�a
    // {nome da pe�a para imagem, casa}
    aPosIniPec := {{"ptorre" , "a1"},;
        {"pcavalo", "b1"},;
        {"pbispo" , "c1"},;
        {"prei"   , "d1"},;
        {"pdama"  , "e1"},;
        {"pbispo" , "f1"},;
        {"pcavalo", "g1"},;
        {"ptorre" , "h1"},;
        {"ppeao"  , "a2"},;
        {"ppeao"  , "b2"},;
        {"ppeao"  , "c2"},;
        {"ppeao"  , "d2"},;
        {"ppeao"  , "e2"},;
        {"ppeao"  , "f2"},;
        {"ppeao"  , "g2"},;
        {"ppeao"  , "h2"},;
        {"btorre" , "a8"},;
        {"bcavalo", "b8"},;
        {"bbispo" , "c8"},;
        {"bdama"  , "d8"},;
        {"brei"   , "e8"},;
        {"bbispo" , "f8"},;
        {"bcavalo", "g8"},;
        {"btorre" , "h8"},;
        {"bpeao"  , "a7"},;
        {"bpeao"  , "b7"},;
        {"bpeao"  , "c7"},;
        {"bpeao"  , "d7"},;
        {"bpeao"  , "e7"},;
        {"bpeao"  , "f7"},;
        {"bpeao"  , "g7"},;
        {"bpeao"  , "h7"}}

Return aPosIniPec

/*/{Protheus.doc} SetPosition
@Description 
@Type		 
@Author 	 
@Since  	 08/07/2023
/*/
Static Function SetPosition()
    
    Local x
    aPosIniPec := GetPositions()    

    for x := 1 to len(aPosIniPec)
        aadd(aPosPecas, aPosIniPec[x])
    next

    for x := 1 to len(aPosPecas)

        SetCasa(aPosPecas[x][2], aPosPecas[x][1])   
        
        // comentar 
        // if (aPosPecas[x][2] != 'a8' .AND. aPosPecas[x][2] <> 'a1')
        //     SetCapturas(aPosPecas[x][2])
        //     SetCasa(aPosPecas[x][2], 'vazio')
        // endif
    next

Return

/*/{Protheus.doc} SetCapturas
Colocar a imagem pequena de cada pe�a j� capturada
@type function
@version  
@author Peter Newton
@since 08/07/2023
@param Args, array, param_description
@return variant, return_description
/*/
Static Function SetCapturas(cCasa)
    
    Local x // para o loop pegar item a item do array
    Local x2 := 1 // para saber quando pular linha das pe�as
    Local nEspacoPec := 16 // espa�o entre as pe�as
    Local nTamPecaCap := 15
    Local nPosH := nPosCapHor
    Local nPosV := nPosCapVer
    Local aDados := aCapBranca
    Local cNomePeca := GetPecaCasa(cCasa)
    Local cCor := left(cNomePeca, 1)
    Local cNomeObj := ''

    // altura vertical para as pe�as serem posicionadas
    if cCor == 'p'
        aadd(aCapPreta, cNomePeca)
        aDados := aCapPreta
        nPosV += 35
    else
        aadd(aCapBranca, cNomePeca)
    endif
    
    for x := 1 to len(aDados)

        if x2 > 8
            x2 := 1
            nPosH := nPosCapHor
            nPosV += nEspacoPec
        endif

        cNomeObj := "oCaps"+cvaltochar(len(aClrCaps)+1)
        aadd(aClrCaps, cNomeObj)

        SetImgCoor(cNomeObj, {nPosH, nPosV}, {nTamPecaCap, nTamPecaCap}, &("cImg"+aDados[x]))

        nPosH += nEspacoPec
        x2++

    next

Return

/*/{Protheus.doc} ClickCasa
@Description 
@Type		 
@Author 	 
@Since  	 03/07/2023
/*/
Static Function ClickCasa(cNomeCasa)
    
    Local cNomePeca := GetPecaCasa(cNomeCasa)
    Local cCor := left(cNomePeca, 1)
    Local bMudaJogad := .F. // mudar jogador da vez
    Local bLimpa := .F. // ap�s movimento, limpar sele��es
    Local bClrApdCap := .F. // limpar o array das pe�as que poderiam ser capturadas
    
    if bTheEnd == .T.
        return FWAlertInfo("Jogo finalizado, inicie uma nova partida!", 'Aten��o')
    endif

    // mensagem para que selecione uma pe�a
    if (cPenultCasa == '' .AND. cNomePeca == 'vazio')        
        oLbNomePeca:SetText('Selecione uma pe�a')
        return NIL
    endif
    
    // se o click tiver sido em pe�a diferente da jogada da vez e n�o for uma casa vazia
    if cCor != cPecaVez .AND. cCor != 'v' .AND. aScan(aPodeCaptu, cNomeCasa) == 0
        oLbNomePeca:SetText('QUEM JOGA S�O AS '+iif(cPecaVez == 'p', 'PRETAS', 'BRANCAS'))
        return NIL
    endif
    
    ClearObjs()
    cUltmCasa := cNomeCasa    
    cUltmPeca := cNomePeca
        
    // quando clica na mesma pe�a, desmarca sele��o
    if cNomeCasa == cPenultCasa

        bLimpa := .T.
        bClrApdCap := .T.
        
    // se for vazio, a �ltima pe�a selecionada ocupa a nova casa e esvazia a que estava
    elseif cUltmPeca == "vazio" .AND. aScan(aPodeMover, cNomeCasa) .AND. cPenultCasa != "" .AND. cPenultCasa != NIL
    // comentar linha de baixo e liberar a de cima
    //elseif cUltmPeca == "vazio" .AND. cPenultCasa != "" .AND. cPenultCasa != NIL
    
        // esvaziar casa
        SetCasa(cPenultCasa, cUltmPeca)
        // ocupar nova casa
        SetCasa(cUltmCasa, cPenultPeca)
        // mudar jogador da vez
        bMudaJogad := .T.
        bLimpa := .T.
        bClrApdCap := .T.
    
    // se tem uma pe�a selecionada e clicou em outra, faz a captura se poss�vel
    elseif cUltmPeca != "vazio" .AND. aScan(aPodeCaptu, cNomeCasa) > 0
        
        // captura a casa antes de alterar as pe�as de lugar
        SetCapturas(cNomeCasa)

        // capturar nova casa
        SetCasa(cUltmCasa, cPenultPeca)
        // esvaziar casa
        SetCasa(cPenultCasa, 'vazio')
        bMudaJogad := .T.
        bLimpa := .T.
        bClrApdCap := .T.
        
    // se clicar em uma pe�a, mostrar� as casas poss�veis
    elseif cUltmPeca != "vazio"

        MovPermPeca(cUltmPeca, cUltmCasa)
        SetBorda(cNomeCasa, 'Green')

    endif
    
    // mudar jogador da vez
    if bMudaJogad
        cPecaVez := iif(cPecaVez == 'p', 'b', 'p')
    endif

    // ap�s movimento, limpar sele��es
    if bLimpa
        ClearObjs()
        cUltmPeca := ""
        cUltmCasa := ""
    endif

    if bClrApdCap
        aPodeCaptu := {}
        aPodeMover := {}
    endif

    oLbCoorAt:SetText(cNomeCasa)
    oLbNomePeca:SetText(iif(cNomePeca == 'vazio', '', right(cNomePeca, len(cNomePeca)-1)))
    
    cPenultCasa := cUltmCasa
    cPenultPeca := cNomePeca
    
    if aScan(aCapPreta, 'prei')
        bTheEnd := .T.
        FWAlertSuccess('As pe�as "BRANCAS" Venceram!', 'Fim de jogo')
    endif

    if aScan(aCapBranca, 'brei')
        bTheEnd := .T.
        FWAlertSuccess('As pe�as "PRETAS" Venceram!', 'Fim de jogo')
    endif

Return 

/*/{Protheus.doc} SetImgCoor
@Description 
@Type		 
@Author 	 
@Since  	 07/07/2023
/*/
Static Function SetImgCoor(cNomeObj, aPos, aTam, cSrcImg)
    
    &(cNomeObj+' := TBitmap():Create(oPnl, aPos[2], aPos[1], aTam[1], aTam[2], NIL, cSrcImg, .T., NIL, NIL, .F., .T., NIL, NIL, .F., NIL, .T., NIL, .F.)')

Return

/*/{Protheus.doc} SetBorda
@Description 
@Type		 
@Author 	 
@Since  	 07/07/2023
/*/
Static Function SetBorda(cCasa, cCor)
    
    Local cNomeObj := 'oB'+cCor+cvaltochar(len(aClearObj)+1)

    aTmp := GetCasaPos(cCasa)

    if aTmp != NIL
        
        &(cNomeObj+' := TBitmap():Create(oPnl, aTmp[2]+nAddBdVert, aTmp[1]+nAddBdHori, nTamPeca+nAddBdTama, nTamPeca+nAddBdTama, NIL, cImgBd'+cCor+', .T., {||ClickCasa(cCasa)}, NIL, .F., .T., NIL, NIL, .F., NIL, .T., NIL, .F.)')
        
        // guardar nome do objeto que ser� destru�do posteriormente
        aadd(aClearObj, cNomeObj)

    endif

Return

/*/{Protheus.doc} ClearObjs
@Description 
@Type		 
@Author 	 
@Since  	 05/07/2023
/*/
Static Function ClearObjs()
    
    Local x

    // ATEN��O ATEN��O ATEN��O 
    for x := 1 to len(aClearObj)    
    // ATEN��O ATEN��O ATEN��O caso n�o esteja removendo a imagem, 
    // veja se a vari�vel da mesma foi iniciada no array em um 'for' 
    // ap�s as declara��es de vari�veis
        if type(aClearObj[x]) == "O"
            &("FwFreeObj("+aClearObj[x]+")")
        endif
    next
    
    aClearObj := {}

Return

/*/{Protheus.doc} SetBrdGreen
@Description 
@Type		 
@Author 	 
@Since  	 10/07/2023
/*/
Static Function SetBrdGreen(cVerCasa)
    
    Local cVerNomePeca := GetPecaCasa(cVerCasa)

    // se estiver vazio, coloca uma borda verde
    if cVerNomePeca == "vazio"
        aTmp = GetCasaPos(cVerCasa)

        if aTmp != NIL
            aadd(aPodeMover, cVerCasa)
            SetBorda(cVerCasa, 'Green')
        endif
    endif
    
Return

/*/{Protheus.doc} SetBrdBlue
@Description 
@Type		 
@Author 	 
@Since  	 10/07/2023
/*/
Static Function SetBrdBlue(cVerCasa)
    
    Local cVerNomePeca := GetPecaCasa(cVerCasa)

    // se estiver vazio, coloca uma borda azul
    if cVerNomePeca == "vazio"
        aTmp = GetCasaPos(cVerCasa)

        if aTmp != NIL
            aadd(aPodeMover, cVerCasa)
            SetBorda(cVerCasa, 'Blue')
        endif
    endif
    
Return


/*/{Protheus.doc} SetbrdMov
Verifica se coloca a borda vermelha nas pe�as do oponente
@type function
@version  
@author Peter Newton
@since 09/07/2023
@param cCor, character, param_description
@param cVerCasa, character, param_description
@return variant, return_description
/*/
Static Function SetBrdRed(cCor, cVerCasa)
    
    Local cVerNomePeca := GetPecaCasa(cVerCasa)
    Local cVerCorPeca := left(cVerNomePeca, 1)

    // se n�o estiver vazio, coloca uma borda vermelha
    if cVerCorPeca != cCor .AND. cVerNomePeca != "vazio"
        aTmp = GetCasaPos(cVerCasa)

        if aTmp != NIL
            aadd(aPodeCaptu, cVerCasa)
            SetBorda(cVerCasa, 'Red')
        endif
    endif
    
Return

/*/{Protheus.doc} MovPermPeca
Movimentos permitidos relacionados ao ponto atual, calculando com ponto cartesiano
@type function
@version  
@author Peter Newton
@since 05/07/2023
@param cPeca, character, nome da pe�a ex.: ppeao, btorre
@param cCasa, character, nome da casa ex.: a1, b3
/*/
Static Function MovPermPeca(cPeca, cCasa)
    
    Local aRet       := {}
    Local x
    Local cCor       := left(cPeca, 1)
    Local cCasaLetra := left(cCasa, 1)
    Local nCasaHoriz := asc(left(cCasa, 1))
    Local nCasaVert  := val(right(cCasa, 1))
    Local cVerCasa
    Local cVerNomePeca
    Local nQtdeExpan := 1 // quantidade de loop para expandir a partir da pe�a selecionada. Ex.: Rei 1 casa, Dama infinito
    Local bContinT := .T. // se continua verificando as casas acima
    Local bContinTR := .T. // se continua verificando as casas acima direita
    Local bContinR := .T. // se continua verificando as casas � direita
    Local bContinBR := .T. // se continua verificando as casas abaixo direita
    Local bContinB := .T. // se continua verificando as casas abaixo    
    Local bContinBL := .T. // se continua verificando as casas abaixo direita
    Local bContinL := .T. // se continua verificando as casas � esquerda        
    Local bContinTL := .T. // se continua verificando as casas acima esquerda

    // vari�vies para calcular posi��es poss�veis de cada pe�a
    Local nXFrente := 1 // quantidade de casas na frente da pe�a selecionada
    Local nXtop    := 0 // para cima no tabuleiro
    Local nXLeft   := 0 // para a esquerda no tabuleiro
    Local nXRight  := 0 // para a direita no tabuleiro
    Local nXBottom := 0 // para baixo no tabuleiro

    // inicializa o array com as casas que podem ser capturadas
    aPodeCaptu := {}
    // remove a letra inicial q indica a cor, aqui n�o precisa, por isso pegamos apenas o nome da pe�a
    cPeca := right(cPeca, (len(cPeca)-1))

    do case
    case cPeca == 'cavalo'
        
        // primeiro loop far� adi��o de 1 casa para um lado e 
        // depois para o outro ap�s contar duas casas de dist�ncia
        nSomarLado := 1

        for x := 1 to 2

            if x == 2
                nSomarLado := -1
            endif

            cVerCasa := chr(nCasaHoriz+nSomarLado)+cvaltochar(nCasaVert-2)
            SetBrds(cVerCasa, cCor)
            cVerCasa := chr(nCasaHoriz+2)+cvaltochar(nCasaVert-nSomarLado)
            SetBrds(cVerCasa, cCor)
            cVerCasa := chr(nCasaHoriz-nSomarLado)+cvaltochar(nCasaVert+2)
            SetBrds(cVerCasa, cCor)
            cVerCasa := chr(nCasaHoriz-2)+cvaltochar(nCasaVert-nSomarLado)
            SetBrds(cVerCasa, cCor)

        next
        
    case cPeca == 'peao'

        // adicionar casa � frente do pe�o
        // no tabuleiro, a pe�a preta desce e a branca sobe
        // na descida os n�meros aumentam
        nXFrente := nCasaVert + (iif(cCor == 'p', +1, -1))
        
        // casa na frente do pe�o para posi��o
        cVerCasa := chr(nCasaHoriz)+cvaltochar(nXFrente)
        SetBrdBlue(cVerCasa)

        // casa na diagonal que o peao pode capturar, esquerda
        cVerCasa := chr(nCasaHoriz-(iif(nCasaHoriz == 97, 0, 1)))+cvaltochar(nXFrente)
        SetBrdRed(cCor, cVerCasa)
        
        // casa na diagonal que o peao pode capturar, direita
        cVerCasa := chr(nCasaHoriz+1)+cvaltochar(nXFrente)
        SetBrdRed(cCor, cVerCasa)                

        // no primeiro movimento do pe�o � poss�vel movimentar duas casas pra frente
        // se forem as pe�as pretas na linha 2 ou pe�as brancas na linha 7, podem iniciar o movimento com 2 casas
        if (cCor == 'p' .AND. nCasaVert == 2) .OR. (cCor == 'b' .AND. nCasaVert == 7)
            nXFrente += (iif(cCor == 'p', +1, -1))
            cVerCasa := chr(nCasaHoriz)+cvaltochar(nXFrente)
            SetBrdBlue(cVerCasa)
        endif

    case cPeca == 'torre-C�DIGO-OBSOLETO'
        // ===================================
        // ESTE C�DIGO FICOU OBSOLETO AP�S A CRA��O PARA O REI E DAMA
        // ===================================
        
        // limite do tamanho do tabuleiro em 8 casas
        for x := 1 to nQtdeCasas

            nXLeft--
            nXRight++
            nXBottom++
            nXTop--

            nVerTop    := (nCasaVert+nXTop)
            nVerRight  := chr(nCasaHoriz+nXRight)
            nVerBottom := (nCasaVert+nXBottom)
            nVerLeft   := chr(nCasaHoriz+nXLeft)
            
            if bContinR .AND. nVerRight <= 'h'
                // casas na direita da torre
                cVerCasa := nVerRight+cvaltochar(nCasaVert)
                bContinR := SetBrds(cVerCasa, cCor)
                
            endif
            
            if bContinL .AND. nVerLeft >= 'a'
                // casas na esquerda da torre
                cVerCasa := nVerLeft+cvaltochar(nCasaVert)
                bContinL := SetBrds(cVerCasa, cCor)
                
            endif
            
            if bContinT .AND. nVerTop >= 1
                // casas para cima da torre
                cVerCasa := cCasaLetra+cvaltochar(nVerTop)
                bContinT := SetBrds(cVerCasa, cCor)

            endif
            
            if bContinB .AND. nVerBottom <= 8
                // casas para baixo da torre
                cVerCasa := cCasaLetra+cvaltochar(nVerBottom)                
                bContinB := SetBrds(cVerCasa, cCor)
            endif
        next

    case cPeca == 'rei' .OR. cPeca == 'dama' .OR. cPeca == 'bispo' .OR. cPeca == 'torre'
        
        // apenas o rei move 1 casa, dama e bispo podem mover at� 8
        nQtdeExpan := iif(cPeca == 'rei', 1, 8)

        // bispo move-se apenas nas diagonais, ent�o desativa as outras possibilidades
        if cPeca == 'bispo'
            bContinT := .F.
            bContinR := .F.
            bContinB := .F.
            bContinL := .F.
        endif

        // torre move-se apenas nas horizontais e diagonais, ent�o desativa as outras possibilidades
        if cPeca == 'torre'
            bContinTR := .F.
            bContinBR := .F.
            bContinBL := .F.
            bContinTL := .F.
        endif

        for x := 1 to nQtdeExpan

            // VERIFICANDO CASAS NO SENTIDO HOR�RIO

            // casa superior
            if bContinT
                cVerCasa := cCasaLetra+cvaltochar(nCasaVert-x)
                bContinT := SetBrds(cVerCasa, cCor)
            endif
            // casa superior direita
            if bContinTR
                cVerCasa := chr(nCasaHoriz+x)+cvaltochar(nCasaVert-x)
                bContinTR := SetBrds(cVerCasa, cCor)
            endif
            // casa direita
            if bContinR
                cVerCasa := chr(nCasaHoriz+x)+cvaltochar(nCasaVert)
                bContinR := SetBrds(cVerCasa, cCor)
            endif
            // casa inferior direita
            if bContinBR
                cVerCasa := chr(nCasaHoriz+x)+cvaltochar(nCasaVert+x)
                bContinBR := SetBrds(cVerCasa, cCor)
            endif
            // casa inferior
            if bContinB
                cVerCasa := cCasaLetra+cvaltochar(nCasaVert+x)
                bContinB := SetBrds(cVerCasa, cCor)
            endif
            // casa inferior esquerda
            if bContinBL
                cVerCasa := chr(nCasaHoriz-x)+cvaltochar(nCasaVert+x)
                bContinBL := SetBrds(cVerCasa, cCor)
            endif
            // casa esquerda
            if bContinL
                cVerCasa := chr(nCasaHoriz-x)+cvaltochar(nCasaVert)
                bContinL := SetBrds(cVerCasa, cCor)
            endif
            // casa superior esquerda
            if bContinTL
                cVerCasa := chr(nCasaHoriz-x)+cvaltochar(nCasaVert-x)
                bContinTL := SetBrds(cVerCasa, cCor)
            endif
        next
        
    endcase
Return

/*/{Protheus.doc} SetTorre
@Description 
@Type		 
@Author 	 
@Since  	 12/07/2023
/*/
Static Function SetBrds(cVerCasa, cCor)
    
    Local bContin := .T. // se continua verificando

    cVerNomePeca := GetPecaCasa(cVerCasa)

    if cVerNomePeca == "vazio" .OR. cVerNomePeca == "fora"
        SetBrdBlue(cVerCasa)
    else
        bContin := .F.
        // se for uma pe�a do oponente, colocar a borda vermelha para captura
        if left(cVerNomePeca, 1) != cCor
            SetBrdRed(cCor, cVerCasa)
        endif
    endif
Return bContin

/*/{Protheus.doc} SetCasa
@Description 
@Type		 
@Author 	 
@Since  	 05/07/2023
/*/
Static Function SetCasa(casa, peca)
    
    &('oCasa'+casa+':cBmpFile:= "'+cSrcFiles+peca+'.PNG"')
    
Return

/*/{Protheus.doc} GetPecaCasa
@Description 
@Type		 
@Author 	 
@Since  	 05/07/2023
/*/
Static Function GetPecaCasa(cCasa)
    
    Local cRet := NIL
    Local cNmSrcImg
    
    if type('oCasa'+cCasa) == 'O'
        cNmSrcImg := &('oCasa'+cCasa+':cBmpFile')
        cRet := lower(retfilename(cNmSrcImg))
    else
        cRet := 'fora'
    endif

Return cRet

/*/{Protheus.doc} GetCasaPos
Pegar posi��o da casa especificada
@type function
@version  
@author Peter Newton
@since 05/07/2023
@param cCasa, character, nome da casa ex.: a1, b3
@return array com as posi��es em x, y
/*/
Static Function GetCasaPos(cCasa)
    
    Local aRet := {0, 0}

    if type('oCasa'+cCasa) == 'O'
        aRet[1] := &('aPosCasa'+cCasa+'[1]')
        aRet[2] := &('aPosCasa'+cCasa+'[2]')
    else
        aRet := NIL
    endif
    
Return aRet

Static Function Tempo()
 
//   nTempo := nLimite - nStop
 
//   oSay4:Refresh()
 
//   nStop++
 
Return

/*/{Protheus.doc} Fechar
@Description Pergunta se deseja fechar o jogo
@Type		 
@Author 	 Peter Newton
@Since  	 01/07/2023
/*/
Static Function Fechar()
    
    if FWAlertNoYes("Deseja realmente sair do Jogo?", "Fechar Xadrez ADVPL")
        oDlg:OOWNER:END()
    endif

Return
