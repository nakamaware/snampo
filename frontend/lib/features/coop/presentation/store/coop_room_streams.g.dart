// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_room_streams.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ルームを監視する (消えたら null)

@ProviderFor(coopRoom)
final coopRoomProvider = CoopRoomFamily._();

/// ルームを監視する (消えたら null)

final class CoopRoomProvider
    extends $FunctionalProvider<AsyncValue<Room?>, Room?, Stream<Room?>>
    with $FutureModifier<Room?>, $StreamProvider<Room?> {
  /// ルームを監視する (消えたら null)
  CoopRoomProvider._({
    required CoopRoomFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'coopRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coopRoomHash();

  @override
  String toString() {
    return r'coopRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Room?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Room?> create(Ref ref) {
    final argument = this.argument as String;
    return coopRoom(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoopRoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coopRoomHash() => r'363f8b3bac9e91126f0cffa10d515429e0b013d9';

/// ルームを監視する (消えたら null)

final class CoopRoomFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Room?>, String> {
  CoopRoomFamily._()
    : super(
        retry: null,
        name: r'coopRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ルームを監視する (消えたら null)

  CoopRoomProvider call(String roomCode) =>
      CoopRoomProvider._(argument: roomCode, from: this);

  @override
  String toString() => r'coopRoomProvider';
}

/// メンバーを監視する (入室順)

@ProviderFor(coopMembers)
final coopMembersProvider = CoopMembersFamily._();

/// メンバーを監視する (入室順)

final class CoopMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RoomMember>>,
          List<RoomMember>,
          Stream<List<RoomMember>>
        >
    with $FutureModifier<List<RoomMember>>, $StreamProvider<List<RoomMember>> {
  /// メンバーを監視する (入室順)
  CoopMembersProvider._({
    required CoopMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'coopMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coopMembersHash();

  @override
  String toString() {
    return r'coopMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RoomMember>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RoomMember>> create(Ref ref) {
    final argument = this.argument as String;
    return coopMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoopMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coopMembersHash() => r'2b88e4822d8188e13411f0d65472c2de659055de';

/// メンバーを監視する (入室順)

final class CoopMembersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RoomMember>>, String> {
  CoopMembersFamily._()
    : super(
        retry: null,
        name: r'coopMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// メンバーを監視する (入室順)

  CoopMembersProvider call(String roomCode) =>
      CoopMembersProvider._(argument: roomCode, from: this);

  @override
  String toString() => r'coopMembersProvider';
}

/// クリアを監視する

@ProviderFor(coopClears)
final coopClearsProvider = CoopClearsFamily._();

/// クリアを監視する

final class CoopClearsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SpotClear>>,
          List<SpotClear>,
          Stream<List<SpotClear>>
        >
    with $FutureModifier<List<SpotClear>>, $StreamProvider<List<SpotClear>> {
  /// クリアを監視する
  CoopClearsProvider._({
    required CoopClearsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'coopClearsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coopClearsHash();

  @override
  String toString() {
    return r'coopClearsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SpotClear>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SpotClear>> create(Ref ref) {
    final argument = this.argument as String;
    return coopClears(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoopClearsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coopClearsHash() => r'd1eb01eeb09b779fb88027818c400b88b1a44c52';

/// クリアを監視する

final class CoopClearsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SpotClear>>, String> {
  CoopClearsFamily._()
    : super(
        retry: null,
        name: r'coopClearsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// クリアを監視する

  CoopClearsProvider call(String roomCode) =>
      CoopClearsProvider._(argument: roomCode, from: this);

  @override
  String toString() => r'coopClearsProvider';
}
