import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../injection_container.dart';
import '../control/prescription_bloc.dart';
import '../control/prescription_event.dart';
import '../control/prescription_state.dart';
import '../entity/prescription_dto.dart';
import '../../staff_sales/boundary/widgets/staff_workspace_shell.dart';

class PrescriptionListScreen extends StatelessWidget {
  const PrescriptionListScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(create: (_) => sl<PrescriptionBloc>()..add(PrescriptionListRequested()), child: const _PrescriptionListView());
}

class _PrescriptionListView extends StatelessWidget {
  const _PrescriptionListView();
  @override
  Widget build(BuildContext context) => StaffWorkspaceShell(
    title: 'Prescriptions',
    subtitle: 'Review prescription records for your branch.',
    section: StaffWorkspaceSection.prescriptions,
    child: BlocConsumer<PrescriptionBloc, PrescriptionState>(
      listener: (context, state) { if (state is PrescriptionLoadFailure) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); },
      builder: (context, state) {
        if (state is PrescriptionLoading) return const Center(child: CircularProgressIndicator());
        if (state is PrescriptionListLoadSuccess) {
          if (state.prescriptions.isEmpty) return const Center(child: Text('Chua co don thuoc.'));
          return RefreshIndicator(onRefresh: () async => context.read<PrescriptionBloc>().add(PrescriptionListRequested()), child: ListView.separated(padding: const EdgeInsets.all(16), itemCount: state.prescriptions.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (context, index) => _PrescriptionListTile(prescription: state.prescriptions[index], onTap: () => context.push('/staff/prescriptions/${state.prescriptions[index].prescriptionId}'))));
        }
        return const SizedBox.shrink();
      },
    ),
  );
}

class _PrescriptionListTile extends StatelessWidget {
  final PrescriptionListItemDto prescription;
  final VoidCallback onTap;
  const _PrescriptionListTile({required this.prescription, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(onTap: onTap, leading: const Icon(Icons.receipt_long_outlined), title: Text(prescription.customerName), subtitle: Text('${prescription.prescriptionDate} - ${prescription.itemCount} thuoc${prescription.doctorName == null ? '' : '\nBS. ${prescription.doctorName}'}'), trailing: Text(prescription.status)));
}
