
# Alvará x Cliente x Produto

Função para verificar se determinado cliente possui um alvará válido para um determinado produto em uma data específica.




## Problematização
Bloquear a venda de produto que necessite de um alvará concedido por Estado ou Prefeitura, como Anvisa por exemplo.

## Solução
-> Campo novo na tabela SB1 (Produtos) para verificar alvará.
-> Criação da tabela.
   - Campos virtuais.
   - Indice.
   - Inicializador Padrão.
   - Inicializador Browse.
   - Gatilhos.
-> Menu.
   - Rdmake MVC para abrir a tela de cadastro.
-> Função.
   - Ponto de entrada para verificar se já existe um mesmo alvará cadastrado.
   - Função para verificar validade e se o produto exige alvará.
   - Chamada da função no ponto de entrada de pedido de venda MTA410.

## Demonstração
 
Demonstração de uso no ponto de entrada do Pedido de Venda

```
User Function MTA410(Args)
    
    Local aArea      := GetArea()
    Local aAreaC5    := SC5->(GetArea())
    Local oDados     := DadosGrid():New()
    Local lRet       := .T.
    Local i          := 0
    Local aQtdeItems := 0
    Local dDataVerif := M->C5_EMISSAO
    
    oDados:SetGrid(aHeader, aCols)

    // Capturar todos os dados da Grid
    aDados := oDados:GetAll()
    aQtdeItems := aDados:GetNames()

    for i := 1 to len(aQtdeItems)

        if lRet == .F. 
            exit
        endif
        // Capturar dados da linha
        aItem := oDados:GetLine(i)
        lRet := U_AlvaraValido(M->C5_CLIENTE, aItem["C6_PRODUTO"], dDataVerif) 
                
    next i
       
    RestArea(aAreaC5)
    RestArea(aArea)

Return lRet
```
## Tabela e Índice

Campos: ZZA_FILIAL, ZZA_CLIENT, ZZA_PRODUT, ZZA_ALVANU, ZZA_DTEMIS, ZZA_DTVCTO, ZZA_UF, ZZA_CODMUN.

Campos Virtuais: ZZA_CLINM, ZZA_PRODNM, ZZA_CIDADE.

![ZZA tabela](https://github.com/PeterNewtonBR/PROTHEUS/assets/61658443/bcdbc047-1d13-4e85-9fb9-2c8daeee4d0e)

![ZZA indices](https://github.com/PeterNewtonBR/PROTHEUS/assets/61658443/5a5a9d73-0c60-4f74-841f-048099213acd)

