
# Liberar venda por Cliente x Quantidade x Período

Função para verificar se determinado tipo de produto não pode ultrapassar a quantidade de itens vendidos em um determinado período de tempo por um cliente.




## Problematização
Controlar a quantidade de itens que podem ser vendido à um cliente por um determinado período de tempo.

## Solução
-> Criação da tabela.
   - Campos virtuais.
   - Indice.
   - Inicializador Padrão.
   - Inicializador Browse.
   - Gatilhos.
-> Menu.
   - Rdmake MVC para abrir a tela de cadastro.
-> Função.
   - Ponto de entrada para verificar se já existe cadastro para uma mesma regra de uma empresa.
   - Função para verificar contagem e validar quantidade.
   - Chamada da função no ponto de entrada de pedido de venda.
   - Chamada da função no ponto de entrada para liberação de venda.


## Demonstração

Demonstração de uso no ponto de entrada do Pedido de Venda

```
User Function MTA410(Args)
    
    Local aArea   := GetArea()
    Local aAreaC5 := SC5->(GetArea())
    Local oDados  := DadosGrid():New()
    Local lRet    := .T.
    Local i       := 0
    Local aQtdeItems
    
    oDados:SetGrid(aHeader, aCols)

    // Capturar todos os dados da Grid
    aDados := oDados:GetAll()
    aQtdeItems := aDados:GetNames()

    for i := 1 to len(aQtdeItems)
        
        // Capturar dados da linha
        aItem := oDados:GetLine(i)

        if lRet == .T.
            lRet := U_PedidoPeriodo(C5_CLIENTE, aItem["C6_PRODUTO"], aItem["C6_QTDVEN"])
        endif

    next i
   
    RestArea(aAreaC5)
    RestArea(aArea)

Return lRet
```
## Tabela e Índice
![tabela](https://github.com/PeterNewtonBR/PROTHEUS/assets/61658443/19220507-b4dd-459b-8b41-ad9eafdc52e4)
![indice](https://github.com/PeterNewtonBR/PROTHEUS/assets/61658443/5c36a889-50f0-441b-ac3d-485b1b21dbdb)
