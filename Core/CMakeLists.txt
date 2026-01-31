add_library(Core STATIC
    ImageSequence.cpp
    ImageSequence.h
    AppController.cpp
    AppController.h
    ColorSwapModel.cpp
    ColorSwapModel.h
    TimelineModel.cpp
    TimelineModel.h
    ImageSequenceProvider.cpp
    ImageSequenceProvider.h
)

target_link_libraries(Core PUBLIC
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Quick
)

target_include_directories(Core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
