import 'dart:io';

import 'package:flutter/material.dart';

import 'package:projeto_final_m02/core/constants/technical_categories.dart';
import 'package:projeto_final_m02/core/di/injection.dart';
import 'package:projeto_final_m02/core/extensions/date_extension.dart';
import 'package:projeto_final_m02/core/extensions/distance_extension.dart';
import 'package:projeto_final_m02/core/services/photo_service.dart';
import 'package:projeto_final_m02/core/utils/form_validators.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/view/widgets/confirm_dialog.dart';
import 'package:projeto_final_m02/view/widgets/info_row.dart';
import 'package:projeto_final_m02/viewModel/service_report_view_model.dart';

class ServiceReportPage extends StatefulWidget {
  final TicketModel ticket;
  final ServiceReportViewModel? viewModel;

  const ServiceReportPage({super.key, required this.ticket, this.viewModel});

  @override
  State<ServiceReportPage> createState() => _ServiceReportPageState();
}

class _ServiceReportPageState extends State<ServiceReportPage> {
  late final ServiceReportViewModel _viewModel =
      widget.viewModel ?? getIt<ServiceReportViewModel>(param1: widget.ticket);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_onViewModelChanged)
      ..dispose();
    super.dispose();
  }

  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  Future<void> _pickPhoto(PhotoSource source) {
    _dismissKeyboard();
    return _viewModel.pickPhoto(source);
  }

  void _onViewModelChanged() {
    final String? message = _viewModel.takeFeedbackMessage();
    if (message != null) _showSnackBar(message, isError: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
          content: Text(message),
        ),
      );
  }

  Future<void> _submit() async {
    _dismissKeyboard();

    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = .onUserInteraction);
      _showSnackBar(
        'Corrija os campos destacados para concluir o atendimento.',
        isError: true,
      );
      return;
    }

    final bool confirmed = await ConfirmDialog.show(
      context,
      title: 'Concluir atendimento?',
      message: 'Essa ação não pode ser desfeita.',
      confirmLabel: 'Concluir',
      cancelLabel: 'Revisar',
    );
    if (!confirmed || !mounted) return;

    final bool saved = await _viewModel.complete();
    if (!saved || !mounted) return;

    _showSnackBar(
      'Atendimento salvo no aparelho. Ele será enviado na próxima sincronização.',
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _pickResolvedAt() async {
    _dismissKeyboard();
    final DateTime current = _viewModel.resolvedAt;

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: _viewModel.earliestResolutionDate,
      lastDate: DateTime.now(),
      helpText: 'Data de conclusão',
    );
    if (date == null || !mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'Horário de conclusão',
    );
    final TimeOfDay selectedTime = time ?? TimeOfDay.fromDateTime(current);

    _viewModel.updateResolvedAt(
      DateTime(
        date.year,
        date.month,
        date.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
    );
  }

  Future<void> _onPopInvoked(bool didPop) async {
    if (didPop || _viewModel.isSaving) return;

    final NavigatorState navigator = Navigator.of(context);
    if (!_viewModel.hasChanges) {
      navigator.pop();
      return;
    }

    final bool leave = await ConfirmDialog.show(
      context,
      title: 'Descartar atendimento?',
      message: 'As informações preenchidas e a foto serão perdidas.',
      confirmLabel: 'Descartar',
      cancelLabel: 'Continuar editando',
    );
    if (!leave) return;

    await _viewModel.discardDraft();
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPopInvoked(didPop),
      child: Scaffold(
        appBar: AppBar(title: const Text('Atendimento')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: SingleChildScrollView(
              padding: const .fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  _TicketHeader(ticket: widget.ticket),
                  const SizedBox(height: 24),
                  Text(
                    'Parecer técnico',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _CategoryField(onChanged: _viewModel.selectCategory),
                  const SizedBox(height: 16),
                  _DescriptionField(onChanged: _viewModel.updateDescription),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) => Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        _ResolvedAtField(
                          value: _viewModel.resolvedAt,
                          onTap: _pickResolvedAt,
                        ),
                        const SizedBox(height: 24),
                        _PhotoField(
                          photoPath: _viewModel.photoPath,
                          isLoading: _viewModel.isPickingPhoto,
                          onPick: _pickPhoto,
                          onRemove: _viewModel.removePhoto,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const .fromLTRB(16, 8, 16, 16),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => _SubmitButton(
                isSaving: _viewModel.isSaving,
                onPressed: _submit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketHeader extends StatelessWidget {
  final TicketModel ticket;

  const _TicketHeader({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              ticket.clientCode,
              style: textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(ticket.clientName, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            InfoRow(icon: Icons.place_outlined, text: ticket.fullAddress),
            if (ticket.distanceKm case final distance?) ...[
              const SizedBox(height: 6),
              InfoRow(
                icon: Icons.near_me_outlined,
                text: '${distance.toDistanceLabel()} de você',
              ),
            ],
            const SizedBox(height: 6),
            InfoRow(
              icon: Icons.schedule,
              text: 'Aberto em ${ticket.createdAt.toDisplayLabel()}',
            ),
            const Divider(height: 24),
            Text(ticket.reportedCategory, style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(ticket.problemDescription, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  final ValueChanged<String?> onChanged;

  const _CategoryField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Categoria técnica *',
        prefixIcon: Icon(Icons.build_outlined),
      ),
      items: TechnicalCategories.values
          .map(
            (category) =>
                DropdownMenuItem(value: category, child: Text(category)),
          )
          .toList(),
      validator: FormValidators.category,
      onChanged: onChanged,
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _DescriptionField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: 4,
      maxLines: 8,
      maxLength: 1000,
      keyboardType: .multiline,
      textCapitalization: .sentences,
      decoration: const InputDecoration(
        labelText: 'Procedimento realizado *',
        hintText: 'Ex: troca do conector e teste de sinal',
        helperText:
            'Mínimo de ${FormValidators.minDescriptionLength} caracteres',
        alignLabelWithHint: true,
      ),
      validator: FormValidators.procedureDescription,
      onChanged: onChanged,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}

class _ResolvedAtField extends StatelessWidget {
  final DateTime value;
  final VoidCallback onTap;

  const _ResolvedAtField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: .circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de conclusão',
          prefixIcon: Icon(Icons.event_outlined),
          suffixIcon: Icon(Icons.edit_calendar_outlined),
        ),
        child: Text(value.toDisplayLabel()),
      ),
    );
  }
}

class _PhotoField extends StatelessWidget {
  final String? photoPath;
  final bool isLoading;
  final ValueChanged<PhotoSource> onPick;
  final VoidCallback onRemove;

  const _PhotoField({
    required this.photoPath,
    required this.isLoading,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final String? path = photoPath;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(
          'Foto do atendimento (opcional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (path != null) ...[
          ClipRRect(
            borderRadius: .circular(12),
            child: Image.file(
              File(path),
              height: 220,
              fit: BoxFit.cover,
              cacheWidth: 800,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (isLoading)
          const Padding(
            padding: .all(12),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onPick(PhotoSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(path == null ? 'Câmera' : 'Nova foto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onPick(PhotoSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
              ),
              if (path != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isSaving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isSaving ? null : onPressed,
      icon: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check),
      label: Text(isSaving ? 'Salvando...' : 'Concluir atendimento'),
    );
  }
}
