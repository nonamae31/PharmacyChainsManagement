import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/exceptions.dart';
import '../network/prescription_api_client.dart';
import 'prescription_event.dart';
import 'prescription_state.dart';
class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final PrescriptionApiClient _apiClient;
  PrescriptionBloc({required PrescriptionApiClient apiClient}) : _apiClient = apiClient, super(PrescriptionInitial()) { on<PrescriptionListRequested>(_onListRequested); on<PrescriptionDetailRequested>(_onDetailRequested); }
  Future<void> _onListRequested(PrescriptionListRequested event, Emitter<PrescriptionState> emit) async { emit(PrescriptionLoading()); try { emit(PrescriptionListLoadSuccess(await _apiClient.getPrescriptions())); } on AppException catch (error) { emit(PrescriptionLoadFailure(error.message)); } catch (_) { emit(const PrescriptionLoadFailure('Da co loi khong xac dinh.')); } }
  Future<void> _onDetailRequested(PrescriptionDetailRequested event, Emitter<PrescriptionState> emit) async { emit(PrescriptionLoading()); try { emit(PrescriptionDetailLoadSuccess(await _apiClient.getPrescription(event.prescriptionId))); } on AppException catch (error) { emit(PrescriptionLoadFailure(error.message)); } catch (_) { emit(const PrescriptionLoadFailure('Da co loi khong xac dinh.')); } }
}
