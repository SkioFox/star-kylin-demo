#include "mockauthservice.h"

std::optional<UserDefinition> MockAuthService::authenticate(const ManifestData &manifest,
                                                            const QString &username,
                                                            const QString &password) const
{
    const auto user = manifest.users.constFind(username);
    return user == manifest.users.constEnd() || user->password != password ? std::nullopt
                                                                            : std::optional<UserDefinition>(*user);
}
