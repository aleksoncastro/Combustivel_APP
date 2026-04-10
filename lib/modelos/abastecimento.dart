class Abastecimento {
  int? id;
  int veiculoId;
  String nomeVeiculo;
  String posto;
  String tipoCombustivel;
  double litros;
  double valorPorLitro;
  double kmAtual;
  double? kmAnterior;
  String data;

  Abastecimento({
    this.id,
    required this.veiculoId,
    required this.nomeVeiculo,
    required this.posto,
    required this.tipoCombustivel,
    required this.litros,
    required this.valorPorLitro,
    required this.kmAtual,
    this.kmAnterior,
    required this.data,
  });

  double get valorTotal => litros * valorPorLitro;

  double? get mediaConsumo {
    if (kmAnterior == null || kmAnterior! <= 0) return null;
    final km = kmAtual - kmAnterior!;
    if (km <= 0) return null;
    return km / litros;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'veiculoId': veiculoId,
      'nomeVeiculo': nomeVeiculo,
      'posto': posto,
      'tipoCombustivel': tipoCombustivel,
      'litros': litros,
      'valorPorLitro': valorPorLitro,
      'kmAtual': kmAtual,
      'kmAnterior': kmAnterior,
      'data': data,
    };
  }

  factory Abastecimento.fromMap(Map<String, dynamic> map) {
    return Abastecimento(
      id: map['id'] as int?,
      veiculoId: map['veiculoId'] as int,
      nomeVeiculo: map['nomeVeiculo'] as String,
      posto: map['posto'] as String,
      tipoCombustivel: map['tipoCombustivel'] as String,
      litros: (map['litros'] as num).toDouble(),
      valorPorLitro: (map['valorPorLitro'] as num).toDouble(),
      kmAtual: (map['kmAtual'] as num).toDouble(),
      kmAnterior: map['kmAnterior'] != null
          ? (map['kmAnterior'] as num).toDouble()
          : null,
      data: map['data'] as String,
    );
  }
}
