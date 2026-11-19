<?php
require_once __DIR__.'/../core/bootstrap.php';
if($_SERVER['REQUEST_METHOD']!=='POST'){http_response_code(405);exit('Método não permitido.');}
verify_csrf();
$acao=(string)($_POST['acao']??'');
$retorno=(string)($_POST['retorno']??'index.php');
if(str_starts_with($retorno,'/') || str_contains($retorno,'://')) $retorno='index.php';
try {
 switch($acao){
  case 'login':
   $u=(new Usuario())->autenticar(trim((string)($_POST['email']??'')),(string)($_POST['senha']??''));
   if(!$u)throw new RuntimeException('E-mail ou senha inválidos.');
   session_regenerate_id(true);$_SESSION['usuario']=$u;flash('sucesso','Bem-vindo(a), '.$u['nome'].'!');
   redirect($u['tipo']==='admin'?'admin/index.php':'index.php?pagina=conta');
  case 'cadastro':
   $nome=trim((string)($_POST['nome']??''));$email=trim((string)($_POST['email']??''));$senha=(string)($_POST['senha']??'');
   if($nome===''||!filter_var($email,FILTER_VALIDATE_EMAIL)||strlen($senha)<8)throw new RuntimeException('Preencha nome e e-mail válidos. A senha deve ter pelo menos 8 caracteres.');
   (new Usuario())->cadastrar(['nome'=>$nome,'email'=>$email,'telefone'=>$_POST['telefone']??'','senha'=>$senha,'tipo'=>'usuario']);
   flash('sucesso','Conta criada. Entre para continuar.');redirect('index.php?pagina=login');
  case 'logout':
   $_SESSION=[];session_regenerate_id(true);flash('sucesso','Você saiu da sua conta.');redirect('index.php');
  case 'add_cart':
   $id=(int)($_POST['livro_id']??0);$l=(new Livro())->buscarPorId($id);if(!$l||(int)$l['estoque_venda']<1)throw new RuntimeException('Este livro está sem estoque para venda.');
   $_SESSION['carrinho']??=[];$_SESSION['carrinho'][$id]=min((int)$l['estoque_venda'],(int)($_SESSION['carrinho'][$id]??0)+1);flash('sucesso','Livro adicionado ao carrinho.');redirect('index.php?pagina=carrinho');
  case 'update_cart':
   $_SESSION['carrinho']??=[];foreach(($_POST['quantidade']??[]) as $id=>$q){$id=(int)$id;$q=max(0,(int)$q);$l=(new Livro())->buscarPorId($id);if(!$l||$q===0)unset($_SESSION['carrinho'][$id]);else $_SESSION['carrinho'][$id]=min($q,(int)$l['estoque_venda']);}flash('sucesso','Carrinho atualizado.');redirect('index.php?pagina=carrinho');
  case 'checkout':
   require_login();$id=(new Compra())->cadastrar(['usuario_id'=>current_user()['id'],'carrinho'=>$_SESSION['carrinho']??[]]);unset($_SESSION['carrinho']);flash('sucesso','Pedido registrado com sucesso.');redirect('index.php?pagina=compra_sucesso&id='.$id);
  case 'reserve_rental':
   require_login();$id=(new Aluguel())->cadastrar(['usuario_id'=>current_user()['id'],'livro_id'=>(int)($_POST['livro_id']??0)]);flash('sucesso','Reserva registrada! Aguarde a confirmação da retirada pela loja.');redirect('index.php?pagina=conta#alugueis');
  case 'cancel_reservation':
   require_login();$a=(new Aluguel())->buscarPorId((int)($_POST['id']??0));if(!$a||(int)$a['usuario_id']!==(int)current_user()['id'])throw new RuntimeException('Reserva não encontrada.');(new Aluguel())->editar((int)$a['id'],['status'=>'cancelado']);flash('sucesso','Reserva cancelada.');redirect('index.php?pagina=conta#alugueis');
  case 'save_book':
   require_admin();$id=(int)($_POST['id']??0);$imagem=trim((string)($_POST['imagem_atual']??''));
   if(!empty($_FILES['imagem']['name'])){$f=$_FILES['imagem'];if($f['error']!==UPLOAD_ERR_OK||$f['size']>5*1024*1024)throw new RuntimeException('A imagem deve ter até 5 MB.');$mime=(new finfo(FILEINFO_MIME_TYPE))->file($f['tmp_name']);$ext=['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$mime]??null;if(!$ext)throw new RuntimeException('Use uma imagem JPG, PNG ou WebP.');$imagem='livro_'.bin2hex(random_bytes(6)).'.'.$ext;if(!move_uploaded_file($f['tmp_name'],__DIR__.'/../../public/imagens/'.$imagem))throw new RuntimeException('Não foi possível salvar a imagem.');}
   $d=['titulo'=>trim($_POST['titulo']??''),'autor'=>trim($_POST['autor']??''),'categoria'=>trim($_POST['categoria']??''),'colecao'=>trim($_POST['colecao']??''),'sinopse'=>trim($_POST['sinopse']??''),'preco_venda'=>(float)($_POST['preco_venda']??0),'valor_aluguel'=>(float)($_POST['valor_aluguel']??0),'estoque_venda'=>(int)($_POST['estoque_venda']??0),'estoque_aluguel'=>(int)($_POST['estoque_aluguel']??0),'imagem'=>$imagem,'fonte_sinopse'=>trim($_POST['fonte_sinopse']??''),'fonte_preco'=>trim($_POST['fonte_preco']??'')];
   if($d['titulo']===''||$d['autor']===''||$d['sinopse']===''||$d['preco_venda']<0||$d['valor_aluguel']<0)throw new RuntimeException('Confira os campos obrigatórios do livro.');
   if($id)(new Livro())->editar($id,$d);else (new Livro())->cadastrar($d);flash('sucesso','Livro salvo com sucesso.');redirect('admin/index.php?secao=livros');
  case 'delete_book':
   require_admin();(new Livro())->deletar((int)$_POST['id']);flash('sucesso','Livro removido do catálogo público.');redirect('admin/index.php?secao=livros');
  case 'save_user':
   require_admin();$id=(int)($_POST['id']??0);$d=['nome'=>trim($_POST['nome']??''),'email'=>trim($_POST['email']??''),'telefone'=>trim($_POST['telefone']??''),'tipo'=>'usuario','ativo'=>(int)($_POST['ativo']??1),'senha'=>(string)($_POST['senha']??'')];
   if($d['nome']===''||!filter_var($d['email'],FILTER_VALIDATE_EMAIL))throw new RuntimeException('Informe nome e e-mail válidos.');
   if(!$id&&strlen($d['senha'])<8)throw new RuntimeException('A senha deve ter pelo menos 8 caracteres.');
   if($id){$existente=(new Usuario())->buscarPorId($id);if(!$existente)throw new RuntimeException('Usuário não encontrado.');if($existente['tipo']==='admin'){$d['tipo']='admin';$d['ativo']=1;} (new Usuario())->editar($id,$d);}else (new Usuario())->cadastrar($d);
   flash('sucesso','Usuário salvo.');redirect('admin/index.php?secao=usuarios');
  case 'delete_user':
   require_admin();if((int)$_POST['id']===(int)current_user()['id'])throw new RuntimeException('Você não pode desativar sua própria conta.');(new Usuario())->deletar((int)$_POST['id']);flash('sucesso','Conta desativada.');redirect('admin/index.php?secao=usuarios');
  case 'update_purchase':
   require_admin();(new Compra())->editar((int)$_POST['id'],['status'=>$_POST['status']??'confirmado']);flash('sucesso','Status do pedido atualizado.');redirect('admin/index.php?secao=compras');
  case 'delete_purchase':
   require_admin();(new Compra())->deletar((int)$_POST['id']);flash('sucesso','Pedido cancelado e itens devolvidos ao estoque.');redirect('admin/index.php?secao=compras');
  case 'update_rental':
   require_admin();if(!(new Aluguel())->editar((int)$_POST['id'],['status'=>$_POST['status']??'']))throw new RuntimeException('Transição de aluguel não permitida.');(new Multa())->atualizarPendencias();flash('sucesso','Situação do aluguel atualizada.');redirect('admin/index.php?secao=alugueis');
  case 'delete_rental':
   require_admin();(new Aluguel())->deletar((int)$_POST['id']);flash('sucesso','Registro do aluguel removido.');redirect('admin/index.php?secao=alugueis');
  case 'update_fine':
   require_admin();(new Multa())->editar((int)$_POST['id'],['status'=>$_POST['status']??'pendente']);flash('sucesso','Multa atualizada.');redirect('admin/index.php?secao=multas');
  case 'delete_fine':
   require_admin();(new Multa())->deletar((int)$_POST['id']);flash('sucesso','Multa removida.');redirect('admin/index.php?secao=multas');
  default: throw new RuntimeException('Ação não reconhecida.');
 }
} catch(Throwable $e) {
 error_log('Athenaeum action '.$acao.': '.$e->getMessage());
 flash('erro',$e instanceof PDOException ? 'Não foi possível concluir. Verifique se o e-mail já está cadastrado ou se há registros vinculados.' : $e->getMessage());
 redirect($retorno);
}
