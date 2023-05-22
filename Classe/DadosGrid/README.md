
# DadosGrid

Classe em ADVPL para facilitar o trabalho com os valores do Grid, sendo eles o ```aHeader``` e ```aCols```.


## Uso/Exemplos

```
#include "protheus.ch"

user function Teste()
    
    Local oDados     := GridAssoc():New()
    Local cProduto

    oDados:SetGrid(aHeader, aCols)
    cProduto := oDados:GetLineData(2, "C6_PRODUTO")

    conout(cProduto)
    
return
```
## Dados fictícios para teste

```
    // dados fictícios de 'aHeader'
    aCabecalho[1][2] := "Campo1"
    aCabecalho[2][2] := "Campo2"
    aCabecalho[3][2] := "Campo3"

    // dados fictícios de 'aCols'
    aLinha[1][1]     := "Valor1 1"
    aLinha[1][2]     := "Valor1 2"
    aLinha[1][3]     := "Valor1 3"
    aLinha[1][4]     := "Valor1 3"

    aLinha[2][1]     := "Valor2 1"
    aLinha[2][2]     := "Valor2 2"
    aLinha[2][3]     := "Valor2 3"
    aLinha[2][4]     := "Valor2 3"
```
## Funcionalidades

- Ter todos os dados em Json
- Ter todos os dados por linha
- Ter os dados por linha e campo
- Guardar o valor desejado


## Demonstração

+ Guardar todas as linhas

    ```oDados:SetGrid(aCabecalho, aLinha)```
#
- Ter todos os dados por linha

    ```aItem := oDados:GetLine(2)```
#
- Ter os dados por linha e campo

    ```conout(oDados:GetLineData(2, "Campo3"))```
#
- Guardar o valor desejado

    ```oDados:Set("Campo", "Valor Teste")```
#
- Recuperar valor desejado
    ```conout(oDados:Get("Campo"))```
## Licença

[MIT](https://choosealicense.com/licenses/mit/)
