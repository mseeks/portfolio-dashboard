<template>
  <div id="graph">
    <div v-bind:class="portfolio_change_class" id="historicals"></div>
  </div>
</template>

<script>
import store from './store'

export default {
  name: 'graph',
  computed: {
    portfolio_change_class() {
      return {
        is_positive: (this.shared.raw_portfolio_change > 0),
        is_neutral: (this.shared.raw_portfolio_change == 0),
        is_negative: (this.shared.raw_portfolio_change < 0)
      };
    }
  },
  data() {
    return {
      historicals: [],
      shared: store.state,
      raw_portfolio_change: 0.0
    }
  },
  methods: {
    fetch_data() {
      axios.get('http://192.168.99.100/graph/' + this.shared.equity + '/' + this.shared.period).then(response => {
        this.raw_portfolio_change = response.data.current_return;
        this.historicals = response.data.historicals;
      });
    },
    setup_graph() {
      let svg = d3.select('#historicals').append('svg');
      let chartWrapper = svg.append('g');
      let path = chartWrapper.append('path').classed('path', true);
      chartWrapper.append('g').classed('x axis', true);
      chartWrapper.append('g').classed('y axis', true);

      let margin = {};

      margin.top = 30;
      margin.right = 20;
      margin.left = 0;
      margin.bottom = 50;

      let width = $("#historicals").width() - margin.left - margin.right;
      let height = 270 - margin.top - margin.bottom;

      svg.attr("class", "graph")
         .attr('width', width + margin.right + margin.left)
         .attr('height', height + margin.top + margin.bottom);
      chartWrapper.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
    },
    render() {
      // Parse the date / time
      let	parseDate = d3.time.format("%Y-%m-%dT%H:%M:%SZ").parse,
          formatValue = d3.format("$f");

      if (this.shared.period == "1d") {
        formatValue = d3.format("$.2f");
      }

      let data = this.historicals;
      data.forEach(function(d) {
        d.begins_at = parseDate(d.begins_at);
        d.adjusted_close_equity = parseFloat(d.adjusted_close_equity);
      });

      //initialize scales
      let xExtent = d3.extent(data, function(d,i) { return d.begins_at });
      let yExtent = d3.extent(data, function(d,i) { return d.adjusted_close_equity });

      let x = d3.time.scale().domain(xExtent);
      let y = d3.scale.linear().domain(yExtent);

      //the path generator for the line chart
      let line = d3.svg.line()
        .x(function(d) { return x(d.begins_at) })
        .y(function(d) { return y(d.adjusted_close_equity) });

      //initialize svg
      let svg = d3.select('#historicals').select('svg');
      let chartWrapper = svg.select('g');
      let path = chartWrapper.select('path').datum(data);

      let margin = {};

      margin.top = 30;
      margin.right = 20;
      margin.left = 0;
      margin.bottom = 50;

      let width = $("#historicals").width() - margin.left - margin.right;
      let height = 270 - margin.top - margin.bottom;

      //initialize axis
      let xAxis = d3.svg.axis().orient('bottom');
      let yAxis = d3.svg.axis().orient('left').tickPadding(5).innerTickSize(-width).outerTickSize(0).tickFormat(formatValue);

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

      path.transition().attr('d', line);
    }
  },
  watch: {
    historicals: "render",
    '$route' (to, from) {
      this.shared.period = to.params.period;
      this.fetch_data();
    },
    raw_portfolio_change: function(newValue, oldValue) {
      var vm = this
      function animate () {
        if (TWEEN.update()) {
          requestAnimationFrame(animate)
        }
      }
      new TWEEN.Tween({ tweeningNumber: oldValue })
        .easing(TWEEN.Easing.Quadratic.Out)
        .to({ tweeningNumber: newValue }, 250)
        .onUpdate(function () {
          vm.shared.raw_portfolio_change = this.tweeningNumber
        })
        .start()
      animate()
    }
  },
  mounted: function() {
    this.shared.period = this.$route.params.period;

    this.setup_graph();
    this.fetch_data();

    this.interval = setInterval(function () {
      this.fetch_data();
    }.bind(this), 10000);
  },
  beforeDestroy: function() {
    clearInterval(this.interval);
  }
}

// function mousemove() {
//   data = last_6mo_data.concat(first_6mo_data);
//   var x0 = x.invert(d3.mouse(this)[0]),
//       i = bisectDate(data, x0, 1),
//       d0 = data[i - 1],
//       d1 = data[i],
//       d = x0 - d0.Date > d1.Date - x0 ? d1 : d0;
//   focus.attr("transform", "translate(" + x(d.Date) + "," + y(d.Balance) + ")");
//   focus.select("text").text(formatCurrency(d.Balance));
// }

// window.addEventListener('resize', render);

</script>

<style lang="scss">
#historicals {
  box-sizing: border-box;
  display: block;
  font-family: "Fira Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
  text-align: center;
  vertical-align: middle;
  width: 100%;
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
  stroke-width: 2px;
  stroke-opacity: 1;
  fill: none;
}

#historicals {
  .graph path.path {
    transition: stroke 0.25s;
  }

  &.is_positive .graph path.path {
    stroke: #98c379;
  }

  &.is_neutral .graph path.path {
    stroke: #e5c07b;
  }

  &.is_negative .graph path.path {
    stroke: #e05252;
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
</style>
