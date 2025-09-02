// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android") // pode usar também: id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 🔹 aplica o Google Services no app
}

android {
    namespace = "antonio.joao.shapeup" // alinhei com o applicationId
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "antonio.joao.shapeup"   // package Android do seu app
        minSdk = 23                               // recomendado p/ Firebase atual
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Se, no futuro, der erro de 65k métodos:
        // multiDexEnabled = true
    }

    buildTypes {
        release {
            // Para testes, assina com a debug. Em produção, configure sua keystore.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// (Opcional) Dependências Java/Kotlin específicas do módulo.
// Para Flutter + Firebase, normalmente não precisa declarar nada aqui, pois os
// pacotes do Flutter cuidam das libs nativas via Gradle.
// dependencies {
//     implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
//     implementation("com.google.firebase:firebase-analytics-ktx")
// }
