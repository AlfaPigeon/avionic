// A small downward-pointing caret, like the lubber line on a heading tape.
import QtQuick
import QtQuick.Shapes

Shape {
    id: caret

    property color color: Theme.accent

    width: 9
    height: 5
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        strokeWidth: 0
        strokeColor: "transparent"
        fillColor: caret.color
        startX: 0
        startY: 0
        PathLine { x: caret.width; y: 0 }
        PathLine { x: caret.width / 2; y: caret.height }
        PathLine { x: 0; y: 0 }
    }
}
