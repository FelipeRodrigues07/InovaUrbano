export const UserRoles = {
  Member: 'member',
  MunicipalityAdmin: 'municipality_admin',
  Operator: 'operator',
  SuperAdmin: 'super_admin',
} as const;

export type UserRole = (typeof UserRoles)[keyof typeof UserRoles];

export function isSuperAdmin(role?: string | null): boolean {
  return role === UserRoles.SuperAdmin;
}

export function isMunicipalityStaff(role?: string | null): boolean {
  return (
    role === UserRoles.MunicipalityAdmin || role === UserRoles.Operator
  );
}

export function canAccessAdminPanel(role?: string | null): boolean {
  return isSuperAdmin(role) || isMunicipalityStaff(role);
}
