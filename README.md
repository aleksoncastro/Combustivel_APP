# Alêkson C. de Souza — Programação Para Dispositivos Móveis I — UNITINS 2026.1
## Tema: *Controle de gastos com combustíveis de seus automóveis*

# ⛽ Combustível App

Aplicativo mobile desenvolvido em **Flutter** para motoristas acompanharem seus gastos com combustível, registrarem abastecimentos e monitorarem o desempenho dos seus veículos.

---

## 📱 Telas do Aplicativo

| Tela | Descrição |
|---|---|
| **Dashboard** | Resumo do mês atual com total gasto, litros abastecidos, média de consumo e quantidade de abastecimentos. Inclui carrossel de destaques deslizável. |
| **Histórico** | Lista completa de todos os abastecimentos com filtro por tipo de combustível. Toque em um item para ver os detalhes completos. |
| **Veículos** | Cadastro e listagem dos veículos do usuário. Cada veículo armazena nome, modelo, placa e ano. |
| **Cadastro de Abastecimento** | Formulário para registrar um novo abastecimento com cálculo automático do valor total e da média de consumo (km/L). |

---

## 🛠️ Tecnologias Utilizadas

- **Flutter** — framework de desenvolvimento mobile multiplataforma
- **Dart** — linguagem de programação
- **shared_preferences** — persistência de dados local em formato JSON
- **Programação Orientada a Objetos (POO)** — modelagem com classes `Veiculo` e `Abastecimento`

---

## ✅ Recursos Implementados

- **Modelagem POO** — classes `Veiculo` e `Abastecimento` com construtores, atributos e métodos de cálculo (`valorTotal`, `mediaConsumo`)
- **Persistência local** — dados salvos com `shared_preferences` e serializados em JSON, mantidos após fechar e reabrir o app
- **Entrada de dados** — `TextField` com `TextEditingController` em todos os formulários
- **Navegação horizontal** — `PageView.builder` no carrossel de destaques do Dashboard
- **Listagem dinâmica** — `ListView.builder` no Histórico e na tela de Veículos
- **Gerenciamento de estado** — `StatefulWidget` com `setState()` para atualização em tempo real
- **Comunicação entre telas** — passagem do objeto `Abastecimento` do Histórico para a tela de Detalhes via `Navigator.push`
- **Feedback ao usuário** — `SnackBar` em todas as ações de salvar e excluir

---

## 📂 Estrutura do Projeto

    lib/
    ├── main.dart                            # Ponto de entrada e navegação principal
    ├── modelos/
    │   ├── veiculo.dart                     # Classe Veiculo
    │   └── abastecimento.dart               # Classe Abastecimento
    ├── database/
    │   └── database_helper.dart             # Camada de persistência (shared_preferences)
    ├── widgets/
    │   ├── texto_formatado_widget.dart      # Texto reutilizável estilizado
    │   ├── header_widget.dart               # AppBar reutilizável
    │   ├── resumo_card_widget.dart          # Card de resumo do Dashboard
    │   ├── abastecimento_card_widget.dart   # Card do ListView de abastecimentos
    │   ├── veiculo_card_widget.dart         # Card do ListView de veículos
    │   └── carrossel_destaques_widget.dart  # PageView.builder com indicadores
    └── telas/
        ├── tela_dashboard.dart              # Tela 1 — Dashboard
        ├── tela_historico.dart              # Tela 2 — Histórico
        ├── tela_detalhe_abastecimento.dart  # Detalhe do abastecimento
        ├── tela_veiculos.dart               # Tela 3 — Veículos
        ├── tela_cadastro_veiculo.dart       # Formulário de veículo
        └── tela_cadastro_abastecimento.dart # Tela 4 — Cadastro de abastecimento

---

## 🚀 Como Executar

**Pré-requisitos:** Flutter SDK instalado e configurado.

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/combustivel_app.git

# Entre na pasta
cd combustivel_app

# Instale as dependências
flutter pub get

# Execute no navegador
flutter run -d chrome

# Ou em um dispositivo Android
flutter run
```

---

## 👨‍💻 Desenvolvido por


