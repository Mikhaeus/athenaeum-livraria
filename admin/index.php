<?php
require_once __DIR__.'/core/bootstrap.php';require_admin();
try{(new Multa())->atualizarPendencias();}catch(Throwable $e){error_log($e->getMessage());}
$secao=(string)($_GET['secao']??'painel');$permitidas=['painel','livros','livro_form','usuarios','usuario_form','usuario_detalhes','compras','alugueis','multas'];if(!in_array($secao,$permitidas,true))$secao='painel';
$L=new Livro();$U=new Usuario();$C=new Compra();$A=new Aluguel();$M=new Multa();$pdo=db();
$stats=['livros'=>(int)$pdo->query("SELECT COUNT(*) FROM livros WHERE ativo=1")->fetchColumn(),'usuarios'=>(int)$pdo->query("SELECT COUNT(*) FROM usuarios WHERE ativo=1 AND tipo='usuario'")->fetchColumn(),'compras'=>(int)$pdo->query("SELECT COUNT(*) FROM compras WHERE status<>'cancelado'")->fetchColumn(),'alugueis'=>(int)$pdo->query("SELECT COUNT(*) FROM alugueis WHERE status IN ('reservado','ativo')")->fetchColumn(),'multas'=>(float)$pdo->query("SELECT COALESCE(SUM(valor),0) FROM multas WHERE status='pendente'")->fetchColumn()];
$livros=$L->listarTodos();$usuarios=$U->listar();$compras=$C->listar();$alugueis=$A->listar();$multas=$M->listar();
$livroEdit=isset($_GET['id'])?$L->buscarPorId((int)$_GET['id']):null;$usuarioEdit=isset($_GET['id'])?$U->buscarPorId((int)$_GET['id']):null;
$usuarioDetalhe=null;$detalheCompras=[];$detalheAlugueis=[];$detalheMultas=[];
if($secao==='usuario_detalhes'){$usuarioDetalhe=$U->buscarPorId((int)($_GET['id']??0));if($usuarioDetalhe){$detalheCompras=$C->listar((int)$usuarioDetalhe['id']);$detalheAlugueis=$A->listar((int)$usuarioDetalhe['id']);$detalheMultas=$M->listar((int)$usuarioDetalhe['id']);}}
include __DIR__.'/partials/admin_header.php';
$view=__DIR__.'/views/admin/'.$secao.'.php';include $view;
include __DIR__.'/partials/admin_footer.php';
