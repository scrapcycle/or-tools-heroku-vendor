#!/bin/bash

# Exit on error
set -e

# Build the Docker image
echo "Building Docker image..."
docker build -t or-tools-builder .

# Create a container from the image
echo "Creating container..."
docker create --name or-tools-container or-tools-builder

# Create vendor directory if it doesn't exist
mkdir -p vendor

# Copy the build artifacts
echo "Extracting build artifacts..."
docker cp or-tools-container:/output ./vendor/or-tools

# Clean up
echo "Cleaning up..."
docker rm or-tools-container

echo "Build and extraction complete!"
echo "The OR-Tools build artifacts are now in ./vendor/or-tools"
echo "You can now configure your Rails application to use these artifacts with:"
echo "bundle config build.or-tools --with-or-tools-dir=vendor/or-tools" 