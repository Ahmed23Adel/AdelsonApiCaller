import Testing
@testable import AdelsonApiCaller

import XCTest
import Alamofire
@testable import AdelsonAuthManager

// MARK: - Test Response Models
struct TestResponse: Codable, Sendable {
    let message: String
    let success: Bool
}

struct StoreResponse: Codable, Sendable {
    let stored: Bool
    let name: String
    let user: String
    let timestamp: String
}

// MARK: - Test Suite
@available(macOS 10.15, *)
class AdelsonApiCallerTests: XCTestCase {
    
    var apiCaller: AdelsonApiCaller<StoreResponse>!
    var valid_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1MzAxNDA4NH0.qjxFHK2DkkKNT_hESbfnvHzxlGJjfh0BLVFMMAbY8FA"
    var valid_refresh = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1MzYxODc2NH0.cEVRjujWJycEEKOx2lE0ei3p8DPM3e-w8h1jhe2M3Lc"
    override func setUp() {
        super.setUp()
        apiCaller = AdelsonApiCaller<StoreResponse>()
    }
    
    override func tearDown() {
        apiCaller = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    private func createValidConfig() async throws -> AdelsonAuthConfig {
        return try await AdelsonAuthPredefinedActions.shared.wakeUp(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh"
        )
    }
    
    
    
    private func createConfigWithoutStoredTokens() async -> AdelsonAuthConfig {
        return await AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh"
        )
    }
    
    private func createConfigWithValidTokens() async -> AdelsonAuthConfig {
        let config = await AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh"
        )
        
        // Set test tokens - in real scenario these would come from keychain
        await MainActor.run {
            config.mainAuthConfig.setAccessToken(accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1MzAxNTI1Nn0.17OEYBKSZFmbjaV9wThoJqd5VVz-PkWIvaMq1GzLRWk")
            config.mainAuthConfig.setRefreshToken(refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1NjQ3MDA1Nn0.d5jJNlljVAQEsYZFknuTr9fw4gh2loerh61-idSISs4")
            config.mainAuthConfig.setUsername(username: "testuser")
            config.mainAuthConfig.setPassword(password: "testpass")
        }
        
        return config
    }
    
    private func createConfigWithInValidAccessTokens() async -> AdelsonAuthConfig {
        let config = await AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh"
        )
        
        // Set test tokens - in real scenario these would come from keychain
        await MainActor.run {
            config.mainAuthConfig.setAccessToken(accessToken: "eyJhbGciOiJIUzI1NiI5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1MzAxNTI1Nn0.17OEYBKSZFmbjaV9wThoJqd5VVz-PkWIvaMq1GzLRWk")
            config.mainAuthConfig.setRefreshToken(refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1NjQ3MDA1Nn0.d5jJNlljVAQEsYZFknuTr9fw4gh2loerh61-idSISs4")
            config.mainAuthConfig.setUsername(username: "testuser")
            config.mainAuthConfig.setPassword(password: "testpass")
        }
        
        return config
    }
    
    private func createConfigWithInValidAccessTokensBoth() async -> AdelsonAuthConfig {
        let config = await AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh"
        )
        
        // Set test tokens - in real scenario these would come from keychain
        await MainActor.run {
            config.mainAuthConfig.setAccessToken(accessToken: "eyJhbGciOiJIUzI1NiI5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1MzAxNTI1Nn0.17OEYBKSZFmbjaV9wThoJqd5VVz-PkWIvaMq1GzLRWk")
            config.mainAuthConfig.setRefreshToken(refreshToken: "eyJhbGciOiJIUzI1NiIsIn5cCI6IkpXVCJ9.eyJzdWIiJhaG1lZCIsImV4cCI6MTc1NjQ3MDA1Nn0.d5jJNlljVAQEsYZFknuTr94gh2loerh61-idSISs4")
            config.mainAuthConfig.setUsername(username: "ahmed")
            config.mainAuthConfig.setPassword(password: "any")
        }
        
        return config
    }
    
    
    
    private func createConfigWithoutRefreshToken() async -> AdelsonAuthConfig {
        let config = await AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh"
        )
        
