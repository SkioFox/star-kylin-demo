#pragma once

#include "manifestservice.h"

struct NativeLaunchResult {
    enum class Status { Started, Missing, Failed, InvalidConfiguration };

    Status status = Status::Failed;
    qint64 pid = -1;
};

class NativeLauncher final {
public:
    static NativeLaunchResult launch(const ModuleDefinition &module);
};
