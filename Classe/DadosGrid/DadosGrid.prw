#include "protheus.ch"

/*/{Protheus.doc} DadosGrid
Transformar os dados da Grid em Json/Array para facilitar o trabalho com as informações
@type function
@version 1
@author Peter Newton
@since 17/05/2023
/*/

user function DadosGrid()
return

CLASS DadosGrid

    DATA oDados

    METHOD New() CONSTRUCTOR
    METHOD SetGrid(aCabecalho, aLinha)
    METHOD GetAll()
    METHOD GetLine(nNum)
    METHOD GetLineData(nNum, cCampo)
    METHOD Set(cCampo, cValor)
    METHOD Get(cCampo, cValor)

ENDCLASS

METHOD New() CLASS DadosGrid

    ::oDados := JsonObject():New()

Return Self

METHOD SetGrid(aCabecalho, aLinha) CLASS DadosGrid

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

METHOD GetAll() CLASS DadosGrid

return ::oDados

METHOD GetLine(nNum) CLASS DadosGrid

return ::oDados[cValToChar(nNum)]

METHOD GetLineData(nNum, cCampo) CLASS DadosGrid

return ::oDados[cValToChar(nNum)][cCampo]

METHOD Set(cCampo, cValor) CLASS DadosGrid
    
    ::oDados[cValToChar(cCampo)] := cValor

return Nil

METHOD Get(cCampo) CLASS DadosGrid

    Local cValor := ::oDados[cValToChar(cCampo)]

return cValor
