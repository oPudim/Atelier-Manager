import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atelier_manager/models/out_flow_data.dart';
import 'package:atelier_manager/providers/product_provider.dart';
import 'package:atelier_manager/widgets/main_drawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:atelier_manager/screens/event_dialog.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Future<void> _navigateToEventDialog({Event? event}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDialog(initialEvent: event),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtemos a instância do ProductProvider aqui para ter acesso à lista de eventos e aos métodos.
    final productProvider = Provider.of<ProductProvider>(
      context,
    ); // Listen: true aqui porque queremos que a UI atualize

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        actions: [
          IconButton(
            onPressed: () {
              // Chama a função de navegação para criar um novo evento
              _navigateToEventDialog();
            },
            icon: const Icon(Icons.add_circle, size: 36, color: Colors.black54),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const MainDrawer(),
      body: Column(
        // Usamos Column para organizar o calendário e a lista
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              // Retorna uma lista de eventos para o dia dado do ProductProvider
              return productProvider.events.where((event) {
                final eventStartDateOnly = DateTime(
                  event.startDate.year,
                  event.startDate.month,
                  event.startDate.day,
                );
                final eventEndDateOnly = DateTime(
                  event.endDate.year,
                  event.endDate.month,
                  event.endDate.day,
                );
                final dayDateOnly = DateTime(day.year, day.month, day.day);
                return dayDateOnly.isAtSameMomentAs(eventStartDateOnly) ||
                    dayDateOnly.isAtSameMomentAs(eventEndDateOnly) ||
                    (dayDateOnly.isAfter(eventStartDateOnly) &&
                        dayDateOnly.isBefore(eventEndDateOnly));
              }).toList();
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child:
                // Use a lista de eventos diretamente do ProductProvider
                productProvider
                        .events
                        .isEmpty // Verifica se a lista total está vazia
                    ? const Center(child: Text('Nenhum evento encontrado.'))
                    : (_selectedDay == null &&
                        productProvider
                            .events
                            .isEmpty) // Caso o dia não esteja selecionado e a lista total esteja vazia
                    ? const Center(child: Text('Nenhum evento encontrado.'))
                    // Se um dia está selecionado, filtra a lista de eventos
                    : (_selectedDay != null &&
                        filteredEvents(
                          productProvider.events,
                          _selectedDay!,
                        ).isEmpty)
                    ? Center(
                      child: Text('Nenhum evento para a data selecionada.'),
                    )
                    : ListView.builder(
                      itemCount:
                          _selectedDay == null
                              ? productProvider
                                  .events
                                  .length // Se nenhum dia selecionado, mostra todos
                              : filteredEvents(
                                productProvider.events,
                                _selectedDay!,
                              ).length, // Se dia selecionado, mostra filtrados
                      itemBuilder: (context, index) {
                        final event =
                            _selectedDay == null
                                ? productProvider
                                    .events[index] // Usa a lista total
                                : filteredEvents(
                                  productProvider.events,
                                  _selectedDay!,
                                )[index]; // Usa a lista filtrada
                        return Dismissible(
                          // Adiciona funcionalidade de deslizar
                          key: ValueKey(event.id),
                          // Chave única para o Dismissible
                          direction: DismissDirection.endToStart,
                          // Desliza da direita para a esquerda
                          background: Container(
                            // Fundo vermelho ao deslizar
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            // Exibe um diálogo de confirmação antes de excluir
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirmar Exclusão"),
                                  content: Text(
                                    "Tem certeza que deseja excluir o evento '${event.name}'?",
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      // Não excluir
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      // Confirmar exclusão
                                      child: const Text("Excluir"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            productProvider.deleteEvent(event);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Evento "${event.name}" excluído.',
                                ),
                                action: SnackBarAction(
                                  label: 'Desfazer',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Desfazer ainda não implementado.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                // Se houver URL da imagem, use a imagem da rede, senão use a primeira letra do nome
                                backgroundImage:
                                    event.imageUrl.isNotEmpty
                                        ? NetworkImage(event.imageUrl)
                                        : null,
                                child:
                                    event.imageUrl.isEmpty &&
                                            event.name.isNotEmpty
                                        ? Text(
                                          event.name[0].toUpperCase(),
                                        ) // Mostra a primeira letra em maiúsculo
                                        : (event.imageUrl.isEmpty
                                            ? const Icon(Icons.event)
                                            : null), // Ícone genérico se sem nome/imagem
                              ),
                              title: Text(event.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Local: ${event.place}'),
                                  Text(
                                    'Início: ${event.startDate.toLocal().toShortString()}',
                                  ),
                                  Text(
                                    'Fim: ${event.endDate.toLocal().toShortString()}',
                                  ),
                                  Text('Pago: ${event.paid ? 'Sim' : 'Não'}'),
                                  if (event.observations != null &&
                                      event.observations!.isNotEmpty)
                                    Text('Obs: ${event.observations}'),
                                  // Exibir OutFlows associados ao evento (se houver)
                                  if (event.outFlows != null &&
                                      event.outFlows!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // const Text('Saídas de Caixa Associadas:', style: TextStyle(fontWeight: FontWeight.bold)),
                                          // ...event.outFlows!.map((outFlow) => Text('- ${outFlow.description} - ${outFlow.amount.toStringAsFixed(2)}')).toList(),
                                        ],
                                      ),
                                    ),
                                  // Exibir Despesas associadas ao evento (se houver)
                                  if (event.expenses != null &&
                                      event.expenses!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Despesas Associadas:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...event.expenses!.entries
                                              .map(
                                                (entry) => Text(
                                                  '- ${entry.key}: ${entry.value.toStringAsFixed(2)}',
                                                ),
                                              )
                                              .toList(),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                // Chama a função de navegação para editar o evento
                                _navigateToEventDialog(event: event);
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

// Helper function to filter events by selected day
List<Event> filteredEvents(List<Event> events, DateTime selectedDay) {
  return events.where((event) {
    final selectedDayDateOnly = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final eventStartDateOnly = DateTime(
      event.startDate.year,
      event.startDate.month,
      event.startDate.day,
    );
    final eventEndDateOnly = DateTime(
      event.endDate.year,
      event.endDate.month,
      event.endDate.day,
    );
    return selectedDayDateOnly.isAtSameMomentAs(eventStartDateOnly) ||
        selectedDayDateOnly.isAtSameMomentAs(eventEndDateOnly) ||
        (selectedDayDateOnly.isAfter(eventStartDateOnly) &&
            selectedDayDateOnly.isBefore(eventEndDateOnly));
  }).toList();
}

// Existing extensions and helper functions (like toShortString and isSameDay)
extension on DateTime {
  String toShortString() {
    return "${day}/${month}/${year}";
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
