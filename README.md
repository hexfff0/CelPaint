# CelPaint

CelPaint is a specialized painting application designed for cel animation workflows. It provides tools for managing image sequences, coloring, and timeline management, built with performance and efficiency in mind using C++ and Qt 6.

## Features

-   **Image Sequence Management**: Efficiently handle and navigate through sequences of animation frames.
-   **Timeline View**: Visual timeline for managing frame timing and ordering.
-   **Smart Coloring**: Tools for efficient cel painting, including:
    -   **Color Swap**: Easily replace colors across frames.
    -   **Guide Check**: Verify line art and color boundaries.

## Technology Stack

-   **Language**: C++17
-   **Framework**: Qt 6 (Core, Gui, Quick, QuickControls2)
-   **Build System**: CMake 3.16+

## Building from Source

### Prerequisites

-   C++17 compatible compiler (MSVC, GCC, or Clang)
-   Qt 6.x SDK
-   CMake 3.16 or later

### Build Instructions

1.  Clone the repository:
    ```bash
    git clone https://github.com/hexfff0/CelPaint.git
    cd CelPaint
    ```

2.  Create a build directory:
    ```bash
    mkdir build
    cd build
    ```

3.  Configure with CMake:
    ```bash
    cmake ..
    ```
    *Note: You may need to specify your Qt installation path if it's not in your system PATH, e.g., `-DCMAKE_PREFIX_PATH="C:/Qt/6.x/msvc2019_64"`*

4.  Build the project:
    ```bash
    cmake --build .
    ```

## License

MIT License
