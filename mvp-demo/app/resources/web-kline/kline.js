(function () {
  "use strict";

  var chartElement = document.getElementById("chart");
  var emptyElement = document.getElementById("chart-empty");
  var values = {
    date: document.getElementById("date-value"),
    open: document.getElementById("open-value"),
    high: document.getElementById("high-value"),
    low: document.getElementById("low-value"),
    close: document.getElementById("close-value"),
    volume: document.getElementById("volume-value"),
  };
  var chart;
  var match = window.location.search.match(/[?&]period=(day|week|month)(?:&|$)/);
  var period = match ? match[1] : "day";
  var numberFormat = new Intl.NumberFormat("zh-CN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  var volumeFormat = new Intl.NumberFormat("zh-CN");

  function dateLabel(value) {
    return value.slice(5);
  }

  function weekKey(value) {
    var date = new Date(value + "T00:00:00Z");
    var offset = (date.getUTCDay() + 6) % 7;
    date.setUTCDate(date.getUTCDate() - offset);
    return date.toISOString().slice(0, 10);
  }

  function groupRecords(records, targetPeriod) {
    if (targetPeriod === "day") {
      return records.slice(-60);
    }
    var groups = {};
    var keys = [];
    records.forEach(function (record) {
      var key = targetPeriod === "week" ? weekKey(record.date) : record.date.slice(0, 7);
      if (!groups[key]) {
        groups[key] = [];
        keys.push(key);
      }
      groups[key].push(record);
    });
    var result = keys.map(function (key) {
      var recordsForKey = groups[key];
      var first = recordsForKey[0];
      var last = recordsForKey[recordsForKey.length - 1];
      return {
        date: last.date,
        open: first.open,
        high: Math.max.apply(null, recordsForKey.map(function (item) { return item.high; })),
        low: Math.min.apply(null, recordsForKey.map(function (item) { return item.low; })),
        close: last.close,
        volume: recordsForKey.reduce(function (total, item) { return total + item.volume; }, 0),
      };
    });
    return result.slice(targetPeriod === "week" ? -52 : -18);
  }

  function updateSummary(record) {
    values.date.textContent = record.date;
    values.open.textContent = numberFormat.format(record.open);
    values.high.textContent = numberFormat.format(record.high);
    values.low.textContent = numberFormat.format(record.low);
    values.close.textContent = numberFormat.format(record.close);
    values.volume.textContent = volumeFormat.format(record.volume);
  }

  function setChartOption(records) {
    var labels = records.map(function (record) {
      return period === "month" ? record.date.slice(0, 7) : dateLabel(record.date);
    });
    var candles = records.map(function (record) {
      return [record.open, record.close, record.low, record.high];
    });
    var volumes = records.map(function (record) {
      return {
        value: record.volume,
        itemStyle: { color: record.close >= record.open ? "rgba(182,62,73,.58)" : "rgba(23,128,92,.58)" },
      };
    });
    var start = period === "month" ? 0 : 18;

    chart.setOption({
      animation: false,
      backgroundColor: "#fcfdff",
      textStyle: { color: "#596b82", fontFamily: '"Noto Sans CJK SC", "Microsoft YaHei", sans-serif' },
      axisPointer: { link: [{ xAxisIndex: [0, 1] }], label: { backgroundColor: "#344a63", fontSize: 10 } },
      tooltip: {
        trigger: "axis",
        axisPointer: { type: "cross" },
        formatter: function (items) {
          var candle = items.filter(function (item) { return item.seriesType === "candlestick"; })[0];
          var volume = items.filter(function (item) { return item.seriesType === "bar"; })[0];
          if (!candle) return "";
          var record = records[candle.dataIndex];
          return [
            "<strong>" + record.date + "</strong>",
            "开盘 " + numberFormat.format(record.open),
            "最高 " + numberFormat.format(record.high),
            "最低 " + numberFormat.format(record.low),
            "收盘 " + numberFormat.format(record.close),
            "成交量 " + volumeFormat.format(volume ? volume.value : record.volume),
          ].join("<br>");
        },
        borderColor: "#b9c9da",
        borderWidth: 1,
        backgroundColor: "rgba(255,255,255,.96)",
        textStyle: { color: "#14243a", fontSize: 11 },
      },
      grid: [
        { left: 62, right: 28, top: 24, height: "56%" },
        { left: 62, right: 28, top: "72%", height: "16%" },
      ],
      xAxis: [
        { type: "category", data: labels, boundaryGap: true, axisLine: { lineStyle: { color: "#b9c9da" } }, axisTick: { show: false }, axisLabel: { show: false } },
        { type: "category", gridIndex: 1, data: labels, boundaryGap: true, axisLine: { lineStyle: { color: "#b9c9da" } }, axisTick: { show: false }, axisLabel: { color: "#6c7d91", fontSize: 10, margin: 10 } },
      ],
      yAxis: [
        { scale: true, splitNumber: 5, axisLine: { show: false }, axisTick: { show: false }, axisLabel: { color: "#6c7d91", fontSize: 10, formatter: function (value) { return value.toFixed(0); } }, splitLine: { lineStyle: { color: "#e3eaf2", type: "dashed" } } },
        { scale: true, gridIndex: 1, splitNumber: 2, axisLine: { show: false }, axisTick: { show: false }, axisLabel: { color: "#6c7d91", fontSize: 9, formatter: function (value) { return Math.round(value / 1000) + "k"; } }, splitLine: { lineStyle: { color: "#edf1f6" } } },
      ],
      dataZoom: [{ type: "inside", xAxisIndex: [0, 1], start: start, end: 100, zoomOnMouseWheel: true, moveOnMouseMove: true }],
      series: [
        { name: "K 线", type: "candlestick", data: candles, itemStyle: { color: "#ffffff", color0: "#17805c", borderColor: "#b63e49", borderColor0: "#17805c", borderWidth: 1.4 } },
        { name: "成交量", type: "bar", xAxisIndex: 1, yAxisIndex: 1, data: volumes, barMaxWidth: 10 },
      ],
    }, true);

    updateSummary(records[records.length - 1]);
    chart.off("updateAxisPointer");
    chart.on("updateAxisPointer", function (event) {
      if (event.axesInfo && event.axesInfo.length) {
        var index = event.axesInfo[0].value;
        if (records[index]) updateSummary(records[index]);
      }
    });
  }

  function render(targetPeriod) {
    period = targetPeriod || "day";
    var data = window.STAR_KYLIN_MARKET_DATA;
    var records = data && data.daily ? groupRecords(data.daily, period) : [];
    if (!records.length || !window.echarts) {
      chartElement.hidden = true;
      emptyElement.hidden = false;
      return;
    }
    chartElement.hidden = false;
    emptyElement.hidden = true;
    if (!chart) chart = window.echarts.init(chartElement, null, { renderer: "canvas" });
    setChartOption(records);
    window.requestAnimationFrame(function () { chart.resize(); });
  }

  window.addEventListener("resize", function () { if (chart) chart.resize(); });
  render(period);
}());
