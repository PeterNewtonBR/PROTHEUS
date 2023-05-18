
#include "protheus.ch"

/*/{Protheus.doc} DadosGrid
Trnasformar os dados da Grid em Json/Array para facilitar o trabalho com as informa��es
@type function
@version 1
@author Peter Newton
@since 17/05/2023
/*/
user function DadosGrid()
    
    Local oDados     := GridAssoc():New()
    Local aDados
    Local x1
    Local aDadosNm1
    Local aItem
    Local aItemNm

    Local aCabecalho := Array(3, 3)
    Local aLinha     := array(2, 4)

    // dados fict�cios de 'aHeader'
    aCabecalho[1][2] := "Campo1"
    aCabecalho[2][2] := "Campo2"
    aCabecalho[3][2] := "Campo3"

    // dados fict�cios de 'aCols'
    aLinha[1][1]     := "Valor1 1"
    aLinha[1][2]     := "Valor1 2"
    aLinha[1][3]     := "Valor1 3"
    aLinha[1][4]     := "Valor1 3"

    aLinha[2][1]     := "Valor2 1"
    aLinha[2][2]     := "Valor2 2"
    aLinha[2][3]     := "Valor2 3"
    aLinha[2][4]     := "Valor2 3"

    conout("BEGIN +++++++++ Dados do Grid para Objeto/Array/Json Associativo +++++++++")

    // Guardar todas as linhas
    oDados:SetGrid(aCabecalho, aLinha)

    // Capturar todos os dados da Grid
    aDados := oDados:GetAll()

    // Quantidade de linhas, retorna o nome de cada �ndice
    aDadosNm1 := aDados:GetNames()

    // Capturar dados da segunda linha
    aItem := oDados:GetLine(2)

    // Quantidade de �ndices
    aItemNm := aItem:GetNames()

    for x1 := 1 to len(aItemNm)
        
        conout("Dado: " + aItemNm[x1] + " = " + aItem[aItemNm[x1]])

    next x1

    // Resumo da �pera acima, buscando pela linha e nome do campo
    conout(oDados:GetLineData(2, "Campo3"))

    // Guardar valor desejado
    oDados:Set("Campo", "Valor Teste")

    // Capturar valor de um campo
    conout(oDados:Get("Campo"))

    // Valor acessado diretamente
    conout("Acesso direto: " + cValToChar(oDados:ODADOS["1"]["Campo1"]))
    
	conout("END +++++++++ Dados do Grid para Objeto/Array/Json Associativo +++++++++")
	
return

CLASS GridAssoc

    DATA oDados

    METHOD New() CONSTRUCTOR
    METHOD SetGrid(aCabecalho, aLinha)
    METHOD GetAll()
    METHOD GetLine(nNum)
    METHOD GetLineData(nNum, cCampo)
    METHOD Set(cCampo, cValor)
    METHOD Get(cCampo, cValor)

ENDCLASS

METHOD New() CLASS GridAssoc

    ::oDados := JsonObject():New()

Return Self

METHOD SetGrid(aCabecalho, aLinha) CLASS GridAssoc

    Local x1, x2

    // percorrer cada linha
    for x1 := 1 to len(aLinha)
        
        ::oDados[cValToChar(x1)] := JsonObject():New()

        // adicionar cada valor associativo
        for x2 := 1 to len(aLinha[x1])-1
        
            ::oDados[cValToChar(x1)][trim(aCabecalho[x2][2])] := cValToChar(aLinha[x1][x2])

        next x2

    next x1

return ::oDados

METHOD GetAll() CLASS GridAssoc

return ::oDados

METHOD GetLine(nNum) CLASS GridAssoc

return ::oDados[cValToChar(nNum)]

METHOD GetLineData(nNum, cCampo) CLASS GridAssoc

return ::oDados[cValToChar(nNum)][cCampo]

METHOD Set(cCampo, cValor) CLASS GridAssoc
    
    ::oDados[cValToChar(cCampo)] := cValor

return Nil

METHOD Get(cCampo) CLASS GridAssoc

    Local cValor := ::oDados[cValToChar(cCampo)]

return cValor
