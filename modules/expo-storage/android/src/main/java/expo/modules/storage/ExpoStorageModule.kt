package expo.modules.storage

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoStorageModule : Module() {
    private val storage = mutableMapOf<String, String>()

    override fun definition() = ModuleDefinition {
        Name("ExpoStorage")

        AsyncFunction("setItem") { key: String, value: String ->
            storage[key] = value
        }

        AsyncFunction("getItem") { key: String ->
            storage[key]
        }

        AsyncFunction("removeItem") { key: String ->
            storage.remove(key)
        }

        AsyncFunction("getAllKeys") {
            storage.keys.toList()
        }
    }
}

