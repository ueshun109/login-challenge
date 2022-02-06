public enum LoadingState {
    case idle
    case loading
    case loaded
    case failed(error: Error, message: ErrorMessage)
}
