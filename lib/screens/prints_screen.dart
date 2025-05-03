import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/print_data.dart';
import '../providers/print_provider.dart';
import '../widgets/main_drawer.dart';
import 'add_print_screen.dart';
import 'edit_print_screen.dart';

class PrintsScreen extends StatefulWidget {
  const PrintsScreen({Key? key}) : super(key: key);

  @override
  State<PrintsScreen> createState() => _PrintsScreenState();
}

class _PrintsScreenState extends State<PrintsScreen> {
  bool _showOnlyNotYetPrinted = true; // Default filter is "Not Yet Printed"

  @override
  void initState() {
    super.initState();
    Provider.of<PrintProvider>(context, listen: false).refreshPrints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressões'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ALL'),
              Switch(
                value: !_showOnlyNotYetPrinted,
                onChanged: (bool value) {
                  setState(() {
                    _showOnlyNotYetPrinted = !value;
                  });
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPrintScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const MainDrawer(), // Add the Drawer here
      body: Consumer<PrintProvider>(
        builder: (context, printProvider, child) {
          List<Print> filteredPrints = _showOnlyNotYetPrinted
              ? printProvider.prints.where((print) =>
              print.products.every((product) => product.failures == -1)).toList()
              : printProvider.prints;

          return ListView.builder(
            itemCount: filteredPrints.length,
            itemBuilder: (context, index) {
              final print = filteredPrints[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arquivo: ${print.file}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Impressora: ${print.printer}'),
                      Text('Data e Hora: ${print.dateTime.toString()}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPrintScreen(print: print),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}