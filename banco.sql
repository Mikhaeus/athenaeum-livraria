-- Athenaeum | instalação limpa — PHP 8 / MySQL / MariaDB

-- Importe este arquivo no phpMyAdmin. Ele cria a base athenaeum_livraria.

SET NAMES utf8mb4;

SET FOREIGN_KEY_CHECKS=0;

CREATE DATABASE IF NOT EXISTS athenaeum_livraria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE athenaeum_livraria;

DROP TABLE IF EXISTS multas, alugueis, compra_itens, compras, livros, usuarios;

SET FOREIGN_KEY_CHECKS=1;



CREATE TABLE usuarios (
 id INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(120) NOT NULL,
 email VARCHAR(160) NOT NULL UNIQUE,
 telefone VARCHAR(30) NULL,
 senha VARCHAR(255) NOT NULL,
 tipo ENUM('admin','usuario') NOT NULL DEFAULT 'usuario',
 ativo TINYINT(1) NOT NULL DEFAULT 1,
 criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE livros (
 id INT AUTO_INCREMENT PRIMARY KEY,
 titulo VARCHAR(180) NOT NULL,
 autor VARCHAR(150) NOT NULL,
 categoria VARCHAR(100) NOT NULL,
 colecao VARCHAR(150) NULL,
 sinopse TEXT NOT NULL,
 preco_venda DECIMAL(10,2) NOT NULL DEFAULT 0.00,
 valor_aluguel DECIMAL(10,2) NOT NULL DEFAULT 7.00,
 estoque_venda INT NOT NULL DEFAULT 0,
 estoque_aluguel INT NOT NULL DEFAULT 0,
 imagem VARCHAR(255) NULL,
 fonte_sinopse VARCHAR(500) NULL,
 fonte_preco VARCHAR(500) NULL,
 ativo TINYINT(1) NOT NULL DEFAULT 1,
 criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 atualizado_em DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
 KEY idx_livros_titulo (titulo), KEY idx_livros_categoria (categoria),
 CONSTRAINT chk_livros_preco CHECK (preco_venda >= 0),
 CONSTRAINT chk_livros_aluguel CHECK (valor_aluguel >= 0),
 CONSTRAINT chk_livros_estoque_venda CHECK (estoque_venda >= 0),
 CONSTRAINT chk_livros_estoque_aluguel CHECK (estoque_aluguel >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE compras (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 total DECIMAL(10,2) NOT NULL,
 status ENUM('confirmado','separando','concluido','cancelado') NOT NULL DEFAULT 'confirmado',
 data_compra DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_compras_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 KEY idx_compras_usuario (usuario_id), KEY idx_compras_data (data_compra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE compra_itens (
 id INT AUTO_INCREMENT PRIMARY KEY,
 compra_id INT NOT NULL,
 livro_id INT NULL,
 titulo_snapshot VARCHAR(180) NOT NULL,
 preco_unitario DECIMAL(10,2) NOT NULL,
 quantidade INT NOT NULL,
 subtotal DECIMAL(10,2) NOT NULL,
 CONSTRAINT fk_compra_itens_compra FOREIGN KEY (compra_id) REFERENCES compras(id) ON DELETE CASCADE,
 CONSTRAINT fk_compra_itens_livro FOREIGN KEY (livro_id) REFERENCES livros(id) ON DELETE SET NULL,
 KEY idx_compra_itens_compra (compra_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE alugueis (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 livro_id INT NULL,
 titulo_snapshot VARCHAR(180) NOT NULL,
 status ENUM('reservado','ativo','devolvido','cancelado') NOT NULL DEFAULT 'reservado',
 valor_aluguel DECIMAL(10,2) NOT NULL,
 data_reserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 data_retirada DATETIME NULL,
 data_prevista_devolucao DATE NULL,
 data_devolucao DATETIME NULL,
 observacoes VARCHAR(500) NULL,
 CONSTRAINT fk_alugueis_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT fk_alugueis_livro FOREIGN KEY (livro_id) REFERENCES livros(id) ON UPDATE CASCADE ON DELETE SET NULL,
 KEY idx_alugueis_usuario (usuario_id), KEY idx_alugueis_status (status), KEY idx_alugueis_vencimento (data_prevista_devolucao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE multas (
 id INT AUTO_INCREMENT PRIMARY KEY,
 aluguel_id INT NOT NULL UNIQUE,
 usuario_id INT NOT NULL,
 dias_atraso INT NOT NULL DEFAULT 0,
 valor DECIMAL(10,2) NOT NULL DEFAULT 0.00,
 status ENUM('pendente','paga','cancelada') NOT NULL DEFAULT 'pendente',
 data_calculo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 pago_em DATETIME NULL,
 CONSTRAINT fk_multas_aluguel FOREIGN KEY (aluguel_id) REFERENCES alugueis(id) ON DELETE CASCADE,
 CONSTRAINT fk_multas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
 KEY idx_multas_usuario (usuario_id), KEY idx_multas_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usuários de demonstração: somente Gustavo é administrador.

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Gustavo Martins','gustavo.martins@gmail.com',NULL,'$2y$12$dHeNAwxAoHi9MqRc7v99wuKA5TJAb0XBYIAWHZ2ThhnfFUB.PuuMi','admin',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Mariana Alves','mariana.alves@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('João Pedro Martins','joao.martins@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Lucas Ferreira','lucas.ferreira@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Ana Clara Souza','ana.souza@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Carlos Eduardo Lima','carlos.lima@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Beatriz Mendes','beatriz.mendes@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Rafael Oliveira','rafael.oliveira@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Gabriel Santos','gabriel.santos@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Fernanda Costa','fernanda.costa@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Pedro Henrique Rocha','pedro.rocha@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Juliana Martins','juliana.martins@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Thiago Almeida','thiago.almeida@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);

INSERT INTO usuarios (nome,email,telefone,senha,tipo,ativo) VALUES ('Camila Ribeiro','camila.ribeiro@example.com',NULL,'$2y$12$G9EFNWUIuL5e6Nw2TVtnC.oCHRldQWnS554/ehbUZ8dEhRO5zAzWC','usuario',1);


-- Catálogo inicial: 38 livros; fotos podem ser enviadas depois pelo painel administrativo.

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Ladrão de Raios','Rick Riordan','Fantasia','Percy Jackson e os Olimpianos','Percy Jackson, um garoto que sempre teve problemas na escola, descobre que é filho de Poseidon. Quando o raio-mestre de Zeus desaparece, ele parte com Annabeth e Grover para impedir uma guerra entre os deuses.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/percy-jackson-and-the-olympians/','https://loja.intrinseca.com.br/o-ladr-o-de-raios/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Mar de Monstros','Rick Riordan','Fantasia','Percy Jackson e os Olimpianos','Percy precisa encontrar o Velocino de Ouro para salvar as proteções mágicas do Acampamento Meio-Sangue. A busca o leva ao Mar de Monstros, onde antigos perigos e uma descoberta sobre seu próprio destino o aguardam.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/percy-jackson-and-the-olympians/','https://rickriordan.com/series/percy-jackson-and-the-olympians/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Maldição do Titã','Rick Riordan','Fantasia','Percy Jackson e os Olimpianos','Durante uma missão de resgate, Percy e seus amigos enfrentam uma ameaça capaz de mudar o equilíbrio do Olimpo. O desaparecimento da deusa Ártemis e uma profecia sombria tornam a jornada ainda mais urgente.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/percy-jackson-and-the-olympians/','https://rickriordan.com/series/percy-jackson-and-the-olympians/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Batalha do Labirinto','Rick Riordan','Fantasia','Percy Jackson e os Olimpianos','Uma entrada para o Labirinto de Dédalo ameaça abrir caminho para uma invasão ao Acampamento Meio-Sangue. Percy e os amigos precisam atravessar corredores mutáveis e descobrir como impedir os planos de Luke.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/percy-jackson-and-the-olympians/','https://rickriordan.com/series/percy-jackson-and-the-olympians/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Último Olimpiano','Rick Riordan','Fantasia','Percy Jackson e os Olimpianos','Enquanto Cronos avança para atacar Nova York e o Monte Olimpo, Percy reúne os semideuses para defender a cidade. A profecia que acompanha sua vida finalmente se aproxima do desfecho.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/percy-jackson-and-the-olympians/','https://rickriordan.com/series/percy-jackson-and-the-olympians/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Herói Perdido','Rick Riordan','Fantasia','Os Heróis do Olimpo','Jason desperta sem memória em um ônibus escolar ao lado de Piper e Leo. Os três descobrem uma ligação com o mundo dos semideuses e partem para uma missão que revela uma nova ameaça aos deuses.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-heroes-of-olympus/','https://rickriordan.com/series/the-heroes-of-olympus/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Filho de Netuno','Rick Riordan','Fantasia','Os Heróis do Olimpo','Sem lembranças de seu passado, Percy chega ao Acampamento Júpiter e conhece os semideuses romanos. Ao lado de Hazel e Frank, ele recebe uma missão que pode determinar o futuro dos acampamentos.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-heroes-of-olympus/','https://rickriordan.com/series/the-heroes-of-olympus/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Marca de Atena','Rick Riordan','Fantasia','Os Heróis do Olimpo','Os sete semideuses da profecia finalmente se reúnem a bordo do Argo II. Annabeth segue uma pista deixada por Atena e precisa enfrentar um desafio ligado à antiga rivalidade entre gregos e romanos.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-heroes-of-olympus/','https://rickriordan.com/series/the-heroes-of-olympus/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Casa de Hades','Rick Riordan','Fantasia','Os Heróis do Olimpo','Enquanto Percy e Annabeth tentam escapar do Tártaro, seus amigos procuram fechar as Portas da Morte do outro lado. A equipe enfrenta monstros, alianças difíceis e o risco de perder os companheiros para sempre.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-heroes-of-olympus/','https://rickriordan.com/series/the-heroes-of-olympus/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Sangue do Olimpo','Rick Riordan','Fantasia','Os Heróis do Olimpo','Com a guerra entre gregos e romanos prestes a explodir, os semideuses precisam impedir que Gaia desperte. A missão final exige que o grupo aja em duas frentes para proteger os acampamentos e o mundo.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-heroes-of-olympus/','https://rickriordan.com/series/the-heroes-of-olympus/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Oráculo Oculto','Rick Riordan','Fantasia','As Provações de Apolo','Depois de provocar a ira de Zeus, Apolo é lançado à Terra na forma de um adolescente mortal. Para recuperar seu lugar no Olimpo, ele precisa ajudar Meg McCaffrey e descobrir por que os oráculos foram silenciados.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-trials-of-apollo/','https://rickriordan.com/series/the-trials-of-apollo/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Profecia das Sombras','Rick Riordan','Fantasia','As Provações de Apolo','Ainda preso à vida mortal, Apolo parte em busca de outro oráculo e enfrenta uma missão marcada por enigmas, inimigos antigos e a ameaça de um imperador que deseja controlar as profecias.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-trials-of-apollo/','https://rickriordan.com/series/the-trials-of-apollo/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Labirinto de Fogo','Rick Riordan','Fantasia','As Provações de Apolo','Apolo e Meg seguem até a Califórnia para localizar um novo oráculo escondido em um labirinto. A jornada mistura armadilhas, criaturas perigosas e um adversário que conhece bem o passado do deus.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-trials-of-apollo/','https://rickriordan.com/series/the-trials-of-apollo/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Tumba do Tirano','Rick Riordan','Fantasia','As Provações de Apolo','A caminho do Acampamento Júpiter, Apolo encontra os semideuses romanos sob ameaça dos imperadores. Para protegê-los, terá de enfrentar uma batalha que coloca à prova sua coragem recém-descoberta.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-trials-of-apollo/','https://rickriordan.com/series/the-trials-of-apollo/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Torre de Nero','Rick Riordan','Fantasia','As Provações de Apolo','Na etapa final de sua jornada, Apolo precisa enfrentar Nero e a força que ameaça dominar o Oráculo de Delfos. O retorno à divindade dependerá do que aprendeu sobre amizade, responsabilidade e sacrifício.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/the-trials-of-apollo/','https://rickriordan.com/series/the-trials-of-apollo/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Sol e a Estrela','Rick Riordan e Mark Oshiro','Fantasia','Nico di Angelo','Nico di Angelo e Will Solace recebem uma missão que os leva às profundezas do Tártaro. Para resgatar um amigo, os dois precisam enfrentar criaturas e lembranças ligadas ao lugar mais temido do Mundo Inferior.',79.90,8.00,5,3,NULL,'https://loja.intrinseca.com.br/o-sol-e-a-estrela/','https://loja.intrinseca.com.br/o-sol-e-a-estrela/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Tribunal dos Mortos','Rick Riordan e Mark Oshiro','Fantasia','Nico di Angelo','Nico e Will vão ao Acampamento Júpiter ajudar Hazel a lidar com monstros que procuram refúgio entre os semideuses. Quando essas criaturas começam a desaparecer, o grupo precisa descobrir quem está julgando seres do Mundo Inferior.',69.90,7.00,5,3,NULL,'https://loja.intrinseca.com.br/o-tribunal-do-mortos/','https://loja.intrinseca.com.br/o-tribunal-do-mortos/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Pirâmide Vermelha','Rick Riordan','Fantasia','As Crônicas dos Kane','Carter e Sadie Kane levam vidas muito diferentes, mas uma visita ao Museu Britânico muda tudo. Ao libertar forças antigas, os irmãos descobrem sua ligação com a magia egípcia e precisam impedir que Set destrua o mundo.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/kane-chronicles/','https://rickriordan.com/series/kane-chronicles/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Trono de Fogo','Rick Riordan','Fantasia','As Crônicas dos Kane','Com o caos se aproximando, Carter e Sadie procuram uma forma de despertar Rá, o deus do Sol. A busca por antigos encantamentos os conduz por diferentes lugares e exige que aprendam a controlar poderes cada vez maiores.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/kane-chronicles/','https://rickriordan.com/series/kane-chronicles/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Sombra da Serpente','Rick Riordan','Fantasia','As Crônicas dos Kane','A serpente do caos, Apófis, ameaça escapar de sua prisão e engolir o mundo. Os irmãos Kane precisam reunir aliados, usar a magia egípcia e encontrar uma maneira de enfrentar a força que ameaça tudo.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/kane-chronicles/','https://rickriordan.com/series/kane-chronicles/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Espada do Verão','Rick Riordan','Fantasia','Magnus Chase e os Deuses de Asgard','Após morrer em circunstâncias inesperadas, Magnus Chase desperta em Valhala e descobre que está ligado a uma antiga profecia nórdica. Para impedir o início do Ragnarök, ele precisa encontrar uma espada perdida.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/magnus-chase-and-the-gods-of-asgard/','https://rickriordan.com/series/magnus-chase-and-the-gods-of-asgard/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Martelo de Thor','Rick Riordan','Fantasia','Magnus Chase e os Deuses de Asgard','O martelo de Thor desaparece mais uma vez, e Magnus e seus aliados recebem a tarefa de recuperá-lo. A missão atravessa os Nove Mundos e envolve gigantes, deuses e acordos perigosos.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/magnus-chase-and-the-gods-of-asgard/','https://rickriordan.com/series/magnus-chase-and-the-gods-of-asgard/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Navio dos Mortos','Rick Riordan','Fantasia','Magnus Chase e os Deuses de Asgard','Com o Ragnarök se aproximando, Magnus precisa impedir que Loki comande o navio dos mortos. A tripulação reúne aliados improváveis e parte para uma jornada decisiva pelos mares do mundo nórdico.',69.90,7.00,5,3,NULL,'https://rickriordan.com/series/magnus-chase-and-the-gods-of-asgard/','https://rickriordan.com/series/magnus-chase-and-the-gods-of-asgard/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Cálice dos Deuses','Rick Riordan','Fantasia','Percy Jackson e os Olimpianos — Novas Aventuras','Percy deseja uma rotina tranquila para conseguir as recomendações necessárias à entrada na faculdade. Mas, antes disso, precisa ajudar Ganimedes a recuperar um cálice divino roubado, ao lado de Annabeth e Grover.',69.90,7.00,5,3,NULL,'https://intrinseca.com.br/livro/o-calice-dos-deuses/','https://intrinseca.com.br/livro/o-calice-dos-deuses/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Fúria da Deusa Tríplice','Rick Riordan','Fantasia','Percy Jackson e os Olimpianos — Novas Aventuras','Para conquistar outra recomendação universitária, Percy aceita cuidar dos animais mágicos de Hécate durante sua ausência. A tarefa aparentemente simples se transforma em uma sucessão de problemas sobrenaturais.',69.90,7.00,5,3,NULL,'https://loja.intrinseca.com.br/a-furia-da-deusa-triplice-serie-percy-jackson-e-os-olimpianos/','https://loja.intrinseca.com.br/a-furia-da-deusa-triplice-serie-percy-jackson-e-os-olimpianos/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Sociedade do Anel','J.R.R. Tolkien','Fantasia épica','O Senhor dos Anéis','Frodo recebe a missão de levar o Um Anel para longe do Condado e impedir que Sauron recupere seu poder. Uma sociedade formada por representantes de diferentes povos parte em uma jornada perigosa pela Terra-média.',79.90,8.00,5,3,NULL,'https://harpercollins.com.br/','https://www.ufmg.br/festadolivro/wp-content/uploads/2026/02/lista-precos-harpercollins.pdf',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('As Duas Torres','J.R.R. Tolkien','Fantasia épica','O Senhor dos Anéis','Após a separação da Sociedade, diferentes grupos seguem caminhos decisivos. Frodo e Sam avançam em direção a Mordor, enquanto seus companheiros tentam resistir às forças que se espalham pela Terra-média.',79.90,8.00,5,3,NULL,'https://harpercollins.com.br/','https://www.ufmg.br/festadolivro/wp-content/uploads/2026/02/lista-precos-harpercollins.pdf',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Retorno do Rei','J.R.R. Tolkien','Fantasia épica','O Senhor dos Anéis','A guerra contra Sauron chega ao momento decisivo. Enquanto os povos livres se preparam para a batalha final, Frodo e Sam enfrentam os últimos obstáculos para destruir o Um Anel.',79.90,8.00,5,3,NULL,'https://harpercollins.com.br/','https://www.ufmg.br/festadolivro/wp-content/uploads/2026/02/lista-precos-harpercollins.pdf',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Hobbit','J.R.R. Tolkien','Fantasia épica','Terra-média','Bilbo Bolseiro deixa o conforto de sua toca para acompanhar um grupo de anões em uma expedição para recuperar um tesouro guardado pelo dragão Smaug. No caminho, encontra criaturas, enigmas e um anel inesperado.',74.90,7.00,5,3,NULL,'https://harpercollins.com.br/','https://www.ufmg.br/festadolivro/wp-content/uploads/2026/02/lista-precos-harpercollins.pdf',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A História Secreta','Donna Tartt','Ficção literária','Romances contemporâneos','Um grupo restrito de estudantes de grego clássico em uma faculdade da Nova Inglaterra se envolve em um acontecimento violento. A narrativa acompanha a amizade, o segredo e a culpa que passam a definir a vida dos envolvidos.',114.90,11.00,5,3,NULL,'https://www.companhiadasletras.com.br/livro/9786559210466/a-historia-secreta-nova-edicao','https://www.companhiadasletras.com.br/livro/9786559210466/a-historia-secreta-nova-edicao',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Espadachim de Carvão','Affonso Solano','Fantasia brasileira','O Espadachim de Carvão','Em Kurgala, mundo abandonado por quatro deuses, Adapak é filho de uma dessas divindades e passa a ser caçado por assassinos. Forçado a deixar a ilha onde cresceu, precisa atravessar terras hostis e descobrir por que se tornou alvo.',59.90,6.00,5,3,NULL,'https://sagaspedia.com/o-espadachim-de-carvao/','https://www.estantevirtual.com.br/busca?autor=solano--affonso',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Espadachim de Carvão e as Pontes de Puzur','Affonso Solano','Fantasia brasileira','O Espadachim de Carvão','Enquanto tenta se adaptar ao mundo dos mortais, Adapak encontra um diário que revela a jornada de Puzur. O relato amplia a história de Kurgala e mostra como acontecimentos do passado influenciam o destino do espadachim.',59.90,6.00,5,3,NULL,'https://sagaspedia.com/o-espadachim-de-carvao/','https://www.estantevirtual.com.br/busca?autor=solano--affonso',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('O Espadachim de Carvão e a Voz do Guardião Cego','Affonso Solano','Fantasia brasileira','O Espadachim de Carvão','Adapak se vê envolvido em uma trama religiosa quando uma seita passa a associá-lo ao retorno de seu profeta. Entre perseguições e crenças perigosas, o espadachim precisa lidar com o papel que outros tentam impor a ele.',59.90,6.00,5,3,NULL,'https://sagaspedia.com/o-espadachim-de-carvao/','https://sagaspedia.com/o-espadachim-de-carvao/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('Drácula','Bram Stoker','Terror clássico','Clássicos do horror','Por meio de diários, cartas e registros, um grupo acompanha a ameaça do conde Drácula, um vampiro que deixa a Transilvânia e passa a perseguir novas vítimas na Inglaterra. Jonathan e Mina Harker se unem a Van Helsing para enfrentá-lo.',84.90,8.00,5,3,NULL,'https://n.companhiadasletras.com.br/livro/9788537816196/','https://n.companhiadasletras.com.br/livro/9788537816196/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('Frankenstein','Mary Shelley','Terror clássico','Clássicos do horror','Obcecado por ultrapassar os limites da ciência, Victor Frankenstein consegue dar vida a uma criatura feita de partes humanas. Horrorizado com o resultado, abandona sua criação, que passa a buscar respostas e a confrontar seu criador.',59.90,6.00,5,3,NULL,'https://www.companhiadasletras.com.br/livro/9788537818589/frankenstein-edicao-bolso-de-luxo','https://www.companhiadasletras.com.br/livro/9788537818589/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('Noites Brancas','Fiódor Dostoiévski','Literatura clássica','Clássicos russos','Durante quatro noites claras de verão em São Petersburgo, um jovem solitário conhece Nástienka. Entre conversas e confidências, ele se apaixona, embora ela espere o retorno de outro homem.',44.90,5.00,5,3,NULL,'https://faroeditorial.com.br/produto/noites-brancas/','https://edipro.com.br/livro/noites-brancas/',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('A Metamorfose','Franz Kafka','Literatura clássica','Clássicos modernos','Gregor Samsa desperta transformado em um inseto monstruoso e passa a enfrentar o afastamento da família e a perda de seu lugar no mundo. A narrativa explora isolamento, responsabilidade e desumanização.',64.90,6.00,5,3,NULL,'https://www.darksidebooks.com.br/livros/ficcao/medo-classico?map=c%2Cc%2Cft','https://www.darksidebooks.com.br/livros/ficcao/medo-classico?map=c%2Cc%2Cft',1);

INSERT INTO livros (titulo,autor,categoria,colecao,sinopse,preco_venda,valor_aluguel,estoque_venda,estoque_aluguel,imagem,fonte_sinopse,fonte_preco,ativo) VALUES ('Os Livros da Magia','Neil Gaiman','HQ / Fantasia','Quadrinhos','Timothy Hunter é um adolescente que descobre ter uma ligação extraordinária com a magia. Guiado por quatro magos, percorre mundos e épocas para conhecer as possibilidades e os perigos do universo mágico.',99.90,10.00,5,3,NULL,'https://panini.com.br/os-livros-da-magia-almag001','https://panini.com.br/os-livros-da-magia-almag001',1);


-- Dados de demonstração para testar a área do cliente:
-- A locação de Mariana está ativa e vencida há 3 dias; a multa é sincronizada automaticamente.
INSERT INTO alugueis (usuario_id, livro_id, titulo_snapshot, status, valor_aluguel, data_reserva, data_retirada, data_prevista_devolucao)
SELECT u.id, l.id, l.titulo, 'ativo', l.valor_aluguel,
       DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL 3 DAY)
FROM usuarios u CROSS JOIN livros l
WHERE u.email='mariana.alves@example.com' AND l.titulo='Noites Brancas' LIMIT 1;

INSERT INTO alugueis (usuario_id, livro_id, titulo_snapshot, status, valor_aluguel, data_reserva)
SELECT u.id, l.id, l.titulo, 'reservado', l.valor_aluguel, NOW()
FROM usuarios u CROSS JOIN livros l
WHERE u.email='joao.martins@example.com' AND l.titulo='O Hobbit' LIMIT 1;

INSERT INTO compras (usuario_id,total,status,data_compra)
SELECT id, 139.80, 'concluido', DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM usuarios WHERE email='lucas.ferreira@example.com';
INSERT INTO compra_itens (compra_id,livro_id,titulo_snapshot,preco_unitario,quantidade,subtotal)
SELECT c.id,l.id,l.titulo,l.preco_venda,2,l.preco_venda*2
FROM compras c JOIN livros l ON l.titulo='O Ladrão de Raios'
JOIN usuarios u ON u.id=c.usuario_id WHERE u.email='lucas.ferreira@example.com' LIMIT 1;
UPDATE livros SET estoque_venda=GREATEST(estoque_venda-2,0) WHERE titulo='O Ladrão de Raios';

