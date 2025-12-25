#!/bin/bash
# Setup script for Verbunkos Sound Gallery

set -e

echo "╔══════════════════════════════════════════════════════╗"
echo "║     Verbunkos Sound Gallery - Setup                  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. Please install Node.js first."
    exit 1
fi

# Create synthdefs directory
mkdir -p synthdefs

# Initialize npm if needed
if [ ! -f "package.json" ]; then
    echo "📦 Initializing npm..."
    npm init -y > /dev/null
fi

# Install SuperSonic
echo "📥 Installing SuperSonic..."
npm install supersonic-scsynth-bundle --save

# Copy SuperSonic bundle to local folder
echo "📁 Setting up SuperSonic folder..."
if [ -d "node_modules/supersonic-scsynth-bundle/dist" ]; then
    rm -rf supersonic
    cp -r node_modules/supersonic-scsynth-bundle/dist supersonic
    echo "   ✓ Copied SuperSonic bundle"
else
    echo "   ⚠ Could not find SuperSonic dist folder"
fi

# Install Vite for development server
echo "📥 Installing Vite..."
npm install vite --save-dev

# Create Vite config
cat > vite.config.js << 'EOF'
export default {
  server: {
    headers: {
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp'
    }
  }
}
EOF
echo "   ✓ Created vite.config.js"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║     Setup Complete!                                  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "1. Compile the SynthDef in SuperCollider:"
echo "   s.boot;"
echo "   \"$(pwd)/compile-synthdefs.scd\".load;"
echo ""
echo "2. Copy the compiled SynthDef:"
echo "   cp synthdefs/cimbalom.scsyndef supersonic/synthdefs/"
echo ""
echo "3. Start the development server:"
echo "   npx vite"
echo ""
echo "4. Open http://localhost:5173 in your browser"
echo ""
