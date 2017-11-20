<template>
<li>
  <div class="shelf" v-bind:class="{ selected: is_selected, cash: !not_cash }" v-on:click="toggle_selected">
    <div class="context">
      <span class="symbol">
        {{ position.symbol }}
        <small>{{ position.name }}</small>
      </span>
    </div>
    <div class="signal_preview"  v-bind:class="{ selected: is_selected }">
      <microsignal v-bind:position="position" v-bind:active="is_selected" v-if="not_cash"></microsignal>
    </div>
    <div class="holding">
      <span class="holding_value">
        {{ formatted_holding_value }}
        <small class="holding_change" v-bind:class="position_change_class">{{ formatted_holding_change }} ({{ formatted_holding_percent_change }}%)</small>
      </span>
    </div>
    <div class="quantity">
      {{ percent_allocation }}%
      <small v-bind:class="percent_allocation_class">
        <span v-for="n in simple_percent_allocation">◼︎</span>
      </small>
    </div>
  </div>
  <div class="drawer" v-bind:class="{ expanded: is_selected }">
    <signal v-bind:position="position" v-bind:active="is_selected" v-if="not_cash"></signal>
  </div>
</li>
</template>

<script>
import microsignal from './microsignal.vue'
import signal from './signal.vue'
import store from './store'

var currency_formatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
});

export default {
  name: 'position',
  data() {
    return {
      holding_value: 0.0,
      is_selected: false,
      shared: store.state
    };
  },
  components: {
    microsignal,
    signal
  },
  computed: {
    formatted_holding_change() {
      let change = this.position.holding_change;
      let sign = "";

      if (change > 0) {
        sign = "+"
      }

      return sign + currency_formatter.format(change);
    },
    formatted_holding_percent_change() {
      let result = (this.position.holding_change / this.position.cost_basis) * 100;
      return Math.round(result * 100) / 100;
    },
    formatted_holding_value() {
      let value = this.holding_value;

      return currency_formatter.format(value);
    },
    position_change_class() {
      return {
        is_positive: (this.position.holding_change > 0),
        is_neutral: (this.position.holding_change == 0),
        is_negative: (this.position.holding_change < 0)
      };
    },
    quantity() {
      return Math.round(this.position.quantity);
    },
    not_cash() {
      let result = true;

      if (this.position.symbol == "CASH") {
        result = false;
      }

      return result;
    },
    percent_allocation() {
      let result = (this.holding_value / this.shared.raw_portfolio_value) * 100;
      return Math.round(result * 100) / 100;
    },
    simple_percent_allocation() {
      let result = Math.round((this.holding_value / this.shared.raw_portfolio_value) * 10);

      if (result == 0) {
        result++;
      }

      return result;
    },
    percent_allocation_class() {
      return {
        is_high: (this.simple_percent_allocation > 3),
        is_medium: (this.simple_percent_allocation <= 3 && this.simple_percent_allocation > 2 ),
        is_low: (this.simple_percent_allocation <= 2)
      };
    }
  },
  methods: {
    toggle_selected() {
      this.is_selected = !this.is_selected;
    }
  },
  watch: {
    position: function(newValue, oldValue) {
      var vm = this
      function animate () {
        if (TWEEN.update()) {
          requestAnimationFrame(animate)
        }
      }
      new TWEEN.Tween({ tweeningNumber: oldValue.holding_value })
        .easing(TWEEN.Easing.Quadratic.Out)
        .to({ tweeningNumber: newValue.holding_value }, 250)
        .onUpdate(function () {
          vm.holding_value = this.tweeningNumber
        })
        .start()
      animate()
    }
  },
  props: ['position']
}
</script>

<style lang="scss">
ul#positions li {
  margin-bottom: 10px;

  .shelf {
    align-items: center;
    display: flex;
    transition: padding 0.25s ease;

    &:not(.cash) {
      &:hover {
        padding: 0 0 5px 0;
      }

      &.selected {
        padding: 0 0 5px 0;
      }
    }

    .context {
      width: 45%;
    }

    .signal_preview {
      opacity: 0.75;
    }

    .quantity {
      transition: opacity 0.25s ease;
      width: 15%;

      &.selected {
        opacity: 0;
      }
    }

    .signal_preview {
      transition: opacity 0.25s ease;
      width: 10%;

      &.selected {
        opacity: 0;
      }
    }

    &:not(.cash) {
      &:hover:not(.selected) .signal_preview {
        opacity: 1;
      }
    }

    .holding {
      width: 30%;
    }

    .context {
      small {
        display: block;
        opacity: 0.75;
      }
    }

    .quantity {
      text-align: right;

      small {
        display: block;
        transition: color 0.25s;

        &.is_low {
          color: #98c379;
        }

        &.is_medium {
          color: #e5c07b;
        }

        &.is_high {
          color: #e05252;
        }
      }
    }

    .holding {
      text-align: right;

      small {
        display: block;
      }
    }
  }

  .drawer {
    max-height: 0;
    overflow: hidden;
    transition: all 0.25s ease;

    &.expanded {
      padding: 0;
      max-height: 105px;
    }
  }
}

.holding_change {
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
</style>
