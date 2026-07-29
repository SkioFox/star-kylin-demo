#pragma once

#include "manifestservice.h"

#include <optional>

class MockAuthService final {
public:
    std::optional<UserDefinition> authenticate(const ManifestData &manifest, const QString &username,
                                               const QString &password) const;
};
