<?php
class Compra { private CompraDAO $dao; public function __construct(){ $this->dao=new CompraDAO(db()); }
 public function listar(?int $uid=null):array{return $this->dao->listar($uid);} public function buscarPorId(int $id):?array{return $this->dao->buscarPorId($id);} public function cadastrar(array $d):int{return $this->dao->finalizar((int)$d['usuario_id'],$d['carrinho']??[]);} public function editar(int $id,array $d):bool{return $this->dao->editar($id,$d);} public function deletar(int $id):bool{return $this->dao->deletar($id);} }
