## AdelsonApiCaller

The **AdelsonApiCaller** library is responsible for making authenticated API requests while handling all aspects of token management seamlessly. It ensures that every outgoing request is authorized, automatically refreshing expired tokens or falling back to re-authentication if needed.  

### Key Responsibilities
- **Token Injection:** Automatically attaches the latest access token to every outgoing API request.  
- **Token Refresh:** Transparently handles expired access tokens by refreshing them with a valid refresh token.  
- **Re-authentication:** If both access and refresh tokens are invalid, it falls back to re-login using stored credentials.  
- **Error Handling:** Provides granular error types (e.g., unauthorized, token not provided, invalid URL, unreachable server) to simplify debugging and resilience.  
- **Type-Safe Responses:** Supports generic response models, enabling strongly-typed parsing of API responses with minimal boilerplate.  

### Typical Workflow
1. **Initialize Config:** Use `AdelsonAuthConfig` or `AdelsonAuthPredefinedActions` to configure authentication endpoints and load stored credentials.  
2. **Call API:** Invoke `apiCaller.call(url:params:method:config:)` with the desired request details.  
3. **Automatic Token Handling:**  
   - If access token is valid → request proceeds normally.  
   - If access token is invalid → refresh flow is triggered.  
   - If refresh also fails → login flow is attempted using stored username/password.  
   - If no credentials are available → error is returned immediately.  

### Example Usage
```swift
let apiCaller = AdelsonApiCaller<MyResponseModel>()

do {
    let config = try await AdelsonAuthPredefinedActions.shared.wakeUp(
        appName: "MyApp",
        baseUrl: "https://api.myapp.com/",
        signUpEndpoint: "signup",
        otpEndpoint: "verify-otp",
        loginEndpoint: "login",
        refreshTokenEndPoint: "refresh"
    )
    
    let response = try await apiCaller.call(
        url: "https://api.myapp.com/store",
        params: ["name": "ahmed"],
        method: .post,
        config: config
    )
    
    print("✅ API call successful: \(response)")
} catch {
    print("❌ API call failed with error: \(error)")
}

```

### Benefits

- **Seamless Authentication:** Developers don’t need to worry about manually attaching or refreshing tokens.  
- **Resilient Networking:** Automatically recovers from expired tokens or failed sessions without breaking the user flow.  
- **Test Coverage:** Comprehensive test suite covering valid/invalid tokens, missing refresh tokens, missing credentials, concurrent calls, and performance benchmarks.  
- **Plug-and-Play:** Designed to work directly with `AdelsonAuthManager` and `AdelsonValidator` for a fully integrated authentication ecosystem.  

