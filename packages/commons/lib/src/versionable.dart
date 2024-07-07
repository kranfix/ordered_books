/// Version of a data class that could be stored in a local DB
extension type Version(String version) implements String {}

/// ID of a versioned data class that could be stored in a local DB
extension type VID<T extends Versionable<T>>(String id) implements String {
  /// Creates a [VID] hashing
  factory VID.fromHash(List<Object?> primaryKeys) {
    return VID(Object.hashAll([T, ...primaryKeys]).toString());
  }
}

/// Declares a data class that is versioned
mixin Versionable<T extends Versionable<T>> {
  /// minimun version
  Version get $version;

  /// Identidifier for versioning purpose
  VID<T> get $id;
}

/**  FUTURE WORK: Create schema migration handler  */

// /// {@template commons_VersionHandler}
// /// VersionUpgraderHandler
// /// {@endtemplate}
// class VersionUpgraderHandler<T extends Base, Base extends Versionable<T>> {
//   /// Version handler
//   const VersionUpgraderHandler(List<VersionUpgrader<T, Base>> upgraders)
//       : _upgraders = upgraders;

//   final List<VersionUpgrader<T, Base>> _upgraders;
// }

// abstract interface class VersionUpgrader<T extends Versionable<T>, S> {
//   /// Expected [Version] to sanitize
//   Version get $version;
// }

// /// Serialize and Deserialize
// mixin SerDe<S, D> {
//   /// Serialize from [D] to [S]
//   S serialize(D value);

//   /// Deserialize form [S] to [D]
//   D deserialize(S value);
// }
