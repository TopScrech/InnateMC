import Foundation

public func setting<T>(_ path: KeyPath<GlobalPreferences, T>) -> T {
    LauncherData.instance.globalPreferences[keyPath: path]
}

public func setting<T>(_ path: KeyPath<InstancePreferences, T>, for instance: Instance) -> T {
    instance.preferences[keyPath: path]
}