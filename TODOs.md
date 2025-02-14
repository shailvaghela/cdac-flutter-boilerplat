# Features:

1. API connection mode: `On form submit, check if corresponding API is reachable`. This would result two different flows:
    1. **API Online Mode**: Upload the form data directly to backend.
    2. **API Offline Mode**: Save the form data locally (SQLite for mobile apps; index DB for browser); with periodically upload, powered by track and management of uploaded data.

## Android

-----

## iOS

1. Test result for camera to be verified. All other features are implemented.

-----

## Web

1. Browser localstorage to be debugged. 
    1. Being used to persistenly store logged in state across the entire application.

2. CI/CD pipeline to build and deploy on IIS server.

### Desktop


### Mobile

1. UI Responsiveness for potrait mode.

-----

## Associated Tech Debt
- Single static method to track `API` status. App logic is already implemented to work in offline mode with periodic upload.