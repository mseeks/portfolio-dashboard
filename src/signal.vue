<template>
<div class="signal" v-bind:class="signal_unique_class">
  <div class="signal_graph" v-bind:class="signal_unique_class">
  </div>
</div>
</template>

<script>
import store from './store'

export default {
  name: 'signal',
  computed: {
    signal_unique_class() {
      let result = {};

      result[this.position.symbol] = true;

      return result;
    }
  },
  data() {
    return {
      interval: null,
      macd: [],
      signal: [],
      shared: store.state
    };
  },
  methods: {
    setup_graph() {
      let svg = d3.select('.signal_graph.' + this.position.symbol).append('svg');
      let chartWrapper = svg.append('g');
      let macd_path = chartWrapper.append('path').classed('path macd', true);
      let signal_path = chartWrapper.append('path').classed('path signal', true);
      chartWrapper.append('g').classed('x axis', true);
      chartWrapper.append('g').classed('y axis', true);

      let margin = {};

      margin.top = 15;
      margin.right = 20;
      margin.left = 0;
      margin.bottom = 25;

      let width = $('.signal_graph.' + this.position.symbol).width() - margin.left - margin.right;
      let height = 150 - margin.top - margin.bottom;

      svg.attr("class", "graph")
         .attr('width', width + margin.right + margin.left)
         .attr('height', height + margin.top + margin.bottom);
      chartWrapper.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
    },
    fetch_data() {
      let self = this;

      $.get('https://apps.msull92.com/data/portfolio/positions/' + this.position.symbol + '/signals/' + this.shared.period, response => {
        this.macd = response.signals.map(function(macd) {
          return {
            begins_at: d3.time.format.utc("%Y-%m-%d").parse(macd.begins_at),
            value: parseFloat(macd.macd)
          };
        });

        this.signal = response.signals.map(function(signal) {
          return {
            begins_at: d3.time.format.utc("%Y-%m-%d").parse(signal.begins_at),
            value: parseFloat(signal.macd_signal)
          };
        });
      });
    },
    render() {
      // Parse the date / time
      let	parseDate = d3.time.format("%Y-%m-%d").parse,
          formatValue = d3.format(".2f");

      let macd_data = this.macd;
      let signal_data = this.signal;

      //initialize scales
      let xExtent = d3.extent(macd_data.concat(signal_data), function(d,i) { return d.begins_at });
      let yExtent = d3.extent(macd_data.concat(signal_data), function(d,i) { return d.value });

      let x = d3.time.scale().domain(xExtent);
      let y = d3.scale.linear().domain(yExtent);

      //the path generator for the line chart
      let line = d3.svg.line()
        .x(function(d) { return x(d.begins_at) })
        .y(function(d) { return y(d.value) });

      //initialize svg
      let svg = d3.select('.signal_graph.' + this.position.symbol).select('svg');
      let chartWrapper = svg.select('g');
      let macd_path = chartWrapper.select('path.macd').datum(macd_data);
      let signal_path = chartWrapper.select('path.signal').datum(signal_data);

      let margin = {};

      margin.top = 15;
      margin.right = 20;
      margin.left = 0;
      margin.bottom = 25;

      let width = $('.signal_graph.' + this.position.symbol).width() - margin.left - margin.right;
      let height = 150 - margin.top - margin.bottom;

      //initialize axis
      let xAxis = d3.svg.axis().orient('bottom').ticks(4);

      let yAxis = d3.svg.axis().orient('left').ticks(4).tickPadding(5).innerTickSize(-width).outerTickSize(0).tickFormat(formatValue);

      //update x and y scales to new dimensions
      x.range([0, width]);
      y.range([height, 0]);

      //update the axis and line
      xAxis.scale(x);
      yAxis.scale(y);

      svg.select('.x.axis')
        .attr('transform', 'translate(0,' + height + ')')
        .transition()
        .call(xAxis);

      svg.select('.y.axis')
         .transition()
         .call(yAxis);

      macd_path.transition().attr('d', line);
      signal_path.transition().attr('d', line);
    }
  },
  mounted: function() {
    this.setup_graph();
    this.fetch_data();
  },
  props: ['active', 'position'],
  watch: {
    signal: "render",
    active() {
      if (this.active) {
        this.fetch_data();
      }
    },
    'shared.heartbeat' () {
      if (this.active) {
        this.fetch_data();
      }
    },
    'shared.period' () {
      if (this.active) {
        this.fetch_data();
      }
    }
  }
}
</script>

<style lang="scss">
.signal {
  box-sizing: border-box;
  display: block;
  font-family: "Fira Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
  text-align: center;
  vertical-align: middle;
  width: 100%;

  @media (max-width: 576px) {
    overflow: hidden;
  }

  svg {
    margin-right: -50px;
  }

  svg {
    overflow: visible;
  }

  .graph .axis {
    fill: #4B515D;
    font-size: 0.75em;
  }
  .graph .axis line,
  .graph .axis path {
    stroke-width: hairline;
    fill: none;
    stroke: transparentize(#4B515D, 0.75);
    shape-rendering: crispEdges;
  }
  .graph path.path {
    stroke-width: 1px;
    stroke-opacity: 1;
    transition: stroke 0.25s;
    fill: none;
  }

  .signal_graph {
    .graph path.path.macd {
      stroke: #69C2CC;
    }

    .graph path.path.signal {
      stroke: #c678dd;
    }
  }

  g.axis.y path.domain {
    display: none;
  }

  g.axis path.domain {
    opacity: 0.2;
  }

  g.axis line {
    opacity: 0.2;
  }
}
</style>
