function generateChart(chartData) {
  if (!chartData || !chartData.data)
    return "Invalid data set";
  
  var chartImage;
  switch (chartData.type) {
    case 0: // timeline chart
      chartImage = generateArea(chartData.data);
      break;
    case 1: // stacked timeline chart
      chartImage = generateStackedArea(chartData.data);
      break;
    case 2: // pie chart
      chartImage = generatePie(chartData.data);
      break;
    case 3: // vertical bar data
      chartImage = generateVerticalBar(chartData.data);
      break;
    case 4: // horizontal bar data
      chartImage = generateHorizontalBar(chartData.data);
      break;
    default:
      chartImage = null; 
  }
  if (!chartImage)
    return "Invalid data set"; 
  
  return chartImage.build().getAs("image/png").getBytes();
}

function generateArea(chartData) {
  var data = Charts.newDataTable().addColumn(Charts.ColumnType.STRING, 'Label');
  var legendTextStyleBuilder = Charts.newTextStyle().setColor('#767171').setFontName('noto sans');
  var legendTextStyle = legendTextStyleBuilder.build();
  
  for (var i = 0; i < chartData.data.length; i++)
    data = data.addColumn(Charts.ColumnType.NUMBER, chartData.series[i]);

  for (var i = 0; i < chartData.data[0].length; i++) {
    data = data.addRow([chartData.labels[i]]);
    for (var j = 0; j < chartData.data.length; j++) 
      data = data.setValue(i, j+1, chartData.data[j][i]);
  }

  var chart = Charts.newAreaChart()
    .setColors(['#5cbae5','#f29b1d'])
    .setLegendPosition(Charts.Position.TOP)
    .setLegendTextStyle(legendTextStyle)
    .setDimensions(800, 510)
    .setOption('areaOpacity', 0.05)
    .setOption('chartArea.left','60')
    .setOption('chartArea.right', '60')
    .setOption('hAxis.gridlines.color', '#ffffff')
    .setOption('vAxis.gridlines.color', '#d6d6d6')
    .setOption('vAxis.baselineColor', '#767171')
    .setOption('hAxis.baselineColor', '#767171')
    .setOption('hAxis.textStyle', {color: '#767171'})
    .setOption('vAxis.textStyle', {color: '#767171'})
    .setDataTable(data);

  return chart;
}

function generateStackedArea(chartData) {
  return generateArea(chartData).setStacked();
}

function generatePie(chartData) {
  var data = Charts.newDataTable().addColumn(Charts.ColumnType.STRING, 'Label').addColumn(Charts.ColumnType.NUMBER, 'Value');
  
  var allSum = 0;
  for (var i = 0; i < chartData.data.length; i++)
    allSum += chartData.data[i]; 
  
  
  for (var i = 0; i < chartData.data.length; i++)
    data = data.addRow([chartData.labels[i] + ' ('+percentageRound( chartData.data[i] / allSum * 100) + '%)', chartData.data[i]]);
  
  var pieSliceTextColor = '#FFFFFF';
  if (chartData.data.length < 2)
    pieSliceTextColor = '#767171';

  var chart = Charts.newPieChart()
    .setColors(['#6534ff', '#FFD454', '#62bcfa', '#cdd422', '#e05915', '#1B9D17', '#bccbde', '#431c5d', '#e6e9f0', '#fccdd3','#10A3C2'])
    .setDimensions(400, 300)
    .setDataTable(data)
    .setOption('pieHole', 0.45)
    .setOption('pieSliceTextStyle', { color: pieSliceTextColor, fontName: "noto sans", format: 'short', bold: true})
    .setOption('pieSliceText', 'value')
    .setOption('chartArea.width', '98%')
    .setOption('chartArea.height', '95%')
    .setOption('legend', {alignment: 'center', position: 'right', textStyle: {color:'#767171'}})
  
  return chart;
}
function generateVerticalBar(chartData) {
  var data = Charts.newDataTable().addColumn(Charts.ColumnType.STRING, 'Label')
  var seriesCount = chartData.series.length;
  
  for(var i = 0; i < seriesCount; i++)
    data = data.addColumn(Charts.ColumnType.NUMBER, chartData.series[i]);
  
  for (var i = 0; i < chartData.data[0].length; i++) {
    data = data.addRow([chartData.labels[i]]);
    
    for (var j = 0; j < seriesCount; j++)
      data = data.setValue(i, j+1, chartData.data[j][i]);
  }
  
  var chart = Charts.newColumnChart()
    .setColors(['#6534ff', '#FFD454', '#62bcfa', '#cdd422', '#e05915', '#1B9D17', '#bccbde', '#431c5d', '#e6e9f0', '#fccdd3'])
    .setDimensions(400, 300)
    .setOption('chartArea.left','60')
    .setOption('chartArea.right','60')
    .setOption('vAxis.gridlines.color', '#d6d6d6')
    .setOption('vAxis.baselineColor', '#767171')
    .setOption('hAxis.baselineColor', '#767171')
    .setOption('legend', {textStyle: {color: '#767171'}, position: 'top'})
    .setOption('hAxis.textStyle', {color: '#767171'})
    .setOption('vAxis.textStyle', {color: '#767171'})
    .setDataTable(data);
  
  
  return chart;
}

function generateHorizontalBar(chartData) {
  var data = Charts.newDataTable().addColumn(Charts.ColumnType.STRING, 'Label')
  var seriesCount = chartData.series.length;
  
  for(var i = 0; i < seriesCount; i++) 
    data = data.addColumn(Charts.ColumnType.NUMBER, chartData.series[i]);
  
  for (var i = 0; i < chartData.data[0].length; i++) {
    data = data.addRow([chartData.labels[i]]);
    
    for (var j = 0; j < seriesCount; j++) 
      data = data.setValue(i, j+1, chartData.data[j][i]);
  }
  
  var chart = Charts.newBarChart()
    .setColors(['#6534ff', '#FFD454', '#62bcfa', '#cdd422', '#e05915', '#1B9D17', '#bccbde', '#431c5d', '#e6e9f0', '#fccdd3'])
    .setDimensions(800, 400)
    .setLegendPosition(Charts.Position.TOP)
    .setDataTable(data)
    .setRange(0, 40)
  return chart;
}


function percentageRound(num) {
  if (num >= 0.1)
     return Math.round(num * 10) / 10;
  else
    return "<0.1";
}
