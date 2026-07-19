abstract final class StockReplenishmentAppStrings {
  static const requestMedicine = 'Request medicines';
  static const requestMedicineSubtitle =
      'Send a medicine replenishment request to Inventory.';
  static const createRequest = 'Create request';
  static const requestHistory = 'Request history';
  static const noRequests = 'No replenishment requests have been submitted.';
  static const noMedicines = 'No active medicines are available.';
  static const medicine = 'Medicine';
  static const quantity = 'Quantity';
  static const currentStock = 'Current stock';
  static const reorderPoint = 'Reorder point';
  static const priority = 'Priority';
  static const normal = 'Normal';
  static const urgent = 'Urgent';
  static const notes = 'Notes';
  static const optionalNotes = 'Notes (optional)';
  static const addMedicine = 'Add medicine';
  static const removeMedicine = 'Remove medicine';
  static const submitRequest = 'Send request';
  static const requestCreated =
      'The replenishment request was sent to Inventory.';
  static const invalidQuantity = 'Quantity must be between 1 and 100,000.';
  static const duplicateMedicine =
      'This medicine is already included in the request.';
  static const atLeastOneMedicine = 'Add at least one medicine.';
  static const requestNumber = 'Request';
  static const requestedOn = 'Requested on';
  static const requestedBy = 'Requested by';
  static const inventoryQueue = 'Live branch replenishment requests';
  static const inventoryQueueSubtitle =
      'Requests below are loaded from the shared database.';
  static const allStatuses = 'All statuses';
  static const pending = 'Pending';
  static const processing = 'Processing';
  static const fulfilled = 'Fulfilled';
  static const shipped = 'Shipped';
  static const rejected = 'Rejected';
  static const startProcessing = 'Start processing';
  static const dispatchMedicines = 'Dispatch medicines';
  static const selectSource = 'Select source branch';
  static const sourceBranch = 'Source branch';
  static const noDispatchSource =
      'No source branch has enough sellable, non-expired stock for this request.';
  static const dispatchCompleted =
      'Medicines were dispatched. Waiting for the branch to receive them.';
  static const confirmReceived = 'Confirm received';
  static const confirmReceivedTitle = 'Confirm medicine receipt';
  static const confirmReceivedMessage =
      'Confirm that all dispatched medicines were received. Stock will be added immediately.';
  static const receiptConfirmed =
      'Receipt confirmed. Branch inventory was updated.';
  static const sourceLabel = 'From';
  static const dispatchedOn = 'Dispatched on';
  static const receivedOn = 'Received on';
  static const reject = 'Reject';
  static const rejectionReason = 'Rejection reason';
  static const rejectionReasonRequired =
      'Enter a reason before rejecting this request.';
  static const updateNote = 'Inventory note (optional)';
  static const statusUpdated = 'Request status updated.';
  static const refresh = 'Refresh';
  static const retry = 'Retry';
  static const cancel = 'Cancel';
  static const close = 'Close';
  static const dataCannotLoad =
      'Replenishment request data cannot be loaded. Please try again.';
}
