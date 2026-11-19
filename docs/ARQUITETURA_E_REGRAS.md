# Athenaeum — arquitetura e regras do sistema

## Camadas

- **Models:** classes de domínio e regras da aplicação.
- **DAOs:** comandos SQL preparados e persistência via PDO.
- **Controllers:** validação das ações recebidas por POST e encaminhamento para Models.
- **Views:** páginas públicas e telas administrativas.
- **Core:** sessão, autenticação, proteção CSRF, helpers e conexão.

## Cinco classes principais

| Classe | Responsabilidade | Operações principais |
|---|---|---|
| `Livro` | Cadastro e catálogo de livros, sinopses, preços e estoque | listar, buscarPorId, cadastrar, editar, deletar |
| `Usuario` | Clientes, administrador e autenticação | listar, buscarPorId, autenticar, cadastrar, editar, deletar |
| `Compra` | Pedidos de compra e seus itens | listar, buscarPorId, cadastrar/finalizar, editar status, cancelar |
| `Aluguel` | Reservas, retiradas e devoluções | listar, buscarPorId, cadastrar/reservar, editar status, deletar |
| `Multa` | Cálculo, consulta e baixa de multas | listar, buscarPorId, cadastrar, editar, deletar |

Cada classe delega a persistência para seu DAO correspondente em `admin/dao/`.

## Modelo relacional

- `usuarios`: clientes e o único administrador inicial.
- `livros`: catálogo, sinopse, preço de venda, valor de aluguel, duas quantidades de estoque e nome do arquivo de capa.
- `compras`: cabeçalho dos pedidos, ligado ao usuário.
- `compra_itens`: itens e valores congelados no momento da compra; permite preservar o histórico mesmo se o cadastro do livro mudar.
- `alugueis`: reserva, retirada, prazo previsto e devolução, com o título preservado no histórico.
- `multas`: uma multa por registro de aluguel, ligada ao cliente e ao aluguel.

## Ciclo de aluguel

1. O cliente reserva um exemplar disponível no site. A reserva fica com status `reservado` e aguarda a loja.
2. No painel, o administrador confirma a retirada. O status passa para `ativo` e o prazo de sete dias começa nessa data.
3. Ao receber o exemplar, o administrador registra a devolução. O aluguel passa para `devolvido`.
4. A cada acesso, o sistema sincroniza multas de aluguéis ativos vencidos e de aluguéis devolvidos com atraso. O cálculo é de R$ 2,00 por dia.
5. O administrador registra o pagamento da multa na área administrativa. Se o aluguel continuar ativo e o atraso aumentar depois, o saldo é recalculado.

As quantidades reservadas e alugadas são consideradas ao calcular a disponibilidade para novos pedidos de aluguel. A conclusão da devolução libera o exemplar novamente.

## Ciclo de compra

1. O visitante adiciona livros ao carrinho.
2. Para finalizar, precisa entrar em uma conta.
3. A compra é registrada em transação, os itens e preços são guardados e o estoque de venda é reduzido.
4. O administrador atualiza o andamento ou cancela o pedido. O cancelamento devolve as quantidades ao estoque.

**Limite da demonstração:** não existe integração com cartão, PIX ou gateway financeiro. O checkout registra o pedido para acompanhamento e demonstração acadêmica.
