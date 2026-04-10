class Veiculo {
  int? id;
  String nome;
  String modelo;
  String placa;
  String ano;

  Veiculo({
    this.id,
    required this.nome,
    required this.modelo,
    required this.placa,
    required this.ano,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'modelo': modelo,
      'placa': placa,
      'ano': ano,
    };
  }

  factory Veiculo.fromMap(Map<String, dynamic> map) {
    return Veiculo(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      modelo: map['modelo'] as String,
      placa: map['placa'] as String,
      ano: map['ano'] as String,
    );
  }

  @override
  String toString() => '$nome ($modelo - $placa)';
}
