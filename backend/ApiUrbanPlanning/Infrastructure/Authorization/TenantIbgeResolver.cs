using System.Security.Claims;
using apiUrbanPlanning.Infrastructure.Constants;

namespace apiUrbanPlanning.Infrastructure.Authorization
{
    public static class TenantIbgeResolver
    {
        public static string? GetRole(ClaimsPrincipal user) =>
            user.FindFirst(ClaimTypes.Role)?.Value
            ?? user.FindFirst("role")?.Value;

        public static bool IsSuperAdmin(ClaimsPrincipal user) =>
            GetRole(user) == UserRoles.SuperAdmin;

        public static int? ResolveEffectiveIbgeId(ClaimsPrincipal user, int? requestedIbgeId)
        {
            var role = GetRole(user);

            if (role == UserRoles.SuperAdmin)
            {
                return requestedIbgeId;
            }

            if (role is UserRoles.MunicipalityAdmin or UserRoles.Operator)
            {
                var ibgeClaim = user.FindFirst("ibge_id")?.Value;
                return int.TryParse(ibgeClaim, out var ibgeId) ? ibgeId : null;
            }

            return null;
        }

        public static bool RequiresTenantIbge(ClaimsPrincipal user)
        {
            var role = GetRole(user);
            return role is UserRoles.MunicipalityAdmin or UserRoles.Operator;
        }
    }
}
