class LembreteModel {
  String nome;
  bool concluido;
  String observacao;
  String recorrencia;

  LembreteModel({
    required this.nome,
    this.concluido = false,
    this.observacao = '',
    this.recorrencia = 'Mensal',
  });
}
