public enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case failed(error: Error, message: ErrorMessage)
    
    public static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
      switch (lhs, rhs) {
      case (.idle, .idle):
        return true
      case (.loading, .loading):
        return true
      case (.loaded, .loaded):
        return true
      case (let .failed(_, message1), let .failed(_, message2)):
        return message1 == message2
      default:
        return false
      }
    }
}
