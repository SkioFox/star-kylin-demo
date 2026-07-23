#include "mockauthservice.h"

std::optional<UserDefinition> MockAuthService::authenticate(const ManifestData &manifest,
                                                            const QString &username,
                                                            const QString &password) const
{
    const auto it = manifest.users.constFind(username);
    if (it == manifest.users.constEnd() || it.value().password != password) {
        return std::nullopt;
    }
    return it.value();
}
