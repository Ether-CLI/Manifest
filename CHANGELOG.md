## [0.4.6] 2018-08-11

### Fixed
- White space in dependencies array when the first dependency is added to the manifest.
- Fixed adding package to dependencies array when the last package has a trailing comma.


## [0.4.5] 2018-05-18

### Fixed
- Removed rouge `result` output from `Manifest.targets()` method.
- Added missing `from` parameter label to `DependencyVersionType.upToNextMajor` description string.
- Remove dependencies leading horizontal whitespace and leading newline when removing it from the manifest.

## [0.4.4] 2018-05-11

### Fixed
- Regex for putting new dependency in populated `dependencies` array.
- Regex for fetching a target by its name. Added capture group around target name.

## [0.4.3] 2018-05-11

### Fixed
- Fail manifest read if file doesn't exist instead of when it exists

## [0.4.2] 2018-05-05

### Fixed
- Fixed Linux support for `NSMutableString` to `String` initializer.

## [0.4.1] 2018-05-04

### Fixed
- Marked `Manifest` class as `final`.

## [0.4.0] 2018-05-04

### Added
- All primary types conform to `Codable`.


## [0.3.0] 2018-04-07

### Added
- `Manifest.data` which acts as the manifest file instead of data fetched from a real file.
- `Manifest.path` for setting a custom path to the manifest file to interact with.

## [0.2.0] 2018-04-06

### Added
- `Manifest.reset` for setting the manifest file to it's initial state when the project was created.

## [0.1.0] 2018-03-28

### Added
- Pretty much everything. Well, not that much, but this release covers all the basic interactions of the manifest file.