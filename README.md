
## Cómo Empezar

Sigue estos pasos para clonar y ejecutar el proyecto en tu máquina local.

### Prerrequisitos

- Tener [Flutter](https://flutter.dev/docs/get-started/install) instalado en tu sistema.
- Un editor de código como [VS Code](https://code.visualstudio.com/) o [Android Studio](https://developer.android.com/studio).
- Si estás en Windows, asegúrate de tener el **Modo de programador** activado.

### Instalación y Ejecución

1.  **Clona el repositorio:**
    ```bash
    git clone https://github.com/AnettVera/wordle_front.git
    ```

2.  **Navega al directorio del proyecto:**
    ```bash
    cd wordle_front/flutter_aplication_1
    ```

3.  **Instala las dependencias:**
    ```bash
    flutter pub get
    ```

4.  **Ejecuta la aplicación:**
    ```bash
    flutter run
    ```

    Selecciona el dispositivo de tu elección (Chrome, Edge, Windows, etc.) cuando se te solicite.

## Estructura del Proyecto

El proyecto está organizado de la siguiente manera:

```
lib/
|-- main.dart           # Punto de entrada de la aplicación
|-- models/             # Modelos de datos (Wordle, letras, etc.)
|-- screens/            # Pantallas principales (juego, perfil, instrucciones)
|-- theme/              # Tema de la aplicación (colores, fuentes)
|-- widgets/            # Widgets reutilizables (cuadrícula, teclado, etc.)
```
