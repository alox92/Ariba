import 'package:dartz/dartz.dart';
import 'package:flashcards_app/domain/failures/failures.dart';

/// Base class for all use cases that return a result
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that don't take parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Base class for use cases that return a stream
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Base class for stream use cases that don't take parameters
abstract class NoParamsStreamUseCase<Type> {
  Stream<Either<Failure, Type>> call();
}

/// No parameters placeholder
class NoParams {
  const NoParams();
}
