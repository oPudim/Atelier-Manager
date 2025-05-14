import 'package:flutter/material.dart';
import 'package:atelier_manager/models/out_flow_data.dart';
import 'package:intl/intl.dart';
import 'package:atelier_manager/services/image_service.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:atelier_manager/providers/product_provider.dart';

class EventDialog extends StatefulWidget {
  final Event? initialEvent;

  const EventDialog({Key? key, this.initialEvent}) : super(key: key);

  @override
  _EventDialogState createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _paid = false;
  final _observationsController = TextEditingController();

  File? _selectedImage;
  String? _imageUrl;
  String? _originalPublicId;

  bool _isUploadingImage = false;
  bool _isSaving = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _nameController.text = widget.initialEvent!.name;
      _placeController.text = widget.initialEvent!.place;
      _startDate = widget.initialEvent!.startDate;
      _endDate = widget.initialEvent!.endDate;
      _paid = widget.initialEvent!.paid;
      _observationsController.text = widget.initialEvent!.observations ?? '';

      if (widget.initialEvent!.imageUrl.isNotEmpty) {
        _imageUrl = widget.initialEvent!.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(
      BuildContext context, {
        required bool isStartDate,
      }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartDate ? _startDate : _endDate,
        ),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStartDate) {
            _startDate = selectedDateTime;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
            }
          } else {
            _endDate = selectedDateTime;
            if (_startDate.isAfter(_endDate)) {
              _startDate = _endDate.subtract(const Duration(hours: 1));
            }
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final File? image = await _imageService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialEvent == null ? 'Criar Novo Evento' : 'Editar Evento',
        ),
        actions: [
          IconButton(
            onPressed: _isSaving
                ? null
                : () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isSaving = true;
                });

                String? finalImageUrl = _imageUrl;

                if (_selectedImage != null) {
                  setState(() {
                    _isUploadingImage = true;
                  });
                  final uploadResult = await _imageService
                      .uploadImageToSupabaseStorage(_selectedImage!);

                  setState(() {
                    _isUploadingImage = false;
                  });

                  if (uploadResult != null) {
                    finalImageUrl = uploadResult;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Erro ao enviar imagem. Não foi possível salvar o evento.',
                        ),
                      ),
                    );
                    setState(() {
                      _isSaving = false;
                    });
                    return;
                  }
                }

                final eventToSave = Event(
                  id: widget.initialEvent?.id ??
                      DateTime.now().toIso8601String(),
                  name: _nameController.text,
                  imageUrl: finalImageUrl ?? '',
                  place: _placeController.text,
                  startDate: _startDate,
                  endDate: _endDate,
                  paid: _paid,
                  observations: _observationsController.text.isNotEmpty
                      ? _observationsController.text
                      : null,
                  outFlows: widget.initialEvent?.outFlows ?? [],
                  expenses: widget.initialEvent?.expenses ?? {},
                );

                try {
                  await productProvider.saveEvent(eventToSave);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Evento salvo com sucesso!'),
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Falha ao salvar evento: ${e.toString()}',
                      ),
                    ),
                  );
                } finally {
                  setState(() {
                    _isSaving = false;
                    _isUploadingImage = false;
                  });
                }
              }
            },
            icon: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Evento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Local'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o local do evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Data e Hora de Início'),
                subtitle: Text(_dateFormat.format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, isStartDate: true),
              ),
              ListTile(
                title: const Text('Data e Hora de Término'),
                subtitle: Text(_dateFormat.format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, isStartDate: false),
              ),
              SwitchListTile(
                title: const Text('Evento Pago'),
                value: _paid,
                onChanged: (bool value) {
                  setState(() {
                    _paid = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Selecionar Imagem'),
                onPressed: _pickImage,
              ),
              if (_selectedImage != null)
                Image.file(_selectedImage!)
              else if (_imageUrl != null)
                Image.network(_imageUrl!),
            ],
          ),
        ),
      ),
    );
  }
}
