<template>
<div id="app">
  <header>
    <h1>
      {{ formatted_portfolio_value }}
      <small v-bind:class="portfolio_change_class">{{ formatted_portfolio_change }} ({{ portfolio_percent_change }}%)</small>
    </h1>
    <periods></periods>
  </header>
  <graph></graph>
  <div id="main">
    <ul id="activity-feed">
    </ul>
    <positions></positions>
  </div>
</div>
</template>

<script>
import graph from './graph.vue'
import periods from './periods.vue'
import positions from './positions.vue'
import store from './store'

var currency_formatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
});

export default {
  name: 'app',
  components: {
    graph,
    periods,
    positions
  },
  created: function() {
    this.fetch_data();
  },
  data() {
    return {
      raw_portfolio_value: 0.0,
      shared: store.state
    }
  },
  computed: {
    formatted_portfolio_change: function () {
      let amount = this.shared.raw_portfolio_change;
      let sign = "";

      if (amount > 0) {
        sign = "+"
      }

      return sign + currency_formatter.format(amount);
    },
    formatted_portfolio_value: function () {
      return currency_formatter.format(this.shared.raw_portfolio_value);
    },
    portfolio_change_class: function() {
      return {
        is_positive: (this.shared.raw_portfolio_change > 0),
        is_neutral: (this.shared.raw_portfolio_change == 0),
        is_negative: (this.shared.raw_portfolio_change < 0)
      };
    },
    portfolio_percent_change: function () {
      let result = (this.shared.raw_portfolio_change / this.shared.raw_portfolio_value) * 100;
      return Math.round(result * 100) / 100;
    }
  },
  methods: {
    fetch_data() {
      axios.get('http://192.168.99.100/portfolio').then(response => {
        this.raw_portfolio_value = response.data.portfolio_value;
      });
    }
  },
  mounted: function () {
    this.fetch_data();

    this.interval = setInterval(function () {
      this.fetch_data();
    }.bind(this), 10000);
  },
  beforeDestroy: function(){
    clearInterval(this.interval);
  },
  watch: {
    raw_portfolio_value: function(newValue, oldValue) {
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
          vm.shared.raw_portfolio_value = this.tweeningNumber
        })
        .start()
      animate()
    }
  }
}
</script>

<style lang="scss">
body {
  margin: 0;
}

#app {
  font-family: "Fira Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #4B515D;
  margin-left: auto;
  margin-right: auto;
  max-width: 960px;
}

header {
  display: flex;

  h1 {
    width: 50%;

    small {
      font-size: 0.5em;
      transition: color 0.25s;

      &.is_positive {
        color: #98c379;
      }

      &.is_neutral {
        color: #e5c07b;
      }

      &.is_negative {
        color: #e05252;
      }
    }
  }
}

#main {
  display: flex;

  ul#activity-feed {
    list-style-type: none;
    padding: 0;
    width: 50%;

    li {
    }
  }
}
</style>
