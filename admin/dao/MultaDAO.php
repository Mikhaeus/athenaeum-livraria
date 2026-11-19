<?php
class MultaDAO {
 public function __construct(private PDO $pdo){}
 public function atualizarPendencias(): void {
  $sql = "INSERT INTO multas(aluguel_id,usuario_id,dias_atraso,valor,status,data_calculo)
   SELECT a.id,a.usuario_id,
          GREATEST(DATEDIFF(DATE(COALESCE(a.data_devolucao,NOW())),a.data_prevista_devolucao),0),
          GREATEST(DATEDIFF(DATE(COALESCE(a.data_devolucao,NOW())),a.data_prevista_devolucao),0)*2.00,
          'pendente',NOW()
   FROM alugueis a
   WHERE a.status IN ('ativo','devolvido')
     AND a.data_prevista_devolucao IS NOT NULL
     AND DATE(COALESCE(a.data_devolucao,NOW()))>a.data_prevista_devolucao
   ON DUPLICATE KEY UPDATE
     pago_em=IF(status='paga' AND VALUES(valor)>valor,NULL,pago_em),
     status=IF(status='paga' AND VALUES(valor)>valor,'pendente',status),
     dias_atraso=VALUES(dias_atraso),valor=VALUES(valor),data_calculo=NOW()";
  $this->pdo->exec($sql);
 }
 public function listar(?int $usuarioId=null): array { $sql="SELECT m.*,u.nome,u.email,a.titulo_snapshot,a.data_prevista_devolucao FROM multas m JOIN usuarios u ON u.id=m.usuario_id JOIN alugueis a ON a.id=m.aluguel_id";if($usuarioId){$s=$this->pdo->prepare($sql." WHERE m.usuario_id=? ORDER BY m.status,m.data_calculo DESC");$s->execute([$usuarioId]);return $s->fetchAll();}return $this->pdo->query($sql." ORDER BY m.status,m.data_calculo DESC")->fetchAll(); }
 public function buscarPorId(int $id): ?array { $s=$this->pdo->prepare("SELECT * FROM multas WHERE id=?");$s->execute([$id]);return $s->fetch()?:null; }
 public function cadastrar(array $d): int { $s=$this->pdo->prepare("INSERT INTO multas(aluguel_id,usuario_id,dias_atraso,valor,status) VALUES(?,?,?,?,?)");$s->execute([(int)$d['aluguel_id'],(int)$d['usuario_id'],(int)$d['dias_atraso'],(float)$d['valor'],$d['status']??'pendente']);return (int)$this->pdo->lastInsertId(); }
 public function editar(int $id,array $d): bool { if(($d['status']??'')==='paga')return $this->pdo->prepare("UPDATE multas SET status='paga',pago_em=NOW() WHERE id=?")->execute([$id]);return $this->pdo->prepare("UPDATE multas SET status=? WHERE id=?")->execute([in_array($d['status']??'',['pendente','paga','cancelada'],true)?$d['status']:'pendente',$id]); }
 public function deletar(int $id): bool { return $this->pdo->prepare("DELETE FROM multas WHERE id=?")->execute([$id]); }
}
