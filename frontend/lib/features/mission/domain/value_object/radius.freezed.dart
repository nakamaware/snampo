// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radius.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Radius {
  int get meters;

  /// Create a copy of Radius
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RadiusCopyWith<Radius> get copyWith =>
      _$RadiusCopyWithImpl<Radius>(this as Radius, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Radius &&
            (identical(other.meters, meters) || other.meters == meters));
  }

  @override
  int get hashCode => Object.hash(runtimeType, meters);

  @override
  String toString() {
    return 'Radius(meters: $meters)';
  }
}

/// @nodoc
abstract mixin class $RadiusCopyWith<$Res> {
  factory $RadiusCopyWith(Radius value, $Res Function(Radius) _then) =
      _$RadiusCopyWithImpl;
  @useResult
  $Res call({int meters});
}

/// @nodoc
class _$RadiusCopyWithImpl<$Res> implements $RadiusCopyWith<$Res> {
  _$RadiusCopyWithImpl(this._self, this._then);

  final Radius _self;
  final $Res Function(Radius) _then;

  /// Create a copy of Radius
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meters = null,
  }) {
    return _then(_self.copyWith(
      meters: null == meters
          ? _self.meters
          : meters // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Radius].
extension RadiusPatterns on Radius {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Radius value)? internal,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Radius() when internal != null:
        return internal(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Radius value) internal,
  }) {
    final _that = this;
    switch (_that) {
      case _Radius():
        return internal(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Radius value)? internal,
  }) {
    final _that = this;
    switch (_that) {
      case _Radius() when internal != null:
        return internal(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int meters)? internal,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Radius() when internal != null:
        return internal(_that.meters);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int meters) internal,
  }) {
    final _that = this;
    switch (_that) {
      case _Radius():
        return internal(_that.meters);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int meters)? internal,
  }) {
    final _that = this;
    switch (_that) {
      case _Radius() when internal != null:
        return internal(_that.meters);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Radius extends Radius {
  const _Radius({required this.meters}) : super._();

  @override
  final int meters;

  /// Create a copy of Radius
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RadiusCopyWith<_Radius> get copyWith =>
      __$RadiusCopyWithImpl<_Radius>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Radius &&
            (identical(other.meters, meters) || other.meters == meters));
  }

  @override
  int get hashCode => Object.hash(runtimeType, meters);

  @override
  String toString() {
    return 'Radius.internal(meters: $meters)';
  }
}

/// @nodoc
abstract mixin class _$RadiusCopyWith<$Res> implements $RadiusCopyWith<$Res> {
  factory _$RadiusCopyWith(_Radius value, $Res Function(_Radius) _then) =
      __$RadiusCopyWithImpl;
  @override
  @useResult
  $Res call({int meters});
}

/// @nodoc
class __$RadiusCopyWithImpl<$Res> implements _$RadiusCopyWith<$Res> {
  __$RadiusCopyWithImpl(this._self, this._then);

  final _Radius _self;
  final $Res Function(_Radius) _then;

  /// Create a copy of Radius
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? meters = null,
  }) {
    return _then(_Radius(
      meters: null == meters
          ? _self.meters
          : meters // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
