<?php
declare(strict_types=1);
if (session_status() !== PHP_SESSION_ACTIVE) { session_start(); }
date_default_timezone_set('America/Sao_Paulo');
const BASE_URL = '/athenaeum_livraria';
require_once __DIR__.'/../config/conexao.php';
require_once __DIR__.'/../dao/LivroDAO.php';
require_once __DIR__.'/../dao/UsuarioDAO.php';
require_once __DIR__.'/../dao/CompraDAO.php';
require_once __DIR__.'/../dao/AluguelDAO.php';
require_once __DIR__.'/../dao/MultaDAO.php';
require_once __DIR__.'/../models/Livro.php';
require_once __DIR__.'/../models/Usuario.php';
require_once __DIR__.'/../models/Compra.php';
require_once __DIR__.'/../models/Aluguel.php';
require_once __DIR__.'/../models/Multa.php';
function url(string $path=''): string { return BASE_URL.'/'.ltrim($path,'/'); }
function h($v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
function money($v): string { return 'R$ '.number_format((float)$v,2,',','.'); }
function csrf_token(): string { if(empty($_SESSION['csrf'])) $_SESSION['csrf']=bin2hex(random_bytes(32)); return $_SESSION['csrf']; }
function csrf_field(): string { return '<input type="hidden" name="csrf" value="'.h(csrf_token()).'">'; }
function verify_csrf(): void { if(!hash_equals((string)($_SESSION['csrf']??''),(string)($_POST['csrf']??''))) { http_response_code(419); exit('Sessão expirada. Volte e tente novamente.'); } }
function flash(string $key, ?string $message=null): ?string { if($message!==null){$_SESSION['flash'][$key]=$message;return null;} $v=$_SESSION['flash'][$key]??null; unset($_SESSION['flash'][$key]); return $v; }
function redirect(string $path): never { header('Location: '.url($path)); exit; }
function current_user(): ?array { return $_SESSION['usuario']??null; }
function is_logged_in(): bool { return current_user()!==null; }
function is_admin(): bool { return is_logged_in() && (current_user()['tipo']??'')==='admin'; }
function require_login(): void { if(!is_logged_in()){flash('erro','Entre na sua conta para continuar.');redirect('index.php?pagina=login');} }
function require_admin(): void { if(!is_admin()){flash('erro','Acesso restrito ao administrador.');redirect('index.php');} }
function excerpt(string $s,int $n=150): string { $s=trim($s); return strlen($s)>$n?substr($s,0,$n-3).'…':$s; }
function cover(array $book): string { $f=(string)($book['imagem']??''); $p=__DIR__.'/../../public/imagens/'.$f; return $f!=='' && is_file($p)?url('public/imagens/'.rawurlencode($f)):''; }
function status_label(string $s): string { return ['confirmado'=>'Confirmado','separando'=>'Separando','concluido'=>'Concluído','cancelado'=>'Cancelado','reservado'=>'Aguardando retirada','ativo'=>'Alugado','devolvido'=>'Devolvido','pendente'=>'Pendente','paga'=>'Paga'][strtolower($s)]??ucfirst($s); }
