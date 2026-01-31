add_library(Core STATIC
    ImageSequence.cpp
    # Core Library Sources
    ImageSequence.h
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
)

target_include_directories(Core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
