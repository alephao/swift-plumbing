# Plumbing Project

This is all WIP and should not be used by anyone :D

## Getting started

### CLI

Run `swift run Server` and the server will be available on [http://localhost:8080]

### On Xcode

- Open Xcode and run the app

⚠️ For assets in `public` folder won't be found unless you do the following: 

- Open Xcode and edit the schema "Server"
- Go to "Run" > "Options" 
- Check "Use custom working directory"
- Select the root folder of the project
- Now Xcode will be able to find the `public` folder

## Packages

- Server - The entry point
- Router - Configuration of your app's routes
- PublicAssets - Runs the public asset generator as a swift package plugin (configured in Package.swift)
- EnvVars - Boilerplace for reading environment variables from .env.json
- Deps - Initialize dependencies (so it can be used across packages if you want to split Application at some point)
- Application - The app logic

## Server

This package just build and run the application, if you have InjectIII installed, it will use it for "hot-reloading". 

## Routes

### Registering Routes

1. Open Routes.swift and add an enum value for each route
2. Open RootRouter.swift and register each route, check the docs on [pointfreeco/swift-url-routing](https://github.com/pointfreeco/swift-url-routing) 

## PublicAssets

The public assets plugin generates static constant you can use in your code via `PublicAsset.folder.file_ext`, e.g.:

```swift
import PublicAssets

let html = """
  <img src="\(PublicAsset.img.my_image_png)" />
  <script src="\(PublicAsset.js.my_script_js)" />
  """
  
  ##
```

## EnvVars

Reads the .env.json and creates an `EnvVars` value that you can use anywhere in the app via `@Dependency(\.envVars)`.

You can edit the EnvVars struct and add/remove any properties, just follow the example.  

## Deps

This package is used to initialize dependencies to be used on Application, if you split Application in multiple packages, you can import Deps in each package and access the same dependencies

## Application

Here is where we add the logic to our application

- `Application.swift` has the `buildApplication` function that generates a Hummingbird application. Here is where you can start services, add middlewares, run migrations and do whatever you want to do before the server starts accepting connections.
- `RootHandler.swift` bridges the `AsyncResult` type to Swift's special `async` syntax
- `Render.swift` is where you handle the routes registered previously in the `Router` package
- AsyncResult is a wrapper over `async () -> Result<S, F>`, it is more composable than using `async/await` syntax. I might document this one day, but basically u can map/flatmap away instead of using guard-let, optional chaining, switch over result success/failure and u can build your own operators for your specific cases.
