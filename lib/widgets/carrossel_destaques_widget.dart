import 'package:flutter/material.dart';
import 'texto_formatado_widget.dart';

class DestaqueItem {
  final IconData icone;
  final String titulo;
  final String descricao;
  final Color cor;

  const DestaqueItem({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.cor,
  });
}

class CarrosselDestaquesWidget extends StatefulWidget {
  final List<DestaqueItem> itens;

  const CarrosselDestaquesWidget({super.key, required this.itens});

  @override
  State<CarrosselDestaquesWidget> createState() =>
      _CarrosselDestaquesWidgetState();
}

class _CarrosselDestaquesWidgetState extends State<CarrosselDestaquesWidget> {
  int _paginaAtual = 0;
  final PageController _pageController =
      PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.itens.length,
            onPageChanged: (i) => setState(() => _paginaAtual = i),
            itemBuilder: (context, index) {
              final item = widget.itens[index];
              return AnimatedScale(
                scale: _paginaAtual == index ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [item.cor, item.cor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: item.cor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(item.icone, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextoFormatado(
                              texto: item.titulo,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextoFormatado(
                              texto: item.descricao,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Indicadores de página
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.itens.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _paginaAtual == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _paginaAtual == i
                    ? const Color(0xFF1565C0)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
