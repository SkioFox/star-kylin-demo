#pragma once

#include "manifestservice.h"

class NativeLauncher final {
public:
    static QString launch(const ModuleDefinition &module);
};
