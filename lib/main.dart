import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // cor de fundo
      elevation: 0, // sem sombra
      iconTheme: const IconThemeData(color: Colors.black), // cor dos ícones
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            // ação do botão de notificação
          },
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openEndDrawer(); // abre o Drawer lateral
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LembretesScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
    );
  }
}

class LembretesScreen extends StatefulWidget {
  const LembretesScreen({super.key});

  @override
  State<LembretesScreen> createState() => _LembretesScreenState();
}

class _LembretesScreenState extends State<LembretesScreen> {
  final List<String> meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  String mesAtual = 'Fevereiro';
  String termoDePesquisa = '';

  final Map<String, List<Map<String, dynamic>>> examesPorMes = {
    'Janeiro': [],
    'Fevereiro': [
      {
        'dia': 14,
        'exames': [
          {
            'nome': 'Exame de Sangue Completo',
            'concluido': false,
            'observacao': '',
            'recorrencia': 'Mensal',
          },
          {
            'nome': 'Exame de CU Completo',
            'concluido': false,
            'observacao': '',
            'recorrencia': 'Mensal',
          },
        ],
      },
      {
        'dia': 25,
        'exames': [
          {
            'nome': 'Exame de Prostata Completo',
            'concluido': false,
            'observacao': '',
            'recorrencia': 'Mensal',
          },
        ],
      },
      {
        'dia': 26,
        'exames': [
          {
            'nome': 'Exame de Sangue Completo',
            'concluido': false,
            'observacao': '',
            'recorrencia': 'Mensal',
          },
          {
            'nome': 'Exame de Prostata Completo',
            'concluido': false,
            'observacao': '',
            'recorrencia': 'Mensal',
          },
        ],
      },
      {
        'dia': 28,
        'exames': [
          {
            'nome': 'Exame de Prostata Completo',
            'concluido': false,
            'observacao': '',
            'recorrencia': 'Mensal',
          },
        ],
      },
    ],
    'Março': [],
    'Abril': [],
    'Maio': [],
    'Junho': [],
    'Julho': [],
    'Agosto': [],
    'Setembro': [],
    'Outubro': [],
    'Novembro': [],
    'Dezembro': [],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> examesDoMes = examesPorMes[mesAtual] ?? [];
    List<Map<String, dynamic>> examesFiltrados = _filtrarExames(examesDoMes);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50), // Adiciona um espaço para o status bar
            _buildMonthSelector(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exames',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    _showAddExamDialog(context);
                  },
                  icon: const Icon(Icons.add_circle, color: Color(0xFF1A75B4)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (examesFiltrados.isEmpty)
              const Center(
                child: Text(
                  'Nenhum resultado encontrado.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              ...List.generate(examesFiltrados.length, (diaIndex) {
                final item = examesFiltrados[diaIndex];
                final examesDoDia = item['exames'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDia(item['dia']),
                    const SizedBox(height: 8),
                    ...List.generate(examesDoDia.length, (exameIndex) {
                      final exame = examesDoDia[exameIndex];
                      return _buildExameCard(
                        exame['nome'],
                        exame['concluido'],
                        () => _toggleChecklist(diaIndex, exameIndex),
                        // A função onEdit agora é passada para o nome
                        () => _showEditDialog(context, diaIndex, exameIndex),
                        () => _removeExame(diaIndex, exameIndex),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  // Ação para "Ver Mais"
                },
                child: const Text(
                  'Ver Mais',
                  style: TextStyle(
                    color: Color(0xFF1A75B4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    int mesIndex = meses.indexOf(mesAtual);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMonthButton(
            meses[(mesIndex - 1 + meses.length) % meses.length],
            isSelected: false,
            onTap: () =>
                _changeMonth((mesIndex - 1 + meses.length) % meses.length),
          ),
          _buildMonthButton(meses[mesIndex], isSelected: true, onTap: () {}),
          _buildMonthButton(
            meses[(mesIndex + 1) % meses.length],
            isSelected: false,
            onTap: () => _changeMonth((mesIndex + 1) % meses.length),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthButton(
    String text, {
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A75B4) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            termoDePesquisa = value;
          });
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Pesquisa',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDia(int dia) {
    return Text(
      'Dia $dia',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildExameCard(
    String nome,
    bool concluido,
    VoidCallback onToggle,
    VoidCallback onEdit, // Esta é a função que será chamada ao tocar no nome
    VoidCallback onRemove,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Checkbox(
            value: concluido,
            onChanged: (bool? newValue) => onToggle(),
            activeColor: const Color(0xFF1A75B4),
            side: const BorderSide(color: Color(0xFF1A75B4)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              // Adicionado GestureDetector aqui
              onTap: onEdit, // Chamada da função onEdit ao tocar no nome
              child: Text(
                nome,
                style: TextStyle(
                  fontSize: 16,
                  decoration: concluido
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filtrarExames(List<Map<String, dynamic>> exames) {
    if (termoDePesquisa.isEmpty) {
      return exames;
    }

    final termoLowerCase = termoDePesquisa.toLowerCase();

    List<Map<String, dynamic>> resultados = [];

    for (var dia in exames) {
      final examesDoDiaFiltrados = (dia['exames'] as List<dynamic>).where((
        exame,
      ) {
        return (exame['nome'] as String).toLowerCase().contains(termoLowerCase);
      }).toList();

      if (examesDoDiaFiltrados.isNotEmpty) {
        resultados.add({'dia': dia['dia'], 'exames': examesDoDiaFiltrados});
      }
    }
    return resultados;
  }

  void _changeMonth(int newIndex) {
    setState(() {
      mesAtual = meses[newIndex];
    });
  }

  void _toggleChecklist(int diaIndex, int exameIndex) {
    setState(() {
      final List<Map<String, dynamic>> examesDoMes =
          examesPorMes[mesAtual] ?? [];
      final examesFiltrados = _filtrarExames(examesDoMes);

      if (diaIndex >= examesFiltrados.length ||
          exameIndex >= examesFiltrados[diaIndex]['exames'].length) {
        return;
      }

      final itemFiltrado = examesFiltrados[diaIndex];
      final exameFiltrado = itemFiltrado['exames'][exameIndex];

      final diaOriginal = examesDoMes.firstWhereOrNull(
        (dia) => dia['dia'] == itemFiltrado['dia'],
      );

      if (diaOriginal != null) {
        final exameOriginal = (diaOriginal['exames'] as List<dynamic>?)
            ?.firstWhereOrNull(
              (exame) => exame['nome'] == exameFiltrado['nome'],
            );

        if (exameOriginal != null) {
          exameOriginal['concluido'] = !exameOriginal['concluido'];
        }
      }
    });
  }

  void _removeExame(int diaIndex, int exameIndex) {
    setState(() {
      final List<Map<String, dynamic>> examesDoMes =
          examesPorMes[mesAtual] ?? [];
      final examesFiltrados = _filtrarExames(examesDoMes);

      if (diaIndex >= examesFiltrados.length ||
          exameIndex >= examesFiltrados[diaIndex]['exames'].length) {
        return;
      }

      final itemFiltrado = examesFiltrados[diaIndex];
      final exameFiltrado = itemFiltrado['exames'][exameIndex];
      final diaOriginal = examesDoMes.firstWhereOrNull(
        (dia) => dia['dia'] == itemFiltrado['dia'],
      );

      if (diaOriginal != null) {
        (diaOriginal['exames'] as List<dynamic>?)?.removeWhere(
          (exame) => exame['nome'] == exameFiltrado['nome'],
        );

        if ((diaOriginal['exames'] as List<dynamic>?)?.isEmpty ?? false) {
          examesDoMes.removeWhere((dia) => dia['dia'] == diaOriginal['dia']);
        }
      }
    });
  }

  void _showAddExamDialog(BuildContext context) {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController diaController = TextEditingController();
    final TextEditingController observacaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Exame'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Exame'),
              ),
              TextField(
                controller: diaController,
                decoration: const InputDecoration(labelText: 'Dia (ex: 14)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: observacaoController,
                decoration: const InputDecoration(
                  labelText: 'Observação (Opcional)',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final nome = nomeController.text;
                final dia = int.tryParse(diaController.text);
                final observacao = observacaoController.text;
                if (nome.isNotEmpty && dia != null) {
                  _addExame(nome, dia, observacao: observacao);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _addExame(
    String nome,
    int dia, {
    String observacao = '',
    String recorrencia = 'Mensal',
  }) {
    setState(() {
      final List<Map<String, dynamic>> examesDoMes =
          examesPorMes[mesAtual] ?? [];
      final diaExistenteIndex = examesDoMes.indexWhere(
        (item) => item['dia'] == dia,
      );
      if (diaExistenteIndex != -1) {
        examesDoMes[diaExistenteIndex]['exames'].add({
          'nome': nome,
          'concluido': false,
          'observacao': observacao,
          'recorrencia': recorrencia,
        });
      } else {
        examesDoMes.add({
          'dia': dia,
          'exames': [
            {
              'nome': nome,
              'concluido': false,
              'observacao': observacao,
              'recorrencia': recorrencia,
            },
          ],
        });
        examesDoMes.sort((a, b) => a['dia'].compareTo(b['dia']));
      }
    });
  }

  void _showEditDialog(BuildContext context, int diaIndex, int exameIndex) {
    final List<Map<String, dynamic>> examesDoMes = examesPorMes[mesAtual] ?? [];
    final examesFiltrados = _filtrarExames(examesDoMes);

    if (diaIndex >= examesFiltrados.length ||
        exameIndex >= examesFiltrados[diaIndex]['exames'].length) {
      return;
    }

    final exameParaEditar = examesFiltrados[diaIndex]['exames'][exameIndex];

    // Encontrar o exame original para pegar as informações extras
    final diaOriginal = examesDoMes.firstWhereOrNull(
      (dia) => dia['dia'] == examesFiltrados[diaIndex]['dia'],
    );
    final exameOriginal = (diaOriginal!['exames'] as List<dynamic>?)
        ?.firstWhereOrNull((exame) => exame['nome'] == exameParaEditar['nome']);

    final TextEditingController nomeController = TextEditingController(
      text: exameParaEditar['nome'],
    );
    final TextEditingController diaController = TextEditingController(
      text: examesFiltrados[diaIndex]['dia'].toString(),
    );
    final TextEditingController observacaoController = TextEditingController(
      text: exameOriginal?['observacao'] ?? '',
    );
    String recorrenciaSelecionada = exameOriginal?['recorrencia'] ?? 'Mensal';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Detalhes do Exame'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: ${exameParaEditar['nome']}'),
                  const SizedBox(height: 8),
                  Text('Recorrência: $recorrenciaSelecionada'),
                  const SizedBox(height: 8),
                  Text(
                    'Observações: ${exameOriginal?['observacao'] ?? 'Nenhuma observação'}',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showRealEditDialog(
                            context,
                            diaIndex,
                            exameIndex,
                            nomeController.text,
                            diaController.text, // Passando o dia como string
                            observacaoController.text,
                            recorrenciaSelecionada,
                          );
                        },
                        child: const Text(
                          'Editar exame',
                          style: TextStyle(color: Color(0xFF1A75B4)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _removeExame(diaIndex, exameIndex);
                        },
                        child: const Text(
                          'Excluir exame',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRealEditDialog(
    BuildContext context,
    int diaIndex,
    int exameIndex,
    String currentNome,
    String currentDia,
    String currentObservacao,
    String currentRecorrencia,
  ) {
    final TextEditingController nomeController = TextEditingController(
      text: currentNome,
    );
    final TextEditingController diaController = TextEditingController(
      text: currentDia,
    );
    final TextEditingController observacaoController = TextEditingController(
      text: currentObservacao,
    );
    String recorrenciaSelecionada = currentRecorrencia;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Editar Exame'),
              content: SizedBox(
                width: 300, // ou qualquer valor que preferir
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Exame',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: diaController,
                      decoration: const InputDecoration(labelText: 'Dia'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Observações:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 70, // Defina a altura que desejar
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: observacaoController,
                        decoration: const InputDecoration(
                          hintText: 'Nenhuma observação',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('Recorrência do Exame'),
                    Wrap(
                      spacing: 8.0,
                      children: ['Mensal', 'Semanal', 'Anual'].map((
                        recorrencia,
                      ) {
                        return ChoiceChip(
                          label: Text(recorrencia),
                          selected: recorrenciaSelecionada == recorrencia,
                          onSelected: (selected) {
                            setStateSB(() {
                              recorrenciaSelecionada = recorrencia;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    final novoNome = nomeController.text;
                    final novoDia = int.tryParse(diaController.text);
                    final novaObservacao = observacaoController.text;
                    final novaRecorrencia = recorrenciaSelecionada;
                    if (novoNome.isNotEmpty && novoDia != null) {
                      _editExame(
                        diaIndex,
                        exameIndex,
                        novoNome,
                        novoDia,
                        novaObservacao,
                        novaRecorrencia,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editExame(
    int diaIndex,
    int exameIndex,
    String novoNome,
    int novoDia,
    String novaObservacao,
    String novaRecorrencia,
  ) {
    setState(() {
      final List<Map<String, dynamic>> examesDoMes =
          examesPorMes[mesAtual] ?? [];
      final examesFiltrados = _filtrarExames(examesDoMes);

      if (diaIndex >= examesFiltrados.length ||
          exameIndex >= examesFiltrados[diaIndex]['exames'].length) {
        return;
      }

      final itemFiltrado = examesFiltrados[diaIndex];
      final exameFiltrado = itemFiltrado['exames'][exameIndex];
      final diaOriginal = examesDoMes.firstWhereOrNull(
        (dia) => dia['dia'] == itemFiltrado['dia'],
      );

      if (diaOriginal != null) {
        final exameOriginal = (diaOriginal['exames'] as List<dynamic>?)
            ?.firstWhereOrNull(
              (exame) => exame['nome'] == exameFiltrado['nome'],
            );
        if (exameOriginal != null) {
          // Se o dia não mudou, simplesmente edita o exame
          if (diaOriginal['dia'] == novoDia) {
            exameOriginal['nome'] = novoNome;
            exameOriginal['observacao'] = novaObservacao;
            exameOriginal['recorrencia'] = novaRecorrencia;
          } else {
            // Se o dia mudou, remove o exame antigo e adiciona um novo
            _removeExame(diaIndex, exameIndex);
            _addExame(
              novoNome,
              novoDia,
              observacao: novaObservacao,
              recorrencia: novaRecorrencia,
            );
          }
        }
      }
    });
  }
}