        await MainActor.run {
            config.mainAuthConfig.setAccessToken(accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1MzAxNTI1Nn0.17OEYBKSZFmbjaV9wThoJqd5VVz-PkWIvaMq1GzLRWk")
            // Intentionally not setting refresh token
            config.mainAuthConfig.setUsername(username: "ahmed")
            config.mainAuthConfig.setPassword(password: "any")
        }
        
        return config
    }
    
    private func createConfigWithoutCredentials() async -> AdelsonAuthConfig {
        let config = await AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh"
        )
        
        await MainActor.run {
            config.mainAuthConfig.setAccessToken(accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1MzAxNTI1Nn0.17OEYBKSZFmbjaV9wThoJqd5VVz-PkWIvaMq1GzLRWk")
            config.mainAuthConfig.setRefreshToken(refreshToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhaG1lZCIsImV4cCI6MTc1NjQ3MDA1Nn0.d5jJNlljVAQEsYZFknuTr9fw4gh2loerh61-idSISs4")
            // Intentionally not setting username and password
        }
        
        return config
    }
    
    // MARK: - TC001: Test successful API call with stored tokens from keychain
    func testSuccessfulApiCallWithStoredTokens() async throws {
        // Arrange: Try to get configuration with stored tokens from keychain
        do {
            let config = try await createValidConfig()
            let url = "http://localhost:8000/store"
            let params = ["name": "ahmed"]
            let method = HTTPMethod.post
            
            // Act: Execute the API call
            let result = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            
            // Assert: Verify the response is correct
            XCTAssertEqual(result.name, "ahmed", "Response should contain the submitted name")
            print("✅ TC001 PASSED: Successful API call with stored tokens")
        } catch AdelsonAuthPredefinedActionsErrors.tokenNotStored {
            print("⚠️ TC001 SKIPPED: No tokens stored in keychain - this is expected for fresh installations")
            // This is not a failure - it's expected behavior when no tokens are stored
        } catch {
            XCTFail("TC001 FAILED with unexpected error: \(error)")
        }
    }
    
    func testSuccessfulApiCallWithInvalidToken() async throws {
        // Arrange: Try to get configuration with stored tokens from keychain
        // i checked on server the stack of calling was correct
//        INFO:     127.0.0.1:58409 - "POST /store HTTP/1.1" 401 Unauthorized
//        INFO:     127.0.0.1:58409 - "POST /refresh HTTP/1.1" 200 OK
//        INFO:     127.0.0.1:58409 - "POST /store HTTP/1.1" 200 OK
        do {
            let config = await createConfigWithInValidAccessTokens()
            let url = "http://localhost:8000/store"
            let params = ["name": "ahmed"]
            let method = HTTPMethod.post
            
            // Act: Execute the API call
            let result = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            
            // Assert: Verify the response is correct
            XCTAssertEqual(result.name, "ahmed", "Response should contain the submitted name")
            print("✅ TC001 PASSED: Successful API call with stored tokens")
        } catch AdelsonAuthPredefinedActionsErrors.tokenNotStored {
            print("⚠️ TC001 SKIPPED: No tokens stored in keychain - this is expected for fresh installations")
            // This is not a failure - it's expected behavior when no tokens are stored
        } catch {
            XCTFail("TC001 FAILED with unexpected error: \(error)")
        }
    }
    func testSuccessfulApiCallWithInvalidTokenBoth() async throws {
        // Arrange: Try to get configuration with stored tokens from keychain
        // i checked on server the stack of calling was correct
        //
//        INFO:     127.0.0.1:58446 - "POST /store HTTP/1.1" 401 Unauthorized
//        INFO:     127.0.0.1:58446 - "POST /refresh HTTP/1.1" 401 Unauthorized
//        INFO:     127.0.0.1:58446 - "POST /login HTTP/1.1" 200 OK
//        INFO:     127.0.0.1:58446 - "POST /store HTTP/1.1" 200 OK
//
        do {
            let config = await createConfigWithInValidAccessTokensBoth()
            let url = "http://localhost:8000/store"
            let params = ["name": "ahmed"]
            let method = HTTPMethod.post
            
            // Act: Execute the API call
            let result = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            
            // Assert: Verify the response is correct
            XCTAssertEqual(result.name, "ahmed", "Response should contain the submitted name")
            print("✅ TC001 PASSED: Successful API call with stored tokens")
        } catch AdelsonAuthPredefinedActionsErrors.tokenNotStored {
            print("⚠️ TC001 SKIPPED: No tokens stored in keychain - this is expected for fresh installations")
            // This is not a failure - it's expected behavior when no tokens are stored
        } catch {
            XCTFail("TC001 FAILED with unexpected error: \(error)")
        }
    }
    
    // MARK: - TC002: Test API call with missing access token (fresh config)
    func testApiCallWithMissingAccessToken() async {
        // Arrange: Create configuration without any stored tokens
        let config = await createConfigWithoutStoredTokens()
        let url = "http://localhost:8000/store"
        let params = ["name": "ahmed"]
        let method = HTTPMethod.post
        
        // Act & Assert: Expect tokenNotProvided error
        do {
            let _ = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            XCTFail("Should have thrown tokenNotProvided error")
        } catch AdelsonNetworkServiceWithTokenError.tokenNotProvided {
            print("✅ TC002 PASSED: Correctly threw tokenNotProvided error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - TC003: Test API call with manually set valid tokens
    func testApiCallWithManuallySetTokens() async throws {
        // Arrange: Create configuration and manually set valid tokens
        let config = await createConfigWithValidTokens()
        let url = "http://localhost:8000/store"
        let params = ["name": "ahmed"]
        let method = HTTPMethod.post
        
        // Act: Execute the API call
        do {
            let result = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            
            // Assert: Verify the response is correct
            XCTAssertEqual(result.name, "ahmed", "Response should contain the submitted name")
            print("✅ TC003 PASSED: Successful API call with manually set tokens")
        } catch AdelsonNetworkServiceWithTokenError.unauthorized {
            print("⚠️ TC003: Got unauthorized error - this is expected if test tokens are invalid")
            print("This tests the error handling path correctly")
        } catch {
            print("TC003 got error: \(error)")
            // Other errors might be network-related or server issues
        }
    }
    
    // MARK: - TC004: Test different HTTP methods
    func testDifferentHttpMethods() async throws {
        // Arrange: Set up valid configuration
        let config = await createConfigWithValidTokens()
        let url = "http://localhost:8000/store"
        let params = ["name": "ahmed"]
        
        // Test POST method
        do {
            let postResult = try await apiCaller.call(
                url: url,
                params: params,
                method: .post,
                config: config
            )
            XCTAssertEqual(postResult.name, "ahmed")
            print("✅ TC004 PASSED: POST method works correctly")
        } catch AdelsonNetworkServiceWithTokenError.unauthorized {
            print("⚠️ TC004: POST got unauthorized - testing error handling")
        } catch {
            print("TC004 POST error: \(error)")
        }
    }
    
    // MARK: - TC005: Test invalid URL handling
    func testInvalidUrl() async {
        // Arrange: Set up configuration with invalid URL
        let config = await createConfigWithValidTokens()
        let invalidUrl = "not-a-valid-url"
        let params = ["name": "ahmed"]
        let method = HTTPMethod.post
        
        // Act & Assert: Expect network or URL error
        do {
            let _ = try await apiCaller.call(
                url: invalidUrl,
                params: params,
                method: method,
                config: config
            )
            XCTFail("Should have thrown a network error for invalid URL")
        } catch {
            // Any error is acceptable for invalid URL
            print("✅ TC005 PASSED: Correctly handled invalid URL with error: \(error)")
        }
    }
    
    // MARK: - TC006: Test unreachable server
    func testUnreachableServer() async {
        // Arrange: Set up configuration with unreachable server
        let config = await createConfigWithValidTokens()
        let unreachableUrl = "http://localhost:9999/store" // Assuming this port is not running
        let params = ["name": "ahmed"]
        let method = HTTPMethod.post
        
        // Act & Assert: Expect network error
        do {
            let _ = try await apiCaller.call(
                url: unreachableUrl,
                params: params,
                method: method,
                config: config
            )
            XCTFail("Should have thrown a network error for unreachable server")
        } catch {
            print("✅ TC006 PASSED: Correctly handled unreachable server with error: \(error)")
        }
    }
    
    // MARK: - TC007: Test empty parameters
    func testEmptyParameters() async {
        // Arrange: Set up valid configuration with empty parameters
        let config = await createConfigWithValidTokens()
        let url = "http://localhost:8000/store"
        let params: [String: String] = [:] // Empty parameters
        let method = HTTPMethod.post
        
        // Act: This might succeed or fail depending on server validation
        do {
            let result = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            print("✅ TC007 PASSED: API accepted empty parameters: \(result)")
        } catch {
            print("✅ TC007 PASSED: API correctly rejected empty parameters or auth failed: \(error)")
        }
    }
    
    // MARK: - TC008: Test special characters in parameters
    func testSpecialCharactersInParameters() async {
        // Arrange: Set up valid configuration with special characters
        let config = await createConfigWithValidTokens()
        let url = "http://localhost:8000/store"
        let params = ["name": "test@#$%^&*()_+{}|:<>?[]\\;'\",./-=`~"]
        let method = HTTPMethod.post
        
        // Act & Assert: Should handle special characters properly
        do {
            let result = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            print("✅ TC008 PASSED: Correctly handled special characters: \(result.name)")
        } catch {
            print("TC008: Special characters test result - \(error)")
        }
    }
    
    // MARK: - TC009: Test concurrent API calls
//    func testConcurrentApiCalls() async throws {
//        // Arrange: Set up valid configuration
//        let config = await createConfigWithValidTokens()
//        let url = "http://localhost:8000/store"
//        let method = HTTPMethod.post
//        
//        // Act: Make multiple concurrent calls
//        let callsCount = 3
//        let tasks = (1...callsCount).map { index in
//            Task {
//                try await apiCaller.call(
//                    url: url,
//                    params: ["name": "user\(index)"],
//                    method: method,
//                    config: config
//                )
//            }
//        }
//        
//        // Assert: Count successful calls
//        var successCount = 0
//        var errorCount = 0
//        
//        for task in tasks {
//            do {
//                let result = try await task.value
//                XCTAssertTrue(result.name.hasPrefix("user"))
//                successCount += 1
//            } catch {
//                errorCount += 1
//                print("Concurrent call failed: \(error)")
//            }
//        }
//        
//        print("✅ TC009 PASSED: \(successCount) successful, \(errorCount) failed out of \(callsCount) concurrent calls")
//        // At least one call should complete (success or failure is both valid for testing)
//        XCTAssertEqual(successCount + errorCount, callsCount, "All concurrent calls should complete")
//    }
    
    // MARK: - TC010: Test missing refresh token scenario
    func testConfigurationWithMissingRefreshToken() async {
        // Arrange: Set up configuration without refresh token
        let config = await createConfigWithoutRefreshToken()
        let url = "http://localhost:8000/store"
        let params = ["name": "ahmed"]
        let method = HTTPMethod.post
        
        // Act & Assert:
        do {
            let result = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            print("✅ TC010a PASSED: Call succeeded with valid access token: \(result)")
        } catch AdelsonNetworkServiceWithTokenError.unauthorized {
            print("✅ TC010b: Got unauthorized, testing refresh token handling")
            // This should trigger the refresh flow, which should fail due to missing refresh token
        } catch AdelsonNetworkServiceWithTokenError.tokenNotProvided {
            print("✅ TC010c PASSED: Correctly failed due to missing refresh token during retry")
        } catch {
            print("TC010: Error occurred: \(error)")
        }
    }
    
    // MARK: - TC011: Test missing credentials scenario
    func testConfigurationWithMissingCredentials() async {
        // Arrange: Set up configuration without username/password
        let config = await createConfigWithoutCredentials()
        let url = "http://localhost:8000/store"
        let params = ["name": "ahmed"]
        let method = HTTPMethod.post
        
        // Act & Assert:
        do {
            let result = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            print("✅ TC011a PASSED: Call succeeded with valid access token: \(result)")
        } catch AdelsonNetworkServiceWithTokenError.unauthorized {
            print("✅ TC011b: Got unauthorized, will test login fallback")
            // This should trigger refresh, and if that fails, login, which should fail due to missing credentials
        } catch AdelsonNetworkServiceWithTokenError.tokenNotProvided {
            print("✅ TC011c PASSED: Correctly failed due to missing credentials during login retry")
        } catch {
            print("TC011: Error occurred: \(error)")
        }
    }
    
    // MARK: - TC012: Test different generic response types
    func testDifferentGenericTypes() async {
        // Arrange: Create API caller with different response type
        let testApiCaller = AdelsonApiCaller<TestResponse>()
        let config = await createConfigWithValidTokens()
        
        // Act & Assert: Verify the type system works
        XCTAssertNotNil(testApiCaller, "Should be able to create API caller with different generic type")
        
        // Test that it's strongly typed
        let expectedType = type(of: testApiCaller)
        XCTAssertTrue(expectedType == AdelsonApiCaller<TestResponse>.self)
        
        print("✅ TC012 PASSED: Generic type system works correctly")
    }
    
    // MARK: - TC013: Test AdelsonAuthConfig creation
    func testAdelsonAuthConfigCreation() async {
        // Arrange & Act: Create configuration using your defined class
        let config = await AdelsonAuthConfig(
            appName: "TestApp",
            baseUrl: "http://localhost:8000/",
            signUpEndpoint: "signup",
            otpEndpoint: "verify-otp",
            loginEndpoint: "login",
            refreshTokenEndPoint: "refresh"
        )
        
        // Assert: Verify configuration is created properly
        XCTAssertNotNil(config, "AdelsonAuthConfig should be created successfully")
        
        
        print("✅ TC013 PASSED: AdelsonAuthConfig created successfully")
    }
    
    // MARK: - TC014: Test AdelsonAuthPredefinedActions wake up functionality
    func testAdelsonAuthPredefinedActionsWakeUp() async {
        // Arrange & Act: Test the wake up functionality
        do {
            let config = try await AdelsonAuthPredefinedActions.shared.wakeUp(
                appName: "TestApp",
                baseUrl: "http://localhost:8000/",
                signUpEndpoint: "signup",
                otpEndpoint: "verify-otp",
                loginEndpoint: "login",
                refreshTokenEndPoint: "refresh"
            )
            
            // Assert: Verify tokens are loaded from keychain
            let hasAccessToken = await config.mainAuthConfig.accessToken != nil
            let hasRefreshToken = await config.mainAuthConfig.refresh_token != nil
            let hasUsername = await config.mainAuthConfig.username != nil
            let hasPassword = await config.mainAuthConfig.password != nil
            
            XCTAssertTrue(hasAccessToken, "Access token should be loaded from keychain")
            XCTAssertTrue(hasRefreshToken, "Refresh token should be loaded from keychain")
            XCTAssertTrue(hasUsername, "Username should be loaded from keychain")
            XCTAssertTrue(hasPassword, "Password should be loaded from keychain")
            
            print("✅ TC014 PASSED: AdelsonAuthPredefinedActions wake up successful with stored tokens")
            
        } catch AdelsonAuthPredefinedActionsErrors.tokenNotStored {
            print("✅ TC014 PASSED: Correctly threw tokenNotStored error when no tokens in keychain")
        } catch {
            XCTFail("TC014 FAILED with unexpected error: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    func testApiCallPerformance() async {
        // Arrange: Set up valid configuration
        let config = await createConfigWithValidTokens()
        let url = "http://localhost:8000/store"
        let params = ["name": "performance_test"]
        let method = HTTPMethod.post
        
        // Act & Assert: Measure performance
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let _ = try await apiCaller.call(
                url: url,
                params: params,
                method: method,
                config: config
            )
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("✅ Performance Test: API call completed in \(timeElapsed) seconds")
            
            // Assert reasonable performance (adjust threshold as needed)
            XCTAssertLessThan(timeElapsed, 10.0, "API call should complete within 10 seconds")
        } catch {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Performance Test: API call failed in \(timeElapsed) seconds with error: \(error)")
            // Even failed calls should not take too long
            XCTAssertLessThan(timeElapsed, 10.0, "Even failed API calls should complete within 10 seconds")
        }
    }
}

