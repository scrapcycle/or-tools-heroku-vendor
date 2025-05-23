# OR-Tools Vendor Build for Heroku-24

This repository contains the necessary files to build Google OR-Tools C++ library for Ubuntu 24.04 (Heroku-24 stack) and prepare it for use as a vendored dependency in a Rails application. This build is specifically configured for use with the [or-tools-ruby](https://github.com/ankane/or-tools-ruby) gem.

## Prerequisites

- Docker installed on your local machine
- Basic understanding of Docker commands
- Access to a terminal/shell
- Ruby 2.7+ (for or-tools-ruby gem compatibility)

## Quick Start for Heroku Rails Applications

1. In your Rails application directory, create a vendor directory for OR-Tools:
   ```bash
   mkdir -p vendor
   ```

2. Download the pre-built artifacts (recommended):
   ```bash
   # Clone this repository in a temporary location
   git clone https://github.com/scrapcycle/or-tools-heroku-vendor.git /tmp/or-tools-build
   cd /tmp/or-tools-build
   
   # Build and extract the artifacts
   ./build_and_extract.sh
   
   # Copy artifacts to your Rails app
   cp -r vendor/or-tools /path/to/your/rails/app/vendor/
   
   # Clean up
   cd /path/to/your/rails/app
   rm -rf /tmp/or-tools-build
   ```

3. Update your Rails application's .gitignore:
   ```bash
   echo "vendor/or-tools/" >> .gitignore
   ```

4. Add the or-tools-ruby gem to your Gemfile:
   ```ruby
   gem 'or-tools'
   ```

5. Configure bundler to use the vendored OR-Tools:
   ```bash
   bundle config --local build.or-tools --with-or-tools-dir=vendor/or-tools
   ```

6. Install the gem with vendored build:
   ```bash
   bundle install
   ```

7. Deploy to Heroku:
   ```bash
   git add .
   git commit -m "Add OR-Tools vendor configuration"
   git push heroku main
   ```

## Heroku Deployment Notes

### Option 1: Include Artifacts in Each Deploy (Recommended)

This is the simplest approach:
1. Keep the artifacts in your `vendor/or-tools` directory
2. Add `vendor/or-tools` to your `.slugignore` to exclude it from Git but include it in your Heroku slug
3. Deploy normally with `git push heroku main`

Pros:
- Simple setup
- Works reliably
- No special buildpacks needed
- Compatible with or-tools-ruby gem's vendored build requirements

Cons:
- Increases slug size
- Slightly longer deploy times

### Option 2: Use a Build Cache

For more advanced setups, you can use Heroku's build cache:

1. Create a `.heroku/vendor/or-tools` directory in your app:
   ```bash
   mkdir -p .heroku/vendor/or-tools
   cp -r vendor/or-tools/* .heroku/vendor/or-tools/
   ```

2. Add to your `.gitignore`:
   ```
   vendor/or-tools/
   .heroku/vendor/or-tools/
   ```

3. Create a `bin/heroku-prebuild` script:
   ```bash
   #!/bin/bash
   
   # Check if OR-Tools is already in vendor
   if [ ! -d "vendor/or-tools" ]; then
     echo "Copying OR-Tools from build cache..."
     mkdir -p vendor/or-tools
     cp -r .heroku/vendor/or-tools/* vendor/or-tools/
   fi
   ```

4. Make the script executable:
   ```bash
   chmod +x bin/heroku-prebuild
   ```

Pros:
- Faster deployments after initial setup
- Smaller Git repository

Cons:
- More complex setup
- Depends on build cache persistence

## Building the Docker Image (Optional)

If you need to build the artifacts yourself:

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Build and extract:
   ```bash
   ./build_and_extract.sh
   ```

## Notes

- The build process uses OR-Tools version v9.10 by default, which matches the or-tools-ruby gem's requirements.
- The build artifacts include both the compiled libraries (`lib/`) and header files (`include/`).
- The build artifacts are automatically ignored by git (see .gitignore).
- You should add the `vendor/or-tools` directory to your application's .gitignore to avoid committing large binary files.
- This build includes all necessary dependencies for the or-tools-ruby gem:
  - Coin-OR libraries (CBC, CGL, CLP, etc.)
  - HiGHS solver
  - SCIP solver
  - Abseil libraries
  - Protobuf
  - Eigen3 (for linear algebra)
  - Gflags (for command-line flags)
  - Zlib (for compression)
  - LAPACK (for linear algebra)
  - BLAS (for basic linear algebra)

Note: Glog (Google Logging Library) is not currently included in the build as it's not required by the or-tools-ruby gem. It could be added in the future if needed by adding `libgoogle-glog-dev` to the Dockerfile's package list.

## Troubleshooting

If you encounter any issues:

1. Ensure Docker is running and you have sufficient permissions
2. Check that the OR-Tools version matches your gem requirements
3. Verify the build artifacts are correctly placed in your Rails application
4. Confirm the bundle config command was executed successfully
5. If deploying to Heroku:
   - Check your slug size (`heroku slugs`)
   - Verify the artifacts are in the correct location (`heroku run ls -la vendor/or-tools`)
   - Check build logs for any compilation errors
   - Ensure you're using the Heroku-24 stack (`heroku stack:set heroku-24`)
6. For or-tools-ruby specific issues:
   - Check the gem's [documentation](https://github.com/ankane/or-tools-ruby)
   - Verify the vendored build configuration matches the gem's requirements
   - Ensure all required dependencies are present in the vendor directory 