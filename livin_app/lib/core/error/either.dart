class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool isLeft;

  const Either._(this._left, this._right, this.isLeft);

  factory Either.left(L left) => Either._(left, null, true);
  factory Either.right(R right) => Either._(null, right, false);

  bool get isRight => !isLeft;
  L get left => _left as L;
  R get right => _right as R;

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return isLeft ? onLeft(_left as L) : onRight(_right as R);
  }
}