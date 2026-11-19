<?php
class UsuarioDAO {
 public function __construct(private PDO $pdo){}
 public function listar(): array { return $this->pdo->query("SELECT id,nome,email,telefone,tipo,ativo,criado_em FROM usuarios ORDER BY nome")->fetchAll(); }
 public function buscarPorId(int $id): ?array { $s=$this->pdo->prepare("SELECT id,nome,email,telefone,tipo,ativo,criado_em FROM usuarios WHERE id=?");$s->execute([$id]);return $s->fetch()?:null; }
 public function buscarPorEmail(string $email): ?array { $s=$this->pdo->prepare("SELECT * FROM usuarios WHERE email=? AND ativo=1");$s->execute([$email]);return $s->fetch()?:null; }
 public function autenticar(string $email,string $senha): ?array { $u=$this->buscarPorEmail($email);if(!$u||!password_verify($senha,$u['senha']))return null;unset($u['senha']);return $u; }
 public function cadastrar(array $d): int { $s=$this->pdo->prepare("INSERT INTO usuarios(nome,email,telefone,senha,tipo,ativo) VALUES(?,?,?,?,?,1)");$s->execute([trim($d['nome']),trim($d['email']),trim($d['telefone']??''),password_hash($d['senha'],PASSWORD_DEFAULT),in_array($d['tipo']??'usuario',['admin','usuario'],true)?$d['tipo']:'usuario']);return (int)$this->pdo->lastInsertId(); }
 public function editar(int $id,array $d): bool { $sql="UPDATE usuarios SET nome=?,email=?,telefone=?,tipo=?,ativo=?";$p=[trim($d['nome']),trim($d['email']),trim($d['telefone']??''),($d['tipo']==='admin'?'admin':'usuario'),(int)($d['ativo']??1)];if(!empty($d['senha'])){$sql.=',senha=?';$p[]=password_hash($d['senha'],PASSWORD_DEFAULT);}$sql.=' WHERE id=?';$p[]=$id;return $this->pdo->prepare($sql)->execute($p); }
 public function deletar(int $id): bool { $s=$this->pdo->prepare("UPDATE usuarios SET ativo=0 WHERE id=? AND tipo<>'admin'");return $s->execute([$id]); }
}
