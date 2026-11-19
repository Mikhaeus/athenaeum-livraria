<?php
class Usuario { private UsuarioDAO $dao; public function __construct(){ $this->dao=new UsuarioDAO(db()); }
 public function listar():array{return $this->dao->listar();} public function buscarPorId(int $id):?array{return $this->dao->buscarPorId($id);} public function autenticar(string $e,string $s):?array{return $this->dao->autenticar($e,$s);} public function cadastrar(array $d):int{return $this->dao->cadastrar($d);} public function editar(int $id,array $d):bool{return $this->dao->editar($id,$d);} public function deletar(int $id):bool{return $this->dao->deletar($id);} }
