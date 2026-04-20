#!/usr/bin/env bash
# This script takes locally built podman images, retags them with a new version,
# and pushes them to quay.io.
#
# Usage: push_images_to_quay.sh <new-version> <quay-org> <image1:tag1> <image2:tag2> ...
#   $1 new-version  - The new version tag for images on quay.io (e.g., 9.1.0)
#   $2 quay-org     - The Quay.io organization (e.g., bamoe)
#   $3+ images      - Space-separated list of local images with tags
#
# Example:
#   ./push_images_to_quay.sh 9.1.0 bamoe localhost/ibm-bamoe/bamoe-kieserver-rhel9:latest
#
# The script will:
#   1. Check if local images exist
#   2. Extract the image name (removing localhost/ibm-bamoe/ prefix)
#   3. Retag as quay.io/{quay-org}/{image-name}:{new-version}
#   4. Push to quay.io

set -e

NEW_VERSION="${1}"
QUAY_ORG="${2}"
shift 2
IMAGES=("$@")

if [[ -z "${NEW_VERSION}" ]]; then
  echo "ERROR: new-version argument is required as \$1."
  echo "Usage: $0 <new-version> <quay-org> <image1:tag1> <image2:tag2> ..."
  exit 1
fi

if [[ -z "${QUAY_ORG}" ]]; then
  echo "ERROR: quay-org argument is required as \$2."
  echo "Usage: $0 <new-version> <quay-org> <image1:tag1> <image2:tag2> ..."
  exit 1
fi

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "ERROR: At least one image name must be specified."
  echo "Usage: $0 <new-version> <quay-org> <image1:tag1> <image2:tag2> ..."
  exit 1
fi

# Check if podman is available
if ! command -v podman &> /dev/null; then
  echo "ERROR: podman not found. Please install podman."
  exit 1
fi

echo "Using podman"

# ---------------------------------------------------------------------------
# Function: push_images_to_quay
# Takes locally built images, retags, and pushes to quay.io
# ---------------------------------------------------------------------------
push_images_to_quay() {
  echo ""
  echo "=== Pushing Podman Images to Quay.io ==="
  echo "New Version: ${NEW_VERSION}"
  echo "Quay Organization: ${QUAY_ORG}"
  echo "Images to push: ${#IMAGES[@]}"
  echo ""
  
  # Check if user is logged in to quay.io
  echo "Checking Quay.io login status..."
  if ! podman login quay.io --get-login &>/dev/null; then
    echo "WARNING: You may not be logged in to quay.io"
    echo "Please run: podman login quay.io"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
  
  for IMAGE_WITH_TAG in "${IMAGES[@]}"; do
    echo "=========================================="
    echo "Processing: ${IMAGE_WITH_TAG}"
    echo "=========================================="
    
    # Split image name and tag
    IFS=':' read -r IMAGE_FULL_NAME IMAGE_TAG <<< "${IMAGE_WITH_TAG}"
    
    if [[ -z "${IMAGE_TAG}" ]]; then
      echo "  ERROR: Image tag not specified for ${IMAGE_FULL_NAME}"
      echo "  Please use format: image-name:tag"
      exit 1
    fi
    
    # Source image (locally built with full path)
    SOURCE_IMAGE="${IMAGE_FULL_NAME}:${IMAGE_TAG}"
    
    # Extract just the image name (remove localhost/ibm-bamoe/ or any path prefix)
    IMAGE_NAME="${IMAGE_FULL_NAME##*/}"  # Get everything after the last /
    
    # Target image on Quay.io
    TARGET_IMAGE="quay.io/${QUAY_ORG}/${IMAGE_NAME}:${NEW_VERSION}"
    
    echo "  Local Image: ${SOURCE_IMAGE}"
    echo "  Image Name: ${IMAGE_NAME}"
    echo "  Target: ${TARGET_IMAGE}"
    echo ""
    
    # Check if local image exists
    echo "  [1/3] Checking if local image exists..."
    if ! podman image inspect "${SOURCE_IMAGE}" >/dev/null 2>&1; then
      echo "  ERROR: Local image ${SOURCE_IMAGE} not found"
      echo "  Please build the image first or check the image name/tag"
      exit 1
    fi
    echo "  ✓ Local image found"
    echo ""
    
    # Tag the image for Quay.io
    echo "  [2/3] Tagging image with new version..."
    podman tag "${SOURCE_IMAGE}" "${TARGET_IMAGE}"
    echo "  ✓ Tagged as ${TARGET_IMAGE}"
    echo ""
    
    # Push to Quay.io
    echo "  [3/3] Pushing to Quay.io..."
    if ! podman push "${TARGET_IMAGE}"; then
      echo "  ERROR: Failed to push ${TARGET_IMAGE}"
      exit 1
    fi
    echo "  ✓ Successfully pushed ${TARGET_IMAGE}"
    echo ""
  done
  
  echo "=========================================="
  echo "All images pushed to Quay.io successfully!"
  echo "=========================================="
}

# ---------------------------------------------------------------------------
# Main execution
# ---------------------------------------------------------------------------
main() {
  echo "=========================================="
  echo "Push Podman Images to Quay.io"
  echo "=========================================="
  echo "New Version: ${NEW_VERSION}"
  echo "Quay Organization: ${QUAY_ORG}"
  echo "Images: ${IMAGES[*]}"
  echo ""
  
  # Push images to Quay.io
  push_images_to_quay
  
  echo ""
  echo "=========================================="
  echo "Process completed successfully!"
  echo "=========================================="
}

# Run main function
main

# Made with Bob
