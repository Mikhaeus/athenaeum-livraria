<?php
require_once __DIR__.'/admin/core/bootstrap.php';
$livrosModel=new Livro();$comprasModel=new Compra();$alugueisModel=new Aluguel();$multasModel=new Multa();
try{$multasModel->atualizarPendencias();}catch(Throwable $e){error_log('Sync multas: '.$e->getMessage());}
$pagina=(string)($_GET['pagina']??'inicio');$q=trim((string)($_GET['q']??''));$categoria=trim((string)($_GET['categoria']??''));
$livros=[];$livro=null;$categorias=$livrosModel->categorias();$carrinho=$_SESSION['carrinho']??[];$itensCarrinho=[];$totalCarrinho=0;
if(in_array($pagina,['inicio','catalogo'],true)){$livros=$livrosModel->listar($q,$categoria);}
if($pagina==='detalhes'){$livro=$livrosModel->buscarPorId((int)($_GET['id']??0));if(!$livro||!(int)$livro['ativo']){$pagina='nao_encontrado';}}
if($pagina==='carrinho'){
 foreach($carrinho as $id=>$qtd){$l=$livrosModel->buscarPorId((int)$id);if($l&&$l['ativo']){$qtd=min((int)$qtd,(int)$l['estoque_venda']);$itensCarrinho[]=['livro'=>$l,'quantidade'=>$qtd,'subtotal'=>$qtd*(float)$l['preco_venda']];$totalCarrinho+=$qtd*(float)$l['preco_venda'];}}
}
if($pagina==='conta'){
 require_login();$uid=(int)current_user()['id'];$minhasCompras=$comprasModel->listar($uid);$meusAlugueis=$alugueisModel->listar($uid);$minhasMultas=$multasModel->listar($uid);
}
if($pagina==='compra_sucesso'){
 require_login();$pedido=$comprasModel->buscarPorId((int)($_GET['id']??0));if(!$pedido||(int)$pedido['usuario_id']!==(int)current_user()['id']){$pagina='nao_encontrado';}
}
include __DIR__.'/admin/partials/header.php';
$view=__DIR__.'/admin/views/public/'.$pagina.'.php';
if(!is_file($view))$view=__DIR__.'/admin/views/public/nao_encontrado.php';
include $view;
include __DIR__.'/admin/partials/footer.php';
