import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../injection_container.dart';
import '../control/prescription_bloc.dart';
import '../control/prescription_event.dart';
import '../control/prescription_state.dart';
import '../entity/prescription_dto.dart';
import '../../staff_sales/boundary/widgets/staff_workspace_shell.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final String prescriptionId;
  const PrescriptionDetailScreen({super.key, required this.prescriptionId});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        sl<PrescriptionBloc>()
          ..add(PrescriptionDetailRequested(prescriptionId)),
    child: const _PrescriptionDetailView(),
  );
}

class _PrescriptionDetailView extends StatelessWidget {
  const _PrescriptionDetailView();
  @override
  Widget build(BuildContext context) => StaffWorkspaceShell(
    title: 'Prescription details',
    subtitle: 'Medication and dosage instructions.',
    section: StaffWorkspaceSection.prescriptions,
    child: BlocConsumer<PrescriptionBloc, PrescriptionState>(
      listener: (context, state) {
        if (state is PrescriptionLoadFailure)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
      },
      builder: (context, state) {
        if (state is PrescriptionLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is PrescriptionDetailLoadSuccess)
          return _PrescriptionDetailBody(prescription: state.prescription);
        return const SizedBox.shrink();
      },
    ),
  );
}

class _PrescriptionDetailBody extends StatelessWidget {
  final PrescriptionDto prescription;
  const _PrescriptionDetailBody({required this.prescription});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        prescription.customerName,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      Text('Ngay ke: ${prescription.prescriptionDate}'),
      if (prescription.doctorName != null)
        Text('Bac si: ${prescription.doctorName}'),
      Text('Trang thai: ${prescription.status}'),
      const SizedBox(height: 16),
      Text('Thuoc duoc ke', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ...prescription.items.map((item) => _PrescriptionLineTile(line: item)),
    ],
  );
}

class _PrescriptionLineTile extends StatelessWidget {
  final PrescriptionLineDto line;
  const _PrescriptionLineTile({required this.line});
  @override
  Widget build(BuildContext context) {
    final instructions = [
      line.dosage,
      line.frequency,
      line.duration,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' - ');
    return Card(
      child: ListTile(
        title: Text(line.medicineName),
        subtitle: Text(
          instructions.isEmpty ? 'Khong co huong dan lieu dung' : instructions,
        ),
        trailing: Text('SL: ${line.quantity}'),
      ),
    );
  }
}
