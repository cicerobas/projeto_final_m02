import 'package:flutter/material.dart';
import 'package:projeto_final_m02/core/di/injection.dart';
import 'package:projeto_final_m02/core/routes/app_routes.dart';
import 'package:projeto_final_m02/core/services/location_service.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/view/home/widgets/ticket_card.dart';
import 'package:projeto_final_m02/view/shared_widgets/message_state.dart';
import 'package:projeto_final_m02/viewModel/home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.viewModel});

  final HomeViewModel? viewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel = widget.viewModel ?? getIt<HomeViewModel>();
  late final AppLifecycleListener _lifecycleListener;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _lifecycleListener = AppLifecycleListener(onResume: _viewModel.onAppResumed);
    _viewModel.init();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _viewModel
      ..removeListener(_onViewModelChanged)
      ..dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.isSessionExpired) {
      _redirectToLogin(message: 'Sessão expirada, entre novamente.');
      return;
    }

    final message = _viewModel.takeFeedbackMessage();
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _logout() async {
    await _viewModel.logout();
    if (mounted) _redirectToLogin();
  }

  void _redirectToLogin({String? message}) {
    if (_hasRedirected) return;
    _hasRedirected = true;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  Future<void> _openTicket(TicketModel ticket) async {
    await Navigator.of(context).pushNamed(AppRoutes.serviceReport, arguments: ticket);
    await _viewModel.loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: _HomeTitle(userName: _viewModel.userName),
          actions: [
            _SyncButton(isSyncing: _viewModel.isSyncing, onPressed: _viewModel.synchronize),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.history),
            ),
            PopupMenuButton<void>(
              itemBuilder: (_) => [PopupMenuItem(onTap: _logout, child: const Text('Sair'))],
            ),
          ],
        ),
        body: Column(
          children: [
            if (!_viewModel.isOnline)
              const _StatusBanner(
                icon: Icons.cloud_off_outlined,
                message: 'Você está offline. Exibindo chamados salvos no aparelho.',
              ),
            if (_viewModel.locationIssue case final issue?)
              _LocationBanner(issue: issue, onAction: _viewModel.handleLocationIssue),
            Expanded(
              child: _TicketList(
                tickets: _viewModel.tickets,
                isLoading: _viewModel.isLoading,
                errorMessage: _viewModel.errorMessage,
                isSortedByDistance: _viewModel.isSortedByDistance,
                onRefresh: _viewModel.synchronize,
                onRetry: _viewModel.loadTickets,
                onTicketTap: _openTicket,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTitle extends StatelessWidget {
  final String? userName;

  const _HomeTitle({required this.userName});

  @override
  Widget build(BuildContext context) {
    final firstName = userName?.split(' ').first;

    return Column(
      crossAxisAlignment: .start,
      children: [
        const Text('Meus chamados'),
        if (firstName != null)
          Text(
            'Olá, $firstName',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
          ),
      ],
    );
  }
}

class _SyncButton extends StatelessWidget {
  final bool isSyncing;
  final VoidCallback onPressed;

  const _SyncButton({required this.isSyncing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (isSyncing) {
      return Padding(
        padding: const .all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
        ),
      );
    }

    return IconButton(icon: const Icon(Icons.sync), onPressed: onPressed);
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.issue, required this.onAction});

  final LocationIssue issue;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final (message, actionLabel) = switch (issue) {
      LocationIssue.serviceDisabled => ('GPS desligado. Ative para ordenar os chamados por proximidade.', 'Ativar'),
      LocationIssue.permissionDenied => ('Permita o acesso à localização para ordenar por proximidade.', 'Permitir'),
      LocationIssue.permissionDeniedForever => (
        'Localização bloqueada. Libere o acesso nas configurações do app.',
        'Configurações',
      ),
      LocationIssue.unavailable => ('Não foi possível obter sua localização.', 'Tentar de novo'),
    };

    return _StatusBanner(
      icon: Icons.location_off_outlined,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusBanner({required this.icon, required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = actionLabel;

    return Material(
      color: colors.secondaryContainer,
      child: Padding(
        padding: const .fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Icon(icon, color: colors.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: colors.onSecondaryContainer)),
            ),
            if (label != null) TextButton(onPressed: onAction, child: Text(label)),
          ],
        ),
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  final List<TicketModel> tickets;
  final bool isLoading;
  final String? errorMessage;
  final bool isSortedByDistance;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<TicketModel> onTicketTap;

  const _TicketList({
    required this.tickets,
    required this.isLoading,
    required this.errorMessage,
    required this.isSortedByDistance,
    required this.onRefresh,
    required this.onRetry,
    required this.onTicketTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final error = errorMessage;
    if (error != null && tickets.isEmpty) {
      return MessageState(
        icon: Icons.error_outline,
        title: 'Não foi possível carregar os chamados',
        message: error,
        actionLabel: 'Tentar de novo',
        onAction: onRetry,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: tickets.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                MessageState(
                  icon: Icons.task_alt,
                  title: 'Nenhum chamado em aberto',
                  message: 'Puxe a tela para baixo para buscar novos chamados.',
                ),
              ],
            )
          : ListView.builder(
              padding: const .fromLTRB(12, 8, 12, 24),
              itemCount: tickets.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ListHeader(count: tickets.length, isSortedByDistance: isSortedByDistance);
                }

                final ticket = tickets[index - 1];
                return TicketCard(ticket: ticket, onTap: () => onTicketTap(ticket));
              },
            ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final int count;
  final bool isSortedByDistance;

  const _ListHeader({required this.count, required this.isSortedByDistance});

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? 'chamado em aberto' : 'chamados em aberto';
    final sorting = isSortedByDistance ? ' - ordenados por distância' : '';

    return Padding(
      padding: const .fromLTRB(4, 4, 4, 8),
      child: Text('$count $label$sorting', style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
