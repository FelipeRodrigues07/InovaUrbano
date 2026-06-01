using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Infrastructure.Services;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;
using Microsoft.AspNetCore.Identity;

namespace apiUrbanPlanning.UseCase.Users
{
    public class AuthenticateUseCase
    {
        private readonly InterfaceUser _userRepository;
        private readonly JwtTokenService _jwtTokenService;
        private readonly PasswordHasher<User> _passwordHasher;

        public AuthenticateUseCase(
            InterfaceUser userRepository,
            JwtTokenService jwtTokenService)
        {
            _userRepository = userRepository;
            _jwtTokenService = jwtTokenService;
            _passwordHasher = new PasswordHasher<User>();
        }

        public async Task<AuthenticateUserResponse> Execute(RequestAuthenticate request)
        {
            var user = await _userRepository.GetUserByEmail(request.Email);

            if (user == null)
            {
                throw new InvalidOperationException("Email does not exist.");
            }

            var passwordOk = _passwordHasher.VerifyHashedPassword(
                user, user.Password, request.Password);

            if (passwordOk == PasswordVerificationResult.Failed)
            {
                throw new UnauthorizedAccessException("User credentials do not match.");
            }

            return await IssueTokensAsync(user);
        }

        public async Task<AuthenticateUserResponse> Refresh(string refreshToken)
        {
            if (string.IsNullOrWhiteSpace(refreshToken))
            {
                throw new UnauthorizedAccessException("Refresh token is required.");
            }

            var userId = _jwtTokenService.ValidateRefreshToken(refreshToken);
            if (userId == null)
            {
                throw new UnauthorizedAccessException("Invalid or expired refresh token.");
            }

            var user = await _userRepository.GetUserById(userId.Value);
            if (user == null)
            {
                throw new UnauthorizedAccessException("User not found.");
            }

            if (string.IsNullOrEmpty(user.RefreshToken) || user.RefreshTokenExpiresAt == null)
            {
                throw new UnauthorizedAccessException("Session ended. Please sign in again.");
            }

            if (user.RefreshTokenExpiresAt <= DateTime.UtcNow)
            {
                throw new UnauthorizedAccessException("Refresh token expired.");
            }

            var hash = JwtTokenService.HashToken(refreshToken);
            if (!string.Equals(user.RefreshToken, hash, StringComparison.Ordinal))
            {
                throw new UnauthorizedAccessException("Refresh token is no longer valid.");
            }

            return await IssueTokensAsync(user);
        }

        public async Task Revoke(string? refreshToken)
        {
            if (string.IsNullOrWhiteSpace(refreshToken))
            {
                return;
            }

            var userId = _jwtTokenService.ValidateRefreshToken(refreshToken);
            if (userId == null)
            {
                return;
            }

            var user = await _userRepository.GetUserById(userId.Value);
            if (user == null)
            {
                return;
            }

            var hash = JwtTokenService.HashToken(refreshToken);
            if (!string.Equals(user.RefreshToken, hash, StringComparison.Ordinal))
            {
                return;
            }

            user.RefreshToken = null;
            user.RefreshTokenExpiresAt = null;
            await _userRepository.UpdateUser(user);
        }

        private async Task<AuthenticateUserResponse> IssueTokensAsync(User user)
        {
            var refreshPlain = _jwtTokenService.GenerateRefreshToken(user);

            user.RefreshToken = JwtTokenService.HashToken(refreshPlain);
            user.RefreshTokenExpiresAt = _jwtTokenService.RefreshTokenExpiresAt;
            await _userRepository.UpdateUser(user);

            return new AuthenticateUserResponse
            {
                Id = user.Id,
                Name = user.Name,
                Email = user.Email,
                Token = _jwtTokenService.GenerateAccessToken(user),
                RefreshToken = refreshPlain,
                ExpiresIn = _jwtTokenService.AccessTokenLifetimeSeconds,
            };
        }
    }
}
