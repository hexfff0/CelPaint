add_library(Core STATIC
    ImageSequence.cpp
    # Core Library Sources
    ImageSequence.h
    UndoCommands.cpp
    UndoCommands.h
    AppController.cpp
    AppController.h
    CelPaintTypes.h
    ColorSwapModel.cpp
    ColorSwapModel.h
    GuideCheckModel.cpp
    GuideCheckModel.h
    TimelineModel.cpp
    TimelineModel.h
    ImageSequenceProvider.cpp
    ImageSequenceProvider.h
)

target_link_libraries(Core PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Widgets
)

target_include_directories(Core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

if(WIN32)
    target_link_libraries(Core PRIVATE ole32 shell32 uuid)
endif()
