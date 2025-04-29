# OR-Tools Vendor Build for Heroku-24

This repository contains the necessary files to build Google OR-Tools C++ library for Ubuntu 24.04 (Heroku-24 stack) and prepare it for use as a vendored dependency in a Rails application.

## Prerequisites

- Docker installed on your local machine
- Basic understanding of Docker commands
- Access to a terminal/shell

## Building the Docker Image

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Build the Docker image:
   ```bash
   docker build -t or-tools-builder .
   ```

## Extracting Build Artifacts

After building the Docker image, you can extract the build artifacts using:

```bash
# Create a container from the image
docker create --name or-tools-container or-tools-builder

# Copy the build artifacts to your local machine
docker cp or-tools-container:/output ./vendor/or-tools

# Clean up the container
docker rm or-tools-container
```

## Using in a Rails Application

1. Copy the extracted `vendor/or-tools` directory to your Rails application's `vendor` directory.

2. Configure the or-tools gem to use the vendored build:
   ```bash
   bundle config build.or-tools --with-or-tools-dir=vendor/or-tools
   ```

3. Deploy your application to Heroku-24. The vendored OR-Tools build will be included in your slug.

## Automated Build Script

For convenience, you can use the provided `build_and_extract.sh` script to automate the build and extraction process:

```bash
./build_and_extract.sh
```

This script will:
1. Build the Docker image
2. Create a container
3. Extract the build artifacts
4. Clean up the container

## Notes

- The build process uses OR-Tools version v9.8 by default. If you need a different version, modify the `Dockerfile` accordingly.
- The build artifacts include both the compiled libraries (`lib/`) and header files (`include/`).
- Make sure to commit the `vendor/or-tools` directory to your repository to ensure it's available during deployment.

## Troubleshooting

If you encounter any issues:

1. Ensure Docker is running and you have sufficient permissions
2. Check that the OR-Tools version matches your gem requirements
3. Verify the build artifacts are correctly placed in your Rails application
4. Confirm the bundle config command was executed successfully 