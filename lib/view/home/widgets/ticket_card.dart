import 'package:flutter/material.dart';
import 'package:projeto_final_m02/core/extensions/distance_extension.dart';

import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/view/widgets/info_row.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Text(
                    ticket.clientCode,
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (ticket.distanceKm case final distance?)
                    _DistanceBadge(distanceKm: distance),
                ],
              ),
              const SizedBox(height: 8),
              Text(ticket.clientName, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              InfoRow(
                icon: Icons.report_problem_outlined,
                text: ticket.reportedCategory,
                style: textTheme.bodyMedium?.copyWith(fontWeight: .w600),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.problemDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              InfoRow(
                icon: Icons.place_outlined,
                text: ticket.fullAddress,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.distanceKm});

  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const .symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: .circular(16),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(
            Icons.near_me_outlined,
            size: 16,
            color: colors.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            distanceKm.toDistanceLabel(),
            style: TextStyle(
              color: colors.onPrimaryContainer,
              fontWeight: .w600,
            ),
          ),
        ],
      ),
    );
  }
}
