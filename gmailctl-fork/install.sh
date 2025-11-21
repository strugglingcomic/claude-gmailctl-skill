#!/bin/bash
#
# Installation script for gmailctl-fork with email analysis capabilities
#

set -e

INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="gmailctl-analyze"

echo "=== gmailctl-fork Installation ==="
echo ""

# Check for Go
if ! command -v go &> /dev/null; then
    echo "Error: Go is not installed."
    echo "Please install Go 1.24+ from https://golang.org/dl/"
    exit 1
fi

GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
echo "✓ Found Go version $GO_VERSION"

# Build the binary
echo ""
echo "Building gmailctl-analyze..."
go build -o "$BINARY_NAME" ./cmd/gmailctl

if [ ! -f "$BINARY_NAME" ]; then
    echo "Error: Build failed"
    exit 1
fi

echo "✓ Build successful"

# Install to system path
echo ""
echo "Installing to $INSTALL_DIR..."

if [ -w "$INSTALL_DIR" ]; then
    mv "$BINARY_NAME" "$INSTALL_DIR/"
else
    echo "Need sudo privileges to install to $INSTALL_DIR"
    sudo mv "$BINARY_NAME" "$INSTALL_DIR/"
fi

echo "✓ Installed successfully"

# Verify installation
echo ""
echo "Verifying installation..."
if command -v gmailctl-analyze &> /dev/null; then
    echo "✓ gmailctl-analyze is available in PATH"
    gmailctl-analyze version
else
    echo "⚠ Warning: gmailctl-analyze not found in PATH"
    echo "  You may need to add $INSTALL_DIR to your PATH"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Set up OAuth credentials (see README-FORK.md)"
echo "2. Run: gmailctl-analyze init"
echo "3. Run: gmailctl-analyze download"
echo "4. Run: gmailctl-analyze analyze"
echo ""
echo "For more information, see README-FORK.md"
