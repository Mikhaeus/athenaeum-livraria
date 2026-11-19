<?php
class Multa { private MultaDAO $dao; public function __construct(){ $this->dao=new MultaDAO(db()); }
 public function atualizarPendencias():void{$this->dao->atualizarPendencias();} public function listar(?int $uid=null):array{return $this->dao->listar($uid);} public function buscarPorId(int $id):?array{return $this->dao->buscarPorId($id);} public function cadastrar(array $d):int{return $this->dao->cadastrar($d);} public function editar(int $id,array $d):bool{return $this->dao->editar($id,$d);} public function deletar(int $id):bool{return $this->dao->deletar($id);} }
