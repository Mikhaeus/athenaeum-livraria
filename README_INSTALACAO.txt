ATHENAEUM — LIVRARIA & ACERVO
================================

PROJETO INDEPENDENTE
--------------------
Pasta: C:\xampp\htdocs\athenaeum_livraria
Página inicial: http://localhost/athenaeum_livraria/
Painel administrativo: http://localhost/athenaeum_livraria/admin/
Banco de dados: athenaeum_livraria

REQUISITOS
----------
- XAMPP com Apache e MySQL/MariaDB ativos
- PHP 8.0 ou superior
- Extensão PDO MySQL habilitada (normal no XAMPP)
- Navegador atualizado (transições de navegação mais suaves em Chrome/Edge atuais)

INSTALAÇÃO LIMPA
----------------
1. Extraia a pasta athenaeum_livraria dentro de C:\xampp\htdocs. Não renomeie a pasta, pois ela define a URL base do sistema.
2. Abra o XAMPP e inicie Apache e MySQL.
3. Entre em http://localhost/phpmyadmin/
4. Clique em Importar e selecione o arquivo banco.sql que está na raiz do projeto. O script cria o banco athenaeum_livraria e suas tabelas.
5. Confirme que admin/config/conexao.php usa host 127.0.0.1, banco athenaeum_livraria, usuário root e senha vazia (padrão local do XAMPP). Ajuste caso seu MySQL use outra senha/porta.
6. Acesse http://localhost/athenaeum_livraria/

ATENÇÃO SOBRE O BANCO
---------------------
- banco.sql é para uma instalação limpa. Ele cria/recria as tabelas do banco athenaeum_livraria. Não importe sobre uma base athenaeum_livraria que já contenha dados importantes.
- O projeto usa um banco próprio e não altera loja_games_gustavo nem biblioteca_athenaeum.

CONTAS DE TESTE
---------------
Veja CONTAS_DE_TESTE.txt. Há 1 administrador (Gustavo) e 13 clientes. O formulário de cadastro administrativo cria somente clientes; o usuário administrador inicial é preservado como a única conta administrativa do pacote.
- Admin: gustavo.martins@gmail.com / gustavo2026
- Clientes: cada usuário tem a senha leitor2026.
As senhas foram geradas com password_hash() compatível com password_verify().

FUNCIONALIDADES
---------------
- Catálogo público de 38 livros, busca por título/autor/sinopse e filtro por categoria.
- Página individual “Ver detalhes” e seção “Sinopse”.
- Carrinho, atualização de quantidades e finalização de pedido.
- Histórico de compras e pedidos no perfil do cliente.
- Reserva online de exemplar para aluguel, com retirada presencial na loja física.
- O administrador confirma a retirada; nessa hora começa o prazo de 7 dias.
- O administrador registra devoluções. O histórico e as datas ficam disponíveis para o cliente e para a administração.
- Multa automática de R$ 2,00 por dia de atraso, recalculada ao consultar o sistema; o pagamento é baixado pelo administrador.
- Painel administrativo com CRUD de livros, usuários, compras, aluguéis e multas.
- Consulta individual do histórico de cada usuário (compras, aluguéis e multas).
- Upload de capa no painel: JPG, PNG ou WebP, até 5 MB.
- Cinco classes de domínio com métodos CRUD: Livro, Usuario, Compra, Aluguel e Multa; DAOs separados e MVC (Models, Views, Controllers).
- Consultas PDO preparadas, senha com password_hash()/password_verify(), sessão, proteção CSRF e permissões administrativas.
- Navegação com abas, menu responsivo e transição suave de página em navegadores atuais.

OBSERVAÇÕES IMPORTANTES
-----------------------
- O checkout registra o pedido e desconta o estoque em transação, mas não processa pagamento real: não foi conectado gateway bancário/cartão. A loja deve confirmar o pagamento por fora.
- Reserva de aluguel não significa retirada automática: fica aguardando até o administrador confirmar a retirada no painel.
- O aluguel padrão é de 7 dias. O valor inicial de aluguel é uma política de demonstração aproximada (cerca de 10% do preço de venda, mínimo R$ 5) e pode ser editado por livro.
- O banco inclui dados de demonstração: um aluguel atrasado de Mariana (para testar a multa), uma reserva de João e um pedido concluído de Lucas.
- Nenhuma imagem de capa foi incluída, conforme solicitado. Adicione-as pelo painel ou copie arquivos para public/imagens e preencha o nome no cadastro do livro.
- Preços e fontes consultadas estão em docs/fontes_catalogo.md. Os valores são referências de edição/consulta em 19/11/2026 e podem variar conforme loja, edição, promoção e disponibilidade.

ESTRUTURA
---------
admin/config/       conexão PDO
admin/core/         bootstrap, autenticação, helpers e segurança
admin/dao/          acesso a dados
admin/models/       cinco classes de domínio
admin/controllers/  ações e validações
admin/views/        telas públicas e administrativas
admin/partials/     cabeçalhos/rodapés
public/css/         identidade visual
public/js/          interações e menu
public/imagens/     capas dos livros
docs/               fontes do catálogo e arquitetura

TESTES
------
Use CHECKLIST_TESTE.txt para executar os fluxos principais com as contas de demonstração. Consulte docs/ARQUITETURA_E_REGRAS.md para conhecer as cinco classes, tabelas e regras de compra/aluguel.

GITHUB
------
Para publicar, crie um repositório público e envie os arquivos desta pasta. Antes de publicar, altere as credenciais de banco para variáveis de ambiente e troque a senha inicial do administrador. Não publique dados pessoais ou senhas reais.
