import 'package:flutter/material.dart';

import 'package:projeto_final_m02/core/di/injection.dart';
import 'package:projeto_final_m02/core/routes/app_routes.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/view/history/widgets/history_card.dart';
import 'package:projeto_final_m02/view/shared_widgets/message_state.dart';
import 'package:projeto_final_m02/viewModel/history_view_model.dart';

class HistoryPage extends StatefulWidget {
  final HistoryViewModel? viewModel;

  const HistoryPage({super.key, this.viewModel});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryViewModel _viewModel =
      widget.viewModel ?? getIt<HistoryViewModel>();
  final _searchController = TextEditingController();
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_onViewModelChanged)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.isSessionExpired && !_hasRedirected) {
      _hasRedirected = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sua sessão expirou. Entre novamente.')),
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      return;
    }

    final message = _viewModel.takeFeedbackMessage();
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _viewModel.search('');
  }

  void _openEntry(HistoryEntryModel entry) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pushNamed(AppRoutes.historyDetail, arguments: entry);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Histórico'),
          bottom: _viewModel.isRefreshing
              ? const PreferredSize(
                  preferredSize: .fromHeight(4),
                  child: LinearProgressIndicator(),
                )
              : null,
        ),
        body: Column(
          children: [
            Padding(
              padding: const .fromLTRB(16, 12, 16, 4),
              child: _SearchField(
                controller: _searchController,
                hasQuery: _viewModel.query.isNotEmpty,
                onChanged: _viewModel.search,
                onClear: _clearSearch,
              ),
            ),
            Expanded(
              child: _HistoryList(
                entries: _viewModel.entries,
                hasEntries: _viewModel.hasEntries,
                isLoading: _viewModel.isLoading,
                errorMessage: _viewModel.errorMessage,
                onRefresh: () => _viewModel.refresh(isManual: true),
                onRetry: _viewModel.loadHistory,
                onEntryTap: _openEntry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: .search,
      decoration: InputDecoration(
        hintText: 'Buscar por nº do chamado, código ou cliente',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: hasQuery
            ? IconButton(icon: const Icon(Icons.close), onPressed: onClear)
            : null,
      ),
      onChanged: onChanged,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<HistoryEntryModel> entries;
  final bool hasEntries;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<HistoryEntryModel> onEntryTap;

  const _HistoryList({
    required this.entries,
    required this.hasEntries,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onRetry,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final error = errorMessage;
    if (error != null && !hasEntries) {
      return MessageState(
        icon: Icons.error_outline,
        title: 'Não foi possível carregar o histórico',
        message: error,
        actionLabel: 'Tentar de novo',
        onAction: onRetry,
      );
    }

    if (entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 48),
            hasEntries
                ? const MessageState(
                    icon: Icons.search_off,
                    title: 'Nenhum resultado',
                    message:
                        'Confira o número do chamado ou o código do cliente.',
                  )
                : const MessageState(
                    icon: Icons.history,
                    title: 'Nenhum atendimento concluído',
                    message:
                        'Os atendimentos que você concluir aparecerão aqui.',
                  ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const .fromLTRB(12, 8, 12, 24),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return HistoryCard(entry: entry, onTap: () => onEntryTap(entry));
        },
      ),
    );
  }
}
