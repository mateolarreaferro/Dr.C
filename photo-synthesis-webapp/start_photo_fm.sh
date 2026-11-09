#!/bin/bash
# Photo Synthesis Collection Web Server Launcher

PORT=8080
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🎨 Starting Photo Synthesis Collection..."
echo "📂 Serving from: $DIR"
echo ""
echo "🌐 Available web apps:"
echo "   Index page:     http://localhost:$PORT/photo_synthesis_index.html"
echo "   FM v1:          http://localhost:$PORT/photo_fm_web.html"
echo "   FM v2:          http://localhost:$PORT/photo_fm_web_v2.html"
echo "   FM v3 FIXED:    http://localhost:$PORT/photo_fm_web_v3_FIXED.html ✨"
echo "   Granular v1:    http://localhost:$PORT/photo_granular_web.html"
echo "   Granular FIXED: http://localhost:$PORT/photo_granular_web_FIXED.html ✨"
echo "   Additive:       http://localhost:$PORT/photo_additive_web.html"
echo "   Multi-Photo:    http://localhost:$PORT/photo_multi_crossfade.html"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

cd "$DIR"

# Open index page in default browser (macOS)
sleep 1 && open "http://localhost:$PORT/photo_synthesis_index.html" &

python3 -m http.server $PORT
