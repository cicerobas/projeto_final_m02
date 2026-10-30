import 'package:flutter/material.dart';
import 'package:projeto_final_m02/core/constants/technical_categories.dart';
import 'package:projeto_final_m02/core/di/injection.dart';
import 'package:projeto_final_m02/core/extensions/date_extension.dart';
import 'package:projeto_final_m02/core/extensions/distance_extension.dart';
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
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = .disabled;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text(
              'Corrija os campos destacados para concluir o atendimento.',
            ),
          ),
        );
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Concluir atendimento?',
      message: 'Essa ação não pode ser desfeita.',
      confirmLabel: 'Concluir',
      cancelLabel: 'Revisar',
    );
    if (!confirmed || !mounted) return;
  }

  Future<void> _pickResolvedAt() async {
    final current = _viewModel.resolvedAt;

    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: _viewModel.earliestResolutionDate,
      lastDate: DateTime.now(),
      helpText: 'Data de conclusão',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'Horário de conclusão',
    );
    final selectedTime = time ?? TimeOfDay.fromDateTime(current);

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
    if (didPop) return;

    final navigator = Navigator.of(context);
    if (!_viewModel.hasChanges) {
      navigator.pop();
      return;
    }

    final leave = await ConfirmDialog.show(
      context,
      title: 'Descartar atendimento?',
      message: 'As informações preenchidas serão perdidas.',
      confirmLabel: 'Descartar',
      cancelLabel: 'Continuar editando',
    );
    if (leave && mounted) navigator.pop();
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
                    builder: (context, _) => _ResolvedAtField(
                      value: _viewModel.resolvedAt,
                      onTap: _pickResolvedAt,
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
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('Concluir atendimento'),
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
