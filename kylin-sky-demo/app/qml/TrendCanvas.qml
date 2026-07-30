import QtQuick 2.12
import KylinSky 1.0

Canvas {
    id: root
    property var series: []
    property var lineColors: [Theme.signal, Theme.gold, "#4F8BFF"]
    property var barValues: []
    property bool fillFirstSeries: false
    property int gridRows: 4
    property color backgroundColor: Theme.surface
    property color gridColor: Theme.softLine

    antialiasing: true

    function rangeFor(values) {
        var low = values[0]
        var high = values[0]
        for (var i = 1; i < values.length; ++i) {
            low = Math.min(low, values[i])
            high = Math.max(high, values[i])
        }
        return { low: low, high: high === low ? high + 1 : high }
    }

    function paintChart() {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.fillStyle = backgroundColor
        ctx.fillRect(0, 0, width, height)
        if (width < 8 || height < 8) return

        var plotBottom = barValues.length ? height * 0.78 : height - 1
        ctx.strokeStyle = gridColor
        ctx.lineWidth = 1
        for (var row = 1; row <= gridRows; ++row) {
            var y = Math.round(row * plotBottom / (gridRows + 1)) + 0.5
            ctx.beginPath()
            ctx.moveTo(0, y)
            ctx.lineTo(width, y)
            ctx.stroke()
        }
        for (var column = 1; column < 6; ++column) {
            var x = Math.round(column * width / 6) + 0.5
            ctx.beginPath()
            ctx.moveTo(x, 0)
            ctx.lineTo(x, plotBottom)
            ctx.stroke()
        }

        if (barValues.length) {
            var maxBar = 1
            for (var barIndex = 0; barIndex < barValues.length; ++barIndex)
                maxBar = Math.max(maxBar, barValues[barIndex])
            var slot = width / barValues.length
            ctx.fillStyle = "#2B7799"
            for (var bar = 0; bar < barValues.length; ++bar) {
                var barHeight = Math.max(2, (barValues[bar] / maxBar) * height * 0.18)
                ctx.fillRect(bar * slot + slot * 0.26, height - barHeight, Math.max(2, slot * 0.48), barHeight)
            }
        }

        for (var line = 0; line < series.length; ++line) {
            var values = series[line]
            if (!values || values.length < 2) continue
            var range = rangeFor(values)
            var pointGap = width / (values.length - 1)
            ctx.beginPath()
            for (var point = 0; point < values.length; ++point) {
                var valueY = plotBottom - ((values[point] - range.low) / (range.high - range.low)) * (plotBottom * 0.80) - plotBottom * 0.10
                if (point === 0) ctx.moveTo(0, valueY)
                else ctx.lineTo(point * pointGap, valueY)
            }
            if (line === 0 && fillFirstSeries) {
                ctx.lineTo(width, plotBottom)
                ctx.lineTo(0, plotBottom)
                ctx.closePath()
                ctx.fillStyle = lineColors[line % lineColors.length]
                ctx.globalAlpha = 0.18
                ctx.fill()
                ctx.globalAlpha = 1
                ctx.beginPath()
                for (var fillPoint = 0; fillPoint < values.length; ++fillPoint) {
                    var fillY = plotBottom - ((values[fillPoint] - range.low) / (range.high - range.low)) * (plotBottom * 0.80) - plotBottom * 0.10
                    if (fillPoint === 0) ctx.moveTo(0, fillY)
                    else ctx.lineTo(fillPoint * pointGap, fillY)
                }
            }
            ctx.strokeStyle = lineColors[line % lineColors.length]
            ctx.lineWidth = line === 0 ? 2.4 : 1.6
            ctx.stroke()
        }
    }

    onPaint: paintChart()
    onSeriesChanged: requestPaint()
    onBarValuesChanged: requestPaint()
    onLineColorsChanged: requestPaint()
    onFillFirstSeriesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
}
